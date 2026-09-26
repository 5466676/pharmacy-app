"""Phase 5: the patient's health file."""

from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy.orm import Session

from app.models import FileAccess, HealthFact

from .central_helpers import bearer, listed_pharmacy, pharmacy_auth, register
from .test_admin import admin_login
from .test_consult_engine import SUMMARY, model

FULL = {
    **SUMMARY,
    "allergies": "حساسية من البنسلين",
    "medications": "دوا ضغط كل يوم",
    "conditions": "ما في",
    "pregnancy": "حامل بالشهر الرابع",
}


def patient(client, engine, consent=True, summary=None, **llm):
    pid, key = listed_pharmacy(engine)
    s = register(client, birth_year=1990, sex="f", file_consent=consent)
    me = bearer(s)
    client.patch("/patients/me", headers=me, json={"pharmacy_id": pid})
    client.app.state.llm = model(
        assistant={"reply": "تمام.", "ready": True}, summary=summary or FULL, **llm
    )
    return s["patient"]["id"], pid, pharmacy_auth(key), me


def sent_case(client, me, text="عندي صداع من يومين") -> str:
    cid = client.post("/consultations", headers=me).json()["id"]
    c = client.post(f"/consultations/{cid}/messages", headers=me, json={"text": text}).json()
    assert c["status"] == "summary", c
    assert client.post(f"/consultations/{cid}/send", headers=me).status_code == 200
    return cid


def by_kind(items) -> dict:
    return {i["kind"]: i for i in items}


# ─── Consent ────────────────────────────────────────────────────────────────


def test_no_file_without_consent(client, engine):
    uid, _, ph, me = patient(client, engine, consent=False)
    assert client.get("/patients/me/file", headers=me).status_code == 409
    sent_case(client, me)
    assert client.get(f"/pharmacy-api/patients/{uid}/file", headers=ph).status_code == 409
    r = client.post("/patients/me/consent", headers=me, json={"consent": True})
    assert r.json()["consent_at"] is not None
    f = client.get("/patients/me/file", headers=me).json()
    assert f["proposals"] == []  # nothing from before the consent
    assert [h["summary"]["duration"] for h in f["history"]] == ["يومين"]


# ─── Proposals from chats ───────────────────────────────────────────────────


def test_a_chat_proposes_never_writes(client, engine):
    uid, _, ph, me = patient(client, engine)
    sent_case(client, me)
    f = client.get("/patients/me/file", headers=me).json()
    assert f["facts"] == []
    props = by_kind(f["proposals"])
    assert set(props) == {"allergy", "medication", "pregnancy"}  # "ما في" is nothing
    assert (props["allergy"]["needs"], props["pregnancy"]["needs"]) == ("pharmacist", "patient")
    # The same again: no duplicates.
    sent_case(client, me)
    assert len(client.get("/patients/me/file", headers=me).json()["proposals"]) == 3


def test_who_confirms_what(client, engine):
    uid, _, ph, me = patient(client, engine)
    sent_case(client, me)
    props = by_kind(client.get("/patients/me/file", headers=me).json()["proposals"])
    r = client.post(
        f"/patients/me/file/proposals/{props['allergy']['id']}", headers=me, json={"accept": True}
    )
    assert (r.status_code, r.json()["detail"]) == (403, "pharmacist_decides")
    client.post(
        f"/patients/me/file/proposals/{props['pregnancy']['id']}", headers=me, json={"accept": True}
    )
    r = client.post(
        f"/pharmacy-api/patients/{uid}/file/proposals/{props['allergy']['id']}",
        headers=ph,
        json={"accept": True},
    )
    assert r.json()["status"] == "accepted"
    client.post(
        f"/pharmacy-api/patients/{uid}/file/proposals/{props['medication']['id']}",
        headers=ph,
        json={"accept": False},
    )
    f = client.get("/patients/me/file", headers=me).json()
    facts = by_kind(f["facts"])
    assert set(facts) == {"allergy", "pregnancy"}
    assert (facts["allergy"]["confirmed"], facts["allergy"]["added_by"]) == (True, "رنا")
    assert (facts["pregnancy"]["source"], facts["pregnancy"]["confirmed"]) == ("patient", False)
    assert f["proposals"] == []


