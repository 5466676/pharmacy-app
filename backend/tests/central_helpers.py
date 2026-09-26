"""Shared set-up for central-server tests: a listed pharmacy with a key,
and signed-in patients."""

from sqlalchemy.orm import Session

from app.central import list_pharmacy, new_pharmacy_key
from app.models import Pharmacy
from app.security import new_id


def listed_pharmacy(engine, name="صيدلية الشفاء", code="SH4F", city="دمشق") -> tuple[str, str]:
    """(pharmacy id, its server's key)."""
    with Session(engine) as db:
        ph = Pharmacy(id=new_id(), name=name, status="active")
        db.add(ph)
        db.commit()
        list_pharmacy(db, ph.id, code=code, city=city, hours="9 - 23")
        return ph.id, new_pharmacy_key(db, ph.id)


def register(client, phone="0933111222", name="سامر", **extra) -> dict:
    r = client.post(
        "/patients/register",
        json={"name": name, "phone": phone, "password": "secret-1", **extra},
    )
    assert r.status_code == 200, r.text
    return r.json()


def bearer(session: dict) -> dict:
    return {"authorization": f"Bearer {session['access_token']}"}


def pharmacy_auth(key: str, actor: str = "رنا") -> dict:
    from urllib.parse import quote

    return {"authorization": f"Pharmacy {key}", "x-doaya-actor": quote(actor)}
