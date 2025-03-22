import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dreamflow/services/language_service.dart';
import 'package:dreamflow/services/user_service.dart';
import 'package:dreamflow/utils/theme.dart';
import 'package:dreamflow/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userService = UserService();
  await userService.init();
  final languageService = LanguageService();
  await languageService.init();
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => userService),
      ChangeNotifierProvider(create: (context) => languageService),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Quiz App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Provider.of<UserService>(context).isDarkMode 
          ? ThemeMode.dark 
          : ThemeMode.light,
      home: const HomePage(),
    );
  }
}