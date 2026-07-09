class AppRoles {
  static const String admin = 'admin';
  static const String pastor = 'pastor';
  static const String ministryLeader = 'ministryLeader';
  static const String groupLeader = 'groupLeader';
  static const String volunteer = 'volunteer';
  static const String member = 'member';
  static const String visitor = 'visitor';

  static bool canAccessAdmin(String role) {
    return role == admin || role == pastor;
  }

  static bool canManageMinistries(String role) {
    return role == admin || role == pastor || role == ministryLeader;
  }

  static bool canManageSmallGroups(String role) {
    return role == admin || role == pastor || role == groupLeader;
  }

  static bool canManageMedia(String role) {
    return role == admin || role == pastor || role == ministryLeader;
  }
}
