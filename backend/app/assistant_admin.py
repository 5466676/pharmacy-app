"""«المساعد» in the admin panel, part 1: which model the assistant uses and
how it is doing.

The owner picks the server (LM Studio, Ollama or a hosted service), then a
model from the list that server offers, and its API key. A model is only
switched to after it answers. The key is never sent back."""

import time
from datetime import UTC, datetime, timedelta
from typing import Literal

import httpx
from fastapi import APIRouter, Request
from pydantic import BaseModel, Field
from sqlalchemy import Float, and_, func, select

from .admin import Admin
from .assistant import (
    PROVIDERS,
    ModelConfig,
    effective_config,
    encrypt_key,
    get_llm,
    make_llm,
)
from .consult.classifier import CATEGORIES, FORMAT, HEAD, RULE
from .consult.engine import ASSISTANT_TAIL, SAFETY_RULES, SUMMARY_HEAD, SUMMARY_TAIL, handle_message
from .consult.llm import ChatMessage, LLMUnavailable
from .deps import DbSession, error
from .models import AiLog, AssistantChange, AssistantConfig, PromptVersion, SafetyExample, User
from .prompts import DEFAULTS, KINDS, active_versions, examples, load_prompts, run_tests

router = APIRouter(prefix="/admin/assistant", tags=["admin"])

Provider = Literal["lm_studio", "ollama", "hosted"]


def _now() -> datetime:
    return datetime.now(UTC)


def _public(c: ModelConfig) -> dict:
    """The model as the panel sees it: never the key itself."""
    return {
        "provider": c.provider,
        "base_url": c.base_url,
        "model": c.model,
        "timeout_seconds": c.timeout,
        "has_key": bool(c.api_key),
        "source": c.source,
    }


@router.get("")
def assistant(_: Admin, db: DbSession, request: Request) -> dict:
    row = db.get(AssistantConfig, 1)
    by = db.get(User, row.updated_by) if row and row.updated_by else None
    return {
        **_public(effective_config(db, request.app.state.settings)),
        "updated_at": row.updated_at.isoformat() if row else None,
        "updated_by": by.name if by else None,
        "providers": PROVIDERS,
    }


class ProbeIn(BaseModel):
    provider: Provider
    base_url: str = Field(min_length=8, max_length=300)
    # None: the key already saved (when the address is the same).
    api_key: str | None = Field(default=None, max_length=500)


def _key_for(db, request: Request, base_url: str, api_key: str | None) -> str:
    if api_key is not None:
        return api_key.strip()
    current = effective_config(db, request.app.state.settings)
    return current.api_key if current.base_url.rstrip("/") == base_url.rstrip("/") else ""


@router.post("/models")
def list_models(body: ProbeIn, _: Admin, db: DbSession, request: Request) -> dict:
    """«اختر النموذج»: the models the chosen server offers (GET /models)."""
    key = _key_for(db, request, body.base_url, body.api_key)
    probe = getattr(request.app.state, "models_probe", None)  # tests
    try:
        if probe:
            ids = probe(body.base_url, key)
        else:
            r = httpx.get(
                body.base_url.rstrip("/") + "/models",
                headers={"authorization": f"Bearer {key}"} if key else {},
                timeout=15,
            )
            r.raise_for_status()
            ids = [m["id"] for m in r.json().get("data", []) if isinstance(m, dict) and "id" in m]
    except (httpx.HTTPError, ValueError, KeyError) as e:
        raise error(502, "server_unreachable") from e
    return {"models": sorted(set(ids))}


class ModelIn(ProbeIn):
    model: str = Field(min_length=1, max_length=200)
    timeout_seconds: int = Field(default=60, ge=5, le=300)


