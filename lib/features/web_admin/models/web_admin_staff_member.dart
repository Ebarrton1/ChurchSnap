import '../../../core/auth/app_roles.dart';

class WebAdminStaffMember {
  const WebAdminStaffMember({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl = '',
    required this.role,
    required this.isActive,
  });

  factory WebAdminStaffMember.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final name = _firstText(data, const [
      'displayName',
      'fullName',
      'name',
    ], fallback: 'Unnamed member');
    final email = _firstText(data, const [
      'email',
    ], fallback: 'Email not provided');
    final rawRole = _firstText(data, const ['role'], fallback: AppRoles.member);
    final role = AppRoles.assignableRoles.contains(rawRole)
        ? rawRole
        : AppRoles.member;
    final isActive = data['isActive'] is bool
        ? data['isActive'] as bool
        : data['active'] is bool
        ? data['active'] as bool
        : true;

    final photoUrl = (data['photoUrl']?.toString() ?? '').trim();
    return WebAdminStaffMember(
      id: id,
      displayName: name,
      email: email,
      photoUrl: photoUrl,
      role: role,
      isActive: isActive,
    );
  }

  final String id;
  final String displayName;
  final String email;
  final String photoUrl;
  final String role;
  final bool isActive;

  bool get isLeadership => const {
    AppRoles.groupLeader,
    AppRoles.ministryLeader,
    AppRoles.pastor,
    AppRoles.admin,
  }.contains(role);

  WebAdminStaffMember copyWith({
    String? photoUrl,
    String? role,
    bool? isActive,
  }) {
    return WebAdminStaffMember(
      id: id,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  static String _firstText(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return fallback;
  }
}
