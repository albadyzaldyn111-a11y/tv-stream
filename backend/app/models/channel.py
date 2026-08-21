from datetime import datetime
from enum import StrEnum

from sqlalchemy import Boolean, DateTime, Enum, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.database.session import Base


class RightsStatus(StrEnum):
    VERIFIED = "verified"
    OFFICIAL_SOURCE = "official_source"
    PERMISSION_REQUIRED = "permission_required"
    UNKNOWN = "unknown"
    UNAVAILABLE = "unavailable"


class StreamType(StrEnum):
    HLS = "HLS"
    DASH = "DASH"
    WEB = "WEB"
    NONE = "NONE"


class HealthStatus(StrEnum):
    ONLINE = "online"
    OFFLINE = "offline"
    UNKNOWN = "unknown"


class Channel(Base):
    __tablename__ = "channels"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(160), nullable=False)
    slug: Mapped[str] = mapped_column(String(180), unique=True, index=True, nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    country: Mapped[str] = mapped_column(String(80), nullable=False)
    category: Mapped[str] = mapped_column(String(40), index=True, nullable=False)
    logo_url: Mapped[str | None] = mapped_column(String(1000))
    stream_url: Mapped[str | None] = mapped_column(String(2000))
    stream_type: Mapped[StreamType] = mapped_column(Enum(StreamType), default=StreamType.NONE, nullable=False)
    language: Mapped[str] = mapped_column(String(40), default="العربية", nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True, nullable=False)
    is_featured: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    source_url: Mapped[str] = mapped_column(String(2000), nullable=False)
    rights_status: Mapped[RightsStatus] = mapped_column(Enum(RightsStatus), nullable=False)
    health_status: Mapped[HealthStatus] = mapped_column(Enum(HealthStatus), default=HealthStatus.UNKNOWN, nullable=False)
    last_checked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
