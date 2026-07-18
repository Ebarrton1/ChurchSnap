# ChurchSnap Testing-Phase Checklist

Use this checklist for the controlled Android testing build. Record each result as
**PASS**, **FAIL**, **BLOCKED**, or **NOT TESTED**.

## Test Record

- Build/version:
- Git commit:
- APK filename:
- Test date:
- Tester:
- Android device/model:
- Android version:
- Network used:
- Fresh install or upgrade:

## Release Gate

The testing APK should not be distributed beyond the controlled test group until:

- [ ] `flutter analyze` reports no issues.
- [ ] All automated tests pass.
- [ ] Firestore and Storage rules are deployed.
- [ ] No critical or high-severity bug remains open.
- [ ] Authentication, roles, private data, and core workflows pass.
- [ ] A fresh installation and an upgrade installation both pass.

## 1. Authentication and Onboarding

- [ ] New invited user can create an account.
- [ ] Invalid credentials show a useful message.
- [ ] Password reset works without closing the login screen unexpectedly.
- [ ] Email verification is required.
- [ ] First and last names are mandatory before Home opens.
- [ ] Returning users with completed names are not prompted again.
- [ ] Sign-out returns to the login screen.
- [ ] Session restores correctly after closing and reopening the app.

## 2. Live Roles and Account Status

Test with two devices or one device plus the Firebase/Admin account.

- [ ] User signs in as Visitor.
- [ ] Admin changes Visitor to Member.
- [ ] Open user session changes to Member without logout.
- [ ] Member-only features refresh automatically.
- [ ] Admin promotes a user to Pastor/Admin and the Admin destination appears.
- [ ] Admin removes an administrative role and the Admin destination disappears.
- [ ] Admin deactivates the account and the user sees the disabled-account screen.
- [ ] Admin reactivates the account and access returns appropriately.
- [ ] Role-change notification states the old and new roles.
- [ ] Users cannot change their own role or active status.

## 3. Member Profile and Directory

- [ ] Member completes first, middle, and last name.
- [ ] Member updates phone number.
- [ ] Member uploads a profile picture under 5 MB.
- [ ] Oversized or non-image upload is rejected safely.
- [ ] Directory updates automatically after profile save.
- [ ] Email visibility preference is honored.
- [ ] Phone visibility preference is honored.
- [ ] Private address and personal fields do not appear in the directory.
- [ ] Admin removes one member from the directory.
- [ ] Overview member count decreases by exactly one.
- [ ] Removed member cannot restore themselves.
- [ ] Admin restores the member.
- [ ] Overview member count increases by exactly one.
- [ ] Giving, RSVP, attendance, prayer, and profile history remain intact.

## 4. Events and RSVP

- [ ] Published events load.
- [ ] Member can RSVP.
- [ ] Member can cancel RSVP.
- [ ] RSVP count remains accurate.
- [ ] Sabbath and Sunday services display correctly.
- [ ] Admin can create, edit, publish, and remove an event.
- [ ] Save and Cancel close stacked form windows correctly.

## 5. Check-ins and Attendance

- [ ] QR check-in records the correct member and event.
- [ ] Manual and QR check-ins both display.
- [ ] Admin removes one incorrect check-in.
- [ ] Admin clears selected check-ins.
- [ ] Admin clears todayâ€™s check-ins.
- [ ] Admin filters and clears a specific event.
- [ ] Clear All requires the confirmation phrase.
- [ ] Clearing attendance does not delete member records.

## 6. Prayer Requests

- [ ] Member submits a prayer request.
- [ ] Privacy choice is honored.
- [ ] Admin can review and update request status.
- [ ] Unauthorized users cannot access protected prayer details.

## 7. Giving

- [ ] Giving funds load.
- [ ] Member can complete the intended giving flow.
- [ ] Giving history shows only that memberâ€™s records.
- [ ] Admin giving dashboard shows authorized records.
- [ ] Directory removal does not erase giving history.
- [ ] No sensitive payment information is stored improperly.

## 8. Sermons, Announcements, Notifications, and Resources

- [ ] Sermons load and details open.
- [ ] Audio/video links behave correctly.
- [ ] Announcements load.
- [ ] Notification permission flow works.
- [ ] Role-targeted notification reaches the correct user role.
- [ ] Bible/resources section loads.
- [ ] Resource permissions prevent unauthorized edits.

## 9. Navigation and Window Behavior

- [ ] Android Back button returns to the expected screen.
- [ ] Save closes the completed form.
- [ ] Cancel closes the current form.
- [ ] Stacked dialogs and bottom sheets close without closing the base page.
- [ ] Failed Save leaves the form open with a useful error.
- [ ] Bottom navigation remains correct after role changes.
- [ ] No screen becomes blank after repeated navigation.

## 10. Connectivity and Recovery

- [ ] App starts on a stable connection.
- [ ] Slow connection shows loading rather than freezing.
- [ ] Temporary loss of internet shows a friendly message.
- [ ] App recovers when internet returns.
- [ ] Duplicate taps do not create duplicate records.
- [ ] Interrupted upload can be retried.
- [ ] App restart during an authenticated session recovers safely.

## 11. Android Installation

- [ ] Fresh APK installation succeeds.
- [ ] Upgrade over the previous build succeeds.
- [ ] User data remains after upgrade.
- [ ] Launcher icon and app name are correct.
- [ ] Release build opens without debug-only dependencies.
- [ ] Physical Android device test passes.

## Severity Guide

- **Critical:** security breach, data loss, app cannot start, or all users blocked.
- **High:** core workflow fails with no reasonable workaround.
- **Medium:** feature problem with a usable workaround.
- **Low:** visual, wording, spacing, or minor usability issue.

## Bug Report Template

### Bug title

- Severity:
- Build/version:
- Git commit:
- Device and Android version:
- User role:
- Network:
- Screen/feature:

**Steps to reproduce**

1.
2.
3.

**Expected result**

**Actual result**

**Frequency**

- [ ] Every time
- [ ] Intermittent
- [ ] Once

**Evidence**

- Screenshot/video:
- Relevant console output:
- Firestore document/path, if appropriate:
- Notes:

## Final Sign-off

- [ ] Critical bugs: 0
- [ ] High-severity bugs: 0
- [ ] Data-privacy review passed
- [ ] Role and permissions review passed
- [ ] Product owner approved controlled tester distribution
- [ ] Testing APK archived with commit and version information