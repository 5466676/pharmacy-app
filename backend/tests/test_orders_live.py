from urllib.parse import quote

import pytest
from starlette.websockets import WebSocketDisconnect

from .central_helpers import bearer, listed_pharmacy, pharmacy_auth, register

SHELF = {
    "currency": "SYP",
    "items": [
        {"product_id": "p1", "trade_name": "Panadol 500", "price_minor": 2500, "available": True},
        {"product_id": "p2", "trade_name": "Brufen 400", "price_minor": 4000, "available": False},
    ],
}


def _setup(client, engine):
    pid, key = listed_pharmacy(engine)
    client.put("/pharmacy-api/shelf", json=SHELF, headers=pharmacy_auth(key))
    s = register(client)
    client.patch("/patients/me", headers=bearer(s), json={"pharmacy_id": pid})
    return pid, key, bearer(s)


def test_order_for_pickup_the_pharmacist_has_the_final_say(client, engine):
    _, key, me = _setup(client, engine)
    bad = client.post("/orders", headers=me, json={"lines": [{"product_id": "zz", "quantity": 1}]})
    assert bad.json()["detail"] == "unknown_product"
    o = client.post(
        "/orders",
        headers=me,
        json={
            "lines": [{"product_id": "p1", "quantity": 3}, {"product_id": "p2", "quantity": 1}],
            "note": "بدي علبة كبيرة إذا في",
        },
    ).json()
    assert (o["status"], o["total_minor"], o["currency"]) == ("sent", 3 * 2500 + 4000, "SYP")

    ph = pharmacy_auth(key, actor="رنا")
    listed = client.get("/pharmacy-api/orders?status=sent", headers=ph).json()
    assert listed[0]["patient"]["name"] == "سامر"
    # Brufen is out: the pharmacist drops it and gives 2 Panadol, not 3.
    r = client.post(
        f"/pharmacy-api/orders/{o['id']}/status",
        headers=ph,
        json={"status": "ready", "quantities": {"p1": 2, "p2": 0}, "note": "البروفين خالص"},
    ).json()
    assert r["status"] == "ready" and r["handled_by"] == "رنا"
    assert [(x["product_id"], x["requested"], x["quantity"]) for x in r["lines"]] == [("p1", 3, 2)]
    mine = client.get(f"/orders/{o['id']}", headers=me).json()
    assert (mine["total_minor"], mine["pharmacist_note"]) == (5000, "البروفين خالص")
    assert client.post(f"/orders/{o['id']}/cancel", headers=me).status_code == 409
    again = client.post(
        f"/pharmacy-api/orders/{o['id']}/status", headers=ph, json={"status": "preparing"}
    )
    assert again.json()["detail"] == "bad_status"
    done = client.post(
        f"/pharmacy-api/orders/{o['id']}/status", headers=ph, json={"status": "picked_up"}
    )
    assert done.json()["status"] == "picked_up"
    _, other = listed_pharmacy(engine, name="صيدلية النور", code="NOOR")
    assert (
        client.get(f"/pharmacy-api/orders/{o['id']}", headers=pharmacy_auth(other)).status_code
        == 404
    )


def test_updates_since_for_background_checks(client, engine):
    _, key, me = _setup(client, engine)
    first = client.get("/updates", headers=me).json()
    assert first["orders"] == []
    o = client.post("/orders", headers=me, json={"lines": [{"product_id": "p1", "quantity": 1}]})
    ph_updates = client.get("/pharmacy-api/updates", headers=pharmacy_auth(key)).json()
    assert [x["id"] for x in ph_updates["orders"]] == [o.json()["id"]]
    since = client.get("/updates", headers=me).json()["now"]
    assert client.get("/updates", headers=me, params={"since": since}).json()["orders"] == []
    client.post(
        f"/pharmacy-api/orders/{o.json()['id']}/status",
        headers=pharmacy_auth(key),
        json={"status": "ready"},
    )
    changed = client.get("/updates", headers=me, params={"since": since}).json()["orders"]
    assert [x["status"] for x in changed] == ["ready"]


def test_websocket_tells_the_patient_and_the_pharmacy(client, engine):
    _, key, me = _setup(client, engine)
    token = me["authorization"][7:]
    with (
        client.websocket_connect(f"/ws?token={token}") as patient_ws,
        client.websocket_connect(f"/ws?key={quote(key)}") as pharmacy_ws,
    ):
        o = client.post(
            "/orders", headers=me, json={"lines": [{"product_id": "p1", "quantity": 1}]}
        )
        assert pharmacy_ws.receive_json() == {
            "type": "order",
            "order_id": o.json()["id"],
            "status": "sent",
        }
        assert patient_ws.receive_json()["status"] == "sent"
    with pytest.raises(WebSocketDisconnect), client.websocket_connect("/ws?token=nope") as ws:
        ws.receive_json()


def test_pharmacy_devices_reach_their_cases_through_their_own_server(client, engine, settings):
    """The pharmacy server forwards /central/… with its key; its devices
    never hold central credentials."""
    _, key, me = _setup(client, engine)
    from app.cli import main

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
    device = {"authorization": f"Bearer {local['access_token']}"}
    assert (
        client.get("/central/orders", headers=device).json()["detail"] == "central_not_configured"
    )

    state = client.app.state
    state.settings = state.settings.model_copy(
        update={"central_url": "http://testserver", "central_key": key}
    )
    state.central_client = client  # the same app plays the central server
    client.post("/orders", headers=me, json={"lines": [{"product_id": "p1", "quantity": 2}]})
    orders = client.get("/central/orders", headers=device).json()
    assert orders[0]["lines"][0]["quantity"] == 2
    r = client.post(
        f"/central/orders/{orders[0]['id']}/status", headers=device, json={"status": "preparing"}
    ).json()
    assert r["handled_by"] == "سامر"  # the device's own account name
    assert client.get("/central/shelf", headers=device).status_code == 404  # not forwarded
    assert client.get("/central/orders").status_code == 401  # devices only
