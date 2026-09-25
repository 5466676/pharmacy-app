"""Push / pull sync for a pharmacy's devices.

Every change a device pushes lands in `sync_rows` with a number from one
sequence. Devices pull "everything after N" from the other devices.

* Ledger tables are append-only: a row is stored once; sending it again is
  harmless (idempotent). A different body for an existing id is ignored and
  reported as a conflict (the first version stays).
* Master data (products, customers…) is last-writer-wins on
  (changed_at, device_id), decided inside the one INSERT … ON CONFLICT.
  Deletions are tombstones (`deleted`, no data) so other devices learn them.
* Pushes of one pharmacy are serialised by a transaction-level advisory lock,
  so sequence numbers commit in order and a pull can never skip a change that
  commits late.
"""

from datetime import datetime

from fastapi import APIRouter, Query
from pydantic import BaseModel, Field
from sqlalchemy import func, select, text
from sqlalchemy.dialects.postgresql import insert

from .deps import Caller, DbSession
from .models import SyncRow

router = APIRouter(prefix="/sync")

# Tables whose rows never change once written (the ledgers).
APPEND_ONLY = frozenset(
    {
        "stock_events",
        "sales",
        "sale_lines",
        "debt_events",
        "returns",
        "return_lines",
        "till_events",
        "purchases",
        "purchase_lines",
        "supplier_debt_events",
        "supplier_returns",
        "expense_events",
        "stocktake_counts",
    }
)

# Master data: edited in place, last writer wins, may be deleted.
MUTABLE = frozenset(
    {
        "devices",
        "settings",
        "employees",
        "products",
        "product_barcodes",
        "customers",
        "suppliers",
        "stocktakes",
        "purchase_orders",
        "purchase_order_lines",
    }
)

MAX_PUSH = 1000
MAX_PULL = 1000


class Change(BaseModel):
    table: str = Field(max_length=60)
    id: str = Field(min_length=1, max_length=80)
    # Ledger rows: when it happened; master rows: when it was last edited.
    changed_at: datetime
    data: dict | None = None
    deleted: bool = False


class PushIn(BaseModel):
    changes: list[Change] = Field(max_length=MAX_PUSH)


class Rejected(BaseModel):
    table: str
    id: str
    reason: str


class PushOut(BaseModel):
    # Everything the device may mark as synced (stored now, already there,
    # or superseded by a newer edit from another device).
    accepted: list[str]
    rejected: list[Rejected]
    # Ledger ids that already existed with a different body.
    conflicts: list[str]


class PulledChange(BaseModel):
    table: str
    id: str
    data: dict | None
    deleted: bool
    changed_at: datetime
    device_id: str
    seq: int


class PullOut(BaseModel):
    changes: list[PulledChange]
    # Pass as `after` next time.
    cursor: int
    more: bool
    # The newest change on the server (for a progress bar on first download).
    latest: int


def _lock_pharmacy(db, pharmacy_id: str) -> None:
    db.execute(text("SELECT pg_advisory_xact_lock(hashtext(:p))"), {"p": pharmacy_id})


@router.post("/push", response_model=PushOut)
def push(body: PushIn, p: Caller, db: DbSession) -> PushOut:
    accepted: list[str] = []
    rejected: list[Rejected] = []
    conflicts: list[str] = []
    _lock_pharmacy(db, p.pharmacy_id)
    for c in body.changes:
        key = f"{c.table}:{c.id}"
        if c.table in APPEND_ONLY:
            if c.deleted or c.data is None:
                rejected.append(Rejected(table=c.table, id=c.id, reason="append_only"))
                continue
            stmt = (
                insert(SyncRow)
                .values(
                    pharmacy_id=p.pharmacy_id,
                    table_name=c.table,
                    row_id=c.id,
                    data=c.data,
                    deleted=False,
                    changed_at=c.changed_at,
                    device_id=p.device_id,
                )
                .on_conflict_do_nothing(constraint="sync_rows_key")
                .returning(SyncRow.id)
            )
            if db.execute(stmt).first() is None:
                existing = db.scalar(
                    select(SyncRow.data).where(
                        SyncRow.pharmacy_id == p.pharmacy_id,
                        SyncRow.table_name == c.table,
                        SyncRow.row_id == c.id,
                    )
                )
                if existing != c.data:
                    conflicts.append(key)
            accepted.append(key)
        elif c.table in MUTABLE:
            if not c.deleted and c.data is None:
                rejected.append(Rejected(table=c.table, id=c.id, reason="no_data"))
                continue
            ins = insert(SyncRow).values(
                pharmacy_id=p.pharmacy_id,
                table_name=c.table,
                row_id=c.id,
                data=None if c.deleted else c.data,
                deleted=c.deleted,
                changed_at=c.changed_at,
                device_id=p.device_id,
            )
            # Newer (changed_at, device_id) wins; the loser is simply dropped.
            stmt = ins.on_conflict_do_update(
                constraint="sync_rows_key",
                set_={
                    "data": ins.excluded.data,
                    "deleted": ins.excluded.deleted,
                    "changed_at": ins.excluded.changed_at,
                    "device_id": ins.excluded.device_id,
                    "seq": func.nextval("change_seq"),
                    "received_at": func.now(),
                },
                where=func.row(SyncRow.changed_at, SyncRow.device_id)
                < func.row(ins.excluded.changed_at, ins.excluded.device_id),
            )
            db.execute(stmt)
            accepted.append(key)
        else:
            rejected.append(Rejected(table=c.table, id=c.id, reason="unknown_table"))
    db.commit()
    return PushOut(accepted=accepted, rejected=rejected, conflicts=conflicts)


@router.get("/pull", response_model=PullOut)
def pull(
    p: Caller,
    db: DbSession,
    after: int = Query(0, ge=0),
    limit: int = Query(500, ge=1, le=MAX_PULL),
) -> PullOut:
    rows = db.scalars(
        select(SyncRow)
        .where(SyncRow.pharmacy_id == p.pharmacy_id, SyncRow.seq > after)
        .order_by(SyncRow.seq)
        .limit(limit)
    ).all()
    latest = db.scalar(
        select(func.coalesce(func.max(SyncRow.seq), 0)).where(SyncRow.pharmacy_id == p.pharmacy_id)
    )
    cursor = rows[-1].seq if rows else max(after, 0)
    return PullOut(
        # A device already has what it wrote itself (and is its last writer).
        changes=[
            PulledChange(
                table=r.table_name,
                id=r.row_id,
                data=r.data,
                deleted=r.deleted,
                changed_at=r.changed_at,
                device_id=r.device_id,
                seq=r.seq,
            )
            for r in rows
            if r.device_id != p.device_id
        ],
        cursor=cursor,
        more=len(rows) == limit,
        latest=latest,
    )
