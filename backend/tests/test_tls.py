import ssl
import sys

from app.discovery import answer
from app.tls import ensure_certificate, fingerprint_of


def test_certificate_is_made_once_and_kept(tmp_path):
    first = ensure_certificate(tmp_path)
    assert first.cert_file.exists() and first.key_file.exists()
    if sys.platform != "win32":  # Windows ignores POSIX modes (chmod only sets read-only)
        assert (first.key_file.stat().st_mode & 0o777) == 0o600
    again = ensure_certificate(tmp_path)
    assert again.fingerprint == first.fingerprint  # same after a restart
    assert len(first.fingerprint) == 64
    assert first.short_code.count("-") == 1 and len(first.short_code) == 9
    assert fingerprint_of(first.cert_file.read_bytes()) == first.fingerprint


def test_certificate_and_key_work_for_tls(tmp_path):
    c = ensure_certificate(tmp_path)
    ctx = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    ctx.load_cert_chain(c.cert_file, c.key_file)  # raises if they don't match


def test_discovery_tells_devices_to_use_https_and_which_certificate():
    import json

    a = json.loads(answer(8000, "الشفاء", "ab" * 32))
    assert (a["scheme"], a["fingerprint"]) == ("https", "ab" * 32)
    assert json.loads(answer(8000, None))["scheme"] == "http"


def test_cli_prints_the_server_code(tmp_path, monkeypatch, capsys):
    from app.cli import main
    from app.config import get_settings

    monkeypatch.setenv("DOAYA_DATA_DIR", str(tmp_path))
    get_settings.cache_clear()
    try:
        assert main(["server-code"]) == 0
    finally:
        get_settings.cache_clear()
    assert capsys.readouterr().out.strip() == ensure_certificate(tmp_path).short_code
