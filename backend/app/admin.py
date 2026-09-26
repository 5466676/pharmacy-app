"""The platform owner's admin panel (central server): sign-in, the overview,
pharmacies and what the owner can do to them, and their performance.

The owner sees whether each pharmacy is running and how fast it answers
patients, never its stock, medicines, sales, profits or debts (owner's
decision). Patients appear only as counts."""

import re
import secrets
import time
from datetime import UTC, date, datetime, timedelta
from typing import Annotated, Literal

from fastapi import APIRouter, Depends, Request
from pydantic import BaseModel, Field
from sqlalchemy import and_, extract, func, select
from sqlalchemy.orm import Session

from . import __version__
from .central import list_pharmacy, new_pharmacy_key
from .deps import DbSession, error
from .models import (
    AdminAction,
    AdminSession,
    AiLog,
    Consultation,
    PatientOrder,
    PatientProfile,
    Pharmacy,
    PharmacyKey,
    PharmacyListing,
    User,
)
from .security import (
    Principal,
    check_password,
    hash_secret,
    issue_access_token,
    new_device_secret,
    new_id,
    normalize_phone,
    read_access_token,
)

router = APIRouter(prefix="/admin", tags=["admin"])

ADMIN = "admin"
# Days and months are counted in Syria's time.
TZ = "Asia/Damascus"
# A pharmacy is "connected" when its server checked in this recently (it
# does every 10 minutes).
CONNECTED_WITHIN = timedelta(minutes=30)
# Rewards: the share of cases answered within this many minutes.
ANSWER_TARGET_MINUTES = 10
# Fewer cases than this in a month: not ranked (too few to be fair).
MIN_CASES_TO_RANK = 10
# Review queue: what the admin should look at.
REVIEW_KINDS = ("red_flag", "guard_block", "correction", "patient_edit", "llm_down")


def _now() -> datetime:
    return datetime.now(UTC)


# ─── Sign-in ────────────────────────────────────────────────────────────────


class LoginIn(BaseModel):
    phone: str
    password: str


class TokenIn(BaseModel):
    session_token: str


class AdminOut(BaseModel):
    id: str
    name: str


class SessionOut(BaseModel):
    admin: AdminOut
    session_token: str
    access_token: str
    expires_in: int


class TokenOut(BaseModel):
    access_token: str
    expires_in: int


def _access(request: Request, user: User, session_id: str) -> tuple[str, int]:
    s = request.app.state.settings
    p = Principal(user.id, session_id, "", ADMIN)
    return issue_access_token(p, s.jwt_secret, s.access_token_minutes), s.access_token_minutes * 60


def current_admin(request: Request, db: DbSession) -> Principal:
    """A signed-in admin. Pharmacy devices, pharmacy servers and patients
    are all refused here (and admins by their endpoints)."""
    auth = request.headers.get("authorization", "")
    if not auth.lower().startswith("bearer "):
        raise error(401, "not_signed_in")
    p = read_access_token(auth[7:], request.app.state.settings.jwt_secret)
    if p is None:
        raise error(401, "token_expired")
    if p.role != ADMIN:
        raise error(403, "admins_only")
    session = db.get(AdminSession, p.device_id)
    user = db.get(User, p.user_id)
    if (
        session is None
        or session.revoked_at is not None
        or user is None
        or not user.active
        or user.role != ADMIN
    ):
        raise error(401, "signed_out")
    return p


Admin = Annotated[Principal, Depends(current_admin)]


@router.post("/login", response_model=SessionOut)
def login(body: LoginIn, db: DbSession, request: Request) -> SessionOut:
    limiter = request.app.state.login_limiter
    phone = normalize_phone(body.phone)
    key = f"admin|{phone}|{request.client.host if request.client else ''}"
    if limiter.blocked(key):
        raise error(429, "too_many_attempts")
    user = db.scalar(select(User).where(User.phone == phone, User.role == ADMIN))
    if user is None or not user.active or not check_password(user.password_hash, body.password):
        limiter.failed(key)
        raise error(401, "bad_credentials")
    limiter.succeeded(key)
    secret = new_device_secret()
    session = AdminSession(id=new_id(), user_id=user.id, token_hash=hash_secret(secret))
    db.add(session)
    db.commit()
    token, expires = _access(request, user, session.id)
    return SessionOut(
        admin=AdminOut(id=user.id, name=user.name),
        session_token=f"{session.id}.{secret}",
        access_token=token,
        expires_in=expires,
    )


