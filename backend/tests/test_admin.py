"""Phase 4: the platform owner's admin panel on the central server."""

from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy.orm import Session

from app.admin import MIN_CASES_TO_RANK, tier
from app.cli import main as cli
from app.models import AiLog, Consultation, PatientOrder, PatientProfile, Pharmacy, User
from app.security import hash_password, new_id

from .central_helpers import bearer, listed_pharmacy, pharmacy_auth, register
from .test_accounts import auth, setup_pharmacy

PHONE, PASSWORD = "0999000111", "owner-pass-1"


def make_admin(settings, phone=PHONE, password=PASSWORD) -> None:
    rc = cli(
        ["create-admin", "--name", "فايز", "--phone", phone, "--password", password],
        settings.database_url,
    )
    assert rc == 0


def admin_login(client, settings) -> dict:
    make_admin(settings)
    r = client.post("/admin/login", json={"phone": PHONE, "password": PASSWORD})
    assert r.status_code == 200, r.text
    return r.json()


@pytest.fixture
def admin(client, settings) -> dict:
    return bearer(admin_login(client, settings))


# ─── Sign-in and who may call ──────────────────────────────────────────────


def test_admin_signs_in_refreshes_and_signs_out(client, settings):
    s = admin_login(client, settings)
    assert s["admin"]["name"] == "فايز"
    assert client.get("/admin/me", headers=bearer(s)).json()["name"] == "فايز"
    r = client.post("/admin/token", json={"session_token": s["session_token"]})
    assert r.status_code == 200
    assert client.post("/admin/logout", headers=bearer(s)).status_code == 200
    assert client.get("/admin/me", headers=bearer(s)).status_code == 401
    r = client.post("/admin/token", json={"session_token": s["session_token"]})
    assert r.status_code == 401


def test_cli_refuses_short_passwords_and_taken_phones(settings, engine):
    assert (
        cli(
            ["create-admin", "--name", "x", "--phone", "0999", "--password", "short"],
            settings.database_url,
        )
        == 1
    )
    make_admin(settings)
    assert (
        cli(
            ["create-admin", "--name", "x", "--phone", PHONE, "--password", "long-enough-1"],
            settings.database_url,
        )
        == 1
    )


def test_wrong_passwords_are_refused_then_blocked(client, settings):
    make_admin(settings)
    for _ in range(10):
        r = client.post("/admin/login", json={"phone": PHONE, "password": "nope"})
        assert r.status_code == 401
    r = client.post("/admin/login", json={"phone": PHONE, "password": PASSWORD})
    assert r.status_code == 429


def test_patients_and_pharmacists_cannot_sign_in_as_admin(client):
    register(client, phone="0933000000")
    r = client.post("/admin/login", json={"phone": "0933000000", "password": "secret-1"})
    assert r.status_code == 401


ADMIN_GETS = [
    "/admin/me",
    "/admin/overview",
    "/admin/pharmacies",
    "/admin/performance",
]


def test_no_other_token_reaches_any_admin_endpoint(client, engine):
    patient = bearer(register(client))
    device = auth(setup_pharmacy(client)["access_token"])
    _, key = listed_pharmacy(engine)
    for headers in (patient, device, pharmacy_auth(key), {}):
        for path in ADMIN_GETS:
            r = client.get(path, headers=headers)
            assert r.status_code in (401, 403), (path, headers, r.status_code)
        r = client.post("/admin/pharmacies/x/actions", json={"action": "suspend"}, headers=headers)
        assert r.status_code in (401, 403)


def test_an_admin_token_reaches_no_patient_or_pharmacy_endpoint(client, admin):
    assert client.get("/patients/me", headers=admin).status_code == 403
    assert client.get("/consultations", headers=admin).status_code == 403
    assert client.get("/sync/pull", headers=admin).status_code in (401, 403)
    assert client.get("/pharmacy-api/cases", headers=admin).status_code == 401


def test_a_disabled_admin_is_signed_out_at_once(client, settings, engine):
    s = admin_login(client, settings)
    with Session(engine) as db:
        user = db.query(User).filter_by(phone=PHONE).one()
        user.active = False
        db.commit()
    assert client.get("/admin/me", headers=bearer(s)).status_code == 401


# ─── Pharmacies and actions ─────────────────────────────────────────────────


