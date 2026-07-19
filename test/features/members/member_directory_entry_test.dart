import 'package:churchsnap/features/members/models/member_directory_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberDirectoryEntry', () {
    test('members are visible by default for backward compatibility', () {
      final entry = MemberDirectoryEntry.fromMap(
        'member-1',
        const <String, dynamic>{
          'displayName': 'Grace Member',
          'email': 'grace@example.com',
          'role': 'member',
        },
      );

      expect(entry.directoryVisible, isTrue);
      expect(entry.isRemoved, isFalse);
    });

    test('removed member fields are parsed correctly', () {
      final entry = MemberDirectoryEntry.fromMap('member-2', <String, dynamic>{
        'displayName': 'Removed Member',
        'email': 'removed@example.com',
        'phone': '555-0100',
        'role': 'volunteer',
        'isActive': true,
        'directoryVisible': false,
        'directoryRemovalReason': 'Transferred membership',
        'directoryRemovedAt': DateTime(2026, 7, 18),
        'directoryRemovedBy': 'admin-1',
      });

      expect(entry.isRemoved, isTrue);
      expect(entry.removalReason, 'Transferred membership');
      expect(entry.removedAt, DateTime(2026, 7, 18));
      expect(entry.searchableText, contains('removed member'));
      expect(entry.searchableText, contains('volunteer'));
    });

    test('entry converts to the existing ChurchMember model', () {
      final entry =
          MemberDirectoryEntry.fromMap('member-3', const <String, dynamic>{
            'displayName': 'Jordan Member',
            'email': 'jordan@example.com',
            'phone': '555-0110',
            'photoUrl': 'https://example.com/photo.jpg',
            'role': 'member',
            'isActive': false,
          });

      final member = entry.toChurchMember();

      expect(member.id, 'member-3');
      expect(member.displayName, 'Jordan Member');
      expect(member.phone, '555-0110');
      expect(member.isActive, isFalse);
    });
    test('reads canonical and legacy member photo field names', () {
      final canonical = MemberDirectoryEntry.fromMap(
        'member-photo-1',
        const <String, dynamic>{
          'displayName': 'Canonical Photo',
          'photoUrl': ' https://example.com/canonical.jpg ',
        },
      );
      final legacy = MemberDirectoryEntry.fromMap(
        'member-photo-2',
        const <String, dynamic>{
          'displayName': 'Legacy Photo',
          'profilePhotoUrl': ' https://example.com/legacy.jpg ',
        },
      );

      expect(canonical.photoUrl, 'https://example.com/canonical.jpg');
      expect(legacy.photoUrl, 'https://example.com/legacy.jpg');
    });
  });
}
