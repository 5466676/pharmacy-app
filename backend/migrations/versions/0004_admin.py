"""Phase 4 step 1: admin sessions and actions, pharmacy control state and
heartbeat, first response times."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0004"
down_revision: str | Sequence[str] | None = "0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

TS = sa.DateTime(timezone=True)


def upgrade() -> None:
    op.add_column("pharmacies", sa.Column("status_reason", sa.String(length=500), nullable=True))
    op.add_column(
        "pharmacies",
        sa.Column("licence_days", sa.Integer(), server_default="30", nullable=False),
    )
    op.add_column("pharmacies", sa.Column("last_heartbeat_at", TS, nullable=True))
    op.add_column("pharmacies", sa.Column("heartbeat", postgresql.JSONB(), nullable=True))
    op.add_column("pharmacies", sa.Column("health", postgresql.JSONB(), nullable=True))
    op.add_column("pharmacies", sa.Column("health_at", TS, nullable=True))
    op.add_column(
        "pharmacies",
        sa.Column("health_requested", sa.Boolean(), server_default="false", nullable=False),
    )
    op.add_column("consultations", sa.Column("first_action_at", TS, nullable=True))
    op.add_column("patient_orders", sa.Column("first_action_at", TS, nullable=True))
    op.create_table(
        "admin_sessions",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("created_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.Column("last_seen_at", TS, nullable=True),
        sa.Column("revoked_at", TS, nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("token_hash"),
    )
    op.create_index(op.f("ix_admin_sessions_user_id"), "admin_sessions", ["user_id"])
    op.create_table(
        "admin_actions",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("admin_id", sa.String(length=36), nullable=False),
        sa.Column("pharmacy_id", sa.String(length=36), nullable=True),
        sa.Column("action", sa.String(length=20), nullable=False),
        sa.Column("reason", sa.String(length=500), nullable=True),
        sa.Column("detail", postgresql.JSONB(), nullable=True),
        sa.Column("created_at", TS, server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["admin_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["pharmacy_id"], ["pharmacies.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_admin_actions_pharmacy_id"), "admin_actions", ["pharmacy_id"])


def downgrade() -> None:
    op.drop_index(op.f("ix_admin_actions_pharmacy_id"), table_name="admin_actions")
    op.drop_table("admin_actions")
    op.drop_index(op.f("ix_admin_sessions_user_id"), table_name="admin_sessions")
    op.drop_table("admin_sessions")
    op.drop_column("patient_orders", "first_action_at")
    op.drop_column("consultations", "first_action_at")
    for c in (
        "health_requested",
        "health_at",
        "health",
        "heartbeat",
        "last_heartbeat_at",
        "licence_days",
        "status_reason",
    ):
        op.drop_column("pharmacies", c)