def new_pharmacy(client, admin, code="HLB1", **extra) -> dict:
    body = {"name": "صيدلية النور", "city": "حلب", "code": code, **extra}
    r = client.post("/admin/pharmacies", json=body, headers=admin)
    assert r.status_code == 200, r.text
    return r.json()


def act(client, admin, pid, action, **extra):
    return client.post(
        f"/admin/pharmacies/{pid}/actions", json={"action": action, **extra}, headers=admin
    )


def test_adding_a_pharmacy_lists_it_and_gives_its_server_a_working_key(client, admin):
    ph = new_pharmacy(client, admin, code="hlb1", phone="٠٢١ ٢٢٢ ٣٣٣")
    assert (ph["code"], ph["city"], ph["status"], ph["listed"]) == ("HLB1", "حلب", "active", True)
    assert ph["phone"] == "021222333"
    assert ph["licence_days"] == 30
    assert client.get("/pharmacy-api/updates", headers=pharmacy_auth(ph["key"])).status_code == 200
    assert [p["id"] for p in client.get("/directory?city=حلب").json()] == [ph["id"]]
    # The key is shown once.
    assert "key" not in client.get(f"/admin/pharmacies/{ph['id']}", headers=admin).json()
    r = client.post(
        "/admin/pharmacies", json={"name": "x y", "city": "حمص", "code": "HLB1"}, headers=admin
    )
    assert r.status_code == 409
    r = client.post(
        "/admin/pharmacies", json={"name": "x y", "city": "حمص", "code": "ab-1"}, headers=admin
    )
    assert r.status_code == 400


def test_suspending_needs_a_reason_and_stops_doaya_online_for_it(client, admin):
    ph = new_pharmacy(client, admin)
    key = pharmacy_auth(ph["key"])
    assert act(client, admin, ph["id"], "suspend").status_code == 400
    assert act(client, admin, ph["id"], "suspend", reason="  ").status_code == 400
    r = act(client, admin, ph["id"], "suspend", reason="ما عم يرد عالمرضى")
    assert r.status_code == 200
    assert (r.json()["status"], r.json()["status_reason"]) == ("suspended", "ما عم يرد عالمرضى")
    assert client.get("/pharmacy-api/updates", headers=key).status_code == 403
    assert client.get("/directory?city=حلب").json() == []
    assert act(client, admin, ph["id"], "suspend", reason="again").status_code == 409
    assert act(client, admin, ph["id"], "resume").json()["status"] == "active"
    assert client.get("/pharmacy-api/updates", headers=key).status_code == 200


def test_stop_and_remove(client, admin):
    ph = new_pharmacy(client, admin)
    key = pharmacy_auth(ph["key"])
    assert act(client, admin, ph["id"], "stop", reason="انتهى العقد").json()["status"] == "stopped"
    assert act(client, admin, ph["id"], "resume").json()["status"] == "active"
    r = act(client, admin, ph["id"], "remove", reason="شلنا البرنامج من عندهم")
    out = r.json()
    assert (out["status"], out["listed"], out["active_keys"]) == ("removed", False, 0)
    assert client.get("/pharmacy-api/updates", headers=key).status_code == 401
    # Removed is final.
    for action in ("resume", "approve", "stop", "list", "new_key", "health_check"):
        assert act(client, admin, ph["id"], action, reason="xxx").status_code == 409, action


def test_approve_only_a_waiting_pharmacy(client, admin, engine):
    ph = new_pharmacy(client, admin)
    assert act(client, admin, ph["id"], "approve").status_code == 409
    with Session(engine) as db:
        db.get(Pharmacy, ph["id"]).status = "pending"
        db.commit()
    assert act(client, admin, ph["id"], "approve").json()["status"] == "active"


def test_a_new_key_replaces_the_old_one(client, admin):
    ph = new_pharmacy(client, admin)
    assert act(client, admin, ph["id"], "new_key").status_code == 400  # reason
    r = act(client, admin, ph["id"], "new_key", reason="الكمبيوتر انسرق")
    new = r.json()["key"]
    assert new != ph["key"]
    assert client.get("/pharmacy-api/updates", headers=pharmacy_auth(ph["key"])).status_code == 401
    assert client.get("/pharmacy-api/updates", headers=pharmacy_auth(new)).status_code == 200


