// lib/pages/test_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clearsky/viewmodels/assessment_view_model.dart';
import 'assessment_page.dart';

class TestListPage extends StatefulWidget {
  const TestListPage({super.key});

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  @override
  void initState() {
    super.initState();
    // 在下一事件循环触发，避免在构建期直接调用 Provider
    Future.microtask(() {
      final vm = context.read<AssessmentViewModel>();
      vm.fetchTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 watch 可以在 vm 状态变化时触发重建
    final vm = context.watch<AssessmentViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('心理测评'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(child: Text('加载失败：${vm.errorMessage}'));
          }

          if (vm.testList.isEmpty) {
            return const Center(child: Text('暂无可用测评'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.testList.length,
            itemBuilder: (context, i) {
              final test = vm.testList[i];
              final title = test['title'] ?? '未命名测试';
              final desc = test['description'] ?? '暂无简介';
              final id = test['id'] ?? test['testId'] ?? i;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssessmentPage(
                          testId: id is int
                              ? id
                              : int.tryParse(id.toString()) ?? i,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
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
