import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dreamflow/models/quiz_model.dart';
import 'package:dreamflow/services/user_service.dart';
import 'package:dreamflow/services/language_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Quiz> _quizzes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    final userService = Provider.of<UserService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    setState(() {
      _quizzes = languageService.getQuizzesForLanguage(userService.selectedLanguageId);
    });
  }

  void _startQuiz(Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizSessionPage(quiz: quiz),
      ),
    ).then((_) => _loadQuizzes()); // Refresh when returning from quiz
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userService = Provider.of<UserService>(context);
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.getLanguageById(userService.selectedLanguageId);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    currentLanguage.flagEmoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentLanguage.name} Quizzes',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Test your knowledge and earn XP',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quiz list
          Expanded(
            child: _quizzes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No quizzes available',
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back soon for new quizzes',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _quizzes[index];
                      return _QuizCard(
                        quiz: quiz,
                        onStart: () => _startQuiz(quiz),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onStart;

  const _QuizCard({
    required this.quiz,
    required this.onStart,
  });

  String _getDifficultyEmoji() {
    switch (quiz.difficulty.toLowerCase()) {
      case 'easy':
        return '🌱';
      case 'medium':
        return '🌿';
      case 'hard':
        return '🌲';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: theme.textTheme.displayMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getDifficultyEmoji()),
                        const SizedBox(width: 4),
                        Text(
                          quiz.difficulty.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quiz.description,
                style: theme.textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.question_mark, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.questions.length} questions',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (quiz.timeLimit > 0)
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.timeLimit} seconds',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Start Quiz'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizSessionPage extends StatefulWidget {
  final Quiz quiz;

  const QuizSessionPage({super.key, required this.quiz});

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  List<String> _userAnswers = [];
  int _correctAnswers = 0;
  int? _timeLeft;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Initialize user answers
    _userAnswers = List.filled(widget.quiz.questions.length, '');
    
    // Setup timer if quiz has time limit
    if (widget.quiz.timeLimit > 0) {
      _timeLeft = widget.quiz.timeLimit;
      _startTimer();
    }
  }
  
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _timeLeft = _timeLeft! - 1;
      });
      
      if (_timeLeft! <= 0) {
        _finishQuiz();
      } else {
        _startTimer();
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _checkAnswer(String answer) {
    if (_hasAnswered) return; // Prevent multiple selections
    
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;
    
    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
      _userAnswers[_currentQuestionIndex] = answer;
      
      if (isCorrect) {
        _correctAnswers++;
      }
    });
    
    _animationController.forward();
    
    // Move to next question after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
        _goToNextQuestion();
      } else {
        _finishQuiz();
      }
    });
  }
  
  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _hasAnswered = false;
    });
    
    _animationController.reset();
    _pageController.animateToPage(
      _currentQuestionIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _finishQuiz() {
    final userService = Provider.of<UserService>(context, listen: false);
    
    // Calculate score and award XP
    final scorePercentage = (_correctAnswers / widget.quiz.questions.length) * 100;
    int xpEarned = 0;
    
    if (scorePercentage >= 80) {
      xpEarned = 20;
    } else if (scorePercentage >= 60) {
      xpEarned = 15;
    } else if (scorePercentage >= 40) {
      xpEarned = 10;
    } else {
      xpEarned = 5;
    }
    
    userService.addXp(xpEarned, languageId: widget.quiz.languageId);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          quiz: widget.quiz,
          userAnswers: _userAnswers,
          correctAnswers: _correctAnswers,
          xpEarned: xpEarned,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_timeLeft != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.timer),
                    const SizedBox(width: 4),
                    Text(
                      '$_timeLeft',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            color: theme.colorScheme.primary,
          ),
          
          // Question counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  'Correct: $_correctAnswers',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                final question = widget.quiz.questions[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: theme.textTheme.displaySmall,
                      ),
                      if (question.imageUrl != null) ...[  
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            question.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 50),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: question.options.length,
                          itemBuilder: (context, optionIndex) {
                            final option = question.options[optionIndex];
                            final isSelected = _selectedAnswer == option;
                            final isCorrect = question.correctAnswer == option;
                            
                            Color? backgroundColor;
                            Color? textColor;
                            
                            if (_hasAnswered) {
                              if (isSelected && isCorrect) {
                                backgroundColor = Colors.green.withOpacity(0.2);
                                textColor = Colors.green;
                              } else if (isSelected && !isCorrect) {
                                backgroundColor = Colors.red.withOpacity(0.2);
                                textColor = Colors.red;
                              } else if (isCorrect) {
                                backgroundColor = Colors.green.withOpacity(0.1);
                                textColor = Colors.green;
                              }
                            }
                            
                            return AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                double scale = 1.0;
                                if (_hasAnswered && (isSelected || isCorrect)) {
                                  scale = 1.0 + (_animation.value * 0.05);
                                }
                                
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected 
                                        ? theme.colorScheme.primary 
                                        : Colors.grey.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: _hasAnswered ? null : () => _checkAnswer(option),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: isSelected 
                                              ? theme.colorScheme.primary 
                                              : Colors.grey.withOpacity(0.2),
                                          child: Text(
                                            String.fromCharCode(65 + optionIndex), // A, B, C, D...
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: textColor,
                                              fontWeight: isSelected || isCorrect 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (_hasAnswered) ...[  
                                          const SizedBox(width: 8),
                                          Icon(
                                            isCorrect 
                                                ? Icons.check_circle 
                                                : (isSelected ? Icons.cancel : null),
                                            color: isCorrect ? Colors.green : Colors.red,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Quit Quiz?'),
                          content: const Text('Your progress will be lost.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Quit'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Quit'),
                  ),
                  if (!_hasAnswered)
                    ElevatedButton(
                      onPressed: () {
                        if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
                          // Skip this question
                          _goToNextQuestion();
                        } else {
                          // Last question, finish the quiz
                          _finishQuiz();
                        }
                      },
                      child: const Text('Skip'),
                    )
                  else if (_currentQuestionIndex < widget.quiz.questions.length - 1)
                    ElevatedButton(
                      onPressed: _goToNextQuestion,
                      child: const Text('Next Question'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _finishQuiz,
                      child: const Text('Finish Quiz'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final Quiz quiz;
  final List<String> userAnswers;
  final int correctAnswers;
  final int xpEarned;

  const QuizResultPage({
    super.key,
    required this.quiz,
    required this.userAnswers,
    required this.correctAnswers,
    required this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scorePercentage = (correctAnswers / quiz.questions.length) * 100;
    
    String resultMessage;
    Color resultColor;
    
    if (scorePercentage >= 90) {
      resultMessage = 'Excellent!';
      resultColor = Colors.green;
    } else if (scorePercentage >= 70) {
      resultMessage = 'Great job!';
      resultColor = Colors.lightGreen;
    } else if (scorePercentage >= 50) {
      resultMessage = 'Good effort!';
      resultColor = Colors.amber;
    } else {
      resultMessage = 'Keep practicing!';
      resultColor = Colors.redAccent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Result summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          resultMessage,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$correctAnswers/${quiz.questions.length} correct answers',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${scorePercentage.round()}%',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: resultColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Score'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                '+$xpEarned XP',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Questions Review',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  
                  // Questions review
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quiz.questions.length,
                    itemBuilder: (context, index) {
                      final question = quiz.questions[index];
                      final userAnswer = userAnswers[index];
                      final isCorrect = userAnswer == question.correctAnswer;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCorrect ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isCorrect ? Colors.green : Colors.red,
                                    child: Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      question.question,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (userAnswer.isNotEmpty) ...[  
                                _ResultItem(
                                  label: 'Your answer:',
                                  value: userAnswer,
                                  isCorrect: isCorrect,
                                ),
                              ],
                              if (!isCorrect) ...[  
                                const SizedBox(height: 8),
                                _ResultItem(
                                  label: 'Correct answer:',
                                  value: question.correctAnswer,
                                  isCorrect: true,
                                ),
                              ],
                              if (question.explanation != null) ...[  
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Explanation:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(question.explanation!),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Quizzes'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizSessionPage(quiz: quiz),
                          ),
                        );
                      },
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isCorrect;

  const _ResultItem({
    required this.label,
    required this.value,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green : Colors.red,
          size: 16,
        ),
      ],
    );
  }
}