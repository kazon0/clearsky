import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'report_page.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  /// 题库：每个维度 1 题（可以后面扩展）
  final List<Question> questions = [
    Question(
      text: '我经常感到紧张或不安。',
      options: ['从不', '有时', '经常', '总是'],
      scores: [1, 2, 3, 4],
      category: '紧张',
    ),
    Question(
      text: '我容易感到疲惫或精力不足。',
      options: ['从不', '有时', '经常', '总是'],
      scores: [1, 2, 3, 4],
      category: '疲倦',
    ),
    Question(
      text: '我常常担心一些小事。',
      options: ['从不', '有时', '经常', '总是'],
      scores: [1, 2, 3, 4],
      category: '担忧',
    ),
    Question(
      text: '我晚上容易失眠或睡得不安稳。',
      options: ['从不', '有时', '经常', '总是'],
      scores: [1, 2, 3, 4],
      category: '睡眠',
    ),
    Question(
      text: '我经常出现心慌、出汗或呼吸急促等身体反应。',
      options: ['从不', '有时', '经常', '总是'],
      scores: [1, 2, 3, 4],
      category: '身体反应',
    ),
  ];

  int currentIndex = 0;
  final Map<int, int> answers = {};

  void _selectAnswer(int score) {
    setState(() {
      answers[currentIndex] = score;

      // 如果是最后一题 → 计算结果并跳转
      if (currentIndex == questions.length - 1) {
        _submit();
      } else {
        currentIndex++;
      }
    });
  }

  void _submit() {
    final totalScore = answers.values.fold(0, (sum, v) => sum + v);

    /// 统计每个维度分数（按题目 category）
    final Map<String, int> subScores = {};
    for (int i = 0; i < questions.length; i++) {
      final cat = questions[i].category;
      final score = answers[i] ?? 0;
      subScores.update(cat, (old) => old + score, ifAbsent: () => score);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReportPage(totalScore: totalScore, subScores: subScores),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('焦虑自评量表'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F1FF), Color(0xFFF8FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    color: Color(0xFF6F99BF),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 40),

                // 题目卡片
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                          '第 ${currentIndex + 1} 题',
                          style: TextStyle(
                            color: Color(0xFF6F99BF),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          q.text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 选项按钮组
                        ...List.generate(
                          q.options.length,
                          (i) {
                            final selected =
                                answers[currentIndex] == q.scores[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Color(0xFF6F99BF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? Color(0xFF6F99BF)
                                        : Colors.grey.shade300,
                                    width: 1.2,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: Color(0xFF6F99BF)
                                                .withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : [],
                                ),
                                child: ListTile(
                                  title: Text(
                                    q.options[i],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  onTap: () =>
                                      _selectAnswer(q.scores[i]),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  '${currentIndex + 1} / ${questions.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
