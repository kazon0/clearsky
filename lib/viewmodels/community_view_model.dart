import 'package:flutter/material.dart';
import '../services/community_service.dart';

class CommunityViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = false;
  String? errorMessage;

  /// 获取社区帖子列表
  Future<void> fetchPosts({int page = 1, int limit = 10}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      posts = await CommunityService.getPosts(page: page, limit: limit);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
