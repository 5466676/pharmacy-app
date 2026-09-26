"""What changed since a client last looked (phones check this in the
background, without Google's push), and a WebSocket for live updates while
an app is open."""

import asyncio
import contextlib
from datetime import UTC, datetime

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from sqlalchemy import select

from .deps import DbSession, Patient, PharmacyCaller, current_pharmacy_server, error
from .events import patient_topic, pharmacy_topic
from .models import Consultation, PatientOrder
from .security import read_access_token

router = APIRouter(tags=["updates"])


def _changes(db, where_c, where_o, since: datetime | None) -> dict:
    cq = select(Consultation.id, Consultation.status, Consultation.urgent, Consultation.updated_at)
    oq = select(PatientOrder.id, PatientOrder.status, PatientOrder.updated_at)
    cq, oq = cq.where(where_c), oq.where(where_o)
    if since:
        cq = cq.where(Consultation.updated_at > since)
        oq = oq.where(PatientOrder.updated_at > since)
    return {
        "now": datetime.now(UTC),
        "consultations": [
            {"id": i, "status": s, "urgent": u, "updated_at": t}
            for i, s, u, t in db.execute(cq.order_by(Consultation.updated_at).limit(500))
        ],
        "orders": [
            {"id": i, "status": s, "updated_at": t}
            for i, s, t in db.execute(oq.order_by(PatientOrder.updated_at).limit(500))
        ],
    }


@router.get("/updates")
def patient_updates(p: Patient, db: DbSession, since: datetime | None = None) -> dict:
    """The patient's consultations and orders changed after [since]. Pass
    the returned `now` as the next `since`."""
    return _changes(
        db, Consultation.patient_id == p.user_id, PatientOrder.patient_id == p.user_id, since
    )


@router.get("/pharmacy-api/updates")
def pharmacy_updates(caller: PharmacyCaller, db: DbSession, since: datetime | None = None) -> dict:
    return _changes(
        db,
        (Consultation.pharmacy_id == caller.pharmacy_id) & Consultation.sent_at.is_not(None),
        PatientOrder.pharmacy_id == caller.pharmacy_id,
        since,
    )


class _FakeRequest:
    """current_pharmacy_server reads headers and settings from a request."""

    def __init__(self, ws: WebSocket, key: str) -> None:
        self.headers = {"authorization": f"Pharmacy {key}"}
        self.app = ws.app


def _topics(ws: WebSocket) -> list[str]:
    """?token=<patient access token>, or ?key=<pharmacy server key>."""
    app = ws.app
    if token := ws.query_params.get("token"):
        p = read_access_token(token, app.state.settings.jwt_secret)
        if p is None or p.role != "patient":
            raise error(401, "token_expired")
        return [patient_topic(p.user_id)]
    if key := ws.query_params.get("key"):
        with app.state.db.sessions() as db:
            caller = current_pharmacy_server(_FakeRequest(ws, key), db)  # type: ignore[arg-type]
        return [pharmacy_topic(caller.pharmacy_id)]
    raise error(401, "not_signed_in")


@router.websocket("/ws")
async def live(ws: WebSocket) -> None:
    """Events as JSON ({"type": "case_new" | "consultation" | "case_message"
    | "case_status" | "order", …}), and a ping every 25 s."""
    try:
        topics = await asyncio.to_thread(_topics, ws)
    except Exception:
        await ws.close(code=4401)
        return
    await ws.accept()
    events = ws.app.state.events
    queue = events.subscribe(topics)
    try:
        while True:
            try:
                event = await asyncio.wait_for(queue.get(), timeout=25)
            except TimeoutError:
                event = {"type": "ping"}
            await ws.send_json(event)
    except (WebSocketDisconnect, RuntimeError):
        pass
    finally:
        events.unsubscribe(queue)
        with contextlib.suppress(Exception):
            await ws.close()