def test_hide_and_list_licence_days_and_health_check_request(client, admin):
    ph = new_pharmacy(client, admin)
    assert act(client, admin, ph["id"], "unlist").json()["listed"] is False
    assert client.get("/directory?city=حلب").json() == []
    assert act(client, admin, ph["id"], "list").json()["listed"] is True
    assert act(client, admin, ph["id"], "licence").status_code == 400
    assert act(client, admin, ph["id"], "licence", licence_days=0).status_code == 422
    assert act(client, admin, ph["id"], "licence", licence_days=45).json()["licence_days"] == 45
    assert act(client, admin, ph["id"], "health_check").json()["health_requested"] is True


def test_every_action_is_logged_with_who_and_why(client, admin):
    ph = new_pharmacy(client, admin)
    act(client, admin, ph["id"], "suspend", reason="تأخير بالرد")
    act(client, admin, ph["id"], "resume")
    act(client, admin, ph["id"], "licence", licence_days=10)
    log = client.get(f"/admin/pharmacies/{ph['id']}", headers=admin).json()["actions"]
    assert [a["action"] for a in log] == ["licence", "resume", "suspend", "create"]
    assert log[2]["reason"] == "تأخير بالرد"
    assert log[2]["detail"] == {"from": "active", "to": "suspended"}
    assert log[0]["detail"] == {"from": 30, "to": 10}
    assert {a["by"] for a in log} == {"فايز"}


def test_pharmacy_list_filters_and_searches(client, admin):
    a = new_pharmacy(client, admin, code="HLB1")
    new_pharmacy(client, admin, code="DMS1", name="صيدلية الشام", city="دمشق")
    act(client, admin, a["id"], "suspend", reason="xyz")
    assert [p["code"] for p in client.get("/admin/pharmacies", headers=admin).json()] == [
        "HLB1",
        "DMS1",
    ]
    only = client.get("/admin/pharmacies?status=suspended", headers=admin).json()
    assert [p["code"] for p in only] == ["HLB1"]
    assert [p["code"] for p in client.get("/admin/pharmacies?q=دمشق", headers=admin).json()] == [
        "DMS1"
    ]
    assert client.get("/admin/pharmacies/nope", headers=admin).status_code == 404


# ─── Response times, overview, performance ─────────────────────────────────


def _patient(db, pharmacy_id: str | None = None) -> str:
    uid = new_id()
    db.add(
        User(
            id=uid,
            role="patient",
            name="م",
            phone=new_id()[:20],
            password_hash=hash_password("x" * 6),
        )
    )
    db.flush()
    db.add(PatientProfile(user_id=uid, pharmacy_id=pharmacy_id))
    return uid


def _case(db, pid, patient, sent: datetime, minutes: float | None, urgent=False) -> None:
    db.add(
        Consultation(
            id=new_id(),
            patient_id=patient,
            pharmacy_id=pid,
            status="preparing" if minutes is not None else "sent",
            urgent=urgent,
            created_at=sent,
            sent_at=sent,
            first_action_at=sent + timedelta(minutes=minutes) if minutes is not None else None,
        )
    )


def test_the_first_pharmacist_action_is_the_response_time(client, engine):
    from .test_consultations import _patient_with_pharmacy

    _, key, me = _patient_with_pharmacy(client, engine)
    cid = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid}/messages", json={"text": "راسي عم يوجعني"}, headers=me)
    client.post(f"/consultations/{cid}/send", headers=me)
    with Session(engine) as db:
        assert db.get(Consultation, cid).first_action_at is None
    client.post(f"/pharmacy-api/cases/{cid}/preparing", headers=pharmacy_auth(key))
    with Session(engine) as db:
        first = db.get(Consultation, cid).first_action_at
    assert first is not None
    client.post(
        f"/pharmacy-api/cases/{cid}/messages",
        json={"text": "من إيمتى؟"},
        headers=pharmacy_auth(key),
    )
    with Session(engine) as db:
        assert db.get(Consultation, cid).first_action_at == first


