"""On a pharmacy's own server: its devices reach their cases and orders on
the central server through here. They stay signed in to their own server
only; this server adds its pharmacy key and the pharmacist's name. Selling
never depends on it: with no internet these calls fail and nothing else
does."""

from urllib.parse import quote

import anyio
import httpx
from fastapi import APIRouter, Request, Response

from .deps import Caller, DbSession, error
from .models import User

router = APIRouter(prefix="/central", tags=["central"])

# Only the pharmacy side of the central API, nothing else.
ALLOWED = ("cases", "orders", "updates")


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
    return Response(r.content, status_code=r.status_code, media_type="application/json")
