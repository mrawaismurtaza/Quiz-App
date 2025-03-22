enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  matching,
}

class QuizQuestion {
  final String id;
  final String languageId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final QuestionType type;
  final String? explanation;
  final String? imageUrl;

  const QuizQuestion({
    required this.id,
    required this.languageId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.type,
    this.explanation,
    this.imageUrl,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      languageId: json['languageId'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      type: QuestionType.values.byName(json['type']),
      explanation: json['explanation'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'type': type.name,
      'explanation': explanation,
      'imageUrl': imageUrl,
    };
  }
}

class Quiz {
  final String id;
  final String languageId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int timeLimit; // in seconds, 0 means no time limit
  final String difficulty; // 'easy', 'medium', 'hard'
  final String category; // 'vocabulary', 'grammar', 'phrases', etc.

  const Quiz({
    required this.id,
    required this.languageId,
    required this.title,
    required this.description,
    required this.questions,
    this.timeLimit = 0,
    required this.difficulty,
    required this.category,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      languageId: json['languageId'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      timeLimit: json['timeLimit'] ?? 0,
      difficulty: json['difficulty'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit,
      'difficulty': difficulty,
      'category': category,
    };
  }
}