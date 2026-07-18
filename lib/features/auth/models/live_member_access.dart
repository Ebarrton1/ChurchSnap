import 'churchsnap_user.dart';

class LiveMemberAccess {
  const LiveMemberAccess({
    required this.displayName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  final String displayName;
  final String email;
  final String role;
  final bool isActive;

  factory LiveMemberAccess.fromMap(
    Map<String, dynamic> data, {
    required ChurchSnapUser fallback,
  }) {
    return LiveMemberAccess(
      displayName: _stringOrFallback(data['displayName'], fallback.displayName),
      email: _stringOrFallback(data['email'], fallback.email),
      role: _stringOrFallback(data['role'], fallback.role),
      isActive: data['isActive'] as bool? ?? fallback.isActive,
    );
  }

  ChurchSnapUser mergeWith(ChurchSnapUser current) {
    return ChurchSnapUser(
      id: current.id,
      churchId: current.churchId,
      displayName: displayName,
      email: email,
      role: role,
      isEmailVerified: current.isEmailVerified,
      isActive: isActive,
    );
  }

  bool differsFrom(ChurchSnapUser current) {
    return displayName != current.displayName ||
        email != current.email ||
        role != current.role ||
        isActive != current.isActive;
  }

  static String _stringOrFallback(dynamic value, String fallback) {
    final normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }
}
