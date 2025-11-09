import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/counselor_view_model.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CounselorViewModel>().fetchMyAppointments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CounselorViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('我的预约'), centerTitle: true),
      body: vm.isLoading && vm.myAppointments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : vm.myAppointments.isEmpty
          ? const Center(child: Text('暂时还没有预约记录'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: vm.myAppointments.length,
              itemBuilder: (context, index) {
                final a = vm.myAppointments[index];
                final status = a['status'] ?? '';
                final canCancel = status == 'PENDING' || status == 'CONFIRMED';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(a['consultantName'] ?? '未知咨询师'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${a['appointmentDate'] ?? ''} '
                          '${a['startTime'] ?? ''} - ${a['endTime'] ?? ''}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '状态：$status',
                          style: TextStyle(
                            fontSize: 12,
                            color: status == 'CONFIRMED'
                                ? Colors.green
                                : status == 'CANCELLED'
                                ? Colors.grey
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    trailing: canCancel
                        ? TextButton(
                            onPressed: () => _cancel(context, a['id']),
                            child: const Text(
                              '取消',
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }

  Future<void> _cancel(BuildContext context, int appointmentId) async {
    final vm = context.read<CounselorViewModel>();
    String reason = '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('取消预约'),
        content: TextField(
          maxLines: 3,
          onChanged: (v) => reason = v,
          decoration: const InputDecoration(
            hintText: '简单写一下取消原因（可选）',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('返回'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认取消', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final success = await vm.cancelAppointment(
      appointmentId: appointmentId,
      reason: reason.isEmpty ? '未说明原因' : reason,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? '已取消预约' : '取消失败：${vm.errorMessage}')),
    );
  }
}
