"""Phase 4: the heartbeat, the owner's control over a pharmacy's system, and
the monthly health check (verdicts only, never business data)."""

import json
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy.orm import Session

from app.control import control_state, heartbeat_body, send_heartbeat
from app.health_check import run_checks
from app.models import Device, SyncRow

from .central_helpers import pharmacy_auth
from .test_accounts import auth, setup_pharmacy
from .test_admin import act, admin_login, bearer, new_pharmacy

NOW = datetime(2026, 9, 26, 12, tzinfo=UTC)


@pytest.fixture
def world(client, settings, engine, tmp_path):
    """One server playing both parts: the pharmacy's own server (set up
    first, so it's the local pharmacy) and Doaya online, where the owner
    added the same pharmacy and gave it a key."""
    local = setup_pharmacy(client)
    admin = bearer(admin_login(client, settings))
    ph = new_pharmacy(client, admin)
    s = settings.model_copy(update={"data_dir": str(tmp_path), "central_key": ph["key"]})
    client.app.state.settings = s
    return {
        "admin": admin,
        "ph": ph,
        "settings": s,
        "device": auth(local["access_token"]),
    }


def beat(client, engine, world, **kw) -> dict:
    with Session(engine) as db:
        return send_heartbeat(db, world["settings"], client=client, disk_free_mb=50_000, **kw)


def _approx(iso: str, expected: datetime) -> bool:
    return abs(datetime.fromisoformat(iso) - expected) < timedelta(minutes=1)


# ─── Doaya online's side ────────────────────────────────────────────────────


def test_the_heartbeat_reports_the_technical_state_and_hears_the_control(client, engine, world):
    answer = beat(client, engine, world, backup_error="pg_dump missing")
    now = datetime.now(UTC)
    assert answer["state"] == "active"
    assert _approx(answer["licence_until"], now + timedelta(days=30))
    # The first heartbeat carried a health check (none on record yet).
    d = client.get(f"/admin/pharmacies/{world['ph']['id']}", headers=world["admin"]).json()
    assert d["connected"] is True
    hb = d["heartbeat"]
    assert hb["backup_error"] == "pg_dump missing"
    assert [x["name"] for x in hb["devices"]] == ["لابتوب الكاونتر"]
    assert d["health"] == "problem"  # no backup yet
    assert {c["id"] for c in d["health_report"]["checks"]} >= {"backup", "stock_below_zero"}
    assert answer["health_wanted"] is False
    # The owner asks for a check now: the next answer asks for it.
    act(client, world["admin"], world["ph"]["id"], "health_check")
    assert beat(client, engine, world)["health_wanted"] is True
    assert beat(client, engine, world)["health_wanted"] is False


def test_suspended_hears_it_and_keeps_its_licence_stopped_is_locked(client, engine, world):
    admin, pid = world["admin"], world["ph"]["id"]
    act(client, admin, pid, "suspend", reason="تأخير")
    a = beat(client, engine, world)
    assert (a["state"], a["reason"]) == ("suspended", "تأخير")
    assert _approx(a["licence_until"], datetime.now(UTC) + timedelta(days=30))
    act(client, admin, pid, "stop", reason="انتهى العقد")
    a = beat(client, engine, world)
    assert a["state"] == "stopped"
    assert _approx(a["licence_until"], datetime.now(UTC))
    assert a["health_wanted"] is False


def test_a_removed_pharmacy_still_hears_it_was_removed(client, engine, world):
    act(client, world["admin"], world["ph"]["id"], "remove", reason="شلنا البرنامج")
    assert beat(client, engine, world)["state"] == "removed"


def test_a_replaced_key_is_refused(client, engine, world):
    act(client, world["admin"], world["ph"]["id"], "new_key", reason="انسرق الكمبيوتر")
    r = client.post(
        "/pharmacy-api/heartbeat",
        json={"server_version": "1"},
        headers=pharmacy_auth(world["ph"]["key"]),
    )
    assert r.status_code == 401
    assert client.post("/pharmacy-api/heartbeat", json={"server_version": "1"}).status_code == 401


def test_licence_days_come_from_the_owner(client, engine, world):
    act(client, world["admin"], world["ph"]["id"], "licence", licence_days=7)
    a = beat(client, engine, world)
    assert a["licence_days"] == 7
    assert _approx(a["licence_until"], datetime.now(UTC) + timedelta(days=7))


def test_the_heartbeat_never_carries_business_data(client, engine, world):
    with Session(engine) as db:
        pid = db.query(Device).first().pharmacy_id
        _row(db, pid, "products", "p1", {"id": "p1", "trade_name": "Amoxil", "price_minor": 4500})
        _row(db, pid, "sales", "s1", _event("s1", total_minor=987654))
        _row(db, pid, "customers", "c1", {"id": "c1", "name": "أبو خالد"})
        db.commit()
        body = heartbeat_body(db, world["settings"], with_health=True, disk_free_mb=50_000)
    assert set(body) == {
        "server_version",
        "devices",
        "last_backup_at",
        "backup_error",
        "shelf_error",
        "disk_free_mb",
        "health",
    }
    text = json.dumps(body, ensure_ascii=False)
    for secret in ("Amoxil", "4500", "987654", "أبو خالد", "p1", "s1"):
        assert secret not in text