# ─── The patient ────────────────────────────────────────────────────────────


def test_the_patient_adds_ends_exports_and_deletes(client, engine):
    uid, _, ph, me = patient(client, engine)
    fact = client.post(
        "/patients/me/file/facts", headers=me, json={"kind": "condition", "text": "سكري"}
    ).json()
    assert (fact["source"], fact["confirmed"], fact["active"]) == ("patient", False, True)
    client.post(f"/patients/me/file/facts/{fact['id']}/end", headers=me)
    f = client.get("/patients/me/file", headers=me).json()
    assert f["facts"] == [] and f["past_facts"][0]["text"] == "سكري"
    assert (
        client.post(
            "/patients/me/file/facts", headers=me, json={"kind": "x", "text": "y"}
        ).status_code
        == 422
    )

    cid = sent_case(client, me)
    e = client.get("/patients/me/file/export", headers=me).json()
    assert [c["action"] for c in e["changes"]][:3] == ["consent", "add", "end"]
    assert e["history"][0]["id"] == cid

    assert client.delete("/patients/me/file", headers=me).json() == {"deleted": True}
    assert client.get("/patients/me/file", headers=me).status_code == 409
    with Session(engine) as db:
        assert db.query(HealthFact).count() == 0
    # The pharmacy keeps its case.
    assert [c["id"] for c in client.get("/pharmacy-api/cases", headers=ph).json()] == [cid]


# ─── The pharmacy ───────────────────────────────────────────────────────────


def test_the_patient_s_pharmacy_adds_and_confirms(client, engine):
    uid, _, ph, me = patient(client, engine)
    mine = client.post(
        "/patients/me/file/facts", headers=me, json={"kind": "allergy", "text": "أسبرين"}
    ).json()
    f = client.post(
        f"/pharmacy-api/patients/{uid}/file/facts",
        headers=ph,
        json={"kind": "condition", "text": "ربو"},
    ).json()
    assert (f["source"], f["confirmed"], f["added_by"]) == ("pharmacist", True, "رنا")
    r = client.post(f"/pharmacy-api/patients/{uid}/file/facts/{mine['id']}/confirm", headers=ph)
    assert r.json()["confirmed"] is True
    got = client.get(f"/pharmacy-api/patients/{uid}/file", headers=ph).json()
    assert got["limited"] is False
    assert {x["text"] for x in got["facts"]} == {"أسبرين", "ربو"}
    # The case says the patient has a file.
    cid = sent_case(client, me)
    case = client.get(f"/pharmacy-api/cases/{cid}", headers=ph).json()
    assert (case["patient"]["id"], case["patient"]["has_file"]) == (uid, True)


def test_other_pharmacies_and_a_pharmacy_the_patient_left(client, engine):
    uid, _, ph, me = patient(client, engine)
    sent_case(client, me)
    other_id, other_key = listed_pharmacy(engine, name="صيدلية النور", code="NOR1")
    other = pharmacy_auth(other_key)
    assert client.get(f"/pharmacy-api/patients/{uid}/file", headers=other).status_code == 403
    # The patient moves to the other pharmacy.
    client.patch("/patients/me", headers=me, json={"pharmacy_id": other_id})
    client.post("/patients/me/file/facts", headers=me, json={"kind": "allergy", "text": "أسبرين"})
    new = client.get(f"/pharmacy-api/patients/{uid}/file", headers=other).json()
    assert new["limited"] is False and new["facts"][0]["text"] == "أسبرين"
    assert len(new["history"]) == 1  # the whole file, older cases included
    old = client.get(f"/pharmacy-api/patients/{uid}/file", headers=ph).json()
    assert old["limited"] is True and old["facts"] == [] and len(old["history"]) == 1
    r = client.post(
        f"/pharmacy-api/patients/{uid}/file/facts", headers=ph, json={"kind": "note", "text": "x"}
    )
    assert r.status_code == 403


