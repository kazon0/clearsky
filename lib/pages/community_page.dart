import 'dart:io';
import 'package:flutter/material.dart';
import '../viewmodels/community_view_model.dart';
import 'add_post_page.dart';

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
      backgroundColor: const Color.fromARGB(255, 243, 241, 237),
      appBar: AppBar(
        title: const Text('社区',
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFFFCF7),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.errorMessage != null) return Center(child: Text(vm.errorMessage!));
          return RefreshIndicator(
            onRefresh: vm.fetchPosts,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: vm.posts.length,
              itemBuilder: (context, index) {
                final post = vm.posts[index];
                return _buildPostCard(post);
              },
            ),
          );
        },
      ),

      // 右下角发帖按钮
    floatingActionButton: Padding(
    padding: const EdgeInsets.only(bottom: 10, right: 20),
    child: FloatingActionButton(
      onPressed: () async {
        final newPost = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPostPage()),
        );
        if (newPost != null) {
          setState(() {
            vm.posts.insert(0, newPost);
          });
        }
      },
      backgroundColor: const Color(0xFF6F99BF),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final date = DateTime.parse(post['createdAt']);
    final formattedTime =
        '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Card(
      color: Colors.grey.shade50,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.15),
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
                  backgroundImage: NetworkImage(post['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['author'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(formattedTime,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(post['content'] ?? '',
                style: const TextStyle(fontSize: 15, height: 1.4)),

            // 图片（自动识别本地或网络）
            if (post['images'] != null && post['images'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPostImage(post['images'][0]),
                ),
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
                        post['isLiked']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post['isLiked'] ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          post['isLiked'] = !post['isLiked'];
                          post['likes'] += post['isLiked'] ? 1 : -1;
                        });
                      },
                    ),
                    Text('${post['likes']}'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text('${post['commentsCount']}'),
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

  /// 自动判断图片来源（本地 or 网络）
  Widget _buildPostImage(String path) {
    final isLocal = path.startsWith('/') || path.startsWith('file://');

    return isLocal
        ? Image.file(
            File(path),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          )
        : Image.network(
            path,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          );
  }
}
