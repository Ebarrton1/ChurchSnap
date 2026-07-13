class ChurchSnapUser {
  final String id;
  final String churchId;
  final String displayName;
  final String email;
  final String role;
  final bool isEmailVerified;
  final bool isActive;

  const ChurchSnapUser({
    required this.id,
    required this.churchId,
    required this.displayName,
    required this.email,
    this.role = 'member',
    this.isEmailVerified = false,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin' || role == 'pastor';

  Map<String, dynamic> toMap() => {
    'id': id,
    'churchId': churchId,
    'displayName': displayName,
    'email': email,
    'role': role,
    'isEmailVerified': isEmailVerified,
    'isActive': isActive,
  };

  factory ChurchSnapUser.fromMap(Map<String, dynamic> map) {
    return ChurchSnapUser(
      id: map['id'] as String? ?? '',
      churchId: map['churchId'] as String? ?? 'demo-church',
      displayName: map['displayName'] as String? ?? 'ChurchSnap Member',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
