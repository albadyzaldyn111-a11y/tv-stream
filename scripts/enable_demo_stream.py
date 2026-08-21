from app.database.session import SessionLocal
from app.models.channel import Channel

with SessionLocal() as db:
    channel = db.query(Channel).filter(Channel.slug == "hls-test-stream").one()
    channel.is_active = True
    channel.is_featured = True
    db.commit()
    print(f"Enabled demo stream: {channel.name}")
