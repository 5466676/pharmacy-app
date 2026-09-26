"""Central server: orders for pickup from a pharmacy's shelf. The patient
asks for quantities; the pharmacist has the final say. Paid at pickup (a
payment interface for local wallets comes later)."""

from datetime import UTC, datetime
from typing import Literal

from fastapi import APIRouter, Request
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from .consultations import CasePatient, _case_patient
from .deps import DbSession, Patient, PharmacyCaller, error
from .events import patient_topic, pharmacy_topic
from .models import PatientOrder, PatientProfile, ShelfItem
from .security import new_id

router = APIRouter(tags=["orders"])


class OrderLineIn(BaseModel):
    product_id: str = Field(max_length=36)
    quantity: int = Field(ge=1, le=100)


class OrderIn(BaseModel):
    lines: list[OrderLineIn] = Field(min_length=1, max_length=50)
    note: str | None = Field(default=None, max_length=1000)
    # A prescription photo uploaded with POST /photos.
    photo_id: str | None = Field(default=None, max_length=36)


class OrderLine(BaseModel):
    product_id: str
    name: str
    # What the patient asked for, and what the pharmacist settled on.
    requested: int
    quantity: int
    price_minor: int


class OrderOut(BaseModel):
    id: str
    pharmacy_id: str
    status: str
    lines: list[OrderLine]
    currency: str
    total_minor: int
    note: str | None
    pharmacist_note: str | None
    handled_by: str | None
    photo_id: str | None = None
    created_at: datetime
    updated_at: datetime


class PharmacyOrderOut(OrderOut):
    patient: CasePatient


class OrderStatusIn(BaseModel):
    status: Literal["preparing", "ready", "rejected", "picked_up"]
    # product id → final quantity (0 drops the line); only before "ready".
    quantities: dict[str, int] | None = None
    note: str | None = Field(default=None, max_length=1000)


NEXT = {
    "sent": {"preparing", "ready", "rejected"},
    "preparing": {"ready", "rejected"},
    "ready": {"picked_up"},
}


def _out(o: PatientOrder) -> dict:
    return {
        **{k: getattr(o, k) for k in OrderOut.model_fields if k != "total_minor"},
        "total_minor": sum(line["quantity"] * line["price_minor"] for line in o.lines),
    }


def _changed(request: Request, o: PatientOrder) -> None:
    o.updated_at = datetime.now(UTC)
    request.app.state.events.publish(
        [patient_topic(o.patient_id), pharmacy_topic(o.pharmacy_id)],
        {"type": "order", "order_id": o.id, "status": o.status},
    )


@router.post("/orders", response_model=OrderOut)
def place(body: OrderIn, p: Patient, db: DbSession, request: Request) -> dict:
    prof = db.get(PatientProfile, p.user_id)
    if prof is None or prof.pharmacy_id is None:
        raise error(409, "no_pharmacy")
    lines, currency = [], None
    for line in body.lines:
        item = db.get(ShelfItem, (prof.pharmacy_id, line.product_id))
        if item is None:
            raise error(400, "unknown_product")
        currency = item.currency
        lines.append(
            {
                "product_id": item.product_id,
                "name": item.trade_name,
                "requested": line.quantity,
                "quantity": line.quantity,
                "price_minor": item.price_minor,
            }
        )
    o = PatientOrder(
        id=new_id(),
        patient_id=p.user_id,
        pharmacy_id=prof.pharmacy_id,
        status="sent",
        lines=lines,
        currency=currency,
        note=body.note.strip() if body.note else None,
    )
    db.add(o)
    if body.photo_id:
        from .photos import attach_to_order

        attach_to_order(db, p.user_id, o, body.photo_id)
    _changed(request, o)
    db.commit()
    return _out(o)


def _mine(db: Session, p, oid: str) -> PatientOrder:
    o = db.get(PatientOrder, oid)
    if o is None or o.patient_id != p.user_id:
        raise error(404, "order_not_found")
    return o


@router.get("/orders", response_model=list[OrderOut])
def my_orders(p: Patient, db: DbSession) -> list:
    rows = db.scalars(
        select(PatientOrder)
        .where(PatientOrder.patient_id == p.user_id)
        .order_by(PatientOrder.updated_at.desc())
        .limit(50)
    )
    return [_out(o) for o in rows]


@router.get("/orders/{oid}", response_model=OrderOut)
def my_order(oid: str, p: Patient, db: DbSession) -> dict:
    return _out(_mine(db, p, oid))


@router.post("/orders/{oid}/cancel", response_model=OrderOut)
def cancel(oid: str, p: Patient, db: DbSession, request: Request) -> dict:
    o = _mine(db, p, oid)
    if o.status != "sent":
        raise error(409, "already_handled")
    o.status = "cancelled"
    _changed(request, o)
    db.commit()
    return _out(o)


# ─── Pharmacy ──────────────────────────────────────────────────────────────


def _theirs(db: Session, caller, oid: str) -> PatientOrder:
    o = db.get(PatientOrder, oid)
    if o is None or o.pharmacy_id != caller.pharmacy_id:
        raise error(404, "order_not_found")
    return o


def _pharmacy_out(db: Session, o: PatientOrder) -> dict:
    return {**_out(o), "patient": _case_patient(db, o.patient_id)}


@router.get("/pharmacy-api/orders", response_model=list[PharmacyOrderOut])
def orders(
    caller: PharmacyCaller,
    db: DbSession,
    status: str | None = None,
    updated_after: datetime | None = None,
) -> list:
    stmt = select(PatientOrder).where(PatientOrder.pharmacy_id == caller.pharmacy_id)
    if status:
        stmt = stmt.where(PatientOrder.status.in_(status.split(",")))
    if updated_after:
        stmt = stmt.where(PatientOrder.updated_at > updated_after)
    stmt = stmt.order_by(PatientOrder.created_at.desc()).limit(200)
    return [_pharmacy_out(db, o) for o in db.scalars(stmt)]


@router.get("/pharmacy-api/orders/{oid}", response_model=PharmacyOrderOut)
def order(oid: str, caller: PharmacyCaller, db: DbSession) -> dict:
    return _pharmacy_out(db, _theirs(db, caller, oid))


@router.post("/pharmacy-api/orders/{oid}/status", response_model=PharmacyOrderOut)
def set_status(
    oid: str, body: OrderStatusIn, caller: PharmacyCaller, db: DbSession, request: Request
) -> dict:
    o = _theirs(db, caller, oid)
    if body.status not in NEXT.get(o.status, set()):
        raise error(409, "bad_status")
    if body.quantities:
        if o.status not in ("sent", "preparing"):
            raise error(409, "bad_status")
        lines = []
        for line in o.lines:
            q = body.quantities.get(line["product_id"], line["quantity"])
            if q < 0 or q > 100:
                raise error(400, "bad_quantity")
            if q > 0:
                lines.append({**line, "quantity": q})
        o.lines = lines  # a new list, so SQLAlchemy stores the change
    o.status = body.status
    o.handled_by = caller.actor or o.handled_by
    if body.note:
        o.pharmacist_note = body.note.strip()
    _changed(request, o)
    db.commit()
    return _pharmacy_out(db, o)
