from fastapi import Header, HTTPException, status

from app.core.config import get_settings


def require_admin(x_admin_key: str | None = Header(default=None)) -> None:
    configured_key = get_settings().admin_api_key
    if not configured_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Admin API is disabled until ADMIN_API_KEY is configured.",
        )
    if x_admin_key != configured_key:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid admin key.")
