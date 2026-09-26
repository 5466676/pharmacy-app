# apps/admin

The platform owner's admin panel (Flutter web, Phase 4): overview, pharmacies
and their control (suspend / stop / remove / licence), performance for
rewards, the review queue and the knowledge base.

```bash
# on the central server: an admin account (no sign-up screen)
cd backend && .venv/bin/python -m app.cli create-admin --name "..." --phone 09.. --password '...'
# server started with DOAYA_CORS_ORIGINS=http://localhost:8300
cd apps/admin && flutter run -d chrome --web-port 8300 --dart-define=DOAYA_API=http://127.0.0.1:8100
flutter build web --no-web-resources-cdn --dart-define=DOAYA_API=https://...
```
