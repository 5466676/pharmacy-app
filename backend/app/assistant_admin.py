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
from .assistant import PROVIDERS, ModelConfig, effective_config, encrypt_key, make_llm
from .consult.llm import ChatMessage, LLMUnavailable
from .deps import DbSession, error
from .models import AiLog, AssistantChange, AssistantConfig, User

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
    rules, model = db.execute(
        select(
            func.count().filter(source == "rules"), func.count().filter(source == "classifier")
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
