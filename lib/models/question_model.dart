class Question {
  final String text;
  final List<String> options;
  final List<int> scores;
  final String category;

  Question({
    required this.text,
    required this.options,
    required this.scores,
    required this.category,
  });
}
