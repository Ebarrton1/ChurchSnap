# Run this from inside the ChurchSnap_product_v1_android_ready folder in PowerShell.
# It deletes any broken Android platform folder, regenerates a modern Android project,
# restores dependencies, generates the ChurchSnap launcher icon, and runs Android release mode.

if (Test-Path android) {
  Remove-Item -Recurse -Force android
}

flutter create --platforms=android --overwrite .
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter run -d android --release
