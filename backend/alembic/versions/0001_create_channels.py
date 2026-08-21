"""create channels

Revision ID: 0001_create_channels
Revises:
Create Date: 2026-08-21
"""

from alembic import op
import sqlalchemy as sa

revision = "0001_create_channels"
down_revision = None
branch_labels = None
depends_on = None

rights_status = sa.Enum(
    "verified", "official_source", "permission_required", "unknown", "unavailable",
    name="rightsstatus",
)
stream_type = sa.Enum("HLS", "DASH", "WEB", "NONE", name="streamtype")
health_status = sa.Enum("online", "offline", "unknown", name="healthstatus")


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        rights_status.create(bind, checkfirst=True)
        stream_type.create(bind, checkfirst=True)
        health_status.create(bind, checkfirst=True)
    op.create_table(
        "channels",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(length=160), nullable=False),
        sa.Column("slug", sa.String(length=180), nullable=False),
        sa.Column("description", sa.Text()),
        sa.Column("country", sa.String(length=80), nullable=False),
        sa.Column("category", sa.String(length=40), nullable=False),
        sa.Column("logo_url", sa.String(length=1000)),
        sa.Column("stream_url", sa.String(length=2000)),
        sa.Column("stream_type", stream_type, nullable=False),
        sa.Column("language", sa.String(length=40), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("is_featured", sa.Boolean(), nullable=False),
        sa.Column("source_url", sa.String(length=2000), nullable=False),
        sa.Column("rights_status", rights_status, nullable=False),
        sa.Column("health_status", health_status, nullable=False),
        sa.Column("last_checked_at", sa.DateTime(timezone=True)),
        sa.Column("notes", sa.Text()),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint("slug"),
    )
    op.create_index("ix_channels_slug", "channels", ["slug"], unique=True)
    op.create_index("ix_channels_category", "channels", ["category"])
    op.create_index("ix_channels_is_active", "channels", ["is_active"])


def downgrade() -> None:
    op.drop_index("ix_channels_is_active", table_name="channels")
    op.drop_index("ix_channels_category", table_name="channels")
    op.drop_index("ix_channels_slug", table_name="channels")
    op.drop_table("channels")
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        health_status.drop(bind, checkfirst=True)
        stream_type.drop(bind, checkfirst=True)
        rights_status.drop(bind, checkfirst=True)
