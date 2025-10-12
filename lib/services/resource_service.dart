import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ResourceService {
  static Future<List<Map<String, dynamic>>> getResources({
    String category = '',
    String keyword = '',
  }) async {
    final query = StringBuffer();
    if (category.isNotEmpty) query.write('category=$category&');
    if (keyword.isNotEmpty) query.write('keyword=$keyword');

    final url = Uri.parse('$baseUrl/api/resources?${query.toString()}');
    final response = await http.get(url, headers: jsonHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> list = data['data'] ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('资源获取失败：${response.statusCode}');
    }
  }
}
