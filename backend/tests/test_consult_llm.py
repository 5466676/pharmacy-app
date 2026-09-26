import json

import httpx
import pytest

from app.consult.classifier import classify
from app.consult.guard import check_reply
from app.consult.llm import (
    ChatMessage,
    LLMUnavailable,
    OpenAICompatibleLLM,
    ScriptedLLM,
    parse_json,
)

# ─── OpenAI-compatible client ──────────────────────────────────────────────


def _llm(handler) -> OpenAICompatibleLLM:
    return OpenAICompatibleLLM(
        "http://localhost:1234/v1",
        "qwen2.5-7b-instruct",
        api_key="k",
        transport=httpx.MockTransport(handler),
    )


def _reply(content: str) -> httpx.Response:
    return httpx.Response(200, json={"choices": [{"message": {"content": content}}]})


def test_client_speaks_the_openai_chat_api():
    seen = {}

    def handler(req: httpx.Request) -> httpx.Response:
        seen["url"] = str(req.url)
        seen["auth"] = req.headers.get("authorization")
        seen["body"] = json.loads(req.content)
        return _reply("<think>hmm</think>سلامتك")

    out = _llm(handler).complete([ChatMessage("user", "مرحبا")], json_mode=True, temperature=0)
    assert out == "سلامتك"
    assert seen["url"] == "http://localhost:1234/v1/chat/completions"
    assert seen["auth"] == "Bearer k"
    assert seen["body"]["model"] == "qwen2.5-7b-instruct"
    assert seen["body"]["messages"] == [{"role": "user", "content": "مرحبا"}]
    assert seen["body"]["response_format"] == {"type": "json_object"}


def test_client_retries_without_json_mode_when_the_server_refuses_it():
    bodies = []

    def handler(req: httpx.Request) -> httpx.Response:
        body = json.loads(req.content)
        bodies.append(body)
        if "response_format" in body:
            return httpx.Response(400, json={"error": "unsupported"})
        return _reply('{"ok": true}')

    assert _llm(handler).complete([ChatMessage("user", "x")], json_mode=True) == '{"ok": true}'
    assert len(bodies) == 2


@pytest.mark.parametrize(
    "handler",
    [
        lambda req: httpx.Response(503),
        lambda req: httpx.Response(200, json={"choices": []}),
        lambda req: _reply("   "),
        lambda req: (_ for _ in ()).throw(httpx.ConnectError("refused")),
    ],
)
def test_client_failures_are_one_clear_error(handler):
    with pytest.raises(LLMUnavailable):
        _llm(handler).complete([ChatMessage("user", "x")])


def test_parse_json_digs_the_object_out_of_prose():
    assert parse_json('```json\n{"red_flag": true, "x": {"y": 1}}\n```') == {
        "red_flag": True,
        "x": {"y": 1},
    }
    assert parse_json('Sure! {bad} then {"a": 1}') == {"a": 1}
    assert parse_json("no json here") is None


# ─── Classifier (second red-flag layer) ────────────────────────────────────

CONVO = [
    ChatMessage("user", "عندي صداع وحرارة"),
    ChatMessage("assistant", "في تيبّس بالرقبة؟"),
    ChatMessage("user", "اي"),
]


def test_classifier_reads_the_conversation_and_can_add_an_alarm():
    llm = ScriptedLLM(['{"red_flag": true, "category": "severe_headache", "reason": "stiff neck"}'])
    hit = classify(llm, CONVO)
    assert hit is not None and hit.category == "severe_headache"
    messages, json_mode = llm.calls[0]
    assert json_mode
    assert "ASSISTANT: في تيبّس بالرقبة؟" in messages[1].content
    assert messages[1].content.endswith("PATIENT: اي")


@pytest.mark.parametrize(
    "reply",
    [
        '{"red_flag": false, "category": "other", "reason": ""}',
        "I think it's fine",
        '{"red_flag": "yes"}',
        LLMUnavailable("down"),
    ],
)
def test_classifier_never_cancels_and_fails_quietly(reply):
    assert classify(ScriptedLLM([reply]), CONVO) is None


def test_classifier_unknown_category_becomes_other():
    hit = classify(ScriptedLLM(['{"red_flag": true, "category": "zombie"}']), CONVO)
    assert hit is not None and hit.category == "other"


# ─── Output guard ──────────────────────────────────────────────────────────

BLOCKED = [
    ("dose", "خود 500 ملغ باراسيتامول"),
    ("dose", "الجرعة 400mg"),
    ("dose", "حبة كل 8 ساعات"),
    ("dose", "حبتين مرتين باليوم بعد الأكل"),
    ("dose", "ملعقة صغيرة ٣ مرات يومياً"),
    ("dose", "5 مل من الشراب"),
    ("dose", "take 2 tablets"),
    ("prescribing", "خود بنادول وارتاح"),
    ("prescribing", "جرب Brufen"),
    ("prescribing", "بنصحك بمضاد حيوي"),
    ("prescribing", "استعملي كريم للحكة"),
    ("prescribing", "I recommend ibuprofen"),
    ("no_doctor", "ما بتحتاج دكتور، الموضوع بسيط"),
    ("no_doctor", "مو ضروري تشوف طبيب"),
    ("no_doctor", "ما في داعي تروح للدكتور"),
    ("no_doctor", "you don't need a doctor"),
]

ALLOWED = [
    "سلامتك. في غثيان، أو تيبّس بالرقبة، أو حساسية على أي دوا؟",
    "من إيمتى بلّش الوجع؟ من يومين أو أكتر؟",
    "بعتت حالتك للصيدلي، وهلق عم يحضّرلك الدوا.",
    "كم عمرك؟ وفي أدوية عم تاخدها هلق؟",
    "حرارتك كم؟ قستها؟ مثلاً 38 أو أكتر؟",
    "اشرب مي كتير وارتاح، والصيدلي رح يحددلك الدوا والجرعة.",
    "إذا صار عندك ضيق نفس أو ألم بالصدر، روح عالطوارئ فوراً.",
    "لا تتأخر، لازم تروح للدكتور إذا ضلت الحرارة.",
    "صار معك هالشي كم مرة هالأسبوع؟",
]


@pytest.mark.parametrize(("kind", "text"), BLOCKED)
def test_guard_blocks(kind, text):
    v = check_reply(text)
    assert v is not None and v.kind == kind, (text, v)


@pytest.mark.parametrize("text", ALLOWED)
def test_guard_allows(text):
    assert check_reply(text) is None, (text, check_reply(text))
