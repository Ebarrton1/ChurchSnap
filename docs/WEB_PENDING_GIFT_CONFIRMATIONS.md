# Web Pending Gift Confirmations

The Windows/Web Giving page now displays a Pending Gift Confirmations banner
above confirmed Giving Records.

The banner includes:

- The current number of pending gift submissions.
- Up to two donor-description previews.
- A responsive **Review pending gifts** button.
- An empty state when no submissions are awaiting confirmation.
- A safe error state that still allows administrators to open the full screen.

Selecting the banner opens the existing `AdminGivingConfirmationsScreen`.
That screen already supports:

- Reviewing the submitted amount, fund, type, and donor description.
- Confirming the amount and currency actually received.
- Rejecting an invalid or unreceived submission.
- Preserving the member-entered description in the confirmed donation ledger.

No new Firestore fields or security-rule changes are required. The banner reads
the existing `giving_submissions` collection and is visible only inside the
role-protected web administration dashboard.