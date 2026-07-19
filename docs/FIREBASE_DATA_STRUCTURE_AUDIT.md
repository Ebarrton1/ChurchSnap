# ChurchSnap Firebase Data Structure Audit

## Interpretation Note

The first-pass Android/web classification below is based mainly on literal `.collection('name')` calls. Repositories using `FirebasePaths` or `FirebaseCollectionNames` can therefore appear platform-specific even when both applications share the same Firestore collection. The detailed reference review and stabilization decisions document are the authoritative interpretation.

Generated: 2026-07-19 10:08:36

Branch: `churchsnap-testing-stabilization`

This report is a static source-code audit. It does not read or modify live Firebase data.

## Executive Summary

- Dart files scanned: 199
- Firestore collection references found: 107
- Distinct collections referenced by Dart code: 18
- Roles found in AppRoles: 7
- Shared Android/web collections: 3
- Android-only collections: 12
- Web-only collections: 3

## Shared Android and Web Collections

| Collection |
| --- |
| churches |
| events |
| members |

## Android-Only Collections

| Collection |
| --- |
| eventCheckIns |
| giving_submissions |
| media |
| memberPrivateProfiles |
| ministries |
| notifications |
| resources |
| sermonBookmarks |
| settings |
| small_groups |
| userChurchLinks |
| volunteer_assignments |

## Web-Only Collections

| Collection |
| --- |
| admin_audit_logs |
| donations |
| prayer_requests |

## Collection Reference Inventory

| Collection | References | Files |
| --- | --- | --- |
| admin_audit_logs | 2 | lib/features/web_admin/services/web_admin_audit_log_service.dart<br>lib/features/web_admin/services/web_admin_staff_access_service.dart |
| churches | 46 | lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/attendance/services/qr_check_in_service.dart<br>lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart<br>lib/features/auth/screens/live_member_session.dart<br>lib/features/auth/services/required_name_service.dart<br>lib/features/check_in/repositories/check_in_repository.dart<br>lib/features/church_directory/repositories/church_directory_repository.dart<br>lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/giving/repositories/giving_currency_repository.dart<br>lib/features/giving/repositories/giving_submission_repository.dart<br>lib/features/home/providers/home_appearance_provider.dart<br>lib/features/home/providers/pastor_appearance_provider.dart<br>lib/features/media/repositories/media_repository.dart<br>lib/features/members/repositories/member_baptism_repository.dart<br>lib/features/members/repositories/member_celebration_repository.dart<br>lib/features/members/repositories/member_count_management_repository.dart<br>lib/features/members/repositories/member_demographics_repository.dart<br>lib/features/members/repositories/member_directory_repository.dart<br>lib/features/members/repositories/member_repository.dart<br>lib/features/members/repositories/member_self_profile_repository.dart<br>lib/features/ministries/repositories/ministry_repository.dart<br>lib/features/notifications/repositories/notification_repository.dart<br>lib/features/notifications/services/notification_service.dart<br>lib/features/resources/repositories/church_resource_repository.dart<br>lib/features/sermons/repositories/sermon_bookmark_repository.dart<br>lib/features/small_group/repositories/small_group_repository.dart<br>lib/features/volunteers/repositories/volunteer_repository.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart<br>lib/features/web_admin/services/web_admin_audit_log_service.dart<br>lib/features/web_admin/services/web_admin_staff_access_service.dart<br>lib/features/worship/repositories/worship_settings_repository.dart<br>lib/screens/admin/admin_church_connection_screen.dart<br>lib/screens/admin/admin_home_appearance_screen.dart<br>lib/screens/admin/admin_pastor_picture_screen.dart |
| donations | 4 | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart |
| eventCheckIns | 4 | lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/attendance/services/qr_check_in_service.dart<br>lib/features/check_in/repositories/check_in_repository.dart<br>lib/features/dashboard/repositories/dashboard_repository.dart |
| events | 6 | lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart |
| giving_submissions | 1 | lib/features/giving/repositories/giving_submission_repository.dart |
| media | 2 | lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/media/repositories/media_repository.dart |
| memberPrivateProfiles | 5 | lib/features/members/repositories/member_baptism_repository.dart<br>lib/features/members/repositories/member_celebration_repository.dart<br>lib/features/members/repositories/member_demographics_repository.dart<br>lib/features/members/repositories/member_repository.dart<br>lib/features/members/repositories/member_self_profile_repository.dart |
| members | 17 | lib/features/attendance/services/qr_check_in_service.dart<br>lib/features/auth/screens/live_member_session.dart<br>lib/features/auth/services/required_name_service.dart<br>lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/members/repositories/member_baptism_repository.dart<br>lib/features/members/repositories/member_celebration_repository.dart<br>lib/features/members/repositories/member_count_management_repository.dart<br>lib/features/members/repositories/member_demographics_repository.dart<br>lib/features/members/repositories/member_directory_repository.dart<br>lib/features/members/repositories/member_repository.dart<br>lib/features/members/repositories/member_self_profile_repository.dart<br>lib/features/notifications/services/notification_service.dart<br>lib/features/sermons/repositories/sermon_bookmark_repository.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart<br>lib/features/web_admin/services/web_admin_staff_access_service.dart |
| ministries | 2 | lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/ministries/repositories/ministry_repository.dart |
| notifications | 1 | lib/features/notifications/repositories/notification_repository.dart |
| prayer_requests | 4 | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/screens/web_admin_action_center.dart<br>lib/features/web_admin/screens/web_admin_operations_reports.dart |
| resources | 1 | lib/features/resources/repositories/church_resource_repository.dart |
| sermonBookmarks | 1 | lib/features/sermons/repositories/sermon_bookmark_repository.dart |
| settings | 6 | lib/features/giving/repositories/giving_currency_repository.dart<br>lib/features/home/providers/home_appearance_provider.dart<br>lib/features/home/providers/pastor_appearance_provider.dart<br>lib/features/worship/repositories/worship_settings_repository.dart<br>lib/screens/admin/admin_home_appearance_screen.dart<br>lib/screens/admin/admin_pastor_picture_screen.dart |
| small_groups | 2 | lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/small_group/repositories/small_group_repository.dart |
| userChurchLinks | 2 | lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart |
| volunteer_assignments | 1 | lib/features/volunteers/repositories/volunteer_repository.dart |