@router.post("/token", response_model=TokenOut)
def token(body: TokenIn, db: DbSession, request: Request) -> TokenOut:
    session_id, _, secret = body.session_token.partition(".")
    session = db.get(AdminSession, session_id)
    if (
        session is None
        or session.revoked_at is not None
        or not secrets.compare_digest(session.token_hash, hash_secret(secret))
    ):
        raise error(401, "signed_out")
    user = db.get(User, session.user_id)
    if user is None or not user.active or user.role != ADMIN:
        raise error(401, "account_disabled")
    session.last_seen_at = _now()
    db.commit()
    access, expires = _access(request, user, session.id)
    return TokenOut(access_token=access, expires_in=expires)


@router.get("/me", response_model=AdminOut)
def me(a: Admin, db: DbSession) -> AdminOut:
    user = db.get(User, a.user_id)
    return AdminOut(id=user.id, name=user.name)


@router.post("/logout")
def logout(a: Admin, db: DbSession) -> dict:
    db.get(AdminSession, a.device_id).revoked_at = _now()
    db.commit()
    return {"ok": True}


# ─── Response times ─────────────────────────────────────────────────────────

_minutes = extract("epoch", Consultation.first_action_at - Consultation.sent_at) / 60.0


def _pct(q: float):
    return func.percentile_cont(q).within_group(_minutes)


def _local_day(col):
    return func.date(func.timezone(TZ, col))


def _period_start(days: int) -> datetime:
    return _now() - timedelta(days=days)


def _day_start_utc(d: date) -> datetime:
    """Midnight in Syria on [d], as a UTC time (Syria has no DST since 2022:
    UTC+3)."""
    return datetime(d.year, d.month, d.day, tzinfo=UTC) - timedelta(hours=3)


def _today_start() -> datetime:
    return _day_start_utc((_now() + timedelta(hours=3)).date())


def _round(v) -> float | None:
    return None if v is None else round(float(v), 1)


# ─── Overview ───────────────────────────────────────────────────────────────


@router.get("/overview")
def overview(_: Admin, db: DbSession, days: int = 30) -> dict:
    days = max(1, min(days, 365))
    since, today = _period_start(days), _today_start()
    by_status = {
        k: n for k, n in db.execute(select(Pharmacy.status, func.count()).group_by(Pharmacy.status))
    }
    connected = db.scalar(
        select(func.count()).where(Pharmacy.last_heartbeat_at > _now() - CONNECTED_WITHIN)
    )
    new_pharmacies = db.scalar(select(func.count()).where(Pharmacy.created_at > since))
    patients = db.scalar(select(func.count()).where(User.role == "patient"))
    active_patients = db.scalar(
        select(func.count(func.distinct(Consultation.patient_id))).where(
            Consultation.created_at > since
        )
    )
    new_patients = db.scalar(
        select(func.count()).where(User.role == "patient", User.created_at > since)
    )
    sent = Consultation.sent_at.is_not(None)
    today_q = db.execute(
        select(
            func.count(),
            func.count().filter(Consultation.urgent),
            func.count().filter(and_(Consultation.urgent, Consultation.first_action_at.is_(None))),
        ).where(sent, Consultation.sent_at >= today)
    ).one()
    orders_today = db.scalar(select(func.count()).where(PatientOrder.created_at >= today))
    answered = Consultation.first_action_at.is_not(None)
    period = db.execute(
        select(_pct(0.5), _pct(0.9), func.count()).where(
            sent, answered, Consultation.sent_at > since
        )
    ).one()
    unanswered = db.scalar(
        select(func.count()).where(
            sent, Consultation.first_action_at.is_(None), Consultation.sent_at > since
        )
    )
    day = _local_day(Consultation.sent_at).label("day")
    series = db.execute(
        select(day, _pct(0.5), _pct(0.9), func.count())
        .where(sent, answered, Consultation.sent_at > since)
        .group_by(day)
        .order_by(day)
    ).all()
    review = db.scalar(
        select(func.count()).where(AiLog.kind.in_(REVIEW_KINDS), AiLog.reviewed.is_(False))
    )
    return {
        "days": days,
        "pharmacies": {
            "by_status": {
                k: by_status.get(k, 0)
                for k in ("active", "pending", "suspended", "stopped", "removed")
            },
            "connected": connected,
            "new": new_pharmacies,
        },
        "patients": {"registered": patients, "active": active_patients, "new": new_patients},
        "today": {
            "consultations": today_q[0],
            "urgent": today_q[1],
            "urgent_unanswered": today_q[2],
            "orders": orders_today,
        },
        "response": {
            "median_minutes": _round(period[0]),
            "p90_minutes": _round(period[1]),
            "answered": period[2],
            "unanswered": unanswered,
            "target_minutes": ANSWER_TARGET_MINUTES,
            "by_day": [
                {"day": d.isoformat(), "median": _round(m), "p90": _round(p), "count": n}
                for d, m, p, n in series
            ],
        },
        "review_waiting": review,
    }


