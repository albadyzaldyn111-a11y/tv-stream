from datetime import datetime

from pydantic import AnyHttpUrl, BaseModel, ConfigDict, Field, field_serializer

from app.models.channel import Channel, HealthStatus, RightsStatus, StreamType


class ChannelBase(BaseModel):
    name: str = Field(min_length=1, max_length=160)
    slug: str = Field(pattern=r"^[a-z0-9]+(?:-[a-z0-9]+)*$", max_length=180)
    description: str | None = None
    country: str = Field(min_length=1, max_length=80)
    category: str = Field(min_length=1, max_length=40)
    logo_url: AnyHttpUrl | None = None
    stream_url: AnyHttpUrl | None = None
    stream_type: StreamType = StreamType.NONE
    language: str = "العربية"
    is_active: bool = True
    is_featured: bool = False
    source_url: AnyHttpUrl
    rights_status: RightsStatus
    notes: str | None = None


class ChannelCreate(ChannelBase):
    pass


class ChannelUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=160)
    slug: str | None = Field(default=None, pattern=r"^[a-z0-9]+(?:-[a-z0-9]+)*$", max_length=180)
    description: str | None = None
    country: str | None = Field(default=None, max_length=80)
    category: str | None = Field(default=None, max_length=40)
    logo_url: AnyHttpUrl | None = None
    stream_url: AnyHttpUrl | None = None
    stream_type: StreamType | None = None
    language: str | None = None
    is_active: bool | None = None
    is_featured: bool | None = None
    source_url: AnyHttpUrl | None = None
    rights_status: RightsStatus | None = None
    notes: str | None = None


class ChannelPublic(BaseModel):
    id: int
    name: str
    slug: str
    description: str | None
    country: str
    category: str
    logo_url: str | None
    stream_type: StreamType
    language: str
    is_active: bool
    is_featured: bool
    source_url: str
    rights_status: RightsStatus
    health_status: HealthStatus
    last_checked_at: datetime | None
    has_playable_stream: bool

    @field_serializer("stream_type", "rights_status", "health_status")
    def serialize_enums(self, value):
        return value.value

    @classmethod
    def from_channel(cls, channel: Channel):
        return cls(
            id=channel.id,
            name=channel.name,
            slug=channel.slug,
            description=channel.description,
            country=channel.country,
            category=channel.category,
            logo_url=str(channel.logo_url) if channel.logo_url else None,
            stream_type=channel.stream_type,
            language=channel.language,
            is_active=channel.is_active,
            is_featured=channel.is_featured,
            source_url=str(channel.source_url),
            rights_status=channel.rights_status,
            health_status=channel.health_status,
            last_checked_at=channel.last_checked_at,
            has_playable_stream=bool(channel.stream_url and channel.rights_status == RightsStatus.VERIFIED),
        )


class ChannelDetail(ChannelPublic):
    stream_url: str | None = None

    @classmethod
    def from_channel(cls, channel: Channel):
        public = ChannelPublic.from_channel(channel).model_dump()
        can_play = bool(channel.stream_url and channel.rights_status == RightsStatus.VERIFIED)
        return cls(**public, stream_url=str(channel.stream_url) if can_play else None)


class ChannelListResponse(BaseModel):
    items: list[ChannelPublic]
    total: int
    page: int
    page_size: int
