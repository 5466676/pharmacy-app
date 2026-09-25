from sqlalchemy import text

from app.backup import BackupScheduler, backup_now, list_backups, restore


def test_backup_and_restore_bring_the_data_back(settings, engine, tmp_path):
    s = settings.model_copy(update={"data_dir": str(tmp_path)})
    with engine.begin() as c:
        c.execute(
            text("INSERT INTO pharmacies (id, name, status) VALUES ('p1', 'الشفاء', 'active')")
        )
    dump = backup_now(s)
    assert dump.exists() and dump.stat().st_size > 0
    with engine.begin() as c:
        c.execute(text("DELETE FROM pharmacies"))
    restore(s, dump)
    with engine.connect() as c:
        assert c.execute(text("SELECT name FROM pharmacies")).scalar_one() == "الشفاء"


def test_only_the_newest_backups_are_kept(settings, engine, tmp_path):
    s = settings.model_copy(update={"data_dir": str(tmp_path)})
    folder = tmp_path / "backups"
    folder.mkdir()
    for i in range(4):  # older dumps already there
        (folder / f"doaya-20260101-00000{i}.dump").write_bytes(b"x")
    backup_now(s, keep=3)
    names = [f.name for f in list_backups(s)]
    assert len(names) == 3
    assert "doaya-20260101-000000.dump" not in names and names[-1] > "doaya-2026010"


def test_scheduler_knows_when_a_backup_is_due(settings, tmp_path):
    s = settings.model_copy(update={"data_dir": str(tmp_path)})
    sched = BackupScheduler(s)
    assert sched.due()  # never backed up
    backup_now(s)
    assert not sched.due()


def test_owner_sees_the_last_backup(client, settings):
    from .test_accounts import auth, setup_pharmacy

    owner = setup_pharmacy(client)
    r = client.get("/backups", headers=auth(owner["access_token"]))
    assert r.status_code == 200
    assert set(r.json()) == {"latest", "count", "error"}