@router.put("/model")
def set_model(body: ModelIn, a: Admin, db: DbSession, request: Request) -> dict:
    """Switches only after the new model answers one short question.
    api_key: None keeps the saved one, "" removes it."""
    state = request.app.state
    before = effective_config(db, state.settings)
    config = ModelConfig(
        provider=body.provider,
        base_url=body.base_url.strip().rstrip("/"),
        model=body.model.strip(),
        api_key=_key_for(db, request, body.base_url, body.api_key),
        timeout=body.timeout_seconds,
        source="panel",
    )
    llm = getattr(state, "llm_factory", make_llm)(config)
    started = time.monotonic()
    try:
        llm.complete([ChatMessage("user", "قل: تمام")], temperature=0)
    except LLMUnavailable as e:
        raise error(400, "model_not_answering") from e
    ms = round((time.monotonic() - started) * 1000)
    row = db.get(AssistantConfig, 1) or AssistantConfig(id=1)
    row.provider, row.base_url, row.model = config.provider, config.base_url, config.model
    row.api_key_enc = (
        encrypt_key(state.settings.jwt_secret, config.api_key) if config.api_key else None
    )
    row.timeout_seconds, row.updated_by, row.updated_at = body.timeout_seconds, a.user_id, _now()
    db.add(row)
    db.add(
        AssistantChange(
            admin_id=a.user_id, kind="model", before=_public(before), after=_public(config)
        )
    )
    db.commit()
    state.llm = llm
    return {**_public(config), "ms": ms}


# ─── State ──────────────────────────────────────────────────────────────────


@router.get("/stats")
def stats(_: Admin, db: DbSession, hours: int = 24) -> dict:
    hours = max(1, min(hours, 24 * 90))
    since = _now() - timedelta(hours=hours)
    recent = AiLog.created_at > since
    counts = {
        k: n
        for k, n in db.execute(select(AiLog.kind, func.count()).where(recent).group_by(AiLog.kind))
    }
    source = AiLog.detail["source"].astext
    doctor = AiLog.detail["level"].astext == "doctor"
    rules, model, doctors = db.execute(
        select(
            func.count().filter(source == "rules"),
            func.count().filter(and_(source == "classifier", ~doctor)),
            func.count().filter(doctor),
        ).where(recent, AiLog.kind == "red_flag")
    ).one()
    ms = AiLog.detail["ms"].astext.cast(Float)
    replies = and_(recent, AiLog.kind == "assistant_reply", AiLog.detail.has_key("ms"))
    med, slow = db.execute(
        select(func.percentile_cont(0.5).within_group(ms), func.max(ms)).where(replies)
    ).one()
    last_down = db.scalar(select(func.max(AiLog.created_at)).where(AiLog.kind == "llm_down"))
    return {
        "hours": hours,
        "replies": counts.get("assistant_reply", 0),
        "down": counts.get("llm_down", 0),
        "guard_blocks": counts.get("guard_block", 0),
        "red_flags_rules": rules,
        "red_flags_model": model,
        "doctor_advice": doctors,
        "median_ms": round(med) if med is not None else None,
        "slowest_ms": round(slow) if slow is not None else None,
        "last_down_at": last_down.isoformat() if last_down else None,
    }


@router.get("/changes")
def changes(_: Admin, db: DbSession, kind: str | None = None) -> list:
    stmt = select(AssistantChange, User.name).join(User, User.id == AssistantChange.admin_id)
    if kind:
        stmt = stmt.where(AssistantChange.kind == kind)
    return [
        {
            "kind": c.kind,
            "before": c.before,
            "after": c.after,
            "by": name,
            "at": c.created_at.isoformat(),
        }
        for c, name in db.execute(stmt.order_by(AssistantChange.id.desc()).limit(100))
    ]


# ─── Prompts: draft → test → active, and one step back ──────────────────────

Kind = Literal["assistant", "summary", "classifier"]

# Shown read-only in the panel: always added by the server, never editable.
LOCKED = {
    "assistant": [SAFETY_RULES, ASSISTANT_TAIL.replace("{{", "{").replace("}}", "}")],
    "summary": [SUMMARY_HEAD, SUMMARY_TAIL],
    "classifier": [HEAD, RULE, FORMAT % ", ".join(CATEGORIES)],
}


