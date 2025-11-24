import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import 'profile_guest_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      userVM.checkLoginAndLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);

    return AnimatedBuilder(
      animation: userVM,
      builder: (context, _) {
        if (userVM.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userVM.isLoggedIn) {
          return const ProfileGuestPage();
        }

        final user = userVM.userInfo!;
        final avatarUrl = user['avatarUrl'];
        final validAvatar =
            avatarUrl != null &&
            avatarUrl.toString().isNotEmpty &&
            avatarUrl.toString().startsWith("http");

        return Scaffold(
          backgroundColor: const Color(0xFFFFFCF7),
          appBar: AppBar(
            titleSpacing: 30,
            title: const Text(
              '个人中心',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFFFFFCF7),
            elevation: 0,
            centerTitle: false,
          ),
          body: RefreshIndicator(
            onRefresh: userVM.checkLoginAndLoad,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==== 顶部个人卡片 ====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.blue.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          backgroundImage: validAvatar
                              ? NetworkImage(avatarUrl)
                              : const AssetImage('assets/images/icon.png'),
                        ),

                        const SizedBox(width: 16),

                        // 用户基本信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['realName']?.isNotEmpty == true
                                    ? user['realName']
                                    : '默认用户',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '学号：${user['username']}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Color(0xFF6F99BF),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    "注册时间：${_formatDate(user['createdAt'])}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==== 详细信息卡片 ====
                  Card(
                    color: Colors.grey.shade50,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.email_outlined,
                            '邮箱',
                            user['email'] ?? '未填写',
                          ),
                          _divider(),
                          _infoRow(
                            Icons.wc_outlined,
                            '性别',
                            genderMapToCN[user['gender']] ?? '未填写',
                          ),
                          _divider(),
                          _infoRow(
                            Icons.phone_android,
                            '手机号',
                            user['phone'] ?? '未填写',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==== 功能区域 ====
                  Material(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _featureItem(Icons.edit_note, '修改个人信息', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                          }),

                          _divider(),
                          _featureItem(Icons.analytics_outlined, '测试报告', () {}),
                          _divider(),
                          _featureItem(
                            Icons.psychology_alt_outlined,
                            '心理测评',
                            () {},
                          ),
                          _divider(),
                          _featureItem(Icons.favorite_border, '我的收藏', () {}),
                          _divider(),
                          _featureItem(
                            Icons.logout,
                            '退出登录',
                            userVM.logout,
                            color: Colors.red.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Text(
                    '心理健康从了解自己开始 💙',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =================
  // 工具函数
  // =================
  static String _formatDate(String? date) {
    if (date == null) return '未知';
    return date.substring(0, 10);
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6F99BF)),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$label：$value', style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: Colors.grey.shade300, height: 14, thickness: 0.5);

  Widget _featureItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: const Color.fromARGB(
          255,
          238,
          243,
          247,
        ).withOpacity(0.6),
        splashColor: const Color.fromARGB(255, 234, 239, 242).withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color ?? const Color(0xFF6F99BF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 16)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
