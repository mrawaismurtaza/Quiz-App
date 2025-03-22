import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dreamflow/models/language_model.dart';
import 'package:dreamflow/services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  final Language currentLanguage;
  final Function(Language) onLanguageSelected;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Language>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLanguage.flagEmoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 4),
          Text(
            currentLanguage.code.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      onSelected: onLanguageSelected,
      itemBuilder: (BuildContext context) {
        final languageService = Provider.of<LanguageService>(context, listen: false);
        return languageService.availableLanguages.map((Language language) {
          return PopupMenuItem<Language>(
            value: language,
            child: Row(
              children: [
                Text(
                  language.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(language.name),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}