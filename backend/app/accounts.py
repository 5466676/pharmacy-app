"""Pharmacy setup, accounts, device linking and access tokens."""

from datetime import UTC, datetime

from fastapi import APIRouter, Request
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .deps import Caller, DbSession, Owner, error
from .models import Device, Pharmacy, User
from .security import (
    Principal,
    check_password,
    hash_password,
    hash_secret,
    issue_access_token,
    new_device_secret,
    new_id,
    normalize_phone,
)

router = APIRouter()

OWNER, EMPLOYEE = "pharmacist_owner", "pharmacist_employee"


class DeviceIn(BaseModel):
    id: str = Field(min_length=8, max_length=36)
    name: str = Field(min_length=1, max_length=200)


class SetupIn(BaseModel):
    pharmacy_name: str = Field(min_length=1, max_length=200)
    owner_name: str = Field(min_length=1, max_length=200)
    owner_phone: str = Field(min_length=6, max_length=30)
    password: str = Field(min_length=6, max_length=200)
    # The app's own owner employee row, so the account signs in as it.
    owner_employee_id: str | None = None
    device: DeviceIn


class LinkIn(BaseModel):
    phone: str
    password: str
    device: DeviceIn


class TokenIn(BaseModel):
    device_id: str
    device_token: str


class UserOut(BaseModel):
    id: str
    name: str
    phone: str
    role: str
    employee_id: str | None
    active: bool


class LinkOut(BaseModel):
    """What a device keeps after linking: its secret and who it belongs to."""

    pharmacy_id: str
    pharmacy_name: str
    user: UserOut
    device_token: str
    access_token: str
    expires_in: int


class TokenOut(BaseModel):
    access_token: str
    expires_in: int


def user_out(u: User) -> UserOut:
    return UserOut(
        id=u.id, name=u.name, phone=u.phone, role=u.role, employee_id=u.employee_id, active=u.active
    )


def link_device(
    db: Session, request: Request, user: User, pharmacy: Pharmacy, device: DeviceIn
) -> LinkOut:
    """Registers (or re-links) the device and hands out its secret."""
    existing = db.get(Device, device.id)
    if existing is not None and existing.pharmacy_id != pharmacy.id:
        raise error(409, "device_other_pharmacy")
    secret = new_device_secret()
    if existing is None:
        existing = Device(id=device.id, pharmacy_id=pharmacy.id)
        db.add(existing)
    existing.name = device.name
    existing.linked_by = user.id
    existing.token_hash = hash_secret(secret)
    existing.linked_at = datetime.now(UTC)
    existing.revoked_at = None
    db.commit()
    settings = request.app.state.settings
    principal = Principal(user.id, device.id, pharmacy.id, user.role)
    return LinkOut(
        pharmacy_id=pharmacy.id,
        pharmacy_name=pharmacy.name,
        user=user_out(user),
        device_token=secret,
        access_token=issue_access_token(
            principal, settings.jwt_secret, settings.access_token_minutes
        ),
        expires_in=settings.access_token_minutes * 60,
    )


@router.get("/setup")
def setup_state(db: DbSession) -> dict:
    """Whether this server still waits for its first pharmacy."""
    count = db.scalar(select(func.count()).select_from(Pharmacy))
    return {"needs_setup": count == 0}


@router.post("/setup", response_model=LinkOut)
def setup(body: SetupIn, db: DbSession, request: Request) -> LinkOut:
    """First run of a pharmacy's own server: creates the pharmacy and the
    owner account, and links the device doing it. Refused once any pharmacy
    exists (more pharmacies are added with the command-line tool)."""
    if db.scalar(select(func.count()).select_from(Pharmacy)):
        raise error(409, "already_set_up")
    phone = normalize_phone(body.owner_phone)
    pharmacy = Pharmacy(id=new_id(), name=body.pharmacy_name.strip(), status="active")
    owner = User(
        id=new_id(),
        pharmacy_id=pharmacy.id,
        role=OWNER,
        name=body.owner_name.strip(),
        phone=phone,
        password_hash=hash_password(body.password),
        employee_id=body.owner_employee_id,
        active=True,
    )
    db.add_all([pharmacy, owner])
    db.flush()
    return link_device(db, request, owner, pharmacy, body.device)


@router.post("/auth/link", response_model=LinkOut)
def link(body: LinkIn, db: DbSession, request: Request) -> LinkOut:
    """Phone + password once; the device then stays signed in."""
    limiter = request.app.state.login_limiter
    phone = normalize_phone(body.phone)
    key = f"{phone}|{request.client.host if request.client else ''}"
    if limiter.blocked(key):
        raise error(429, "too_many_attempts")
    user = db.scalar(select(User).where(User.phone == phone))
    if user is None or not user.active or not check_password(user.password_hash, body.password):
        limiter.failed(key)
        raise error(401, "bad_credentials")
    limiter.succeeded(key)
    pharmacy = db.get(Pharmacy, user.pharmacy_id) if user.pharmacy_id else None
    if pharmacy is None or pharmacy.status != "active":
        raise error(403, "pharmacy_inactive")
    return link_device(db, request, user, pharmacy, body.device)


