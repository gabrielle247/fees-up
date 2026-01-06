# Alpha Release Dead-Click Audit

Offline-first focus: only wire what’s critical for alpha; mark or hide the rest to avoid confusing users and to keep the local DB lean. Links point to empty `onPressed` handlers.

## Must Work for Alpha
- Add Student CTA: [pc/screens/students_screen.dart](lib/pc/screens/students_screen.dart#L107)
- Student detail actions (payments/invoices): [pc/screens/student_details_screen.dart](lib/pc/screens/student_details_screen.dart#L310-L338) and [pc/screens/student_details_screen.dart](lib/pc/screens/student_details_screen.dart#L657)
- Invoice actions header: [pc/widgets/invoices/invoices_header.dart](lib/pc/widgets/invoices/invoices_header.dart#L92)
- Password change + forgot password: [pc/widgets/profile/security_password_view.dart](lib/pc/widgets/profile/security_password_view.dart#L99-L102)
- Notifications screen primary CTA: [pc/screens/notifications_screen.dart](lib/pc/screens/notifications_screen.dart#L65)
- Announcements screen primary CTA: [pc/screens/announcements_screen.dart](lib/pc/screens/announcements_screen.dart#L73)

## Should Be Wired or Clearly Labeled
- Transactions header CTA: [pc/widgets/transactions/transactions_header.dart](lib/pc/widgets/transactions/transactions_header.dart#L84)
- Students header secondary CTA: [pc/widgets/students/students_header.dart](lib/pc/widgets/students/students_header.dart#L102)
- Year configuration actions: [pc/widgets/settings/year_configuration_card.dart](lib/pc/widgets/settings/year_configuration_card.dart#L88-L161)
- School year registry actions: [pc/widgets/settings/school_year_registry_card.dart](lib/pc/widgets/settings/school_year_registry_card.dart#L49)
- Settings header buttons: [pc/widgets/settings/settings_header.dart](lib/pc/widgets/settings/settings_header.dart#L181-L186)
- Users & permissions actions: [pc/widgets/settings/users_permissions_view.dart](lib/pc/widgets/settings/users_permissions_view.dart#L55-L355)
- Notification settings toggles: [pc/widgets/settings/notifications_settings_view.dart](lib/pc/widgets/settings/notifications_settings_view.dart#L67-L253)

## Integrations (Mark Coming Soon unless ready)
- Connected services: [pc/widgets/settings/integrations/connected_services_card.dart](lib/pc/widgets/settings/integrations/connected_services_card.dart#L115-L119)
- API config: [pc/widgets/settings/integrations/api_config_card.dart](lib/pc/widgets/settings/integrations/api_config_card.dart#L65)
- Teacher tokens: [pc/widgets/settings/integrations/teacher_tokens_card.dart](lib/pc/widgets/settings/integrations/teacher_tokens_card.dart#L32)

## Low Priority / Mobile Parity
- Mobile home quick actions: [mobile/screens/mobile_home_screen.dart](lib/mobile/screens/mobile_home_screen.dart#L172-L233)
- Activity log CTA (server-only data; keep server-only): [pc/widgets/profile/activity_log_view.dart](lib/pc/widgets/profile/activity_log_view.dart#L24)

## Recommendations
1. For each “Must Work,” either wire to existing offline-safe flows or remove until functional—no dead-clicks.
2. For “Should Be Wired,” prefer a small snackbar “Coming soon” if backend/UI isn’t ready; hide if misleading.
3. Leave integrations as “Coming Soon” to keep offline DB light and avoid faux connectivity.
4. After fixes, rerun a grep for `onPressed: () {}` to ensure no dead-clicks remain in alpha-critical surfaces.
