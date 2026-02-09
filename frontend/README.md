# Dental Management Frontend (Flutter)

Two main screens wired with routing:
- `/login` – SmartNest-style login (remember me, password toggle, social buttons).
- `/dashboard` – sidebar + stats + appointments layout inspired by the provided design.

## Structure
- `lib/main.dart` – boots the app.
- `lib/src/app.dart` – routes and theme wiring.
- `lib/src/config/theme.dart` – colors + theming.
- `lib/src/screens/auth/login_screen.dart` – login UI.
- `lib/src/screens/dashboard/dashboard_screen.dart` – dashboard shell.
  - `widgets/sidebar.dart` – navigation rail.
  - `widgets/stat_card.dart` – progress cards.
  - `widgets/appointment_card.dart` – appointment rows.

## Run
```
cd frontend
flutter pub get
flutter run
```
You can hot-reload between `/login` and `/dashboard` using:
- `Navigator.pushReplacementNamed(context, '/dashboard');`

## Next hookups
- Replace mock login delay with real API call to `POST /api/auth/login` and store JWT.
- Fetch appointments/patients from backend and feed into the dashboard.
- Add assets: place `assets/avatar_placeholder.png` in `assets/` and update `pubspec.yaml` to include it.
