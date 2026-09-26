# apps/patient

Patient app (Flutter, Android + web): an AI consultation that goes to your chosen pharmacy, the pharmacy's shelf and orders for pickup, dose reminders. Talks to the central server (`backend/`, see docs/DECISIONS.md).

```bash
flutter test
flutter run -d chrome --web-port 8200 --dart-define=DOAYA_API=http://127.0.0.1:8100
flutter run -d emulator-5554 --dart-define=DOAYA_API=http://10.0.2.2:8100   # debug builds allow plain http
flutter build web --no-web-resources-cdn --dart-define=DOAYA_API=https://…
```

- The server must allow the web app's address: `DOAYA_CORS_ORIGINS=http://localhost:8200` (or wherever it's hosted).
- Emergency numbers default to 110 / 112: `--dart-define=DOAYA_AMBULANCE=… --dart-define=DOAYA_EMERGENCY=…`.
