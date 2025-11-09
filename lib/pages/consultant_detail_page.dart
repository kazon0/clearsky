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
  @override
  void initState() {
    super.initState();
    final vm = context.read<CounselorViewModel>();
    Future.microtask(() async {
      await vm.loadConsultantDetail(widget.consultantId);
      await vm.fetchSchedules(widget.consultantId);
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
        backgroundColor: const Color(0xFFFFFCF7),
        centerTitle: true,
      ),
      body: vm.isLoading && c == null
          ? const Center(child: CircularProgressIndicator())
          : c == null
          ? const Center(child: Text('加载失败'))
          : Column(
              children: [
                // 顶部信息
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/images/man.jpg',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['realName'] ?? '未命名咨询师',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c['qualification'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '擅长：${c['specialization'] ?? '未填写'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '经验：${c['experienceYears'] ?? '--'} 年',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    c['introduction'] ?? '暂无简介',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),

                // 可预约时间段
                Expanded(
                  child: vm.schedules.isEmpty
                      ? const Center(child: Text('暂时没有可预约时间'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.schedules.length,
                          itemBuilder: (context, index) {
                            final s = vm.schedules[index];
                            final date = s['date'] ?? '';
                            final start = s['startTime'] ?? '';
                            final end = s['endTime'] ?? '';
                            final available = s['isAvailable'] == true;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text('$date  $start - $end'),
                                subtitle: Text(
                                  available ? '可预约' : '已被预约',
                                  style: TextStyle(
                                    color: available
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: available
                                    ? TextButton(
                                        onPressed: () => _onTapSchedule(
                                          context,
                                          s,
                                          widget.consultantId,
                                        ),
                                        child: const Text('预约'),
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
            Text('$date  $start - $end'),
            const SizedBox(height: 8),
            const Text('备注（可选）：', style: TextStyle(fontSize: 13)),
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
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认预约'),
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
        content: Text(success ? '预约成功，等待确认' : '预约失败：${vm.errorMessage}'),
      ),
    );
  }
}
