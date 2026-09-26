def test_health_reports_ok_with_a_live_database(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
    assert r.json()["service"] == "doaya"


def test_without_a_configured_secret_one_is_generated_once_and_kept(tmp_path, migrated):
    from app.config import Settings
    from app.main import ensure_secret

    s = Settings(database_url=migrated, jwt_secret="", data_dir=str(tmp_path))
    first = ensure_secret(s).jwt_secret
    assert len(first) >= 48
    assert ensure_secret(s).jwt_secret == first  # same after a restart


def test_browsers_elsewhere_are_let_in_only_from_configured_origins(settings, engine):
    from fastapi.testclient import TestClient

    from app.main import create_app

    ask = {"origin": "https://app.example", "access-control-request-method": "POST"}
    with TestClient(create_app(settings)) as c:
        r = c.options("/patients/login", headers=ask)
        assert "access-control-allow-origin" not in r.headers
    s = settings.model_copy(update={"cors_origins": "https://app.example, http://localhost:8200"})
    with TestClient(create_app(s)) as c:
        r = c.options("/patients/login", headers=ask)
        assert r.headers["access-control-allow-origin"] == "https://app.example"
        r = c.get("/health", headers={"origin": "https://evil.example"})
        assert "access-control-allow-origin" not in r.headers
