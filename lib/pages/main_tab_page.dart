import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'consultation_page.dart';
import 'community_page.dart';
import 'home_page.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _index = 0;

  final pages = const [
    HomePage(),
    CounselorPage(),
    CommunityPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFBF2),
      body: pages[_index],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
          child: Container(
            height: 70, // 稍微再矮一点
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _index,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF6F99BF),
                unselectedItemColor: Colors.grey,
                iconSize: 22,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                onTap: (i) => setState(() => _index = i),
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4), // 稍微往下，但不会撑破
                      child: Icon(Icons.home),
                    ),
                    label: '首页',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.calendar_month_outlined),
                    ),
                    label: '咨询',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.forum_outlined),
                    ),
                    label: '社区',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.person_outline),
                    ),
                    label: '我的',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
