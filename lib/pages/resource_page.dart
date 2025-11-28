import 'package:flutter/material.dart';
import '../viewmodels/resource_view_model.dart';

class ResourcePage extends StatefulWidget {
  const ResourcePage({super.key});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  final vm = ResourceViewModel();

  @override
  void initState() {
    super.initState();
    vm.fetchResources();
  }

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFFFEFBF2),
              onSelected: vm.updateType,
              itemBuilder: (context) => [
                _typeItem("", "全部", Icons.all_inclusive),
                _typeItem("ARTICLE", "文章", Icons.description_outlined),
                _typeItem("VIDEO", "视频", Icons.play_circle_outline),
                _typeItem("MUSIC", "音乐", Icons.music_note_outlined),
              ],
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (_, __) {
          return RefreshIndicator(
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
                      suffixIcon: vm.searchKeyword.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                vm.updateKeyword('');
                                vm.fetchResources();
                              },
                            )
                          : null,
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 列表
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.resources.isEmpty
                      ? const Center(child: Text('暂无资源'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: vm.resources.length,
                          itemBuilder: (context, index) =>
                              _resourceCard(context, index),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 小工具：构建分类菜单项
  PopupMenuItem<String> _typeItem(String key, String label, IconData icon) {
    return PopupMenuItem<String>(
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

  /// 类型中文显示
  String _filterLabel(String type) {
    switch (type) {
      case 'ARTICLE':
        return "文章";
      case 'VIDEO':
        return "视频";
      case 'MUSIC':
        return "音乐";
      default:
        return "全部";
    }
  }

  /// 资源卡片组件
  Widget _resourceCard(BuildContext ctx, int index) {
    final item = vm.resources[index];

    return Card(
      color: Colors.grey.shade50,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 25, left: 4, right: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: 跳转资源详情
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 封面图
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['coverImage'] ?? '',
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image),
                  ),
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

                    // 简介
                    Text(
                      item['description'] ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 分类
                        Text(
                          item['categoryName'] ?? '未知分类',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),

                        // 点赞
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
}
