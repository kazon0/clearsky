import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? message;

  /// 登录逻辑
  Future<bool> login(String username, String password) async {
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final res = await AuthService.login(username, password);

      final code = res['code'];
      if (code == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', res['data']['token'] ?? '');
        await prefs.setString('name', res['data']['username'] ?? '');

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

  /// 注册逻辑
  Future<bool> register(String username, String password) async {
    isLoading = true;
    message = null;
    notifyListeners();

    try {
      final res = await AuthService.register(username, password);

      final code = res['code'];
      if (code == 200) {
        message = '注册成功，请登录';
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        message = res['message'] ?? '注册失败';
      }
    } catch (e) {
      message = '请求出错：$e';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
