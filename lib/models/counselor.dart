class Counselor {
  final String name;
  final String field;

  Counselor({required this.name, required this.field});

  static List<Counselor> sampleList() => [
        Counselor(name: '李老师', field: '焦虑与压力'),
        Counselor(name: '王老师', field: '人际关系'),
        Counselor(name: '陈老师', field: '青少年心理'),
      ];
}
