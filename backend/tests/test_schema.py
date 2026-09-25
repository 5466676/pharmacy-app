import pytest
from alembic import command
from sqlalchemy import create_engine, text
from sqlalchemy.exc import IntegrityError

from .conftest import alembic_config


def add_pharmacy(c, pid: str) -> None:
    c.execute(
        text("INSERT INTO pharmacies (id, name, status) VALUES (:id, 'x', 'active')"), {"id": pid}
    )


def add_row(c, pid: str, row: str) -> int:
    return c.execute(
        text(
            "INSERT INTO sync_rows (pharmacy_id, table_name, row_id, data, deleted, changed_at,"
            " device_id) VALUES (:p, 'stock_events', :r, '{}', false, now(), 'd') RETURNING seq"
        ),
        {"p": pid, "r": row},
    ).scalar_one()


def test_same_row_id_in_two_pharmacies_is_two_rows_but_not_twice_in_one(engine):
    with engine.begin() as c:
        add_pharmacy(c, "a")
        add_pharmacy(c, "b")
        add_row(c, "a", "r1")
        add_row(c, "b", "r1")
    with pytest.raises(IntegrityError), engine.begin() as c:
        add_row(c, "a", "r1")


def test_every_change_gets_a_higher_sequence_number(engine):
    with engine.begin() as c:
        add_pharmacy(c, "a")
        seqs = [add_row(c, "a", f"r{i}") for i in range(3)]
    assert seqs == sorted(seqs) and len(set(seqs)) == 3


def test_migrations_go_down_and_up_again(migrated):
    cfg = alembic_config(migrated)
    command.downgrade(cfg, "base")
    engine = create_engine(migrated)
    with engine.connect() as c:
        tables = c.execute(
            text(
                "SELECT count(*) FROM pg_tables WHERE schemaname = 'public'"
                " AND tablename <> 'alembic_version'"
            )
        ).scalar_one()
    engine.dispose()
    assert tables == 0
    command.upgrade(cfg, "head")
