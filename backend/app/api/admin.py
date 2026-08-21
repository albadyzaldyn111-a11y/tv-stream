from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import require_admin
from app.core.config import get_settings
from app.database.session import get_db
from app.repositories.channel_repository import ChannelRepository
from app.schemas.channel import ChannelCreate, ChannelDetail, ChannelPublic, ChannelUpdate
from app.services.stream_health import StreamHealthService

router = APIRouter(prefix="/api/admin", tags=["admin"], dependencies=[Depends(require_admin)])


def normalize_payload(payload: ChannelCreate | ChannelUpdate) -> dict:
    values = payload.model_dump(exclude_unset=True)
    for key in ("logo_url", "stream_url", "source_url"):
        if values.get(key) is not None:
            values[key] = str(values[key])
    return values


@router.get("/channels", response_model=list[ChannelPublic])
def list_all_channels(db: Session = Depends(get_db)):
    return [ChannelPublic.from_channel(item) for item in ChannelRepository(db).list_all()]


@router.post("/channels", response_model=ChannelDetail, status_code=status.HTTP_201_CREATED)
def create_channel(payload: ChannelCreate, db: Session = Depends(get_db)):
    repository = ChannelRepository(db)
    try:
        channel = repository.create(normalize_payload(payload))
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="Channel slug must be unique.") from exc
    return ChannelDetail.from_channel(channel)


@router.put("/channels/{channel_id}", response_model=ChannelDetail)
def update_channel(channel_id: int, payload: ChannelUpdate, db: Session = Depends(get_db)):
    repository = ChannelRepository(db)
    channel = repository.get_by_id(channel_id)
    if not channel:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Channel not found.")
    try:
        channel = repository.update(channel, normalize_payload(payload))
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="Could not update channel.") from exc
    return ChannelDetail.from_channel(channel)


@router.delete("/channels/{channel_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_channel(channel_id: int, db: Session = Depends(get_db)):
    repository = ChannelRepository(db)
    channel = repository.get_by_id(channel_id)
    if not channel:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Channel not found.")
    repository.delete(channel)


@router.post("/channels/{channel_id}/health-check", response_model=ChannelDetail)
async def health_check_channel(channel_id: int, db: Session = Depends(get_db)):
    repository = ChannelRepository(db)
    channel = repository.get_by_id(channel_id)
    if not channel:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Channel not found.")
    await StreamHealthService(get_settings()).update_channel(channel)
    db.commit()
    db.refresh(channel)
    return ChannelDetail.from_channel(channel)
