import os
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text

from app.config import Settings
from app.main import create_app

TEST_DB = os.environ.get(
    "DOAYA_TEST_DATABASE_URL", "postgresql+psycopg://doaya:doaya@localhost:5432/doaya_test"
)
BACKEND = Path(__file__).resolve().parents[1]


def alembic_config(url: str = TEST_DB) -> Config:
    cfg = Config(str(BACKEND / "alembic.ini"))
    cfg.set_main_option("script_location", str(BACKEND / "migrations"))
    cfg.set_main_option("sqlalchemy.url", url)
    cfg.attributes["configure_logger"] = False
    return cfg


@pytest.fixture(scope="session")
def migrated() -> str:
    """The test database, rebuilt from the migrations once per test run."""
    engine = create_engine(TEST_DB)
    with engine.begin() as c:
        c.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public"))
    engine.dispose()
    command.upgrade(alembic_config(), "head")
    return TEST_DB


@pytest.fixture
def engine(migrated):
    engine = create_engine(migrated)
    yield engine
    with engine.begin() as c:
        c.execute(text("TRUNCATE sync_rows, devices, users, pharmacies RESTART IDENTITY CASCADE"))
    engine.dispose()


@pytest.fixture
def settings(migrated) -> Settings:
    return Settings(database_url=migrated, jwt_secret="test-secret")


@pytest.fixture
def client(settings: Settings, engine) -> TestClient:
    with TestClient(create_app(settings)) as c:
        yield c
