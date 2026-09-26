"""On a pharmacy's own server: its devices reach their cases and orders on
the central server through here. They stay signed in to their own server
only; this server adds its pharmacy key and the pharmacist's name. Selling
never depends on it: with no internet these calls fail and nothing else
does."""

import json
from pathlib import Path
from urllib.parse import quote

import anyio
import httpx
from fastapi import APIRouter, Request, Response
from pydantic import BaseModel, Field

from .bridge import ShelfPublisher
from .config import Settings
from .deps import Caller, DbSession, Owner, error
from .models import User

router = APIRouter(prefix="/central", tags=["central"])
link_router = APIRouter(prefix="/central-link", tags=["central"])

# ─── The link itself (owner, from the app) ──────────────────────────────────
# Kept in <data_dir>/central.json so the owner can set it from the app;
# DOAYA_CENTRAL_URL / _KEY in the environment win when set.


def _link_file(settings: Settings) -> Path:
    return Path(settings.data_dir) / "central.json"


def load_central_link(settings: Settings) -> Settings:
    if settings.central_url and settings.central_key:
        return settings
    f = _link_file(settings)
    if not f.exists():
        return settings
    data = json.loads(f.read_text())
    return settings.model_copy(update={"central_url": data["url"], "central_key": data["key"]})


def restart_publisher(app) -> None:
    """(Re)starts the shelf publisher on the real server once linked."""
    state = app.state
    if state.shelf_publisher:
        state.shelf_publisher.stop()
        state.shelf_publisher = None
    s = state.settings
    if state.runs_publisher and s.central_url and s.central_key:
        state.shelf_publisher = ShelfPublisher(
            s, state.db.sessions, every=s.shelf_publish_minutes * 60
        ).start()


class LinkIn(BaseModel):
    url: str = Field(min_length=8, max_length=300)
    key: str = Field(min_length=8, max_length=200)


@link_router.get("")
def link_state(_: Caller, request: Request) -> dict:
    s = request.app.state.settings
    pub = request.app.state.shelf_publisher
    return {
        "linked": bool(s.central_url and s.central_key),
        "url": s.central_url or None,
        "last_published": pub.last_published if pub else None,
        "error": pub.last_error if pub else None,
    }


@link_router.put("")
def set_link(body: LinkIn, _: Owner, request: Request) -> dict:
    """Checks the key with the central server, then keeps it."""
    url = body.url.strip().rstrip("/")
    key = body.key.strip()
    probe = getattr(request.app.state, "central_probe", None)  # tests
    client = probe(url) if probe else httpx.Client(base_url=url, timeout=20)
    try:
        r = client.get("/pharmacy-api/updates", headers={"authorization": f"Pharmacy {key}"})
    except httpx.HTTPError as e:
        raise error(502, "central_unreachable") from e
    finally:
        if not probe:
            client.close()
    if r.status_code in (401, 403):
        raise error(400, "bad_pharmacy_key")
    if r.status_code != 200:
        raise error(502, "central_unreachable")
    state = request.app.state
    f = _link_file(state.settings)
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text(json.dumps({"url": url, "key": key}))
    f.chmod(0o600)
    state.settings = state.settings.model_copy(update={"central_url": url, "central_key": key})
    state.central_client = None
    restart_publisher(request.app)
    return {"linked": True, "url": url}


@link_router.delete("")
def remove_link(_: Owner, request: Request) -> dict:
    state = request.app.state
    _link_file(state.settings).unlink(missing_ok=True)
    state.settings = state.settings.model_copy(update={"central_url": "", "central_key": ""})
    state.central_client = None
    restart_publisher(request.app)
    return {"linked": False}


# ─── Forwarding for the pharmacy's devices ─────────────────────────────────

# Only the pharmacy side of the central API, nothing else.
ALLOWED = ("cases", "orders", "updates", "photos")


def _client(request: Request) -> httpx.Client:
    state = request.app.state
    if getattr(state, "central_client", None) is None:
        state.central_client = httpx.Client(base_url=state.settings.central_url, timeout=30)
    return state.central_client


@router.api_route("/{path:path}", methods=["GET", "POST", "PUT"])
async def forward(path: str, request: Request, caller: Caller, db: DbSession) -> Response:
    settings = request.app.state.settings
    if not settings.central_url or not settings.central_key:
        raise error(503, "central_not_configured")
    if path.split("/")[0] not in ALLOWED:
        raise error(404, "not_found")
    user = db.get(User, caller.user_id)
    body = await request.body()
    headers = {
        "authorization": f"Pharmacy {settings.central_key}",
        "x-doaya-actor": quote(user.name if user else ""),
        "content-type": request.headers.get("content-type", "application/json"),
    }

    def send() -> httpx.Response:
        return _client(request).request(
            request.method,
            f"/pharmacy-api/{path}",
            params=request.query_params,
            content=body or None,
            headers=headers,
        )

    try:
        r = await anyio.to_thread.run_sync(send)
    except httpx.HTTPError as e:
        raise error(503, "central_unreachable") from e
    # JSON, or a prescription photo's own type.
    return Response(
        r.content,
        status_code=r.status_code,
        media_type=r.headers.get("content-type", "application/json"),
    )
