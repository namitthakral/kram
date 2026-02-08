enum MessageSender { user, ai }

class ChatMessage {

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
}
