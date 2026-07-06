# ChurchSnap v2.2 Firebase Ready

This package continues the ChurchSnap v2 architecture and prepares the app for Firebase without forcing Firebase packages into the build yet.

## What changed

- Added Firebase collection name/path helpers.
- Added Firebase bootstrap placeholder.
- Added Firebase status service placeholder.
- Added auth repository interface.
- Added mock auth repository compatible with future Firebase Auth implementation.
- Added starter login screen.
- Added Firestore security rules draft.
- Added Firestore indexes draft.
- Added Firebase setup documentation.

## How to use

1. Replace your current `lib/` folder with the `lib/` folder in this package.
2. Keep the `firebase/` and `docs/` folders somewhere safe in your project root.
3. Build before adding Firebase packages:

```powershell
flutter clean
flutter pub get
flutter build apk --release --target-platform android-arm64
```

4. When ready for real Firebase, follow `docs/FIREBASE_SETUP.md`.

## Why Firebase is still placeholder-based

The project will continue to build without Firebase keys or generated `firebase_options.dart`. Once you run `flutterfire configure`, we can switch the placeholder services to real Firebase Auth and Firestore implementations.

## v2.3 Auth Flow Added

This version adds a complete mock authentication flow that is ready to be swapped for Firebase Auth.

### New files

- `lib/features/auth/state/auth_controller.dart`
- `lib/features/auth/screens/auth_gate.dart`
- `lib/features/auth/screens/login_screen.dart`
- `lib/features/auth/repositories/firebase/firebase_auth_repository_stub.dart`
- `docs/AUTH_FLOW.md`

### Test it

Replace your project `lib/` folder with this ZIP's `lib/` folder, then run:

```powershell
flutter clean
flutter pub get
flutter build apk --release --target-platform android-arm64
```

When the app opens, use:

- Email: `member@churchsnap.app`
- Password: `password`

Or tap **Continue as Guest**.
