"""Live updates: a case or order changed → its patient and its pharmacy are
told. Endpoints (sync, in worker threads) publish; WebSocket connections
(async, on the event loop) listen. Delivery is best-effort: clients also
fetch what changed since their last look (GET /updates), so nothing is lost
when a phone was offline."""

import asyncio
import contextlib
import threading
from collections import deque


class Events:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._subs: dict[str, set[tuple[asyncio.AbstractEventLoop, asyncio.Queue]]] = {}
        # The last events, for tests and debugging.
        self.recent: deque[tuple[str, dict]] = deque(maxlen=200)

    def publish(self, topics: list[str], event: dict) -> None:
        """Thread-safe; never blocks the caller."""
        with self._lock:
            targets = [(t, q) for t in topics for q in self._subs.get(t, ())]
            for t in topics:
                self.recent.append((t, event))
        for loop, queue in (q for _, q in targets):
            # A closed loop means that connection is gone.
            with contextlib.suppress(RuntimeError):
                loop.call_soon_threadsafe(_offer, queue, event)

    def subscribe(self, topics: list[str]) -> asyncio.Queue:
        queue: asyncio.Queue = asyncio.Queue(maxsize=100)
        entry = (asyncio.get_running_loop(), queue)
        with self._lock:
            for t in topics:
                self._subs.setdefault(t, set()).add(entry)
        queue.topics = topics  # type: ignore[attr-defined]
        queue.entry = entry  # type: ignore[attr-defined]
        return queue

    def unsubscribe(self, queue: asyncio.Queue) -> None:
        with self._lock:
            for t in queue.topics:  # type: ignore[attr-defined]
                self._subs.get(t, set()).discard(queue.entry)  # type: ignore[attr-defined]


def _offer(queue: asyncio.Queue, event: dict) -> None:
    # A stuck client drops events; it catches up with /updates.
    with contextlib.suppress(asyncio.QueueFull):
        queue.put_nowait(event)


def pharmacy_topic(pharmacy_id: str) -> str:
    return f"pharmacy:{pharmacy_id}"


def patient_topic(patient_id: str) -> str:
    return f"patient:{patient_id}"