# ─── The pharmacy's own side ────────────────────────────────────────────────


def test_devices_learn_whether_the_system_is_locked(client, engine, world):
    device = world["device"]
    assert client.get("/control", headers=device).json()["state"] == "standalone"
    beat(client, engine, world)
    c = client.get("/control", headers=device).json()
    assert (c["state"], c["locked"]) == ("active", False)
    act(client, world["admin"], world["ph"]["id"], "stop", reason="انتهى العقد")
    beat(client, engine, world)
    c = client.get("/control", headers=device).json()
    assert (c["state"], c["locked"], c["reason"]) == ("stopped", True, "انتهى العقد")
    act(client, world["admin"], world["ph"]["id"], "resume")
    beat(client, engine, world)
    assert client.get("/control", headers=device).json()["locked"] is False
    assert client.get("/control").status_code == 401


def test_no_contact_for_longer_than_the_licence_locks_it(client, engine, world):
    beat(client, engine, world)
    s = world["settings"]
    now = datetime.now(UTC)
    assert control_state(s, now + timedelta(days=29))["locked"] is False
    late = control_state(s, now + timedelta(days=31))
    assert (late["locked"], late["licence_expired"], late["state"]) == (True, True, "active")


def test_removing_the_link_does_not_lift_the_lock(client, engine, world):
    act(client, world["admin"], world["ph"]["id"], "stop", reason="انتهى العقد")
    beat(client, engine, world)
    assert client.delete("/central-link", headers=world["device"]).status_code == 200
    assert client.get("/control", headers=world["device"]).json()["locked"] is True


def test_offline_the_last_answer_keeps_counting(client, engine, world):
    import httpx

    beat(client, engine, world)
    before = control_state(world["settings"])
    offline = httpx.Client(transport=httpx.MockTransport(_refuse), base_url="http://central")
    with Session(engine) as db, pytest.raises(httpx.ConnectError):
        send_heartbeat(db, world["settings"], client=offline, disk_free_mb=1)
    assert control_state(world["settings"]) == before


def _refuse(request):
    import httpx

    raise httpx.ConnectError("no internet", request=request)


# ─── The health check ───────────────────────────────────────────────────────


def _row(db, pid, table, row_id, data):
    db.add(
        SyncRow(
            pharmacy_id=pid,
            table_name=table,
            row_id=row_id,
            data=data,
            deleted=False,
            changed_at=datetime.now(UTC),
            device_id="pc",
        )
    )


def _event(eid, **extra) -> dict:
    return {
        "id": eid,
        "device_id": "pc",
        "employee_id": "e1",
        "occurred_at": "2026-09-01T10:00:00.000",
        **extra,
    }


def _levels(report) -> dict:
    return {c["id"]: (c["level"], c["count"]) for c in report["checks"]}


def test_health_check_finds_the_problems_and_counts_only(client, engine, settings, tmp_path):
    setup_pharmacy(client)
    s = settings.model_copy(update={"data_dir": str(tmp_path)})
    with Session(engine) as db:
        dev = db.query(Device).first()
        pid = dev.pharmacy_id
        dev.last_seen_at = NOW - timedelta(days=10)
        stock = [
            ("a", "b1", 5, "2026-12-01T00:00:00.000"),
            ("a", "b1", -2, None),
            ("b", "b2", 3, "2026-08-01T00:00:00.000"),  # expired, still 3 left
            ("c", "b3", 1, None),
            ("c", "b3", -2, None),  # below zero
        ]
        for i, (prod, batch, q, exp) in enumerate(stock):
            _row(
                db,
                pid,
                "stock_events",
                f"s{i}",
                _event(f"s{i}", product_id=prod, batch_id=batch, quantity=q, expiry=exp),
            )
        _row(db, pid, "debt_events", "d1", {"id": "d1", "device_id": "pc"})  # incomplete
        _row(db, pid, "till_events", "t1", _event("t1", type="opened", shift_id="t1"))
        _row(db, pid, "till_events", "t2", _event("t2", type="opened", shift_id="t2"))
        _row(db, pid, "till_events", "t3", _event("t3", type="closed", shift_id="t2"))
        db.commit()
        report = run_checks(db, s, pid, now=NOW, disk_free_mb=1000)
    assert _levels(report) == {
        "backup": ("problem", None),
        "devices_synced": ("warn", 1),
        "stock_below_zero": ("problem", 1),
        "expired_on_sale": ("warn", 1),
        "events_incomplete": ("problem", 1),
        "open_shifts": ("warn", 1),
        "disk": ("warn", 1000),
    }


def test_a_healthy_pharmacy_is_all_ok(client, engine, settings, tmp_path):
    setup_pharmacy(client)
    s = settings.model_copy(update={"data_dir": str(tmp_path)})
    backups = tmp_path / "backups"
    backups.mkdir()
    (backups / "doaya-20260926.dump").write_bytes(b"x")
    with Session(engine) as db:
        dev = db.query(Device).first()
        dev.last_seen_at = datetime.now(UTC)
        _row(db, dev.pharmacy_id, "stock_events", "s1", _event("s1", product_id="a", quantity=2))
        db.commit()
        report = run_checks(db, s, dev.pharmacy_id, disk_free_mb=50_000)
    assert {c["level"] for c in report["checks"]} == {"ok"}
