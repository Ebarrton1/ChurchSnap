# ChurchSnap Firebase Rules Release-Readiness Tests

This suite adds emulator-backed tests for the production `firestore.rules` and
`storage.rules` files.

## Covered policy matrix

- Public/unauthenticated access to public church and published event data
- Visitor separation from member directory and member-only data
- Approved-member directory access
- Own-private-profile access and protection from cross-member reads
- Self-profile updates without role escalation
- Inactive-member denial
- Cross-church denial
- Ministry-leader access limited to the assigned ministry
- Group-leader access limited to the assigned small group
- General administrator and pastor content management
- Exact-administrator-only audited staff-role governance
- Member profile-photo ownership, type validation, and visitor denial
- Administrator profile-photo management

## Run

From the ChurchSnap project root:

```powershell
npm install --prefix .\firebase\rules-tests --save-dev @firebase/rules-unit-testing firebase
firebase emulators:exec --project demo-churchsnap-release-readiness --only firestore,storage "npm --prefix firebase/rules-tests test"
```

The demo project ID keeps emulator testing isolated from production.
