class Language {
  final String id;
  final String name;
  final String code;
  final String flagEmoji;
  
  const Language({
    required this.id,
    required this.name,
    required this.code,
    required this.flagEmoji,
  });
  
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      flagEmoji: json['flagEmoji'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'flagEmoji': flagEmoji,
    };
  }
}

// Define some sample languages
class Languages {
  static const List<Language> all = [
    Language(id: '1', name: 'English', code: 'en', flagEmoji: '🇬🇧'),
    Language(id: '2', name: 'Spanish', code: 'es', flagEmoji: '🇪🇸'),
    Language(id: '3', name: 'French', code: 'fr', flagEmoji: '🇫🇷'),
    Language(id: '4', name: 'German', code: 'de', flagEmoji: '🇩🇪'),
    Language(id: '5', name: 'Italian', code: 'it', flagEmoji: '🇮🇹'),
    Language(id: '6', name: 'Japanese', code: 'ja', flagEmoji: '🇯🇵'),
    Language(id: '7', name: 'Korean', code: 'ko', flagEmoji: '🇰🇷'),
    Language(id: '8', name: 'Chinese', code: 'zh', flagEmoji: '🇨🇳'),
    Language(id: '9', name: 'Russian', code: 'ru', flagEmoji: '🇷🇺'),
    Language(id: '10', name: 'Portuguese', code: 'pt', flagEmoji: '🇵🇹'),
  ];
}