# ChurchSnap v2.3 Auth Flow

This package adds a build-safe authentication flow using a mock repository.

## Included

- `AuthGate` chooses between Login and the main app shell.
- `AuthController` manages auth state.
- Login, create account, password reset preview, guest mode.
- Profile screen displays the signed-in user and supports sign out.
- Admin tab appears only when the user's role is `admin` or `pastor`.
- Firebase Auth repository stub documents the production implementation target.

## Next Firebase step

After you create the Firebase project and run FlutterFire configuration, replace `MockAuthRepository` inside `AuthController` with a real `FirebaseAuthRepository`.

Recommended Firestore member path:

```text
churches/{churchId}/members/{uid}
```

Recommended member fields:

```json
{
  "displayName": "Member Name",
  "email": "member@example.com",
  "role": "member",
  "status": "active",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```
