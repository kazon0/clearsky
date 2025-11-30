import 'package:flutter/foundation.dart';
import '../services/test_service.dart';

class AssessmentViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // 测试列表数据
  List<Map<String, dynamic>> testList = [];

  // 测试题目与作答数据
  List<Map<String, dynamic>> questions = [];
  Map<int, int> answers = {};
  Map<String, dynamic>? report;

  // 当前题目索引
  int currentIndex = 0;

  final List<String> coverImages = List.generate(
    9,
    (i) => "assets/images/cover${i + 1}.jpg",
  );

  /// 根据 resourceId 生成稳定随机封面
  String getRandomCover(int resourceId) {
    final index = resourceId % coverImages.length;
    return coverImages[index];
  }

  /// 获取所有可用的测试列表
  Future<void> fetchTests({String keyword = ""}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await TestService.getTests(keyword: keyword);
      testList = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 加载指定测试的题目
  Future<void> loadQuestions(int testId) async {
    isLoading = true;

    // 重置
    currentIndex = 0;
    answers.clear();

    notifyListeners();
    try {
      final data = await TestService.getQuestions(testId);

      final rawQuestions = List<Map<String, dynamic>>.from(
        data['questions'] ?? [],
      );

      questions = rawQuestions.map((q) {
        return {
          ...q,

          /// question 兼容 content
          'question': q['question'] ?? q['content'] ?? '',

          /// options 兼容 text / label, score / value
          'options': (q['options'] ?? []).map((o) {
            return {
              ...o,
              'text': o['text'] ?? o['label'] ?? '',
              'score':
                  o['score'] ??
                  int.tryParse(o['value']?.toString() ?? '0') ??
                  0,
            };
          }).toList(),
        };
      }).toList();
    } catch (e) {
      errorMessage = "加载题目失败：$e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 选择题目答案
  void selectAnswer(int index, int optionIndex) {
    answers[index] = optionIndex;
    notifyListeners();
  }

  /// 下一题
  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      notifyListeners();
    }
  }

  /// 上一题
  void previousQuestion() {
    if (currentIndex > 0) {
      currentIndex--;
      notifyListeners();
    }
  }

  /// 提交答案，生成报告
  Future<void> submit(int testId) async {
    isLoading = true;
    notifyListeners();
    try {
      final formattedAnswers = answers.entries.map((e) {
        final question = questions[e.key];
        final options = question['options'] as List<dynamic>;

        final selectedValue = options[e.value]['value'];

        return {
          'questionId': question['id'],
          'selectedOption': selectedValue.toString(),
        };
      }).toList();

      report = await TestService.submitAnswers(
        testId: testId,
        answers: formattedAnswers,
      );
      print("测评报告 result = $report");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> recordList = [];

  Future<void> fetchTestRecords({int page = 1, int size = 10}) async {
    isLoading = true;
    notifyListeners();

    try {
      recordList = await TestService.getTestRecords(page: page, size: size);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
