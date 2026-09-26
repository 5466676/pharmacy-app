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
    Integer,
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
    # pending | active | suspended | stopped | removed. On the central server
    # only the admin changes it; "stopped" and "removed" also lock the
    # pharmacy's own system when its server next checks in.
    status: Mapped[str] = mapped_column(String(20), default="active")
    status_reason: Mapped[str | None] = mapped_column(String(500))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    # Phase 4, central server: how long the pharmacy's system keeps working
    # without checking in, and what its server last reported (technical
    # state only: versions, devices, backups; never its business data).
    licence_days: Mapped[int] = mapped_column(Integer, default=30, server_default="30")
    last_heartbeat_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    heartbeat: Mapped[dict | None] = mapped_column(JSONB)
    # The monthly health check's results (verdicts and counts only).
    health: Mapped[dict | None] = mapped_column(JSONB)
    health_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    health_requested: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false")


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


# ─── Phase 3: patients, the directory, consultations, orders ─────────────────
# These live on the central (internet) server. A pharmacy's own server keeps
# using only the tables above, plus the bridge that publishes its shelf.


class PharmacyListing(Base):
    """How patients find a pharmacy: city, a short code shown at its counter,
    phone and hours. Only listed pharmacies appear in the directory."""

    __tablename__ = "pharmacy_listings"

    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"), primary_key=True)
    code: Mapped[str] = mapped_column(String(12), unique=True)
    city: Mapped[str] = mapped_column(String(80), index=True)
    address: Mapped[str | None] = mapped_column(String(300))
    phone: Mapped[str | None] = mapped_column(String(30))
    hours: Mapped[str | None] = mapped_column(String(120))
    listed: Mapped[bool] = mapped_column(Boolean, default=True)


class PharmacyKey(Base):
    """The key a pharmacy's own server uses to talk to the central server
    (publish its shelf, handle cases and orders). Stored hashed."""

    __tablename__ = "pharmacy_keys"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"), index=True)
    key_hash: Mapped[str] = mapped_column(String(64), unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class ShelfItem(Base):
    """One product as patients see it: price and available or not (never
    the quantity, owner's decision)."""

    __tablename__ = "shelf_items"

    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"), primary_key=True)
    product_id: Mapped[str] = mapped_column(String(36), primary_key=True)
    trade_name: Mapped[str] = mapped_column(String(200))
    arabic_name: Mapped[str | None] = mapped_column(String(200))
    active_ingredient: Mapped[str | None] = mapped_column(String(200))
    strength: Mapped[str | None] = mapped_column(String(60))
    form: Mapped[str | None] = mapped_column(String(60))
    price_minor: Mapped[int] = mapped_column(BigInteger)
    currency: Mapped[str] = mapped_column(String(3))
    available: Mapped[bool] = mapped_column(Boolean)
    prescription_only: Mapped[bool] = mapped_column(Boolean, default=False)
    photo_url: Mapped[str | None] = mapped_column(String(300))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class PatientProfile(Base):
    __tablename__ = "patient_profiles"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), primary_key=True)
    birth_year: Mapped[int | None] = mapped_column()
    # m | f
    sex: Mapped[str | None] = mapped_column(String(1))
    city: Mapped[str | None] = mapped_column(String(80))
    # The pharmacy the patient chose; cases and orders go there.
    pharmacy_id: Mapped[str | None] = mapped_column(ForeignKey("pharmacies.id"))


