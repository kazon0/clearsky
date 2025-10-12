import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class CounselorService {
  /// 获取咨询师列表
  static Future<List<dynamic>> fetchCounselors({
    String? specialty,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/counselors/availability');

    final response = await http.get(url, headers: jsonHeaders());

    if (response.statusCode == 200) {
      // 解析 JSON 数组
      final data = json.decode(response.body);
      // 确保返回列表类型
      if (data is List) {
        return data;
      } else if (data is Map && data['data'] is List) {
        // 如果 mock 平台外层包了 data 字段
        return data['data'];
      } else {
        throw Exception('响应格式异常');
      }
    } else {
      throw Exception('获取咨询师列表失败：${response.statusCode}');
    }
  }
}
