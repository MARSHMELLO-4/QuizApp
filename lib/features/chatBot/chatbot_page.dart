import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:quizpp/widgets/chatBubble.dart';

import 'chatmessage.dart';

class ChatbotPage extends StatefulWidget {
  final String question;
  final String correctOption;
  final String? selectedOption;
  const ChatbotPage({
    super.key,
    required this.question,
    required this.correctOption,
    required this.selectedOption,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;
  final Gemini gemini = Gemini.instance;
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isResponding = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _showQuestionFromUser();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showQuestionFromUser() {
    final userQuestionMessage = ChatMessage(
      isUser: true,
      text: 'Question: ${widget.question}\n\n'
          'Your answer: ${widget.selectedOption ?? "None"}\n'
          'why ?',
    );
    _addMessage(userQuestionMessage);
    _handleSendMessage(userQuestionMessage);
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
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

  void _handleSendMessage(ChatMessage message) {
    if (!message.isUser) return;

    setState(() {
      _isResponding = true;
    });

    // Add typing indicator
    final typingMessage = ChatMessage(
      isUser: false,
      text: '...',
    );
    _addMessage(typingMessage);

    try {
      String fullResponse = '';
      final responseMessageIndex = _messages.length - 1;

      gemini.streamGenerateContent(message.text).listen(
            (event) {
          final response = event.content?.parts
              ?.whereType<TextPart>()
              .map((part) => part.text)
              .join(' ') ??
              '';

          fullResponse += response;

          setState(() {
            _messages[responseMessageIndex] = ChatMessage(
              isUser: false,
              text: fullResponse.trim(),
            );
          });
          _scrollToBottom();
        },
        onDone: () {
          setState(() {
            _isResponding = false;
          });
        },
        onError: (e) {
          setState(() {
            _isResponding = false;
            _messages[responseMessageIndex] = ChatMessage(
              isUser: false,
              text: 'Error: ${e.toString()}',
            );
          });
        },
      );
    } catch (e) {
      setState(() {
        _isResponding = false;
        _messages.removeLast(); // Remove typing indicator
        _addMessage(ChatMessage(
          isUser: false,
          text: 'Error: ${e.toString()}',
        ));
      });
    }
  }

  void _handleSubmitMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isResponding) return;

    final message = ChatMessage(
      isUser: true,
      text: text,
    );
    _addMessage(message);
    _handleSendMessage(message);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Explanation'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                  userImage: message.isUser ? _firebaseUser?.photoURL : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onSubmitted: (_) => _handleSubmitMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSubmitMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

