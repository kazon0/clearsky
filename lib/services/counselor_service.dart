import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class CounselorService {
  /// 统一请求封装
  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 拼 URL
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));

    // Header
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // ========= 调试输出 =========
    print('\n================ HTTP 调试 =================');
    print('[请求方式] $method');
    print('[请求地址] $uri');
    print('[请求头部] $headers');
    if (body != null) print('[请求体] ${jsonEncode(body)}');
    print('===========================================');

    // 发送请求
    late http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: headers);
          break;
        case 'POST':
          res = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          res = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      print(' 网络请求失败: $e');
      throw Exception('网络异常或服务器未响应');
    }

    // ========= 响应调试 =========
    print('[响应状态码] ${res.statusCode}');
    print('[响应头部] ${res.headers}');
    print('[响应体内容] ${res.body}');
    print('===========================================\n');

    // 空响应
    if (res.body.isEmpty) {
      throw Exception('服务器未返回内容（可能被拦截或跨域）');
    }

    // 尝试解析 JSON
    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (e) {
      throw Exception('响应解析失败：${res.body}');
    }

    // 403 特殊提示
    if (res.statusCode == 403) {
      throw Exception('无访问权限 (403)：请检查是否登录、Token是否过期、角色是否匹配');
    }

    if (res.statusCode == 200 && decoded is Map && decoded['code'] == 200) {
      final data = decoded['data'];
      if (data is List) return {'_list': data};
      return Map<String, dynamic>.from(data ?? {});
    } else {
      throw Exception(decoded['message'] ?? '请求失败 (${res.statusCode})');
    }
  }

  /// 获取咨询师列表
  static Future<List<Map<String, dynamic>>> fetchCounselors({
    int page = 1,
    int size = 10,
    String? specialization,
    double? minRating,
  }) async {
    final result = await _request(
      'GET',
      '/consultants',
      withAuth: true,
      query: {
        'page': page,
        'size': size,
        if (specialization != null && specialization.isNotEmpty)
          'specialization': specialization,
        if (minRating != null) 'minRating': minRating,
      },
    );

    final list = List<Map<String, dynamic>>.from(result['list'] ?? []);
    print('获取咨询师成功：共 ${list.length} 位');
    return list;
  }

  /// 获取咨询师详情
  static Future<Map<String, dynamic>> getConsultantDetail(
    int consultantId,
  ) async {
    final data = await _request(
      'GET',
      '/consultants/$consultantId',
      withAuth: true,
    );
    print('获取咨询师详情：${data['realName']}');
    return data;
  }

  /// 获取咨询师可预约时间
  static Future<List<Map<String, dynamic>>> getAvailableSchedules(
    int consultantId, {
    String? startDate,
    String? endDate,
  }) async {
    final result = await _request(
      'GET',
      '/consultants/$consultantId/schedules',
      withAuth: true,
      query: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
    );

    final list = List<Map<String, dynamic>>.from(result['_list'] ?? []);
    print('获取可预约时间：共 ${list.length} 条');
    return list;
  }

  /// 创建预约
  static Future<Map<String, dynamic>> createAppointment({
    required int consultantId,
    required int scheduleId,
    required String appointmentDate,
    required String startTime,
    required String endTime,
    String? userNotes,
  }) async {
    final data = await _request(
      'POST',
      '/appointments',
      withAuth: true,
      body: {
        'consultantId': consultantId,
        'scheduleId': scheduleId,
        'appointmentDate': appointmentDate,
        'startTime': startTime,
        'endTime': endTime,
        'userNotes': userNotes ?? '',
      },
    );
    print('预约成功：appointmentId=${data['appointmentId']}');
    return data;
  }

  /// 获取我的预约列表
  static Future<List<Map<String, dynamic>>> getMyAppointments({
    int page = 1,
    int size = 10,
    String? status,
  }) async {
    final result = await _request(
      'GET',
      '/appointments/my',
      withAuth: true,
      query: {'page': page, 'size': size, if (status != null) 'status': status},
    );

    final list = List<Map<String, dynamic>>.from(result['list'] ?? []);
    print('获取我的预约：共 ${list.length} 条');
    return list;
  }

  /// 取消预约
  static Future<void> cancelAppointment({
    required int appointmentId,
    required String reason,
  }) async {
    await _request(
      'PUT',
      '/appointments/$appointmentId/cancel',
      withAuth: true,
      body: {'reason': reason},
    );
    print('取消预约成功');
  }
}
