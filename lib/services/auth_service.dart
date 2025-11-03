import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String studentId, String password) async {
    final url = Uri.parse('$baseUrl/api/login');
    final response = await http.post(
      url,
      headers: jsonHeaders(),
      body: jsonEncode({
        'studentId': studentId,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token'] ?? '');
      return data;
    } else {
      throw Exception('登录失败：${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> register(
      String studentId, String password, String name) async {
    final url = Uri.parse('$baseUrl/api/register');
    final response = await http.post(
      url,
      headers: jsonHeaders(),
      body: jsonEncode({
        'studentId': studentId,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('注册失败：${response.statusCode}');
    }
  }
}
