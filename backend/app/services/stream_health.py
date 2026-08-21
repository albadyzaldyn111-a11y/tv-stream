from datetime import datetime, timezone

import httpx

from app.core.config import Settings
from app.models.channel import Channel, HealthStatus, RightsStatus, StreamType


class StreamHealthService:
    def __init__(self, settings: Settings):
        self.settings = settings

    async def check(self, channel: Channel) -> HealthStatus:
        if not channel.stream_url or channel.rights_status != RightsStatus.VERIFIED:
            return HealthStatus.UNKNOWN
        if channel.stream_type != StreamType.HLS:
            return HealthStatus.UNKNOWN

        try:
            async with httpx.AsyncClient(
                timeout=self.settings.health_check_timeout_seconds,
                follow_redirects=True,
                headers={"User-Agent": "TV-Stream-HealthCheck/1.0"},
            ) as client:
                response = await client.get(str(channel.stream_url))
                if response.status_code != 200:
                    return HealthStatus.OFFLINE
                body = response.text.lstrip()
                if "#EXTM3U" not in body:
                    return HealthStatus.OFFLINE
                if "#EXTINF" not in body and "#EXT-X-STREAM-INF" not in body:
                    return HealthStatus.UNKNOWN
                return HealthStatus.ONLINE
        except (httpx.HTTPError, ValueError):
            return HealthStatus.OFFLINE

    async def update_channel(self, channel: Channel) -> HealthStatus:
        channel.health_status = await self.check(channel)
        channel.last_checked_at = datetime.now(timezone.utc)
        return channel.health_status
