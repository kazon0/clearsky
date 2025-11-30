import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clearsky/viewmodels/assessment_view_model.dart';
import 'assessment_page.dart';
import 'test_report_page.dart';

class TestListPage extends StatefulWidget {
  const TestListPage({super.key});

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  String keyword = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AssessmentViewModel>().fetchTests(keyword: keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssessmentViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '心理测评',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.black87),
            tooltip: '我的测评报告',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TestReportPage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => keyword = v,
              onSubmitted: (_) => vm.fetchTests(keyword: keyword),
              decoration: InputDecoration(
                hintText: '搜索测评，如“焦虑”、“抑郁”',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.testList.isEmpty
                ? const Center(child: Text('暂无可用测评'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: vm.testList.length,
                    itemBuilder: (_, idx) {
                      final t = vm.testList[idx];

                      final title = t['title'] ?? '未命名测试';
                      final desc = t['description'] ?? '暂无简介';
                      final rawId = t['id'] ?? t['testId'] ?? idx;

                      final int testId = rawId is int
                          ? rawId
                          : int.tryParse(rawId.toString()) ?? idx;

                      return _testCard(
                        context,
                        testId: testId,
                        title: title,
                        desc: desc,
                        cover: vm.getRandomCover(testId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _testCard(
    BuildContext context, {
    required int testId,
    required String title,
    required String desc,
    required String cover,
  }) {
    return Card(
      color: Colors.grey.shade50,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 22),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AssessmentPage(testId: testId)),
          );
        },
        child: Row(
          children: [
            // 左侧封面图
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  cover,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 右侧标题 + 简介
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 0, bottom: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // 描述
                    Text(
                      desc,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
