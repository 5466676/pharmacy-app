import os

import pytest
from fastapi.testclient import TestClient

from app.config import Settings
from app.main import create_app

TEST_DB = os.environ.get(
    "DOAYA_TEST_DATABASE_URL", "postgresql+psycopg://doaya:doaya@localhost:5432/doaya_test"
)


@pytest.fixture
def settings() -> Settings:
    return Settings(database_url=TEST_DB, jwt_secret="test-secret")


@pytest.fixture
def client(settings: Settings) -> TestClient:
    with TestClient(create_app(settings)) as c:
        yield c
