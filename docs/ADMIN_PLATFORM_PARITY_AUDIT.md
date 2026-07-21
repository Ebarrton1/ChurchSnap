# ChurchSnap Admin Platform Parity Audit

- Generated: 2026-07-21 14:22:26 -04:00
- Branch: churchsnap-testing-stabilization
- Working tree at audit start: clean
- Dart files scanned: 203
- Candidate one-sided capability gaps: 12

> This is a source-discovery audit. A keyword match indicates that a capability is likely represented in source; it does not by itself prove navigation, permissions, Firestore rules, and full workflow parity.

## Capability matrix

| Capability | Android/mobile | Web dashboard | Result | Mobile evidence | Web evidence |
|---|---:|---:|---|---|---|
| Dashboard overview | Yes | Yes | Candidate on both | lib/features/dashboard/providers/dashboard_providers.dart<br>lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/members/models/member_count_summary.dart<br>lib/screens/admin/admin_dashboard_screen.dart<br>lib/screens/admin/admin_member_count_management_screen.dart<br>lib/screens/admin/admin_member_demographics_screen.dart | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_staff_access.dart<br>lib/features/web_admin/widgets/web_admin_responsive_navigation.dart |
| Action center | No | Yes | Web candidate only |  | lib/features/web_admin/models/web_admin_action_item.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart |
| Sermons and media | Yes | No | Mobile candidate only | lib/core/demo/demo_data.dart<br>lib/core/providers/repository_providers.dart<br>lib/features/auth/screens/guest_account_screen.dart<br>lib/features/sermons/providers/sermon_providers.dart<br>lib/features/sermons/repositories/sermon_bookmark_repository.dart<br>lib/features/sermons/repositories/sermon_download_repository.dart |  |
| Events and RSVP administration | Yes | Yes | Candidate on both | lib/core/demo/demo_data.dart<br>lib/core/providers/repository_providers.dart<br>lib/features/admin/providers/admin_providers.dart<br>lib/features/admin/services/admin_event_service.dart<br>lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/auth/screens/guest_account_screen.dart | lib/features/web_admin/models/web_admin_report_snapshot.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| Members and directory | Yes | No | Mobile candidate only | lib/screens/admin/admin_dashboard_screen.dart<br>lib/screens/admin/admin_member_count_management_screen.dart<br>lib/screens/admin/admin_member_directory_screen.dart<br>lib/screens/admin/admin_members_screen.dart<br>lib/screens/profile/edit_my_member_profile_screen.dart<br>lib/screens/profile/profile_screen.dart |  |
| Prayer and pastoral care | Yes | Yes | Candidate on both | lib/features/auth/screens/guest_account_screen.dart<br>lib/features/prayer/repositories/prayer_repository.dart<br>lib/screens/admin/admin_dashboard_screen.dart<br>lib/screens/admin/admin_prayer_requests_screen.dart<br>lib/screens/home/churchsnap_shell.dart<br>lib/screens/prayer/prayer_screen.dart | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart |
| Giving and funds | Yes | Yes | Candidate on both | lib/features/giving/models/donation_record.dart<br>lib/features/giving/models/giving_submission.dart<br>lib/features/giving/models/standard_giving_funds.dart<br>lib/features/giving/repositories/giving_repository.dart<br>lib/features/giving/repositories/giving_submission_repository.dart<br>lib/features/giving/services/giving_confirmation_ledger.dart | lib/features/web_admin/models/web_admin_donation_amount.dart<br>lib/features/web_admin/models/web_admin_report_snapshot.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart |
| Attendance and check-in | Yes | No | Mobile candidate only | lib/features/attendance/models/attendance_check_in_document.dart<br>lib/features/attendance/models/attendance_record.dart<br>lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/attendance/services/qr_check_in_service.dart<br>lib/features/auth/screens/guest_account_screen.dart<br>lib/features/check_in/repositories/check_in_repository.dart |  |
| Notifications and announcements | Yes | No | Mobile candidate only | lib/core/demo/demo_data.dart<br>lib/core/providers/repository_providers.dart<br>lib/core/services/notification_service.dart<br>lib/features/admin/providers/admin_providers.dart<br>lib/features/admin/services/admin_announcement_service.dart<br>lib/features/announcements/providers/announcement_providers.dart |  |
| Resources and documents | Yes | No | Mobile candidate only | lib/features/resources/models/church_resource.dart<br>lib/screens/admin/admin_dashboard_screen.dart<br>lib/screens/admin/admin_media_screen.dart<br>lib/screens/admin/admin_resources_screen.dart<br>lib/screens/media/media_detail_screen.dart<br>lib/screens/media/media_screen.dart |  |
| Home, branding and church profile | Yes | No | Mobile candidate only | lib/screens/settings/church_settings_screen.dart |  |
| Sunday and Sabbath worship settings | Yes | No | Mobile candidate only | lib/core/constants/church_config.dart<br>lib/core/demo/demo_data.dart<br>lib/features/resources/models/church_resource.dart<br>lib/features/worship/models/worship_settings.dart<br>lib/screens/admin/admin_dashboard_screen.dart<br>lib/screens/admin/admin_worship_settings_screen.dart |  |
| Staff access and role management | Yes | Yes | Candidate on both | lib/core/auth/app_roles.dart<br>lib/features/auth/screens/live_member_session.dart<br>lib/features/auth/state/auth_controller.dart<br>lib/features/notifications/models/app_notification.dart<br>lib/screens/admin/admin_notifications_screen.dart<br>lib/screens/admin/admin_role_management_screen.dart | lib/features/web_admin/models/web_admin_staff_member.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_audit_log.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart<br>lib/features/web_admin/screens/web_admin_staff_access.dart<br>lib/features/web_admin/services/web_admin_staff_access_service.dart |
| Administrative activity log | No | Yes | Web candidate only |  | lib/features/web_admin/models/web_admin_audit_entry.dart<br>lib/features/web_admin/screens/web_admin_audit_log.dart<br>lib/features/web_admin/screens/web_admin_staff_access.dart<br>lib/features/web_admin/services/web_admin_audit_log_service.dart<br>lib/features/web_admin/services/web_admin_staff_access_service.dart |
| Operations reports | No | Yes | Web candidate only |  | lib/features/web_admin/models/web_admin_report_snapshot.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| Ministries, groups and volunteers | Yes | Yes | Candidate on both | lib/core/auth/app_roles.dart<br>lib/core/demo/demo_data.dart<br>lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/giving/models/standard_giving_funds.dart<br>lib/features/ministries/models/ministry.dart<br>lib/features/ministries/providers/ministry_providers.dart | lib/features/web_admin/screens/web_admin_staff_access.dart |
| Baptism, communion and membership care | Yes | No | Mobile candidate only | lib/features/members/models/member_baptism_record.dart<br>lib/features/members/providers/member_baptism_providers.dart<br>lib/features/members/repositories/member_baptism_repository.dart<br>lib/screens/admin/admin_dashboard_screen.dart<br>lib/screens/admin/admin_recent_baptisms_screen.dart<br>lib/screens/profile/edit_my_member_profile_screen.dart |  |
| Live stream and media operations | Yes | No | Mobile candidate only | lib/screens/admin/admin_media_screen.dart<br>lib/screens/media/media_detail_screen.dart<br>lib/screens/media/media_screen.dart |  |
| Security and settings | Yes | Yes | Candidate on both | lib/features/giving/models/giving_currency.dart<br>lib/features/giving/repositories/giving_currency_repository.dart<br>lib/features/home/providers/home_appearance_provider.dart<br>lib/features/home/providers/pastor_appearance_provider.dart<br>lib/features/members/models/upcoming_celebration.dart<br>lib/features/members/repositories/member_celebration_repository.dart | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_audit_log.dart<br>lib/features/web_admin/screens/web_admin_staff_access.dart |

