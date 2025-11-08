import 'package:flutter/material.dart';
import '../viewmodels/community_view_model.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final vm = CommunityViewModel();
  final _commentController = TextEditingController();

  Map<String, dynamic>? postDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() => isLoading = true);
    final detail = await vm.fetchPostDetail(widget.postId);
    await vm.fetchComments(widget.postId);
    setState(() {
      postDetail = detail;
      isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      await vm.addComment(postId: widget.postId, content: text);
      _commentController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('评论成功')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('评论失败：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || postDetail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final post = postDetail!;
    final author = post['isAnonymous'] == true
        ? '匿名用户'
        : (post['authorName'] ?? '未知用户');

    final date = DateTime.tryParse(post['createdAt'] ?? '');
    final formattedTime = date != null
        ? '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        title: const Text('帖子详情'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPost,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者 + 时间
              // 作者 + 时间
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/images/app_icon.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 标题
              Text(
                post['title'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              // 正文
              Text(
                post['content'] ?? '',
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),

              const SizedBox(height: 12),

              // 点赞 & 评论统计
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post['isLiked'] == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post['isLiked'] == true ? Colors.red : Colors.grey,
                    ),
                    onPressed: () async {
                      try {
                        await vm.toggleLike(
                          post['id'],
                          post['isLiked'] == true,
                        );
                        setState(() {
                          post['isLiked'] = !(post['isLiked'] ?? false);
                          post['likeCount'] += post['isLiked'] ? 1 : -1;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('点赞失败：$e')));
                      }
                    },
                  ),
                  Text('${post['likeCount'] ?? 0} 赞'),
                  const SizedBox(width: 20),
                  const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post['commentCount'] ?? 0} 评论'),
                ],
              ),

              const Divider(height: 30),

              // 评论标题
              const Text(
                '评论区',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              AnimatedBuilder(
                animation: vm,
                builder: (context, _) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('还没有评论，快来抢沙发吧~'),
                    );
                  }

                  return Column(
                    children: vm.comments.map((comment) {
                      final commenter = comment['isAnonymous'] == true
                          ? '匿名用户'
                          : (comment['authorName'] ?? '未知用户');
                      final avatar =
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(commenter)}&background=random';
                      final cTime = DateTime.tryParse(
                        comment['createdAt'] ?? '',
                      );
                      final cFormatted = cTime != null
                          ? '${cTime.month}月${cTime.day}日 ${cTime.hour.toString().padLeft(2, '0')}:${cTime.minute.toString().padLeft(2, '0')}'
                          : '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(avatar),
                        ),
                        title: Text(
                          commenter,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment['content'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cFormatted,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // 底部输入栏
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: '写下你的评论...',
                    filled: true,
                    fillColor: const Color(0xFFF2F3F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF6F99BF)),
                onPressed: _submitComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
