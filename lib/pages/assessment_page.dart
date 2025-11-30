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
      return const Scaffold(body: Center(child: Text("暂无题目")));
    }

    final currentIndex = vm.currentIndex;
    final q = vm.questions[currentIndex];

    final questionText = q['question'] ?? '';
    final options = q['options'] as List<dynamic>;
    final optionTexts = options.map((o) => o['text'].toString()).toList();
    final selected = vm.answers[currentIndex];

    final progress = (currentIndex + 1) / vm.questions.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('焦虑自评量表'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF2F3), Color(0xFFF8FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF6F99BF),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "第 ${currentIndex + 1} 题",
                          style: const TextStyle(
                            color: Color(0xFF6F99BF),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          questionText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 26),

                        ...List.generate(optionTexts.length, (i) {
                          final isSelected = selected == i;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6F99BF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6F99BF)
                                      : Colors.grey.shade300,
                                  width: 1.3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF6F99BF,
                                          ).withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),

                              child: ListTile(
                                title: Text(
                                  optionTexts[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                onTap: () {
                                  vm.selectAnswer(currentIndex, i);
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "${currentIndex + 1} / ${vm.questions.length}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (currentIndex < vm.questions.length - 1) {
                        vm.nextQuestion();
                      } else {
                        await vm.submit(widget.testId);
                        if (vm.report != null && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportPage(result: vm.report!),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F99BF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      currentIndex < vm.questions.length - 1 ? "下一题" : "提交",
                      style: const TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
