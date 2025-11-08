import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/community_service.dart';

class CommunityViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> comments = [];
  bool isLoading = false;
  String? errorMessage;

  /// 获取帖子列表
  Future<void> fetchPosts({int page = 1, int size = 10}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      posts = await CommunityService.getPosts(page: page, size: size);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 获取帖子详情（用于详情页）
  Future<Map<String, dynamic>?> fetchPostDetail(int postId) async {
    try {
      return await CommunityService.getPostDetail(postId);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// 发布帖子
  Future<void> createPost({
    required String title,
    required String content,
    bool isAnonymous = false,
  }) async {
    try {
      final newPost = await CommunityService.createPost(
        title: title,
        content: content,
        isAnonymous: isAnonymous,
      );
      posts.insert(0, newPost); // 插入列表头部（假设审核通过即可显示）
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 点赞 / 取消点赞
  Future<void> toggleLike(int postId, bool isCurrentlyLiked) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) throw Exception('未登录，无法点赞');

    try {
      await CommunityService.likePost(
        postId: postId,
        token: token,
        isLike: !isCurrentlyLiked,
      );

      // 本地更新 UI
      final idx = posts.indexWhere((p) => p['id'] == postId);
      if (idx != -1) {
        posts[idx]['isLiked'] = !isCurrentlyLiked;
        posts[idx]['likeCount'] += isCurrentlyLiked ? -1 : 1;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 删除帖子
  Future<void> deletePost(int postId) async {
    try {
      await CommunityService.deletePost(postId);
      posts.removeWhere((p) => p['id'] == postId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 获取评论列表
  Future<void> fetchComments(int postId, {int page = 1, int size = 10}) async {
    isLoading = true;
    notifyListeners();

    try {
      comments = await CommunityService.getComments(
        postId,
        page: page,
        size: size,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 发表评论
  Future<void> addComment({
    required int postId,
    required String content,
    int? parentId,
    bool isAnonymous = false,
  }) async {
    try {
      await CommunityService.addComment(
        postId: postId,
        content: content,
        parentId: parentId,
        isAnonymous: isAnonymous,
      );
      await fetchComments(postId); // 重新加载评论
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 删除评论
  Future<void> deleteComment(int commentId) async {
    try {
      await CommunityService.deleteComment(commentId);
      comments.removeWhere((c) => c['id'] == commentId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
