"""Patient accounts on the central server: phone + password once (no SMS in
v1), then the app stays signed in with a session secret."""

from datetime import UTC, datetime
from typing import Literal

from fastapi import APIRouter, Request
from pydantic import BaseModel, Field
from sqlalchemy import select

from .deps import DbSession, Patient, error
from .models import PatientProfile, PatientSession, Pharmacy, PharmacyListing, User
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

router = APIRouter(prefix="/patients", tags=["patients"])

PATIENT = "patient"


class RegisterIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    phone: str = Field(min_length=6, max_length=30)
    password: str = Field(min_length=6, max_length=200)
    birth_year: int | None = Field(default=None, ge=1900, le=2100)
    sex: Literal["m", "f"] | None = None
    city: str | None = Field(default=None, max_length=80)


class LoginIn(BaseModel):
    phone: str
    password: str


class TokenIn(BaseModel):
    session_token: str


class PatientPatch(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=200)
    birth_year: int | None = Field(default=None, ge=1900, le=2100)
    sex: Literal["m", "f"] | None = None
    city: str | None = Field(default=None, max_length=80)
    pharmacy_id: str | None = None


class PharmacyBrief(BaseModel):
    id: str
    name: str
    code: str
    city: str
    address: str | None
    phone: str | None
    hours: str | None


class PatientOut(BaseModel):
    id: str
    name: str
    phone: str
    birth_year: int | None
    sex: str | None
    city: str | None
    pharmacy: PharmacyBrief | None


class SessionOut(BaseModel):
    patient: PatientOut
    # Kept by the app to stay signed in ("<session id>.<secret>").
    session_token: str
    access_token: str
    expires_in: int


class TokenOut(BaseModel):
    access_token: str
    expires_in: int


def pharmacy_brief(db, pharmacy_id: str | None) -> PharmacyBrief | None:
    if pharmacy_id is None:
        return None
    ph, li = db.get(Pharmacy, pharmacy_id), db.get(PharmacyListing, pharmacy_id)
    if ph is None or li is None:
        return None
    return PharmacyBrief(
        id=ph.id,
        name=ph.name,
        code=li.code,
        city=li.city,
        address=li.address,
        phone=li.phone,
        hours=li.hours,
    )


def patient_out(db, user: User) -> PatientOut:
    prof = db.get(PatientProfile, user.id) or PatientProfile(user_id=user.id)
    return PatientOut(
        id=user.id,
        name=user.name,
        phone=user.phone,
        birth_year=prof.birth_year,
        sex=prof.sex,
        city=prof.city,
        pharmacy=pharmacy_brief(db, prof.pharmacy_id),
    )


def _access(request: Request, user: User, session_id: str) -> tuple[str, int]:
    s = request.app.state.settings
    p = Principal(user.id, session_id, "", PATIENT)
    return issue_access_token(p, s.jwt_secret, s.access_token_minutes), s.access_token_minutes * 60


def _new_session(db, request: Request, user: User) -> SessionOut:
    secret = new_device_secret()
    session = PatientSession(id=new_id(), user_id=user.id, token_hash=hash_secret(secret))
    db.add(session)
    db.commit()
    token, expires = _access(request, user, session.id)
    return SessionOut(
        patient=patient_out(db, user),
        session_token=f"{session.id}.{secret}",
        access_token=token,
        expires_in=expires,
    )


@router.post("/register", response_model=SessionOut)
def register(body: RegisterIn, db: DbSession, request: Request) -> SessionOut:
    phone = normalize_phone(body.phone)
    if db.scalar(select(User).where(User.phone == phone)):
        raise error(409, "phone_taken")
    user = User(
        id=new_id(),
        pharmacy_id=None,
        role=PATIENT,
        name=body.name.strip(),
        phone=phone,
        password_hash=hash_password(body.password),
        active=True,
    )
    db.add(user)
    db.flush()
    db.add(
        PatientProfile(
            user_id=user.id,
            birth_year=body.birth_year,
            sex=body.sex,
            city=body.city.strip() if body.city else None,
        )
    )
    return _new_session(db, request, user)


@router.post("/login", response_model=SessionOut)
def login(body: LoginIn, db: DbSession, request: Request) -> SessionOut:
    limiter = request.app.state.login_limiter
    phone = normalize_phone(body.phone)
    key = f"patient|{phone}|{request.client.host if request.client else ''}"
    if limiter.blocked(key):
        raise error(429, "too_many_attempts")
    user = db.scalar(select(User).where(User.phone == phone, User.role == PATIENT))
    if user is None or not user.active or not check_password(user.password_hash, body.password):
        limiter.failed(key)
        raise error(401, "bad_credentials")
    limiter.succeeded(key)
    return _new_session(db, request, user)


@router.post("/token", response_model=TokenOut)
def token(body: TokenIn, db: DbSession, request: Request) -> TokenOut:
    session_id, _, secret = body.session_token.partition(".")
    session = db.get(PatientSession, session_id)
    if (
        session is None
        or session.revoked_at is not None
        or session.token_hash != hash_secret(secret)
    ):
        raise error(401, "signed_out")
    user = db.get(User, session.user_id)
    if user is None or not user.active:
        raise error(401, "account_disabled")
    session.last_seen_at = datetime.now(UTC)
    db.commit()
    access, expires = _access(request, user, session.id)
    return TokenOut(access_token=access, expires_in=expires)


@router.get("/me", response_model=PatientOut)
def me(p: Patient, db: DbSession) -> PatientOut:
    return patient_out(db, db.get(User, p.user_id))


@router.patch("/me", response_model=PatientOut)
def update_me(body: PatientPatch, p: Patient, db: DbSession) -> PatientOut:
    user = db.get(User, p.user_id)
    prof = db.get(PatientProfile, p.user_id) or PatientProfile(user_id=p.user_id)
    db.add(prof)
    fields = body.model_dump(exclude_unset=True)
    if "pharmacy_id" in fields and fields["pharmacy_id"] is not None:
        listing = db.get(PharmacyListing, fields["pharmacy_id"])
        pharmacy = db.get(Pharmacy, fields["pharmacy_id"])
        if listing is None or not listing.listed or pharmacy is None or pharmacy.status != "active":
            raise error(404, "pharmacy_not_found")
    for k, v in fields.items():
        if k == "name":
            user.name = v.strip()
        else:
            setattr(prof, k, v)
    db.commit()
    return patient_out(db, user)


@router.post("/logout")
def logout(p: Patient, db: DbSession) -> dict:
    session = db.get(PatientSession, p.device_id)
    session.revoked_at = datetime.now(UTC)
    db.commit()
    return {"ok": True}
