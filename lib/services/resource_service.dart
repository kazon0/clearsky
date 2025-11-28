import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourceService {
  /// 获取 JWT Token
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  /// 获取资源列表（带分页+筛选）
  static Future<Map<String, dynamic>> getResources({
    int page = 1,
    int size = 10,
    int? categoryId,
    String? type,
    String? keyword,
  }) async {
    final token = await _getToken();

    final query = {'page': '$page', 'size': '$size'};

    if (categoryId != null) query['categoryId'] = '$categoryId';
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (keyword != null && keyword.isNotEmpty) query['keyword'] = keyword;

    final url = Uri.parse('$baseUrl/resources').replace(queryParameters: query);

    print("请求 URL = $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("返回结果 = ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      return result['data'];
    } else {
      throw Exception("资源获取失败：${response.statusCode}");
    }
  }

  /// 获取资源详情
  static Future<Map<String, dynamic>> getResourceDetail(int resourceId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/resources/$resourceId');

    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body)['data'];
      return data;
    } else {
      throw Exception('获取资源详情失败：${res.statusCode}');
    }
  }

  /// 点赞 / 取消点赞
  static Future<void> likeResource(int id, bool isLike) async {
    final token = await _getToken();
    final action = isLike ? 'LIKE' : 'UNLIKE';

    final url = Uri.parse('$baseUrl/resources/$id/like?action=$action');

    final res = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('点赞失败：${res.statusCode}');
    }
  }
}
