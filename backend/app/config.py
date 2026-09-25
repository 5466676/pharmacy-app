from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Server settings, from environment variables (DOAYA_*) or a `.env` file."""

    model_config = SettingsConfigDict(env_prefix="DOAYA_", env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg://doaya:doaya@localhost:5432/doaya"

    # Signs access tokens. Must be set to a long random value in production.
    jwt_secret: str = "change-me"
    access_token_minutes: int = 15
    refresh_token_days: int = 180

    # The app finds the server on the local network by UDP broadcast.
    discovery_port: int = 47800
    http_port: int = 8000


@lru_cache
def get_settings() -> Settings:
    return Settings()
