import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/auth/me');

    // ===== 调试输出 =====
    debugPrint('[UserService] 请求用户信息');
    debugPrint('[UserService] URL: $url');
    debugPrint('[UserService] token: $token');
    debugPrint(
      '[UserService] headers: ${jsonEncode(jsonHeaders(token: token))}',
    );
    // ===================

    final response = await http.get(url, headers: jsonHeaders(token: token));

    debugPrint('[UserService] 状态码: ${response.statusCode}');
    debugPrint('[UserService] 响应内容: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('获取用户信息失败：${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> updateUserInfo(
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/users/profile');

    final response = await http.put(
      url,
      headers: jsonHeaders(token: token),
      body: jsonEncode(data),
    );
    debugPrint('[UPDATE] 请求地址: $url');
    debugPrint('[UPDATE] 请求Headers: ${jsonEncode(jsonHeaders(token: token))}');
    debugPrint('[UPDATE] 请求Body: ${jsonEncode(data)}');
    debugPrint('[UPDATE] 状态码: ${response.statusCode}');
    debugPrint('[UPDATE] 响应内容: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("更新失败：${response.statusCode}");
    }
  }
}
