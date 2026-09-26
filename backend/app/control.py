"""The platform owner's control over each pharmacy, and the heartbeat.

Central server: `POST /pharmacy-api/heartbeat`. A pharmacy's server reports
its technical state (versions, devices, backups, errors; never business
data) and gets back its control state and licence.

Pharmacy's own server: sends the heartbeat with every shelf publish, keeps
the answer in `<data_dir>/control.json`, and tells its devices through
`GET /control` whether the system is locked:
- «stopped» or «removed» by the owner → locked;
- no answer from Doaya online for more than the licence days → locked.
The app locks selling and stock changes at its next start, never in the
middle of a sale; reading and exporting the pharmacy's data stay open."""

import json
import shutil
from datetime import UTC, datetime, timedelta
from pathlib import Path

import httpx
from fastapi import APIRouter, Request
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from . import __version__
from .backup import latest_backup_time
from .config import Settings
from .deps import Caller, DbSession, error
from .health_check import run_checks
from .models import Device, Pharmacy, PharmacyKey
from .security import hash_secret

router = APIRouter(tags=["control"])

# Doaya online asks for a health check this often (and when the owner asks).
HEALTH_EVERY = timedelta(days=30)
# What the owner can set a pharmacy to; the pharmacy side locks on these.
LOCKED_STATES = {"stopped", "removed"}


def _now() -> datetime:
    return datetime.now(UTC)


# ─── Central server ─────────────────────────────────────────────────────────


class DeviceState(BaseModel):
    name: str = Field(max_length=200)
    last_seen_at: datetime | None = None


class HealthCheck(BaseModel):
    id: str = Field(max_length=40)
    level: str = Field(pattern="^(ok|warn|problem)$")
    count: int | None = None


class HealthReport(BaseModel):
    ran_at: datetime
    checks: list[HealthCheck] = Field(max_length=30)


class HeartbeatIn(BaseModel):
    server_version: str = Field(max_length=40)
    devices: list[DeviceState] = Field(default=[], max_length=50)
    last_backup_at: datetime | None = None
    backup_error: str | None = Field(default=None, max_length=500)
    shelf_error: str | None = Field(default=None, max_length=500)
    disk_free_mb: int | None = None
    health: HealthReport | None = None


class ControlOut(BaseModel):
    state: str
    reason: str | None
    licence_days: int
    # Until when the pharmacy's system works without hearing from us.
    licence_until: datetime
    health_wanted: bool


def _heartbeat_pharmacy(request: Request, db: Session) -> Pharmacy:
    """Like the other pharmacy-api calls, but answered in every state, so
    a suspended or stopped pharmacy learns it. A removed pharmacy's revoked
    key still hears that it was removed; any other revoked key doesn't."""
    auth = request.headers.get("authorization", "")
    if not auth.lower().startswith("pharmacy "):
        raise error(401, "no_pharmacy_key")
    key = db.scalar(
        select(PharmacyKey).where(PharmacyKey.key_hash == hash_secret(auth[9:].strip()))
    )
    if key is None:
        raise error(401, "bad_pharmacy_key")
    ph = db.get(Pharmacy, key.pharmacy_id)
    if ph is None or (key.revoked_at is not None and ph.status != "removed"):
        raise error(401, "bad_pharmacy_key")
    return ph


@router.post("/pharmacy-api/heartbeat", response_model=ControlOut)
def heartbeat(body: HeartbeatIn, request: Request, db: DbSession) -> ControlOut:
    ph = _heartbeat_pharmacy(request, db)
    now = _now()
    if ph.status != "removed":
        ph.last_heartbeat_at = now
        ph.heartbeat = body.model_dump(mode="json", exclude={"health"})
        if body.health is not None:
            ph.health = body.health.model_dump(mode="json")
            ph.health_at = now
            ph.health_requested = False
    db.commit()
    locked = ph.status in LOCKED_STATES
    wanted = not locked and (
        ph.health_requested or ph.health_at is None or now - ph.health_at > HEALTH_EVERY
    )
    return ControlOut(
        state=ph.status,
        reason=ph.status_reason,
        licence_days=ph.licence_days,
        licence_until=now if locked else now + timedelta(days=ph.licence_days),
        health_wanted=wanted,
    )


