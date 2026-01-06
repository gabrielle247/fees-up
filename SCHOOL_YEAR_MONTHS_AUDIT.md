# School Year & Month Audit (Alpha)

## Data Layer
- Local schema synced: `school_years` (school_id, year_label, start_date, end_date, description, active, created_at) and `school_year_months` (school_year_id, school_id, name, month_index, start_date, end_date, is_billable, created_at) — both present in [lib/data/services/schema.dart](lib/data/services/schema.dart#L93-L153).
- UI references a `status` field for school years ([school_year_registry_card.dart](lib/pc/widgets/settings/school_year_registry_card.dart#L66-L118)), but the schema only has `active` (int). Result: status shows as “Draft” for all rows.
- No provider for months. Only `schoolYearsProvider` exists ([settings_provider.dart](lib/data/providers/settings_provider.dart#L33-L76)). `school_year_months` is read ad-hoc in [student_dialog.dart](lib/pc/widgets/dashboard/student_dialog.dart#L245-L312) for auto-billing; if months aren’t synced/seeded, auto-billing quietly fails.
- Settings providers still query `user_settings` / `school_preferences`, which are absent locally; server tables are `user_global_settings` / `user_school_preferences`.

## UI Layer
- Registry table shows years from `schoolYearsProvider`; “Add New Year” is a dead click ([school_year_registry_card.dart](lib/pc/widgets/settings/school_year_registry_card.dart#L28-L76)).
- Year configuration card is entirely static demo data (no provider, no mutations) ([year_configuration_card.dart](lib/pc/widgets/settings/year_configuration_card.dart#L1-L150)).
- No month editor/viewer; months are invisible in UI despite being critical for billing cycles and auto-billing.

## Risks
- Auto-billing for new students can’t find an active month/year if data isn’t seeded, leading to missing bills.
- Status/active mismatch: UI implies lifecycle states that the data model doesn’t store.
- Users cannot create or edit years/months in-app; only existing synced data is visible.

## Recommendations (offline-first, minimal footprint)
1) **Unify status field:** derive UI status from `active` (1 = Active, 0 = Draft) or add a `status` text column to `school_years` and sync.
2) **Add months provider:** create `schoolYearMonthsProvider(schoolYearId)` to read months; show them in the configuration card.
3) **Seed data:** ensure `school_years` and `school_year_months` rows sync for each school (one active year, 12 months, billable flag). Keep audit tables server-only.
4) **Wire actions:**
   - “Add New Year” → insert skeleton year with dates and set `active=0`.
   - Year config form → edit/save to local DB (and sync), including month rows.
   - Guard deletes/edits behind offline-safe transactions.
5) **Settings tables:** align providers to `user_global_settings` / `user_school_preferences` or add those tables locally to make preference toggles persist.
