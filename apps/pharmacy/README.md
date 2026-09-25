# apps/pharmacy — Doaya pharmacy app

Offline-first counter app: POS, inventory with expiry, customer debts. The local SQLite (drift) database is the source of truth; stock and debts are append-only event ledgers (`doaya_core`).

```bash
flutter pub get                       # at repo root
dart run build_runner build           # regenerate drift code after editing lib/data/database.dart
flutter test
flutter run -d windows                # or -d linux while developing
flutter build windows --release       # on a Windows machine
```
