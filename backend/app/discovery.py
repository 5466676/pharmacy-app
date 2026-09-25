"""Lets the app find the server on the pharmacy's Wi-Fi.

The app broadcasts `DOAYA?` on UDP port 47800; the server answers with a
small JSON: where its HTTP API is and which pharmacy it serves. Standard
library only.
"""

import json
import socket
import threading
from collections.abc import Callable

QUESTION = b"DOAYA?"


def answer(http_port: int, pharmacy_name: str | None) -> bytes:
    return json.dumps(
        {"service": "doaya", "http_port": http_port, "pharmacy": pharmacy_name},
        ensure_ascii=False,
    ).encode()


class DiscoveryResponder:
    """A small UDP listener thread; `stop()` ends it."""

    def __init__(self, port: int, http_port: int, pharmacy_name: Callable[[], str | None]) -> None:
        self.http_port = http_port
        self.pharmacy_name = pharmacy_name
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind(("", port))
        self.sock.settimeout(0.5)
        self.port = self.sock.getsockname()[1]
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, name="doaya-discovery", daemon=True)

    def start(self) -> "DiscoveryResponder":
        self._thread.start()
        return self

    def stop(self) -> None:
        self._stop.set()
        self._thread.join(timeout=2)
        self.sock.close()

    def _run(self) -> None:
        while not self._stop.is_set():
            try:
                data, addr = self.sock.recvfrom(64)
            except TimeoutError:
                continue
            except OSError:
                return
            if data.strip() == QUESTION:
                try:
                    name = self.pharmacy_name()
                except Exception:  # the database may be down; still answer
                    name = None
                self.sock.sendto(answer(self.http_port, name), addr)
