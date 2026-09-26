"""Central server: the patient's consultation (chat with the assistant) and
the same record as the pharmacy's case once it's sent.

Patient:  /consultations …          (patient token)
Pharmacy: /pharmacy-api/cases …     (the pharmacy server's key; the
                                     pharmacist's name rides in X-Doaya-Actor)
"""

from datetime import UTC, date, datetime
from typing import Literal

from fastapi import APIRouter, Request, UploadFile
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from .consult import texts
from .consult.engine import CaseSummary, Emergency, LogEntry, handle_message
from .consult.llm import ChatMessage, llm_from_settings
from .consult.redflags import check
from .deps import DbSession, Patient, PharmacyCaller, error
from .events import patient_topic, pharmacy_topic
from .knowledge import match_notes
from .models import AiLog, Consultation, ConsultMessage, PatientProfile, User
from .security import new_id

router = APIRouter(tags=["consultations"])

# While chatting the assistant answers; once sent, the pharmacist does.
CHATTING = {"chatting", "summary"}
WITH_PHARMACY = {"sent", "preparing", "ready", "emergency"}
FINISHED = {"picked_up", "needs_doctor", "closed"}


class MessageOut(BaseModel):
    id: int
    role: str
    text: str
    quick_replies: list[str] | None
    author: str | None
    photo_id: str | None = None
    created_at: datetime


class ConsultationOut(BaseModel):
    id: str
    pharmacy_id: str
    status: str
    urgent: bool
    red_flag: str | None
    summary: dict | None
    decision: dict | None
    handled_by: str | None
    created_at: datetime
    sent_at: datetime | None
    updated_at: datetime
    messages: list[MessageOut]


class CasePatient(BaseModel):
    name: str
    phone: str
    age: int | None
    sex: str | None


class CaseBrief(BaseModel):
    id: str
    status: str
    urgent: bool
    red_flag: str | None
    title: str
    patient: CasePatient
    sent_at: datetime | None
    updated_at: datetime


class CaseOut(ConsultationOut):
    patient: CasePatient


class TextIn(BaseModel):
    text: str = Field(min_length=1, max_length=2000)


class DecisionItem(BaseModel):
    product_id: str | None = Field(default=None, max_length=36)
    name: str = Field(min_length=1, max_length=200)
    quantity: int = Field(ge=1, le=1000)
    # The pharmacist's own words: how to take it.
    instructions: str = Field(min_length=1, max_length=500)
    # For reminders on the patient's phone (optional).
    times_per_day: int | None = Field(default=None, ge=1, le=12)
    days: int | None = Field(default=None, ge=1, le=365)
    price_minor: int | None = Field(default=None, ge=0)


class DecisionIn(BaseModel):
    items: list[DecisionItem] = Field(min_length=1, max_length=30)
    note: str | None = Field(default=None, max_length=1000)


class CorrectionIn(BaseModel):
    """The pharmacist flags something the assistant got wrong."""

    target: Literal["summary", "message"]
    message_id: int | None = None
    field: str | None = Field(default=None, max_length=40)
    correction: str = Field(min_length=1, max_length=2000)


# ─── Helpers ───────────────────────────────────────────────────────────────


def _now() -> datetime:
    return datetime.now(UTC)


def _messages(db: Session, cid: str) -> list[ConsultMessage]:
    return list(
        db.scalars(
            select(ConsultMessage)
            .where(ConsultMessage.consultation_id == cid)
            .order_by(ConsultMessage.id)
        )
    )


def _out(db: Session, c: Consultation) -> dict:
    return {
        **{k: getattr(c, k) for k in ConsultationOut.model_fields if k != "messages"},
        "messages": [
            MessageOut.model_validate(m, from_attributes=True) for m in _messages(db, c.id)
        ],
    }


def _say(db, c: Consultation, role: str, text: str, quick=None, author=None, photo_id=None) -> None:
    db.add(
        ConsultMessage(
            consultation_id=c.id,
            role=role,
            text=text,
            quick_replies=quick or None,
            author=author,
            photo_id=photo_id,
        )
    )


def _log(db, c: Consultation, entries: list[LogEntry]) -> None:
    for e in entries:
        db.add(AiLog(consultation_id=c.id, kind=e.kind, detail=e.detail))


def _changed(request: Request, c: Consultation, kind: str) -> None:
    c.updated_at = _now()
    request.app.state.events.publish(
        [patient_topic(c.patient_id), pharmacy_topic(c.pharmacy_id)],
        {"type": kind, "consultation_id": c.id, "status": c.status, "urgent": c.urgent},
    )


