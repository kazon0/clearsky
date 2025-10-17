import 'package:flutter/material.dart';
import '../viewmodels/auth_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _pwdController = TextEditingController();
  final authVM = AuthViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: authVM,
        builder: (context, _) {
          return Stack(
            children: [
             Container(
              decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEAF2F3), Color.fromARGB(255, 252, 246, 237)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
             ),
Positioned(
  top: 0,
  left: 0,
  right: 0,
  child: SizedBox(
    height: 220,
    child: ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.transparent],
          stops: [0.55, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: 
      Opacity(opacity: 0.5,
      child: 
        Image.asset(
        'assets/images/musicbg.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
      ),
      )
    ),
  ),
),
              
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Logo + 标题 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage('assets/images/icon.png'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '晴空心理',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 86, 146, 202),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '关心你的每一次情绪波动',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

// --- 登录表单 ---
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 18),
  child: Column(
    children: [
      TextField(
        controller: _idController,
        decoration: InputDecoration(
          labelText: '学号',
          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6F99BF)),
          filled: false, // 不要填充背景色
          border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), // 改成简洁底线风格
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _pwdController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: '密码',
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6F99BF)),
          filled: false,
          border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ),
        ),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            '忘记密码？',
            style: TextStyle(
              color: Color.fromARGB(255, 123, 162, 199),
              fontSize: 13,
            ),
          ),
        ),
      ),
    ],
  ),
),


                    const SizedBox(height: 28),

                    // --- 登录按钮 ---
                    authVM.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final ok = await authVM.login(
                                  _idController.text.trim(),
                                  _pwdController.text.trim(),
                                );
                                if (ok && mounted) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 121, 166, 207),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                              child: const Text(
                                '登录',
                                style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                              ),
                            ),
                          ),

                    const SizedBox(height: 16),

                    // --- 登录提示 ---
                    if (authVM.message != null)
                      Text(
                        authVM.message!,
                        style: TextStyle(
                          color: authVM.message == '登录成功'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // --- 底部注册提示 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '还没有账号？',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '立即注册',
                            style: TextStyle(
                              color: Color.fromARGB(255, 121, 162, 200),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ],
          );
        },
      ),
    );
  }
}
