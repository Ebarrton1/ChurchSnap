# ChurchSnap Firebase Setup

## 1. Create Firebase project

Create a Firebase project named `churchsnap` or your preferred app/project name.

## 2. Add FlutterFire packages

From the project root, run:

```powershell
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage firebase_messaging firebase_crashlytics firebase_analytics
```

Optional later:

```powershell
flutter pub add google_sign_in sign_in_with_apple
```

## 3. Install FlutterFire CLI

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

This creates `lib/firebase_options.dart`.

## 4. Initialize Firebase in `main.dart`

Replace the current no-op startup with:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ChurchSnapApp());
}
```

## 5. Suggested Firestore structure

```text
churches/{churchId}
  name
  logoUrl
  worshipDay: sabbath | sunday | both | custom
  primaryColor
  serviceTimes

churches/{churchId}/members/{userId}
  displayName
  email
  role: visitor | member | volunteer | leader | pastor | admin
  photoUrl
  householdId

churches/{churchId}/sermons/{sermonId}
churches/{churchId}/events/{eventId}
churches/{churchId}/announcements/{announcementId}
churches/{churchId}/ministries/{ministryId}
churches/{churchId}/prayer_requests/{prayerId}
churches/{churchId}/check_ins/{checkInId}
churches/{churchId}/settings/app
```

## 6. Deploy rules

The active Firebase configuration is defined in the root `firebase.json` and uses:

- `firestore.rules`
- `firestore.indexes.json`
- `storage.rules`

Deploy the active Firestore and Storage rules from the project root:

```powershell
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## 7. Next implementation step

Replace `MockAuthRepository` with a `FirebaseAuthRepository` that uses `firebase_auth`, then replace `MockChurchRepository` with a Firestore-backed repository.
