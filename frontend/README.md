# TaskFlow (Flutter)

Flutter client for the Express/MongoDB task API. Clean architecture, Riverpod (no code generation), go_router, Dio.

## First-time setup
This archive contains `lib/`, `pubspec.yaml` and `analysis_options.yaml` only.

```bash
flutter create --org com.example --project-name taskflow_app taskflow_app_tmp
cp -r taskflow_app_tmp/{android,ios,web,macos,linux,windows,.gitignore,.metadata} .   # whichever platforms you need
rm -rf taskflow_app_tmp test/widget_test.dart      # the default counter test no longer applies
flutter pub get
flutter analyze
```

## Run
```bash
# API running on your machine (npm run dev). Defaults:
#   Android emulator -> http://10.0.2.2:3000/api    iOS sim / web / desktop -> http://localhost:3000/api
flutter run
# or point it elsewhere
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api
```
Sign in with the seeded user: `admin@example.com` / `Password123!`.

**Android + plain HTTP:** for local development add `android:usesCleartextTraffic="true"` to the
`<application>` tag in `android/app/src/main/AndroidManifest.xml`. Remove it when you move to HTTPS.
You also need `<uses-permission android:name="android.permission.INTERNET"/>` in release builds
(debug already has it).

## Architecture
```
lib/
  main.dart
  app/                      composition root: theme, router, MaterialApp
  core/                     shared, feature-agnostic code
    config/                 AppConfig (base URL)
    error/                  exceptions (data layer) + failures (domain/UI)
    network/                Dio provider, auth interceptor, error mapping, response helpers
    storage/                flutter_secure_storage wrapper, token storage
    usecase/                UseCase<T, P> + NoParams
    utils/                  Result<T> (Success / Err), runCatching, formatters
    widgets/                AsyncValueView, ErrorView
  features/<feature>/       auth | dashboard | projects | tasks | home
    domain/                 entities, repository interfaces, use cases   (pure Dart)
    data/                   models (JSON), remote/local data sources, repository impls
    presentation/           Riverpod providers (DI + state), pages, widgets
```

Dependency rule: `presentation → domain ← data`. The domain layer never imports Flutter, Dio or JSON code.

Request flow: `Page → provider → UseCase → Repository (interface) → RepositoryImpl → DataSource → Dio → API`.

Errors: data sources throw `AppException`s (via `guardApi`); repositories turn them into `Failure`s with
`runCatching`; use cases return `Result<T>`; providers call `getOrThrow()` so pages get an `AsyncValue` error.

Auth: login stores the JWT (+ user JSON) in secure storage; the interceptor adds `Authorization: Bearer ...`;
a 401 on a protected call signs the user out and the router redirects to `/login`.

## Status
| Feature | State |
|---|---|
| Login, session restore, logout, 401 handling | done |
| Dashboard (stats, recent projects, upcoming deadlines) | done |
| Projects (list, create, archive/unarchive, open -> its tasks) | done |
| Tasks (list, filter, search, complete, delete) | done |
| Create / edit task form (`TaskFormPage`) | TODO (stub with notes) |
| Edit project name/description (use case + endpoint ready) | TODO (UI) |
| Tasks pagination (first 50 shown) | TODO |

## Adding a feature
1. `domain/`: entity, repository interface, use case(s)
2. `data/`: model, remote data source (wrap calls in `guardApi`), repository impl (wrap in `runCatching`)
3. `presentation/providers/`: DI providers + a `FutureProvider` / `AsyncNotifier`
4. Page + route in `lib/app/app_router.dart`
