import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_bubble.dart';
import '../viewmodels/ai_chat_view_model.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始化会话
    Future.microtask(() {
      Provider.of<AiChatViewModel>(context, listen: false).initConversation();
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final vm = Provider.of<AiChatViewModel>(context, listen: false);
    vm.sendMessage(text);
    _controller.clear();

    // 自动滚到底部
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AiChatViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        title: const Text('AI 心理陪伴'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.messages.length,
                    itemBuilder: (context, index) {
                      final msg = vm.messages[index];
                      return ChatBubble(
                        text: msg['text'],
                        isUser: msg['isUser'],
                      );
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Color(0xFF6F99BF)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
