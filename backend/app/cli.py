"""Server administration from the command line.

    python -m app.cli create-pharmacy --name "صيدلية الشفاء" --owner-name "سامر" \\
        --owner-phone 0944123456 --password '...'
    python -m app.cli list
    python -m app.cli set-status <pharmacy-id> active|suspended
    python -m app.cli reset-password <phone> <new-password>
    python -m app.cli backup                 # a backup now (also done daily)
    python -m app.cli list-backups
    python -m app.cli restore <file.dump>    # replaces the database's content
    python -m app.cli server-code            # the code devices show when linking

Central (internet) server:
    python -m app.cli list-pharmacy <pharmacy-id> --code SH4F --city دمشق \\
        [--address ...] [--phone ...] [--hours "9 - 23"] [--hide]
    python -m app.cli pharmacy-key <pharmacy-id>   # for its server's DOAYA_CENTRAL_KEY
    python -m app.cli create-admin --name "..." --phone 09.. --password '...'
        # the platform owner's admin panel (no sign-up screen)
"""

import argparse
import sys
from pathlib import Path

from sqlalchemy import select

from .backup import backup_now, list_backups, restore
from .central import list_pharmacy, new_pharmacy_key
from .config import Settings, get_settings
from .db import Database
from .models import Pharmacy, User
from .security import hash_password, new_id, normalize_phone
from .tls import ensure_certificate


def main(argv: list[str] | None = None, database_url: str | None = None) -> int:
    parser = argparse.ArgumentParser(prog="doaya")
    sub = parser.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("create-pharmacy")
    c.add_argument("--name", required=True)
    c.add_argument("--owner-name", required=True)
    c.add_argument("--owner-phone", required=True)
    c.add_argument("--password", required=True)
    sub.add_parser("list")
    s = sub.add_parser("set-status")
    s.add_argument("pharmacy_id")
    s.add_argument("status", choices=["active", "pending", "suspended"])
    r = sub.add_parser("reset-password")
    r.add_argument("phone")
    r.add_argument("password")
    sub.add_parser("backup")
    sub.add_parser("list-backups")
    rs = sub.add_parser("restore")
    rs.add_argument("file")
    sub.add_parser("server-code")
    lp = sub.add_parser("list-pharmacy")
    lp.add_argument("pharmacy_id")
    lp.add_argument("--code", required=True)
    lp.add_argument("--city", required=True)
    lp.add_argument("--address")
    lp.add_argument("--phone")
    lp.add_argument("--hours")
    lp.add_argument("--hide", action="store_true")
    pk = sub.add_parser("pharmacy-key")
    pk.add_argument("pharmacy_id")
    ca = sub.add_parser("create-admin")
    ca.add_argument("--name", required=True)
    ca.add_argument("--phone", required=True)
    ca.add_argument("--password", required=True)
    args = parser.parse_args(argv)

    settings: Settings = get_settings()
    if database_url:
        settings = settings.model_copy(update={"database_url": database_url})
    if args.cmd == "backup":
        print(backup_now(settings))
        return 0
    if args.cmd == "list-backups":
        for f in list_backups(settings):
            print(f)
        return 0
    if args.cmd == "server-code":
        print(ensure_certificate(settings.data_dir).short_code)
        return 0
    if args.cmd == "restore":
        restore(settings, Path(args.file))
        return 0

    db = Database(settings.database_url)
    with db.sessions() as session:
        if args.cmd == "create-pharmacy":
            phone = normalize_phone(args.owner_phone)
            if session.scalar(select(User).where(User.phone == phone)):
                print("phone already has an account", file=sys.stderr)
                return 1
            if len(args.password) < 6:
                print("password: at least 6 characters", file=sys.stderr)
                return 1
            ph = Pharmacy(id=new_id(), name=args.name.strip(), status="active")
            session.add(ph)
            session.flush()
            session.add(
                User(
                    id=new_id(),
                    pharmacy_id=ph.id,
                    role="pharmacist_owner",
                    name=args.owner_name.strip(),
                    phone=phone,
                    password_hash=hash_password(args.password),
                    active=True,
                )
            )
            session.commit()
            print(ph.id)
        elif args.cmd == "create-admin":
            phone = normalize_phone(args.phone)
            if session.scalar(select(User).where(User.phone == phone)):
                print("phone already has an account", file=sys.stderr)
                return 1
            if len(args.password) < 10:
                print("password: at least 10 characters", file=sys.stderr)
                return 1
            user = User(
                id=new_id(),
                pharmacy_id=None,
                role="admin",
                name=args.name.strip(),
                phone=phone,
                password_hash=hash_password(args.password),
                active=True,
            )
            session.add(user)
            session.commit()
            print(user.id)
        elif args.cmd == "list":
            for ph in session.scalars(select(Pharmacy).order_by(Pharmacy.created_at)):
                print(f"{ph.id}\t{ph.status}\t{ph.name}")
        elif args.cmd == "set-status":
            ph = session.get(Pharmacy, args.pharmacy_id)
            if ph is None:
                print("no such pharmacy", file=sys.stderr)
                return 1
            ph.status = args.status
            session.commit()
        elif args.cmd in ("list-pharmacy", "pharmacy-key"):
            if session.get(Pharmacy, args.pharmacy_id) is None:
                print("no such pharmacy", file=sys.stderr)
                return 1
            if args.cmd == "pharmacy-key":
                print(new_pharmacy_key(session, args.pharmacy_id))
            else:
                list_pharmacy(
                    session,
                    args.pharmacy_id,
                    code=args.code,
                    city=args.city,
                    address=args.address,
                    phone=args.phone,
                    hours=args.hours,
                    listed=not args.hide,
                )
        elif args.cmd == "reset-password":
            user = session.scalar(select(User).where(User.phone == normalize_phone(args.phone)))
            if user is None:
                print("no such account", file=sys.stderr)
                return 1
            user.password_hash = hash_password(args.password)
            session.commit()
    return 0


if __name__ == "__main__":
    sys.exit(main())
