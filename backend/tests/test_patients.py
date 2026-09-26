from .central_helpers import bearer, listed_pharmacy, register


def test_register_once_then_stay_signed_in(client):
    s = register(client, phone="٠٩٣٣ ١١١ ٢٢٢", birth_year=1990, sex="m", city="دمشق")
    assert s["patient"]["phone"] == "0933111222"
    assert s["patient"]["pharmacy"] is None
    r = client.post("/patients/token", json={"session_token": s["session_token"]})
    assert r.status_code == 200
    me = client.get("/patients/me", headers={"authorization": f"Bearer {r.json()['access_token']}"})
    assert me.json()["birth_year"] == 1990
    assert register_again(client).status_code == 409


def register_again(client):
    return client.post(
        "/patients/register",
        json={"name": "x", "phone": "0933111222", "password": "secret-1"},
    )


def test_login_and_logout(client):
    register(client)
    bad = client.post("/patients/login", json={"phone": "0933111222", "password": "nope"})
    assert bad.status_code == 401
    s = client.post("/patients/login", json={"phone": "0933111222", "password": "secret-1"}).json()
    assert client.post("/patients/logout", headers=bearer(s)).status_code == 200
    assert client.get("/patients/me", headers=bearer(s)).json()["detail"] == "signed_out"
    r = client.post("/patients/token", json={"session_token": s["session_token"]})
    assert r.status_code == 401


def test_choose_a_listed_pharmacy(client, engine):
    pid, _ = listed_pharmacy(engine)
    s = register(client)
    r = client.patch("/patients/me", headers=bearer(s), json={"pharmacy_id": pid})
    assert r.json()["pharmacy"]["code"] == "SH4F"
    assert r.json()["pharmacy"]["name"] == "صيدلية الشفاء"
    r = client.patch("/patients/me", headers=bearer(s), json={"pharmacy_id": "nope"})
    assert r.status_code == 404


def test_patient_and_pharmacy_tokens_never_cross(client):
    s = register(client)
    # A patient token is no device: the pharmacy API refuses it.
    assert client.get("/sync/pull", headers=bearer(s)).status_code == 401
    # A pharmacy device's token is refused by patient endpoints.
    setup = client.post(
        "/setup",
        json={
            "pharmacy_name": "x",
            "owner_name": "o",
            "owner_phone": "0944000000",
            "password": "secret-1",
            "device": {"id": "device-0001", "name": "pc"},
        },
    ).json()
    r = client.get("/patients/me", headers={"authorization": f"Bearer {setup['access_token']}"})
    assert r.status_code == 403
