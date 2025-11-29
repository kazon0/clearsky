import 'package:flutter/material.dart';

class TestReportPage extends StatelessWidget {
  const TestReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "测评报告",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "暂无测评报告",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "做完测评后可在这里查看结果~",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
