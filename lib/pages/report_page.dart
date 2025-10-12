import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatelessWidget {
  final int totalScore;
  final Map<String, int> subScores;

  const ReportPage({
    super.key,
    required this.totalScore,
    required this.subScores,
  });

  String getLevel() {
    if (totalScore <= 8) return '无明显焦虑';
    if (totalScore <= 12) return '轻度焦虑';
    if (totalScore <= 16) return '中度焦虑';
    return '重度焦虑';
  }

  String getAdvice() {
    switch (getLevel()) {
      case '无明显焦虑':
        return '你的情绪总体平稳，继续保持良好的作息与生活节奏。';
      case '轻度焦虑':
        return '你可能在学习或人际中感到一定压力，建议多进行放松与运动。';
      case '中度焦虑':
        return '焦虑对生活已有一定影响，建议及时与心理咨询师沟通。';
      default:
        return '焦虑程度较高，建议进行专业心理辅导或进一步评估。';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = subScores.keys.toList();
    final values = subScores.values.map((v) => v.toDouble()).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        title: const Text('测评结果'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFCF7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // 雷达图区域 —— 提前放到最上面
            SizedBox(
              height: 320,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  gridBorderData:
                      BorderSide(color: Colors.blue.shade100, width: 1),
                  borderData: FlBorderData(show: false),
                  tickBorderData:
                      BorderSide(color: Colors.grey.shade300, width: 0.8),
                  radarBorderData:
                      BorderSide(color: Color(0xFF6F99BF), width: 2),
                  tickCount: 4,
                  ticksTextStyle:
                      const TextStyle(color: Colors.transparent),
                  titleTextStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  titlePositionPercentageOffset: 0.15,
                  getTitle: (index, angle) => RadarChartTitle(
                    text: categories[index],
                    angle: angle,
                  ),
                  radarTouchData: RadarTouchData(enabled: false),
                  dataSets: [
                    RadarDataSet(
                      entryRadius: 2.5,
                      dataEntries:
                          values.map((v) => RadarEntry(value: v)).toList(),
                      fillColor: Color(0xFF6F99BF).withValues(alpha: 0.25),
                      borderColor: Color(0xFF6F99BF),
                      borderWidth: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 分数与等级卡片
            Card(
              color: Colors.grey.shade50,
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                    Text(
                      '总得分：$totalScore',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 120),
                    Text(
                      getLevel(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F99BF),
                      ),
                    ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Text(
                      getAdvice(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 各维度得分标签
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: categories.map((key) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Color(0xFF6F99BF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$key：${subScores[key]}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
            Text(
              '测评结果仅供参考，如持续存在明显不适，请寻求专业心理咨询师帮助。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
