"""On a pharmacy's own server: the monthly health check.

It reads *all* the pharmacy's synced data, on the pharmacy's own PC, and
sends Doaya online only the verdicts: ok / warn / problem per check, with a
count at most. Never a product, a price, a sale, a debt or a customer
(owner's decision: the pharmacy's business is private)."""

import shutil
from collections import defaultdict
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from .backup import latest_backup_time
from .config import Settings
from .models import Device, SyncRow

# Ledgers whose every event must say who, where and when (CLAUDE.md).
LEDGERS = ("stock_events", "debt_events", "till_events", "sales", "supplier_debt_events")
EVENT_FIELDS = ("id", "device_id", "employee_id", "occurred_at")

DEVICE_STALE = timedelta(days=7)
SHIFT_TOO_LONG = timedelta(hours=24)
DISK_WARN_MB, DISK_PROBLEM_MB = 2048, 512


def _time(v) -> datetime | None:
    """The app's ISO text dates ("2026-09-26T10:00:00.000", maybe with Z);
    without a zone they are the device's UTC."""
    if not v or not isinstance(v, str):
        return None
    try:
        t = datetime.fromisoformat(v)
    except ValueError:
        return None
    return t if t.tzinfo else t.replace(tzinfo=UTC)


def _rows(db: Session, pharmacy_id: str, table: str):
    return db.scalars(
        select(SyncRow.data).where(
            SyncRow.pharmacy_id == pharmacy_id,
            SyncRow.table_name == table,
            SyncRow.deleted.is_(False),
        )
    )


def _check(cid: str, count: int, problem: bool = False) -> dict:
    level = "ok" if count == 0 else ("problem" if problem else "warn")
    return {"id": cid, "level": level, "count": count}


def run_checks(
    db: Session,
    settings: Settings,
    pharmacy_id: str,
    now: datetime | None = None,
    disk_free_mb: int | None = None,
) -> dict:
    now = now or datetime.now(UTC)
    checks = []

    last = latest_backup_time(settings)
    if last is None:
        checks.append({"id": "backup", "level": "problem", "count": None})
    else:
        age = now - last
        level = (
            "ok" if age < timedelta(days=2) else "warn" if age < timedelta(days=7) else "problem"
        )
        checks.append({"id": "backup", "level": level, "count": age.days})

    stale = db.scalars(
        select(Device).where(Device.pharmacy_id == pharmacy_id, Device.revoked_at.is_(None))
    ).all()
    checks.append(
        _check(
            "devices_synced",
            sum(1 for d in stale if d.last_seen_at is None or now - d.last_seen_at > DEVICE_STALE),
        )
    )

    on_hand: dict[tuple, int] = defaultdict(int)
    expiry: dict[tuple, datetime] = {}
    for e in _rows(db, pharmacy_id, "stock_events"):
        if not e or not e.get("product_id"):
            continue
        k = (e["product_id"], e.get("batch_id"))
        on_hand[k] += int(e.get("quantity") or 0)
        if t := _time(e.get("expiry")):
            expiry[k] = t
    checks.append(_check("stock_below_zero", sum(1 for q in on_hand.values() if q < 0), True))
    checks.append(
        _check(
            "expired_on_sale",
            sum(1 for k, q in on_hand.items() if q > 0 and k in expiry and expiry[k] < now),
        )
    )

    incomplete = 0
    for table in LEDGERS:
        for e in _rows(db, pharmacy_id, table):
            if not e or any(not e.get(f) for f in EVENT_FIELDS):
                incomplete += 1
    checks.append(_check("events_incomplete", incomplete, True))

    opened: dict[str, datetime] = {}
    closed: set[str] = set()
    for e in _rows(db, pharmacy_id, "till_events"):
        if not e:
            continue
        if e.get("type") == "opened" and (t := _time(e.get("occurred_at"))):
            opened[e.get("shift_id") or e.get("id")] = t
        elif e.get("type") == "closed":
            closed.add(e.get("shift_id"))
    checks.append(
        _check(
            "open_shifts",
            sum(1 for s, t in opened.items() if s not in closed and now - t > SHIFT_TOO_LONG),
        )
    )

    if disk_free_mb is None:
        disk_free_mb = shutil.disk_usage(settings.data_dir).free // (1024 * 1024)
    level = (
        "problem"
        if disk_free_mb < DISK_PROBLEM_MB
        else "warn"
        if disk_free_mb < DISK_WARN_MB
        else "ok"
    )
    checks.append({"id": "disk", "level": level, "count": disk_free_mb})

    return {"ran_at": now.isoformat(), "checks": checks}
