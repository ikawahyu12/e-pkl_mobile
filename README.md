# e_pkl

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Web fonts

Montserrat is bundled locally with explicit static weights from 400 to 900 in
`assets/fonts/`; no external font service is required. After changing font
assets or their weight declarations, rebuild the web app. Flutter Web's service
worker can keep serving an older font bundle; if an already-open browser still
shows the old font, unregister the app's service worker and clear its site data
in browser DevTools, then reload the page.

## Connecting to the local API

The Android emulator uses `http://10.0.2.2:8000/api/v1` by default. A physical
device must use the development computer's reachable LAN address, with both
devices on the same network and the API server/firewall allowing the connection:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

Replace `192.168.1.10` with the computer's actual LAN IP. Use the same
`--dart-define` when building a deployed app and provide its public HTTPS API
URL.
