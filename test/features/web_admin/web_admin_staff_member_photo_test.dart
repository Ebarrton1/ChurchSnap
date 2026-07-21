import 'package:churchsnap/features/web_admin/models/web_admin_staff_member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAdminStaffMember photoUrl', () {
    test('reads and trims the canonical member photo URL', () {
      final member = WebAdminStaffMember.fromMap(
        id: 'member-1',
        data: const <String, dynamic>{
          'displayName': 'Ada Member',
          'email': 'ada@example.com',
          'photoUrl': ' https://example.com/member.jpg ',
          'role': 'member',
          'isActive': true,
        },
      );

      expect(member.photoUrl, 'https://example.com/member.jpg');
    });

    test('uses an empty photo URL when no picture is stored', () {
      final member = WebAdminStaffMember.fromMap(
        id: 'member-2',
        data: const <String, dynamic>{
          'displayName': 'No Photo Member',
          'email': 'member@example.com',
          'role': 'member',
        },
      );

      expect(member.photoUrl, isEmpty);
    });

    test('copyWith preserves or replaces the photo URL', () {
      const member = WebAdminStaffMember(
        id: 'member-3',
        displayName: 'Photo Member',
        email: 'photo@example.com',
        photoUrl: 'https://example.com/original.jpg',
        role: 'member',
        isActive: true,
      );

      expect(member.copyWith().photoUrl, member.photoUrl);
      expect(
        member
            .copyWith(photoUrl: 'https://example.com/replacement.jpg')
            .photoUrl,
        'https://example.com/replacement.jpg',
      );
    });
  });
}
