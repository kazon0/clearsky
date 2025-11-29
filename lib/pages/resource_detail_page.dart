import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resource_view_model.dart';

import '../widgets/video_player_widget.dart';
import '../widgets/audio_player_widget.dart';

class ResourceDetailPage extends StatefulWidget {
  final int id;
  const ResourceDetailPage({super.key, required this.id});

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ResourceViewModel>().loadDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResourceViewModel>();
    final d = vm.currentDetail;

    if (vm.isLoading || d == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFCF7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final vmRead = context.read<ResourceViewModel>();
    final cover = vmRead.getRandomCover(d['id']);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      body: SizedBox.expand(
        child: Stack(
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: Image.asset(cover, fit: BoxFit.cover),
            ),

            Positioned(
              top: 230,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
                  child: _buildContent(d),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: ClipOval(
                child: Material(
                  color: Colors.white.withOpacity(0.9),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_back, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          d['title'],
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(
          "${d['categoryName']} · ${d['author']}",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),

        const SizedBox(height: 20),

        _buildResourceContent(d),

        const SizedBox(height: 25),

        if ((d['description'] ?? "").isNotEmpty)
          Text(
            d['description'],
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),

        const SizedBox(height: 25),

        if ((d['relatedResources'] ?? []).isNotEmpty)
          _buildRelated(d['relatedResources']),
      ],
    );
  }

  Widget _buildResourceContent(Map d) {
    final type = d['resourceType'];
    final url = d['fileUrl'];

    switch (type) {
      case "ARTICLE":
        return Text(
          d['content'] ?? "",
          style: const TextStyle(fontSize: 16, height: 1.6),
        );

      case "VIDEO":
        return VideoPlayerWidget(url: url);

      case "MUSIC":
        return AudioPlayerWidget(url: url);

      default:
        return const Text("未知资源类型");
    }
  }

  Widget _buildRelated(List list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "相关推荐",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...list.map(
          (e) => Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(e['title']),
          ),
        ),
      ],
    );
  }
}
