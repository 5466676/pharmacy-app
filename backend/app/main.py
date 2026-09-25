import secrets
from pathlib import Path

from fastapi import FastAPI
from sqlalchemy import text

from . import __version__, accounts, sync
from .config import Settings, get_settings
from .db import Database
from .deps import DbSession
from .security import LoginLimiter


def ensure_secret(settings: Settings) -> Settings:
    """Uses the configured token secret, or one generated once and kept in
    the data folder (so restarts don't sign every device out)."""
    if settings.jwt_secret:
        return settings
    path = Path(settings.data_dir) / "jwt_secret"
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(secrets.token_urlsafe(48))
        path.chmod(0o600)
    return settings.model_copy(update={"jwt_secret": path.read_text().strip()})


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = ensure_secret(settings or get_settings())
    app = FastAPI(title="Doaya", version=__version__)
    app.state.settings = settings
    app.state.db = Database(settings.database_url)
    app.state.login_limiter = LoginLimiter()
    app.include_router(accounts.router)
    app.include_router(sync.router)

    @app.get("/health")
    def health(db: DbSession) -> dict:
        db.execute(text("SELECT 1"))
        return {"status": "ok", "service": "doaya", "version": __version__}

    return app
