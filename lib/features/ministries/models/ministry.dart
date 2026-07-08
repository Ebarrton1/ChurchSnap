class Ministry {
  final String id;
  final String name;
  final String description;
  final String leaderId;
  final String leaderName;
  final List<String> memberIds;
  final bool isActive;

  const Ministry({
    this.id = '',
    required this.name,
    this.description = '',
    this.leaderId = '',
    this.leaderName = '',
    this.memberIds = const [],
    this.isActive = true,
  });

  factory Ministry.fromMap(String id, Map<String, dynamic> map) {
    return Ministry(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      leaderId: map['leaderId'] ?? '',
      leaderName: map['leaderName'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? const []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'leaderName': leaderName,
      'memberIds': memberIds,
      'isActive': isActive,
    };
  }
}
