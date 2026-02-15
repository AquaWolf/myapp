import 'rich_card_data.dart';

/// Enum for the response types from the AI assistant.
/// Mirrors the `responseType` enum from the Zod `UniversalResponseSchema`.
enum ResponseType {
  general,
  trainStatus;

  static ResponseType fromString(String? value) {
    switch (value) {
      case 'TRAIN_STATUS':
        return ResponseType.trainStatus;
      case 'GENERAL':
      default:
        return ResponseType.general;
    }
  }
}

/// Model for the full AI assistant response.
/// Mirrors the Zod `UniversalResponseSchema`.
class AssistantResponse {
  final String text;
  final ResponseType responseType;
  final RichCardData? richCard;

  const AssistantResponse({
    required this.text,
    required this.responseType,
    this.richCard,
  });

  /// Creates an [AssistantResponse] from the raw map returned by Cloud Functions.
  /// Handles the `Map<Object?, Object?>` type that Firebase returns by
  /// recursively casting nested maps.
  factory AssistantResponse.fromMap(Map<dynamic, dynamic> map) {
    final rawRichCard = map['richCard'];
    RichCardData? richCard;

    if (rawRichCard != null && rawRichCard is Map) {
      richCard = RichCardData.fromMap(rawRichCard);
    }

    return AssistantResponse(
      text: (map['text'] ?? map['displayText'] ?? '') as String,
      responseType: ResponseType.fromString(map['responseType'] as String?),
      richCard: richCard,
    );
  }

  /// Whether this response should show a rich card.
  bool get hasRichCard =>
      responseType == ResponseType.trainStatus &&
      richCard != null &&
      richCard!.showCard;
}
