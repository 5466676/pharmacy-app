"""The admin's review queue (from the AI log) and the knowledge base.

Review: red flags, replies the guard blocked, pharmacists' corrections,
summaries the patient edited, and moments the model was down. Each item
shows the conversation without the patient's name or phone (age, sex and
pharmacy only).

Knowledge base: short notes the admin curates. A note reaches the assistant
when the patient's messages mention one of its tags. Never automatic
training, and a note that states a dose is refused (the assistant never
gives one)."""

from datetime import UTC, date, datetime

from fastapi import APIRouter
from pydantic import BaseModel, Field, field_validator
from sqlalchemy import select
from sqlalchemy.orm import Session

from .admin import REVIEW_KINDS, Admin
from .consult.guard import check_reply
from .consult.redflags import normalize
from .deps import DbSession, error
from .models import (
    AiLog,
    Consultation,
    ConsultMessage,
    KnowledgeChange,
    KnowledgeNote,
    PatientProfile,
    Pharmacy,
)
from .security import new_id

router = APIRouter(prefix="/admin", tags=["admin"])

# At most this many notes go with one assistant turn.
MAX_NOTES = 3
MIN_TAG = 2


def _now() -> datetime:
    return datetime.now(UTC)


# ─── Matching (used by the assistant) ───────────────────────────────────────


def _tag(t: str) -> str:
    return normalize(t)


def match_notes(db: Session, texts: list[str], limit: int = MAX_NOTES) -> list[KnowledgeNote]:
    """Enabled notes with a tag in the patient's words, most tags first.
    Tags match inside words too («حرار» matches «حرارتو»), so a tag can be
    a word's stem."""
    hay = normalize(" ".join(texts))
    if not hay:
        return []
    scored = []
    for n in db.scalars(select(KnowledgeNote).where(KnowledgeNote.enabled)):
        hits = sum(1 for t in n.tags if (k := _tag(t)) and len(k) >= MIN_TAG and k in hay)
        if hits:
            scored.append((hits, n.updated_at, n))
    scored.sort(key=lambda x: (-x[0], -x[1].timestamp()))
    return [n for *_, n in scored[:limit]]


# ─── Review queue ───────────────────────────────────────────────────────────


def _who(db: Session, c: Consultation) -> dict:
    prof = db.get(PatientProfile, c.patient_id)
    ph = db.get(Pharmacy, c.pharmacy_id)
    return {
        "age": date.today().year - prof.birth_year if prof and prof.birth_year else None,
        "sex": prof.sex if prof else None,
        "pharmacy": ph.name if ph else None,
    }


def _item(db: Session, log: AiLog, c: Consultation) -> dict:
    return {
        "id": log.id,
        "kind": log.kind,
        "detail": log.detail,
        "created_at": log.created_at.isoformat(),
        "reviewed": log.reviewed,
        "review_note": log.review_note,
        "reviewed_at": log.reviewed_at.isoformat() if log.reviewed_at else None,
        "consultation_id": c.id,
        "urgent": c.urgent,
        "red_flag": c.red_flag,
        **_who(db, c),
    }


@router.get("/review")
def review_queue(
    _: Admin,
    db: DbSession,
    kind: str | None = None,
    reviewed: bool = False,
    limit: int = 100,
) -> list:
    kinds = [k for k in (kind.split(",") if kind else REVIEW_KINDS) if k in REVIEW_KINDS]
    rows = db.execute(
        select(AiLog, Consultation)
        .join(Consultation, Consultation.id == AiLog.consultation_id)
        .where(AiLog.kind.in_(kinds), AiLog.reviewed.is_(reviewed))
        .order_by(AiLog.id.desc())
        .limit(max(1, min(limit, 500)))
    ).all()
    return [_item(db, log, c) for log, c in rows]


def _log(db: Session, log_id: int) -> tuple[AiLog, Consultation]:
    log = db.get(AiLog, log_id)
    if log is None or log.kind not in REVIEW_KINDS:
        raise error(404, "not_found")
    return log, db.get(Consultation, log.consultation_id)


@router.get("/review/{log_id}")
def review_item(log_id: int, _: Admin, db: DbSession) -> dict:
    """The item with its whole conversation: roles, text and time; the
    pharmacist's name, never the patient's. A photo shows as a marker."""
    log, c = _log(db, log_id)
    messages = db.scalars(
        select(ConsultMessage)
        .where(ConsultMessage.consultation_id == c.id)
        .order_by(ConsultMessage.id)
    )
    return {
        **_item(db, log, c),
        "status": c.status,
        "summary": c.summary,
        "decision": c.decision,
        "messages": [
            {
                "role": m.role,
                "text": m.text,
                "author": m.author if m.role == "pharmacist" else None,
                "photo": m.photo_id is not None,
                "at": m.created_at.isoformat(),
            }
            for m in messages
        ],
    }


