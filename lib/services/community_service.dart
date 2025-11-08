import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class CommunityService {
  /// 统一封装 HTTP 请求
  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 拼接 URL
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));

    // 构造 Headers
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // 打印请求日志
    print('\n[$method] $uri');
    print('headers: $headers');
    if (body != null) print('body: ${jsonEncode(body)}');

    // 发起请求
    late http.Response res;
    switch (method) {
      case 'GET':
        res = await http.get(uri, headers: headers);
        break;
      case 'POST':
        res = await http.post(uri, headers: headers, body: jsonEncode(body));
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // 打印响应日志
    print('状态码: ${res.statusCode}');
    print('响应体: ${res.body}');

    if (res.body.isEmpty) {
      throw Exception('服务器未返回内容');
    }

    final decoded = jsonDecode(res.body);

    if (res.statusCode == 200 && decoded['code'] == 200) {
      final inner = decoded['data'];

      // 若 data 为数组（评论等接口）
      if (inner is List) {
        return {'_list': inner};
      }

      // 若 data 为对象
      return Map<String, dynamic>.from(inner ?? {});
    } else {
      throw Exception(decoded['message'] ?? '请求失败');
    }
  }

  /// 获取博文列表
  static Future<List<Map<String, dynamic>>> getPosts({
    int page = 1,
    int size = 10,
    String? keyword,
  }) async {
    final data = await _request(
      'GET',
      '/community/posts',
      query: {
        'page': page,
        'size': size,
        if (keyword != null) 'keyword': keyword,
      },
    );

    final list = List<Map<String, dynamic>>.from(data['list'] ?? []);
    print('获取帖子成功：共 ${list.length} 条');
    return list;
  }

  /// 获取博文详情
  static Future<Map<String, dynamic>> getPostDetail(int postId) async {
    final data = await _request('GET', '/community/posts/$postId');
    print('获取详情成功：${data['title']}');
    return data;
  }

  /// 发布博文
  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    bool isAnonymous = false,
  }) async {
    final data = await _request(
      'POST',
      '/community/posts',
      body: {'title': title, 'content': content, 'isAnonymous': isAnonymous},
    );
    print('发布成功：postId=${data['postId']}');
    return data;
  }

  /// 获取评论列表
  static Future<List<Map<String, dynamic>>> getComments(
    int postId, {
    int page = 1,
    int size = 10,
  }) async {
    final result = await _request(
      'GET',
      '/community/posts/$postId/comments',
      query: {'page': page, 'size': size},
    );

    final list = List<Map<String, dynamic>>.from(result['_list'] ?? []);
    print('获取评论成功：共 ${list.length} 条');
    return list;
  }

  /// 发表评论
  static Future<void> addComment({
    required int postId,
    required String content,
    int? parentId,
    bool isAnonymous = false,
  }) async {
    await _request(
      'POST',
      '/community/posts/$postId/comments',
      body: {
        'content': content,
        'parentId': parentId,
        'isAnonymous': isAnonymous,
      },
    );
    print('评论成功');
  }

  /// 点赞 / 取消点赞
  static Future<void> likePost({
    required int postId,
    required String token,
    bool isLike = true,
  }) async {
    final action = isLike ? 'LIKE' : 'UNLIKE';
    final url = Uri.parse(
      '$baseUrl/community/posts/$postId/like?action=$action',
    );

    print('[POST] $url');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('状态码: ${response.statusCode}');
    print('响应体: ${response.body}');
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['code'] == 200) {
      print('点赞操作成功：$action');
    } else {
      throw Exception(decoded['message'] ?? '点赞操作失败');
    }
  }

  /// 删除博文
  static Future<void> deletePost(int postId) async {
    await _request('DELETE', '/community/posts/$postId');
    print('删除帖子成功');
  }

  /// 删除评论
  static Future<void> deleteComment(int commentId) async {
    await _request('DELETE', '/community/comments/$commentId');
    print('删除评论成功');
  }
}
