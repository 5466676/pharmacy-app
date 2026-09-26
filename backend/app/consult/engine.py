"""One patient message through the safety pipeline (docs/SPEC.md §2.1):

    red-flag rules → LLM classifier → assistant → output guard → (summary)

Pure logic over the conversation so far; the API (step 4) stores the
messages, the case and the log entries this returns.
"""

from collections.abc import Sequence
from dataclasses import dataclass, field
from typing import Literal

from pydantic import BaseModel, Field, ValidationError

from . import texts
from .classifier import classify
from .guard import check_reply
from .llm import LLM, ChatMessage, LLMUnavailable, parse_json
from .redflags import RedFlagHit, check

PROMPT_VERSION = "assistant-v1"
MAX_PATIENT_MESSAGES = 8

ASSISTANT_PROMPT = """You are «مساعد دوايا», the intake assistant of a pharmacy in Syria.
Speak Syrian Arabic: warm, short (one or two sentences), ONE question at a time.

Your only job is to collect what the pharmacist needs: the main symptoms, how long,
age, sex, pregnancy or breastfeeding (women of childbearing age), allergies to
medicines, medicines taken now, chronic conditions, and the danger signs that fit
the symptoms (for example: stiff neck with fever and headache, blood, trouble
breathing). Don't ask what is already known or already answered.

Rules you never break:
- Never name, suggest or recommend any medicine, cream, syrup or supplement.
- Never give a dose, an amount, or how often to take anything.
- Never tell the patient a doctor is not needed, and never diagnose with certainty.
- If asked what to take: the pharmacist will decide and prepare it.

Known about the patient: {profile}
{knowledge}
Reply with JSON only:
{{"reply": "your message", "quick_replies": ["up to 3 short answers the patient may tap"],
  "ready": true when you have enough for the pharmacist (usually after 3 to 6 questions)}}"""

SUMMARY_PROMPT = """Summarize this pharmacy chat for the pharmacist. Use the patient's own
facts, in short Arabic. Unknown → null. Never add a medicine, a dose or a diagnosis.
Reply with JSON only, exactly these keys:
{"symptoms": ["..."], "duration": "...", "age": "...", "sex": "...",
 "pregnancy": "...", "allergies": "...", "medications": "...", "conditions": "...",
 "denied_red_flags": ["danger signs the patient said they do NOT have"],
 "notes": "anything else the pharmacist should know"}"""


class CaseSummary(BaseModel):
    """What the pharmacist reads first (design/pharmacy_case_detail_layout)."""

    symptoms: list[str] = Field(min_length=1)
    duration: str | None = None
    age: str | None = None
    sex: str | None = None
    pregnancy: str | None = None
    allergies: str | None = None
    medications: str | None = None
    conditions: str | None = None
    denied_red_flags: list[str] = []
    notes: str | None = None


@dataclass(frozen=True)
class LogEntry:
    """For the admin review queue (Phase 4); never used for fine-tuning."""

    kind: Literal[
        "red_flag",
        "assistant_reply",
        "guard_block",
        "summary",
        "llm_down",
        "patient_edit",
        "correction",
    ]
    detail: dict


@dataclass
class Turn:
    """What happens after one patient message."""

    kind: Literal["reply", "emergency", "summary", "fallback"]
    text: str
    quick_replies: list[str] = field(default_factory=list)
    red_flag: RedFlagHit | None = None
    red_flag_source: Literal["rules", "classifier"] | None = None
    summary: CaseSummary | None = None
    logs: list[LogEntry] = field(default_factory=list)


@dataclass(frozen=True)
class Emergency:
    ambulance: str = "110"
    general: str = "112"


DEFAULT_EMERGENCY = Emergency()


