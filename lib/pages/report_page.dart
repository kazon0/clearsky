import 'package:flutter/material.dart';
import 'test_list_page.dart';

class ReportPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const ReportPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result['score'] ?? '--';
    final level = result['level'] ?? '未知';
    final report = result['report'] ?? '暂无报告内容';
    final suggestions = List<String>.from(result['suggestions'] ?? []);
    final detailedResults = Map<String, dynamic>.from(
      result['detailedResults'] ?? {},
    );
    final completedAt =
        result['completedAt']?.toString().substring(0, 19) ?? '';
    final testTitle = result['testTitle'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("测评报告"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(score, level, testTitle, completedAt),
            const SizedBox(height: 20),
            _buildSection("总体报告", report),
            const SizedBox(height: 20),
            _buildSuggestions(suggestions),
            const SizedBox(height: 20),
            _buildDetailedResults(detailedResults),
            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestListPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("返回测评列表"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部卡片
  Widget _buildHeader(
    dynamic score,
    String level,
    String title,
    String completedAt,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            "得分：$score",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "等级：$level",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// 通用文本区域
  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  /// 建议模块
  Widget _buildSuggestions(List<String> suggestions) {
    if (suggestions.isEmpty) {
      return _buildSection("建议", "暂无建议");
    }

    return _buildSection("建议", suggestions.map((s) => "• $s").join("\n"));
  }

  /// 详细维度得分
  Widget _buildDetailedResults(Map<String, dynamic> details) {
    if (details.isEmpty) {
      return _buildSection("维度分析", "暂无详细分析");
    }

    String formatted = details.entries
        .map((e) => "${e.key}：${e.value}")
        .join("\n");

    return _buildSection("维度分析", formatted);
  }
}