# ─── Pharmacy's own server ──────────────────────────────────────────────────


def control_file(settings: Settings) -> Path:
    return Path(settings.data_dir) / "control.json"


def read_control(settings: Settings) -> dict | None:
    f = control_file(settings)
    if not f.exists():
        return None
    try:
        return json.loads(f.read_text())
    except (OSError, ValueError):
        return None


def _write_control(settings: Settings, data: dict) -> None:
    f = control_file(settings)
    f.parent.mkdir(parents=True, exist_ok=True)
    tmp = f.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False))
    tmp.replace(f)


def control_state(settings: Settings, now: datetime | None = None) -> dict:
    """What the devices are told. Never linked to Doaya online: not
    controlled. Once linked, the last answer counts even after unlinking,
    so removing the link doesn't lift a lock or the licence."""
    now = now or _now()
    c = read_control(settings)
    if c is None:
        return {"state": "standalone", "locked": False, "reason": None, "licence_until": None}
    until = datetime.fromisoformat(c["licence_until"])
    expired = now > until
    return {
        "state": c["state"],
        "reason": c.get("reason"),
        "licence_until": c["licence_until"],
        "checked_at": c.get("checked_at"),
        "licence_expired": expired,
        "locked": c["state"] in LOCKED_STATES or expired,
    }


def _local_pharmacy(db: Session) -> str | None:
    return db.scalar(select(Pharmacy.id).order_by(Pharmacy.created_at).limit(1))


def heartbeat_body(
    db: Session,
    settings: Settings,
    *,
    backup_error: str | None = None,
    shelf_error: str | None = None,
    with_health: bool = False,
    disk_free_mb: int | None = None,
) -> dict:
    pid = _local_pharmacy(db)
    if disk_free_mb is None:
        Path(settings.data_dir).mkdir(parents=True, exist_ok=True)
        disk_free_mb = shutil.disk_usage(settings.data_dir).free // (1024 * 1024)
    devices = (
        db.scalars(
            select(Device)
            .where(Device.pharmacy_id == pid, Device.revoked_at.is_(None))
            .order_by(Device.linked_at)
        ).all()
        if pid
        else []
    )
    last_backup = latest_backup_time(settings)
    body = {
        "server_version": __version__,
        "devices": [
            {
                "name": d.name,
                "last_seen_at": d.last_seen_at.isoformat() if d.last_seen_at else None,
            }
            for d in devices[:50]
        ],
        "last_backup_at": last_backup.isoformat() if last_backup else None,
        "backup_error": backup_error,
        "shelf_error": shelf_error,
        "disk_free_mb": disk_free_mb,
    }
    if with_health and pid:
        body["health"] = run_checks(db, settings, pid, disk_free_mb=disk_free_mb)
    return body


def send_heartbeat(
    db: Session,
    settings: Settings,
    client: httpx.Client | None = None,
    *,
    backup_error: str | None = None,
    shelf_error: str | None = None,
    disk_free_mb: int | None = None,
) -> dict:
    """Reports to Doaya online and keeps its answer; runs the health check
    when the last answer asked for one. Raises httpx errors offline (the
    last answer and its licence then keep counting)."""
    previous = read_control(settings) or {}
    own = client is None
    client = client or httpx.Client(base_url=settings.central_url, timeout=60)
    try:
        body = heartbeat_body(
            db,
            settings,
            backup_error=backup_error,
            shelf_error=shelf_error,
            with_health=previous.get("health_wanted", True),
            disk_free_mb=disk_free_mb,
        )
        r = client.post(
            "/pharmacy-api/heartbeat",
            json=body,
            headers={"authorization": f"Pharmacy {settings.central_key}"},
        )
        r.raise_for_status()
    finally:
        if own:
            client.close()
    answer = r.json()
    _write_control(
        settings,
        {
            "state": answer["state"],
            "reason": answer.get("reason"),
            "licence_days": answer["licence_days"],
            "licence_until": answer["licence_until"],
            "health_wanted": answer["health_wanted"],
            "checked_at": _now().isoformat(),
        },
    )
    return answer


@router.get("/control")
def device_control(_: Caller, request: Request) -> dict:
    """For the pharmacy's devices: is the system locked, and why."""
    return control_state(request.app.state.settings)