## Firestore Rule Collection Inventory

| Collection | RuleMatches |
| --- | --- |
| admin_audit_logs | 1 |
| announcements | 1 |
| attendance | 1 |
| churches | 1 |
| databases | 1 |
| donations | 1 |
| eventCheckIns | 1 |
| events | 1 |
| giving | 1 |
| giving_funds | 1 |
| giving_submissions | 1 |
| media | 1 |
| memberPrivateProfiles | 1 |
| members | 1 |
| ministries | 1 |
| notifications | 1 |
| prayer_requests | 1 |
| resources | 1 |
| sermonBookmarks | 1 |
| sermons | 1 |
| settings | 4 |
| small_groups | 1 |
| userChurchLinks | 1 |
| volunteer_assignments | 1 |

## Collections Referenced in Code but Not Found in Rules

| Collection | References |
| --- | --- |
| None found | None found |

## Collections Found in Rules but Not Referenced by Dart Code

| Collection | RuleMatches |
| --- | --- |
| announcements | 1 |
| attendance | 1 |
| databases | 1 |
| giving | 1 |
| giving_funds | 1 |
| sermons | 1 |

## Role Values

| Role |
| --- |
| admin |
| groupLeader |
| member |
| ministryLeader |
| pastor |
| visitor |
| volunteer |

## Frequently Referenced Firestore Fields

