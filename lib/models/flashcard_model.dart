class Flashcard {
  final String id;
  final String languageId;
  final String term;
  final String definition;
  final String? example;
  final String? imageUrl;
  final bool isFavorite;
  final double masteryLevel; // 0.0 to 1.0 representing mastery
  final DateTime lastReviewed;

  const Flashcard({
    required this.id,
    required this.languageId,
    required this.term,
    required this.definition,
    this.example,
    this.imageUrl,
    this.isFavorite = false,
    this.masteryLevel = 0.0,
    required this.lastReviewed,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      languageId: json['languageId'],
      term: json['term'],
      definition: json['definition'],
      example: json['example'],
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
      masteryLevel: json['masteryLevel'] ?? 0.0,
      lastReviewed: DateTime.parse(json['lastReviewed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'term': term,
      'definition': definition,
      'example': example,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'masteryLevel': masteryLevel,
      'lastReviewed': lastReviewed.toIso8601String(),
    };
  }

  Flashcard copyWith({
    String? id,
    String? languageId,
    String? term,
    String? definition,
    String? example,
    String? imageUrl,
    bool? isFavorite,
    double? masteryLevel,
    DateTime? lastReviewed,
  }) {
    return Flashcard(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }
}