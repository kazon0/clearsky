import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';
import 'dart:math';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // {text: '', isUser: bool}
  final ScrollController _scrollController = ScrollController();

  final List<String> fakeReplies = [
    '我在呢，慢慢说。',
    '听起来你最近有点累，要不要试着休息一下？',
    '嗯，我能理解这种感受。',
    '或许可以先深呼吸一下，我们再聊聊。',
    '你已经在努力了，这点很不容易。',
    '没关系，我会一直在这里听你说。',
  ];

  @override
  void initState() {
    super.initState();
    // 页面加载时 AI 打招呼
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _messages.add({'text': '你好呀，我是晴空AI 🌤️ 可以跟我聊聊你的心情吗？', 'isUser': false});
      });
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _controller.clear();
    });

    // 模拟 AI 回复（延迟 1.5 秒）
    Future.delayed(const Duration(seconds: 1), () {
      final randomReply = fakeReplies[Random().nextInt(fakeReplies.length)];
      setState(() {
        _messages.add({'text': randomReply, 'isUser': false});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7), 
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFCF7),
        title: const Text('AI 心理陪伴')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(text: msg['text'], isUser: msg['isUser']);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '输入你的想法...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Color(0xFF6F99BF)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
