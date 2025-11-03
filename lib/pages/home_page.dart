import 'package:flutter/material.dart';
import '../viewmodels/user_view_model.dart';
import 'ai_chat_page.dart';
import 'test_page.dart';
import 'resource_page.dart';
import 'community_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userVM = UserViewModel();

  @override
  void initState() {
    super.initState();
    userVM.checkLoginAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      body: AnimatedBuilder(
        animation: userVM,
        builder: (context, _) {
          if (userVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: userVM.checkLoginAndLoad,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部蓝色背景
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/musicbg.jpg'),
                        fit: BoxFit.cover,
                        opacity: 0.25, // 调淡，不影响文字
                      ),
                      color: const Color(0x99CFE5F3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 80,
                      left: 40,
                      right: 20,
                      bottom: 30,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFFEFBF2),
                          backgroundImage: const AssetImage(
                            'assets/images/icon.png',
                          ),
                          // 本地头像
                        ),
                        const SizedBox(width: 20),
                        Text(
                          userVM.greeting,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 120),
                        Image.asset(
                          'assets/images/wanshang.png',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 横向提示卡片
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6E5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.orangeAccent,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '保持平衡的作息，能让你更容易放松。',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0, -100), // 向上移动10像素
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildSoftCard(
                            context,
                            'AI陪伴',
                            'assets/images/record.jpg',
                            const AIChatPage(),
                            isBlue: false,
                          ),
                          _buildSoftCard(
                            context,
                            '心理测评',
                            'assets/images/test.jpg',
                            const AssessmentPage(),
                            isBlue: true,
                          ),
                          _buildSoftCard(
                            context,
                            '资源推荐',
                            'assets/images/resource.jpg',
                            const ResourcePage(),
                            isBlue: true,
                          ),
                          _buildSoftCard(
                            context,
                            '社区交流',
                            'assets/images/community.jpg',
                            const CommunityPage(),
                            isBlue: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Transform.translate(
                    offset: const Offset(0, -90),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/images/musicbg.jpg'),
                            fit: BoxFit.cover,
                            opacity: 0.25, // 调淡，不影响文字
                          ),
                          color: const Color(0xFFEAF2F3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.music_note,
                              color: Color(0xFF6F99BF),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '冥想 · 平静呼吸',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF37474F),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: 0.4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6F99BF),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFF6F99BF),
                                size: 36,
                              ),
                              onPressed: () {
                                // TODO: 播放逻辑
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSoftCard(
    BuildContext context,
    String title,
    String imagePath,
    Widget page, {
    bool isBlue = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isBlue
              ? const Color(0xFFEAF2F3) // 蓝色
              : const Color(0xFFFFF6E5), // 米黄色
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 90, height: 90, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
