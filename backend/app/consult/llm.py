"""The language model behind an OpenAI-compatible chat API: a hosted
service, LM Studio or Ollama, chosen by settings (DOAYA_LLM_*). Nothing here
knows which one it is."""

import json
import re
from collections.abc import Callable, Sequence
from dataclasses import dataclass, field
from typing import Literal, Protocol

import httpx

Role = Literal["system", "user", "assistant"]


@dataclass(frozen=True)
class ChatMessage:
    role: Role
    content: str


class LLMUnavailable(Exception):
    """The model didn't answer (off, overloaded, timed out, bad reply)."""


class LLM(Protocol):
    model: str

    def complete(
        self, messages: Sequence[ChatMessage], *, json_mode: bool = False, temperature: float = 0.2
    ) -> str: ...


class OpenAICompatibleLLM:
    """POST {base_url}/chat/completions. LM Studio: http://localhost:1234/v1,
    Ollama: http://localhost:11434/v1."""

    def __init__(
        self,
        base_url: str,
        model: str,
        api_key: str = "",
        timeout: float = 60,
        transport: httpx.BaseTransport | None = None,
    ) -> None:
        self.model = model
        headers = {"authorization": f"Bearer {api_key}"} if api_key else {}
        self._client = httpx.Client(
            base_url=base_url.rstrip("/") + "/",
            headers=headers,
            timeout=timeout,
            transport=transport,
        )

    def complete(
        self, messages: Sequence[ChatMessage], *, json_mode: bool = False, temperature: float = 0.2
    ) -> str:
        body: dict = {
            "model": self.model,
            "messages": [{"role": m.role, "content": m.content} for m in messages],
            "temperature": temperature,
            "stream": False,
        }
        if json_mode:
            # Not every local server supports response_format; the prompt
            # asks for JSON too, and parse_json() digs it out of prose.
            body["response_format"] = {"type": "json_object"}
        try:
            r = self._client.post("chat/completions", json=body)
            if r.status_code == 400 and json_mode:
                body.pop("response_format")
                r = self._client.post("chat/completions", json=body)
            r.raise_for_status()
            content = r.json()["choices"][0]["message"]["content"]
        except (httpx.HTTPError, KeyError, IndexError, TypeError, ValueError) as e:
            raise LLMUnavailable(str(e)) from e
        if not isinstance(content, str) or not content.strip():
            raise LLMUnavailable("empty reply")
        return _strip_thinking(content)


def llm_from_settings(settings) -> OpenAICompatibleLLM:
    return OpenAICompatibleLLM(
        settings.llm_base_url,
        settings.llm_model,
        api_key=settings.llm_api_key,
        timeout=settings.llm_timeout_seconds,
    )


def _strip_thinking(text: str) -> str:
    """Reasoning models (Qwen, DeepSeek) may prefix <think>…</think>."""
    return re.sub(r"<think>.*?</think>", "", text, flags=re.S).strip()


def parse_json(text: str) -> dict | None:
    """The first JSON object in a reply, even wrapped in prose or ```json."""
    start = text.find("{")
    while start != -1:
        depth = 0
        for i in range(start, len(text)):
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
                if depth == 0:
                    try:
                        value = json.loads(text[start : i + 1])
                    except json.JSONDecodeError:
                        break
                    return value if isinstance(value, dict) else None
        start = text.find("{", start + 1)
    return None


@dataclass
class ScriptedLLM:
    """A stand-in model for tests: answers from [replies] in order (or from
    [respond]), raising LLMUnavailable for an Exception entry; records
    every call."""

    replies: list[str | Exception] = field(default_factory=list)
    respond: Callable[[Sequence[ChatMessage], bool], str] | None = None
    model: str = "scripted"
    calls: list[tuple[list[ChatMessage], bool]] = field(default_factory=list)

    def complete(
        self, messages: Sequence[ChatMessage], *, json_mode: bool = False, temperature: float = 0.2
    ) -> str:
        self.calls.append((list(messages), json_mode))
        if self.respond is not None:
            return self.respond(messages, json_mode)
        if not self.replies:
            raise LLMUnavailable("no scripted reply left")
        r = self.replies.pop(0)
        if isinstance(r, Exception):
            raise LLMUnavailable(str(r))
        return r
