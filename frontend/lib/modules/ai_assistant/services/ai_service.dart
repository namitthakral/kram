import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../../../../core/services/api_service.dart';

class AiService {
  final Dio _dio = ApiService().dio;

  Future<ChatMessage> sendMessage(String message, {int? userId}) async {
    try {
      final response = await _dio.post(
        '/ai/chat',
        data: {'prompt': message, if (userId != null) 'userId': userId},
      );

      final responseText = response.data['response'] as String;

      return ChatMessage(
        text: responseText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get response from AI: $e');
    }
  }
}
