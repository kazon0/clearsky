import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/user_view_model.dart';
import 'login_page.dart';
import 'regist_page.dart';

class ProfileGuestPage extends StatefulWidget {
  const ProfileGuestPage({super.key});

  @override
  State<ProfileGuestPage> createState() => _ProfileGuestPageState();
}

class _ProfileGuestPageState extends State<ProfileGuestPage>
    with SingleTickerProviderStateMixin {
  double _opacity = 0;
  double _offsetY = 40;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _opacity = 1;
        _offsetY = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      body: Stack(
        children: [
          // 背景图
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_register.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 内容淡入上移动画
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              opacity: _opacity,
              child: Transform.translate(
                offset: Offset(0, _offsetY),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // logo + 标题
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 0, 100),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: 0.85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/app_icon.png',
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/xinli_text.png',
                                height: 30,
                              ),
                              const SizedBox(height: 18),
                              Image.asset(
                                'assets/images/fangqing_text.png',
                                height: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 登录按钮
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 0, 40),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ).then((_) {
                            // 登录页关闭后刷新一次
                            debugPrint('[GuestPage] 登录页返回，准备刷新用户信息');
                            userVM.checkLoginAndLoad();
                          });
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/denglu_text.png',
                              height: 30,
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              'assets/images/denglutijiao.png',
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 注册按钮
                    Padding(
                      padding: const EdgeInsets.fromLTRB(100, 40, 0, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/zhuce_text.png',
                              height: 30,
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              'assets/images/denglutijiao.png',
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
