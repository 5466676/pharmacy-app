"""Server administration from the command line.

    python -m app.cli create-pharmacy --name "صيدلية الشفاء" --owner-name "سامر" \\
        --owner-phone 0944123456 --password '...'
    python -m app.cli list
    python -m app.cli set-status <pharmacy-id> active|suspended
    python -m app.cli reset-password <phone> <new-password>
"""

import argparse
import sys

from sqlalchemy import select

from .config import get_settings
from .db import Database
from .models import Pharmacy, User
from .security import hash_password, new_id, normalize_phone


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
    args = parser.parse_args(argv)

    db = Database(database_url or get_settings().database_url)
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
