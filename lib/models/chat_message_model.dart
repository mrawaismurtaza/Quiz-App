enum MessageSender {
  user,
  ai,
}

class ChatMessage {
  final String id;
  final String languageId;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final String? translation; // Optional translation to user's native language

  ChatMessage({
    required this.id,
    required this.languageId,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.translation,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      languageId: json['languageId'],
      content: json['content'],
      sender: MessageSender.values.byName(json['sender']),
      timestamp: DateTime.parse(json['timestamp']),
      translation: json['translation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageId': languageId,
      'content': content,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'translation': translation,
    };
  }
}