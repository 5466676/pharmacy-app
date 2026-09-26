import secrets
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from sqlalchemy import select, text

from . import (
    __version__,
    accounts,
    central_proxy,
    consultations,
    directory,
    orders,
    patients,
    realtime,
    sync,
)
from .backup import BackupScheduler, latest_backup_time, list_backups
from .bridge import ShelfPublisher
from .config import Settings, get_settings
from .db import Database
from .deps import DbSession, Owner
from .discovery import DiscoveryResponder
from .events import Events
from .models import Pharmacy
from .security import LoginLimiter
from .tls import ensure_certificate


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


def create_app(
    settings: Settings | None = None,
    *,
    discovery: bool = False,
    backups: bool = False,
    tls: bool = False,
) -> FastAPI:
    """[discovery] starts the Wi-Fi discovery responder and [backups] the
    daily database backup (the real server; tests leave them off). With [tls]
    discovery announces https and the certificate fingerprint."""
    settings = ensure_secret(settings or get_settings())

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        responder = None
        if discovery:

            def pharmacy_name() -> str | None:
                with app.state.db.sessions() as s:
                    return s.scalar(select(Pharmacy.name).order_by(Pharmacy.created_at).limit(1))

            fingerprint = ensure_certificate(settings.data_dir).fingerprint if tls else None
            responder = DiscoveryResponder(
                settings.discovery_port, settings.http_port, pharmacy_name, fingerprint
            ).start()
        scheduler = BackupScheduler(settings).start() if backups else None
        app.state.backups = scheduler
        publisher = None
        if backups and settings.central_url and settings.central_key:
            publisher = ShelfPublisher(
                settings, app.state.db.sessions, every=settings.shelf_publish_minutes * 60
            ).start()
        app.state.shelf_publisher = publisher
        yield
        if publisher:
            publisher.stop()
        if responder:
            responder.stop()
        if scheduler:
            scheduler.stop()

    app = FastAPI(title="Doaya", version=__version__, lifespan=lifespan)
    app.state.settings = settings
    app.state.db = Database(settings.database_url)
    app.state.login_limiter = LoginLimiter()
    app.state.events = Events()
    app.state.llm = None  # made from settings on first use
    app.include_router(accounts.router)
    app.include_router(sync.router)
    app.include_router(patients.router)
    app.include_router(directory.router)
    app.include_router(consultations.router)
    app.include_router(orders.router)
    app.include_router(realtime.router)
    app.include_router(central_proxy.router)

    @app.get("/health")
    def health(db: DbSession) -> dict:
        db.execute(text("SELECT 1"))
        return {"status": "ok", "service": "doaya", "version": __version__}

    @app.get("/backups")
    def backups_state(_: Owner) -> dict:
        """For the owner: when the server last backed up the database."""
        last = latest_backup_time(settings)
        scheduler = getattr(app.state, "backups", None)
        return {
            "latest": last.isoformat() if last else None,
            "count": len(list_backups(settings)),
            "error": scheduler.last_error if scheduler else None,
        }

    return app


def server_app(tls: bool = False) -> FastAPI:
    """What runs on the pharmacy PC: the API plus Wi-Fi discovery and backups
    (`python -m app.serve` turns on [tls])."""
    return create_app(discovery=True, backups=True, tls=tls)
