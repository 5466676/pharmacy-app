"""«ملف المريض»: one health file per patient, kept on the central server.

- The patient sees all of it, adds and ends their own facts, confirms
  proposals about themselves, exports it, or deletes it.
- The pharmacy the patient chose sees it, adds and confirms medical facts.
  A pharmacy the patient left keeps only its own past cases.
- The platform owner sees it too (owner's decision); every opening is
  logged.
- The assistant never writes the file: what a chat reveals becomes a
  proposal someone confirms. The pharmacist's decision adds the medicines.

Nothing exists without the patient's consent."""

from datetime import UTC, date, datetime, timedelta
from typing import Literal

from fastapi import APIRouter, Request
from pydantic import BaseModel, Field
from sqlalchemy import delete, func, or_, select
from sqlalchemy.orm import Session

from .admin import Admin
from .consult.redflags import normalize
from .deps import DbSession, Patient, PharmacyCaller, error
from .models import (
    Consultation,
    FileAccess,
    FileChange,
    FileProposal,
    HealthFact,
    PatientOrder,
    PatientProfile,
    Pharmacy,
    User,
)
from .security import new_id

router = APIRouter(tags=["health file"])

Kind = Literal["allergy", "condition", "medication", "pregnancy", "weight", "note"]
# Medical facts a pharmacist confirms; the patient confirms the rest.
MEDICAL = {"allergy", "condition", "medication"}
# Summary field → fact kind.
FROM_SUMMARY = {
    "allergies": "allergy",
    "conditions": "condition",
    "medications": "medication",
    "pregnancy": "pregnancy",
}
# Summary answers that mean "nothing".
NOTHING = {
    normalize(w)
    for w in (
        "لا",
        "ما في",
        "مافي",
        "ما في شي",
        "لا يوجد",
        "ولا شي",
        "ولا شيء",
        "ما عندي",
        "ماعندي",
        "لأ",
        "no",
        "none",
        "null",
        "غير معروف",
        "مو معروف",
        "لا شيء",
    )
}


def _now() -> datetime:
    return datetime.now(UTC)


def _log(db: Session, patient_id: str, actor: str, name: str | None, action: str, **detail):
    db.add(
        FileChange(
            patient_id=patient_id, actor=actor, actor_name=name, action=action, detail=detail
        )
    )


def _active(f: HealthFact, now: datetime) -> bool:
    return f.ended_at is None and (f.ends_at is None or f.ends_at > now)


def _fact(f: HealthFact, now: datetime) -> dict:
    return {
        "id": f.id,
        "kind": f.kind,
        "text": f.text,
        "detail": f.detail,
        "source": f.source,
        "confirmed": f.confirmed,
        "added_by": f.added_by,
        "created_at": f.created_at.isoformat(),
        "ends_at": f.ends_at.isoformat() if f.ends_at else None,
        "ended_at": f.ended_at.isoformat() if f.ended_at else None,
        "active": _active(f, now),
    }


def _proposal(p: FileProposal) -> dict:
    return {
        "id": p.id,
        "kind": p.kind,
        "text": p.text,
        "needs": p.needs,
        "status": p.status,
        "consultation_id": p.consultation_id,
        "created_at": p.created_at.isoformat(),
    }


def has_file(db: Session, patient_id: str) -> bool:
    prof = db.get(PatientProfile, patient_id)
    return bool(prof and prof.file_consent_at)


def active_facts(db: Session, patient_id: str) -> list[HealthFact]:
    now = _now()
    return [
        f
        for f in db.scalars(
            select(HealthFact)
            .where(HealthFact.patient_id == patient_id)
            .order_by(HealthFact.created_at)
        )
        if _active(f, now)
    ]