def _age(prof: PatientProfile | None) -> int | None:
    return date.today().year - prof.birth_year if prof and prof.birth_year else None


def _profile_text(db: Session, patient_id: str) -> str:
    prof = db.get(PatientProfile, patient_id)
    parts = []
    if age := _age(prof):
        parts.append(f"age {age}")
    if prof and prof.sex:
        parts.append({"m": "male", "f": "female"}[prof.sex])
    return ", ".join(parts)


def _emergency_numbers(request: Request) -> Emergency:
    s = request.app.state.settings
    return Emergency(ambulance=s.emergency_ambulance, general=s.emergency_general)


def get_llm(request: Request):
    """The configured model (tests put a scripted one on app.state)."""
    state = request.app.state
    if getattr(state, "llm", None) is None:
        state.llm = llm_from_settings(state.settings)
    return state.llm


# ─── Patient ───────────────────────────────────────────────────────────────


def _mine(db: Session, p, cid: str) -> Consultation:
    c = db.get(Consultation, cid)
    if c is None or c.patient_id != p.user_id:
        raise error(404, "consultation_not_found")
    return c


@router.post("/consultations", response_model=ConsultationOut)
def start(p: Patient, db: DbSession) -> dict:
    """A new chat with the chosen pharmacy's assistant."""
    prof = db.get(PatientProfile, p.user_id)
    if prof is None or prof.pharmacy_id is None:
        raise error(409, "no_pharmacy")
    c = Consultation(
        id=new_id(),
        patient_id=p.user_id,
        pharmacy_id=prof.pharmacy_id,
        status="chatting",
        urgent=False,
    )
    db.add(c)
    db.flush()
    _say(db, c, "assistant", texts.GREETING)
    db.commit()
    return _out(db, c)


@router.get("/consultations", response_model=list[ConsultationOut])
def my_consultations(p: Patient, db: DbSession) -> list:
    rows = db.scalars(
        select(Consultation)
        .where(Consultation.patient_id == p.user_id)
        .order_by(Consultation.updated_at.desc())
        .limit(50)
    )
    return [_out(db, c) for c in rows]


@router.get("/consultations/{cid}", response_model=ConsultationOut)
def one(cid: str, p: Patient, db: DbSession) -> dict:
    return _out(db, _mine(db, p, cid))


@router.post("/consultations/{cid}/messages", response_model=ConsultationOut)
def patient_says(cid: str, body: TextIn, p: Patient, db: DbSession, request: Request) -> dict:
    c = _mine(db, p, cid)
    if c.status in FINISHED:
        raise error(409, "consultation_closed")
    text = body.text.strip()

    if c.status in WITH_PHARMACY:
        # To the pharmacist now, but the red-flag rules still run first.
        _say(db, c, "patient", text)
        if hit := check(text):
            c.urgent, c.red_flag = True, c.red_flag or hit.category
            n = _emergency_numbers(request)
            template = texts.SELF_HARM if hit.category == "self_harm" else texts.EMERGENCY
            _say(db, c, "system", template.format(ambulance=n.ambulance, general=n.general))
            _log(
                db,
                c,
                [
                    LogEntry(
                        "red_flag",
                        {"source": "rules", "category": hit.category, "matched": hit.matched},
                    )
                ],
            )
        _changed(request, c, "case_message")
        db.commit()
        return _out(db, c)

    history = [
        ChatMessage("user" if m.role == "patient" else "assistant", m.text)
        for m in _messages(db, c.id)
        if m.role in ("patient", "assistant")
    ]
    # The admin's notes whose tags the patient mentioned.
    notes = match_notes(db, [m.content for m in history if m.role == "user"] + [text])
    turn = handle_message(
        get_llm(request),
        history,
        text,
        profile=_profile_text(db, p.user_id),
        knowledge=[n.text for n in notes],
        emergency=_emergency_numbers(request),
    )
    for entry in turn.logs:
        if entry.kind == "assistant_reply" and notes:
            entry.detail["notes"] = [n.id for n in notes]
    _say(db, c, "patient", text)
    _say(db, c, "assistant", turn.text, quick=turn.quick_replies)
    _log(db, c, turn.logs)
    if turn.kind == "emergency":
        # Straight to the pharmacy as urgent; the chat with the assistant stops.
        c.status, c.urgent, c.red_flag, c.sent_at = (
            "emergency",
            True,
            turn.red_flag.category,
            _now(),
        )
        _changed(request, c, "case_new")
    elif turn.kind == "summary":
        c.status, c.summary = "summary", turn.summary.model_dump()
        _changed(request, c, "consultation")
    else:
        _changed(request, c, "consultation")
    db.commit()
    return _out(db, c)


