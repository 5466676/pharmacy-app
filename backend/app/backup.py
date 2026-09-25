"""Daily database backups, done by the server itself (Windows or Linux).

`pg_dump -Fc` into `<data_dir>/backups/doaya-YYYYMMDD-HHMMSS.dump`, keeping
the newest 30. Restoring is `python -m app.cli restore <file>`.
"""

import os
import shutil
import subprocess
import threading
import time
from datetime import UTC, datetime
from pathlib import Path

from sqlalchemy.engine import make_url

from .config import Settings

PREFIX, SUFFIX = "doaya-", ".dump"


def backups_dir(settings: Settings) -> Path:
    return Path(settings.data_dir) / "backups"


def _tool(settings: Settings, name: str) -> str:
    """pg_dump / pg_restore from the configured PostgreSQL bin folder
    (Windows: C:\\Program Files\\PostgreSQL\\16\\bin), else from PATH."""
    if settings.pg_bin_dir:
        exe = Path(settings.pg_bin_dir) / (name + (".exe" if os.name == "nt" else ""))
        return str(exe)
    found = shutil.which(name)
    if not found:
        raise FileNotFoundError(f"{name} not found: set DOAYA_PG_BIN_DIR")
    return found


def _connection(settings: Settings) -> tuple[list[str], dict[str, str]]:
    url = make_url(settings.database_url)
    args = [
        "--host",
        url.host or "localhost",
        "--port",
        str(url.port or 5432),
        "--username",
        url.username or "postgres",
        "--dbname",
        url.database or "doaya",
    ]
    env = {**os.environ}
    if url.password:
        env["PGPASSWORD"] = url.password
    return args, env


def list_backups(settings: Settings) -> list[Path]:
    d = backups_dir(settings)
    if not d.exists():
        return []
    return sorted(d.glob(f"{PREFIX}*{SUFFIX}"))


def backup_now(settings: Settings, keep: int | None = None) -> Path:
    """Dumps the whole database; removes the oldest beyond [keep]."""
    d = backups_dir(settings)
    d.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(UTC).strftime("%Y%m%d-%H%M%S")
    target = d / f"{PREFIX}{stamp}{SUFFIX}"
    tmp = target.with_suffix(".partial")
    args, env = _connection(settings)
    subprocess.run(
        [_tool(settings, "pg_dump"), "--format=custom", "--file", str(tmp), *args],
        env=env,
        check=True,
        capture_output=True,
    )
    tmp.replace(target)  # only complete dumps get the .dump name
    for old in list_backups(settings)[: -(keep or settings.backup_keep)]:
        old.unlink()
    return target


def restore(settings: Settings, file: Path) -> None:
    """Replaces the database's content with the backup's."""
    args, env = _connection(settings)
    subprocess.run(
        [_tool(settings, "pg_restore"), "--clean", "--if-exists", "--no-owner", *args, str(file)],
        env=env,
        check=True,
        capture_output=True,
    )


def latest_backup_time(settings: Settings) -> datetime | None:
    files = list_backups(settings)
    if not files:
        return None
    return datetime.fromtimestamp(files[-1].stat().st_mtime, UTC)


class BackupScheduler:
    """Backs up once a day while the server runs (and soon after start if
    the last backup is more than a day old)."""

    def __init__(self, settings: Settings, every: float = 24 * 3600, check: float = 600) -> None:
        self.settings, self.every, self.check = settings, every, check
        self.last_error: str | None = None
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, name="doaya-backup", daemon=True)

    def start(self) -> "BackupScheduler":
        self._thread.start()
        return self

    def stop(self) -> None:
        self._stop.set()
        self._thread.join(timeout=5)

    def due(self) -> bool:
        last = latest_backup_time(self.settings)
        return last is None or (datetime.now(UTC) - last).total_seconds() >= self.every

    def _run(self) -> None:
        # A short wait so a restart loop doesn't dump the database each time.
        if self._stop.wait(min(60.0, self.check)):
            return
        while not self._stop.is_set():
            if self.due():
                try:
                    backup_now(self.settings)
                    self.last_error = None
                except Exception as e:  # keep serving; report on /backups
                    self.last_error = str(e)[:500]
            start = time.monotonic()
            self._stop.wait(max(1.0, self.check - (time.monotonic() - start)))
