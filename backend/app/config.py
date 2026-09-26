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

    # The AI assistant: any OpenAI-compatible chat server. Default is LM
    # Studio on the same machine (owner's choice for the pilot); Ollama is
    # http://localhost:11434/v1, a hosted service needs llm_api_key.
    llm_base_url: str = "http://localhost:1234/v1"
    llm_model: str = "qwen2.5-7b-instruct"
    llm_api_key: str = ""
    llm_timeout_seconds: float = 60

    # A pharmacy's own server → the central (internet) server. Empty: the
    # pharmacy works on its own. The key comes from `app.cli pharmacy-key`
    # on the central server.
    central_url: str = ""
    central_key: str = ""
    shelf_publish_minutes: float = 10

    # Where the patient web app is served from, when that's another address
    # than this server's (comma-separated, e.g. "https://app.example").
    # Empty: no browser page elsewhere may call this server.
    cors_origins: str = ""


@lru_cache
def get_settings() -> Settings:
    return Settings()