@router.post("/consultations/{cid}/photos", response_model=ConsultationOut)
async def send_photo(
    cid: str, file: UploadFile, p: Patient, db: DbSession, request: Request
) -> dict:
    """A photo in the chat (a prescription, a box). It goes to the
    pharmacist with the case; the assistant doesn't read it."""
    from .photos import save_photo

    c = _mine(db, p, cid)
    if c.status in FINISHED:
        raise error(409, "consultation_closed")
    photo = await save_photo(request, db, p.user_id, c.pharmacy_id, file)
    photo.consultation_id = c.id
    _say(db, c, "patient", texts.PHOTO, photo_id=photo.id)
    _changed(request, c, "case_message" if c.sent_at else "consultation")
    db.commit()
    return _out(db, c)


@router.put("/consultations/{cid}/summary", response_model=ConsultationOut)
def correct_summary(
    cid: str, body: CaseSummary, p: Patient, db: DbSession, request: Request
) -> dict:
    """The patient fixes the summary before sending it."""
    c = _mine(db, p, cid)
    if c.status != "summary":
        raise error(409, "no_summary")
    new = body.model_dump()
    if new != c.summary:
        _log(db, c, [LogEntry("patient_edit", {"before": c.summary, "after": new})])
        c.summary = new
    _changed(request, c, "consultation")
    db.commit()
    return _out(db, c)


@router.post("/consultations/{cid}/send", response_model=ConsultationOut)
def send(cid: str, p: Patient, db: DbSession, request: Request) -> dict:
    """To the pharmacy: with the summary, or (assistant down, or the patient
    prefers) with the conversation alone."""
    c = _mine(db, p, cid)
    if c.status not in CHATTING:
        raise error(409, "already_sent")
    if not any(m.role == "patient" for m in _messages(db, c.id)):
        raise error(409, "empty_consultation")
    c.status, c.sent_at = "sent", _now()
    _say(db, c, "system", texts.SENT)
    _changed(request, c, "case_new")
    db.commit()
    return _out(db, c)


# ─── Pharmacy ──────────────────────────────────────────────────────────────


def _case(db: Session, caller, cid: str) -> Consultation:
    c = db.get(Consultation, cid)
    if c is None or c.pharmacy_id != caller.pharmacy_id or c.sent_at is None:
        raise error(404, "case_not_found")
    return c


def _case_patient(db: Session, patient_id: str) -> CasePatient:
    user, prof = db.get(User, patient_id), db.get(PatientProfile, patient_id)
    return CasePatient(
        name=user.name, phone=user.phone, age=_age(prof), sex=prof.sex if prof else None
    )


def _title(db: Session, c: Consultation) -> str:
    if c.summary and c.summary.get("symptoms"):
        return "، ".join(c.summary["symptoms"][:3])
    first = db.scalar(
        select(ConsultMessage.text)
        .where(ConsultMessage.consultation_id == c.id, ConsultMessage.role == "patient")
        .order_by(ConsultMessage.id)
        .limit(1)
    )
    return (first or "")[:80]


@router.get("/pharmacy-api/cases", response_model=list[CaseBrief])
def cases(
    caller: PharmacyCaller,
    db: DbSession,
    status: str | None = None,
    updated_after: datetime | None = None,
) -> list:
    """Urgent first, then newest."""
    stmt = select(Consultation).where(
        Consultation.pharmacy_id == caller.pharmacy_id, Consultation.sent_at.is_not(None)
    )
    if status:
        stmt = stmt.where(Consultation.status.in_(status.split(",")))
    if updated_after:
        stmt = stmt.where(Consultation.updated_at > updated_after)
    stmt = stmt.order_by(Consultation.urgent.desc(), Consultation.sent_at.desc()).limit(200)
    return [
        CaseBrief(
            id=c.id,
            status=c.status,
            urgent=c.urgent,
            red_flag=c.red_flag,
            title=_title(db, c),
            patient=_case_patient(db, c.patient_id),
            sent_at=c.sent_at,
            updated_at=c.updated_at,
        )
        for c in db.scalars(stmt)
    ]


@router.get("/pharmacy-api/cases/{cid}", response_model=CaseOut)
def case(cid: str, caller: PharmacyCaller, db: DbSession) -> dict:
    c = _case(db, caller, cid)
    return {**_out(db, c), "patient": _case_patient(db, c.patient_id)}


