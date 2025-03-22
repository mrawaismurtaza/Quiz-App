import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:dreamflow/models/language_model.dart';
import 'package:dreamflow/models/flashcard_model.dart';
import 'package:dreamflow/models/quiz_model.dart';
import 'package:dreamflow/models/challenge_model.dart';

class LanguageService extends ChangeNotifier {
  late SharedPreferences _prefs;
  List<Language> _availableLanguages = [];
  Map<String, List<Flashcard>> _flashcards = {};
  Map<String, List<Quiz>> _quizzes = {};
  Map<String, List<Challenge>> _challenges = {};
  
  List<Language> get availableLanguages => _availableLanguages;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load available languages
    _availableLanguages = Languages.all;
    
    // Load flashcards from SharedPreferences
    final flashcardsJson = _prefs.getString('flashcards');
    if (flashcardsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(flashcardsJson);
      _flashcards = {};
      decoded.forEach((languageId, cards) {
        _flashcards[languageId] = (cards as List)
            .map((card) => Flashcard.fromJson(card))
            .toList();
      });
    } else {
      // Initialize with sample flashcards if none exist
      _initializeSampleData();
    }
    
    // Load quizzes from SharedPreferences
    final quizzesJson = _prefs.getString('quizzes');
    if (quizzesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(quizzesJson);
      _quizzes = {};
      decoded.forEach((languageId, quizList) {
        _quizzes[languageId] = (quizList as List)
            .map((quiz) => Quiz.fromJson(quiz))
            .toList();
      });
    }
    
