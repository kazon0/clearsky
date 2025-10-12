import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? message;

  /// 登录逻辑
  Future<bool> login(String studentId, String password) async {
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final res = await AuthService.login(studentId, password);

      final code = res['code'];
      if (code == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', res['data']['token']);
        await prefs.setString('name', res['data']['name']);

        message = '登录成功';
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        message = res['message'] ?? '登录失败';
      }
    } catch (e) {
      message = '请求出错：$e';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
