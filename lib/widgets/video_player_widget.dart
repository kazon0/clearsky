import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() => initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: initialized ? _controller.value.aspectRatio : 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: initialized
                ? VideoPlayer(_controller)
                : _buildLoadingPlaceholder(),
          ),
        ),

        const SizedBox(height: 12),

        _buildPlayButton(),
      ],
    );
  }

  /// 黑色背景 + 中间转圈
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF6F99BF)), // 蓝白色风格
        ),
      ),
    );
  }

  /// 美化版按钮
  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6F99BF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Text(_controller.value.isPlaying ? "暂停视频" : "播放视频"),
      ),
    );
  }
}
