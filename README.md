# Maktoob — mobile app

The event host's app: event wizard, guests, invitation designs, payment and the offline door (QR check-in).

- Architecture, conventions and the API contract: `../CLAUDE.md` (Mobile section) and `API_ENDPOINTS.md`.
- Look and feel: `DESIGN.md`. Product rules: `PRODUCT.md`.

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://<LAN-IP>:8000/api/v1
```
