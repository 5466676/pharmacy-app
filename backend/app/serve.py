"""Runs the server as installed on the pharmacy PC: HTTPS with its own
certificate, Wi-Fi discovery and daily backups.

    python -m app.serve            # port from DOAYA_HTTP_PORT (8000)
"""

import logging

import uvicorn

from .config import get_settings
from .main import server_app
from .tls import ensure_certificate


def main() -> None:
    settings = get_settings()
    cert = ensure_certificate(settings.data_dir)
    logging.basicConfig(level=logging.INFO)
    logging.getLogger("doaya").info("Server code (compare on devices): %s", cert.short_code)
    uvicorn.run(
        server_app(tls=True),
        host="0.0.0.0",
        port=settings.http_port,
        ssl_certfile=str(cert.cert_file),
        ssl_keyfile=str(cert.key_file),
        log_level="info",
    )


if __name__ == "__main__":
    main()
