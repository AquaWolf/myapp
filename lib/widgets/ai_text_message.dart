import 'package:flutter/material.dart';

class AiTextMessage extends StatelessWidget {
  final String text;

  const AiTextMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF192233) : Colors.white;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/images/db_logo.png'),
              ),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  children: _buildTextSpans(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    final List<TextSpan> spans = [];
    final RegExp trainIdPattern = RegExp(
      r'\b(ICE|IC|EC|RJ|TGV|RE|RB|S)\s?\d+\b',
    );

    int start = 0;
    for (final match in trainIdPattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF135BEC),
          ),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
