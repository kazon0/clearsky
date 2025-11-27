import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/counselor_view_model.dart';

class ConsultantDetailPage extends StatefulWidget {
  final int consultantId;
  const ConsultantDetailPage({super.key, required this.consultantId});

  @override
  State<ConsultantDetailPage> createState() => _ConsultantDetailPageState();
}

class _ConsultantDetailPageState extends State<ConsultantDetailPage> {
  DateTime selectedDay = DateTime.now();

  List<DateTime> get next7days =>
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  void initState() {
    super.initState();
    final vm = context.read<CounselorViewModel>();

    Future.microtask(() async {
      await vm.loadConsultantDetail(widget.consultantId);

      // 默认加载今天
      final start = _format(selectedDay);
      await vm.fetchSchedules(
        widget.consultantId,
        startDate: start,
        endDate: start,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CounselorViewModel>();
    final c = vm.selectedCounselor;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        title: const Text('咨询师详情'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: vm.isLoading && c == null
          ? const Center(child: CircularProgressIndicator())
          : c == null
          ? const Center(child: Text('加载失败'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部信息
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                'assets/images/man.jpg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c['realName'] ?? '未命名咨询师',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      c['qualification'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(
                                          255,
                                          119,
                                          116,
                                          116,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          c['rating'].toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 13),
                                Row(
                                  children: [
                                    Text(
                                      '经验: ${c['experienceYears'] ?? '--'}年',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Text(
                                      '擅长领域: ${c['specialization'] ?? '未填写'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 简介
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Text(
                          c['introduction'] ?? '暂无简介',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 日期选择横向列表
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: next7days.length,
                    itemBuilder: (_, index) {
                      final day = next7days[index];
                      final isSelected = _isSame(day, selectedDay);

                      final week = _weekdayText(day.weekday);
                      final dateStr =
                          "${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

                      return GestureDetector(
                        onTap: () async {
                          setState(() => selectedDay = day);
                          await vm.fetchSchedules(
                            widget.consultantId,
                            startDate: _format(day),
                            endDate: _format(day),
                          );
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF608DFE)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF608DFE)
                                  : Colors.grey.shade300,
                              width: 1.2,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: const Color(
                                    0xFF608DFE,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      week,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 4,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4EA3FF),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "约",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 排班列表（当日）
                Expanded(
                  child: vm.schedules.isEmpty
                      ? const Center(child: Text("当天没有可预约时间"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.schedules.length,
                          itemBuilder: (_, index) {
                            final s = vm.schedules[index];
                            final start = s['startTime'];
                            final end = s['endTime'];
                            final available = s['isAvailable'] == true;

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(
                                  "$start - $end",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: available
                                    ? TextButton(
                                        onPressed: () => _onTapSchedule(
                                          context,
                                          s,
                                          widget.consultantId,
                                        ),
                                        child: const Text(
                                          '预约',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF608DFE),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _weekdayText(int w) {
    switch (w) {
      case 1:
        return "周一";
      case 2:
        return "周二";
      case 3:
        return "周三";
      case 4:
        return "周四";
      case 5:
        return "周五";
      case 6:
        return "周六";
      case 7:
        return "周日";
      default:
        return "";
    }
  }

  bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _format(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _onTapSchedule(
    BuildContext context,
    Map<String, dynamic> s,
    int consultantId,
  ) async {
    final vm = context.read<CounselorViewModel>();
    final date = s['date'];
    final start = s['startTime'];
    final end = s['endTime'];
    final scheduleId = s['id'];

    String notes = '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认预约'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$date  $start - $end"),
            const SizedBox(height: 8),
            const Text("备注（可选）：", style: TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            TextField(
              maxLines: 2,
              onChanged: (v) => notes = v,
              decoration: const InputDecoration(
                hintText: '简单说说想咨询的问题',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("确认预约"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final success = await vm.createAppointment(
      consultantId: consultantId,
      scheduleId: scheduleId,
      date: date,
      startTime: start,
      endTime: end,
      notes: notes,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "预约成功，等待确认" : "预约失败：${vm.errorMessage}"),
      ),
    );
  }
}
