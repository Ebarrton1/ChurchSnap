# ChurchSnap Firebase Schema Stabilization Decisions

Date: 2026-07-19

Branch: `churchsnap-testing-stabilization`

## Scope

These decisions interpret the static Firebase source audits. They do not claim that legacy collections contain or do not contain live documents; live-data occupancy requires a separate controlled review.

## Canonical shared collections

- `churches`
- `members`
- `memberPrivateProfiles`
- `events`
- `prayer_requests`
- `sermons`
- `media`
- `eventCheckIns`
- `giving_funds`
- `giving_submissions`
- `donations`
- `admin_audit_logs`

## Giving workflow

- `giving_funds` stores fund configuration.
- `giving_submissions` stores member-submitted gifts awaiting administrative review.
- `donations` is the canonical confirmed-giving ledger used by member Giving History, the Android giving administration screen, the Windows Action Center, and Operations Reports.
- A confirmed submission maps to the deterministic donation document ID equal to the submission ID.
- Confirmation writes the donation ledger record and updates the submission in one Firestore transaction.
- Retrying the same confirmation cannot create a duplicate donation.
- A confirmed submission cannot silently be reconfirmed with different amount, currency, or note details.

## Attendance

- `eventCheckIns` is the active application collection for attendance and QR check-in.
- The `attendance` rules path is treated as legacy or reserved until live-data review proves otherwise.
- No new application writes should target `attendance`.

## Sermons and media

- `sermons` remains the structured sermon collection.
- `media` remains the broader media library.
- Media items may use a sermon category, but that does not replace the structured sermon records.

## Prayer

- Android and Windows both use `prayer_requests`.
- Android reaches the path through `FirebasePaths.prayerRequests`, which the first literal-call audit did not classify correctly.

## Legacy or reserved paths

- `giving` is denied by Firestore rules and is not a production write target.
- `attendance` is not an active repository write target.
- These paths must not be removed until a separate live-data review confirms they are empty or safely migrated.

## Security

The existing Firestore rules already allow administrators to update `giving_submissions` and create or update `donations`. No rules change is required for the transactional confirmation correction.