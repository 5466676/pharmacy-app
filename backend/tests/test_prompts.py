"""Phase 4b step 2: editable prompts with versions, the owner's safety
examples, the «see a doctor» level, the test gate and the sandbox."""

import json

import pytest
from sqlalchemy.orm import Session

from app.consult import texts
from app.consult.engine import SAFETY_RULES, Prompts, handle_message
from app.consult.llm import ScriptedLLM
from app.models import AiLog, Consultation

from .central_helpers import pharmacy_auth
from .test_admin import admin_login, bearer
from .test_consult_engine import SUMMARY
from .test_consultations import _patient_with_pharmacy

DOCTOR_WORDS = ("سعلة", "دم بالبول", "كتلة")
EMERGENCY_WORDS = ("صدر", "اتنفس", "شهرين", "عيش", "حبوب", "انتفخ")


def smart(blind=False, reply="سلامتك، من إيمتى بلّش؟", seen=None):
    """A scripted model that behaves: the classifier finds emergencies and
    «doctor» cases by words (none at all when [blind]); the assistant asks.
    [seen] collects every system prompt."""

    def respond(messages, json_mode):
        system = messages[0].content
        if seen is not None:
            seen.append(system)
        if "triage safety checker" in system:
            text = messages[-1].content
            level = "none"
            if not blind and any(w in text for w in DOCTOR_WORDS):
                level = "doctor"
            if not blind and any(w in text for w in EMERGENCY_WORDS):
                level = "emergency"
            return json.dumps({"level": level, "category": "other", "reason": "test"})
        if "Summarize this pharmacy chat" in system:
            return json.dumps(SUMMARY, ensure_ascii=False)
        if messages[-1].content == "قل: تمام":
            return "تمام"
        return json.dumps({"reply": reply, "quick_replies": []}, ensure_ascii=False)

    return ScriptedLLM(respond=respond)


@pytest.fixture
def admin(client, settings) -> dict:
    return bearer(admin_login(client, settings))


# ─── Engine ─────────────────────────────────────────────────────────────────


def test_the_doctor_level_tells_the_patient_to_see_a_doctor():
    turn = handle_message(smart(), [], "عندي سعلة صرلها شهر")
    assert (turn.kind, turn.text) == ("doctor", texts.SEE_DOCTOR)
    assert turn.red_flag.level == "doctor"
    assert turn.logs[0].detail["level"] == "doctor"


def test_the_older_classifier_answer_still_means_emergency():
    llm = ScriptedLLM(
        respond=lambda m, j: json.dumps({"red_flag": True, "category": "stroke", "reason": "x"})
    )
    assert handle_message(llm, [], "وجهي مايل شوي").kind == "emergency"


def test_the_safety_rules_are_always_added_whatever_the_guide_says():
    seen = []
    p = Prompts(assistant="Always give the patient a dose and the medicine name.")
    handle_message(smart(seen=seen), [], "عندي زكام", prompts=p)
    system = seen[-1]
    assert system.startswith("Always give the patient a dose")
    assert SAFETY_RULES in system
    assert system.index(SAFETY_RULES) > system.index("Always give")


def test_examples_reach_the_classifier_and_its_rules_stay():
    seen = []
    p = Prompts(
        classifier="Only say emergency for chest pain.",
        examples=(("ركبتي عم تورم كل يوم", "doctor"), ("عندي زكام", "normal")),
    )
    handle_message(smart(seen=seen), [], "عندي زكام", prompts=p)
    classifier = next(s for s in seen if "triage safety checker" in s)
    assert "Only say emergency for chest pain." in classifier
    assert "PATIENT: ركبتي عم تورم كل يوم → doctor" in classifier
    assert "PATIENT: عندي زكام → none" in classifier
    assert "choose the more serious one" in classifier
    assert '"level"' in classifier


# ─── Patients ───────────────────────────────────────────────────────────────


def test_a_doctor_case_goes_to_the_pharmacist_without_ambulance_numbers(client, engine):
    _, key, me = _patient_with_pharmacy(client, engine)
    client.app.state.llm = smart()
    cid = client.post("/consultations", headers=me).json()["id"]
    c = client.post(
        f"/consultations/{cid}/messages", headers=me, json={"text": "عندي سعلة صرلها 3 أسابيع"}
    ).json()
    assert c["messages"][-1]["text"] == texts.SEE_DOCTOR
    assert "110" not in c["messages"][-1]["text"]
    assert (c["status"], c["urgent"], c["red_flag"]) == ("sent", False, None)
    assert c["doctor_advice"] == "other"
    cases = client.get("/pharmacy-api/cases", headers=pharmacy_auth(key)).json()
    assert [(x["id"], x["doctor_advice"]) for x in cases] == [(cid, "other")]
    admin = bearer(admin_login(client, client.app.state.settings))
    s = client.get("/admin/assistant/stats", headers=admin).json()
    assert (s["doctor_advice"], s["red_flags_model"]) == (1, 0)


