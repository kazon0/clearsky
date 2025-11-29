import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resource_view_model.dart';
import 'resource_detail_page.dart';

class ResourcePage extends StatelessWidget {
  const ResourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResourceViewModel()..fetchResources(),
      child: const _ResourcePageContent(),
    );
  }
}

class _ResourcePageContent extends StatefulWidget {
  const _ResourcePageContent();

  @override
  State<_ResourcePageContent> createState() => _ResourcePageContentState();
}

class _ResourcePageContentState extends State<_ResourcePageContent> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResourceViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: const Color(0xFFFFFCF7),
          titleSpacing: 16,
          automaticallyImplyLeading: true,
          title: const Text(
            '资源库',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.black87),
              onSelected: vm.updateType,
              itemBuilder: (_) => [
                _typeItem("", "全部", Icons.all_inclusive),
                _typeItem("ARTICLE", "文章", Icons.description_outlined),
                _typeItem("VIDEO", "视频", Icons.play_circle_outline),
                _typeItem("MUSIC", "音乐", Icons.music_note_outlined),
              ],
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: vm.fetchResources,
        child: Column(
          children: [
            // 搜索框
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: vm.updateKeyword,
                onSubmitted: (_) => vm.fetchResources(),
                decoration: InputDecoration(
                  hintText: '搜索资源，如“焦虑”、“冥想”',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 当前筛选标签
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '当前类型：${_filterLabel(vm.selectedType)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 列表
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.resources.isEmpty
                  ? const Center(child: Text("暂无资源"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: vm.resources.length,
                      itemBuilder: (_, index) =>
                          _resourceCard(context, vm, index),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 分类选项
PopupMenuItem<String> _typeItem(String key, String label, IconData icon) {
  return PopupMenuItem(
    value: key,
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );
}

String _filterLabel(String type) {
  switch (type) {
    case 'ARTICLE':
      return '文章';
    case 'VIDEO':
      return '视频';
    case 'MUSIC':
      return '音乐';
    default:
      return '全部';
  }
}

// 单个卡片
Widget _resourceCard(BuildContext context, ResourceViewModel vm, int index) {
  final item = vm.resources[index];

  return Card(
    color: Colors.grey.shade50,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.only(bottom: 25, left: 4, right: 4),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResourceDetailPage(id: item['id'])),
        );
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                vm.getRandomCover(item['id']),
                width: 120,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    item['title'] ?? '未命名资源',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // 描述
                  Text(
                    item['description'] ?? '',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['categoryName'] ?? '未知分类',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                      IconButton(
                        onPressed: () => vm.toggleLike(index),
                        icon: Icon(
                          (item['isLiked'] ?? false)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: (item['isLiked'] ?? false)
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
