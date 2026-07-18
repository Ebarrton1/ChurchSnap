import 'package:churchsnap/features/members/models/member_directory_entry.dart';
import 'package:churchsnap/features/members/models/member_self_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberSelfProfileDraft', () {
    test('requires first and last names', () {
      const draft = MemberSelfProfileDraft(
        firstName: '',
        middleName: '',
        lastName: 'Barrett',
        phone: '',
        directoryEmailVisible: true,
        directoryPhoneVisible: true,
        addressLine1: '',
        addressLine2: '',
        city: '',
        stateOrProvince: '',
        postalCode: '',
        country: '',
        marriageDate: null,
        dateOfBirth: null,
        maritalStatus: '',
        gender: '',
      );

      expect(draft.validate(), 'First name is required.');
    });

    test('builds a directory name and never changes protected fields', () {
      const draft = MemberSelfProfileDraft(
        firstName: 'Mary',
        middleName: 'Ann',
        lastName: 'Johnson',
        phone: '555-0100',
        directoryEmailVisible: false,
        directoryPhoneVisible: true,
        addressLine1: '1 Main Street',
        addressLine2: '',
        city: 'Kingston',
        stateOrProvince: '',
        postalCode: '',
        country: 'Jamaica',
        marriageDate: null,
        dateOfBirth: null,
        maritalStatus: 'single',
        gender: 'female',
      );

      final publicMap = draft.publicDirectoryMap(
        photoUrl: 'https://example.com/member.jpg',
      );

      expect(draft.displayName, 'Mary Ann Johnson');
      expect(publicMap['displayName'], 'Mary Ann Johnson');
      expect(publicMap['directoryEmailVisible'], isFalse);
      expect(publicMap.containsKey('role'), isFalse);
      expect(publicMap.containsKey('isActive'), isFalse);
      expect(publicMap.containsKey('directoryVisible'), isFalse);
    });

    test('keeps private fields out of the public directory map', () {
      const draft = MemberSelfProfileDraft(
        firstName: 'John',
        middleName: '',
        lastName: 'Brown',
        phone: '',
        directoryEmailVisible: true,
        directoryPhoneVisible: false,
        addressLine1: 'Private address',
        addressLine2: '',
        city: 'Private city',
        stateOrProvince: '',
        postalCode: '',
        country: '',
        marriageDate: null,
        dateOfBirth: null,
        maritalStatus: 'married',
        gender: 'male',
      );

      final publicMap = draft.publicDirectoryMap(photoUrl: '');

      expect(publicMap.containsKey('addressLine1'), isFalse);
      expect(publicMap.containsKey('dateOfBirth'), isFalse);
      expect(publicMap.containsKey('maritalStatus'), isFalse);
      expect(publicMap.containsKey('gender'), isFalse);
    });
  });

  group('MemberDirectoryEntry contact privacy', () {
    test('hides member-selected private contact details', () {
      final entry =
          MemberDirectoryEntry.fromMap('member-1', const <String, dynamic>{
            'displayName': 'Grace Member',
            'email': 'grace@example.com',
            'phone': '555-0110',
            'directoryEmailVisible': false,
            'directoryPhoneVisible': false,
          });

      expect(entry.email, 'grace@example.com');
      expect(entry.phone, '555-0110');
      expect(entry.directoryEmail, isEmpty);
      expect(entry.directoryPhone, isEmpty);
      expect(entry.searchableText, isNot(contains('grace@example.com')));
    });
  });
}
