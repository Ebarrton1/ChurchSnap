# Donation Description Feature

ChurchSnap donations now support an optional giver-entered description of up
to 500 characters.

Examples include:

- A dedication or memorial message.
- The intended ministry purpose.
- A short explanation for a special contribution.
- A note such as "Youth retreat transportation."

## Data flow

The `description` field is saved to the pending `giving_submissions` record.
When an administrator confirms the gift, the same description is copied into
the canonical `donations` ledger record.

Existing submissions and donations without this field continue to load with an
empty description.

## Display surfaces

The description is available in:

- The giver's review window.
- Gift Confirmations for administrators.
- The member's Giving History.
- Giving Administration contribution records.
- The Windows/Web Giving Records page.
- The administrator's manual contribution editor.

## Security

Firestore rules allow the optional `description` field only when it is a
string no longer than 500 characters. Administrators cannot alter the
giver-entered description while confirming or rejecting the submission.

The rules change must be deployed before updated clients submit descriptions.