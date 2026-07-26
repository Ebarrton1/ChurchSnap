# ChurchSnap Local Administrator Backup — Phase 1

## Purpose

An active ChurchSnap administrator can create an encrypted, church-scoped local
backup from **Admin Dashboard → Data Management**.

Firebase remains the primary live database. The local file is an additional
record-retention and disaster-recovery copy.

## Security design

- Access is restricted to an active member whose exact role is `admin`.
- The selected church ID is used for every Firestore read.
- The payload is encrypted before it is saved.
- Encryption uses AES-256-GCM.
- The encryption key is derived from the administrator password using
  PBKDF2-HMAC-SHA256 with 210,000 iterations and a random salt.
- Each backup receives a random AES-GCM nonce.
- Sensitive credential, token, card, and bank fields are redacted.
- Successful backup creation is written to `admin_audit_logs`.
- ChurchSnap does not store or recover the backup password.

## Included Firestore records

The phase 1 allowlist includes church details, members, private member profiles,
announcements, events, resources, sermons, prayer requests, media metadata,
attendance, settings, notifications, ministries, small groups, volunteer
assignments, giving submissions and funds, donations, group/ministry join
requests, and administrative audit records.

Large collections are read in pages of 500 documents.

## Excluded in phase 1

- Firebase Authentication passwords and credentials
- Firebase Storage binary files such as images, PDFs, audio, and video
- Raw payment-card and bank credentials
- Member-only `sermonBookmarks` subcollections
- Restore operations
- Offline editing and bidirectional synchronisation
- Arbitrary unlisted or future Firestore collections

Storage URLs and paths already present in Firestore metadata remain in the
encrypted record backup, but the binary files themselves are not copied.

## File type

The generated extension is:

`*.churchsnapbackup`

The outer file is a JSON encryption envelope. Church records are not stored as
readable plaintext. The existing file picker saves the encrypted bytes through
the native save dialog on supported ChurchSnap platforms.

## Recovery warning

The backup password cannot be recovered by ChurchSnap. The church should store
the password separately from the backup file and keep at least one protected
copy in another approved location.

## Future phases

1. Validated restore into a controlled staging church
2. Selective CSV reporting exports
3. Scheduled Windows administrative backups
4. Firebase Storage archive support
5. Encrypted offline administrative access and conflict-aware synchronisation
