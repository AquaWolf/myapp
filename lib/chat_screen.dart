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
    // Startnachricht
    _messages.add(ChatMessage(
      text: 'Hallo! Ich bin dein DB Expert AI Begleiter. Wie kann ich dir heute helfen?',
      isUser: false,
      type: 'GENERAL',
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      // Aufruf des Genkit Flows via Firebase Cloud Functions
      final result = await FirebaseFunctions.instance
          .httpsCallable('smartAssistantFlow')
          .call(text);

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
          text: 'Fehler bei der Anfrage: $e',
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
        title: Column(
          children: [
            Text(
              'DB Expert AI',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text('Live Tracking', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ],
        ),
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
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
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
        decoration: const BoxDecoration(
          color: Color(0xFF135BEC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAiRichDataCard(BuildContext context, Map<String, dynamic> data) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40), // Platz für Avatar
        Flexible(
          child: Container(
            width: screenWidth * 0.75,
            margin: const EdgeInsets.only(bottom: 16),
            child: AiRichDataCard(data: data),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(bool isDark, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: 'Frag nach deiner Verbindung...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF135BEC)),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}
