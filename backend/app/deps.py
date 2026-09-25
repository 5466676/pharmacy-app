from datetime import UTC, datetime
from typing import Annotated

from fastapi import Depends, HTTPException, Request
from sqlalchemy.orm import Session

from .models import Device, Pharmacy
from .security import Principal, read_access_token


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
