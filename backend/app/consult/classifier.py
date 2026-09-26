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

# Fixed: who the checker is, the rule for doubt, and the answer format. The
# owner edits only what counts (GUIDE) and adds examples; a wrong guide can
# hide nothing the code rules catch, and never removes "when unsure, alarm".
HEAD = """You are a triage safety checker for a pharmacy chat in Syria. You never answer
the patient. Read the conversation (Arabic, often Syrian dialect)."""

GUIDE = """Say "emergency" when the PATIENT currently describes something that needs an
ambulance or the emergency room now: chest pain, trouble breathing, stroke signs,
heavy bleeding, fever in a baby under 3 months, suicidal thoughts or self-harm,
poisoning or an overdose, seizures, fainting or unconsciousness, a severe allergic
reaction (swelling of the face, lips, tongue or throat), bleeding in pregnancy, a
stiff neck with fever, or the worst headache of their life. A short answer such as
"yes" / «اي» / «ايه» to the assistant's question about one of these counts.

Say "doctor" when it is not an emergency but a doctor should examine the patient
soon rather than the pharmacy alone: symptoms lasting more than two weeks, a fever
for more than three days, blood in the urine or stool, unexplained weight loss, a
lump, pain that keeps coming back, or a child who is getting worse.

Symptoms the patient clearly denies do not count."""

RULE = "When unsure between two levels, choose the more serious one."

FORMAT = """Reply with JSON only:
{"level": "emergency" or "doctor" or "none", "category": one of %s,
 "reason": "a few words"}"""

LEVELS = ("emergency", "doctor", "normal")


def build_prompt(guide: str = GUIDE, examples: Sequence[tuple[str, str]] = ()) -> str:
    """[examples]: (patient text, emergency | doctor | normal), from the
    owner's «أمثلة السلامة»."""
    parts = [HEAD, guide.strip(), RULE]
    if examples:
        shown = {"emergency": "emergency", "doctor": "doctor", "normal": "none"}
        parts.append(
            "Examples checked by the platform's owner:\n"
            + "\n".join(f"PATIENT: {t.strip()} → {shown[label]}" for t, label in examples)
        )
    parts.append(FORMAT % ", ".join(CATEGORIES))
    return "\n\n".join(parts)


PROMPT = build_prompt()


def classify(
    llm: LLM,
    conversation: Sequence[ChatMessage],
    *,
    last: int = 6,
    prompt: str = PROMPT,
) -> RedFlagHit | None:
    """[conversation]: the chat so far (patient = user, assistant = assistant),
    newest last. Only the [last] messages are sent. A hit's level is
    "emergency" or "doctor"."""
    lines = "\n".join(
        f"{'PATIENT' if m.role == 'user' else 'ASSISTANT'}: {m.content}"
        for m in conversation[-last:]
        if m.role != "system"
    )
    try:
        reply = llm.complete(
            [
                ChatMessage("system", prompt),
                ChatMessage("user", lines),
            ],
            json_mode=True,
            temperature=0,
        )
    except LLMUnavailable:
        return None
    data = parse_json(reply)
    if not data:
        return None
    level = data.get("level")
    if data.get("red_flag") is True:  # the older answer format
        level = "emergency"
    if level not in ("emergency", "doctor"):
        return None
    category = data.get("category")
    if category not in CATEGORIES:
        category = "other"
    return RedFlagHit(category, str(data.get("reason") or "")[:200], level)
