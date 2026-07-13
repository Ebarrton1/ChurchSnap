class AppRoles {
  static const String visitor = 'visitor';
  static const String member = 'member';
  static const String volunteer = 'volunteer';
  static const String groupLeader = 'groupLeader';
  static const String ministryLeader = 'ministryLeader';
  static const String pastor = 'pastor';
  static const String admin = 'admin';

  static const List<String> assignableRoles = <String>[
    visitor,
    member,
    volunteer,
    groupLeader,
    ministryLeader,
    pastor,
    admin,
  ];

  static bool isValid(String role) {
    return assignableRoles.contains(role);
  }

  static bool isPrivileged(String role) {
    return role == admin || role == pastor;
  }

  static bool canAccessAdmin(String role) {
    return isPrivileged(role);
  }

  static bool canManageMinistries(String role) {
    return isPrivileged(role) || role == ministryLeader;
  }

  static bool canManageSmallGroups(String role) {
    return isPrivileged(role) || role == groupLeader;
  }

  static bool canManageMedia(String role) {
    return isPrivileged(role);
  }

  static String label(String role) {
    return switch (role) {
      visitor => 'Visitor',
      member => 'Member',
      volunteer => 'Volunteer',
      groupLeader => 'Group Leader',
      ministryLeader => 'Ministry Leader',
      pastor => 'Pastor',
      admin => 'Administrator',
      _ => 'Legacy role: $role',
    };
  }

  static String description(String role) {
    return switch (role) {
      visitor => 'Can view public and member content after approval.',
      member => 'Standard church member access.',
      volunteer => 'Member access plus volunteer scheduling.',
      groupLeader => 'Can manage assigned small-group content.',
      ministryLeader => 'Can manage assigned ministry content.',
      pastor => 'Full administrative access.',
      admin => 'Full administrative access.',
      _ => 'This role is no longer supported and should be replaced.',
    };
  }
}
