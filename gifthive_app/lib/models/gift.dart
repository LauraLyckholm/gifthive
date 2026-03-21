class Gift {
  final String id;
  final String hiveId;
  final String gift;
  final List<String> tags;
  final bool bought;
  final String? dueDate;

  Gift({
    required this.id,
    required this.hiveId,
    required this.gift,
    required this.tags,
    required this.bought,
    this.dueDate,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['_id'] ?? '',
      hiveId: json['hiveId'] ?? '',
      gift: json['gift'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      bought: json['bought'] ?? false,
      dueDate: json['dueDate'],
    );
  }

  Gift copyWith({bool? bought}) {
    return Gift(
      id: id,
      hiveId: hiveId,
      gift: gift,
      tags: tags,
      bought: bought ?? this.bought,
      dueDate: dueDate,
    );
  }
}
