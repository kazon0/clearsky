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
          automaticallyImplyLeading: true,
          titleSpacing: 16,
          centerTitle: false,
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
              icon: const Icon(Icons.menu_rounded, color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFFFEFBF2),
              onSelected: (value) => vm.updateCategory(value),
              itemBuilder: (context) => vm.categories.map((cat) {
                return PopupMenuItem<String>(
                  value: cat['key'],
                  child: Row(
                    children: [
                      Icon(
                        cat['key'] == 'article'
                            ? Icons.description_outlined
                            : cat['key'] == 'video'
                            ? Icons.play_circle_outline
                            : cat['key'] == 'course'
                            ? Icons.school_outlined
                            : Icons.all_inclusive,
                        size: 18,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      Text(cat['label']!),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
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
                      hintText: '搜索资源、课程或视频',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          vm.updateKeyword('');
                          vm.fetchResources();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // 分类显示（仅提示当前选中）
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '当前分类：${vm.categoryLabel(vm.selectedCategory)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 资源列表
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.resources.isEmpty
                      ? const Center(child: Text('暂无资源'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: vm.resources.length,
                          itemBuilder: (context, index) {
                            final item = vm.resources[index];
                            return Card(
                              color: Colors.grey.shade50,
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(
                                bottom: 25,
                                left: 4,
                                right: 4,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // TODO: 跳转详情
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item['cover'],
                                          width: 120,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                          top: 8,
                                          bottom: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
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
                                            Text(
                                              item['summary'] ?? '',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  vm.categoryLabel(
                                                    item['category'],
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors
                                                        .blueGrey
                                                        .shade400,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      vm.toggleFavorite(index),
                                                  icon: Icon(
                                                    item['isFavorite'] ?? false
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color:
                                                        item['isFavorite'] ??
                                                            false
                                                        ? Colors.amber
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
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
