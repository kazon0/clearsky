import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/assessment_view_model.dart';
import 'report_page.dart';

class AssessmentPage extends StatefulWidget {
  final int testId;
  const AssessmentPage({super.key, required this.testId});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AssessmentViewModel>().loadQuestions(widget.testId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssessmentViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('暂无题目')));
    }

    final currentIndex = vm.currentIndex;
    final q = vm.questions[currentIndex];

    final questionText = (q['question'] ?? q['content'] ?? '').toString();

    final options = (q['options'] as List<dynamic>);
    final optionTexts = options
        .map((o) => (o['text'] ?? o['label'] ?? '').toString())
        .toList();

    final scores = options
        .map((o) => o['score'] ?? o['value'] ?? 0)
        .map((s) => int.tryParse(s.toString()) ?? 0)
        .toList();

    final selected = vm.answers[currentIndex];

    final progress = (currentIndex + 1) / vm.questions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('心理测评')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 20),

            Text(
              "第 ${currentIndex + 1} / ${vm.questions.length} 题",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            Text(questionText, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            ...List.generate(optionTexts.length, (i) {
              final isSelected = selected == scores[i];
              return ListTile(
                title: Text(optionTexts[i]),
                tileColor: isSelected ? Colors.blue.shade100 : null,
                onTap: () {
                  vm.selectAnswer(currentIndex, scores[i]);
                },
              );
            }),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 上一题：第一题不显示按钮
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: vm.previousQuestion,
                    child: const Text("上一题"),
                  )
                else
                  const SizedBox(width: 100), // 占位
                // 下一题 OR 提交
                if (currentIndex < vm.questions.length - 1)
                  ElevatedButton(
                    onPressed: vm.nextQuestion,
                    child: const Text("下一题"),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      await vm.submit(widget.testId);

                      if (vm.report != null && context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportPage(result: vm.report!),
                          ),
                        );
                      }
                    },
                    child: const Text("提交"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
