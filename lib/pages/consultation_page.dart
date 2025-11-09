import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/counselor_view_model.dart';
import 'consultant_detail_page.dart';
import 'my_appointments_page.dart';

class CounselorPage extends StatefulWidget {
  const CounselorPage({super.key});

  @override
  State<CounselorPage> createState() => _CounselorPageState();
}

class _CounselorPageState extends State<CounselorPage> {
  final specialties = ['全部', '焦虑症', '抑郁症', '家庭', '青少年', '创伤'];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CounselorViewModel>().fetchCounselors(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CounselorViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F1),
      appBar: AppBar(
        titleSpacing: 30,
        title: const Text(
          '心理咨询师预约',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFFFFCF7),
        elevation: 0.5,
        actions: [
          // 我的预约入口
          IconButton(
            icon: const Icon(Icons.event_note, color: Colors.black),
            tooltip: '我的预约',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyAppointmentsPage()),
              );
            },
          ),
          // 筛选菜单
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (s) {
              if (s == '全部') {
                vm.updateSpecialty('');
              } else {
                vm.updateSpecialty(s);
              }
            },
            itemBuilder: (context) {
              return specialties
                  .map(
                    (s) => PopupMenuItem<String>(
                      value: s,
                      child: Text(
                        s,
                        style: TextStyle(
                          fontWeight:
                              (vm.selectedSpecialty == s ||
                                  (s == '全部' && vm.selectedSpecialty.isEmpty))
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color:
                              (vm.selectedSpecialty == s ||
                                  (s == '全部' && vm.selectedSpecialty.isEmpty))
                              ? const Color(0xFF3A6ED4)
                              : Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (vm.isLoading && vm.counselors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.counselors.isEmpty) {
            return Center(
              child: Text(
                '暂时没有可展示的咨询师',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          final list = vm.selectedSpecialty.isEmpty
              ? vm.counselors
              : vm.counselors.where((c) {
                  final spec = (c['specialization'] ?? '') as String;
                  return spec.contains(vm.selectedSpecialty);
                }).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final c = list[index];

              final name = c['realName'] ?? '未命名咨询师';
              final spec = (c['specialization'] ?? '').toString();
              final rating = c['rating'] ?? 0.0;
              final reviewCount = c['reviewCount'] ?? 0;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ConsultantDetailPage(consultantId: c['id']),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey.shade50,
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 头像（本地默认）
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/images/man.jpg',
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 文本部分
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 名字 + 评分
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        spec.isEmpty ? '擅长方向：未填写' : '擅长：$spec',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 18,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        ' ($reviewCount)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c['introduction'] ?? '暂无简介',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '点击查看可预约时间',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
