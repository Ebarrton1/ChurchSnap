import '../../auth/services/required_name_validator.dart';
import 'member_profile_details.dart';

class MemberSelfProfileSnapshot {
  const MemberSelfProfileSnapshot({
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.role,
    required this.directoryVisible,
    required this.directoryEmailVisible,
    required this.directoryPhoneVisible,
    required this.details,
  });

  final String email;
  final String phone;
  final String photoUrl;
  final String role;
  final bool directoryVisible;
  final bool directoryEmailVisible;
  final bool directoryPhoneVisible;
  final MemberProfileDetails details;

  factory MemberSelfProfileSnapshot.fromMaps({
    required Map<String, dynamic> memberData,
    required Map<String, dynamic> privateData,
  }) {
    final privateDetails = MemberProfileDetails.fromMap(privateData);
    final displayName = (memberData['displayName']?.toString() ?? '').trim();
    final displayNameParts = RequiredNameValidator.splitDisplayName(
      displayName,
    );

    final firstName = _firstNonEmpty([
      memberData['firstName'],
      privateDetails.firstName,
      displayNameParts.firstName,
    ]);
    final middleName = _firstNonEmpty([
      memberData['middleName'],
      privateDetails.middleName,
    ]);
    final lastName = _firstNonEmpty([
      memberData['lastName'],
      privateDetails.lastName,
      displayNameParts.lastName,
    ]);

    return MemberSelfProfileSnapshot(
      email: (memberData['email']?.toString() ?? '').trim(),
      phone: (memberData['phone']?.toString() ?? '').trim(),
      photoUrl: (memberData['photoUrl']?.toString() ?? '').trim(),
      role: (memberData['role']?.toString() ?? 'member').trim(),
      directoryVisible: memberData['directoryVisible'] as bool? ?? true,
      directoryEmailVisible:
          memberData['directoryEmailVisible'] as bool? ?? true,
      directoryPhoneVisible:
          memberData['directoryPhoneVisible'] as bool? ?? true,
      details: MemberProfileDetails(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        addressLine1: privateDetails.addressLine1,
        addressLine2: privateDetails.addressLine2,
        city: privateDetails.city,
        stateOrProvince: privateDetails.stateOrProvince,
        postalCode: privateDetails.postalCode,
        country: privateDetails.country,
        membershipDate: privateDetails.membershipDate,
        marriageDate: privateDetails.marriageDate,
        dateOfBirth: privateDetails.dateOfBirth,
        maritalStatus: privateDetails.maritalStatus,
        gender: privateDetails.gender,
      ),
    );
  }

  static String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final normalized = value?.toString().trim() ?? '';

      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return '';
  }
}

class MemberSelfProfileDraft {
  const MemberSelfProfileDraft({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phone,
    required this.directoryEmailVisible,
    required this.directoryPhoneVisible,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.stateOrProvince,
    required this.postalCode,
    required this.country,
    required this.marriageDate,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.gender,
  });

  final String firstName;
  final String middleName;
  final String lastName;
  final String phone;
  final bool directoryEmailVisible;
  final bool directoryPhoneVisible;

  final String addressLine1;
  final String addressLine2;
  final String city;
  final String stateOrProvince;
  final String postalCode;
  final String country;
  final DateTime? marriageDate;
  final DateTime? dateOfBirth;
  final String maritalStatus;
  final String gender;

  String get normalizedFirstName => RequiredNameValidator.normalize(firstName);
  String get normalizedMiddleName =>
      RequiredNameValidator.normalize(middleName);
  String get normalizedLastName => RequiredNameValidator.normalize(lastName);

  String get displayName => [
    normalizedFirstName,
    normalizedMiddleName,
    normalizedLastName,
  ].where((part) => part.isNotEmpty).join(' ');

  String? validate() {
    final nameError = RequiredNameValidator.validateFullName(
      firstName: firstName,
      lastName: lastName,
    );

    if (nameError != null) {
      return nameError;
    }

    if (normalizedMiddleName.length > 60) {
      return 'Middle name must be 60 characters or fewer.';
    }

    if (phone.trim().length > 40) {
      return 'Phone number must be 40 characters or fewer.';
    }

    if (dateOfBirth != null && dateOfBirth!.isAfter(DateTime.now())) {
      return 'Date of birth cannot be in the future.';
    }

    if (marriageDate != null && marriageDate!.isAfter(DateTime.now())) {
      return 'Marriage date cannot be in the future.';
    }

    return null;
  }

  Map<String, dynamic> publicDirectoryMap({required String photoUrl}) {
    return <String, dynamic>{
      'firstName': normalizedFirstName,
      'middleName': normalizedMiddleName,
      'lastName': normalizedLastName,
      'displayName': displayName,
      'phone': phone.trim(),
      'photoUrl': photoUrl.trim(),
      'directoryEmailVisible': directoryEmailVisible,
      'directoryPhoneVisible': directoryPhoneVisible,
      'profileNameComplete': true,
    };
  }

  Map<String, dynamic> privateProfileMap() {
    return <String, dynamic>{
      'firstName': normalizedFirstName,
      'middleName': normalizedMiddleName,
      'lastName': normalizedLastName,
      'addressLine1': addressLine1.trim(),
      'addressLine2': addressLine2.trim(),
      'city': city.trim(),
      'stateOrProvince': stateOrProvince.trim(),
      'postalCode': postalCode.trim(),
      'country': country.trim(),
      'marriageDate': marriageDate,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus.trim(),
      'gender': gender.trim(),
    };
  }
}