def test_the_decision_adds_the_medicines_for_their_days(client, engine):
    uid, _, ph, me = patient(client, engine)
    cid = sent_case(client, me)
    r = client.post(
        f"/pharmacy-api/cases/{cid}/decision",
        headers=ph,
        json={
            "items": [
                {
                    "name": "Augmentin 1g",
                    "quantity": 1,
                    "instructions": "حبة كل 12 ساعة",
                    "days": 7,
                },
                {"name": "Vitamin D", "quantity": 1, "instructions": "حبة بالأسبوع"},
            ]
        },
    )
    assert r.status_code == 200, r.text
    meds = {f["text"]: f for f in client.get("/patients/me/file", headers=me).json()["facts"]}
    assert meds["Augmentin 1g"]["detail"]["instructions"] == "حبة كل 12 ساعة"
    assert meds["Augmentin 1g"]["ends_at"] is not None and meds["Vitamin D"]["ends_at"] is None
    # After the course the medicine is no longer current.
    with Session(engine) as db:
        f = db.query(HealthFact).filter_by(text="Augmentin 1g").one()
        f.ends_at = datetime.now(UTC) - timedelta(minutes=1)
        db.commit()
    f = client.get("/patients/me/file", headers=me).json()
    assert [x["text"] for x in f["facts"]] == ["Vitamin D"]
    assert f["past_facts"][0]["text"] == "Augmentin 1g"


def test_the_assistant_knows_the_file_but_not_the_doses(client, engine):
    uid, _, ph, me = patient(client, engine)
    client.post("/patients/me/file/facts", headers=me, json={"kind": "allergy", "text": "البنسلين"})
    cid = sent_case(client, me)
    client.post(
        f"/pharmacy-api/cases/{cid}/decision",
        headers=ph,
        json={"items": [{"name": "Concor 5", "quantity": 1, "instructions": "حبة الصبح"}]},
    )
    client.post("/consultations", headers=me)
    cid2 = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid2}/messages", headers=me, json={"text": "راسي عم يوجعني"})
    system = next(
        m[0].content
        for m, _ in reversed(client.app.state.llm.calls)
        if "intake assistant" in m[0].content
    )
    assert "allergic to: البنسلين" in system
    assert "takes: Concor 5" in system
    assert "حبة الصبح" not in system


# ─── The platform owner ─────────────────────────────────────────────────────


def test_the_owner_sees_every_file_and_every_opening_is_logged(client, engine, settings):
    uid, _, ph, me = patient(client, engine)
    register(client, phone="0933999888", name="خالد")
    admin = bearer(admin_login(client, settings))
    found = client.get("/admin/patients?q=0933111222", headers=admin).json()
    assert [(p["id"], p["has_file"]) for p in found] == [(uid, True)]
    assert len(client.get("/admin/patients", headers=admin).json()) == 2
    f = client.get(f"/admin/patients/{uid}/file", headers=admin).json()
    assert f["patient"]["name"] == "سامر"
    client.get(f"/admin/patients/{uid}/file", headers=admin)
    with Session(engine) as db:
        assert db.query(FileAccess).count() == 2
    f = client.get(f"/admin/patients/{uid}/file", headers=admin).json()
    assert [o["by"] for o in f["opened"]] == ["فايز"] * 3
    for headers in (me, ph):
        assert client.get(f"/admin/patients/{uid}/file", headers=headers).status_code in (401, 403)


@pytest.mark.parametrize("path", ["/patients/me/file", "/patients/me/file/export"])
def test_only_the_patient_reaches_their_own_file(client, engine, path):
    _, _, ph, _ = patient(client, engine)
    assert client.get(path, headers=ph).status_code in (401, 403)
    assert client.get(path).status_code == 401