# ─── Pharmacies ─────────────────────────────────────────────────────────────


def _connected(ph: Pharmacy) -> bool:
    return ph.last_heartbeat_at is not None and ph.last_heartbeat_at > _now() - CONNECTED_WITHIN


def _health_level(health: dict | None) -> str | None:
    """The worst verdict of the last health check: ok | warn | problem."""
    if not health:
        return None
    levels = [c.get("level") for c in health.get("checks", [])]
    for worst in ("problem", "warn"):
        if worst in levels:
            return worst
    return "ok"


def _brief(ph: Pharmacy, li: PharmacyListing | None, patients: int, median) -> dict:
    return {
        "id": ph.id,
        "name": ph.name,
        "status": ph.status,
        "status_reason": ph.status_reason,
        "city": li.city if li else None,
        "code": li.code if li else None,
        "listed": bool(li and li.listed),
        "patients": patients,
        "median_minutes": _round(median),
        "created_at": ph.created_at.isoformat(),
        "last_heartbeat_at": ph.last_heartbeat_at.isoformat() if ph.last_heartbeat_at else None,
        "connected": _connected(ph),
        "licence_days": ph.licence_days,
        "health": _health_level(ph.health),
        "health_requested": ph.health_requested,
    }


def _patients_by_pharmacy(db: Session) -> dict[str, int]:
    rows = db.execute(
        select(PatientProfile.pharmacy_id, func.count())
        .where(PatientProfile.pharmacy_id.is_not(None))
        .group_by(PatientProfile.pharmacy_id)
    )
    return {k: n for k, n in rows}


def _median_by_pharmacy(db: Session, since: datetime) -> dict[str, float]:
    rows = db.execute(
        select(Consultation.pharmacy_id, _pct(0.5))
        .where(Consultation.first_action_at.is_not(None), Consultation.sent_at > since)
        .group_by(Consultation.pharmacy_id)
    )
    return {k: m for k, m in rows}


@router.get("/pharmacies")
def pharmacies(_: Admin, db: DbSession, q: str | None = None, status: str | None = None) -> list:
    stmt = select(Pharmacy, PharmacyListing).join(
        PharmacyListing, PharmacyListing.pharmacy_id == Pharmacy.id, isouter=True
    )
    if status:
        stmt = stmt.where(Pharmacy.status.in_(status.split(",")))
    if q and q.strip():
        like = f"%{q.strip()}%"
        stmt = stmt.where(
            Pharmacy.name.ilike(like)
            | PharmacyListing.city.ilike(like)
            | PharmacyListing.code.ilike(like)
        )
    patients = _patients_by_pharmacy(db)
    medians = _median_by_pharmacy(db, _period_start(30))
    rows = db.execute(stmt.order_by(Pharmacy.created_at)).all()
    return [_brief(ph, li, patients.get(ph.id, 0), medians.get(ph.id)) for ph, li in rows]


