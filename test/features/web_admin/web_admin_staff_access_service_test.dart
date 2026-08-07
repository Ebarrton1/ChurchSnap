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
      expect(member.isAccountTypeVerified, isFalse);
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

    test('reads registered and anonymous account markers', () {
      final registered = WebAdminStaffMember.fromMap(
        id: 'registered-1',
        data: {
          'displayName': 'Registered',
          'email': 'registered@example.com',
          'role': AppRoles.visitor,
          'authAccountType': 'registered',
        },
      );
      final anonymous = WebAdminStaffMember.fromMap(
        id: 'anonymous-1',
        data: {
          'displayName': 'Guest Visitor',
          'email': '',
          'role': AppRoles.visitor,
          'authAccountType': 'anonymous',
        },
      );

      expect(registered.isRegisteredAccount, isTrue);
      expect(registered.accountTypeLabel, 'Registered account');
      expect(anonymous.isAnonymousAccount, isTrue);
      expect(anonymous.accountTypeLabel, 'Anonymous visitor');
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

    test('registered targets may receive assigned roles', () {
      const member = WebAdminStaffMember(
        id: 'registered-1',
        displayName: 'Registered',
        email: 'registered@example.com',
        role: AppRoles.visitor,
        isActive: true,
        authAccountType: 'registered',
      );

      expect(
        WebAdminStaffAccessService.canAssignRole(
          member: member,
          newRole: AppRoles.member,
        ),
        isTrue,
      );
      expect(
        WebAdminStaffAccessService.canAssignRole(
          member: member,
          newRole: AppRoles.admin,
        ),
        isTrue,
      );
    });

    test('anonymous and unverified targets cannot be promoted', () {
      const anonymous = WebAdminStaffMember(
        id: 'anonymous-1',
        displayName: 'Guest Visitor',
        email: 'Email not provided',
        role: AppRoles.visitor,
        isActive: true,
        authAccountType: 'anonymous',
      );
      const unverified = WebAdminStaffMember(
        id: 'legacy-1',
        displayName: 'Legacy',
        email: 'legacy@example.com',
        role: AppRoles.visitor,
        isActive: true,
      );

      for (final member in [anonymous, unverified]) {
        expect(
          WebAdminStaffAccessService.canAssignRole(
            member: member,
            newRole: AppRoles.member,
          ),
          isFalse,
        );
        expect(
          WebAdminStaffAccessService.canAssignRole(
            member: member,
            newRole: AppRoles.visitor,
          ),
          isTrue,
        );
      }
    });
  });
}
