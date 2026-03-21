import 'gift.dart';

class Hive {
  final String id;
  final String name;
  final List<Gift> gifts;

  Hive({
    required this.id,
    required this.name,
    required this.gifts,
  });

  factory Hive.fromJson(Map<String, dynamic> json) {
    final rawGifts = json['gifts'] as List<dynamic>? ?? [];
    final gifts = rawGifts
        .whereType<Map<String, dynamic>>()
        .map((g) => Gift.fromJson(g))
        .toList();

    return Hive(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      gifts: gifts,
    );
  }
}