def file_out(db: Session, patient_id: str, *, history_for: str | None = None) -> dict:
    """The whole file. [history_for]: only this pharmacy's cases in the
    history (a pharmacy the patient left)."""
    now = _now()
    user, prof = db.get(User, patient_id), db.get(PatientProfile, patient_id)
    facts = db.scalars(
        select(HealthFact)
        .where(HealthFact.patient_id == patient_id)
        .order_by(HealthFact.created_at.desc())
    ).all()
    proposals = db.scalars(
        select(FileProposal)
        .where(FileProposal.patient_id == patient_id, FileProposal.status == "pending")
        .order_by(FileProposal.created_at)
    ).all()
    cases = select(Consultation).where(
        Consultation.patient_id == patient_id, Consultation.sent_at.is_not(None)
    )
    orders = select(PatientOrder).where(PatientOrder.patient_id == patient_id)
    if history_for:
        cases = cases.where(Consultation.pharmacy_id == history_for)
        orders = orders.where(PatientOrder.pharmacy_id == history_for)
    names = {p.id: p.name for p in db.scalars(select(Pharmacy))}
    return {
        "patient": {
            "id": user.id,
            "name": user.name,
            "phone": user.phone,
            "age": date.today().year - prof.birth_year if prof and prof.birth_year else None,
            "sex": prof.sex if prof else None,
            "city": prof.city if prof else None,
        },
        "consent_at": prof.file_consent_at.isoformat() if prof and prof.file_consent_at else None,
        "facts": [_fact(f, now) for f in facts if _active(f, now)],
        "past_facts": [_fact(f, now) for f in facts if not _active(f, now)],
        "proposals": [_proposal(p) for p in proposals],
        "history": [
            {
                "id": c.id,
                "pharmacy": names.get(c.pharmacy_id),
                "sent_at": c.sent_at.isoformat(),
                "status": c.status,
                "urgent": c.urgent,
                "red_flag": c.red_flag,
                "doctor_advice": c.doctor_advice,
                "summary": c.summary,
                "decision": c.decision,
            }
            for c in db.scalars(cases.order_by(Consultation.sent_at.desc()).limit(100))
        ],
        "orders": [
            {
                "id": o.id,
                "pharmacy": names.get(o.pharmacy_id),
                "status": o.status,
                "lines": o.lines,
                "created_at": o.created_at.isoformat(),
            }
            for o in db.scalars(orders.order_by(PatientOrder.created_at.desc()).limit(100))
        ],
    }


# ─── Filled from consultations (called by consultations.py) ─────────────────


def _meaningful(text: str | None) -> str | None:
    if not text or not isinstance(text, str):
        return None
    t = text.strip()
    return None if not t or normalize(t) in NOTHING else t[:300]


def _known(db: Session, patient_id: str, kind: str, text: str) -> bool:
    n = normalize(text)
    for f in active_facts(db, patient_id):
        if f.kind == kind and normalize(f.text) == n:
            return True
    return bool(
        db.scalar(
            select(func.count()).where(
                FileProposal.patient_id == patient_id,
                FileProposal.kind == kind,
                FileProposal.status == "pending",
                FileProposal.text == text,
            )
        )
    )


def propose_from_summary(db: Session, c: Consultation) -> int:
    """New allergies, conditions, medicines and pregnancy the chat revealed
    become proposals (never facts). Returns how many."""
    if not c.summary or not has_file(db, c.patient_id):
        return 0
    n = 0
    for field, kind in FROM_SUMMARY.items():
        text = _meaningful(c.summary.get(field))
        if text is None or _known(db, c.patient_id, kind, text):
            continue
        db.add(
            FileProposal(
                id=new_id(),
                patient_id=c.patient_id,
                consultation_id=c.id,
                kind=kind,
                text=text,
                needs="pharmacist" if kind in MEDICAL else "patient",
            )
        )
        n += 1
    if n:
        _log(db, c.patient_id, "system", None, "proposed", consultation_id=c.id, count=n)
    return n


