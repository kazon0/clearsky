import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/assessment_view_model.dart';
import 'report_page.dart';

class TestReportPage extends StatefulWidget {
  const TestReportPage({super.key});

  @override
  State<TestReportPage> createState() => _TestReportPageState();
}

class _TestReportPageState extends State<TestReportPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AssessmentViewModel>().fetchTestRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssessmentViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "测评记录",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.recordList.isEmpty
          ? _emptyView()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.recordList.length,
              itemBuilder: (_, i) {
                final r = vm.recordList[i];
                return _recordCard(context, data: r);
              },
            ),
    );
  }

  /// 空状态
  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "暂无测评记录",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            "完成测评后会显示在这里~",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  /// 单个报告卡片
  Widget _recordCard(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) {
    final title = data['testTitle'] ?? '未命名测评';
    final score = data['score']?.toString() ?? '--';
    final level = data['level'] ?? '未知';
    final preview = data['reportPreview'] ?? '';
    final time = _formatDate(data['completedAt']);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportPage(result: data)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF4285F4),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              // 内容区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 得分等级
                    Text(
                      "得分：$score    等级：$level",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 报告摘要
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 时间
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return "--";

    try {
      final dt = DateTime.parse(isoString);
      final y = dt.year;
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return "$y-$m-$d $h:$min";
    } catch (_) {
      return isoString;
    }
  }
}
