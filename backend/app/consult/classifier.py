"""The second red-flag layer: the LLM reads the recent conversation and says
whether it is an emergency. It can only add alarms; if the model is down or
its answer can't be read, the rules alone decide."""

from collections.abc import Sequence

from .llm import LLM, ChatMessage, LLMUnavailable, parse_json
from .redflags import RedFlagHit

CATEGORIES = (
    "chest_pain",
    "breathing",
    "stroke",
    "bleeding",
    "infant_fever",
    "self_harm",
    "poisoning",
    "seizure",
    "unconscious",
    "anaphylaxis",
    "pregnancy_bleeding",
    "severe_headache",
    "other",
)

PROMPT = """You are a triage safety checker for a pharmacy chat in Syria. You never answer
the patient. Read the conversation (Arabic, often Syrian dialect) and decide if the
PATIENT currently describes a medical emergency that needs an ambulance or the
emergency room now: chest pain, trouble breathing, stroke signs, heavy bleeding,
fever in a baby under 3 months, suicidal thoughts or self-harm, poisoning or an
overdose, seizures, fainting or unconsciousness, a severe allergic reaction
(swelling of the face, lips, tongue or throat), bleeding in pregnancy, a stiff
neck with fever, or the worst headache of their life. A short answer such as
"yes" / «اي» / «ايه» to the assistant's question about one of these counts.
Symptoms the patient clearly denies do not count. When unsure, say it IS an
emergency.

Reply with JSON only:
{"red_flag": true or false, "category": one of %s, "reason": "a few words"}"""


def classify(llm: LLM, conversation: Sequence[ChatMessage], *, last: int = 6) -> RedFlagHit | None:
    """[conversation]: the chat so far (patient = user, assistant = assistant),
    newest last. Only the [last] messages are sent."""
    lines = "\n".join(
        f"{'PATIENT' if m.role == 'user' else 'ASSISTANT'}: {m.content}"
        for m in conversation[-last:]
        if m.role != "system"
    )
    try:
        reply = llm.complete(
            [
                ChatMessage("system", PROMPT % ", ".join(CATEGORIES)),
                ChatMessage("user", lines),
            ],
            json_mode=True,
            temperature=0,
        )
    except LLMUnavailable:
        return None
    data = parse_json(reply)
    if not data or data.get("red_flag") is not True:
        return None
    category = data.get("category")
    if category not in CATEGORIES:
        category = "other"
    return RedFlagHit(category, str(data.get("reason") or "")[:200])
