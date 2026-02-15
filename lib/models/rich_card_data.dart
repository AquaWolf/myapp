/// Model for the rich card data returned by the AI assistant.
/// Mirrors the `richCard` field from the Zod `UniversalResponseSchema`.
class RichCardData {
  final String trainId;
  final String route;
  final int delayMinutes;
  final String status;
  final String scheduledTime;
  final String expectedTime;
  final String platformInfo;
  final bool showCard;

  const RichCardData({
    required this.trainId,
    required this.route,
    required this.delayMinutes,
    required this.status,
    required this.scheduledTime,
    required this.expectedTime,
    required this.platformInfo,
    required this.showCard,
  });

  /// Creates a [RichCardData] from a raw map (e.g. from Cloud Functions).
  /// Handles the `Map<Object?, Object?>` type that Firebase returns.
  factory RichCardData.fromMap(Map<dynamic, dynamic> map) {
    return RichCardData(
      trainId: (map['trainId'] ?? 'Unbekannt') as String,
      route: (map['route'] ?? 'Unbekannte Route') as String,
      delayMinutes: _parseInt(map['delayMinutes']),
      status: (map['status'] ?? 'Unbekannt') as String,
      scheduledTime: (map['scheduledTime'] ?? '--:--') as String,
      expectedTime: (map['expectedTime'] ?? '--:--') as String,
      platformInfo: (map['platformInfo'] ?? '-') as String,
      showCard: (map['showCard'] ?? false) as bool,
    );
  }

  /// Safely parse an int from a value that might be int, double, or null.
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
