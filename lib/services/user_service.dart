import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  String _userId = '';
  String _selectedLanguageId = '';
  Map<String, int> _languageProgress = {};
  int _totalXp = 0;
  int _streak = 0;
  DateTime? _lastActivityDate;
  
  bool get isDarkMode => _isDarkMode;
  String get userId => _userId;
  String get selectedLanguageId => _selectedLanguageId;
  Map<String, int> get languageProgress => _languageProgress;
  int get totalXp => _totalXp;
  int get streak => _streak;
  DateTime? get lastActivityDate => _lastActivityDate;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserData();
  }

  void _loadUserData() {
    // Load user preferences from SharedPreferences
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _userId = _prefs.getString('userId') ?? const Uuid().v4();
    _selectedLanguageId = _prefs.getString('selectedLanguageId') ?? '1'; // Default to English (id: 1)
    
    // Load progress data
    final progressJson = _prefs.getString('languageProgress');
    if (progressJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(progressJson);
      _languageProgress = decoded.map((key, value) => MapEntry(key, value as int));
    }
    
    _totalXp = _prefs.getInt('totalXp') ?? 0;
    _streak = _prefs.getInt('streak') ?? 0;
    
    final lastActivity = _prefs.getString('lastActivityDate');
    if (lastActivity != null) {
      _lastActivityDate = DateTime.parse(lastActivity);
    }
    
    // Update streak if necessary
    _updateStreak();
    
    // Save user ID if it was generated
    if (!_prefs.containsKey('userId')) {
      _prefs.setString('userId', _userId);
    }
  }

  void _updateStreak() {
    if (_lastActivityDate == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastActivity = DateTime(
      _lastActivityDate!.year,
      _lastActivityDate!.month,
      _lastActivityDate!.day
    );
    
    if (lastActivity.isBefore(yesterday)) {
      // Break the streak if last activity was before yesterday
      _streak = 0;
      _prefs.setInt('streak', 0);
    }
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  void setSelectedLanguage(String languageId) {
    _selectedLanguageId = languageId;
    _prefs.setString('selectedLanguageId', languageId);
    notifyListeners();
  }

  void addXp(int amount, {String? languageId}) {
    _totalXp += amount;
    _prefs.setInt('totalXp', _totalXp);
    
    // Update language-specific progress
    if (languageId != null) {
      final currentXp = _languageProgress[languageId] ?? 0;
      _languageProgress[languageId] = currentXp + amount;
      _prefs.setString('languageProgress', jsonEncode(_languageProgress));
    }
    
    // Update last activity date and streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastActivityDate == null) {
      _streak = 1;
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      final lastActivity = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day
      );
      
      if (lastActivity.isBefore(yesterday) && !lastActivity.isAtSameMomentAs(yesterday)) {
        _streak = 1; // Reset streak
      } else if (lastActivity.isAtSameMomentAs(yesterday)) {
        _streak += 1; // Increment streak
      }
      // If same day, streak remains unchanged
    }
    
    _lastActivityDate = now;
    _prefs.setString('lastActivityDate', now.toIso8601String());
    _prefs.setInt('streak', _streak);
    
    notifyListeners();
  }

  // Get level based on XP for a specific language
  int getLevelForLanguage(String languageId) {
    final xp = _languageProgress[languageId] ?? 0;
    // Simple level calculation - can be adjusted as needed
    return (xp / 100).floor() + 1; // Every 100 XP is a new level
  }

  // Reset all user data (for testing)
  Future<void> resetUserData() async {
    await _prefs.clear();
    _isDarkMode = false;
    _userId = const Uuid().v4();
    _selectedLanguageId = '1';
    _languageProgress = {};
    _totalXp = 0;
    _streak = 0;
    _lastActivityDate = null;
    
    // Save the new user ID
    _prefs.setString('userId', _userId);
    
    notifyListeners();
  }
}