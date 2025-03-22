import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';

import 'package:dreamflow/models/flashcard_model.dart';
import 'package:dreamflow/services/user_service.dart';
import 'package:dreamflow/services/language_service.dart';
import 'package:dreamflow/widgets/add_flashcard_dialog.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFlipped = false;
  int _currentCardIndex = 0;
  List<Flashcard> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFlashcards();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadFlashcards() {
    final userService = Provider.of<UserService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    _flashcards = languageService.getFlashcardsForLanguage(userService.selectedLanguageId);
    setState(() {
      _currentCardIndex = _flashcards.isEmpty ? -1 : 0;
    });
  }

  void _flipCard() {
    setState(() {
      if (_isFlipped) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      _isFlipped = !_isFlipped;
    });
  }

  void _markCardKnown() {
    if (_flashcards.isEmpty || _currentCardIndex < 0) return;
    
    final userService = Provider.of<UserService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    final currentCard = _flashcards[_currentCardIndex];
    final updatedCard = currentCard.copyWith(
      masteryLevel: math.min(1.0, currentCard.masteryLevel + 0.2),
      lastReviewed: DateTime.now(),
    );
    
    languageService.updateFlashcard(updatedCard);
    userService.addXp(5, languageId: currentCard.languageId);
    
    _nextCard();
  }

  void _markCardUnknown() {
    if (_flashcards.isEmpty || _currentCardIndex < 0) return;
    
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    final currentCard = _flashcards[_currentCardIndex];
    final updatedCard = currentCard.copyWith(
      masteryLevel: math.max(0.0, currentCard.masteryLevel - 0.1),
      lastReviewed: DateTime.now(),
    );
    
    languageService.updateFlashcard(updatedCard);
    
    _nextCard();
  }

  void _nextCard() {
    setState(() {
      if (_isFlipped) {
        _animationController.reverse();
        _isFlipped = false;
      }
      
      if (_currentCardIndex < _flashcards.length - 1) {
        _currentCardIndex++;
      } else {
        // End of deck
        _currentCardIndex = _flashcards.isEmpty ? -1 : 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End of flashcards deck')),
        );
      }
    });
  }

  void _addNewFlashcard() async {
    final result = await showDialog<Flashcard>(
      context: context,
      builder: (context) => const AddFlashcardDialog(),
    );
    
    if (result != null) {
      final languageService = Provider.of<LanguageService>(context, listen: false);
      await languageService.addFlashcard(result);
      _loadFlashcards();
    }
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
          // Header with stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_flashcards.length}',
                      style: theme.textTheme.displaySmall,
                    ),
                    Text(
                      'Cards',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      currentLanguage.flagEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      currentLanguage.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${userService.getLevelForLanguage(currentLanguage.id)}',
                      style: theme.textTheme.displaySmall,
                    ),
                    Text(
                      'Level',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Flashcard area
          Expanded(
            child: _flashcards.isEmpty || _currentCardIndex < 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.style_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No flashcards yet',
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some flashcards to start learning',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _addNewFlashcard,
                          child: const Text('Add Flashcard'),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: _flipCard,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // Swiped right - mark as known
                        _markCardKnown();
                      } else if (details.primaryVelocity! < 0) {
                        // Swiped left - mark as unknown
                        _markCardUnknown();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final isFlipped = _animation.value >= 0.5;
                        final transform = Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateY(_animation.value * math.pi);
                        
                        return Transform(
                          transform: transform,
                          alignment: Alignment.center,
                          child: Card(
                            margin: const EdgeInsets.all(24),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!isFlipped) ...[  // Front side
                                    Text(
                                      _flashcards[_currentCardIndex].term,
                                      style: theme.textTheme.displayLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    if (_flashcards[_currentCardIndex].example != null)
                                      Text(
                                        _flashcards[_currentCardIndex].example!,
                                        style: theme.textTheme.bodyLarge!.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: theme.textTheme.bodyLarge!.color!.withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ] else ...[  // Back side (flipped horizontally)
                                    Transform(
                                      transform: Matrix4.identity()..rotateY(math.pi),
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Text(
                                            _flashcards[_currentCardIndex].definition,
                                            style: theme.textTheme.displayLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 32),
                                          Text(
                                            'Tap to flip card',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          
          // Bottom controls
          if (_flashcards.isNotEmpty && _currentCardIndex >= 0)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.close,
                    color: Colors.redAccent,
                    onPressed: _markCardUnknown,
                    tooltip: 'Don\'t Know',
                  ),
                  _ActionButton(
                    icon: Icons.refresh,
                    color: Colors.amber,
                    onPressed: _flipCard,
                    tooltip: 'Flip Card',
                  ),
                  _ActionButton(
                    icon: Icons.check,
                    color: Colors.greenAccent,
                    onPressed: _markCardKnown,
                    tooltip: 'Know It',
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFlashcard,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
      ),
    );
  }
}