def _pharmacy(db: Session, pid: str) -> Pharmacy:
    ph = db.get(Pharmacy, pid)
    if ph is None:
        raise error(404, "pharmacy_not_found")
    return ph


def _detail(db: Session, ph: Pharmacy) -> dict:
    li = db.get(PharmacyListing, ph.id)
    patients = _patients_by_pharmacy(db).get(ph.id, 0)
    median = _median_by_pharmacy(db, _period_start(30)).get(ph.id)
    actions = db.execute(
        select(AdminAction, User.name)
        .join(User, User.id == AdminAction.admin_id)
        .where(AdminAction.pharmacy_id == ph.id)
        .order_by(AdminAction.id.desc())
        .limit(50)
    ).all()
    keys = db.scalar(
        select(func.count()).where(
            PharmacyKey.pharmacy_id == ph.id, PharmacyKey.revoked_at.is_(None)
        )
    )
    return {
        **_brief(ph, li, patients, median),
        "address": li.address if li else None,
        "phone": li.phone if li else None,
        "hours": li.hours if li else None,
        "active_keys": keys,
        "heartbeat": ph.heartbeat,
        "health_report": ph.health,
        "health_at": ph.health_at.isoformat() if ph.health_at else None,
        "actions": [
            {
                "action": a.action,
                "reason": a.reason,
                "detail": a.detail,
                "by": name,
                "at": a.created_at.isoformat(),
            }
            for a, name in actions
        ],
    }


@router.get("/pharmacies/{pid}")
def pharmacy(pid: str, _: Admin, db: DbSession) -> dict:
    return _detail(db, _pharmacy(db, pid))


_CODE = re.compile(r"^[A-Z0-9]{3,12}$")


class NewPharmacyIn(BaseModel):
    name: str = Field(min_length=2, max_length=200)
    city: str = Field(min_length=2, max_length=80)
    code: str = Field(min_length=3, max_length=12)
    address: str | None = Field(default=None, max_length=300)
    phone: str | None = Field(default=None, max_length=30)
    hours: str | None = Field(default=None, max_length=120)
    licence_days: int = Field(default=30, ge=1, le=365)


def _record(db: Session, a: Principal, pid: str | None, action: str, reason=None, detail=None):
    db.add(
        AdminAction(
            admin_id=a.user_id,
            pharmacy_id=pid,
            action=action,
            reason=reason.strip() if reason else None,
            detail=detail,
        )
    )


@router.post("/pharmacies")
def add_pharmacy(body: NewPharmacyIn, a: Admin, db: DbSession) -> dict:
    """A new pharmacy on Doaya online, listed for patients, with the key
    its own server links with (shown once)."""
    code = body.code.strip().upper()
    if not _CODE.match(code):
        raise error(400, "bad_code")
    if db.scalar(select(PharmacyListing).where(PharmacyListing.code == code)):
        raise error(409, "code_taken")
    ph = Pharmacy(
        id=new_id(), name=body.name.strip(), status="active", licence_days=body.licence_days
    )
    db.add(ph)
    db.flush()
    list_pharmacy(
        db,
        ph.id,
        code=code,
        city=body.city,
        address=body.address,
        phone=normalize_phone(body.phone) if body.phone else None,
        hours=body.hours,
    )
    key = new_pharmacy_key(db, ph.id)
    _record(db, a, ph.id, "create", detail={"code": code})
    db.commit()
    return {**_detail(db, ph), "key": key}


Action = Literal[
    "approve",
    "suspend",
    "resume",
    "stop",
    "remove",
    "list",
    "unlist",
    "new_key",
    "licence",
    "health_check",
]

