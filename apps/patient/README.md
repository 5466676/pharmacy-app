# apps/patient

Patient app (Flutter, Android + web): an AI consultation that goes to your chosen pharmacy, the pharmacy's shelf and orders for pickup, dose reminders. Talks to the central server (`backend/`, see docs/DECISIONS.md).

```bash
flutter run -d chrome --dart-define=DOAYA_API=http://127.0.0.1:8100
flutter build web --no-web-resources-cdn --dart-define=DOAYA_API=https://…
```
