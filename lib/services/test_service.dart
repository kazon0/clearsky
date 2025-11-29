import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart';

class TestService {
  /// 获取 token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 获取测评列表
  static Future<List<Map<String, dynamic>>> getTests({
    String keyword = "",
  }) async {
    final token = await _getToken();

    // 构建 URL（带 keyword 参数）
    final uri = Uri.parse(
      keyword.isEmpty ? '$baseUrl/tests' : '$baseUrl/tests?keyword=$keyword',
    );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("测试接口响应 = ${jsonDecode(res.body)}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final list = (data['data']?['list']) ?? [];

      return List<Map<String, dynamic>>.from(list);
    } else {
      throw Exception('获取测评列表失败：${res.statusCode}');
    }
  }

  /// 获取指定测评的题目
  static Future<Map<String, dynamic>> getQuestions(int testId) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/tests/$testId');

    print('请求 URL: $uri');
    print('Token: $token');

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('状态码: ${res.statusCode}');
    print('响应 body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('解析 data: ${data['data']}');
      return data['data'] ?? data;
    } else {
      throw Exception('加载题目失败：${res.statusCode}');
    }
  }

  /// 提交答案生成报告
  static Future<Map<String, dynamic>> submitAnswers({
    required int testId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/tests/$testId/submit');

    final body = {
      'answers': answers, // 注意 answers 内字段必须是 questionId + answer
      'isAnonymous': false, // 后端要求 boolean（默认 false）
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print("----提交内容----");
      print(body);

      return data['data'] ?? data;
    } else {
      throw Exception('提交失败：${res.statusCode}');
    }
  }
}
