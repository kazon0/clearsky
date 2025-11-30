import 'package:flutter/material.dart';
import '../services/resource_service.dart';

class ResourceViewModel extends ChangeNotifier {
  bool isLoading = false;

  String searchKeyword = '';
  String selectedType = ''; // => 对应后端 type: ARTICLE / VIDEO / MUSIC
  int? selectedCategoryId;

  List<Map<String, dynamic>> resources = [];
  Map<String, dynamic>? currentDetail;

  int currentPage = 1;
  int totalPages = 1;

  final List<String> coverImages = List.generate(
    9,
    (i) => "assets/images/cover${i + 1}.jpg",
  );

  /// 根据 resourceId 生成稳定随机封面
  String getRandomCover(int resourceId) {
    final index = resourceId % coverImages.length;
    return coverImages[index];
  }

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

    // 本地优化更新
    resources[index]['isLiked'] = !oldStatus;
    notifyListeners();

    try {
      final res = await ResourceService.likeResource(item['id'], !oldStatus);

      // 兼容后端可能返回新的状态
      if (res['data'] != null && res['data'] is Map) {
        resources[index]['isLiked'] = res['data']['isLiked'] ?? !oldStatus;

        if (res['data']['likeCount'] != null) {
          resources[index]['likeCount'] = res['data']['likeCount'];
        }
      }
    } catch (e) {
      debugPrint("点赞失败: $e");

      // 失败回滚
      resources[index]['isLiked'] = oldStatus;
    }

    notifyListeners();
  }

  Future<void> loadDetail(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      currentDetail = await ResourceService.getResourceDetail(id);
    } catch (e) {
      debugPrint("详情加载失败: $e");
    }

    isLoading = false;
    notifyListeners();
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
