import json
import socket

from app.discovery import DiscoveryResponder


def ask(port: int) -> dict | None:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(2)
    try:
        s.sendto(b"DOAYA?", ("127.0.0.1", port))
        data, _ = s.recvfrom(1024)
        return json.loads(data)
    finally:
        s.close()


def test_answers_with_the_http_port_and_pharmacy_name():
    r = DiscoveryResponder(0, 8000, lambda: "صيدلية الشفاء", "ab" * 32).start()
    try:
        assert ask(r.port) == {
            "service": "doaya",
            "http_port": 8000,
            "pharmacy": "صيدلية الشفاء",
            "scheme": "https",
            "fingerprint": "ab" * 32,
        }
    finally:
        r.stop()


def test_still_answers_when_the_database_is_down():
    def broken():
        raise RuntimeError("db down")

    r = DiscoveryResponder(0, 8000, broken).start()
    try:
        assert ask(r.port)["pharmacy"] is None
    finally:
        r.stop()


def test_ignores_anything_else():
    r = DiscoveryResponder(0, 8000, lambda: None).start()
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0.5)
    try:
        s.sendto(b"hello", ("127.0.0.1", r.port))
        try:
            s.recvfrom(1024)
            raise AssertionError("should not answer")
        except TimeoutError:
            pass
    finally:
        s.close()
        r.stop()