class ReviewIn(BaseModel):
    note: str | None = Field(default=None, max_length=1000)


@router.post("/review/{log_id}")
def mark_reviewed(log_id: int, body: ReviewIn, a: Admin, db: DbSession) -> dict:
    log, c = _log(db, log_id)
    log.reviewed = True
    log.review_note = body.note.strip() if body.note and body.note.strip() else None
    log.reviewed_by = a.user_id
    log.reviewed_at = _now()
    db.commit()
    return _item(db, log, c)


# ─── Knowledge base ─────────────────────────────────────────────────────────


def _clean_tags(v: list[str]) -> list[str]:
    """Trimmed, no duplicates, none too short to mean anything."""
    tags = list(dict.fromkeys(t.strip() for t in v if len(_tag(t)) >= MIN_TAG))
    if not tags:
        raise ValueError("tags")
    return tags


class NoteIn(BaseModel):
    title: str = Field(min_length=2, max_length=200)
    text: str = Field(min_length=5, max_length=1000)
    tags: list[str] = Field(min_length=1, max_length=20)
    enabled: bool = True
    source_log_id: int | None = None

    @field_validator("tags")
    @classmethod
    def _tags(cls, v: list[str]) -> list[str]:
        return _clean_tags(v)


class NotePatch(BaseModel):
    title: str | None = Field(default=None, min_length=2, max_length=200)
    text: str | None = Field(default=None, min_length=5, max_length=1000)
    tags: list[str] | None = Field(default=None, min_length=1, max_length=20)
    enabled: bool | None = None

    @field_validator("tags")
    @classmethod
    def _tags(cls, v: list[str] | None) -> list[str] | None:
        return None if v is None else _clean_tags(v)


def _note(n: KnowledgeNote) -> dict:
    return {
        "id": n.id,
        "title": n.title,
        "text": n.text,
        "tags": n.tags,
        "enabled": n.enabled,
        "source_log_id": n.source_log_id,
        "created_at": n.created_at.isoformat(),
        "updated_at": n.updated_at.isoformat(),
    }


def _snapshot(n: KnowledgeNote) -> dict:
    return {"title": n.title, "text": n.text, "tags": n.tags, "enabled": n.enabled}


def _safe(text: str) -> None:
    if check_reply(text):
        raise error(400, "note_has_dose")


@router.get("/knowledge")
def notes(_: Admin, db: DbSession) -> list:
    return [_note(n) for n in db.scalars(select(KnowledgeNote).order_by(KnowledgeNote.title))]


@router.get("/knowledge/match")
def preview(_: Admin, db: DbSession, text: str) -> list:
    """Which notes the assistant would get for this patient text."""
    return [_note(n) for n in match_notes(db, [text])]


@router.post("/knowledge")
def add_note(body: NoteIn, a: Admin, db: DbSession) -> dict:
    _safe(f"{body.title} {body.text}")
    if body.source_log_id is not None and db.get(AiLog, body.source_log_id) is None:
        raise error(404, "not_found")
    n = KnowledgeNote(
        id=new_id(),
        title=body.title.strip(),
        text=body.text.strip(),
        tags=body.tags,
        enabled=body.enabled,
        source_log_id=body.source_log_id,
    )
    db.add(n)
    db.flush()
    db.add(KnowledgeChange(note_id=n.id, admin_id=a.user_id, action="create", after=_snapshot(n)))
    db.commit()
    return _note(n)


@router.patch("/knowledge/{note_id}")
def update_note(note_id: str, body: NotePatch, a: Admin, db: DbSession) -> dict:
    n = db.get(KnowledgeNote, note_id)
    if n is None:
        raise error(404, "not_found")
    before = _snapshot(n)
    for k, v in body.model_dump(exclude_unset=True).items():
        if v is not None:
            setattr(n, k, v.strip() if isinstance(v, str) else v)
    _safe(f"{n.title} {n.text}")
    if _snapshot(n) != before:
        n.updated_at = _now()
        db.add(
            KnowledgeChange(
                note_id=n.id, admin_id=a.user_id, action="update", before=before, after=_snapshot(n)
            )
        )
    db.commit()
    return _note(n)


@router.get("/knowledge/{note_id}/changes")
def note_changes(note_id: str, _: Admin, db: DbSession) -> list:
    return [
        {
            "action": ch.action,
            "before": ch.before,
            "after": ch.after,
            "at": ch.created_at.isoformat(),
        }
        for ch in db.scalars(
            select(KnowledgeChange)
            .where(KnowledgeChange.note_id == note_id)
            .order_by(KnowledgeChange.id)
        )
    ]
