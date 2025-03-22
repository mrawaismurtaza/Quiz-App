import 'package:uuid/uuid.dart';

class Challenge {
  final String id;
  final String languageId;
  final String title;
  final String description;
  final String challengeType; // 'translation', 'listening', 'speaking', 'writing', etc.
  final String content;
  final String solution;
  final DateTime date;
  final int xpReward;
  final bool isCompleted;
  final String? userAnswer;

  Challenge({
    required this.id,
    required this.languageId,
    required this.title,
    required this.description,
    required this.challengeType,
    required this.content,
    required this.solution,
    required this.date,
    required this.xpReward,
    this.isCompleted = false,
    this.userAnswer,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      languageId: json['languageId'],
      title: json['title'],
      description: json['description'],
      challengeType: json['challengeType'],
      content: json['content'],
      solution: json['solution'],
      date: DateTime.parse(json['date']),
      xpReward: json['xpReward'],
      isCompleted: json['isCompleted'] ?? false,
      userAnswer: json['userAnswer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'title': title,
      'description': description,
      'challengeType': challengeType,
      'content': content,
      'solution': solution,
      'date': date.toIso8601String(),
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'userAnswer': userAnswer,
    };
  }

  Challenge copyWith({
    String? id,
    String? languageId,
    String? title,
    String? description,
    String? challengeType,
    String? content,
    String? solution,
    DateTime? date,
    int? xpReward,
    bool? isCompleted,
    String? userAnswer,
  }) {
    return Challenge(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      title: title ?? this.title,
      description: description ?? this.description,
      challengeType: challengeType ?? this.challengeType,
      content: content ?? this.content,
      solution: solution ?? this.solution,
      date: date ?? this.date,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      userAnswer: userAnswer ?? this.userAnswer,
    );
  }

  static Challenge generateDailyChallenge(String languageId) {
    const uuid = Uuid();
    final now = DateTime.now();
    
    // Generate a simple translation challenge as an example
    // In a real app, you would have more varied challenge types
    return Challenge(
      id: uuid.v4(),
      languageId: languageId,
      title: 'Daily Translation',
      description: 'Translate this sentence to practice your skills',
      challengeType: 'translation',
      content: 'How are you today?', // This would be in the target language normally
      solution: '¿Cómo estás hoy?', // Example for Spanish
      date: DateTime(now.year, now.month, now.day),
      xpReward: 10,
    );
  }
}