| Field | References | Files |
| --- | --- | --- |
| isActive | 16 | lib/features/auth/models/churchsnap_user.dart<br>lib/features/auth/models/live_member_access.dart<br>lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart<br>lib/features/church_directory/models/church_directory_entry.dart<br>lib/features/members/models/church_member.dart<br>lib/features/members/models/member_baptism_record.dart<br>lib/features/members/models/member_demographics_summary.dart<br>lib/features/members/models/member_directory_entry.dart |
| role | 13 | lib/features/auth/models/churchsnap_user.dart<br>lib/features/auth/models/live_member_access.dart<br>lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart<br>lib/features/members/models/church_member.dart<br>lib/features/members/models/member_baptism_record.dart<br>lib/features/members/models/member_demographics_summary.dart<br>lib/features/members/models/member_directory_entry.dart<br>lib/features/members/models/member_self_profile.dart |
| displayName | 12 | lib/features/attendance/models/attendance_record.dart<br>lib/features/attendance/services/qr_check_in_service.dart<br>lib/features/auth/models/churchsnap_user.dart<br>lib/features/auth/models/live_member_access.dart<br>lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart<br>lib/features/check_in/models/check_in_record.dart<br>lib/features/members/models/church_member.dart<br>lib/features/members/models/member_baptism_record.dart |
| createdAt | 11 | lib/features/giving/models/donation_record.dart<br>lib/features/media/models/media_item.dart<br>lib/features/notifications/models/app_notification.dart<br>lib/features/resources/models/church_resource.dart<br>lib/features/web_admin/models/web_admin_audit_entry.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/models/announcement.dart |
| published | 8 | lib/features/dashboard/repositories/dashboard_repository.dart<br>lib/features/events/repositories/event_repository.dart<br>lib/features/media/models/media_item.dart<br>lib/features/resources/models/church_resource.dart<br>lib/models/announcement.dart<br>lib/models/church_event.dart<br>lib/models/prayer_request.dart<br>lib/models/sermon.dart |
| title | 8 | lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/media/models/media_item.dart<br>lib/features/notifications/models/app_notification.dart<br>lib/features/resources/models/church_resource.dart<br>lib/features/worship/models/worship_service_entry.dart<br>lib/models/announcement.dart<br>lib/models/church_event.dart<br>lib/models/sermon.dart |
| v | 8 | lib/screens/home/home_screen.dart<br>lib/screens/sermons/sermon_detail_screen.dart<br>lib/screens/sermons/sermon_video_player_screen.dart<br>lib/screens/sermons/sermons_screen.dart |
| description | 7 | lib/features/giving/models/giving_fund.dart<br>lib/features/media/models/media_item.dart<br>lib/features/ministries/models/ministry.dart<br>lib/features/resources/models/church_resource.dart<br>lib/features/small_group/models/small_group.dart<br>lib/features/worship/models/worship_service_entry.dart<br>lib/models/sermon.dart |
| active | 6 | lib/features/giving/models/giving_fund.dart<br>lib/features/small_group/models/small_group.dart<br>lib/features/web_admin/models/web_admin_staff_member.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| email | 6 | lib/features/auth/models/churchsnap_user.dart<br>lib/features/auth/models/live_member_access.dart<br>lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart<br>lib/features/members/models/church_member.dart<br>lib/features/members/models/member_directory_entry.dart<br>lib/features/members/models/member_self_profile.dart |
| name | 6 | lib/features/giving/models/giving_fund.dart<br>lib/features/giving/repositories/giving_repository.dart<br>lib/features/ministries/models/ministry.dart<br>lib/features/small_group/models/small_group.dart<br>lib/models/prayer_request.dart |
| updatedAt | 6 | lib/features/home/providers/home_appearance_provider.dart<br>lib/features/home/providers/pastor_appearance_provider.dart<br>lib/features/media/models/media_item.dart<br>lib/features/resources/models/church_resource.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/features/worship/models/worship_settings.dart |
| memberId | 5 | lib/features/attendance/models/attendance_record.dart<br>lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/check_in/models/check_in_record.dart<br>lib/features/giving/models/donation_record.dart<br>lib/features/volunteers/models/volunteer_assignment.dart |
| status | 5 | lib/features/giving/models/donation_record.dart<br>lib/features/giving/models/giving_submission.dart<br>lib/features/volunteers/models/volunteer_assignment.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| memberName | 4 | lib/features/attendance/models/attendance_record.dart<br>lib/features/check_in/models/check_in_record.dart<br>lib/features/giving/models/donation_record.dart<br>lib/features/volunteers/models/volunteer_assignment.dart |
| photoUrl | 4 | lib/features/members/models/church_member.dart<br>lib/features/members/models/member_baptism_record.dart<br>lib/features/members/models/member_directory_entry.dart<br>lib/features/members/models/member_self_profile.dart |
| storagePath | 4 | lib/features/home/providers/home_appearance_provider.dart<br>lib/features/home/providers/pastor_appearance_provider.dart<br>lib/features/resources/models/church_resource.dart<br>lib/screens/admin/admin_home_appearance_screen.dart |
| amount | 3 | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| attendeeIds | 3 | lib/features/events/repositories/event_repository.dart<br>lib/models/church_event.dart |
| churchId | 3 | lib/features/auth/models/churchsnap_user.dart<br>lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart<br>lib/features/church_directory/repositories/church_directory_repository.dart |
| city | 3 | lib/features/church_directory/models/church_directory_entry.dart<br>lib/features/members/models/member_profile_details.dart<br>lib/screens/admin/admin_church_connection_screen.dart |
| currencyCode | 3 | lib/features/giving/models/giving_currency.dart<br>lib/features/giving/models/giving_submission.dart |
| Date | 3 | lib/features/members/models/member_demographics_summary.dart<br>lib/features/web_admin/screens/churchsnap_web_admin_shell.dart |
| dateOfBirth | 3 | lib/features/members/models/member_demographics_summary.dart<br>lib/features/members/models/member_profile_details.dart<br>lib/features/members/models/upcoming_celebration.dart |
| directoryVisible | 3 | lib/features/members/models/member_count_summary.dart<br>lib/features/members/models/member_directory_entry.dart<br>lib/features/members/models/member_self_profile.dart |
| eventId | 3 | lib/features/attendance/models/attendance_record.dart<br>lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/check_in/models/check_in_record.dart |
| firstName | 3 | lib/features/auth/services/required_name_service.dart<br>lib/features/members/models/member_profile_details.dart<br>lib/features/members/models/member_self_profile.dart |
| lastName | 3 | lib/features/auth/services/required_name_service.dart<br>lib/features/members/models/member_profile_details.dart<br>lib/features/members/models/member_self_profile.dart |
| location | 3 | lib/features/small_group/models/small_group.dart<br>lib/features/worship/models/worship_service_entry.dart<br>lib/models/church_event.dart |
| maritalStatus | 3 | lib/features/members/models/member_demographics_summary.dart<br>lib/features/members/models/member_profile_details.dart<br>lib/features/members/models/upcoming_celebration.dart |
| phone | 3 | lib/features/members/models/church_member.dart<br>lib/features/members/models/member_directory_entry.dart<br>lib/features/members/models/member_self_profile.dart |
| userId | 3 | lib/features/attendance/models/attendance_record.dart<br>lib/features/attendance/repositories/attendance_history_repository.dart<br>lib/features/check_in/models/check_in_record.dart |
| visitorAccessEnabled | 3 | lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart<br>lib/features/church_directory/models/church_directory_entry.dart<br>lib/screens/admin/admin_church_connection_screen.dart |
| Adults | 2 | lib/features/members/models/member_demographics_summary.dart |
| body | 2 | lib/features/notifications/models/app_notification.dart<br>lib/models/announcement.dart |
| category | 2 | lib/features/media/models/media_item.dart<br>lib/features/resources/models/church_resource.dart |
| checkedInAt | 2 | lib/features/attendance/models/attendance_record.dart<br>lib/features/check_in/models/check_in_record.dart |
| checkInMethod | 2 | lib/features/attendance/models/attendance_record.dart<br>lib/features/check_in/models/check_in_record.dart |
| Children | 2 | lib/features/members/models/member_demographics_summary.dart |
| currency | 2 | lib/features/giving/models/donation_record.dart<br>lib/features/web_admin/services/web_admin_action_center_builder.dart |
| directoryEmailVisible | 2 | lib/features/members/models/member_directory_entry.dart<br>lib/features/members/models/member_self_profile.dart |
| directoryPhoneVisible | 2 | lib/features/members/models/member_directory_entry.dart<br>lib/features/members/models/member_self_profile.dart |
| duration | 2 | lib/features/media/models/media_item.dart<br>lib/models/sermon.dart |
| featured | 2 | lib/features/media/models/media_item.dart<br>lib/models/sermon.dart |
| fundId | 2 | lib/features/giving/models/donation_record.dart<br>lib/features/giving/models/giving_submission.dart |
| fundName | 2 | lib/features/giving/models/donation_record.dart<br>lib/features/giving/models/giving_submission.dart |
| gender | 2 | lib/features/members/models/member_demographics_summary.dart<br>lib/features/members/models/member_profile_details.dart |
| id | 2 | lib/features/auth/models/churchsnap_user.dart<br>lib/features/worship/models/worship_service_entry.dart |
| isPrivate | 2 | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/models/prayer_request.dart |
| isPublic | 2 | lib/features/church_directory/models/church_directory_entry.dart<br>lib/screens/admin/admin_church_connection_screen.dart |
| leaderId | 2 | lib/features/ministries/models/ministry.dart<br>lib/features/small_group/models/small_group.dart |
| leaderName | 2 | lib/features/ministries/models/ministry.dart<br>lib/features/small_group/models/small_group.dart |
| memberIds | 2 | lib/features/ministries/models/ministry.dart<br>lib/features/small_group/models/small_group.dart |
| middleName | 2 | lib/features/members/models/member_profile_details.dart<br>lib/features/members/models/member_self_profile.dart |
| needsFollowUp | 2 | lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| needsReview | 2 | lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| profileComplete | 2 | lib/features/web_admin/services/web_admin_action_center_builder.dart<br>lib/features/web_admin/services/web_admin_report_builder.dart |
| recurring | 2 | lib/features/giving/models/donation_record.dart<br>lib/features/giving/models/giving_submission.dart |
| reference | 2 | lib/features/giving/models/donation_record.dart<br>lib/features/resources/models/bible_models.dart |
| Seniors | 2 | lib/features/members/models/member_demographics_summary.dart |
| speaker | 2 | lib/features/media/models/media_item.dart<br>lib/models/sermon.dart |
| startDate | 2 | lib/features/web_admin/screens/churchsnap_web_admin_shell.dart<br>lib/models/church_event.dart |
| stateOrProvince | 2 | lib/features/church_directory/models/church_directory_entry.dart<br>lib/features/members/models/member_profile_details.dart |
| Teens | 2 | lib/features/members/models/member_demographics_summary.dart |
| thumbnailUrl | 2 | lib/features/media/models/media_item.dart<br>lib/models/sermon.dart |
| translation_id | 2 | lib/features/resources/models/bible_models.dart |
| USD | 2 | lib/features/giving/models/giving_currency.dart<br>lib/screens/admin/admin_giving_currency_screen.dart |
| Young | 2 | lib/features/members/models/member_demographics_summary.dart |

## Stabilization Review Checklist

- Confirm every web-only collection is intentional.
- Confirm every Android-only collection is intentional.
- Confirm all role values match Firestore rules and existing member documents.
- Confirm member profile fields use identical names across Android and web.
- Confirm event date fields use one canonical field with documented fallbacks.
- Confirm prayer status values are standardized.
- Confirm giving amount, currency, fund, date, and status fields are standardized.
- Confirm all sensitive collections have explicit Firestore rules.
- Confirm deprecated aliases are documented before removal.