def _version(v: PromptVersion) -> dict:
    return {
        "id": v.id,
        "kind": v.kind,
        "text": v.text,
        "note": v.note,
        "status": v.status,
        "test": v.test,
        "tested_at": v.tested_at.isoformat() if v.tested_at else None,
        "created_at": v.created_at.isoformat(),
        "activated_at": v.activated_at.isoformat() if v.activated_at else None,
        # Tested after its last edit, and passed: it may be activated.
        "ready": bool(
            v.test and v.test.get("passed") and v.tested_at and v.tested_at >= v.updated_at
        ),
    }


@router.get("/prompts")
def prompts(_: Admin, db: DbSession) -> dict:
    """Per kind: the text in use (a version or the built-in one), the fixed
    safety parts (read-only) and every version, newest first."""
    active = active_versions(db)
    out = {}
    for kind in KINDS:
        versions = db.scalars(
            select(PromptVersion)
            .where(PromptVersion.kind == kind)
            .order_by(PromptVersion.id.desc())
        )
        out[kind] = {
            "active_id": active[kind].id if kind in active else None,
            "text": active[kind].text if kind in active else DEFAULTS[kind],
            "default": DEFAULTS[kind],
            "locked": LOCKED[kind],
            "versions": [_version(v) for v in versions],
        }
    return out


class DraftIn(BaseModel):
    kind: Kind
    text: str = Field(min_length=20, max_length=8000)
    note: str | None = Field(default=None, max_length=300)


class DraftPatch(BaseModel):
    text: str | None = Field(default=None, min_length=20, max_length=8000)
    note: str | None = Field(default=None, max_length=300)


def _log(db, a, kind: str, before, after) -> None:
    db.add(AssistantChange(admin_id=a.user_id, kind=kind, before=before, after=after))


@router.post("/prompts")
def new_draft(body: DraftIn, a: Admin, db: DbSession) -> dict:
    v = PromptVersion(
        kind=body.kind, text=body.text.strip(), note=body.note, status="draft", created_by=a.user_id
    )
    db.add(v)
    db.commit()
    return _version(v)


def _draft(db, vid: int) -> PromptVersion:
    v = db.get(PromptVersion, vid)
    if v is None:
        raise error(404, "not_found")
    return v


@router.patch("/prompts/{vid}")
def edit_draft(vid: int, body: DraftPatch, _: Admin, db: DbSession) -> dict:
    """Only a draft changes; a change needs a new test."""
    v = _draft(db, vid)
    if v.status != "draft":
        raise error(409, "not_a_draft")
    if body.text is not None:
        v.text = body.text.strip()
    if body.note is not None:
        v.note = body.note
    v.updated_at = _now()
    db.commit()
    return _version(v)


@router.post("/prompts/{vid}/test")
def test_draft(vid: int, _: Admin, db: DbSession, request: Request) -> dict:
    """Runs the built-in cases and the owner's examples with this version in
    place of the active one."""
    v = _draft(db, vid)
    result = run_tests(get_llm(request), load_prompts(db, [v]), examples(db))
    v.test, v.tested_at = result, _now()
    db.commit()
    return _version(v)


@router.post("/prompts/{vid}/activate")
def activate(vid: int, a: Admin, db: DbSession) -> dict:
    v = _draft(db, vid)
    if v.status != "draft":
        raise error(409, "not_a_draft")
    if not _version(v)["ready"]:
        raise error(409, "test_not_passed")
    old = active_versions(db).get(v.kind)
    if old:
        old.status = "retired"
    v.status, v.activated_at = "active", _now()
    _log(
        db,
        a,
        "prompt",
        {"kind": v.kind, "version": f"v{old.id}" if old else "default"},
        {"kind": v.kind, "version": f"v{v.id}"},
    )
    db.commit()
    return _version(v)


