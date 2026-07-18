import 'church_member.dart';

class MemberDirectoryEntry {
  const MemberDirectoryEntry({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.role,
    required this.isActive,
    required this.directoryVisible,
    this.directoryEmailVisible = true,
    this.directoryPhoneVisible = true,
    required this.removalReason,
    required this.removedAt,
    required this.removedBy,
    required this.restoredAt,
    required this.restoredBy,
  });

  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String photoUrl;
  final String role;
  final bool isActive;
  final bool directoryVisible;
  final bool directoryEmailVisible;
  final bool directoryPhoneVisible;
  final String removalReason;
  final DateTime? removedAt;
  final String removedBy;
  final DateTime? restoredAt;
  final String restoredBy;

  bool get isRemoved => !directoryVisible;

  String get directoryEmail => directoryEmailVisible ? email : '';
  String get directoryPhone => directoryPhoneVisible ? phone : '';

  String get searchableText => [
    displayName,
    directoryEmail,
    directoryPhone,
    role,
  ].join(' ').toLowerCase();

  factory MemberDirectoryEntry.fromMap(String id, Map<String, dynamic> map) {
    return MemberDirectoryEntry(
      id: id,
      displayName: (map['displayName']?.toString() ?? '').trim(),
      email: (map['email']?.toString() ?? '').trim(),
      phone: (map['phone']?.toString() ?? '').trim(),
      photoUrl: (map['photoUrl']?.toString() ?? '').trim(),
      role: (map['role']?.toString() ?? 'member').trim(),
      isActive: map['isActive'] as bool? ?? true,
      directoryVisible: map['directoryVisible'] as bool? ?? true,
      directoryEmailVisible: map['directoryEmailVisible'] as bool? ?? true,
      directoryPhoneVisible: map['directoryPhoneVisible'] as bool? ?? true,
      removalReason: (map['directoryRemovalReason']?.toString() ?? '').trim(),
      removedAt: _dateTimeFromValue(map['directoryRemovedAt']),
      removedBy: (map['directoryRemovedBy']?.toString() ?? '').trim(),
      restoredAt: _dateTimeFromValue(map['directoryRestoredAt']),
      restoredBy: (map['directoryRestoredBy']?.toString() ?? '').trim(),
    );
  }

  ChurchMember toChurchMember() {
    return ChurchMember(
      id: id,
      displayName: displayName,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      role: role,
      isActive: isActive,
    );
  }

  static DateTime? _dateTimeFromValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value.trim());
    }

    if (value != null) {
      try {
        final dynamic converted = value.toDate();

        if (converted is DateTime) {
          return converted;
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}
