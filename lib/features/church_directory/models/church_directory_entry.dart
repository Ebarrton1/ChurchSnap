import 'package:cloud_firestore/cloud_firestore.dart';

class ChurchDirectoryEntry {
  const ChurchDirectoryEntry({
    required this.id,
    required this.name,
    this.address = '',
    this.city = '',
    this.stateOrProvince = '',
    this.logoUrl = '',
    this.connectionCode = '',
    this.isActive = true,
    this.isPublic = true,
    this.visitorAccessEnabled = true,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String stateOrProvince;
  final String logoUrl;
  final String connectionCode;
  final bool isActive;
  final bool isPublic;
  final bool visitorAccessEnabled;

  bool get canAcceptVisitors => isActive && visitorAccessEnabled;

  String get displayAddress {
    final parts = <String>[
      address.trim(),
      city.trim(),
      stateOrProvince.trim(),
    ].where((part) => part.isNotEmpty).toList();

    return parts.join(', ');
  }

  String get searchableText {
    return <String>[
      id,
      name,
      address,
      city,
      stateOrProvince,
      connectionCode,
    ].join(' ').toLowerCase();
  }

  factory ChurchDirectoryEntry.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    String readString(List<String> keys) {
      for (final key in keys) {
        final value = data[key];

        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      return '';
    }

    final resolvedName = readString([
      'name',
      'churchName',
      'displayName',
      'title',
    ]);

    return ChurchDirectoryEntry(
      id: document.id,
      name: resolvedName.isEmpty ? _titleFromId(document.id) : resolvedName,
      address: readString(['address', 'addressLine1', 'streetAddress']),
      city: readString(['city']),
      stateOrProvince: readString(['stateOrProvince', 'state', 'province']),
      logoUrl: readString(['logoUrl', 'photoUrl']),
      connectionCode: readString([
        'inviteCode',
        'connectionCode',
        'churchCode',
      ]).toUpperCase(),
      isActive: data['isActive'] as bool? ?? true,
      isPublic: data['isPublic'] as bool? ?? true,
      visitorAccessEnabled: data['visitorAccessEnabled'] as bool? ?? true,
    );
  }

  static String _titleFromId(String id) {
    if (id.trim().isEmpty) {
      return 'ChurchSnap Church';
    }

    return id
        .split(RegExp(r'[-_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part.length == 1
              ? part.toUpperCase()
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
