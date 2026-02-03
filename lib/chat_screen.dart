import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:db_mcp_demo_flutter_app/widgets/ai_rich_data_card.dart';
import 'package:db_mcp_demo_flutter_app/widgets/ai_text_message.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? richData;
  final String? type;

  ChatMessage({required this.text, required this.isUser, this.richData, this.type});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Hallo! Ich bin dein DB Expert AI Begleiter. Wie kann ich dir helfen?',
      isUser: false,
      type: 'GENERAL',
    ));
  }

  // Hilfsmethode um die Historie für Genkit zu formatieren
  List<Map<String, dynamic>> _getHistory() {
    return _messages.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'model',
        'content': [{'text': msg.text}],
      };
    }).toList();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final historyBeforeRequest = _getHistory();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('smartAssistantFlow')
          .call({
            'prompt': text,
            'history': historyBeforeRequest,
          });

      final data = Map<String, dynamic>.from(result.data);
      
      setState(() {
        _messages.add(ChatMessage(
          text: data['text'] ?? '',
          isUser: false,
          type: data['responseType'],
          richData: data['richCard'],
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Fehler: $e',
          isUser: false,
          type: 'GENERAL',
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8);
    final Color surfaceColor = isDark ? const Color(0xFF192233) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text('DB Expert AI', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isUser) {
                  return _buildUserMessage(msg.text);
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AiTextMessage(text: msg.text),
                      if (msg.type == 'TRAIN_STATUS' && msg.richData != null)
                        _buildAiRichDataCard(context, msg.richData!),
                    ],
                  );
                }
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputField(isDark, surfaceColor),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF135BEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAiRichDataCard(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, bottom: 16),
      child: AiRichDataCard(data: data),
    );
  }

  Widget _buildInputField(bool isDark, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _sendMessage,
              decoration: const InputDecoration(hintText: 'Nachricht...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}
