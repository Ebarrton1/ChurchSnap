import 'package:churchsnap/core/auth/app_roles.dart';
import 'package:churchsnap/features/web_admin/models/web_admin_staff_member.dart';
import 'package:churchsnap/features/web_admin/services/web_admin_staff_access_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAdminStaffMember', () {
    test('normalizes missing and unsupported values safely', () {
      final member = WebAdminStaffMember.fromMap(
        id: 'member-1',
        data: {
          'name': 'Jordan Member',
          'role': 'unsupported-role',
          'active': false,
        },
      );

      expect(member.displayName, 'Jordan Member');
      expect(member.email, 'Email not provided');
      expect(member.role, AppRoles.member);
      expect(member.isActive, isFalse);
    });

    test('identifies leadership roles', () {
      const pastor = WebAdminStaffMember(
        id: 'pastor-1',
        displayName: 'Pastor',
        email: 'pastor@example.com',
        role: AppRoles.pastor,
        isActive: true,
      );
      const volunteer = WebAdminStaffMember(
        id: 'volunteer-1',
        displayName: 'Volunteer',
        email: 'volunteer@example.com',
        role: AppRoles.volunteer,
        isActive: true,
      );

      expect(pastor.isLeadership, isTrue);
      expect(volunteer.isLeadership, isFalse);
    });
  });

  group('WebAdminStaffAccessService helpers', () {
    test('sorts privileged roles first and then by name', () {
      final members = <WebAdminStaffMember>[
        const WebAdminStaffMember(
          id: 'member-1',
          displayName: 'Zoe',
          email: 'zoe@example.com',
          role: AppRoles.member,
          isActive: true,
        ),
        const WebAdminStaffMember(
          id: 'admin-1',
          displayName: 'Beth',
          email: 'beth@example.com',
          role: AppRoles.admin,
          isActive: true,
        ),
        const WebAdminStaffMember(
          id: 'admin-2',
          displayName: 'Adam',
          email: 'adam@example.com',
          role: AppRoles.admin,
          isActive: true,
        ),
      ];

      WebAdminStaffAccessService.sortMembers(members);

      expect(members.map((member) => member.displayName), [
        'Adam',
        'Beth',
        'Zoe',
      ]);
    });

    test('counts exact roles', () {
      const members = <WebAdminStaffMember>[
        WebAdminStaffMember(
          id: 'admin-1',
          displayName: 'Admin',
          email: 'admin@example.com',
          role: AppRoles.admin,
          isActive: true,
        ),
        WebAdminStaffMember(
          id: 'pastor-1',
          displayName: 'Pastor',
          email: 'pastor@example.com',
          role: AppRoles.pastor,
          isActive: true,
        ),
      ];

      expect(WebAdminStaffAccessService.countRole(members, AppRoles.admin), 1);
      expect(
        WebAdminStaffAccessService.countRole(members, AppRoles.volunteer),
        0,
      );
    });
  });
}