def _act(db, request, caller, c: Consultation, kind: str) -> dict:
    c.handled_by = caller.actor or c.handled_by
    c.first_action_at = c.first_action_at or _now()
    _changed(request, c, kind)
    db.commit()
    return {**_out(db, c), "patient": _case_patient(db, c.patient_id)}


@router.post("/pharmacy-api/cases/{cid}/messages", response_model=CaseOut)
def pharmacist_says(
    cid: str, body: TextIn, caller: PharmacyCaller, db: DbSession, request: Request
) -> dict:
    """«اسأل المريض سؤال»: a message in the patient's chat."""
    c = _case(db, caller, cid)
    if c.status in FINISHED:
        raise error(409, "case_closed")
    _say(db, c, "pharmacist", body.text.strip(), author=caller.actor)
    if c.status == "sent":
        c.status = "preparing"
    return _act(db, request, caller, c, "case_message")


@router.post("/pharmacy-api/cases/{cid}/preparing", response_model=CaseOut)
def preparing(cid: str, caller: PharmacyCaller, db: DbSession, request: Request) -> dict:
    c = _case(db, caller, cid)
    if c.status not in ("sent", "emergency"):
        raise error(409, "bad_status")
    c.status = "preparing"
    return _act(db, request, caller, c, "case_status")


@router.post("/pharmacy-api/cases/{cid}/decision", response_model=CaseOut)
def decide(
    cid: str, body: DecisionIn, caller: PharmacyCaller, db: DbSession, request: Request
) -> dict:
    """The pharmacist's choice of medicines and how to take them; the
    patient is told it's ready for pickup."""
    c = _case(db, caller, cid)
    if c.status not in ("sent", "preparing", "emergency"):
        raise error(409, "bad_status")
    c.decision = {**body.model_dump(), "by": caller.actor, "at": _now().isoformat()}
    c.status = "ready"
    lines = [f"• {i.name} ({i.quantity}): {i.instructions}" for i in body.items]
    text = "\n".join([texts.READY, *lines, *([body.note] if body.note else [])])
    _say(db, c, "pharmacist", text, author=caller.actor)
    return _act(db, request, caller, c, "case_status")


@router.post("/pharmacy-api/cases/{cid}/needs-doctor", response_model=CaseOut)
def needs_doctor(
    cid: str, caller: PharmacyCaller, db: DbSession, request: Request, body: TextIn | None = None
) -> dict:
    c = _case(db, caller, cid)
    if c.status in FINISHED:
        raise error(409, "case_closed")
    c.status = "needs_doctor"
    _say(db, c, "pharmacist", texts.NEEDS_DOCTOR, author=caller.actor)
    if body:
        _say(db, c, "pharmacist", body.text.strip(), author=caller.actor)
    return _act(db, request, caller, c, "case_status")


@router.post("/pharmacy-api/cases/{cid}/picked-up", response_model=CaseOut)
def picked_up(cid: str, caller: PharmacyCaller, db: DbSession, request: Request) -> dict:
    c = _case(db, caller, cid)
    if c.status != "ready":
        raise error(409, "bad_status")
    c.status = "picked_up"
    return _act(db, request, caller, c, "case_status")


@router.post("/pharmacy-api/cases/{cid}/close", response_model=CaseOut)
def close(cid: str, caller: PharmacyCaller, db: DbSession, request: Request) -> dict:
    """E.g. an emergency the pharmacy followed up by phone."""
    c = _case(db, caller, cid)
    c.status = "closed"
    return _act(db, request, caller, c, "case_status")


@router.post("/pharmacy-api/cases/{cid}/corrections")
def correct(cid: str, body: CorrectionIn, caller: PharmacyCaller, db: DbSession) -> dict:
    """Logged for the admin review queue and, once curated there, the
    knowledge base. Never used for automatic fine-tuning."""
    c = _case(db, caller, cid)
    original = None
    if body.target == "message":
        m = db.get(ConsultMessage, body.message_id or -1)
        if m is None or m.consultation_id != c.id or m.role != "assistant":
            raise error(404, "message_not_found")
        original = m.text
    elif body.field and c.summary is not None:
        original = c.summary.get(body.field)
    _log(
        db,
        c,
        [
            LogEntry(
                "correction",
                {
                    "target": body.target,
                    "message_id": body.message_id,
                    "field": body.field,
                    "original": original,
                    "correction": body.correction,
                    "by": caller.actor,
                },
            )
        ],
    )
    db.commit()
    return {"ok": True}
