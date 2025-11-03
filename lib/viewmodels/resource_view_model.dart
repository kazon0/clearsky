import 'package:flutter/material.dart';
import '../services/resource_service.dart';

class ResourceViewModel extends ChangeNotifier {
  bool isLoading = false;
  String searchKeyword = '';
  String selectedCategory = 'all';
  List<Map<String, dynamic>> resources = [];

  /// 分类标签
  final List<Map<String, String>> categories = const [
    {'key': 'all', 'label': '全部'},
    {'key': 'article', 'label': '文章'},
    {'key': 'video', 'label': '视频'},
    {'key': 'course', 'label': '课程'},
  ];

  /// 获取资源数据
  Future<void> fetchResources() async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await ResourceService.getResources();
      List<Map<String, dynamic>> filtered = all;

      if (selectedCategory != 'all') {
        filtered = filtered
            .where((e) => e['category'] == selectedCategory)
            .toList();
      }

      if (searchKeyword.isNotEmpty) {
        final kw = searchKeyword.toLowerCase();
        filtered = filtered.where((e) {
          return (e['title'] ?? '').toLowerCase().contains(kw) ||
              (e['summary'] ?? '').toLowerCase().contains(kw);
        }).toList();
      }

      resources = filtered;
    } catch (e) {
      debugPrint('获取资源失败: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// 更新分类
  void updateCategory(String category) {
    selectedCategory = category;
    fetchResources();
  }

  /// 更新搜索关键字
  void updateKeyword(String keyword) {
    searchKeyword = keyword;
    notifyListeners();
  }

  /// 收藏状态切换（本地模拟）
  void toggleFavorite(int index) {
    resources[index]['isFavorite'] = !(resources[index]['isFavorite'] ?? false);
    notifyListeners();
  }

  String categoryLabel(String type) {
    switch (type) {
      case 'article':
        return '文章';
      case 'video':
        return '视频';
      case 'course':
        return '课程';
      default:
        return '其他';
    }
  }
}