## Detected Android/mobile admin classes

- AdminAnnouncementsListScreen - lib/screens/admin/admin_announcements_list_screen.dart
- AdminAnnouncementsScreen - lib/screens/admin/admin_announcements_screen.dart
- AdminAttendanceScreen - lib/screens/admin/admin_attendance_screen.dart
- AdminCalendarScreen - lib/screens/admin/admin_calendar_screen.dart
- AdminChurchConnectionScreen - lib/screens/admin/admin_church_connection_screen.dart
- AdminDashboardScreen - lib/screens/admin/admin_dashboard_screen.dart
- AdminEventsScreen - lib/screens/admin/admin_events_screen.dart
- AdminGivingConfirmationsScreen - lib/screens/admin/admin_giving_confirmations_screen.dart
- AdminGivingCurrencyScreen - lib/screens/admin/admin_giving_currency_screen.dart
- AdminGivingScreen - lib/screens/admin/admin_giving_screen.dart
- AdminHomeAppearanceScreen - lib/screens/admin/admin_home_appearance_screen.dart
- AdminMediaScreen - lib/screens/admin/admin_media_screen.dart
- AdminMemberCountManagementScreen - lib/screens/admin/admin_member_count_management_screen.dart
- AdminMemberDemographicsScreen - lib/screens/admin/admin_member_demographics_screen.dart
- AdminMemberDirectoryScreen - lib/screens/admin/admin_member_directory_screen.dart
- AdminMemberProfileScreen - lib/screens/admin/admin_member_profile_screen.dart
- AdminMembersScreen - lib/screens/admin/admin_members_screen.dart
- AdminMinistriesScreen - lib/screens/admin/admin_ministries_screen.dart
- AdminNotificationsScreen - lib/screens/admin/admin_notifications_screen.dart
- AdminPastorPictureScreen - lib/screens/admin/admin_pastor_picture_screen.dart
- AdminPrayerRequestsScreen - lib/screens/admin/admin_prayer_requests_screen.dart
- AdminQrScannerScreen - lib/screens/admin/admin_qr_scanner_screen.dart
- AdminRecentBaptismsScreen - lib/screens/admin/admin_recent_baptisms_screen.dart
- AdminResourcesScreen - lib/screens/admin/admin_resources_screen.dart
- AdminRoleManagementScreen - lib/screens/admin/admin_role_management_screen.dart
- AdminSermonsScreen - lib/screens/admin/admin_sermons_screen.dart
- AdminSmallGroupsScreen - lib/screens/admin/admin_small_groups_screen.dart
- AdminUpcomingCelebrationsScreen - lib/screens/admin/admin_upcoming_celebrations_screen.dart
- AdminVolunteerScheduleScreen - lib/screens/admin/admin_volunteer_schedule_screen.dart
- AdminWorshipSettingsScreen - lib/screens/admin/admin_worship_settings_screen.dart

## Detected web-admin classes

- ChurchSnapWebAdminShell - lib/features/web_admin/screens/churchsnap_web_admin_shell.dart
- WebAdminAuditLogScreen - lib/features/web_admin/screens/web_admin_audit_log.dart
- WebAdminStaffAccessScreen - lib/features/web_admin/screens/web_admin_staff_access.dart

## Parity acceptance criteria

A capability should be marked fully aligned only when all of the following are true:

1. The same role or permission grants the action on Android and web.
2. The action is reachable from each platform's admin navigation.
3. Both platforms read and write the same Firebase collections and field schema.
4. Firestore and Storage rules authorize the action independently of hidden UI.
5. Destructive actions use confirmations and self-protection where applicable.
6. Sensitive actions produce an administrative audit record.
7. Automated tests cover allowed and denied roles on both platforms.

## Recommended implementation direction

Use one shared admin capability registry and one shared permission service. Android and web may use different layouts, but they should derive visibility and authorization from the same capability identifiers and role rules.
