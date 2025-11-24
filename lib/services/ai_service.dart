import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AiService {
  /// 创建新会话
  static Future<Map<String, dynamic>> createConversation(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/ai/conversations');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title}),
    );

    final data = json.decode(response.body);
    return data;
  }

  ///  发送消息
  static Future<Map<String, dynamic>> sendMessage(
    int conversationId,
    String content,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/ai/conversations/$conversationId/messages');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content, 'messageType': 'TEXT'}),
    );

    final data = json.decode(response.body);
    return data;
  }

  ///  获取会话详情（含所有消息）
  static Future<Map<String, dynamic>> getConversationDetail(
    int conversationId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/ai/conversations/$conversationId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(response.body);
    return data;
  }

  /// 向人工咨询师发送消息
  static Future<Map<String, dynamic>> sendHumanMessage(
    int conversationId,
    String content,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(
      '$baseUrl/ai/conversations/$conversationId/human-messages',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content, 'messageType': 'TEXT'}),
    );

    final data = json.decode(response.body);
    return data;
  }
}