    // Load challenges from SharedPreferences
    final challengesJson = _prefs.getString('challenges');
    if (challengesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(challengesJson);
      _challenges = {};
      decoded.forEach((languageId, challengeList) {
        _challenges[languageId] = (challengeList as List)
            .map((challenge) => Challenge.fromJson(challenge))
            .toList();
      });
    }
  }

  void _initializeSampleData() {
    // Initialize with sample flashcards for Spanish (id: 2)
    const spanishId = '2';
    final now = DateTime.now();
    const uuid = Uuid();
    
    final sampleSpanishFlashcards = [
      Flashcard(
        id: uuid.v4(),
        languageId: spanishId,
        term: 'Hola',
        definition: 'Hello',
        example: 'u00A1Hola! u00BFCu00F3mo estu00E1s?',
        lastReviewed: now,
      ),
      Flashcard(
        id: uuid.v4(),
        languageId: spanishId,
        term: 'Gracias',
        definition: 'Thank you',
        example: 'Muchas gracias por tu ayuda.',
        lastReviewed: now,
      ),
      Flashcard(
        id: uuid.v4(),
        languageId: spanishId,
        term: 'Por favor',
        definition: 'Please',
        example: 'Por favor, pu00e1same el libro.',
        lastReviewed: now,
      ),
      Flashcard(
        id: uuid.v4(),
        languageId: spanishId,
        term: 'Amigo',
        definition: 'Friend',
        example: 'u00c9l es mi mejor amigo.',
        lastReviewed: now,
      ),
      Flashcard(
        id: uuid.v4(),
        languageId: spanishId,
        term: 'Casa',
        definition: 'House',
        example: 'Mi casa estu00e1 cerca del parque.',
        lastReviewed: now,
      ),
    ];
    
    // Initialize with sample quiz for Spanish
    final sampleSpanishQuiz = Quiz(
      id: uuid.v4(),
      languageId: spanishId,
      title: 'Basic Spanish Greetings',
      description: 'Test your knowledge of common Spanish greetings and phrases.',
      questions: [
        QuizQuestion(
          id: uuid.v4(),
          languageId: spanishId,
          question: 'What does "Buenos du00edas" mean?',
          options: ['Good morning', 'Good afternoon', 'Good evening', 'Good night'],
          correctAnswer: 'Good morning',
          type: QuestionType.multipleChoice,
        ),
        QuizQuestion(
          id: uuid.v4(),
          languageId: spanishId,
          question: 'How do you say "Thank you very much" in Spanish?',
          options: ['Gracias', 'Por favor', 'Muchas gracias', 'De nada'],
          correctAnswer: 'Muchas gracias',
          type: QuestionType.multipleChoice,
        ),
        QuizQuestion(
          id: uuid.v4(),
          languageId: spanishId,
          question: 'True or False: "Adiu00f3s" means "hello" in Spanish.',
          options: ['True', 'False'],
          correctAnswer: 'False',
          type: QuestionType.trueFalse,
          explanation: '"Adiu00f3s" means "goodbye" in Spanish.',
        ),
      ],
      difficulty: 'easy',
      category: 'greetings',
    );
    
    // Create sample daily challenge
    final sampleChallenge = Challenge(
      id: uuid.v4(),
      languageId: spanishId,
      title: 'Daily Spanish Phrase',
      description: 'Translate this common Spanish phrase to English',
      challengeType: 'translation',
      content: 'u00bfDu00f3nde estu00e1 la biblioteca?',
      solution: 'Where is the library?',
      date: DateTime(now.year, now.month, now.day),
      xpReward: 10,
    );
    
    // Save to the maps
    _flashcards = {
      spanishId: sampleSpanishFlashcards,
    };
    
    _quizzes = {
      spanishId: [sampleSpanishQuiz],
    };
    
    _challenges = {
      spanishId: [sampleChallenge],
    };
    
    // Persist to SharedPreferences
    _saveFlashcards();
    _saveQuizzes();
    _saveChallenges();
  }

  void _saveFlashcards() {
    final Map<String, dynamic> flashcardsMap = {};
    _flashcards.forEach((languageId, cards) {
      flashcardsMap[languageId] = cards.map((card) => card.toJson()).toList();
    });
    _prefs.setString('flashcards', jsonEncode(flashcardsMap));
  }

  void _saveQuizzes() {
    final Map<String, dynamic> quizzesMap = {};
    _quizzes.forEach((languageId, quizList) {
      quizzesMap[languageId] = quizList.map((quiz) => quiz.toJson()).toList();
    });
    _prefs.setString('quizzes', jsonEncode(quizzesMap));
  }

  void _saveChallenges() {
    final Map<String, dynamic> challengesMap = {};
    _challenges.forEach((languageId, challengeList) {
      challengesMap[languageId] = challengeList.map((challenge) => challenge.toJson()).toList();
    });
    _prefs.setString('challenges', jsonEncode(challengesMap));
  }

  // Flashcard methods
  List<Flashcard> getFlashcardsForLanguage(String languageId) {
    return _flashcards[languageId] ?? [];
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    if (!_flashcards.containsKey(flashcard.languageId)) {
      _flashcards[flashcard.languageId] = [];
    }
    _flashcards[flashcard.languageId]!.add(flashcard);
    _saveFlashcards();
    notifyListeners();
  }

  Future<void> updateFlashcard(Flashcard updatedFlashcard) async {
    final languageId = updatedFlashcard.languageId;
    if (_flashcards.containsKey(languageId)) {
      final index = _flashcards[languageId]!.indexWhere((card) => card.id == updatedFlashcard.id);
      if (index >= 0) {
        _flashcards[languageId]![index] = updatedFlashcard;
        _saveFlashcards();
        notifyListeners();
      }
    }
  }

  Future<void> deleteFlashcard(String flashcardId, String languageId) async {
    if (_flashcards.containsKey(languageId)) {
      _flashcards[languageId]!.removeWhere((card) => card.id == flashcardId);
      _saveFlashcards();
      notifyListeners();
    }
  }

  // Quiz methods
  List<Quiz> getQuizzesForLanguage(String languageId) {
    return _quizzes[languageId] ?? [];
  }

  Quiz? getQuizById(String quizId, String languageId) {
    if (_quizzes.containsKey(languageId)) {
      return _quizzes[languageId]!.firstWhere(
        (quiz) => quiz.id == quizId,
        orElse: () => throw Exception('Quiz not found'),
      );
    }
    return null;
  }

  // Challenge methods
  List<Challenge> getChallengesForLanguage(String languageId) {
    return _challenges[languageId] ?? [];
  }

  Challenge? getTodaysChallenge(String languageId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_challenges.containsKey(languageId)) {
      // Find today's challenge
      for (final challenge in _challenges[languageId]!) {
        final challengeDate = DateTime(
          challenge.date.year,
          challenge.date.month,
          challenge.date.day,
        );
        
        if (challengeDate.isAtSameMomentAs(today)) {
          return challenge;
        }
      }
    }
    
    // If no challenge exists for today, create one
    final newChallenge = Challenge.generateDailyChallenge(languageId);
    if (!_challenges.containsKey(languageId)) {
      _challenges[languageId] = [];
    }
    _challenges[languageId]!.add(newChallenge);
    _saveChallenges();
    
    return newChallenge;
  }

  Future<void> completeChallenge(String challengeId, String languageId, String userAnswer) async {
    if (_challenges.containsKey(languageId)) {
      final index = _challenges[languageId]!.indexWhere((c) => c.id == challengeId);
      if (index >= 0) {
        final challenge = _challenges[languageId]![index];
        _challenges[languageId]![index] = challenge.copyWith(
          isCompleted: true,
          userAnswer: userAnswer,
        );
        _saveChallenges();
        notifyListeners();
      }
    }
  }

  // Get language by ID
  Language getLanguageById(String languageId) {
    return _availableLanguages.firstWhere(
      (lang) => lang.id == languageId,
      orElse: () => _availableLanguages.first,
    );
  }
}