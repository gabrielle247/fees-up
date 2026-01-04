# PowerSync Initialization Overview

This document explains how PowerSync is initialized when the app starts and how credentials are supplied.

## Startup Flow (app launch)
1) **Supabase keys are loaded** in `main.dart` from dart-defines (`SUPABASE_URL`, `SUPABASE_ANON_KEY`). If missing, Supabase is not initialized and downstream PowerSync cannot connect.
2) **Supabase.initialize(...)** runs with the provided URL and anon key.
3) **DatabaseService.initialize()** is called in `main.dart`:
   - Creates local database path: `<appSupportDir>/greyway_feesup.db`.
   - Instantiates `PowerSyncDatabase(schema: appSchema, path: dbPath)`.
   - Calls `_db.initialize()`.
   - Builds a `SupabaseConnector(Supabase.instance.client)` and calls `_db.connect(connector: connector)`.
   - Sets `_isInitialized = true`.

## SupabaseConnector (credentials + upload)
- File: lib/data/services/supabase_connector.dart
- `fetchCredentials()`
  - Reads current Supabase session: `db.auth.currentSession`. If `null`, returns `null` (PowerSync will keep retrying and log credentials errors).
  - Reads endpoint from dart-define `POWERSYNC_ENDPOINT_URL`; throws if empty.
  - Returns `PowerSyncCredentials(endpoint, token=session.accessToken, userId=session.user.id)`.
- `uploadData()`
  - Processes queued CRUD ops from PowerSync and mirrors them to Supabase via REST (`upsert`/`update`/`delete`).
  - On RLS or FK violations (42501, 23503) it completes the transaction to avoid blocking the queue; other errors rethrow so PowerSync retries.

## Schema
- File: lib/data/services/schema.dart
- Defines `appSchema` for the local SQLite backing PowerSync. This must match Supabase tables for sync to be consistent.

## Required runtime values (dart-defines / env)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` (for Supabase.initialize).
- `POWERSYNC_ENDPOINT_URL` (PowerSync endpoint).
- A valid Supabase session (user must be signed in) so `fetchCredentials` can supply a token.

## What happens on launch
- If Supabase keys are missing: Supabase init fails, so `Supabase.instance.client` is not ready and PowerSync cannot connect.
- If user is not signed in: `fetchCredentials` returns `null`; PowerSync logs repeated "Credentials error: Not logged in" until a session exists.
- If `POWERSYNC_ENDPOINT_URL` is empty: connector throws an exception and PowerSync cannot start syncing.

## Where to look in code
- App entry: lib/main.dart (Supabase initialize + DatabaseService.initialize).
- PowerSync DB + connect: lib/data/services/database_service.dart.
- Credentials + upload: lib/data/services/supabase_connector.dart.
- Schema: lib/data/services/schema.dart.

## Quick checklist to get sync working
- Provide dart-defines via `make run` (or your runner): `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `POWERSYNC_ENDPOINT_URL`, `POWERSYNC_API_KEY` (if used elsewhere), `UFT_PASSWORD`.
- Ensure user is authenticated before expecting PowerSync to connect (session required for token).
- Confirm `POWERSYNC_ENDPOINT_URL` matches your PowerSync service.
- Watch logs: repeated `CredentialsException: Not logged in` means no Supabase session; supply login before sync.
## Fresh assessment (post-incident)
- The repeated `Credentials error: Not logged in` loop is expected when no Supabase session exists; PowerSync keeps polling `fetchCredentials()` and gets `null`.
- Missing `POWERSYNC_ENDPOINT_URL` will throw during `fetchCredentials`, blocking connect.
- Supabase initialization depends entirely on dart-defines; if they are empty, `Supabase.instance.client` is unusable and the downstream connect quietly fails.

## Recommended hardening (no code changes committed yet)
1) Validate env on startup: in `main.dart`, fail fast if `SUPABASE_URL`, `SUPABASE_ANON_KEY`, or `POWERSYNC_ENDPOINT_URL` are empty; surface a clear UI error.
2) Auth-gated connect: if `Supabase.instance.client.auth.currentSession` is `null`, route to an auth-required screen and delay `DatabaseService.initialize()` until login completes.
3) Throttle the retry noise: when `fetchCredentials()` returns `null`, log once and back off retries to avoid spam while prompting the user to sign in.
4) Endpoint sanity: optionally validate `POWERSYNC_ENDPOINT_URL` format (https + host) before attempting to connect.

## If/when we implement
- Add env validation before `Supabase.initialize` in `main.dart`.
- After Supabase init, check session; if absent, show an auth gate and only then run `DatabaseService.initialize()`.
- In `SupabaseConnector.fetchCredentials()`, keep returning `null` when unauthenticated but debounce logging; throw only on bad endpoint config.