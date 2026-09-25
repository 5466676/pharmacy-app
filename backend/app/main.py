from typing import Annotated

from fastapi import Depends, FastAPI, Request
from sqlalchemy import text
from sqlalchemy.orm import Session

from . import __version__
from .config import Settings, get_settings
from .db import Database


def get_db(request: Request):
    yield from request.app.state.db.session()


DbSession = Annotated[Session, Depends(get_db)]


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or get_settings()
    app = FastAPI(title="Doaya", version=__version__)
    app.state.settings = settings
    app.state.db = Database(settings.database_url)

    @app.get("/health")
    def health(db: DbSession) -> dict:
        db.execute(text("SELECT 1"))
        return {"status": "ok", "service": "doaya", "version": __version__}

    return app
