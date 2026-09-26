from datetime import UTC, datetime

from sqlalchemy.orm import Session

from app.bridge import compute_shelf, publish_shelf
from app.models import Pharmacy, SyncRow

from .central_helpers import listed_pharmacy, pharmacy_auth

ITEM = {
    "product_id": "p1",
    "trade_name": "Amoxil 500 mg",
    "arabic_name": "أموكسيل",
    "active_ingredient": "amoxicillin",
    "price_minor": 4500,
    "available": True,
    "prescription_only": True,
}


def test_a_pharmacy_publishes_its_shelf_and_patients_browse_it(client, engine):
    pid, key = listed_pharmacy(engine)
    shelf = {
        "currency": "syp",
        "items": [
            ITEM,
            {
                **ITEM,
                "product_id": "p2",
                "trade_name": "Brufen 400",
                "arabic_name": "بروفين",
                "active_ingredient": "ibuprofen",
                "available": False,
                "prescription_only": False,
            },
        ],
    }
    assert client.put("/pharmacy-api/shelf", json=shelf).status_code == 401
    bad = {"authorization": "Pharmacy nope"}
    assert client.put("/pharmacy-api/shelf", json=shelf, headers=bad).status_code == 401
    r = client.put("/pharmacy-api/shelf", json=shelf, headers=pharmacy_auth(key))
    assert r.json() == {"items": 2}

    items = client.get(f"/directory/{pid}/shelf").json()
    assert [i["trade_name"] for i in items] == ["Amoxil 500 mg", "Brufen 400"]  # available first
    assert items[0]["currency"] == "SYP" and "quantity" not in items[0]
    assert [i["product_id"] for i in client.get(f"/directory/{pid}/shelf?q=بروف").json()] == ["p2"]
    assert client.get(f"/directory/{pid}/shelf?available_only=true").json()[0]["product_id"] == "p1"
    one = client.get(f"/directory/{pid}/shelf/p2").json()
    assert (one["product_id"], one["currency"]) == ("p2", "SYP")
    assert client.get(f"/directory/{pid}/shelf/nope").status_code == 404

    # Publishing again replaces the shelf.
    shelf["items"] = shelf["items"][:1]
    client.put("/pharmacy-api/shelf", json=shelf, headers=pharmacy_auth(key))
    assert len(client.get(f"/directory/{pid}/shelf").json()) == 1


def test_directory_by_city_name_and_code(client, engine):
    pid, _ = listed_pharmacy(engine)
    listed_pharmacy(engine, name="صيدلية النور", code="NOOR", city="حلب")
    assert [p["name"] for p in client.get("/directory?city=دمشق").json()] == ["صيدلية الشفاء"]
    assert len(client.get("/directory").json()) == 2
    assert client.get("/directory?q=النور").json()[0]["code"] == "NOOR"
    assert client.get("/directory/code/sh4f").json()["id"] == pid
    assert client.get("/directory/code/XXXX").status_code == 404
    assert client.get("/directory/nope/shelf").status_code == 404


def _row(db, pharmacy_id, table, row_id, data, deleted=False):
    db.add(
        SyncRow(
            pharmacy_id=pharmacy_id,
            table_name=table,
            row_id=row_id,
            data=None if deleted else data,
            deleted=deleted,
            changed_at=datetime.now(UTC),
            device_id="pc",
        )
    )


def test_the_bridge_computes_the_shelf_from_synced_rows_and_publishes_it(client, engine, settings):
    central_id, key = listed_pharmacy(engine)
    with Session(engine) as db:
        local = Pharmacy(id="local-pharmacy", name="الشفاء (محلي)", status="active")
        db.add(local)
        db.commit()
        product = {
            "trade_name": "Amoxil",
            "active_ingredient": "amoxicillin",
            "price_minor": 4500,
            "prescription_only": 1,
            "active": 1,
        }
        _row(db, local.id, "products", "a", {**product, "id": "a"})
        _row(db, local.id, "products", "b", {**product, "id": "b", "trade_name": "Brufen"})
        _row(db, local.id, "products", "c", {**product, "id": "c", "active": 0})
        _row(db, local.id, "products", "d", {}, deleted=True)
        _row(db, local.id, "stock_events", "e1", {"product_id": "a", "quantity": 5})
        _row(db, local.id, "stock_events", "e2", {"product_id": "a", "quantity": -2})
        _row(db, local.id, "stock_events", "e3", {"product_id": "b", "quantity": 3})
        _row(db, local.id, "stock_events", "e4", {"product_id": "b", "quantity": -3})
        _row(db, local.id, "settings", "currency_code", {"key": "currency_code", "value": "syp"})
        db.commit()

        shelf = compute_shelf(db, local.id)
        assert shelf["currency"] == "SYP"
        by_id = {i["product_id"]: i for i in shelf["items"]}
        assert set(by_id) == {"a", "b"}  # inactive and deleted products left out
        assert (by_id["a"]["available"], by_id["b"]["available"]) == (True, False)
        assert by_id["a"]["prescription_only"] is True
        assert "quantity" not in by_id["a"]

    with Session(engine) as db:
        s = settings.model_copy(update={"central_key": key})
        count = publish_shelf(db, s, client=client, pharmacy_id="local-pharmacy")
    assert count == 2
    names = [i["trade_name"] for i in client.get(f"/directory/{central_id}/shelf").json()]
    assert names == ["Amoxil", "Brufen"]


def test_cli_lists_a_pharmacy_and_gives_it_a_key(client, engine, settings, capsys):
    from app.cli import main

    with Session(engine) as db:
        db.add(Pharmacy(id="ph-cli", name="صيدلية الأمل", status="active"))
        db.commit()
    url = settings.database_url
    assert main(["list-pharmacy", "ph-cli", "--code", "amal", "--city", "حمص"], url) == 0
    assert main(["pharmacy-key", "ph-cli"], url) == 0
    key = capsys.readouterr().out.strip()
    assert key.startswith("dk_")
    assert client.get("/directory/code/AMAL").json()["city"] == "حمص"
    r = client.put(
        "/pharmacy-api/shelf", json={"currency": "SYP", "items": []}, headers=pharmacy_auth(key)
    )
    assert r.status_code == 200
    assert main(["pharmacy-key", "nope"], url) == 1
