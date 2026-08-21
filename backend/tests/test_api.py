from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.database.session import Base, get_db
from app.main import app
from app.models.channel import Channel, HealthStatus, RightsStatus, StreamType


@pytest.fixture()
def client() -> Generator[TestClient, None, None]:
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

    def override_get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    db = SessionLocal()
    db.add_all(
        [
            Channel(
                name="قناة مصرح بها",
                slug="verified-channel",
                description="مصدر اختبار HLS معلن.",
                country="Test",
                category="Educational",
                logo_url=None,
                stream_url="https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                stream_type=StreamType.HLS,
                language="العربية",
                is_active=True,
                is_featured=True,
                source_url="https://test-streams.mux.dev/",
                rights_status=RightsStatus.VERIFIED,
                health_status=HealthStatus.UNKNOWN,
            ),
            Channel(
                name="قناة رسمية",
                slug="official-channel",
                description="صفحة رسمية فقط.",
                country="المغرب",
                category="General",
                logo_url=None,
                stream_url=None,
                stream_type=StreamType.WEB,
                language="العربية",
                is_active=True,
                is_featured=False,
                source_url="https://snrtlive.ma/ar/al-aoula",
                rights_status=RightsStatus.OFFICIAL_SOURCE,
                health_status=HealthStatus.UNKNOWN,
            ),
            Channel(
                name="تحتاج ترخيصًا",
                slug="permission-channel",
                description="لا تظهر للعامة.",
                country="قطر",
                category="News",
                logo_url=None,
                stream_url="https://not-used.invalid/stream.m3u8",
                stream_type=StreamType.HLS,
                language="العربية",
                is_active=True,
                is_featured=False,
                source_url="https://www.aljazeera.net/",
                rights_status=RightsStatus.PERMISSION_REQUIRED,
                health_status=HealthStatus.UNKNOWN,
            ),
        ]
    )
    db.commit()
    db.close()

    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def test_public_list_filters_permission_required_and_hides_stream_url(client: TestClient):
    response = client.get("/api/channels")
    assert response.status_code == 200
    payload = response.json()
    assert payload["total"] == 2
    assert {item["slug"] for item in payload["items"]} == {"verified-channel", "official-channel"}
    assert all("stream_url" not in item for item in payload["items"])


def test_verified_detail_exposes_playable_stream(client: TestClient):
    response = client.get("/api/channels/1")
    assert response.status_code == 200
    assert response.json()["stream_url"].endswith(".m3u8")
    assert response.json()["has_playable_stream"] is True


def test_official_source_detail_does_not_expose_internal_stream(client: TestClient):
    response = client.get("/api/channels/2")
    assert response.status_code == 200
    assert response.json()["stream_url"] is None
    assert response.json()["rights_status"] == "official_source"


def test_categories_and_search(client: TestClient):
    assert client.get("/api/categories").json() == ["Educational", "General"]
    response = client.get("/api/channels/search", params={"q": "غير موجود"})
    assert response.status_code == 200
    assert response.json()["total"] == 0
