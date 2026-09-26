"""Phase 4b: the assistant's model chosen in the panel, and its state."""

import json

import pytest
from sqlalchemy.orm import Session

from app.assistant import decrypt_key, encrypt_key
from app.consult.llm import LLMUnavailable, ScriptedLLM
from app.models import AssistantConfig

from .central_helpers import pharmacy_auth
from .test_admin import admin_login, bearer
from .test_consultations import _patient_with_pharmacy

KEY = "sk-secret-123456"


@pytest.fixture
def admin(client, settings) -> dict:
    return bearer(admin_login(client, settings))


@pytest.fixture
def made(client) -> list:
    """Every model the server makes; each answers «تمام» unless its name
    starts with "down"."""
    out = []

    def factory(config):
        llm = ScriptedLLM(
            respond=lambda m, j: (
                (_ for _ in ()).throw(LLMUnavailable("off"))
                if config.model.startswith("down")
                else "تمام"
            )
        )
        llm.model = config.model
        out.append((config, llm))
        return llm

    client.app.state.llm_factory = factory
    client.app.state.models_probe = lambda url, key: (
        ["qwen2.5-7b-instruct", "llama-3.1-8b"] if "1234" in url else ["gpt-x"] if key else []
    )
    return out


def choose(client, admin, **body):
    body = {
        "provider": "lm_studio",
        "base_url": "http://localhost:1234/v1",
        "model": "llama-3.1-8b",
        **body,
    }
    return client.put("/admin/assistant/model", json=body, headers=admin)


def test_until_chosen_the_server_settings_are_used(client, admin):
    a = client.get("/admin/assistant", headers=admin).json()
    assert (a["source"], a["provider"], a["has_key"]) == ("settings", "lm_studio", False)
    assert a["providers"]["ollama"] == "http://localhost:11434/v1"


def test_the_models_the_chosen_server_offers(client, admin, made):
    r = client.post(
        "/admin/assistant/models",
        json={"provider": "lm_studio", "base_url": "http://localhost:1234/v1"},
        headers=admin,
    )
    assert r.json()["models"] == ["llama-3.1-8b", "qwen2.5-7b-instruct"]
    r = client.post(
        "/admin/assistant/models",
        json={"provider": "hosted", "base_url": "https://api.example/v1", "api_key": KEY},
        headers=admin,
    )
    assert r.json()["models"] == ["gpt-x"]


def test_an_unreachable_server_says_so(client, admin):
    r = client.post(
        "/admin/assistant/models",
        json={"provider": "ollama", "base_url": "http://127.0.0.1:9/v1"},
        headers=admin,
    )
    assert (r.status_code, r.json()["detail"]) == (502, "server_unreachable")


def test_switching_only_after_the_model_answers(client, admin, made):
    r = choose(client, admin, model="down-model")
    assert (r.status_code, r.json()["detail"]) == (400, "model_not_answering")
    assert client.get("/admin/assistant", headers=admin).json()["source"] == "settings"

    r = choose(client, admin)
    assert r.status_code == 200 and r.json()["ms"] >= 0
    a = client.get("/admin/assistant", headers=admin).json()
    assert (a["source"], a["model"], a["updated_by"]) == ("panel", "llama-3.1-8b", "فايز")
    # The assistant uses it from now on.
    assert client.app.state.llm is made[-1][1]


def test_the_new_model_answers_patients(client, engine, admin, made):
    choose(client, admin)
    ask = json.dumps({"reply": "سلامتك، من إيمتى؟", "quick_replies": []}, ensure_ascii=False)
    client.app.state.llm.respond = lambda m, j: ask if "intake assistant" in m[0].content else "{}"
    _, _, me = _patient_with_pharmacy(client, engine)
    client.app.state.llm = made[-1][1]  # the helper put its own scripted model
    cid = client.post("/consultations", headers=me).json()["id"]
    c = client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "عندي زكام"}).json()
    assert c["messages"][-1]["text"] == "سلامتك، من إيمتى؟"


def test_the_key_is_stored_encrypted_and_never_sent_back(client, engine, admin, made, settings):
    r = choose(client, admin, provider="hosted", base_url="https://api.example/v1", api_key=KEY)
    assert KEY not in r.text
    assert r.json()["has_key"] is True
    assert made[-1][0].api_key == KEY
    with Session(engine) as db:
        row = db.get(AssistantConfig, 1)
        assert KEY not in (row.api_key_enc or "")
        assert decrypt_key(settings.jwt_secret, row.api_key_enc) == KEY
    everything = client.get("/admin/assistant", headers=admin).text
    everything += client.get("/admin/assistant/changes", headers=admin).text
    everything += client.get("/admin/settings", headers=admin).text
    assert KEY not in everything

    # Not sending a key keeps it (same address); "" removes it.
    choose(client, admin, provider="hosted", base_url="https://api.example/v1", model="gpt-x")
    assert made[-1][0].api_key == KEY
    choose(client, admin, provider="hosted", base_url="https://api.example/v1", api_key="")
    assert client.get("/admin/assistant", headers=admin).json()["has_key"] is False
    # Another address never gets the old key.
    choose(client, admin, provider="hosted", base_url="https://api.example/v1", api_key=KEY)
    choose(client, admin, provider="ollama", base_url="http://localhost:11434/v1")
    assert made[-1][0].api_key == ""


def test_a_key_made_with_another_server_secret_is_unreadable(settings):
    token = encrypt_key(settings.jwt_secret, KEY)
    assert decrypt_key("another-secret-" + "y" * 40, token) == ""
    assert decrypt_key(settings.jwt_secret, None) == ""


def test_every_change_is_logged_without_the_key(client, admin, made):
    choose(client, admin)
    choose(client, admin, model="qwen2.5-7b-instruct", api_key=KEY)
    log = client.get("/admin/assistant/changes?kind=model", headers=admin).json()
    assert [c["after"]["model"] for c in log] == ["qwen2.5-7b-instruct", "llama-3.1-8b"]
    assert log[0]["before"]["model"] == "llama-3.1-8b"
    assert log[0]["after"]["has_key"] is True
    assert log[1]["before"]["source"] == "settings"


def test_state_of_the_assistant(client, engine, admin):
    _, key, me = _patient_with_pharmacy(
        client, engine, assistant={"reply": "سلامتك.", "quick_replies": []}
    )
    cid = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "عندي زكام"})
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "من يومين"})
    other = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{other}/messages", headers=me, json={"text": "عندي ألم بالصدر"})
    client.app.state.llm = ScriptedLLM(replies=[])  # down
    third = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{third}/messages", headers=me, json={"text": "راسي عم يوجعني"})
    s = client.get("/admin/assistant/stats", headers=admin).json()
    assert (s["replies"], s["down"], s["red_flags_rules"]) == (2, 1, 1)
    assert s["median_ms"] is not None and s["slowest_ms"] >= s["median_ms"]
    assert s["last_down_at"] is not None
    assert pharmacy_auth(key)  # the pharmacy side is untouched


def test_only_admins(client, engine):
    _, key, me = _patient_with_pharmacy(client, engine)
    for headers in (me, pharmacy_auth(key), {}):
        assert client.get("/admin/assistant", headers=headers).status_code in (401, 403)
        r = client.put("/admin/assistant/model", json={}, headers=headers)
        assert r.status_code in (401, 403)
