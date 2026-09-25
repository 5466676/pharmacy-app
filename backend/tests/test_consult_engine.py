import json

from app.consult import texts
from app.consult.engine import Emergency, handle_message, summarize
from app.consult.llm import ChatMessage, LLMUnavailable, ScriptedLLM

SUMMARY = {
    "symptoms": ["صداع", "حرارة خفيفة"],
    "duration": "يومين",
    "age": "34",
    "sex": "ذكر",
    "pregnancy": None,
    "allergies": "ما في",
    "medications": "ولا شي",
    "conditions": None,
    "denied_red_flags": ["غثيان", "تيبس بالرقبة"],
    "notes": None,
}


def model(assistant=None, classifier=None, summary=None):
    """A scripted model that answers by which prompt it gets."""
    calls = {"classifier": 0, "assistant": 0, "summary": 0}

    def respond(messages, json_mode):
        system = messages[0].content
        if "triage safety checker" in system:
            calls["classifier"] += 1
            r = classifier or {"red_flag": False, "category": "other", "reason": ""}
        elif "Summarize this pharmacy chat" in system:
            calls["summary"] += 1
            r = summary.pop(0) if isinstance(summary, list) else (summary or SUMMARY)
        else:
            calls["assistant"] += 1
            r = assistant(messages) if callable(assistant) else assistant
        if isinstance(r, Exception):
            raise LLMUnavailable(str(r))
        return r if isinstance(r, str) else json.dumps(r, ensure_ascii=False)

    llm = ScriptedLLM(respond=respond)
    llm.counts = calls  # type: ignore[attr-defined]
    return llm


ASK = {"reply": "سلامتك. في غثيان أو تيبّس بالرقبة؟", "quick_replies": ["لا، ولا شي", "اي"]}


def test_a_normal_question_turn():
    llm = model(assistant={**ASK, "ready": False})
    turn = handle_message(llm, [], "عندي صداع من يومين وحرارة خفيفة", profile="34 سنة، ذكر")
    assert (turn.kind, turn.text) == ("reply", ASK["reply"])
    assert turn.quick_replies == ["لا، ولا شي", "اي"]
    assert [e.kind for e in turn.logs] == ["assistant_reply"]
    assert turn.logs[0].detail["prompt"] == "assistant-v1"
    system = next(c for c in llm.calls if "مساعد دوايا" in c[0][0].content)[0][0].content
    assert "34 سنة، ذكر" in system and "Never give a dose" in system


def test_rules_stop_before_any_model_call():
    llm = model(assistant=ASK)
    turn = handle_message(
        llm, [], "عندي وجع بصدري وعرقان", emergency=Emergency(ambulance="110", general="112")
    )
    assert turn.kind == "emergency" and turn.red_flag.category == "chest_pain"
    assert turn.red_flag_source == "rules"
    assert "110" in turn.text and "112" in turn.text
    assert llm.calls == []  # no LLM at all
    assert turn.logs[0].kind == "red_flag"


def test_self_harm_gets_its_own_words():
    turn = handle_message(model(), [], "ما عاد بدي عيش")
    assert turn.kind == "emergency" and turn.text.startswith("شكراً إنك حكيت")


def test_classifier_catches_a_bare_yes_to_a_danger_question():
    history = [
        ChatMessage("user", "عندي صداع وحرارة"),
        ChatMessage("assistant", "في تيبّس بالرقبة؟"),
    ]
    llm = model(assistant=ASK, classifier={"red_flag": True, "category": "severe_headache"})
    turn = handle_message(llm, history, "اي")
    assert turn.kind == "emergency" and turn.red_flag_source == "classifier"
    assert llm.counts["assistant"] == 0


def test_the_guard_replaces_a_dose_and_logs_it():
    llm = model(assistant={"reply": "خود بنادول حبتين كل 8 ساعات", "quick_replies": ["تمام"]})
    turn = handle_message(llm, [], "شو باخد للصداع؟")
    assert turn.kind == "reply" and turn.text == texts.GUARD_REPLACEMENT
    assert turn.quick_replies == []
    block = [e for e in turn.logs if e.kind == "guard_block"][0]
    assert block.detail["reply"] == "خود بنادول حبتين كل 8 ساعات"


def test_ready_produces_a_checked_summary():
    llm = model(assistant={"reply": "تمام، هيك صار عندي كل شي.", "ready": True})
    turn = handle_message(llm, [ChatMessage("user", "عندي صداع")], "لا ما في حساسية")
    assert turn.kind == "summary" and turn.summary.duration == "يومين"
    assert turn.summary.denied_red_flags == ["غثيان", "تيبس بالرقبة"]
    assert [e.kind for e in turn.logs] == ["assistant_reply", "summary"]


def test_summary_retries_once_then_gives_up_quietly():
    bad = {"symptoms": []}  # must have at least one symptom
    llm = model(summary=[bad, SUMMARY])
    summary, _ = summarize(llm, [ChatMessage("user", "صداع")])
    assert summary is not None and llm.counts["summary"] == 2
    llm = model(summary=[bad, "not json"])
    summary, _ = summarize(llm, [ChatMessage("user", "صداع")])
    assert summary is None


def test_a_long_chat_is_summarized_anyway():
    history = [
        m
        for i in range(7)
        for m in (ChatMessage("user", f"جواب {i}"), ChatMessage("assistant", "سؤال؟"))
    ]
    llm = model(assistant={"reply": "سؤال كمان؟", "ready": False})
    assert handle_message(llm, history, "جواب اخير").kind == "summary"


def test_model_down_never_blocks_the_patient():
    llm = model(assistant=RuntimeError("LM Studio is off"))
    turn = handle_message(llm, [], "عندي رشح")
    assert turn.kind == "fallback" and turn.text == texts.ASSISTANT_DOWN
    assert turn.logs[0].kind == "llm_down"
    # With the whole model down the classifier fails quietly too, and the
    # rules still stop emergencies.
    dead = ScriptedLLM(replies=[])
    assert handle_message(dead, [], "عندي رشح").kind == "fallback"
    assert handle_message(dead, [], "ما عم اقدر اتنفس").kind == "emergency"


def test_plain_text_reply_is_used_when_the_model_ignores_json():
    llm = model(assistant="من إيمتى بلّش الرشح؟")
    turn = handle_message(llm, [], "عندي رشح")
    assert (turn.kind, turn.text, turn.quick_replies) == ("reply", "من إيمتى بلّش الرشح؟", [])