# Actions that change what a pharmacy can do need a reason, kept in the log.
NEEDS_REASON = {"suspend", "stop", "remove", "new_key"}
# Which statuses each status-changing action applies to.
FROM = {
    "approve": {"pending"},
    "suspend": {"active"},
    "resume": {"suspended", "stopped"},
    "stop": {"active", "suspended"},
    "remove": {"pending", "active", "suspended", "stopped"},
}
TO = {
    "approve": "active",
    "suspend": "suspended",
    "resume": "active",
    "stop": "stopped",
    "remove": "removed",
}


class ActionIn(BaseModel):
    action: Action
    reason: str | None = Field(default=None, max_length=500)
    licence_days: int | None = Field(default=None, ge=1, le=365)


def _revoke_keys(db: Session, pid: str) -> None:
    for k in db.scalars(
        select(PharmacyKey).where(PharmacyKey.pharmacy_id == pid, PharmacyKey.revoked_at.is_(None))
    ):
        k.revoked_at = _now()


@router.post("/pharmacies/{pid}/actions")
def act(pid: str, body: ActionIn, a: Admin, db: DbSession) -> dict:
    """Approve, suspend, resume, stop, remove; list or hide it for patients;
    a new key for its server; its licence days; a health check now."""
    ph = _pharmacy(db, pid)
    if body.action in NEEDS_REASON and len((body.reason or "").strip()) < 3:
        raise error(400, "reason_required")
    detail: dict = {"from": ph.status}
    key = None
    if body.action in FROM:
        if ph.status not in FROM[body.action]:
            raise error(409, "bad_status")
        ph.status = TO[body.action]
        ph.status_reason = body.reason.strip() if body.reason else None
        detail["to"] = ph.status
        if body.action == "remove":
            # Its server can no longer reach Doaya online, and patients
            # no longer find it.
            _revoke_keys(db, ph.id)
            if li := db.get(PharmacyListing, ph.id):
                li.listed = False
    elif body.action in ("list", "unlist"):
        li = db.get(PharmacyListing, ph.id)
        if li is None:
            raise error(409, "not_in_directory")
        if body.action == "list" and ph.status == "removed":
            raise error(409, "bad_status")
        li.listed = body.action == "list"
    elif body.action == "new_key":
        if ph.status == "removed":
            raise error(409, "bad_status")
        _revoke_keys(db, ph.id)
        key = new_pharmacy_key(db, ph.id)
    elif body.action == "licence":
        if body.licence_days is None:
            raise error(400, "licence_days_required")
        detail = {"from": ph.licence_days, "to": body.licence_days}
        ph.licence_days = body.licence_days
    elif body.action == "health_check":
        if ph.status == "removed":
            raise error(409, "bad_status")
        ph.health_requested = True
    _record(db, a, ph.id, body.action, body.reason, detail)
    db.commit()
    out = _detail(db, ph)
    return {**out, "key": key} if key else out


# ─── Performance, for rewards ───────────────────────────────────────────────


