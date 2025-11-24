import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  bool isLoggedIn = false;
  bool isLoading = false;
  Map<String, dynamic>? userInfo;
  String greeting = '';

  /// 初始化时自动设置问候语并检查登录
  Future<void> checkLoginAndLoad() async {
    debugPrint('[UserVM] 开始检测登录状态');
    isLoading = true;
    greeting = _getGreeting();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final logged = prefs.getBool('isLoggedIn') ?? false;
    debugPrint('[UserVM] 本地登录标志: $logged');

    if (!logged) {
      isLoggedIn = false;
      isLoading = false;
      debugPrint('[UserVM] 未登录，结束检测');
      notifyListeners();
      return;
    }

    try {
      debugPrint('[UserVM] 已登录，尝试获取用户信息');
      final res = await UserService.getUserInfo();
      debugPrint('[UserVM] API响应: $res');

      if (res['code'] == 200) {
        isLoggedIn = true;
        userInfo = res['data'];
        debugPrint('[UserVM] 用户信息加载成功');
      } else {
        isLoggedIn = false;
        userInfo = null;
        debugPrint('[UserVM] 加载失败，code=${res['code']}');
      }
    } catch (e) {
      debugPrint('[UserVM] 请求异常: $e');
      isLoggedIn = false;
      userInfo = null;
    }

    isLoading = false;
    notifyListeners();
  }

  /// 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    isLoggedIn = false;
    userInfo = null;
    notifyListeners();
  }

  Future<bool> updateUserInfo({
    required String realName,
    required String email,
    required String phone,
    required String gender,
  }) async {
    try {
      final res = await UserService.updateUserInfo({
        "realName": realName,
        "email": email,
        "phone": phone,
        "gender": gender,
      });

      if (res['code'] == 200) {
        userInfo = res['data'];
        notifyListeners();
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// 时间问候
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '早上好';
    if (hour >= 12 && hour < 18) return '下午好';
    return '晚上好 ';
  }

  /// 如果要手动刷新问候语（比如跨时间段）
  void refreshGreeting() {
    greeting = _getGreeting();
    notifyListeners();
  }
}
