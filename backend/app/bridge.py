"""On a pharmacy's own server: publishes its shelf to the central server
whenever there's internet (DOAYA_CENTRAL_URL + DOAYA_CENTRAL_KEY). Only
product names, prices and available-or-not leave the pharmacy; never sales,
debts, customers or quantities."""

import threading
import time
from collections import defaultdict

import httpx
from sqlalchemy import select
from sqlalchemy.orm import Session

from .config import Settings
from .models import Pharmacy, SyncRow


def _rows(db: Session, pharmacy_id: str, table: str):
    return db.scalars(
        select(SyncRow.data).where(
            SyncRow.pharmacy_id == pharmacy_id,
            SyncRow.table_name == table,
            SyncRow.deleted.is_(False),
        )
    )


def compute_shelf(db: Session, pharmacy_id: str) -> dict:
    """The shelf from the synced rows: active products, their sale price,
    and whether the stock ledger has any left."""
    on_hand: dict[str, int] = defaultdict(int)
    for e in _rows(db, pharmacy_id, "stock_events"):
        if e and e.get("product_id"):
            on_hand[e["product_id"]] += int(e.get("quantity") or 0)
    settings = {s["key"]: s.get("value") for s in _rows(db, pharmacy_id, "settings") if s}
    items = []
    for p in _rows(db, pharmacy_id, "products"):
        if not p or not p.get("active", 1):
            continue
        items.append(
            {
                "product_id": p["id"],
                "trade_name": p["trade_name"],
                "arabic_name": p.get("arabic_name"),
                "active_ingredient": p.get("active_ingredient"),
                "strength": p.get("strength"),
                "form": p.get("form"),
                "price_minor": int(p.get("price_minor") or 0),
                "available": on_hand[p["id"]] > 0,
                "prescription_only": bool(p.get("prescription_only")),
            }
        )
    return {"currency": (settings.get("currency_code") or "SYP").upper(), "items": items}


def publish_shelf(
    db: Session,
    settings: Settings,
    client: httpx.Client | None = None,
    pharmacy_id: str | None = None,
) -> int:
    """Sends the shelf of this server's pharmacy (its first one unless
    [pharmacy_id]); returns the item count. Raises httpx errors when the
    central server can't be reached."""
    pharmacy_id = pharmacy_id or db.scalar(
        select(Pharmacy.id).order_by(Pharmacy.created_at).limit(1)
    )
    if pharmacy_id is None:
        return 0
    shelf = compute_shelf(db, pharmacy_id)
    own = client is None
    client = client or httpx.Client(base_url=settings.central_url, timeout=60)
    try:
        r = client.put(
            "/pharmacy-api/shelf",
            json=shelf,
            headers={"authorization": f"Pharmacy {settings.central_key}"},
        )
        r.raise_for_status()
    finally:
        if own:
            client.close()
    return len(shelf["items"])


class ShelfPublisher:
    """Every [every] seconds while the server runs; failures (no internet)
    are kept for the owner to see and tried again next time."""

    def __init__(self, settings: Settings, sessions, every: float = 600) -> None:
        self.settings, self.sessions, self.every = settings, sessions, every
        self.last_error: str | None = None
        self.last_published: float | None = None
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, name="doaya-shelf", daemon=True)

    def start(self) -> "ShelfPublisher":
        self._thread.start()
        return self

    def stop(self) -> None:
        self._stop.set()
        self._thread.join(timeout=5)

    def _run(self) -> None:
        while not self._stop.wait(
            min(30.0, self.every) if self.last_published is None else self.every
        ):
            try:
                with self.sessions() as db:
                    publish_shelf(db, self.settings)
                self.last_published, self.last_error = time.time(), None
            except Exception as e:  # no internet, central down: try later
                self.last_error = str(e)[:300]
