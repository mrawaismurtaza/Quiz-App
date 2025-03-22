import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:dreamflow/models/challenge_model.dart';
import 'package:dreamflow/services/user_service.dart';
import 'package:dreamflow/services/language_service.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> with SingleTickerProviderStateMixin {
  Challenge? _todayChallenge;
  bool _isLoading = true;
  bool _hasSubmitted = false;
  final TextEditingController _answerController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCorrect = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _loadTodayChallenge();
  }
  
  @override
  void dispose() {
    _answerController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTodayChallenge() async {
    final userService = Provider.of<UserService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    final challenge = languageService.getTodaysChallenge(userService.selectedLanguageId);
    
    setState(() {
      _todayChallenge = challenge;
      _isLoading = false;
      _hasSubmitted = challenge?.isCompleted ?? false;
      if (_hasSubmitted && _todayChallenge?.userAnswer != null) {
        _answerController.text = _todayChallenge!.userAnswer!;
        _isCorrect = _checkAnswer(_todayChallenge!.userAnswer!);
      }
    });
  }
  
  bool _checkAnswer(String answer) {
    if (_todayChallenge == null) return false;
    
    // Simple direct comparison - could be enhanced with fuzzy matching
    // or accepting multiple correct answers
    return answer.trim().toLowerCase() == _todayChallenge!.solution.trim().toLowerCase();
  }
  
  void _submitAnswer() async {
    if (_todayChallenge == null || _answerController.text.trim().isEmpty) return;
    
    final userService = Provider.of<UserService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    final answer = _answerController.text.trim();
    final isCorrect = _checkAnswer(answer);
    
    // Complete the challenge
    await languageService.completeChallenge(
      _todayChallenge!.id,
      _todayChallenge!.languageId,
      answer,
    );
    
    // Award XP if correct
    if (isCorrect) {
      userService.addXp(_todayChallenge!.xpReward, languageId: _todayChallenge!.languageId);
    }
    
    setState(() {
      _hasSubmitted = true;
      _isCorrect = isCorrect;
    });
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userService = Provider.of<UserService>(context);
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.getLanguageById(userService.selectedLanguageId);
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date and streak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Challenge',
                              style: theme.textTheme.displayMedium,
                            ),
                            Text(
                              DateFormat('EEEE, MMMM d').format(DateTime.now()),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '${userService.streak} day streak',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Challenge card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.8),
                              theme.colorScheme.secondary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    currentLanguage.flagEmoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _todayChallenge?.title ?? 'Challenge',
                                      style: theme.textTheme.displaySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '+${_todayChallenge?.xpReward ?? 0} XP',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _todayChallenge?.description ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _todayChallenge?.content ?? '',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Answer section
                    if (_hasSubmitted) ...[  
                      // Show result
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isCorrect ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _isCorrect ? Icons.check_circle : Icons.cancel,
                                color: _isCorrect ? Colors.green : Colors.red,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isCorrect ? 'Correct!' : 'Try Again Tomorrow',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: _isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isCorrect 
                                    ? 'Great job! You earned ${_todayChallenge?.xpReward ?? 0} XP.'
                                    : 'The correct answer was: ${_todayChallenge?.solution}',
                                style: theme.textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              if (_isCorrect) ...[  
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      RichText(
                                        text: TextSpan(
                                          style: theme.textTheme.bodyLarge,
                                          children: [
                                            const TextSpan(text: '+'),
                                            TextSpan(
                                              text: '${_todayChallenge?.xpReward ?? 0}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const TextSpan(text: ' XP'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ] else ...[  
                      // Submit answer form
                      Text(
                        'Your Answer:',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: 'Type your answer here',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Submit Answer'),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Challenge tips
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  'Tips',
                                  style: theme.textTheme.displaySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• Complete daily challenges to maintain your streak',
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• Longer streaks will earn you bonus XP',
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• A new challenge appears every day at midnight',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}