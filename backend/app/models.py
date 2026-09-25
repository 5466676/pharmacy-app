"""Server tables.

Pharmacies, accounts and devices are ordinary tables. Everything the app
syncs is kept in one generic table, `sync_rows`: one row per (pharmacy,
table, row id) holding the row as JSON, so app schema changes don't need a
server migration. Typed indexes/views are added when the server itself needs
to query a table (e.g. stock for the patient app in Phase 3).
"""

from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
    Sequence,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base

# One sequence numbers every change the server accepts; devices pull
# "everything after N".
change_seq = Sequence("change_seq", metadata=Base.metadata)


class Pharmacy(Base):
    __tablename__ = "pharmacies"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(200))
    # pending | active | suspended
    status: Mapped[str] = mapped_column(String(20), default="active")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class User(Base):
    """An account: pharmacy owner or employee (patients and admins later)."""

    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    pharmacy_id: Mapped[str | None] = mapped_column(ForeignKey("pharmacies.id"), index=True)
    # pharmacist_owner | pharmacist_employee | patient | admin
    role: Mapped[str] = mapped_column(String(30))
    name: Mapped[str] = mapped_column(String(200))
    # English digits, as typed ("0944 123 456" → "0944123456").
    phone: Mapped[str] = mapped_column(String(30), unique=True)
    password_hash: Mapped[str] = mapped_column(String(200))
    # The app's employee row this account signs in as.
    employee_id: Mapped[str | None] = mapped_column(String(36))
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Device(Base):
    """A linked device (counter PC, phone). Its secret token is stored hashed."""

    __tablename__ = "devices"

    # The app's own device id (UUIDv7), so events already carry it.
    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"), index=True)
    name: Mapped[str] = mapped_column(String(200))
    linked_by: Mapped[str] = mapped_column(ForeignKey("users.id"))
    token_hash: Mapped[str] = mapped_column(String(64), unique=True)
    linked_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class SyncRow(Base):
    """The latest version of one synced app row."""

    __tablename__ = "sync_rows"
    __table_args__ = (
        UniqueConstraint("pharmacy_id", "table_name", "row_id", name="sync_rows_key"),
        Index("sync_rows_cursor", "pharmacy_id", "seq"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"))
    table_name: Mapped[str] = mapped_column(String(60))
    row_id: Mapped[str] = mapped_column(String(80))
    # The row as the app sends it; null once deleted (tombstone).
    data: Mapped[dict | None] = mapped_column(JSONB)
    deleted: Mapped[bool] = mapped_column(Boolean, default=False)
    # Last-writer-wins order for mutable rows: (changed_at, device_id).
    changed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    device_id: Mapped[str] = mapped_column(String(36))
    seq: Mapped[int] = mapped_column(BigInteger, change_seq, server_default=change_seq.next_value())
    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
