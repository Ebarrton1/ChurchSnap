import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'required_name_validator.dart';

class RequiredNameStatus {
  const RequiredNameStatus({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;

  bool get isComplete =>
      firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;

  factory RequiredNameStatus.fromMap(Map<String, dynamic>? data) {
    return RequiredNameStatus(
      firstName: (data?['firstName']?.toString() ?? '').trim(),
      lastName: (data?['lastName']?.toString() ?? '').trim(),
    );
  }
}

class RequiredNameService {
  RequiredNameService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required this.churchId,
    required this.userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String churchId;
  final String userId;

  DocumentReference<Map<String, dynamic>> get _memberReference => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('members')
      .doc(userId);

  Stream<RequiredNameStatus> watchStatus() {
    return _memberReference.snapshots().map(
      (snapshot) => RequiredNameStatus.fromMap(snapshot.data()),
    );
  }

  Future<void> saveRequiredName({
    required String firstName,
    required String lastName,
  }) async {
    final validationError = RequiredNameValidator.validateFullName(
      firstName: firstName,
      lastName: lastName,
    );

    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final normalizedFirstName = RequiredNameValidator.normalize(firstName);
    final normalizedLastName = RequiredNameValidator.normalize(lastName);
    final displayName = RequiredNameValidator.buildDisplayName(
      firstName: normalizedFirstName,
      lastName: normalizedLastName,
    );

    final authenticatedUser = _auth.currentUser;

    if (authenticatedUser == null || authenticatedUser.uid != userId) {
      throw StateError(
        'Your signed-in account could not be verified. Please sign in again.',
      );
    }

    await authenticatedUser.updateDisplayName(displayName);

    await _memberReference.update({
      'firstName': normalizedFirstName,
      'lastName': normalizedLastName,
      'displayName': displayName,
      'profileNameComplete': true,
      'profileNameCompletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