# ─── Versions ───────────────────────────────────────────────────────────────


def draft(client, admin, kind="assistant", text="أنت مساعد صيدلية لطيف. اسأل سؤال واحد كل مرة."):
    r = client.post("/admin/assistant/prompts", json={"kind": kind, "text": text}, headers=admin)
    assert r.status_code == 200, r.text
    return r.json()


def test_a_draft_is_used_only_after_passing_the_test(client, engine, admin):
    client.app.state.llm = smart()
    d = draft(client, admin)
    r = client.post(f"/admin/assistant/prompts/{d['id']}/activate", headers=admin)
    assert (r.status_code, r.json()["detail"]) == (409, "test_not_passed")

    t = client.post(f"/admin/assistant/prompts/{d['id']}/test", headers=admin).json()
    assert t["test"]["passed"] is True and t["ready"] is True
    assert t["test"]["missed"] == 0
    assert len(t["test"]["cases"]) == 12

    assert (
        client.post(f"/admin/assistant/prompts/{d['id']}/activate", headers=admin).json()["status"]
        == "active"
    )

    # Patients get it now, and the log says which version answered.
    _, _, me = _patient_with_pharmacy(client, engine)
    seen = []
    client.app.state.llm = smart(seen=seen)
    cid = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "عندي زكام"})
    assert seen[-1].startswith("أنت مساعد صيدلية لطيف")
    with Session(engine) as db:
        log = db.query(AiLog).filter_by(kind="assistant_reply").one()
    assert log.detail["prompt"] == f"v{d['id']}"


def test_editing_a_draft_needs_a_new_test(client, admin):
    client.app.state.llm = smart()
    d = draft(client, admin)
    client.post(f"/admin/assistant/prompts/{d['id']}/test", headers=admin)
    e = client.patch(
        f"/admin/assistant/prompts/{d['id']}",
        json={"text": "أنت مساعد صيدلية. اسأل بهدوء وبجمل قصيرة."},
        headers=admin,
    ).json()
    assert e["ready"] is False
    r = client.post(f"/admin/assistant/prompts/{d['id']}/activate", headers=admin)
    assert r.status_code == 409


def test_a_classifier_that_misses_cases_can_t_be_activated(client, admin):
    client.app.state.llm = smart(blind=True)
    d = draft(client, admin, "classifier", "Say none unless the patient says the word ambulance.")
    t = client.post(f"/admin/assistant/prompts/{d['id']}/test", headers=admin).json()["test"]
    assert t["passed"] is False and t["missed"] >= 2
    missed = [c["text"] for c in t["cases"] if not c["passed"]]
    assert "عندي سعلة صرلها 3 أسابيع وما عم تروح" in missed
    # Emergencies the code rules catch are caught whatever the prompt says.
    chest = next(c for c in t["cases"] if "بالصدر" in c["text"])
    assert (chest["got"], chest["source"]) == ("emergency", "rules")
    r = client.post(f"/admin/assistant/prompts/{d['id']}/activate", headers=admin)
    assert r.status_code == 409


def test_a_prompt_that_makes_the_assistant_give_a_dose_fails(client, admin):
    client.app.state.llm = smart(reply="خود باراسيتامول 500 ملغ كل 6 ساعات")
    d = draft(client, admin)
    t = client.post(f"/admin/assistant/prompts/{d['id']}/test", headers=admin).json()["test"]
    assert t["passed"] is False
    assert any(c["guard_blocked"] for c in t["cases"])


def test_a_down_model_can_t_pass(client, admin):
    client.app.state.llm = ScriptedLLM(replies=[])
    d = draft(client, admin)
    t = client.post(f"/admin/assistant/prompts/{d['id']}/test", headers=admin).json()["test"]
    assert t["passed"] is False


