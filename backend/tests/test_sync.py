import threading

import pytest

from app.cli import main as cli

from .test_accounts import DEV2, auth, setup_pharmacy

DEV3 = {"id": "0190a000-0000-7000-8000-000000000003", "name": "صيدلية تانية"}
T1, T2, T3 = "2026-09-25T10:00:00Z", "2026-09-25T11:00:00Z", "2026-09-25T12:00:00Z"


@pytest.fixture
def devices(client):
    """The counter PC (owner) and Rana's phone, same pharmacy."""
    owner = setup_pharmacy(client)
    h = auth(owner["access_token"])
    client.post(
        "/users", headers=h, json={"name": "رنا", "phone": "0933000111", "password": "rana-pass"}
    )
    rana = client.post(
        "/auth/link", json={"phone": "0933000111", "password": "rana-pass", "device": DEV2}
    ).json()
    return h, auth(rana["access_token"])


def push(client, h, *changes):
    r = client.post("/sync/push", headers=h, json={"changes": list(changes)})
    assert r.status_code == 200, r.text
    return r.json()


def pull(client, h, after=0, limit=500):
    r = client.get(f"/sync/pull?after={after}&limit={limit}", headers=h)
    assert r.status_code == 200, r.text
    return r.json()


def sale(i, total=4500):
    return {
        "table": "sales",
        "id": f"s{i}",
        "changed_at": T1,
        "data": {"id": f"s{i}", "total_minor": total},
    }


def test_ledger_rows_are_stored_once_and_other_devices_pull_them(client, devices):
    pc, phone = devices
    out = push(client, pc, sale(1), sale(2))
    assert out["accepted"] == ["sales:s1", "sales:s2"] and out["rejected"] == []
    # Sending again (a lost response) is harmless.
    again = push(client, pc, sale(1))
    assert again["accepted"] == ["sales:s1"] and again["conflicts"] == []

    got = pull(client, phone)
    assert [c["id"] for c in got["changes"]] == ["s1", "s2"]
    assert got["latest"] == got["cursor"] and got["more"] is False
    # The device that wrote them doesn't get them back, but its cursor moves.
    mine = pull(client, pc)
    assert mine["changes"] == [] and mine["cursor"] == got["cursor"]


def test_a_changed_ledger_row_is_kept_as_first_written_and_reported(client, devices):
    pc, _ = devices
    push(client, pc, sale(1, total=4500))
    out = push(client, pc, sale(1, total=9999))
    assert out["conflicts"] == ["sales:s1"]
    assert pull(client, devices[1])["changes"][0]["data"]["total_minor"] == 4500


def test_ledger_rows_cannot_be_deleted_and_unknown_tables_are_refused(client, devices):
    pc, _ = devices
    out = push(
        client,
        pc,
        {"table": "sales", "id": "s1", "changed_at": T1, "deleted": True},
        {"table": "secrets", "id": "x", "changed_at": T1, "data": {}},
    )
    assert out["accepted"] == []
    assert [r["reason"] for r in out["rejected"]] == ["append_only", "unknown_table"]


def product(price, at):
    return {
        "table": "products",
        "id": "p1",
        "changed_at": at,
        "data": {"id": "p1", "price_minor": price},
    }


def test_master_data_last_writer_wins_even_when_the_older_edit_arrives_later(client, devices):
    pc, phone = devices
    push(client, phone, product(5000, T2))  # phone edited at 11:00
    first = pull(client, pc)
    assert first["changes"][0]["data"]["price_minor"] == 5000
    # The PC's older edit (10:00) arrives late: accepted, but it doesn't win.
    out = push(client, pc, product(4000, T1))
    assert out["accepted"] == ["products:p1"]
    assert pull(client, phone, after=first["cursor"])["changes"] == []
    assert pull(client, pc)["changes"][0]["data"]["price_minor"] == 5000
    # A newer edit wins and gets a new sequence number, so others pull it.
    push(client, pc, product(5500, T3))
    latest = pull(client, phone, after=first["cursor"])["changes"]
    assert [c["data"]["price_minor"] for c in latest] == [5500]


def test_same_time_edits_are_decided_by_device_id(client, devices):
    pc, phone = devices
    push(client, pc, product(1, T1))  # DEV1
    push(client, phone, product(2, T1))  # DEV2 > DEV1 → wins
    push(client, pc, product(3, T1))  # DEV1 again: loses to DEV2
    rows = pull(client, pc)["changes"]
    assert [c["data"]["price_minor"] for c in rows] == [2]


def test_deleting_master_data_leaves_a_tombstone_others_pull(client, devices):
    pc, phone = devices
    push(
        client,
        pc,
        {"table": "product_barcodes", "id": "b1", "changed_at": T1, "data": {"code": "1"}},
    )
    push(client, pc, {"table": "product_barcodes", "id": "b1", "changed_at": T2, "deleted": True})
    [c] = pull(client, phone)["changes"]
    assert (c["deleted"], c["data"]) == (True, None)


def test_pull_pages_by_cursor(client, devices):
    pc, phone = devices
    push(client, pc, *[sale(i) for i in range(7)])
    seen, cursor, pages = [], 0, 0
    while True:
        page = pull(client, phone, after=cursor, limit=3)
        seen += [c["id"] for c in page["changes"]]
        cursor, pages = page["cursor"], pages + 1
        if not page["more"]:
            break
    assert seen == [f"s{i}" for i in range(7)] and pages == 3


def test_pharmacies_never_see_each_other(client, devices, settings):
    pc, _ = devices
    push(client, pc, sale(1))
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
    other = client.post(
        "/auth/link", json={"phone": "0966000000", "password": "other-1", "device": DEV3}
    ).json()
    oh = auth(other["access_token"])
    assert pull(client, oh) == {"changes": [], "cursor": 0, "more": False, "latest": 0}
    # The same id in the other pharmacy is a separate row.
    push(client, oh, sale(1, total=1))
    assert pull(client, devices[1])["changes"][0]["data"]["total_minor"] == 4500


def test_sync_needs_a_linked_device(client, devices):
    assert client.get("/sync/pull").status_code == 401
    assert client.post("/sync/push", json={"changes": []}).status_code == 401


def test_concurrent_pushes_commit_in_sequence_order(client, devices):
    """With pushes serialised per pharmacy, a puller never skips a row."""
    pc, phone = devices
    errors = []

    def worker(n):
        try:
            push(client, pc if n % 2 else phone, *[sale(f"{n}-{i}") for i in range(20)])
        except Exception as e:  # pragma: no cover - reported below
            errors.append(e)

    threads = [threading.Thread(target=worker, args=(n,)) for n in range(6)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    assert errors == []
    # Pages read by a third device see every row exactly once.
    other = client.post(
        "/auth/link",
        json={
            "phone": "0944123456",
            "password": "secret-1",
            "device": {"id": "0190a000-0000-7000-8000-00000000000a", "name": "3"},
        },
    ).json()
    oh = auth(other["access_token"])
    seen, cursor = set(), 0
    while True:
        page = pull(client, oh, after=cursor, limit=17)
        seen |= {c["id"] for c in page["changes"]}
        cursor = page["cursor"]
        if not page["more"]:
            break
    assert len(seen) == 120
