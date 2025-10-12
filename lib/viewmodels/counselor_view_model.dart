import 'package:flutter/material.dart';
import '../services/counselor_service.dart';

class CounselorViewModel extends ChangeNotifier {
  /// 咨询师数据列表
  List<dynamic> counselors = [];

  /// 是否正在加载中
  bool isLoading = false;

  /// 当前筛选条件
  String selectedSpecialty = '';

  /// 加载咨询师列表
  Future<void> fetchCounselors({String? specialty}) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await CounselorService.fetchCounselors(
        specialty: specialty ?? selectedSpecialty,
      );

      counselors = result;
    } catch (e) {
      debugPrint('获取咨询师列表失败: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 设置专业筛选并重新加载
  void updateSpecialty(String specialty) {
    selectedSpecialty = specialty;
    fetchCounselors();
  }
}
