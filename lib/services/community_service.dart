import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class CommunityService {
  /// 获取社区帖子列表
  static Future<List<Map<String, dynamic>>> getPosts({
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/api/community/posts?page=$page&limit=$limit');
    final response = await http.get(url, headers: jsonHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // mockapi 直接返回数组
      if (data is List) {
        final list = data.map((e) => Map<String, dynamic>.from(e)).toList();

        // 按时间倒序排序（createdAt 字段）
        list.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        return list;
      } else {
        throw Exception('返回数据格式错误：期望数组');
      }
    } else {
      throw Exception('请求失败：${response.statusCode}');
    }
  }
}
