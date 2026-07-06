class FirebaseStatusService {
  const FirebaseStatusService({this.isConfigured = false});

  final bool isConfigured;

  String get statusLabel =>
      isConfigured ? 'Firebase connected' : 'Firebase not configured yet';
}
