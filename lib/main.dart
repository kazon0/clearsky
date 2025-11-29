import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/main_tab_page.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/user_view_model.dart';
import 'viewmodels/ai_chat_view_model.dart';
import 'viewmodels/community_view_model.dart';
import 'viewmodels/counselor_view_model.dart';
import 'viewmodels/assessment_view_model.dart';
import 'viewmodels/resource_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClearSkyApp());
}

class ClearSkyApp extends StatelessWidget {
  const ClearSkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => AiChatViewModel()),
        ChangeNotifierProvider(create: (_) => CommunityViewModel()),
        ChangeNotifierProvider(create: (_) => CounselorViewModel()),
        ChangeNotifierProvider(create: (_) => AssessmentViewModel()),
        ChangeNotifierProvider(create: (_) => ResourceViewModel()),
      ],
      child: MaterialApp(
        title: '晴空心理',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.grey.shade100,
          fontFamily: 'PingFang SC',
        ),

        home: const AppSplashScreen(),
      ),
    );
  }
}

/// 自定义全屏启动页
class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1200), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset("assets/images/LaunchImage.png", fit: BoxFit.cover),
      ),
    );
  }
}