@router.post("/auth/token", response_model=TokenOut)
def token(body: TokenIn, db: DbSession, request: Request) -> TokenOut:
    """A linked device trades its secret for a short access token."""
    device = db.get(Device, body.device_id)
    if (
        device is None
        or device.revoked_at is not None
        or device.token_hash != hash_secret(body.device_token)
    ):
        raise error(401, "device_unlinked")
    user = db.get(User, device.linked_by)
    pharmacy = db.get(Pharmacy, device.pharmacy_id)
    if user is None or not user.active:
        raise error(401, "account_disabled")
    if pharmacy is None or pharmacy.status != "active":
        raise error(403, "pharmacy_inactive")
    device.last_seen_at = datetime.now(UTC)
    db.commit()
    settings = request.app.state.settings
    p = Principal(user.id, device.id, pharmacy.id, user.role)
    return TokenOut(
        access_token=issue_access_token(p, settings.jwt_secret, settings.access_token_minutes),
        expires_in=settings.access_token_minutes * 60,
    )


@router.get("/me")
def me(p: Caller, db: DbSession) -> dict:
    user = db.get(User, p.user_id)
    pharmacy = db.get(Pharmacy, p.pharmacy_id)
    return {"user": user_out(user), "pharmacy": {"id": pharmacy.id, "name": pharmacy.name}}


# ─── Owner: devices and employee accounts ──────────────────────────────────


class DeviceOut(BaseModel):
    id: str
    name: str
    linked_by: str
    linked_at: datetime
    last_seen_at: datetime | None
    revoked: bool


@router.get("/devices", response_model=list[DeviceOut])
def devices(p: Owner, db: DbSession) -> list[DeviceOut]:
    rows = db.scalars(
        select(Device).where(Device.pharmacy_id == p.pharmacy_id).order_by(Device.linked_at)
    )
    return [
        DeviceOut(
            id=d.id,
            name=d.name,
            linked_by=d.linked_by,
            linked_at=d.linked_at,
            last_seen_at=d.last_seen_at,
            revoked=d.revoked_at is not None,
        )
        for d in rows
    ]


@router.post("/devices/{device_id}/unlink", status_code=204)
def unlink(device_id: str, p: Owner, db: DbSession) -> None:
    d = db.get(Device, device_id)
    if d is None or d.pharmacy_id != p.pharmacy_id:
        raise error(404, "not_found")
    if d.id == p.device_id:
        raise error(409, "cannot_unlink_self")
    d.revoked_at = datetime.now(UTC)
    db.commit()


class UserIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    phone: str = Field(min_length=6, max_length=30)
    password: str = Field(min_length=6, max_length=200)
    employee_id: str | None = None


class UserPatch(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=200)
    password: str | None = Field(default=None, min_length=6, max_length=200)
    active: bool | None = None


@router.get("/users", response_model=list[UserOut])
def users(p: Owner, db: DbSession) -> list[UserOut]:
    rows = db.scalars(select(User).where(User.pharmacy_id == p.pharmacy_id).order_by(User.name))
    return [user_out(u) for u in rows]


@router.post("/users", response_model=UserOut, status_code=201)
def add_user(body: UserIn, p: Owner, db: DbSession) -> UserOut:
    """An employee account (phone + password), linked to the app's employee."""
    phone = normalize_phone(body.phone)
    if db.scalar(select(User).where(User.phone == phone)):
        raise error(409, "phone_taken")
    u = User(
        id=new_id(),
        pharmacy_id=p.pharmacy_id,
        role=EMPLOYEE,
        name=body.name.strip(),
        phone=phone,
        password_hash=hash_password(body.password),
        employee_id=body.employee_id,
        active=True,
    )
    db.add(u)
    db.commit()
    return user_out(u)


@router.patch("/users/{user_id}", response_model=UserOut)
def update_user(user_id: str, body: UserPatch, p: Owner, db: DbSession) -> UserOut:
    u = db.get(User, user_id)
    if u is None or u.pharmacy_id != p.pharmacy_id:
        raise error(404, "not_found")
    if body.active is False and u.id == p.user_id:
        raise error(409, "cannot_disable_self")
    if body.name is not None:
        u.name = body.name.strip()
    if body.password is not None:
        u.password_hash = hash_password(body.password)
    if body.active is not None:
        u.active = body.active
    db.commit()
    return user_out(u)
