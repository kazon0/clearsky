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
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("测评报告"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.4,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(testTitle, score, level, completedAt),
            const SizedBox(height: 20),
            _textCard("总体报告", report),
            const SizedBox(height: 20),
            _suggestionCard(suggestions),
            const SizedBox(height: 20),
            _detailsCard(detailedResults),
            const SizedBox(height: 40),
            _backButton(context),
          ],
        ),
      ),
    );
  }

  /// 顶部卡片
  Widget _headerCard(
    String title,
    dynamic score,
    String level,
    String completedAt,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 圆形徽章
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFF80A7FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "$score",
              style: const TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? "测评结果" : title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "等级：$level",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5086FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedAt,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 通用文本卡片
  Widget _textCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  /// 建议
  Widget _suggestionCard(List<String> suggestions) {
    if (suggestions.isEmpty) {
      return _textCard("建议", "暂无建议");
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("建议"),
          const SizedBox(height: 12),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF6CA6FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 维度分析
  Widget _detailsCard(Map<String, dynamic> details) {
    if (details.isEmpty) return _textCard("维度分析", "暂无详细分析");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("维度分析"),
          const SizedBox(height: 12),
          ...details.entries.map(
            (e) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${e.key}：${e.value}",
                  style: const TextStyle(fontSize: 15),
                ),
                const Divider(height: 14, color: Colors.black12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 返回列表按钮
  Widget _backButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TestListPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8CFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
        ),
        child: const Text("返回测评列表", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  /// 小标题
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    );
  }

  /// 卡片样式
  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
