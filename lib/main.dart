import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/main_tab_page.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/user_view_model.dart';
import 'viewmodels/ai_chat_view_model.dart';
import 'viewmodels/community_view_model.dart';
import 'viewmodels/counselor_view_model.dart';

void main() {
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
      ],
      child: MaterialApp(
        title: '晴空心理',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.grey.shade100,
          fontFamily: 'PingFang SC',
        ),
        home: const MainTabPage(),
      ),
    );
  }
}
