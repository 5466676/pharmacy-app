from sqlalchemy import select
from sqlalchemy.orm import Session

from app.consult import texts
from app.models import AiLog

from .central_helpers import bearer, listed_pharmacy, pharmacy_auth, register
from .test_consult_engine import model


def _patient_with_pharmacy(client, engine, **llm):
    pid, key = listed_pharmacy(engine)
    s = register(client, birth_year=1992, sex="m")
    client.patch("/patients/me", headers=bearer(s), json={"pharmacy_id": pid})
    client.app.state.llm = model(**llm)
    return pid, key, bearer(s)


def _logs(engine, kind=None) -> list[AiLog]:
    with Session(engine) as db:
        stmt = select(AiLog).order_by(AiLog.id)
        if kind:
            stmt = stmt.where(AiLog.kind == kind)
        return list(db.scalars(stmt))


def test_needs_a_chosen_pharmacy(client):
    s = register(client)
    assert client.post("/consultations", headers=bearer(s)).json()["detail"] == "no_pharmacy"


def test_from_first_message_to_pickup(client, engine):
    replies = iter(
        [
            {"reply": "سلامتك. في غثيان أو تيبّس بالرقبة؟", "quick_replies": ["لا، ولا شي"]},
            {"reply": "تمام، صار عندي كل شي.", "ready": True},
        ]
    )
    pid, key, me = _patient_with_pharmacy(client, engine, assistant=lambda m: next(replies))
    events = client.app.state.events.recent

    c = client.post("/consultations", headers=me).json()
    assert c["messages"][0]["text"] == texts.GREETING
    cid = c["id"]
    c = client.post(
        f"/consultations/{cid}/messages",
        headers=me,
        json={"text": "عندي صداع من يومين وحرارة خفيفة"},
    ).json()
    assert c["status"] == "chatting"
    assert c["messages"][-1]["quick_replies"] == ["لا، ولا شي"]
    # The assistant knew the patient's age and sex from the profile.
    system = client.app.state.llm.calls[-1][0][0].content
    assert "male" in system

    c = client.post(
        f"/consultations/{cid}/messages", headers=me, json={"text": "لا، ولا شي"}
    ).json()
    assert c["status"] == "summary" and c["summary"]["duration"] == "يومين"

    # Not visible to the pharmacy before it's sent.
    assert client.get("/pharmacy-api/cases", headers=pharmacy_auth(key)).json() == []

    fixed = {**c["summary"], "duration": "3 أيام"}
    c = client.put(f"/consultations/{cid}/summary", headers=me, json=fixed).json()
    assert c["summary"]["duration"] == "3 أيام"
    assert _logs(engine, "patient_edit")[0].detail["after"]["duration"] == "3 أيام"

    c = client.post(f"/consultations/{cid}/send", headers=me).json()
    assert c["status"] == "sent" and c["messages"][-1]["text"] == texts.SENT
    assert (
        f"pharmacy:{pid}",
        {"type": "case_new", "consultation_id": cid, "status": "sent", "urgent": False},
    ) in events

    ph = pharmacy_auth(key, actor="رنا")
    brief = client.get("/pharmacy-api/cases", headers=ph).json()[0]
    assert brief["title"] == "صداع، حرارة خفيفة"
    assert brief["patient"]["phone"] == "0933111222" and brief["patient"]["sex"] == "m"

    # «اسأل المريض سؤال», and the answer goes to the pharmacist, not the model.
    calls = len(client.app.state.llm.calls)
    case = client.post(
        f"/pharmacy-api/cases/{cid}/messages",
        headers=ph,
        json={"text": "في عندك حساسية على البنسلين؟"},
    ).json()
    assert case["status"] == "preparing" and case["messages"][-1]["author"] == "رنا"
    c = client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "لا"}).json()
    assert c["messages"][-1]["role"] == "patient"
    assert len(client.app.state.llm.calls) == calls

    decision = {
        "items": [
            {
                "name": "Panadol 500",
                "quantity": 1,
                "instructions": "حبة كل 8 ساعات بعد الأكل",
                "times_per_day": 3,
                "days": 3,
                "price_minor": 2500,
            }
        ],
        "note": "إذا ضلت الحرارة بعد 3 أيام راجع طبيب",
    }
    case = client.post(f"/pharmacy-api/cases/{cid}/decision", headers=ph, json=decision).json()
    assert case["status"] == "ready" and case["decision"]["by"] == "رنا"
    # The pharmacist may write the dose: it's their decision, not the AI's.
    assert "حبة كل 8 ساعات" in case["messages"][-1]["text"]
    assert (
        client.post(f"/pharmacy-api/cases/{cid}/picked-up", headers=ph).json()["status"]
        == "picked_up"
    )
    r = client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "شكراً"})
    assert r.json()["detail"] == "consultation_closed"
    assert [e.kind for e in _logs(engine) if e.kind != "patient_edit"] == [
        "assistant_reply",
        "assistant_reply",
        "summary",
    ]