def _month_bounds(month: str | None) -> tuple[str, datetime, datetime]:
    if month:
        m = re.fullmatch(r"(\d{4})-(\d{2})", month)
        if not m or not 1 <= int(m.group(2)) <= 12:
            raise error(400, "bad_month")
        y, mo = int(m.group(1)), int(m.group(2))
    else:
        local = _now() + timedelta(hours=3)
        y, mo = local.year, local.month
    start = _day_start_utc(date(y, mo, 1))
    end = _day_start_utc(date(y + mo // 12, mo % 12 + 1, 1))
    return f"{y:04d}-{mo:02d}", start, end


def tier(cases: int, answered_share: float | None, within_share: float | None) -> str | None:
    """gold | silver | None; None also when too few cases to judge."""
    if cases < MIN_CASES_TO_RANK or answered_share is None or within_share is None:
        return None
    if answered_share >= 0.95 and within_share >= 0.90:
        return "gold"
    if answered_share >= 0.90 and within_share >= 0.75:
        return "silver"
    return None


@router.get("/performance")
def performance(_: Admin, db: DbSession, month: str | None = None) -> dict:
    label, start, end = _month_bounds(month)
    in_month = and_(
        Consultation.sent_at.is_not(None), Consultation.sent_at >= start, Consultation.sent_at < end
    )
    answered = Consultation.first_action_at.is_not(None)
    in_time = and_(answered, _minutes <= ANSWER_TARGET_MINUTES)
    cases_rows = db.execute(
        select(
            Consultation.pharmacy_id,
            func.count(),
            func.count().filter(answered),
            func.count().filter(in_time),
            _pct(0.5),
            _pct(0.9),
            func.count().filter(Consultation.urgent),
            func.count().filter(and_(Consultation.urgent, in_time)),
        )
        .where(in_month)
        .group_by(Consultation.pharmacy_id)
    ).all()
    cases = {r[0]: r[1:] for r in cases_rows}
    order_rows = db.execute(
        select(
            PatientOrder.pharmacy_id,
            func.count(),
            func.count().filter(PatientOrder.status.in_(("ready", "picked_up"))),
            func.count().filter(PatientOrder.status == "rejected"),
        )
        .where(PatientOrder.created_at >= start, PatientOrder.created_at < end)
        .group_by(PatientOrder.pharmacy_id)
    ).all()
    orders = {r[0]: r[1:] for r in order_rows}
    names = db.execute(
        select(Pharmacy.id, Pharmacy.name, Pharmacy.status, PharmacyListing.city).join(
            PharmacyListing, PharmacyListing.pharmacy_id == Pharmacy.id, isouter=True
        )
    ).all()
    out = []
    for pid, name, status, city in names:
        if pid not in cases and pid not in orders and status != "active":
            continue
        n, ans, ok, med, p90, urgent, urgent_ok = cases.get(pid, (0, 0, 0, None, None, 0, 0))
        o_n, o_ready, o_rej = orders.get(pid, (0, 0, 0))
        answered_share = ans / n if n else None
        within_share = ok / n if n else None
        out.append(
            {
                "pharmacy_id": pid,
                "name": name,
                "city": city,
                "status": status,
                "cases": n,
                "answered": ans,
                "unanswered": n - ans,
                "answered_share": answered_share,
                "within_target_share": within_share,
                "median_minutes": _round(med),
                "p90_minutes": _round(p90),
                "urgent": urgent,
                "urgent_in_time": urgent_ok,
                "orders": o_n,
                "orders_prepared": o_ready,
                "orders_rejected": o_rej,
                "tier": tier(n, answered_share, within_share),
            }
        )
    # Ranked: enough cases first, then answered in time, then speed.
    out.sort(
        key=lambda r: (
            r["cases"] < MIN_CASES_TO_RANK,
            -(r["within_target_share"] or 0),
            -(r["answered_share"] or 0),
            r["median_minutes"] if r["median_minutes"] is not None else 1e9,
        )
    )
    for i, r in enumerate(out, 1):
        r["rank"] = i if r["cases"] >= MIN_CASES_TO_RANK else None
    return {
        "month": label,
        "target_minutes": ANSWER_TARGET_MINUTES,
        "min_cases": MIN_CASES_TO_RANK,
        "pharmacies": out,
    }


# ─── Settings (read-only; changed in the server's own settings) ─────────────


@router.get("/settings")
def settings_view(_: Admin, request: Request) -> dict:
    s = request.app.state.settings
    return {
        "llm_base_url": s.llm_base_url,
        "llm_model": s.llm_model,
        "emergency_ambulance": s.emergency_ambulance,
        "emergency_general": s.emergency_general,
        "cors_origins": [o.strip() for o in s.cors_origins.split(",") if o.strip()],
        "server_version": __version__,
    }


@router.post("/settings/model-check")
def model_check(_: Admin, request: Request) -> dict:
    """Asks the model one tiny question: does it answer, and how fast."""
    from .consult.llm import ChatMessage, LLMUnavailable
    from .consultations import get_llm

    start = time.monotonic()
    try:
        get_llm(request).complete([ChatMessage("user", "قل: تمام")], temperature=0)
    except LLMUnavailable as e:
        return {"ok": False, "error": str(e)[:300], "ms": None}
    return {"ok": True, "error": None, "ms": round((time.monotonic() - start) * 1000)}
