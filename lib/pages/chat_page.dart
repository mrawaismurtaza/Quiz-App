import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:dreamflow/models/chat_message_model.dart';
import 'package:dreamflow/services/user_service.dart';
import 'package:dreamflow/services/language_service.dart';
import 'package:dreamflow/services/openai_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late OpenAIService _openAIService;
  
  @override
  void initState() {
    super.initState();
    _openAIService = OpenAIService();
    _addWelcomeMessage();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _addWelcomeMessage() {
    final userService = Provider.of<UserService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final currentLanguage = languageService.getLanguageById(userService.selectedLanguageId);
    
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          id: const Uuid().v4(),
          languageId: currentLanguage.id,
          content: 'Hello! I\'m your ${currentLanguage.name} conversation partner. Let\'s practice together! How are you today?',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
      });
    }
  }
  
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final userService = Provider.of<UserService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final currentLanguage = languageService.getLanguageById(userService.selectedLanguageId);
    
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      languageId: currentLanguage.id,
      content: _messageController.text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isLoading = true;
    });
    
    // Scroll to bottom after message is added
    _scrollToBottom();
    
    try {
      final aiResponse = await _openAIService.sendMessage(userMessage.content, currentLanguage);
      
      setState(() {
        _messages.add(aiResponse);
        _isLoading = false;
      });
      
      // Award XP for practicing
      userService.addXp(5, languageId: currentLanguage.id);
      
      // Scroll to bottom after AI response
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          id: const Uuid().v4(),
          languageId: currentLanguage.id,
          content: 'Sorry, I had trouble responding. Please try again.',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
      });
      
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          // Chat header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    currentLanguage.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentLanguage.name} Conversation',
                        style: theme.textTheme.displaySmall,
                      ),
                      Text(
                        'Practice your skills with an AI tutor',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Loading indicator for AI response
                  return _buildLoadingBubble();
                }
                
                final message = _messages[index];
                return _ChatBubble(
                  message: message,
                  isUser: message.sender == MessageSender.user,
                  languageName: currentLanguage.name,
                );
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8, right: 64),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Typing...'),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final String languageName;

  const _ChatBubble({
    required this.message,
    required this.isUser,
    required this.languageName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isUser ? 64 : 0,
          right: isUser ? 0 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUser ? 'You' : '$languageName AI',
                  style: TextStyle(
                    color: isUser
                        ? Colors.white.withOpacity(0.7)
                        : theme.textTheme.bodyMedium?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: isUser
                        ? Colors.white.withOpacity(0.7)
                        : theme.textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}