def test_an_emergency_goes_straight_to_the_pharmacy_as_urgent(client, engine):
    pid, key, me = _patient_with_pharmacy(client, engine, assistant={"reply": "؟"})
    normal = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{normal}/messages", headers=me, json={"text": "عندي رشح"})
    client.post(f"/consultations/{normal}/send", headers=me)

    cid = client.post("/consultations", headers=me).json()["id"]
    c = client.post(
        f"/consultations/{cid}/messages", headers=me, json={"text": "بابا عنده وجع بصدره وعرقان"}
    ).json()
    assert (c["status"], c["urgent"], c["red_flag"]) == ("emergency", True, "chest_pain")
    assert "110" in c["messages"][-1]["text"]
    listed = client.get("/pharmacy-api/cases", headers=pharmacy_auth(key)).json()
    assert [x["id"] for x in listed] == [cid, normal]  # urgent first
    assert _logs(engine, "red_flag")[0].detail["source"] == "rules"
    # The assistant is done with it; the patient can still write to the pharmacy.
    c = client.post(
        f"/consultations/{cid}/messages", headers=me, json={"text": "طلبنا الإسعاف"}
    ).json()
    assert c["messages"][-1]["role"] == "patient"


def test_a_red_flag_after_sending_marks_the_case_urgent(client, engine):
    _, key, me = _patient_with_pharmacy(client, engine, assistant={"reply": "؟"})
    cid = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "عندي سعلة"})
    client.post(f"/consultations/{cid}/send", headers=me)
    c = client.post(
        f"/consultations/{cid}/messages", headers=me, json={"text": "هلق صار عندي ضيق نفس قوي"}
    ).json()
    assert (c["status"], c["urgent"], c["red_flag"]) == ("sent", True, "breathing")
    assert c["messages"][-1]["role"] == "system"


def test_model_down_the_patient_sends_the_chat_as_it_is(client, engine):
    _, key, me = _patient_with_pharmacy(client, engine, assistant=RuntimeError("off"))
    cid = client.post("/consultations", headers=me).json()["id"]
    c = client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "عندي رشح"}).json()
    assert c["messages"][-1]["text"] == texts.ASSISTANT_DOWN
    c = client.post(f"/consultations/{cid}/send", headers=me).json()
    assert c["status"] == "sent" and c["summary"] is None
    brief = client.get("/pharmacy-api/cases", headers=pharmacy_auth(key)).json()[0]
    assert brief["title"] == "عندي رشح"


def test_pharmacies_only_see_their_own_cases_and_patients_their_own(client, engine):
    _, key, me = _patient_with_pharmacy(client, engine, assistant={"reply": "؟"})
    cid = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "عندي رشح"})
    client.post(f"/consultations/{cid}/send", headers=me)
    _, other_key = listed_pharmacy(engine, name="صيدلية النور", code="NOOR")
    assert client.get("/pharmacy-api/cases", headers=pharmacy_auth(other_key)).json() == []
    r = client.get(f"/pharmacy-api/cases/{cid}", headers=pharmacy_auth(other_key))
    assert r.status_code == 404
    someone = register(client, phone="0944999888")
    assert client.get(f"/consultations/{cid}", headers=bearer(someone)).status_code == 404


def test_pharmacist_corrections_are_logged_for_review(client, engine):
    _, key, me = _patient_with_pharmacy(client, engine, assistant={"reply": "كم عمر المريض؟"})
    cid = client.post("/consultations", headers=me).json()["id"]
    c = client.post(
        f"/consultations/{cid}/messages", headers=me, json={"text": "ابني عندو اسهال"}
    ).json()
    client.post(f"/consultations/{cid}/send", headers=me)
    msg = c["messages"][-1]["id"]
    ph = pharmacy_auth(key, actor="سامر")
    r = client.post(
        f"/pharmacy-api/cases/{cid}/corrections",
        headers=ph,
        json={
            "target": "message",
            "message_id": msg,
            "correction": "كان لازم يسأل عن علامات الجفاف أول شي",
        },
    )
    assert r.json() == {"ok": True}
    log = _logs(engine, "correction")[0].detail
    assert (log["original"], log["by"]) == ("كم عمر المريض؟", "سامر")
    bad = client.post(
        f"/pharmacy-api/cases/{cid}/corrections",
        headers=ph,
        json={"target": "message", "message_id": 999999, "correction": "x"},
    )
    assert bad.status_code == 404
