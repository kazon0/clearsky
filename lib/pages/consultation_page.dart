import 'package:flutter/material.dart';
import '../viewmodels/counselor_view_model.dart';

class CounselorPage extends StatefulWidget {
  const CounselorPage({super.key});

  @override
  State<CounselorPage> createState() => _CounselorPageState();
}

class _CounselorPageState extends State<CounselorPage> {
  final vm = CounselorViewModel();

  final specialties = ['全部', 'CBT', '抑郁', '焦虑', '家庭治疗', '青少年', '创伤'];

  @override
  void initState() {
    super.initState();
    vm.fetchCounselors();
  }

  @override
  Widget build(BuildContext context) {
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
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
            color: Colors.grey.shade50,
            itemBuilder: (context) {
              return specialties
                  .map(
                    (s) => PopupMenuItem<String>(
                      value: s,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s,
                            style: TextStyle(
                              fontWeight:
                                  (vm.selectedSpecialty == s ||
                                      (s == '全部' &&
                                          vm.selectedSpecialty.isEmpty))
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                                  (vm.selectedSpecialty == s ||
                                      (s == '全部' &&
                                          vm.selectedSpecialty.isEmpty))
                                  ? const Color(0xFF3A6ED4)
                                  : Colors.black87,
                            ),
                          ),
                          if (vm.selectedSpecialty == s ||
                              (s == '全部' && vm.selectedSpecialty.isEmpty))
                            const Icon(
                              Icons.check,
                              color: Color(0xFF3A6ED4),
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 筛选逻辑
          final filteredCounselors = vm.selectedSpecialty.isEmpty
              ? vm.counselors
              : vm.counselors
                    .where(
                      (c) => (c['specialties'] as List).contains(
                        vm.selectedSpecialty,
                      ),
                    )
                    .toList();

          if (filteredCounselors.isEmpty) {
            return Center(
              child: Text(
                '暂无与 "${vm.selectedSpecialty}" 相关的咨询师',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            itemCount: filteredCounselors.length,
            itemBuilder: (context, index) {
              final c = filteredCounselors[index];
              return Card(
                color: Colors.grey.shade50,
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.15),
                margin: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          (c['gender'] == 'female')
                              ? 'assets/images/woman.jpg'
                              : 'assets/images/man.jpg',
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 姓名 + 星级
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['name'] ?? '未知',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      c['title'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
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
                                      '${c['rating'] ?? '--'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // 标签
                            Wrap(
                              spacing: 5,
                              runSpacing: 3,
                              children:
                                  (c['specialties'] as List<dynamic>?)
                                      ?.map(
                                        (s) => Chip(
                                          label: Text(
                                            s.toString(),
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          backgroundColor: Colors.blue.shade50,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                        ),
                                      )
                                      .toList() ??
                                  [],
                            ),
                            const SizedBox(height: 8),
                            // 时间 + 预约按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '最近可约：${c['nextSoonestSlot'].toString().substring(11, 16)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                FilledButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('已预约 ${c['name']}'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF6F99BF),
                                    minimumSize: const Size(60, 30),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    '预约',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