def medicines_from_decision(db: Session, c: Consultation, actor: str | None) -> None:
    """The pharmacist's decision: each medicine becomes a current medicine,
    ending by itself after its days."""
    if not c.decision or not has_file(db, c.patient_id):
        return
    now = _now()
    for item in c.decision.get("items", []):
        days = item.get("days")
        db.add(
            HealthFact(
                id=new_id(),
                patient_id=c.patient_id,
                kind="medication",
                text=item["name"][:300],
                detail={
                    "instructions": item.get("instructions"),
                    "times_per_day": item.get("times_per_day"),
                    "days": days,
                },
                source="pharmacist",
                confirmed=True,
                added_by=actor,
                pharmacy_id=c.pharmacy_id,
                consultation_id=c.id,
                ends_at=now + timedelta(days=days) if days else None,
            )
        )
    _log(db, c.patient_id, "pharmacist", actor, "decision", consultation_id=c.id)


def profile_lines(db: Session, patient_id: str) -> list[str]:
    """What the assistant is told, so it doesn't ask again: facts only,
    never a dose."""
    if not has_file(db, patient_id):
        return []
    labels = {
        "allergy": "allergic to",
        "condition": "condition",
        "medication": "takes",
        "pregnancy": "pregnancy",
        "weight": "weight",
    }
    return [f"{labels[f.kind]}: {f.text}" for f in active_facts(db, patient_id) if f.kind in labels]


# ─── The patient ────────────────────────────────────────────────────────────


class ConsentIn(BaseModel):
    consent: bool


class FactIn(BaseModel):
    kind: Kind
    text: str = Field(min_length=1, max_length=300)


class DecisionIn(BaseModel):
    accept: bool


def _me(db: Session, p) -> str:
    if not has_file(db, p.user_id):
        raise error(409, "no_consent")
    return p.user_id


@router.post("/patients/me/consent")
def consent(body: ConsentIn, p: Patient, db: DbSession) -> dict:
    prof = db.get(PatientProfile, p.user_id) or PatientProfile(user_id=p.user_id)
    db.add(prof)
    if body.consent and not prof.file_consent_at:
        prof.file_consent_at = _now()
        _log(db, p.user_id, "patient", None, "consent")
    elif not body.consent and prof.file_consent_at:
        _delete_file(db, p.user_id)
    db.commit()
    return {"consent_at": prof.file_consent_at.isoformat() if prof.file_consent_at else None}


@router.get("/patients/me/file")
def my_file(p: Patient, db: DbSession) -> dict:
    return file_out(db, _me(db, p))


@router.post("/patients/me/file/facts")
def add_my_fact(body: FactIn, p: Patient, db: DbSession) -> dict:
    pid = _me(db, p)
    f = HealthFact(
        id=new_id(),
        patient_id=pid,
        kind=body.kind,
        text=body.text.strip(),
        source="patient",
        confirmed=False,
        added_by=db.get(User, pid).name,
    )
    db.add(f)
    _log(db, pid, "patient", f.added_by, "add", fact=f.id, kind=f.kind, text=f.text)
    db.commit()
    return _fact(f, _now())


def _end(db: Session, pid: str, fid: str, actor: str, name: str | None) -> HealthFact:
    f = db.get(HealthFact, fid)
    if f is None or f.patient_id != pid:
        raise error(404, "not_found")
    if f.ended_at is None:
        f.ended_at = _now()
        _log(db, pid, actor, name, "end", fact=f.id, kind=f.kind, text=f.text)
    db.commit()
    return f


@router.post("/patients/me/file/facts/{fid}/end")
def end_my_fact(fid: str, p: Patient, db: DbSession) -> dict:
    pid = _me(db, p)
    return _fact(_end(db, pid, fid, "patient", db.get(User, pid).name), _now())


