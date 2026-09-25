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
