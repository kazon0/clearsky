import 'package:flutter/material.dart';
import '../viewmodels/user_view_model.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userVM = UserViewModel();

  @override
  void initState() {
    super.initState();
    userVM.checkLoginAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: userVM,
      builder: (context, _) {
        if (userVM.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

if (!userVM.isLoggedIn) {
  return Scaffold(
    backgroundColor: const Color(0xFFFFFCF7),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
  borderRadius: BorderRadius.circular(16), // 圆角半径
  child: Image.asset(
    'assets/images/musicbg.jpg',
    fit: BoxFit.cover, // 填充方式
  ),
),
            const SizedBox(height: 30),

            const Text(
              '你还没有登录',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F99BF),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '登录后即可查看你的个人信息与测评记录',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ).then((_) => userVM.checkLoginAndLoad());
              },
              icon: const Icon(Icons.login),
              label: const Text(
                '立即登录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 132, 171, 208),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {},
              child: Text(
                '没有账号？去注册',
                style: TextStyle(
                  color: Color(0xFF6F99BF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
        final user = userVM.userInfo!;
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
            centerTitle: false,
            elevation: 0,
            backgroundColor: const Color(0xFFFFFCF7),
          ),
          body: RefreshIndicator(
            onRefresh: userVM.checkLoginAndLoad,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 顶部个人信息卡
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade100,
                          Colors.blue.shade50,
                        ],
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
                          backgroundImage:
                              const AssetImage('assets/images/icon.png'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? '未命名',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user['major']} · ${user['grade']}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.badge_outlined,
                                      size: 16,
                                      color: Color(0xFF6F99BF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '学号 ${user['studentId']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 详细信息卡
                  Card(
                    color: Colors.grey.shade50,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      child: Column(
                        children: [
                          _infoRow(Icons.email_outlined, '邮箱', user['email']),
                          _divider(),
                          _infoRow(Icons.wc_outlined, '性别', user['gender']),
                          _divider(),
                          _infoRow(Icons.calendar_today_outlined, '入学时间',
                              user['joinDate']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 大功能卡片区域
                  Card(
                    color: Colors.grey.shade50,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Column(
                        children: [
                          _featureItem(Icons.edit_note, '修改个人信息', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('修改信息功能待实现')),
                            );
                          }),
                          _divider(),
                          _featureItem(Icons.analytics_outlined, '测试报告', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('打开测试报告页')),
                            );
                          }),
                          _divider(),
                          _featureItem(Icons.psychology_alt_outlined, '心理测评', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('进入心理测评功能')),
                            );
                          }),
                          _divider(),
                          _featureItem(Icons.favorite_border, '我的收藏', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('查看收藏内容')),
                            );
                          }),
                          _divider(),
                          _featureItem(Icons.logout, '退出登录', userVM.logout,
                              color: Colors.red.shade400),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 小提示或页脚
                  Text(
                    '心理健康从了解自己开始 💙',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF6F99BF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label：$value',
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Divider(
        color: Colors.grey.shade300,
        height: 14,
        thickness: 0.5,
      );

  Widget _featureItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? Color(0xFF6F99BF)),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
