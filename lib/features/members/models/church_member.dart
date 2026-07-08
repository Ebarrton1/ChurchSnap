class ChurchMember {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String photoUrl;
  final String role;
  final bool isActive;

  const ChurchMember({
    required this.id,
    required this.displayName,
    required this.email,
    this.phone = '',
    this.photoUrl = '',
    this.role = 'member',
    this.isActive = true,
  });

  factory ChurchMember.fromMap(String id, Map<String, dynamic> map) {
    return ChurchMember(
      id: id,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'member',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'isActive': isActive,
    };
  }
}