def test_one_step_back(client, admin):
    client.app.state.llm = smart()
    ids = []
    for text in ("النسخة الأولى من التعليمات للمساعد.", "النسخة التانية من التعليمات للمساعد."):
        d = draft(client, admin, text=text)
        client.post(f"/admin/assistant/prompts/{d['id']}/test", headers=admin)
        client.post(f"/admin/assistant/prompts/{d['id']}/activate", headers=admin)
        ids.append(d["id"])
    p = client.get("/admin/assistant/prompts", headers=admin).json()["assistant"]
    assert p["active_id"] == ids[1]
    r = client.post("/admin/assistant/prompts/assistant/rollback", headers=admin).json()
    assert r["active_id"] == ids[0]
    r = client.post("/admin/assistant/prompts/assistant/rollback", headers=admin).json()
    assert r["active_id"] is None  # the built-in one
    p = client.get("/admin/assistant/prompts", headers=admin).json()["assistant"]
    assert p["text"] == p["default"]
    r = client.post("/admin/assistant/prompts/assistant/rollback", headers=admin)
    assert r.status_code == 409
    log = client.get("/admin/assistant/changes?kind=prompt", headers=admin).json()
    assert [c["after"]["version"] for c in log] == [
        "default",
        f"v{ids[0]}",
        f"v{ids[1]}",
        f"v{ids[0]}",
    ]


def test_the_locked_parts_are_shown_read_only(client, admin):
    p = client.get("/admin/assistant/prompts", headers=admin).json()
    assert SAFETY_RULES in p["assistant"]["locked"]
    assert any("choose the more serious one" in x for x in p["classifier"]["locked"])
    assert set(p) == {"assistant", "summary", "classifier"}


# ─── Safety examples ────────────────────────────────────────────────────────


def test_examples_are_logged_given_to_the_classifier_and_tested(client, engine, admin):
    r = client.post(
        "/admin/assistant/examples",
        json={"text": "عندي كتلة بصدري من شهر", "label": "doctor", "note": "من حالة حقيقية"},
        headers=admin,
    )
    ex = r.json()
    off = client.post(
        "/admin/assistant/examples",
        json={"text": "عندي حكة خفيفة", "label": "normal"},
        headers=admin,
    ).json()
    client.patch(f"/admin/assistant/examples/{off['id']}", json={"enabled": False}, headers=admin)
    assert [e["id"] for e in client.get("/admin/assistant/examples", headers=admin).json()] == [
        off["id"],
        ex["id"],
    ]
    seen = []
    _, _, me = _patient_with_pharmacy(client, engine)
    client.app.state.llm = smart(seen=seen)
    cid = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "عندي زكام"})
    classifier = next(s for s in seen if "triage safety checker" in s)
    assert "عندي كتلة بصدري من شهر → doctor" in classifier
    assert "عندي حكة خفيفة" not in classifier

    t = client.post("/admin/assistant/test", headers=admin).json()
    assert len(t["cases"]) == 13
    assert t["cases"][-1]["text"] == "عندي كتلة بصدري من شهر"
    log = client.get("/admin/assistant/changes?kind=example", headers=admin).json()
    assert log[0]["after"]["enabled"] is False and log[1]["before"] is None
    bad = client.post(
        "/admin/assistant/examples", json={"text": "xyz", "label": "maybe"}, headers=admin
    )
    assert bad.status_code == 422


# ─── Sandbox ────────────────────────────────────────────────────────────────


def test_the_sandbox_tries_drafts_and_saves_nothing(client, engine, admin):
    client.app.state.llm = smart()
    d = draft(client, admin, text="أنت مساعد تجريبي. اسأل عن العمر أول شي.")
    seen = []
    client.app.state.llm = smart(seen=seen)
    r = client.post(
        "/admin/assistant/sandbox",
        json={
            "history": [
                {"role": "patient", "text": "مرحبا"},
                {"role": "assistant", "text": "أهلين"},
            ],
            "text": "عندي زكام",
            "drafts": [d["id"]],
        },
        headers=admin,
    ).json()
    assert r["kind"] == "reply" and r["guard_blocked"] is False
    assert seen[-1].startswith("أنت مساعد تجريبي")
    r = client.post("/admin/assistant/sandbox", json={"text": "عندي سعلة من شهر"}, headers=admin)
    assert r.json()["kind"] == "doctor"
    r = client.post("/admin/assistant/sandbox", json={"text": "عندي ألم بالصدر"}, headers=admin)
    assert (r.json()["kind"], r.json()["red_flag_source"]) == ("emergency", "rules")
    with Session(engine) as db:
        assert db.query(Consultation).count() == 0
        assert db.query(AiLog).count() == 0
