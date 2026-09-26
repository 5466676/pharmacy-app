"""Central server: the pharmacy directory patients choose from, and each
pharmacy's shelf (published by its own server: price and available or not)."""

from datetime import UTC, datetime

from fastapi import APIRouter
from pydantic import BaseModel, Field
from sqlalchemy import delete, func, or_, select

from .deps import DbSession, PharmacyCaller, error
from .models import Pharmacy, PharmacyListing, ShelfItem
from .patients import PharmacyBrief, pharmacy_brief

router = APIRouter(tags=["directory"])


class ShelfIn(BaseModel):
    product_id: str = Field(max_length=36)
    trade_name: str = Field(max_length=200)
    arabic_name: str | None = Field(default=None, max_length=200)
    active_ingredient: str | None = Field(default=None, max_length=200)
    strength: str | None = Field(default=None, max_length=60)
    form: str | None = Field(default=None, max_length=60)
    price_minor: int = Field(ge=0)
    available: bool
    prescription_only: bool = False
    photo_url: str | None = Field(default=None, max_length=300)


class ShelfPublish(BaseModel):
    currency: str = Field(min_length=3, max_length=3)
    items: list[ShelfIn] = Field(max_length=50_000)


class ShelfOut(BaseModel):
    product_id: str
    trade_name: str
    arabic_name: str | None
    active_ingredient: str | None
    strength: str | None
    form: str | None
    price_minor: int
    currency: str
    available: bool
    prescription_only: bool
    photo_url: str | None


@router.put("/pharmacy-api/shelf")
def publish_shelf(body: ShelfPublish, caller: PharmacyCaller, db: DbSession) -> dict:
    """The pharmacy's whole shelf, replacing the previous one."""
    now = datetime.now(UTC)
    db.execute(delete(ShelfItem).where(ShelfItem.pharmacy_id == caller.pharmacy_id))
    db.add_all(
        ShelfItem(
            pharmacy_id=caller.pharmacy_id,
            currency=body.currency.upper(),
            updated_at=now,
            **i.model_dump(),
        )
        for i in {i.product_id: i for i in body.items}.values()
    )
    db.commit()
    return {"items": len(body.items)}


def _listed(db, pharmacy_id: str) -> None:
    listing = db.get(PharmacyListing, pharmacy_id)
    pharmacy = db.get(Pharmacy, pharmacy_id)
    if listing is None or not listing.listed or pharmacy is None or pharmacy.status != "active":
        raise error(404, "pharmacy_not_found")


@router.get("/directory", response_model=list[PharmacyBrief])
def directory(db: DbSession, city: str | None = None, q: str | None = None) -> list:
    stmt = (
        select(Pharmacy.id)
        .join(PharmacyListing, PharmacyListing.pharmacy_id == Pharmacy.id)
        .where(PharmacyListing.listed, Pharmacy.status == "active")
        .order_by(Pharmacy.name)
        .limit(200)
    )
    if city:
        stmt = stmt.where(PharmacyListing.city == city.strip())
    if q:
        stmt = stmt.where(Pharmacy.name.ilike(f"%{q.strip()}%"))
    return [pharmacy_brief(db, pid) for pid in db.scalars(stmt)]


@router.get("/directory/code/{code}", response_model=PharmacyBrief)
def by_code(code: str, db: DbSession) -> PharmacyBrief:
    """The short code a pharmacy shows at its counter."""
    listing = db.scalar(
        select(PharmacyListing).where(func.upper(PharmacyListing.code) == code.strip().upper())
    )
    if listing is None:
        raise error(404, "pharmacy_not_found")
    _listed(db, listing.pharmacy_id)
    return pharmacy_brief(db, listing.pharmacy_id)


@router.get("/directory/{pharmacy_id}/shelf", response_model=list[ShelfOut])
def shelf(
    pharmacy_id: str,
    db: DbSession,
    q: str | None = None,
    available_only: bool = False,
    limit: int = 50,
    offset: int = 0,
) -> list:
    _listed(db, pharmacy_id)
    stmt = select(ShelfItem).where(ShelfItem.pharmacy_id == pharmacy_id)
    if q:
        like = f"%{q.strip()}%"
        stmt = stmt.where(
            or_(
                ShelfItem.trade_name.ilike(like),
                ShelfItem.arabic_name.ilike(like),
                ShelfItem.active_ingredient.ilike(like),
            )
        )
    if available_only:
        stmt = stmt.where(ShelfItem.available)
    stmt = stmt.order_by(ShelfItem.available.desc(), ShelfItem.trade_name)
    return list(db.scalars(stmt.limit(min(limit, 200)).offset(max(offset, 0))))
