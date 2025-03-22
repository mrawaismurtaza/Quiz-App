import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:dreamflow/models/chat_message_model.dart';
import 'package:dreamflow/models/language_model.dart';

class OpenAIService {
  static const String _apiKey = "OPENAI-API-KEY";
  static const String _baseUrl = "https://api.openai.com/v1/chat/completions";
  
  // Send a message to the OpenAI API and get a response
  Future<ChatMessage> sendMessage(String message, Language language) async {
    final systemPrompt = _generateSystemPrompt(language);
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Create a new chat message from the response
        return ChatMessage(
          id: const Uuid().v4(),
          languageId: language.id,
          content: content,
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with OpenAI: $e');
    }
  }

  // Generate a system prompt based on the language
  String _generateSystemPrompt(Language language) {
    return '''You are a helpful language tutor for ${language.name}. 
    Your job is to help the user practice ${language.name} through conversation.
    
    Follow these rules strictly:
    1. Respond ONLY in ${language.name} unless the user explicitly asks for a translation or explanation in English.
    2. Keep responses concise and appropriate for language learners.
    3. Use simple vocabulary and sentence structures that beginners can understand.
    4. If the user makes mistakes, gently correct them and explain the correct form.
    5. If the user seems to struggle, offer hints or simplify your language further.
    6. Incorporate common phrases and idioms where appropriate to enhance learning.
    7. Be encouraging and supportive, as language learning can be challenging.
    
    When responding to messages, try to continue the conversation with questions or prompts that encourage the user to practice more. However, always make your responses natural and conversational, not like a rigid language exercise.''';
  }
  
  // Use this method to translate text when needed
  Future<String> translateText(String text, String fromLanguageCode, String toLanguageCode) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a translation assistant. Translate the provided text accurately without adding any explanations or extra content.',
            },
            {
              'role': 'user',
              'content': 'Translate the following text from $fromLanguageCode to $toLanguageCode: "$text"',
            },
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to translate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error translating text: $e');
    }
  }
}