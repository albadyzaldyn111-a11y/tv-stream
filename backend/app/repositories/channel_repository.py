from sqlalchemy import Select, func, or_, select
from sqlalchemy.orm import Session

from app.models.channel import Channel, RightsStatus


class ChannelRepository:
    def __init__(self, db: Session):
        self.db = db

    def public_query(self, category: str | None = None, query: str | None = None) -> Select:
        statement = select(Channel).where(
            Channel.is_active.is_(True),
            Channel.rights_status.in_([RightsStatus.VERIFIED, RightsStatus.OFFICIAL_SOURCE]),
        )
        if category and category.lower() != "all":
            statement = statement.where(Channel.category == category)
        if query:
            pattern = f"%{query.strip()}%"
            statement = statement.where(
                or_(Channel.name.ilike(pattern), Channel.country.ilike(pattern), Channel.category.ilike(pattern))
            )
        return statement.order_by(Channel.is_featured.desc(), Channel.name.asc())

    def list_public(self, page: int, page_size: int, category: str | None = None, query: str | None = None):
        statement = self.public_query(category, query)
        items = self.db.scalars(statement.offset((page - 1) * page_size).limit(page_size)).all()
        total_statement = select(func.count()).select_from(self.public_query(category, query).subquery())
        total = self.db.scalar(total_statement) or 0
        return items, total

    def get_public_by_id(self, channel_id: int) -> Channel | None:
        statement = self.public_query().where(Channel.id == channel_id)
        return self.db.scalar(statement)

    def get_public_by_slug(self, slug: str) -> Channel | None:
        statement = self.public_query().where(Channel.slug == slug)
        return self.db.scalar(statement)

    def list_categories(self) -> list[str]:
        statement = (
            select(Channel.category)
            .where(
                Channel.is_active.is_(True),
                Channel.rights_status.in_([RightsStatus.VERIFIED, RightsStatus.OFFICIAL_SOURCE]),
            )
            .distinct()
            .order_by(Channel.category.asc())
        )
        return list(self.db.scalars(statement).all())

    def list_all(self):
        return self.db.scalars(select(Channel).order_by(Channel.created_at.desc())).all()

    def get_by_id(self, channel_id: int) -> Channel | None:
        return self.db.get(Channel, channel_id)

    def create(self, values: dict) -> Channel:
        channel = Channel(**values)
        self.db.add(channel)
        self.db.commit()
        self.db.refresh(channel)
        return channel

    def update(self, channel: Channel, values: dict) -> Channel:
        for key, value in values.items():
            setattr(channel, key, value)
        self.db.commit()
        self.db.refresh(channel)
        return channel

    def delete(self, channel: Channel) -> None:
        self.db.delete(channel)
        self.db.commit()