def handle_message(
    llm: LLM,
    history: Sequence[ChatMessage],
    text: str,
    *,
    profile: str = "",
    knowledge: Sequence[str] = (),
    emergency: Emergency = DEFAULT_EMERGENCY,
) -> Turn:
    """[history]: the conversation before [text] (patient = user). Never
    raises: a model failure becomes a fallback turn."""
    conversation = [*history, ChatMessage("user", text)]

    # 1. Rules: no model involved, instant.
    if hit := check(text):
        return _emergency(hit, "rules", emergency)

    # 2. Classifier: reads the recent conversation; only adds alarms.
    if hit := classify(llm, conversation):
        return _emergency(hit, "classifier", emergency)

    # 3. Assistant.
    patient_turns = sum(1 for m in conversation if m.role == "user")
    system = ASSISTANT_PROMPT.format(
        profile=profile or "nothing yet",
        knowledge=(
            "Pharmacist-approved notes that may help you ask better questions:\n"
            + "\n".join(f"- {k}" for k in knowledge)
            + "\n"
            if knowledge
            else ""
        ),
    )
    try:
        raw = llm.complete([ChatMessage("system", system), *conversation], json_mode=True)
    except LLMUnavailable as e:
        return Turn(
            "fallback", texts.ASSISTANT_DOWN, logs=[LogEntry("llm_down", {"error": str(e)})]
        )

    data = parse_json(raw) or {}
    reply = data.get("reply") if isinstance(data.get("reply"), str) else None
    reply = (reply or raw).strip()
    quick = [q for q in data.get("quick_replies") or [] if isinstance(q, str)][:3]
    ready = data.get("ready") is True or patient_turns >= MAX_PATIENT_MESSAGES
    logs = [
        LogEntry(
            "assistant_reply",
            {"model": llm.model, "prompt": PROMPT_VERSION, "raw": raw, "reply": reply},
        )
    ]

    # 4. Guard: the patient never sees a dose, a prescription or "no doctor".
    if violation := check_reply(reply):
        logs.append(
            LogEntry(
                "guard_block",
                {"kind": violation.kind, "matched": violation.matched, "reply": reply},
            )
        )
        reply, quick = texts.GUARD_REPLACEMENT, []

    if not ready:
        return Turn("reply", reply, quick_replies=quick, logs=logs)

    # 5. Summary for the pharmacist, which the patient checks before sending.
    summary, summary_logs = summarize(llm, conversation)
    logs += summary_logs
    if summary is None:
        return Turn("fallback", texts.SUMMARY_FAILED, logs=logs)
    return Turn("summary", texts.SUMMARY_READY, summary=summary, logs=logs)


def summarize(llm: LLM, conversation: Sequence[ChatMessage]) -> tuple[CaseSummary | None, list]:
    """The case summary, validated; one retry with the error. None if the
    model can't produce it (the case then goes with the conversation)."""
    chat = "\n".join(
        f"{'PATIENT' if m.role == 'user' else 'ASSISTANT'}: {m.content}"
        for m in conversation
        if m.role != "system"
    )
    messages = [ChatMessage("system", SUMMARY_PROMPT), ChatMessage("user", chat)]
    logs: list[LogEntry] = []
    for _ in range(2):
        try:
            raw = llm.complete(messages, json_mode=True, temperature=0)
        except LLMUnavailable as e:
            logs.append(LogEntry("llm_down", {"error": str(e), "step": "summary"}))
            return None, logs
        try:
            summary = CaseSummary.model_validate(parse_json(raw) or {})
        except ValidationError as e:
            messages = [
                *messages,
                ChatMessage("assistant", raw),
                ChatMessage("user", f"Invalid: {e.errors()[:3]}. Reply with the JSON only."),
            ]
            continue
        # No guard here: the summary repeats the patient's own facts, such as
        # "Brufen 400 mg" they already take, for the pharmacist.
        logs.append(LogEntry("summary", {"model": llm.model, "summary": summary.model_dump()}))
        return summary, logs
    return None, logs


def _emergency(hit: RedFlagHit, source: str, emergency: Emergency) -> Turn:
    template = texts.SELF_HARM if hit.category == "self_harm" else texts.EMERGENCY
    return Turn(
        "emergency",
        template.format(ambulance=emergency.ambulance, general=emergency.general),
        red_flag=hit,
        red_flag_source=source,  # type: ignore[arg-type]
        logs=[
            LogEntry(
                "red_flag", {"source": source, "category": hit.category, "matched": hit.matched}
            )
        ],
    )
