from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Annotated
from urllib.parse import unquote

from fastapi import Depends, HTTPException, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from .models import Device, PatientSession, Pharmacy, PharmacyKey, User
from .security import Principal, hash_secret, read_access_token


def get_db(request: Request):
    yield from request.app.state.db.session()


DbSession = Annotated[Session, Depends(get_db)]


def error(status: int, code: str) -> HTTPException:
    """Errors carry a short code; the app shows its own Arabic message."""
    return HTTPException(status_code=status, detail=code)


def current_principal(request: Request, db: DbSession) -> Principal:
    auth = request.headers.get("authorization", "")
    if not auth.lower().startswith("bearer "):
        raise error(401, "not_signed_in")
    p = read_access_token(auth[7:], request.app.state.settings.jwt_secret)
    if p is None:
        raise error(401, "token_expired")
    # Unlinking a device (or suspending a pharmacy) takes effect at once,
    # not when its access token expires.
    device = db.get(Device, p.device_id)
    if device is None or device.revoked_at is not None or device.pharmacy_id != p.pharmacy_id:
        raise error(401, "device_unlinked")
    pharmacy = db.get(Pharmacy, p.pharmacy_id)
    if pharmacy is None or pharmacy.status != "active":
        raise error(403, "pharmacy_inactive")
    device.last_seen_at = datetime.now(UTC)
    db.commit()
    return p


Caller = Annotated[Principal, Depends(current_principal)]


def owner_only(p: Caller) -> Principal:
    if not p.is_owner:
        raise error(403, "owner_only")
    return p


Owner = Annotated[Principal, Depends(owner_only)]


# ─── Central server: patients and pharmacy servers ────────────────────────


def current_patient(request: Request, db: DbSession) -> Principal:
    """A signed-in patient. Pharmacy tokens are refused here, and patient
    tokens by [current_principal] (their session is no device)."""
    auth = request.headers.get("authorization", "")
    if not auth.lower().startswith("bearer "):
        raise error(401, "not_signed_in")
    p = read_access_token(auth[7:], request.app.state.settings.jwt_secret)
    if p is None:
        raise error(401, "token_expired")
    if p.role != "patient":
        raise error(403, "patients_only")
    session = db.get(PatientSession, p.device_id)
    user = db.get(User, p.user_id)
    if session is None or session.revoked_at is not None or user is None or not user.active:
        raise error(401, "signed_out")
    return p


Patient = Annotated[Principal, Depends(current_patient)]


@dataclass(frozen=True)
class PharmacyServer:
    """A pharmacy's own server calling the central one with its key, on
    behalf of [actor] (the pharmacist's name, for the record)."""

    pharmacy_id: str
    actor: str | None


def current_pharmacy_server(request: Request, db: DbSession) -> PharmacyServer:
    auth = request.headers.get("authorization", "")
    if not auth.lower().startswith("pharmacy "):
        raise error(401, "no_pharmacy_key")
    key = db.scalar(
        select(PharmacyKey).where(PharmacyKey.key_hash == hash_secret(auth[9:].strip()))
    )
    if key is None or key.revoked_at is not None:
        raise error(401, "bad_pharmacy_key")
    pharmacy = db.get(Pharmacy, key.pharmacy_id)
    if pharmacy is None or pharmacy.status != "active":
        raise error(403, "pharmacy_inactive")
    # Header values are ASCII: the Arabic name comes percent-encoded.
    actor = request.headers.get("x-doaya-actor")
    return PharmacyServer(key.pharmacy_id, unquote(actor)[:200] if actor else None)


PharmacyCaller = Annotated[PharmacyServer, Depends(current_pharmacy_server)]
