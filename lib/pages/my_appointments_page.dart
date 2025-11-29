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
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        title: const Text(
          '我的预约',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: vm.isLoading && vm.myAppointments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : vm.myAppointments.isEmpty
          ? const Center(
              child: Text(
                '暂时还没有预约记录',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.myAppointments.length,
              itemBuilder: (context, index) {
                final a = vm.myAppointments[index];
                final status = a['status'] ?? '';
                final canCancel = status == 'PENDING' || status == 'CONFIRMED';

                Color statusColor;
                switch (status) {
                  case 'CONFIRMED':
                    statusColor = Colors.green;
                    break;
                  case 'CANCELLED':
                    statusColor = Colors.grey;
                    break;
                  default:
                    statusColor = Colors.orange;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 咨询师姓名 + 取消按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            a['consultantName'] ?? '未知咨询师',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (canCancel)
                            GestureDetector(
                              onTap: () => _cancel(context, a['id']),
                              child: const Text(
                                "取消",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 时间
                      Text(
                        "${a['appointmentDate'] ?? ''}  "
                        "${a['startTime'] ?? ''} - ${a['endTime'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 状态
                      Text(
                        "状态：$status",
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '取消预约',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextField(
                maxLines: 3,
                onChanged: (v) => reason = v,
                decoration: InputDecoration(
                  hintText: '简单写一下取消原因（可选）',
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      "返回",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("确认取消"),
                  ),
                ],
              ),
            ],
          ),
        ),
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
