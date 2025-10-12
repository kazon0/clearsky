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
    isLoading = true;
    greeting = _getGreeting();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final logged = prefs.getBool('isLoggedIn') ?? false;

    if (!logged) {
      isLoggedIn = false;
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final res = await UserService.getUserInfo();
      if (res['code'] == 200) {
        isLoggedIn = true;
        userInfo = res['data'];
        print('User info from API: ${res['data']}');
      } else {
        isLoggedIn = false;
        userInfo = null;
      }
    } catch (e) {
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
