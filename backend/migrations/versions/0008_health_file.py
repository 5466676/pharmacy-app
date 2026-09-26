"""Phase 5: the patient's health file (facts, proposals, change log, the
owner's access log, consent)."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0008"
down_revision: str | Sequence[str] | None = "0007"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

TS = sa.DateTime(timezone=True)


def _now() -> sa.Column:
    return sa.Column("created_at", TS, server_default=sa.text("now()"), nullable=False)


def upgrade() -> None:
    op.add_column("patient_profiles", sa.Column("file_consent_at", TS, nullable=True))
    op.create_table(
        "health_facts",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("patient_id", sa.String(length=36), nullable=False),
        sa.Column("kind", sa.String(length=12), nullable=False),
        sa.Column("text", sa.String(length=300), nullable=False),
        sa.Column("detail", postgresql.JSONB(), nullable=True),
        sa.Column("source", sa.String(length=10), nullable=False),
        sa.Column("confirmed", sa.Boolean(), nullable=False),
        sa.Column("added_by", sa.String(length=200), nullable=True),
        sa.Column("pharmacy_id", sa.String(length=36), nullable=True),
        sa.Column("consultation_id", sa.String(length=36), nullable=True),
        _now(),
        sa.Column("ends_at", TS, nullable=True),
        sa.Column("ended_at", TS, nullable=True),
        sa.ForeignKeyConstraint(["patient_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["pharmacy_id"], ["pharmacies.id"]),
        sa.ForeignKeyConstraint(["consultation_id"], ["consultations.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_health_facts_patient_id"), "health_facts", ["patient_id"])
    op.create_table(
        "file_proposals",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("patient_id", sa.String(length=36), nullable=False),
        sa.Column("consultation_id", sa.String(length=36), nullable=True),
        sa.Column("kind", sa.String(length=12), nullable=False),
        sa.Column("text", sa.String(length=300), nullable=False),
        sa.Column("needs", sa.String(length=10), nullable=False),
        sa.Column("status", sa.String(length=8), nullable=False),
        sa.Column("decided_by", sa.String(length=200), nullable=True),
        sa.Column("decided_at", TS, nullable=True),
        _now(),
        sa.ForeignKeyConstraint(["patient_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["consultation_id"], ["consultations.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_file_proposals_patient_id"), "file_proposals", ["patient_id"])
    op.create_table(
        "file_changes",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("patient_id", sa.String(length=36), nullable=False),
        sa.Column("actor", sa.String(length=10), nullable=False),
        sa.Column("actor_name", sa.String(length=200), nullable=True),
        sa.Column("action", sa.String(length=12), nullable=False),
        sa.Column("detail", postgresql.JSONB(), nullable=True),
        _now(),
        sa.ForeignKeyConstraint(["patient_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_file_changes_patient_id"), "file_changes", ["patient_id"])
    op.create_table(
        "file_access",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("admin_id", sa.String(length=36), nullable=False),
        sa.Column("patient_id", sa.String(length=36), nullable=False),
        _now(),
        sa.ForeignKeyConstraint(["admin_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["patient_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_file_access_patient_id"), "file_access", ["patient_id"])


def downgrade() -> None:
    for t in ("file_access", "file_changes", "file_proposals", "health_facts"):
        op.drop_index(op.f(f"ix_{t}_patient_id"), table_name=t)
        op.drop_table(t)
    op.drop_column("patient_profiles", "file_consent_at")
