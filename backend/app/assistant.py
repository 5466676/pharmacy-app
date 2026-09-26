"""The assistant's model, as the owner chose it in the panel or, until then,
as the server's settings say (DOAYA_LLM_*).

The API key is encrypted with a key derived from the server's own secret,
so a copy of the database alone doesn't reveal it."""

import base64
import hashlib
from dataclasses import dataclass

from cryptography.fernet import Fernet, InvalidToken
from fastapi import Request
from sqlalchemy.orm import Session

from .consult.llm import LLM, OpenAICompatibleLLM
from .models import AssistantConfig

# What «اختر المخدم» offers, and where each usually listens.
PROVIDERS = {
    "lm_studio": "http://localhost:1234/v1",
    "ollama": "http://localhost:11434/v1",
    "hosted": "",
}


@dataclass(frozen=True)
class ModelConfig:
    provider: str
    base_url: str
    model: str
    api_key: str
    timeout: float
    # panel | settings
    source: str


def _fernet(secret: str) -> Fernet:
    key = hashlib.sha256(("doaya-llm-key|" + secret).encode()).digest()
    return Fernet(base64.urlsafe_b64encode(key))


def encrypt_key(secret: str, api_key: str) -> str:
    return _fernet(secret).encrypt(api_key.encode()).decode()


def decrypt_key(secret: str, token: str | None) -> str:
    """Empty when there is none, or it was made with another server secret."""
    if not token:
        return ""
    try:
        return _fernet(secret).decrypt(token.encode()).decode()
    except InvalidToken:
        return ""


def _guess_provider(base_url: str) -> str:
    for name, url in PROVIDERS.items():
        if url and base_url.rstrip("/") == url:
            return name
    return "hosted"


def effective_config(db: Session, settings) -> ModelConfig:
    row = db.get(AssistantConfig, 1)
    if row is None:
        return ModelConfig(
            provider=_guess_provider(settings.llm_base_url),
            base_url=settings.llm_base_url,
            model=settings.llm_model,
            api_key=settings.llm_api_key,
            timeout=settings.llm_timeout_seconds,
            source="settings",
        )
    return ModelConfig(
        provider=row.provider,
        base_url=row.base_url,
        model=row.model,
        api_key=decrypt_key(settings.jwt_secret, row.api_key_enc),
        timeout=row.timeout_seconds,
        source="panel",
    )


def make_llm(config: ModelConfig) -> LLM:
    return OpenAICompatibleLLM(
        config.base_url, config.model, api_key=config.api_key, timeout=config.timeout
    )


def get_llm(request: Request) -> LLM:
    """The model in use, made once (tests put a scripted one on app.state;
    a change in the panel clears it)."""
    state = request.app.state
    if getattr(state, "llm", None) is None:
        with state.db.sessions() as db:
            config = effective_config(db, state.settings)
        state.llm = getattr(state, "llm_factory", make_llm)(config)
    return state.llm
