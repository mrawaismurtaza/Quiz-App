import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:dreamflow/models/language_model.dart';
import 'package:dreamflow/services/user_service.dart';
import 'package:dreamflow/services/language_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          currentLanguage.flagEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Progress',
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currentLanguage.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${userService.totalXp}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(' XP'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  '${userService.streak}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(' days'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLevelProgressBar(userService, currentLanguage),
                ],
              ),
            ),
          ),
          
          // Tab bar for switching views
          TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyLarge?.color,
            tabs: const [
              Tab(text: 'STATISTICS'),
              Tab(text: 'ACHIEVEMENTS'),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Statistics tab
                _StatisticsView(language: currentLanguage),
                
                // Achievements tab
                _AchievementsView(language: currentLanguage),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelProgressBar(UserService userService, Language language) {
    final level = userService.getLevelForLanguage(language.id);
    final xp = userService.languageProgress[language.id] ?? 0;
    final xpForCurrentLevel = (level - 1) * 100;
    final xpForNextLevel = level * 100;
    final progress = (xp - xpForCurrentLevel) / 100.0; // 100 XP per level
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Level ${level + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            color: Colors.white,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$xpForCurrentLevel XP',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
            Text(
              '$xpForNextLevel XP',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatisticsView extends StatelessWidget {
  final Language language;

  const _StatisticsView({required this.language});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userService = Provider.of<UserService>(context);
    final xp = userService.languageProgress[language.id] ?? 0;
    
    // Mock data for the chart - in a real app this would come from user activity
    final weeklyData = [
      FlSpot(1, 20), // Monday
      FlSpot(2, 35), // Tuesday
      FlSpot(3, 15), // Wednesday
      FlSpot(4, 40), // Thursday
      FlSpot(5, 25), // Friday
      FlSpot(6, 50), // Saturday
      FlSpot(7, 30), // Sunday
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Overview
          Text(
            'Overview',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(
                icon: Icons.calendar_today,
                color: Colors.blue,
                title: 'Current streak',
                value: '${userService.streak} days',
              ),
              const SizedBox(width: 16),
              _StatCard(
                icon: Icons.star,
                color: Colors.amber,
                title: 'Total XP',
                value: '$xp XP',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(
                icon: Icons.emoji_events,
                color: Colors.orange,
                title: 'Level',
                value: '${userService.getLevelForLanguage(language.id)}',
              ),
              const SizedBox(width: 16),
              _StatCard(
                icon: Icons.checklist,
                color: Colors.green,
                title: 'Exercises',
                value: '${(xp / 5).round()}', // Assuming 5 XP per exercise
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Weekly Progress Chart
          Text(
            'Weekly Progress',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const days = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyData,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: theme.colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ],
                minX: 1,
                maxX: 7,
                minY: 0,
                maxY: 60,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Activity Log
          Text(
            'Recent Activity',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          // This would ideally be populated from real user activity data
          _buildActivityItem(
            context,
            icon: Icons.quiz,
            title: 'Completed Basic Phrases Quiz',
            subtitle: 'Earned 15 XP',
            time: '2 hours ago',
          ),
          _buildActivityItem(
            context,
            icon: Icons.chat,
            title: 'Practice Conversation',
            subtitle: 'Earned 10 XP',
            time: 'Yesterday',
          ),
          _buildActivityItem(
            context,
            icon: Icons.star,
            title: 'Completed Daily Challenge',
            subtitle: 'Earned 10 XP',
            time: 'Yesterday',
          ),
          _buildActivityItem(
            context,
            icon: Icons.style,
            title: 'Added 5 new flashcards',
            subtitle: 'Food vocabulary',
            time: '2 days ago',
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  final Language language;

  const _AchievementsView({required this.language});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userService = Provider.of<UserService>(context);
    
    // Example achievements - in a real app these would be based on user progress
    final achievements = [
      _Achievement(
        title: 'First Step',
        description: 'Complete your first lesson',
        icon: Icons.emoji_events,
        isUnlocked: true,
        progress: 1.0,
      ),
      _Achievement(
        title: 'Vocabulary Builder',
        description: 'Learn 50 new words',
        icon: Icons.style,
        isUnlocked: (userService.languageProgress[language.id] ?? 0) >= 100,
        progress: ((userService.languageProgress[language.id] ?? 0) / 100).clamp(0.0, 1.0),
      ),
      _Achievement(
        title: 'Conversation Starter',
        description: 'Have 10 conversations with the AI',
        icon: Icons.chat,
        isUnlocked: false,
        progress: 0.4, // Mock progress
      ),
      _Achievement(
        title: 'Quiz Master',
        description: 'Get a perfect score on 5 quizzes',
        icon: Icons.quiz,
        isUnlocked: false,
        progress: 0.6, // Mock progress
      ),
      _Achievement(
        title: '7 Day Streak',
        description: 'Practice for 7 days in a row',
        icon: Icons.local_fire_department,
        isUnlocked: userService.streak >= 7,
        progress: (userService.streak / 7.0).clamp(0.0, 1.0),
      ),
      _Achievement(
        title: '30 Day Streak',
        description: 'Practice for 30 days in a row',
        icon: Icons.whatshot,
        isUnlocked: userService.streak >= 30,
        progress: (userService.streak / 30.0).clamp(0.0, 1.0),
      ),
      _Achievement(
        title: 'Level 5',
        description: 'Reach level 5 in ${language.name}',
        icon: Icons.military_tech,
        isUnlocked: userService.getLevelForLanguage(language.id) >= 5,
        progress: (userService.getLevelForLanguage(language.id) / 5.0).clamp(0.0, 1.0),
      ),
      _Achievement(
        title: 'Challenge Champion',
        description: 'Complete 10 daily challenges',
        icon: Icons.star,
        isUnlocked: false,
        progress: 0.3, // Mock progress
      ),
    ];
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _AchievementCard(achievement: achievements[index]);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Achievement icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  value: achievement.progress,
                  backgroundColor: Colors.transparent,
                  color: achievement.isUnlocked ? Colors.amber : Colors.grey.shade400,
                  strokeWidth: 6,
                ),
              ),
              Icon(
                achievement.icon,
                size: 36,
                color: achievement.isUnlocked ? Colors.amber : Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Achievement title and description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(
                  achievement.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? theme.textTheme.titleMedium?.color
                        : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: achievement.isUnlocked
                        ? theme.textTheme.bodySmall?.color
                        : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Status text
          Text(
            achievement.isUnlocked
                ? 'UNLOCKED'
                : '${(achievement.progress * 100).round()}% COMPLETE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? Colors.amber : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}