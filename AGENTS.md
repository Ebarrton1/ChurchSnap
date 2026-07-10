# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is
ChurchSnap: an **Android-only Flutter app** (Dart, Riverpod) for church management, plus an
optional **Firebase Cloud Functions** backend in `functions/` (Node.js). The Flutter client is
the primary product. Firebase project is referenced in `lib/firebase_options.dart` /
`android/app/google-services.json`. Standard build/run steps live in `README.md`; Firebase
details in `docs/FIREBASE_SETUP.md`.

### Toolchain (already installed in the VM snapshot; PATH set in `~/.bashrc`)
- Flutter `3.44.6` (Dart `3.12.2`) at `~/flutter` — matches `pubspec.yaml` `sdk: ^3.12.2`.
- Android SDK at `~/android-sdk` (`platform-tools`, `platforms;android-36`, `build-tools;36.0.0`,
  NDK/CMake auto-installed by the first Gradle build, `emulator`, and both `google_apis` and
  `default` android-34 x86_64 system images). `flutter config --android-sdk` is already pointed here.
- The update script only refreshes deps (`flutter pub get`, `npm install` in `functions/`); it does
  NOT reinstall the SDKs. If a new shell doesn't have `flutter`/`adb` on PATH, re-source `~/.bashrc`
  or call binaries by absolute path (`~/flutter/bin/flutter`, `~/android-sdk/platform-tools/adb`).

### Lint / test / build (fast, no emulator needed)
- Lint: `flutter analyze` (only info-level lints exist; exits 0).
- Test: `flutter test` (a single placeholder widget test under `test/`).
- Build: `flutter build apk --debug` (first run downloads Gradle 9.1.0 + NDK; ~3-4 min).

### Running the app (non-obvious — read before starting an emulator)
- The app is **Android-only**: `main.dart` calls `Firebase.initializeApp(...)` unconditionally and
  `firebase_options.dart` throws `UnsupportedError` for web/desktop, so it cannot run on Flutter web
  or Linux desktop without code changes. It must run on an Android device/emulator.
- **No KVM** is available in the cloud VM, so the emulator runs in pure software (TCG) and is very
  slow. Use the lighter **AOSP** image, not the Play/`google_apis` one, to avoid the
  `system_server` thrashing that causes repeated "Process system isn't responding" dialogs:
  - AVD already created: `aosp_avd` (from `system-images;android-34;default;x86_64`).
  - Launch headless: `emulator -avd aosp_avd -no-accel -no-snapshot -no-boot-anim -gpu swiftshader_indirect -no-window -no-audio -memory 3072`
  - Boot + APK install + first app launch each take minutes and spike guest load (transient ANR
    dialogs are expected). After each step, **let the emulator sit idle** until guest load
    (`adb shell cat /proc/loadavg`) drops to ~1-2 before interacting; then taps/screenshots work.
  - `adb shell input tap X Y` uses **real device pixels** (screen is `1080x2400`), not
    screenshot-scaled coordinates. Capture UI with `adb exec-out screencap -p > out.png`.
- **Guest login** ("Continue as Guest") is the offline happy path: it sets the user locally with no
  network. Email sign-in and most data screens talk to real Firebase Auth/Firestore, so without a
  live/emulated backend some screens (e.g. Events) show empty/"Unable to load" states — that is
  expected, not an environment failure.

### Cloud Functions backend (`functions/`) — optional
- Only powers push-notification fan-out; the app runs fine without it.
- `package.json` declares `"node": "24"` and scripts wrap the Firebase CLI
  (`firebase emulators:start`). The VM's system Node is v22 and `firebase-tools` is not installed,
  so running the functions emulator requires installing those first. `npm install` (in `functions/`)
  still works for dependency setup.
