"""Phase 3 step 7: prescription photos (in a consultation or with an
order)."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0003"
down_revision: str | Sequence[str] | None = "0002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "photos",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("patient_id", sa.String(length=36), nullable=False),
        sa.Column("pharmacy_id", sa.String(length=36), nullable=False),
        sa.Column("content_type", sa.String(length=20), nullable=False),
        sa.Column("size", sa.Integer(), nullable=False),
        sa.Column("consultation_id", sa.String(length=36), nullable=True),
        sa.Column("order_id", sa.String(length=36), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["patient_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["pharmacy_id"], ["pharmacies.id"]),
        sa.ForeignKeyConstraint(["consultation_id"], ["consultations.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_photos_patient_id"), "photos", ["patient_id"], unique=False)
    op.add_column("consult_messages", sa.Column("photo_id", sa.String(length=36), nullable=True))
    op.create_foreign_key(
        "consult_messages_photo_id_fkey", "consult_messages", "photos", ["photo_id"], ["id"]
    )
    op.add_column("patient_orders", sa.Column("photo_id", sa.String(length=36), nullable=True))
    op.create_foreign_key(
        "patient_orders_photo_id_fkey", "patient_orders", "photos", ["photo_id"], ["id"]
    )


def downgrade() -> None:
    op.drop_constraint("patient_orders_photo_id_fkey", "patient_orders", type_="foreignkey")
    op.drop_column("patient_orders", "photo_id")
    op.drop_constraint("consult_messages_photo_id_fkey", "consult_messages", type_="foreignkey")
    op.drop_column("consult_messages", "photo_id")
    op.drop_index(op.f("ix_photos_patient_id"), table_name="photos")
    op.drop_table("photos")
