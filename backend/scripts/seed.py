import json
from pathlib import Path

from app.database.session import Base, SessionLocal, engine
from app.models.channel import Channel


SCRIPT_PATH = Path(__file__).resolve()
ROOT_CANDIDATES = [SCRIPT_PATH.parents[2], SCRIPT_PATH.parents[1], SCRIPT_PATH.parent]
SEED_FILE = next((root / "data" / "channels_seed.json" for root in ROOT_CANDIDATES if (root / "data" / "channels_seed.json").exists()), None)


def main() -> None:
    if SEED_FILE is None:
        raise FileNotFoundError("Could not locate data/channels_seed.json")
    Base.metadata.create_all(bind=engine)
    channels = json.loads(SEED_FILE.read_text(encoding="utf-8"))
    db = SessionLocal()
    try:
        for item in channels:
            existing = db.query(Channel).filter(Channel.slug == item["slug"]).one_or_none()
            if existing:
                for key, value in item.items():
                    setattr(existing, key, value)
            else:
                db.add(Channel(**item))
        db.commit()
        print(f"Seeded {len(channels)} channels from {SEED_FILE}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
