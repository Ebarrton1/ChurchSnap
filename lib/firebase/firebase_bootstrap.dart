/// Firebase bootstrap placeholder.
///
/// This file intentionally avoids importing firebase_core so the project still
/// builds before Firebase packages and generated firebase_options.dart are added.
///
/// After running `flutterfire configure`, replace this body with:
///
/// import 'package:firebase_core/firebase_core.dart';
/// import 'firebase_options.dart';
///
/// class FirebaseBootstrap {
///   static Future<void> initialize() async {
///     await Firebase.initializeApp(
///       options: DefaultFirebaseOptions.currentPlatform,
///     );
///   }
/// }
class FirebaseBootstrap {
  static Future<void> initialize() async {
    // No-op until Firebase is configured.
  }
}