@router.post("/prompts/{kind}/rollback")
def rollback(kind: Kind, a: Admin, db: DbSession) -> dict:
    """One step back: the version active before this one, or the built-in
    one. It was used with patients already, so it needs no new test."""
    current = active_versions(db).get(kind)
    if current is None:
        raise error(409, "already_default")
    current.status = "retired"
    previous = db.scalar(
        select(PromptVersion)
        .where(
            PromptVersion.kind == kind,
            PromptVersion.status == "retired",
            PromptVersion.id != current.id,
            PromptVersion.activated_at.is_not(None),
            PromptVersion.activated_at < current.activated_at,
        )
        .order_by(PromptVersion.activated_at.desc())
        .limit(1)
    )
    if previous:
        previous.status = "active"
    _log(
        db,
        a,
        "prompt",
        {"kind": kind, "version": f"v{current.id}"},
        {"kind": kind, "version": f"v{previous.id}" if previous else "default"},
    )
    db.commit()
    return {"kind": kind, "active_id": previous.id if previous else None}


# ─── Safety examples ────────────────────────────────────────────────────────

Label = Literal["emergency", "doctor", "normal"]


class ExampleIn(BaseModel):
    text: str = Field(min_length=3, max_length=1000)
    label: Label
    note: str | None = Field(default=None, max_length=300)


class ExamplePatch(BaseModel):
    text: str | None = Field(default=None, min_length=3, max_length=1000)
    label: Label | None = None
    note: str | None = Field(default=None, max_length=300)
    enabled: bool | None = None


def _example(e: SafetyExample) -> dict:
    return {
        "id": e.id,
        "text": e.text,
        "label": e.label,
        "note": e.note,
        "enabled": e.enabled,
        "created_at": e.created_at.isoformat(),
    }


def _snap(e: SafetyExample) -> dict:
    return {"text": e.text, "label": e.label, "note": e.note, "enabled": e.enabled}


@router.get("/examples")
def list_examples(_: Admin, db: DbSession) -> list:
    return [
        _example(e) for e in db.scalars(select(SafetyExample).order_by(SafetyExample.id.desc()))
    ]


@router.post("/examples")
def add_example(body: ExampleIn, a: Admin, db: DbSession) -> dict:
    e = SafetyExample(
        text=body.text.strip(), label=body.label, note=body.note, created_by=a.user_id
    )
    db.add(e)
    db.flush()
    _log(db, a, "example", None, {"id": e.id, **_snap(e)})
    db.commit()
    return _example(e)


@router.patch("/examples/{eid}")
def edit_example(eid: int, body: ExamplePatch, a: Admin, db: DbSession) -> dict:
    e = db.get(SafetyExample, eid)
    if e is None:
        raise error(404, "not_found")
    before = _snap(e)
    for k, v in body.model_dump(exclude_unset=True).items():
        if v is not None:
            setattr(e, k, v.strip() if isinstance(v, str) else v)
    if _snap(e) != before:
        _log(db, a, "example", {"id": e.id, **before}, {"id": e.id, **_snap(e)})
    db.commit()
    return _example(e)


@router.post("/test")
def test_current(_: Admin, db: DbSession, request: Request) -> dict:
    """The prompts in use against the built-in cases and the examples."""
    return run_tests(get_llm(request), load_prompts(db), examples(db))


# ─── Sandbox: chat as a patient, with drafts, nothing saved ─────────────────


class SandboxLine(BaseModel):
    role: Literal["patient", "assistant"]
    text: str = Field(max_length=2000)


class SandboxIn(BaseModel):
    history: list[SandboxLine] = Field(default=[], max_length=30)
    text: str = Field(min_length=1, max_length=2000)
    # Draft ids to use in place of the active versions.
    drafts: list[int] = Field(default=[], max_length=3)


@router.post("/sandbox")
def sandbox(body: SandboxIn, _: Admin, db: DbSession, request: Request) -> dict:
    drafts = [_draft(db, d) for d in body.drafts]
    history = [
        ChatMessage("user" if m.role == "patient" else "assistant", m.text) for m in body.history
    ]
    turn = handle_message(get_llm(request), history, body.text, prompts=load_prompts(db, drafts))
    return {
        "kind": turn.kind,
        "text": turn.text,
        "quick_replies": turn.quick_replies,
        "red_flag": turn.red_flag.category if turn.red_flag else None,
        "red_flag_source": turn.red_flag_source,
        "summary": turn.summary.model_dump() if turn.summary else None,
        "guard_blocked": any(e.kind == "guard_block" for e in turn.logs),
    }
