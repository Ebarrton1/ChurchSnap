class GivingFund {
  const GivingFund({
    this.id = '',
    required this.name,
    this.description = '',
    this.active = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String description;
  final bool active;
  final int sortOrder;

  factory GivingFund.fromMap(String id, Map<String, dynamic> map) {
    return GivingFund(
      id: id,
      name: map['name'] as String? ?? 'General Giving',
      description: map['description'] as String? ?? '',
      active: map['active'] as bool? ?? true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'description': description.trim(),
      'active': active,
      'sortOrder': sortOrder,
    };
  }
}
