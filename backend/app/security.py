"""Passwords, device secrets and access tokens."""

import hashlib
import re
import secrets
import time
import uuid
from dataclasses import dataclass

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerifyMismatchError

_hasher = PasswordHasher()

_ARABIC_DIGITS = str.maketrans("٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹", "01234567890123456789")


def normalize_phone(phone: str) -> str:
    """English digits only, keeping a leading +: "٠٩٤٤ ١٢٣" → "0944123"."""
    p = phone.strip().translate(_ARABIC_DIGITS)
    plus = p.startswith("+")
    digits = re.sub(r"\D", "", p)
    return f"+{digits}" if plus else digits


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def check_password(password_hash: str, password: str) -> bool:
    try:
        return _hasher.verify(password_hash, password)
    except (VerifyMismatchError, InvalidHashError):
        return False


def new_device_secret() -> str:
    return secrets.token_urlsafe(32)


def hash_secret(secret: str) -> str:
    """Device secrets are random and long: a plain SHA-256 is enough."""
    return hashlib.sha256(secret.encode()).hexdigest()


def new_id() -> str:
    return str(uuid.uuid4())


@dataclass(frozen=True)
class Principal:
    """Who is calling: a user, through a linked device, of a pharmacy."""

    user_id: str
    device_id: str
    pharmacy_id: str
    role: str

    @property
    def is_owner(self) -> bool:
        return self.role == "pharmacist_owner"


def issue_access_token(p: Principal, secret: str, minutes: int) -> str:
    now = int(time.time())
    claims = {
        "sub": p.user_id,
        "dev": p.device_id,
        "ph": p.pharmacy_id,
        "role": p.role,
        "iat": now,
        "exp": now + minutes * 60,
    }
    return jwt.encode(claims, secret, algorithm="HS256")


def read_access_token(token: str, secret: str) -> Principal | None:
    try:
        c = jwt.decode(token, secret, algorithms=["HS256"], options={"require": ["exp", "sub"]})
    except jwt.PyJWTError:
        return None
    return Principal(user_id=c["sub"], device_id=c["dev"], pharmacy_id=c["ph"], role=c["role"])


class LoginLimiter:
    """At most [limit] failed logins per key in [window] seconds (in memory:
    one server process per pharmacy)."""

    def __init__(self, limit: int = 10, window: float = 15 * 60) -> None:
        self.limit, self.window = limit, window
        self._fails: dict[str, list[float]] = {}

    def blocked(self, key: str) -> bool:
        now = time.monotonic()
        recent = [t for t in self._fails.get(key, []) if now - t < self.window]
        self._fails[key] = recent
        return len(recent) >= self.limit

    def failed(self, key: str) -> None:
        self._fails.setdefault(key, []).append(time.monotonic())

    def succeeded(self, key: str) -> None:
        self._fails.pop(key, None)
