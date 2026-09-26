"""Admin actions on the central server (command line now, the admin panel in
Phase 4): list a pharmacy in the directory, give its server a key."""

import secrets

from sqlalchemy.orm import Session

from .models import PharmacyKey, PharmacyListing
from .security import hash_secret, new_id


def list_pharmacy(
    db: Session,
    pharmacy_id: str,
    *,
    code: str,
    city: str,
    address: str | None = None,
    phone: str | None = None,
    hours: str | None = None,
    listed: bool = True,
) -> PharmacyListing:
    listing = db.get(PharmacyListing, pharmacy_id) or PharmacyListing(pharmacy_id=pharmacy_id)
    listing.code = code.strip().upper()
    listing.city = city.strip()
    listing.address, listing.phone, listing.hours, listing.listed = address, phone, hours, listed
    db.add(listing)
    db.commit()
    return listing


def new_pharmacy_key(db: Session, pharmacy_id: str) -> str:
    """A new key for the pharmacy's server; shown once, stored hashed."""
    key = "dk_" + secrets.token_urlsafe(32)
    db.add(PharmacyKey(id=new_id(), pharmacy_id=pharmacy_id, key_hash=hash_secret(key)))
    db.commit()
    return key