def test_overview_counts_and_response_times(client, admin, engine):
    a = new_pharmacy(client, admin, code="HLB1")
    b = new_pharmacy(client, admin, code="DMS1", city="دمشق")
    act(client, admin, b["id"], "suspend", reason="xyz")
    now = datetime.now(UTC)
    with Session(engine) as db:
        p1, p2 = _patient(db, a["id"]), _patient(db, a["id"])
        _patient(db)
        for m in (2, 4, 6, 8):
            _case(db, a["id"], p1, now - timedelta(days=2), m)
        _case(db, a["id"], p2, now - timedelta(minutes=30), 1, urgent=True)
        _case(db, a["id"], p2, now - timedelta(minutes=20), None, urgent=True)
        _case(db, a["id"], p2, now - timedelta(days=60), 100)  # outside 30 days
        db.add(
            PatientOrder(
                id=new_id(),
                patient_id=p1,
                pharmacy_id=a["id"],
                status="sent",
                lines=[],
                currency="SYP",
            )
        )
        db.add(AiLog(consultation_id=db.query(Consultation).first().id, kind="red_flag", detail={}))
        db.add(AiLog(consultation_id=db.query(Consultation).first().id, kind="summary", detail={}))
        db.commit()
    o = client.get("/admin/overview", headers=admin).json()
    assert o["pharmacies"]["by_status"]["active"] == 1
    assert o["pharmacies"]["by_status"]["suspended"] == 1
    assert o["pharmacies"]["new"] == 2
    assert o["patients"] == {"registered": 3, "active": 2, "new": 3}
    assert o["today"]["urgent"] == 2
    assert o["today"]["urgent_unanswered"] == 1
    assert o["today"]["orders"] == 1
    r = o["response"]
    assert (r["answered"], r["unanswered"]) == (5, 1)
    assert r["median_minutes"] == 4.0
    assert sum(d["count"] for d in r["by_day"]) == 5
    assert o["review_waiting"] == 1  # a summary log isn't for review
    listed = {p["code"]: p for p in client.get("/admin/pharmacies", headers=admin).json()}
    assert (listed["HLB1"]["patients"], listed["HLB1"]["median_minutes"]) == (2, 4.0)


def test_rewards_tier_rules():
    n = MIN_CASES_TO_RANK
    assert tier(n - 1, 1.0, 1.0) is None
    assert tier(n, 0.96, 0.92) == "gold"
    assert tier(n, 0.94, 0.92) == "silver"
    assert tier(n, 0.92, 0.80) == "silver"
    assert tier(n, 0.92, 0.70) is None


def test_performance_ranks_pharmacies_for_the_month(client, admin, engine):
    fast = new_pharmacy(client, admin, code="FAST", name="صيدلية سريعة")
    slow = new_pharmacy(client, admin, code="SLOW", name="صيدلية بطيئة")
    few = new_pharmacy(client, admin, code="FEW1", name="صيدلية قليلة")
    month_start = datetime(2026, 8, 1, tzinfo=UTC)
    with Session(engine) as db:
        pat = _patient(db)
        for i in range(12):
            _case(db, fast["id"], pat, month_start + timedelta(days=i), 3, urgent=i == 0)
            _case(db, slow["id"], pat, month_start + timedelta(days=i), 25 if i % 2 else 5)
        _case(db, slow["id"], pat, month_start + timedelta(days=3), None)
        _case(db, few["id"], pat, month_start + timedelta(days=3), 1)
        # Next month: not counted.
        _case(db, slow["id"], pat, datetime(2026, 9, 2, tzinfo=UTC), 1)
        db.commit()
    r = client.get("/admin/performance?month=2026-08", headers=admin).json()
    assert r["month"] == "2026-08"
    rows = {p["name"]: p for p in r["pharmacies"]}
    f, s, w = rows["صيدلية سريعة"], rows["صيدلية بطيئة"], rows["صيدلية قليلة"]
    assert (f["rank"], s["rank"], w["rank"]) == (1, 2, None)
    assert (f["cases"], f["answered"], f["tier"]) == (12, 12, "gold")
    assert (f["urgent"], f["urgent_in_time"]) == (1, 1)
    assert (s["cases"], s["unanswered"], s["tier"]) == (13, 1, None)
    assert s["within_target_share"] == pytest.approx(6 / 13)
    assert (s["median_minutes"], s["p90_minutes"]) == (15.0, 25.0)
    assert w["tier"] is None
    assert [p["name"] for p in r["pharmacies"]][-1] == "صيدلية قليلة"
    assert client.get("/admin/performance?month=2026-13", headers=admin).status_code == 400
    assert client.get("/admin/performance?month=aug", headers=admin).status_code == 400
