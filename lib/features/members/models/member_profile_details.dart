import 'package:cloud_firestore/cloud_firestore.dart';

class MemberProfileDetails {
  const MemberProfileDetails({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.city = '',
    this.stateOrProvince = '',
    this.postalCode = '',
    this.country = '',
    this.membershipDate,
    this.marriageDate,
    this.dateOfBirth,
    this.maritalStatus = '',
    this.gender = '',
  });

  final String firstName;
  final String middleName;
  final String lastName;

  final String addressLine1;
  final String addressLine2;
  final String city;
  final String stateOrProvince;
  final String postalCode;
  final String country;

  final DateTime? membershipDate;
  final DateTime? marriageDate;
  final DateTime? dateOfBirth;

  final String maritalStatus;
  final String gender;

  String get fullName {
    return [
      firstName.trim(),
      middleName.trim(),
      lastName.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  String get formattedAddress {
    final streetAddress = [
      addressLine1.trim(),
      addressLine2.trim(),
    ].where((part) => part.isNotEmpty).join(', ');

    final locality = [
      city.trim(),
      stateOrProvince.trim(),
      postalCode.trim(),
    ].where((part) => part.isNotEmpty).join(', ');

    return [
      streetAddress,
      locality,
      country.trim(),
    ].where((part) => part.isNotEmpty).join('\n');
  }

  factory MemberProfileDetails.fromMap(Map<String, dynamic> map) {
    return MemberProfileDetails(
      firstName: _stringValue(map['firstName']),
      middleName: _stringValue(map['middleName']),
      lastName: _stringValue(map['lastName']),
      addressLine1: _stringValue(map['addressLine1']),
      addressLine2: _stringValue(map['addressLine2']),
      city: _stringValue(map['city']),
      stateOrProvince: _stringValue(map['stateOrProvince']),
      postalCode: _stringValue(map['postalCode']),
      country: _stringValue(map['country']),
      membershipDate: _dateValue(map['membershipDate']),
      marriageDate: _dateValue(map['marriageDate']),
      dateOfBirth: _dateValue(map['dateOfBirth']),
      maritalStatus: _stringValue(map['maritalStatus']),
      gender: _stringValue(map['gender']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName.trim(),
      'middleName': middleName.trim(),
      'lastName': lastName.trim(),
      'addressLine1': addressLine1.trim(),
      'addressLine2': addressLine2.trim(),
      'city': city.trim(),
      'stateOrProvince': stateOrProvince.trim(),
      'postalCode': postalCode.trim(),
      'country': country.trim(),
      'membershipDate': _timestampValue(membershipDate),
      'marriageDate': _timestampValue(marriageDate),
      'dateOfBirth': _timestampValue(dateOfBirth),
      'maritalStatus': maritalStatus.trim(),
      'gender': gender.trim(),
    };
  }

  MemberProfileDetails copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? stateOrProvince,
    String? postalCode,
    String? country,
    DateTime? membershipDate,
    DateTime? marriageDate,
    DateTime? dateOfBirth,
    String? maritalStatus,
    String? gender,
  }) {
    return MemberProfileDetails(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      stateOrProvince: stateOrProvince ?? this.stateOrProvince,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      membershipDate: membershipDate ?? this.membershipDate,
      marriageDate: marriageDate ?? this.marriageDate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      gender: gender ?? this.gender,
    );
  }

  static String _stringValue(dynamic value) {
    return value is String ? value.trim() : '';
  }

  static DateTime? _dateValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static Timestamp? _timestampValue(DateTime? value) {
    if (value == null) {
      return null;
    }

    return Timestamp.fromDate(DateTime(value.year, value.month, value.day));
  }
}