class PatientSession(Base):
    """A signed-in patient app: its long-lived secret, stored hashed."""

    __tablename__ = "patient_sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class Consultation(Base):
    """A chat with the assistant and, once sent, the pharmacy's case."""

    __tablename__ = "consultations"
    __table_args__ = (Index("consultations_pharmacy_updated", "pharmacy_id", "updated_at"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    patient_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"))
    # chatting | summary | sent | preparing | ready | picked_up | needs_doctor
    # | emergency | closed
    status: Mapped[str] = mapped_column(String(20))
    urgent: Mapped[bool] = mapped_column(Boolean, default=False)
    red_flag: Mapped[str | None] = mapped_column(String(40))
    summary: Mapped[dict | None] = mapped_column(JSONB)
    # The pharmacist's decision: medicines, how to use them, a note.
    decision: Mapped[dict | None] = mapped_column(JSONB)
    handled_by: Mapped[str | None] = mapped_column(String(200))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    sent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    # The pharmacist's first action on the case (response time).
    first_action_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class ConsultMessage(Base):
    __tablename__ = "consult_messages"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    consultation_id: Mapped[str] = mapped_column(ForeignKey("consultations.id"), index=True)
    # patient | assistant | pharmacist | system
    role: Mapped[str] = mapped_column(String(12))
    text: Mapped[str] = mapped_column(String(4000))
    quick_replies: Mapped[list | None] = mapped_column(JSONB)
    # The pharmacist's name for pharmacist messages.
    author: Mapped[str | None] = mapped_column(String(200))
    # A photo the patient sent (a prescription, a box).
    photo_id: Mapped[str | None] = mapped_column(ForeignKey("photos.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class AiLog(Base):
    """Every AI reply, red flag, guard block and pharmacist correction, for
    the admin review queue. Never used for automatic fine-tuning."""

    __tablename__ = "ai_log"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    consultation_id: Mapped[str] = mapped_column(ForeignKey("consultations.id"), index=True)
    # red_flag | assistant_reply | guard_block | summary | llm_down | correction
    kind: Mapped[str] = mapped_column(String(20), index=True)
    detail: Mapped[dict] = mapped_column(JSONB)
    reviewed: Mapped[bool] = mapped_column(Boolean, default=False)
    # Phase 4: the admin's review.
    review_note: Mapped[str | None] = mapped_column(String(1000))
    reviewed_by: Mapped[str | None] = mapped_column(ForeignKey("users.id"))
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class PatientOrder(Base):
    """An order for pickup from the shelf. The patient asks for quantities;
    the pharmacist sets the final ones. Paid at pickup."""

    __tablename__ = "patient_orders"
    __table_args__ = (Index("patient_orders_pharmacy_updated", "pharmacy_id", "updated_at"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    patient_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"))
    # sent | preparing | ready | picked_up | rejected | cancelled
    status: Mapped[str] = mapped_column(String(20))
    # [{product_id, name, requested, quantity, price_minor}]
    lines: Mapped[list] = mapped_column(JSONB)
    currency: Mapped[str] = mapped_column(String(3))
    note: Mapped[str | None] = mapped_column(String(1000))
    pharmacist_note: Mapped[str | None] = mapped_column(String(1000))
    handled_by: Mapped[str | None] = mapped_column(String(200))
    # A prescription photo sent with the order.
    photo_id: Mapped[str | None] = mapped_column(ForeignKey("photos.id"))
    first_action_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Photo(Base):
    """A photo a patient sent (a prescription, a medicine box). The file
    lives in `<data_dir>/photos/<id>`; only its patient and the pharmacy it
    was sent to can open it."""

    __tablename__ = "photos"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    patient_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    pharmacy_id: Mapped[str] = mapped_column(ForeignKey("pharmacies.id"))
    content_type: Mapped[str] = mapped_column(String(20))
    size: Mapped[int] = mapped_column(Integer)
    # Where it was sent: a consultation, or an order (set when attached).
    consultation_id: Mapped[str | None] = mapped_column(ForeignKey("consultations.id"))
    order_id: Mapped[str | None] = mapped_column(String(36))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


# ─── Phase 4: the platform owner's admin panel ──────────────────────────────


class AdminSession(Base):
    """A signed-in admin panel: its long-lived secret, stored hashed."""

    __tablename__ = "admin_sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class AdminAction(Base):
    """Every admin action on a pharmacy: who, when, what and why."""

    __tablename__ = "admin_actions"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    admin_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    pharmacy_id: Mapped[str | None] = mapped_column(ForeignKey("pharmacies.id"), index=True)
    # approve | suspend | resume | stop | remove | list | unlist | new_key
    # | licence | health_check
    action: Mapped[str] = mapped_column(String(20))
    reason: Mapped[str | None] = mapped_column(String(500))
    detail: Mapped[dict | None] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class KnowledgeNote(Base):
    """A short note the admin curates (usually from a pharmacist's
    correction) that helps the assistant ask better questions. Given to the
    assistant when the conversation mentions one of its tags. Never used
    for automatic training."""

    __tablename__ = "knowledge_notes"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    text: Mapped[str] = mapped_column(String(1000))
    tags: Mapped[list] = mapped_column(JSONB)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    # The review item it came from, if any.
    source_log_id: Mapped[int | None] = mapped_column(ForeignKey("ai_log.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class KnowledgeChange(Base):
    """Every change to a note: who, when, before and after."""

    __tablename__ = "knowledge_changes"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    note_id: Mapped[str] = mapped_column(ForeignKey("knowledge_notes.id"), index=True)
    admin_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    # create | update
    action: Mapped[str] = mapped_column(String(10))
    before: Mapped[dict | None] = mapped_column(JSONB)
    after: Mapped[dict] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