def _decide(db: Session, pid: str, prop_id: str, accept: bool, who: str, name, needs: str, **fact):
    prop = db.get(FileProposal, prop_id)
    if prop is None or prop.patient_id != pid or prop.status != "pending":
        raise error(404, "not_found")
    if prop.needs != needs:
        raise error(403, f"{prop.needs}_decides")
    prop.status = "accepted" if accept else "rejected"
    prop.decided_by, prop.decided_at = name, _now()
    if accept:
        db.add(
            HealthFact(
                id=new_id(),
                patient_id=pid,
                kind=prop.kind,
                text=prop.text,
                source=who,
                confirmed=who == "pharmacist",
                added_by=name,
                consultation_id=prop.consultation_id,
                **fact,
            )
        )
    _log(db, pid, who, name, prop.status, proposal=prop.id, kind=prop.kind, text=prop.text)
    db.commit()
    return _proposal(prop)


@router.post("/patients/me/file/proposals/{prop_id}")
def decide_mine(prop_id: str, body: DecisionIn, p: Patient, db: DbSession) -> dict:
    pid = _me(db, p)
    return _decide(db, pid, prop_id, body.accept, "patient", db.get(User, pid).name, "patient")


@router.get("/patients/me/file/export")
def export_mine(p: Patient, db: DbSession) -> dict:
    """Everything, with the change log: the patient's own copy."""
    pid = _me(db, p)
    changes = db.scalars(
        select(FileChange).where(FileChange.patient_id == pid).order_by(FileChange.id)
    )
    _log(db, pid, "patient", None, "export")
    db.commit()
    return {
        **file_out(db, pid),
        "exported_at": _now().isoformat(),
        "changes": [
            {
                "actor": c.actor,
                "name": c.actor_name,
                "action": c.action,
                "detail": c.detail,
                "at": c.created_at.isoformat(),
            }
            for c in changes
        ],
    }


def _delete_file(db: Session, pid: str) -> None:
    """The facts, proposals and change log go; the consultations stay with
    the pharmacy as its records, outside any file."""
    db.execute(delete(HealthFact).where(HealthFact.patient_id == pid))
    db.execute(delete(FileProposal).where(FileProposal.patient_id == pid))
    db.execute(delete(FileChange).where(FileChange.patient_id == pid))
    db.get(PatientProfile, pid).file_consent_at = None


@router.delete("/patients/me/file")
def delete_mine(p: Patient, db: DbSession) -> dict:
    _delete_file(db, _me(db, p))
    db.commit()
    return {"deleted": True}


# ─── The patient's pharmacy ─────────────────────────────────────────────────


class PharmacyFactIn(FactIn):
    detail: dict | None = None


def _theirs(db: Session, caller, pid: str) -> str:
    """The file, for the pharmacy the patient chose now."""
    prof = db.get(PatientProfile, pid)
    if prof is None:
        raise error(404, "patient_not_found")
    if prof.pharmacy_id != caller.pharmacy_id:
        raise error(403, "not_your_patient")
    if not prof.file_consent_at:
        raise error(409, "no_consent")
    return pid


@router.get("/pharmacy-api/patients/{pid}/file")
def patient_file(pid: str, caller: PharmacyCaller, db: DbSession) -> dict:
    prof = db.get(PatientProfile, pid)
    if (
        prof
        and prof.pharmacy_id != caller.pharmacy_id
        and db.scalar(
            select(func.count()).where(
                Consultation.patient_id == pid, Consultation.pharmacy_id == caller.pharmacy_id
            )
        )
    ):
        # A pharmacy the patient left: only its own past cases.
        out = file_out(db, pid, history_for=caller.pharmacy_id)
        return {**out, "facts": [], "past_facts": [], "proposals": [], "limited": True}
    return {**file_out(db, _theirs(db, caller, pid)), "limited": False}


@router.post("/pharmacy-api/patients/{pid}/file/facts")
def add_fact(pid: str, body: PharmacyFactIn, caller: PharmacyCaller, db: DbSession) -> dict:
    _theirs(db, caller, pid)
    f = HealthFact(
        id=new_id(),
        patient_id=pid,
        kind=body.kind,
        text=body.text.strip(),
        detail=body.detail,
        source="pharmacist",
        confirmed=True,
        added_by=caller.actor,
        pharmacy_id=caller.pharmacy_id,
    )
    db.add(f)
    _log(db, pid, "pharmacist", caller.actor, "add", fact=f.id, kind=f.kind, text=f.text)
    db.commit()
    return _fact(f, _now())


