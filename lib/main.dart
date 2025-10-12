import 'package:flutter/material.dart';
import 'pages/main_tab_page.dart';

void main() {
  runApp(const ClearSkyApp());
}

class ClearSkyApp extends StatelessWidget {
  const ClearSkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '晴空心理',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'PingFang SC',
      ),
      home: const MainTabPage(), 
    );
  }
}
