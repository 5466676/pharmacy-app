"""Phase 4 step 2: the review queue (anonymised) and the knowledge base the
assistant reads."""

import json

import pytest
from sqlalchemy.orm import Session

from app.models import AiLog

from .central_helpers import pharmacy_auth
from .test_accounts import auth, setup_pharmacy
from .test_admin import admin_login, bearer
from .test_consultations import _patient_with_pharmacy

ASK = {"reply": "سلامتك. من إيمتى الحرارة؟", "quick_replies": []}


@pytest.fixture
def admin(client, settings) -> dict:
    return bearer(admin_login(client, settings))


def chat(client, me, *texts) -> str:
    cid = client.post("/consultations", headers=me).json()["id"]
    for t in texts:
        r = client.post(f"/consultations/{cid}/messages", headers=me, json={"text": t})
        assert r.status_code == 200, r.text
    return cid


def note(client, admin, **body) -> dict:
    body = {"title": "أطفال صغار", "text": "اسأل عن العمر بالأشهر.", "tags": ["طفل"], **body}
    r = client.post("/admin/knowledge", json=body, headers=admin)
    assert r.status_code == 200, r.text
    return r.json()


def last_system(client) -> str:
    return client.app.state.llm.calls[-1][0][0].content


# ─── Who may call ───────────────────────────────────────────────────────────


def test_only_admins_reach_review_and_knowledge(client, engine):
    device = auth(setup_pharmacy(client)["access_token"])
    _, key, me = _patient_with_pharmacy(client, engine, assistant=ASK)
    for headers in (me, device, pharmacy_auth(key), {}):
        for path in ("/admin/review", "/admin/knowledge", "/admin/knowledge/match?text=x"):
            assert client.get(path, headers=headers).status_code in (401, 403), path
        r = client.post("/admin/knowledge", json={}, headers=headers)
        assert r.status_code in (401, 403)


# ─── Review queue ───────────────────────────────────────────────────────────


def test_the_queue_shows_what_needs_review_without_the_patient_s_name(client, engine, admin):
    _, key, me = _patient_with_pharmacy(client, engine, assistant={**ASK, "ready": False})
    cid = chat(client, me, "ابني عندو حرارة")  # an ordinary reply: not for review
    red = chat(client, me, "عندي ألم بالصدر وضيق نفس")
    client.post(f"/consultations/{cid}/send", headers=me)
    client.post(
        f"/pharmacy-api/cases/{cid}/corrections",
        json={"target": "summary", "field": "notes", "correction": "اسأل عن العمر"},
        headers=pharmacy_auth(key),
    )
    items = client.get("/admin/review", headers=admin).json()
    assert [i["kind"] for i in items] == ["correction", "red_flag"]
    flag = items[1]
    assert (flag["consultation_id"], flag["age"], flag["sex"]) == (red, 34, "m")
    assert flag["pharmacy"] == "صيدلية الشفاء"
    text = json.dumps(items, ensure_ascii=False)
    assert "سامر" not in text and "0933111222" not in text

    detail = client.get(f"/admin/review/{flag['id']}", headers=admin).json()
    assert detail["messages"][1]["text"] == "عندي ألم بالصدر وضيق نفس"
    assert "سامر" not in json.dumps(detail, ensure_ascii=False)

    only = client.get("/admin/review?kind=correction", headers=admin).json()
    assert [i["kind"] for i in only] == ["correction"]


def test_marking_reviewed_moves_it_out_of_the_queue(client, engine, admin):
    _, _, me = _patient_with_pharmacy(client, engine, assistant=ASK)
    chat(client, me, "عندي ألم بالصدر")
    item = client.get("/admin/review", headers=admin).json()[0]
    r = client.post(f"/admin/review/{item['id']}", json={"note": "الإحالة صح"}, headers=admin)
    assert (r.json()["reviewed"], r.json()["review_note"]) == (True, "الإحالة صح")
    assert client.get("/admin/review", headers=admin).json() == []
    done = client.get("/admin/review?reviewed=true", headers=admin).json()
    assert [i["id"] for i in done] == [item["id"]]
    assert client.get("/admin/overview", headers=admin).json()["review_waiting"] == 0
    assert client.post("/admin/review/999999", json={}, headers=admin).status_code == 404


def test_ordinary_assistant_replies_are_not_review_items(client, engine, admin):
    _, _, me = _patient_with_pharmacy(client, engine, assistant=ASK)
    chat(client, me, "عندي زكام")
    with Session(engine) as db:
        reply = db.query(AiLog).filter_by(kind="assistant_reply").first()
    assert client.get(f"/admin/review/{reply.id}", headers=admin).status_code == 404


# ─── Knowledge base ─────────────────────────────────────────────────────────


