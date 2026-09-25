from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Server settings, from environment variables (DOAYA_*) or a `.env` file."""

    model_config = SettingsConfigDict(env_prefix="DOAYA_", env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg://doaya:doaya@localhost:5432/doaya"

    # Signs access tokens. Left empty, the server makes a strong one on first
    # run and keeps it in `<data_dir>/jwt_secret` (the pharmacy PC install).
    jwt_secret: str = ""
    data_dir: str = "data"
    access_token_minutes: int = 15
    refresh_token_days: int = 180

    # The app finds the server on the local network by UDP broadcast.
    discovery_port: int = 47800

    # Daily PostgreSQL backups into <data_dir>/backups (pg_dump from this
    # folder, or from PATH when empty).
    pg_bin_dir: str = ""
    backup_keep: int = 30
    http_port: int = 8000

    # Shown with every red-flag stop. Ambulance 110 is the Ministry of
    # Health's unified operations room (2026); 112 is police / emergency.
    emergency_ambulance: str = "110"
    emergency_general: str = "112"


@lru_cache
def get_settings() -> Settings:
    return Settings()