@router.post("/pharmacy-api/patients/{pid}/file/facts/{fid}/end")
def end_fact(pid: str, fid: str, caller: PharmacyCaller, db: DbSession) -> dict:
    _theirs(db, caller, pid)
    return _fact(_end(db, pid, fid, "pharmacist", caller.actor), _now())


@router.post("/pharmacy-api/patients/{pid}/file/facts/{fid}/confirm")
def confirm_fact(pid: str, fid: str, caller: PharmacyCaller, db: DbSession) -> dict:
    """A fact the patient reported, checked by the pharmacist."""
    _theirs(db, caller, pid)
    f = db.get(HealthFact, fid)
    if f is None or f.patient_id != pid:
        raise error(404, "not_found")
    if not f.confirmed:
        f.confirmed = True
        _log(db, pid, "pharmacist", caller.actor, "confirm", fact=f.id, kind=f.kind, text=f.text)
    db.commit()
    return _fact(f, _now())


@router.post("/pharmacy-api/patients/{pid}/file/proposals/{prop_id}")
def decide_proposal(
    pid: str, prop_id: str, body: DecisionIn, caller: PharmacyCaller, db: DbSession
) -> dict:
    _theirs(db, caller, pid)
    return _decide(
        db,
        pid,
        prop_id,
        body.accept,
        "pharmacist",
        caller.actor,
        "pharmacist",
        pharmacy_id=caller.pharmacy_id,
    )


# ─── The platform owner ─────────────────────────────────────────────────────


@router.get("/admin/patients")
def patients(_: Admin, db: DbSession, q: str | None = None, limit: int = 100) -> list:
    stmt = (
        select(User, PatientProfile)
        .join(PatientProfile, PatientProfile.user_id == User.id, isouter=True)
        .where(User.role == "patient")
    )
    if q and q.strip():
        like = f"%{q.strip()}%"
        stmt = stmt.where(or_(User.name.ilike(like), User.phone.ilike(like)))
    names = {p.id: p.name for p in db.scalars(select(Pharmacy))}
    counts = {
        pid: n
        for pid, n in db.execute(
            select(Consultation.patient_id, func.count())
            .where(Consultation.sent_at.is_not(None))
            .group_by(Consultation.patient_id)
        )
    }
    rows = db.execute(stmt.order_by(User.created_at.desc()).limit(max(1, min(limit, 500))))
    return [
        {
            "id": u.id,
            "name": u.name,
            "phone": u.phone,
            "age": date.today().year - prof.birth_year if prof and prof.birth_year else None,
            "sex": prof.sex if prof else None,
            "city": prof.city if prof else None,
            "pharmacy": names.get(prof.pharmacy_id) if prof else None,
            "cases": counts.get(u.id, 0),
            "has_file": bool(prof and prof.file_consent_at),
            "created_at": u.created_at.isoformat(),
        }
        for u, prof in rows
    ]


@router.get("/admin/patients/{pid}/file")
def admin_file(pid: str, a: Admin, db: DbSession, request: Request) -> dict:
    """Logged every time (owner's decision: he sees everything, and it is
    on record)."""
    user = db.get(User, pid)
    if user is None or user.role != "patient":
        raise error(404, "patient_not_found")
    db.add(FileAccess(admin_id=a.user_id, patient_id=pid))
    db.commit()
    opened = db.execute(
        select(FileAccess.created_at, User.name)
        .join(User, User.id == FileAccess.admin_id)
        .where(FileAccess.patient_id == pid)
        .order_by(FileAccess.id.desc())
        .limit(20)
    ).all()
    return {
        **file_out(db, pid),
        "opened": [{"by": name, "at": at.isoformat()} for at, name in opened],
    }
