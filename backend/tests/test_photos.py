"""Prescription photos: the patient sends one in a consultation or with an
order; only that patient and that pharmacy can open it."""

import pytest

from .central_helpers import bearer, listed_pharmacy, pharmacy_auth, register
from .test_consult_engine import model
from .test_orders_live import SHELF

JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 2000
PNG = b"\x89PNG\r\n\x1a\n" + b"\x00" * 100


@pytest.fixture
def photos_dir(client, tmp_path):
    state = client.app.state
    state.settings = state.settings.model_copy(update={"data_dir": str(tmp_path)})
    return tmp_path / "photos"


def _patient(client, engine, phone="0933111222", pharmacy=None):
    pid, key = pharmacy or listed_pharmacy(engine)
    client.put("/pharmacy-api/shelf", json=SHELF, headers=pharmacy_auth(key))
    s = register(client, phone=phone)
    client.patch("/patients/me", headers=bearer(s), json={"pharmacy_id": pid})
    client.app.state.llm = model()
    return (pid, key), bearer(s)


def _file(data=JPEG, name="rx.jpg", ctype="image/jpeg"):
    return {"file": (name, data, ctype)}


def test_a_photo_in_the_consultation_reaches_the_pharmacist(client, engine, photos_dir):
    (pid, key), me = _patient(client, engine)
    cid = client.post("/consultations", headers=me).json()["id"]
    client.post(f"/consultations/{cid}/messages", headers=me, json={"text": "بدي هالدوا"})
    c = client.post(f"/consultations/{cid}/photos", headers=me, files=_file()).json()
    msg = c["messages"][-1]
    assert (msg["role"], bool(msg["photo_id"])) == ("patient", True)
    photo = msg["photo_id"]
    assert (photos_dir / photo).read_bytes() == JPEG

    r = client.get(f"/photos/{photo}", headers=me)
    assert (r.status_code, r.content, r.headers["content-type"]) == (200, JPEG, "image/jpeg")
    # Not sent yet: the pharmacy can't see it.
    assert (
        client.get(f"/pharmacy-api/photos/{photo}", headers=pharmacy_auth(key)).status_code == 404
    )

    client.post(f"/consultations/{cid}/send", headers=me)
    case = client.get(f"/pharmacy-api/cases/{cid}", headers=pharmacy_auth(key)).json()
    assert any(m["photo_id"] == photo for m in case["messages"])
    r = client.get(f"/pharmacy-api/photos/{photo}", headers=pharmacy_auth(key))
    assert (r.status_code, r.content) == (200, JPEG)

    # Nobody else.
    _, other = _patient(client, engine, phone="0933999888", pharmacy=(pid, key))
    assert client.get(f"/photos/{photo}", headers=other).status_code == 404
    _, key2 = listed_pharmacy(engine, name="تانية", code="XX2")
    assert (
        client.get(f"/pharmacy-api/photos/{photo}", headers=pharmacy_auth(key2)).status_code == 404
    )
    assert client.get(f"/photos/{photo}").status_code == 401


def test_only_real_images_of_a_sane_size(client, engine, photos_dir):
    _, me = _patient(client, engine)
    cid = client.post("/consultations", headers=me).json()["id"]
    bad = client.post(
        f"/consultations/{cid}/photos", headers=me, files=_file(b"%PDF-1.4 junk", "x.jpg")
    )
    assert (bad.status_code, bad.json()["detail"]) == (415, "not_an_image")
    big = client.post(f"/consultations/{cid}/photos", headers=me, files=_file(JPEG * 3000))
    assert (big.status_code, big.json()["detail"]) == (413, "photo_too_big")
    assert (
        client.post("/photos", headers=me, files=_file(PNG, "rx.png", "image/png")).status_code
        == 200
    )
    assert not photos_dir.exists() or len(list(photos_dir.iterdir())) == 1


def test_a_photo_with_a_pickup_order(client, engine, photos_dir):
    (pid, key), me = _patient(client, engine)
    photo = client.post("/photos", headers=me, files=_file()).json()["id"]
    o = client.post(
        "/orders",
        headers=me,
        json={"lines": [{"product_id": "p1", "quantity": 1}], "photo_id": photo},
    ).json()
    assert o["photo_id"] == photo
    theirs = client.get(f"/pharmacy-api/orders/{o['id']}", headers=pharmacy_auth(key)).json()
    assert theirs["photo_id"] == photo
    assert client.get(f"/pharmacy-api/photos/{photo}", headers=pharmacy_auth(key)).content == JPEG

    # Someone else's photo can't ride on my order.
    _, other = _patient(client, engine, phone="0933999888", pharmacy=(pid, key))
    stolen = client.post(
        "/orders",
        headers=other,
        json={"lines": [{"product_id": "p1", "quantity": 1}], "photo_id": photo},
    )
    assert stolen.json()["detail"] == "bad_photo"


def test_the_pharmacy_app_gets_the_photo_through_its_own_server(
    client, engine, settings, photos_dir
):
    from app.cli import main

    (pid, key), me = _patient(client, engine)
    photo = client.post("/photos", headers=me, files=_file(PNG, "rx.png", "image/png")).json()
    client.post(
        "/orders",
        headers=me,
        json={"lines": [{"product_id": "p1", "quantity": 1}], "photo_id": photo["id"]},
    )
    main(
        [
            "create-pharmacy",
            "--name",
            "الشفاء المحلي",
            "--owner-name",
            "سامر",
            "--owner-phone",
            "0944000111",
            "--password",
            "secret-1",
        ],
        settings.database_url,
    )
    local = client.post(
        "/auth/link",
        json={
            "phone": "0944000111",
            "password": "secret-1",
            "device": {"id": "counter-pc-1", "name": "الكاونتر"},
        },
    ).json()
    state = client.app.state
    state.settings = state.settings.model_copy(
        update={"central_url": "http://testserver", "central_key": key}
    )
    state.central_client = client
    r = client.get(
        f"/central/photos/{photo['id']}",
        headers={"authorization": f"Bearer {local['access_token']}"},
    )
    assert (r.status_code, r.content, r.headers["content-type"]) == (200, PNG, "image/png")
