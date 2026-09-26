"""Phase 4 step 2: the admin's review of the AI log, and the knowledge
base."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0005"
down_revision: str | Sequence[str] | None = "0004"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

TS = sa.DateTime(timezone=True)


def upgrade() -> None:
    op.add_column("ai_log", sa.Column("review_note", sa.String(length=1000), nullable=True))
    op.add_column("ai_log", sa.Column("reviewed_by", sa.String(length=36), nullable=True))
    op.add_column("ai_log", sa.Column("reviewed_at", TS, nullable=True))
    op.create_foreign_key("ai_log_reviewed_by_fkey", "ai_log", "users", ["reviewed_by"], ["id"])
    op.create_table(
        "knowledge_notes",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("text", sa.String(length=1000), nullable=False),
        sa.Column("tags", postgresql.JSONB(), nullable=False),
        sa.Column("enabled", sa.Boolean(), nullable=False),
        sa.Column("source_log_id", sa.BigInteger(), nullable=True),
        sa.Column("created_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["source_log_id"], ["ai_log.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_table(
        "knowledge_changes",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("note_id", sa.String(length=36), nullable=False),
        sa.Column("admin_id", sa.String(length=36), nullable=False),
        sa.Column("action", sa.String(length=10), nullable=False),
        sa.Column("before", postgresql.JSONB(), nullable=True),
        sa.Column("after", postgresql.JSONB(), nullable=False),
        sa.Column("created_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["admin_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["note_id"], ["knowledge_notes.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_knowledge_changes_note_id"), "knowledge_changes", ["note_id"])


def downgrade() -> None:
    op.drop_index(op.f("ix_knowledge_changes_note_id"), table_name="knowledge_changes")
    op.drop_table("knowledge_changes")
    op.drop_table("knowledge_notes")
    op.drop_constraint("ai_log_reviewed_by_fkey", "ai_log", type_="foreignkey")
    op.drop_column("ai_log", "reviewed_at")
    op.drop_column("ai_log", "reviewed_by")
    op.drop_column("ai_log", "review_note")
