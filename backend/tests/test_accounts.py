from app.cli import main as cli

DEV1 = {"id": "0190a000-0000-7000-8000-000000000001", "name": "لابتوب الكاونتر"}
DEV2 = {"id": "0190a000-0000-7000-8000-000000000002", "name": "موبايل رنا"}


def setup_pharmacy(client, device=DEV1):
    r = client.post(
        "/setup",
        json={
            "pharmacy_name": "صيدلية الشفاء",
            "owner_name": "سامر",
            "owner_phone": "٠٩٤٤ ١٢٣ ٤٥٦",
            "password": "secret-1",
            "owner_employee_id": "emp-owner",
            "device": device,
        },
    )
    assert r.status_code == 200, r.text
    return r.json()


def auth(token: str) -> dict:
    return {"authorization": f"Bearer {token}"}


def test_first_setup_creates_the_pharmacy_owner_and_links_the_device(client):
    assert client.get("/setup").json() == {"needs_setup": True}
    out = setup_pharmacy(client)
    assert out["user"]["phone"] == "0944123456"  # English digits, no spaces
    assert out["user"]["role"] == "pharmacist_owner"
    assert out["user"]["employee_id"] == "emp-owner"
    assert client.get("/setup").json() == {"needs_setup": False}
    # A second setup is refused: the server has its pharmacy.
    r = client.post(
        "/setup",
        json={
            "pharmacy_name": "x",
            "owner_name": "x",
            "owner_phone": "0999999999",
            "password": "secret-2",
            "device": DEV2,
        },
    )
    assert (r.status_code, r.json()["detail"]) == (409, "already_set_up")
    me = client.get("/me", headers=auth(out["access_token"])).json()
    assert me["pharmacy"]["name"] == "صيدلية الشفاء"


def test_a_linked_device_trades_its_secret_for_access_tokens(client):
    out = setup_pharmacy(client)
    r = client.post(
        "/auth/token", json={"device_id": DEV1["id"], "device_token": out["device_token"]}
    )
    assert r.status_code == 200
    assert client.get("/me", headers=auth(r.json()["access_token"])).status_code == 200
    bad = client.post("/auth/token", json={"device_id": DEV1["id"], "device_token": "nope"})
    assert (bad.status_code, bad.json()["detail"]) == (401, "device_unlinked")


def test_employee_account_links_their_phone_once(client):
    owner = setup_pharmacy(client)
    h = auth(owner["access_token"])
    r = client.post(
        "/users",
        headers=h,
        json={"name": "رنا", "phone": "0933 000 111", "password": "rana-pass", "employee_id": "e2"},
    )
    assert r.status_code == 201, r.text
    wrong = client.post(
        "/auth/link", json={"phone": "0933000111", "password": "nope-nope", "device": DEV2}
    )
    assert (wrong.status_code, wrong.json()["detail"]) == (401, "bad_credentials")
    ok = client.post(
        "/auth/link", json={"phone": "0933000111", "password": "rana-pass", "device": DEV2}
    ).json()
    assert ok["user"]["role"] == "pharmacist_employee"
    assert ok["user"]["employee_id"] == "e2"
    # Employees can't manage devices or accounts.
    eh = auth(ok["access_token"])
    assert client.get("/devices", headers=eh).json()["detail"] == "owner_only"
    assert client.get("/users", headers=eh).status_code == 403
    # Same phone twice is refused.
    dup = client.post(
        "/users", headers=h, json={"name": "x", "phone": "0933000111", "password": "123456"}
    )
    assert dup.json()["detail"] == "phone_taken"


def test_unlinking_a_device_stops_it_at_once(client):
    owner = setup_pharmacy(client)
    h = auth(owner["access_token"])
    client.post(
        "/users", headers=h, json={"name": "رنا", "phone": "0933000111", "password": "rana-pass"}
    )
    rana = client.post(
        "/auth/link", json={"phone": "0933000111", "password": "rana-pass", "device": DEV2}
    ).json()
    devices = client.get("/devices", headers=h).json()
    assert [d["name"] for d in devices] == ["لابتوب الكاونتر", "موبايل رنا"]

    assert client.post(f"/devices/{DEV2['id']}/unlink", headers=h).status_code == 204
    # Her still-valid access token and her device secret both stop working.
    r = client.get("/me", headers=auth(rana["access_token"]))
    assert (r.status_code, r.json()["detail"]) == (401, "device_unlinked")
    r = client.post(
        "/auth/token", json={"device_id": DEV2["id"], "device_token": rana["device_token"]}
    )
    assert r.status_code == 401
    # The owner can't unlink the device they're using.
    assert client.post(f"/devices/{DEV1['id']}/unlink", headers=h).status_code == 409
    # Linking again with the password works (a phone that was found).
    again = client.post(
        "/auth/link", json={"phone": "0933000111", "password": "rana-pass", "device": DEV2}
    )
    assert again.status_code == 200


def test_disabled_account_and_suspended_pharmacy_are_refused(client, settings):
    owner = setup_pharmacy(client)
    h = auth(owner["access_token"])
    rana = client.post(
        "/users", headers=h, json={"name": "رنا", "phone": "0933000111", "password": "rana-pass"}
    ).json()
    client.patch(f"/users/{rana['id']}", headers=h, json={"active": False})
    r = client.post(
        "/auth/link", json={"phone": "0933000111", "password": "rana-pass", "device": DEV2}
    )
    assert r.status_code == 401

    assert cli(["set-status", owner["pharmacy_id"], "suspended"], settings.database_url) == 0
    r = client.get("/me", headers=h)
    assert (r.status_code, r.json()["detail"]) == (403, "pharmacy_inactive")


def test_too_many_wrong_passwords_are_blocked(client):
    setup_pharmacy(client)
    for _ in range(10):
        client.post(
            "/auth/link", json={"phone": "0944123456", "password": "wrong!", "device": DEV2}
        )
    r = client.post(
        "/auth/link", json={"phone": "0944123456", "password": "secret-1", "device": DEV2}
    )
    assert (r.status_code, r.json()["detail"]) == (429, "too_many_attempts")


def test_cli_creates_a_pharmacy_whose_owner_can_link(client, settings, capsys):
    rc = cli(
        [
            "create-pharmacy",
            "--name",
            "صيدلية الأم",
            "--owner-name",
            "أم سامر",
            "--owner-phone",
            "0955 111 222",
            "--password",
            "mother-1",
        ],
        settings.database_url,
    )
    assert rc == 0
    r = client.post(
        "/auth/link", json={"phone": "0955111222", "password": "mother-1", "device": DEV1}
    )
    assert r.status_code == 200
    assert r.json()["pharmacy_name"] == "صيدلية الأم"


def test_a_device_cannot_be_moved_to_another_pharmacy(client, settings):
    setup_pharmacy(client)
    cli(
        [
            "create-pharmacy",
            "--name",
            "ب",
            "--owner-name",
            "ب",
            "--owner-phone",
            "0966000000",
            "--password",
            "other-1",
        ],
        settings.database_url,
    )
    r = client.post(
        "/auth/link", json={"phone": "0966000000", "password": "other-1", "device": DEV1}
    )
    assert (r.status_code, r.json()["detail"]) == (409, "device_other_pharmacy")
