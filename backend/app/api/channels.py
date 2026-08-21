from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.repositories.channel_repository import ChannelRepository
from app.schemas.channel import ChannelDetail, ChannelListResponse, ChannelPublic

router = APIRouter(prefix="/api", tags=["channels"])


@router.get("/channels", response_model=ChannelListResponse)
def list_channels(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=24, ge=1, le=100),
    category: str | None = Query(default=None),
    q: str | None = Query(default=None, max_length=100),
    db: Session = Depends(get_db),
):
    items, total = ChannelRepository(db).list_public(page=page, page_size=page_size, category=category, query=q)
    return ChannelListResponse(
        items=[ChannelPublic.from_channel(item) for item in items],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/channels/search", response_model=ChannelListResponse)
def search_channels(
    q: str = Query(min_length=1, max_length=100),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=24, ge=1, le=100),
    db: Session = Depends(get_db),
):
    items, total = ChannelRepository(db).list_public(page=page, page_size=page_size, query=q)
    return ChannelListResponse(
        items=[ChannelPublic.from_channel(item) for item in items],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/channels/{channel_id}", response_model=ChannelDetail)
def get_channel(channel_id: int, db: Session = Depends(get_db)):
    channel = ChannelRepository(db).get_public_by_id(channel_id)
    if not channel:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Channel not found.")
    return ChannelDetail.from_channel(channel)


@router.get("/categories", response_model=list[str])
def list_categories(db: Session = Depends(get_db)):
    return ChannelRepository(db).list_categories()
