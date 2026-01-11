# Fees Up

Production-minded Flutter app with Supabase + PowerSync.

## Run & Debug

- This app requires compile-time secrets via `--dart-define`:
 	- `SUPABASE_URL`
 	- `SUPABASE_ANON_KEY`
 	- `POWERSYNC_ENDPOINT_URL`
 	- `ENVIRONMENT` (development|staging|production)

### VS Code

- Use the preconfigured Run and Debug profiles in `.vscode/launch.json`.
- Set the values as environment variables on your machine to avoid committing secrets:

```bash
export SUPABASE_URL="https://YOUR.supabase.co"
export SUPABASE_ANON_KEY="YOUR_ANON_KEY"
export POWERSYNC_ENDPOINT_URL="https://powersync.example.com"
```

- Then select a profile like "Fees Up (Web) — Development" and press F5.

### CLI (optional)

```bash
flutter run -d chrome \
 --dart-define=SUPABASE_URL=$SUPABASE_URL \
 --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
 --dart-define=POWERSYNC_ENDPOINT_URL=$POWERSYNC_ENDPOINT_URL \
 --dart-define=ENVIRONMENT=development
```

## Build Tasks

- Use VS Code Tasks in `.vscode/tasks.json`:
 	- "Flutter: Pub Get" — installs dependencies
 	- "Flutter: Test" — runs tests
 	- "Build Android (Release)" — generates a release APK with defines
 	- "Build Web (Release)" — builds the production web bundle

## Notes

- Backend initialization validates that all required defines are present (see `lib/data/initilize/env.dart`).
- Router uses auth/onboarding gates (see `lib/router.dart`).
