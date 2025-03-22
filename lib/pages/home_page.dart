import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dreamflow/services/user_service.dart';
import 'package:dreamflow/services/language_service.dart';
import 'package:dreamflow/models/language_model.dart';
import 'package:dreamflow/pages/flashcard_page.dart';
import 'package:dreamflow/pages/quiz_page.dart';
import 'package:dreamflow/pages/challenge_page.dart';
import 'package:dreamflow/pages/chat_page.dart';
import 'package:dreamflow/pages/progress_page.dart';
import 'package:dreamflow/widgets/language_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const FlashcardPage(),
    const QuizPage(),
    const ChallengePage(),
    const ChatPage(),
    const ProgressPage(),
  ];

  final List<String> _pageTitles = [
    'Flashcards',
    'Quizzes',
    'Daily Challenge',
    'Language Chat',
    'Progress'
  ];

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.getLanguageById(userService.selectedLanguageId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          // Language selector
          LanguageSelector(
            currentLanguage: currentLanguage,
            onLanguageSelected: (Language language) {
              userService.setSelectedLanguage(language.id);
            },
          ),
          // Dark mode toggle
          IconButton(
            icon: Icon(userService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              userService.setDarkMode(!userService.isDarkMode);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style),
            label: 'Flashcards',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz),
            label: 'Quizzes',
          ),
          NavigationDestination(
            icon: Icon(Icons.star),
            label: 'Challenge',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}