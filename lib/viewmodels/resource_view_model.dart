import 'package:flutter/material.dart';
import '../services/resource_service.dart';

class ResourceViewModel extends ChangeNotifier {
  bool isLoading = false;

  String searchKeyword = '';
  String selectedType = ''; // => 对应后端 type: ARTICLE / VIDEO / MUSIC
  int? selectedCategoryId;

  List<Map<String, dynamic>> resources = [];
  int currentPage = 1;
  int totalPages = 1;

  /// 获取资源列表
  Future<void> fetchResources({int page = 1}) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await ResourceService.getResources(
        page: page,
        type: selectedType.isEmpty ? null : selectedType,
        keyword: searchKeyword.isEmpty ? null : searchKeyword,
      );

      resources = List<Map<String, dynamic>>.from(data['list'] ?? []);
    } catch (e) {
      debugPrint('资源加载失败: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// 切换类型
  void updateType(String type) {
    selectedType = type;
    fetchResources();
  }

  /// 切换分类
  void updateCategory(int? id) {
    selectedCategoryId = id;
    fetchResources(page: 1);
  }

  /// 更新搜索关键字
  void updateKeyword(String keyword) {
    searchKeyword = keyword;
    fetchResources(page: 1);
  }

  /// 点赞
  Future<void> toggleLike(int index) async {
    final item = resources[index];
    final oldStatus = item['isLiked'] ?? false;

    try {
      await ResourceService.likeResource(item['id'], !oldStatus);
      resources[index]['isLiked'] = !oldStatus;
      notifyListeners();
    } catch (e) {
      debugPrint('操作失败: $e');
    }
  }

  /// 类型中文名
  String typeLabel(String type) {
    switch (type) {
      case 'ARTICLE':
        return '文章';
      case 'VIDEO':
        return '视频';
      case 'MUSIC':
        return '音乐';
      default:
        return '其他';
    }
  }
}
