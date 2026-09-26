"""Phase 4b step 2: prompt versions, safety examples, and the «see a
doctor» marker on consultations."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0007"
down_revision: str | Sequence[str] | None = "0006"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

TS = sa.DateTime(timezone=True)


def upgrade() -> None:
    op.add_column("consultations", sa.Column("doctor_advice", sa.String(length=40), nullable=True))
    op.create_table(
        "prompt_versions",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("kind", sa.String(length=12), nullable=False),
        sa.Column("text", sa.String(length=8000), nullable=False),
        sa.Column("note", sa.String(length=300), nullable=True),
        sa.Column("status", sa.String(length=8), nullable=False),
        sa.Column("test", postgresql.JSONB(), nullable=True),
        sa.Column("tested_at", TS, nullable=True),
        sa.Column("created_by", sa.String(length=36), nullable=False),
        sa.Column("created_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.Column("activated_at", TS, nullable=True),
        sa.ForeignKeyConstraint(["created_by"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_prompt_versions_kind"), "prompt_versions", ["kind"])
    op.create_table(
        "safety_examples",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("text", sa.String(length=1000), nullable=False),
        sa.Column("label", sa.String(length=10), nullable=False),
        sa.Column("note", sa.String(length=300), nullable=True),
        sa.Column("enabled", sa.Boolean(), nullable=False),
        sa.Column("created_by", sa.String(length=36), nullable=False),
        sa.Column("created_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["created_by"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def downgrade() -> None:
    op.drop_table("safety_examples")
    op.drop_index(op.f("ix_prompt_versions_kind"), table_name="prompt_versions")
    op.drop_table("prompt_versions")
    op.drop_column("consultations", "doctor_advice")
