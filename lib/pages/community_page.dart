// import 'dart:io';
import 'package:flutter/material.dart';
import '../viewmodels/community_view_model.dart';
import 'add_post_page.dart';
import 'post_detail_page.dart'; // 详情页

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final vm = CommunityViewModel();

  @override
  void initState() {
    super.initState();
    vm.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1ED),
      appBar: AppBar(
        title: const Text(
          '心理社区',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF3F1ED),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }
          if (vm.posts.isEmpty) {
            return const Center(child: Text('还没有帖子，快去发布一个吧~'));
          }

          return RefreshIndicator(
            onRefresh: vm.fetchPosts,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: vm.posts.length,
              itemBuilder: (context, index) {
                final post = vm.posts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailPage(postId: post['id']),
                      ),
                    );
                  },
                  child: _buildPostCard(post),
                );
              },
            ),
          );
        },
      ),

      // 右下角发帖按钮
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 20),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF6F99BF),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            final newPost = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPostPage()),
            );
            if (newPost != null) {
              vm.fetchPosts(); // 刷新列表
            }
          },
        ),
      ),
    );
  }

  /// 帖子卡片
  Widget _buildPostCard(Map<String, dynamic> post) {
    final authorName = post['isAnonymous'] == true
        ? '匿名用户'
        : (post['authorName'] ?? '未知');

    final date = DateTime.tryParse(post['createdAt'] ?? '');
    final formattedTime = date != null
        ? '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '未知时间';

    return Card(
      color: Colors.grey.shade50,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：头像 + 用户名 + 时间
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: post['isAnonymous'] == true
                      ? const AssetImage('assets/images/app_icon.png')
                      : (post['authorAvatar'] != null
                            ? AssetImage(post['authorAvatar'])
                            : const AssetImage('assets/images/app_icon.png')),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // 标题 + 内容摘要
            if (post['title'] != null && post['title'].toString().isNotEmpty)
              Text(
                post['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              post['contentPreview'] ?? post['content'] ?? '',
              style: const TextStyle(fontSize: 15, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // 底部：点赞 + 评论
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post['isLiked'] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post['isLiked'] == true
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () async {
                        try {
                          await vm.toggleLike(
                            post['id'],
                            post['isLiked'] == true,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('操作失败：$e')));
                        }
                      },
                    ),
                    Text('${post['likeCount'] ?? 0}'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text('${post['commentCount'] ?? 0}'),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