def test_a_note_reaches_the_assistant_only_when_its_tag_is_mentioned(client, engine, admin):
    _, _, me = _patient_with_pharmacy(client, engine, assistant=ASK)
    n = note(client, admin, tags=["طفل", "رضيع"])
    note(client, admin, title="حمل", text="اسألي عن أسبوع الحمل.", tags=["حامل"])

    chat(client, me, "عندي زكام من يومين")
    assert "اسأل عن العمر بالأشهر" not in last_system(client)

    # Inside a word too, and spelling folded («الطفل» / «طفلي»).
    chat(client, me, "طفلي عندو حرارة")
    system = last_system(client)
    assert "اسأل عن العمر بالأشهر" in system
    assert "أسبوع الحمل" not in system
    with Session(engine) as db:
        log = db.query(AiLog).filter_by(kind="assistant_reply").order_by(AiLog.id.desc()).first()
    assert log.detail["notes"] == [n["id"]]

    # Earlier patient messages count too.
    cid = chat(client, me, "بنتي الرضيعة")
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "من امبارح"})
    assert "اسأل عن العمر بالأشهر" in last_system(client)


def test_a_disabled_note_never_reaches_the_assistant(client, engine, admin):
    _, _, me = _patient_with_pharmacy(client, engine, assistant=ASK)
    n = note(client, admin)
    r = client.patch(f"/admin/knowledge/{n['id']}", json={"enabled": False}, headers=admin)
    assert r.json()["enabled"] is False
    chat(client, me, "طفلي عندو حرارة")
    assert "اسأل عن العمر بالأشهر" not in last_system(client)
    assert client.get("/admin/knowledge/match?text=طفلي", headers=admin).json() == []


def test_at_most_three_notes_most_tags_first(client, engine, admin):
    for i in range(4):
        note(client, admin, title=f"n{i}", text=f"ملاحظة رقم {i}.", tags=["حرارة"])
    best = note(client, admin, title="best", text="الأهم.", tags=["حرارة", "طفل"])
    got = client.get("/admin/knowledge/match?text=طفلي عندو حرارة", headers=admin).json()
    assert len(got) == 3
    assert got[0]["id"] == best["id"]


def test_a_note_that_states_a_dose_is_refused(client, admin):
    r = client.post(
        "/admin/knowledge",
        json={"title": "حرارة", "text": "باراسيتامول 500 ملغ كل 6 ساعات", "tags": ["حرارة"]},
        headers=admin,
    )
    assert (r.status_code, r.json()["detail"]) == (400, "note_has_dose")
    n = note(client, admin)
    r = client.patch(
        f"/admin/knowledge/{n['id']}", json={"text": "اعطيه 5 مل كل 8 ساعات"}, headers=admin
    )
    assert r.status_code == 400
    # Unchanged.
    assert client.get("/admin/knowledge", headers=admin).json()[0]["text"] == n["text"]


def test_tags_are_cleaned_and_every_change_is_logged(client, engine, admin):
    r = client.post(
        "/admin/knowledge",
        json={"title": "x y", "text": "نص الملاحظة.", "tags": [" طفل ", "طفل", "ا"]},
        headers=admin,
    )
    assert r.json()["tags"] == ["طفل"]
    bad = {"title": "x y", "text": "نص الملاحظة.", "tags": ["ا"]}
    assert client.post("/admin/knowledge", json=bad, headers=admin).status_code == 422
    nid = r.json()["id"]
    client.patch(f"/admin/knowledge/{nid}", json={"text": "نص أوضح للملاحظة."}, headers=admin)
    client.patch(f"/admin/knowledge/{nid}", json={"text": "نص أوضح للملاحظة."}, headers=admin)
    changes = client.get(f"/admin/knowledge/{nid}/changes", headers=admin).json()
    assert [c["action"] for c in changes] == ["create", "update"]  # no-op not logged
    assert changes[1]["before"]["text"] == "نص الملاحظة."
    assert changes[1]["after"]["text"] == "نص أوضح للملاحظة."


def test_a_note_can_come_from_a_review_item(client, engine, admin):
    _, _, me = _patient_with_pharmacy(client, engine, assistant=ASK)
    chat(client, me, "عندي ألم بالصدر")
    item = client.get("/admin/review", headers=admin).json()[0]
    n = note(client, admin, source_log_id=item["id"])
    assert n["source_log_id"] == item["id"]
    r = client.post(
        "/admin/knowledge",
        json={"title": "x y", "text": "نص الملاحظة.", "tags": ["طفل"], "source_log_id": 999999},
        headers=admin,
    )
    assert r.status_code == 404


# ─── Settings ───────────────────────────────────────────────────────────────


def test_settings_show_the_model_and_whether_it_answers(client, engine, admin):
    from app.consult.llm import ScriptedLLM

    s = client.get("/admin/settings", headers=admin).json()
    assert (s["emergency_ambulance"], s["emergency_general"]) == ("110", "112")
    assert s["llm_model"]
    client.app.state.llm = ScriptedLLM(replies=["تمام"])
    r = client.post("/admin/settings/model-check", headers=admin).json()
    assert r["ok"] is True and r["ms"] >= 0
    client.app.state.llm = ScriptedLLM(replies=[])
    r = client.post("/admin/settings/model-check", headers=admin).json()
    assert r["ok"] is False and r["error"]
