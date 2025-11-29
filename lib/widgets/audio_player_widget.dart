import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  const AudioPlayerWidget({super.key, required this.url});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer player;
  bool isPlaying = false;
  Duration progress = Duration.zero;
  Duration total = Duration.zero;

  @override
  void initState() {
    super.initState();

    player = AudioPlayer();

    player.onDurationChanged.listen((d) {
      setState(() => total = d);
    });

    player.onPositionChanged.listen((p) {
      setState(() => progress = p);
    });

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标
          const Icon(Icons.music_note, size: 50, color: Color(0xFF6F99BF)),
          const SizedBox(height: 12),

          // 进度条
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6F99BF),
              inactiveTrackColor: const Color(0xFFBFD4E5),
              thumbColor: const Color(0xFF6F99BF),
              trackHeight: 4,
            ),
            child: Slider(
              value: progress.inMilliseconds.toDouble().clamp(
                0,
                total.inMilliseconds.toDouble(),
              ),
              max: total.inMilliseconds.toDouble() == 0
                  ? 1
                  : total.inMilliseconds.toDouble(),
              onChanged: (value) {
                player.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),

          // 时间
          Text(
            "${_format(progress)} / ${_format(total)}",
            style: const TextStyle(fontSize: 12, color: Color(0xFF516A7B)),
          ),

          const SizedBox(height: 16),

          // 按钮
          SizedBox(
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
                if (isPlaying) {
                  player.pause();
                } else {
                  player.play(UrlSource(widget.url));
                }
              },
              child: Text(isPlaying ? "暂停" : "播放"),
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}
