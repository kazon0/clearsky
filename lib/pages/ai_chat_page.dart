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
    Future.microtask(() {
      Provider.of<AiChatViewModel>(context, listen: false).initChat();
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final vm = Provider.of<AiChatViewModel>(context, listen: false);
    vm.sendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AiChatViewModel>(context);

    // 自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PopupMenuButton<int>(
                onSelected: vm.switchConversation,
                itemBuilder: (context) => vm.conversations.isEmpty
                    ? [
                        const PopupMenuItem<int>(
                          value: -1,
                          child: Text('暂无历史会话'),
                        ),
                      ]
                    : vm.conversations.map((c) {
                        return PopupMenuItem<int>(
                          value: c['id'],
                          child: Text(c['title'] ?? '未命名对话'),
                        );
                      }).toList(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vm.isAiTyping
                          ? '${vm.currentTitle} · 正在输入中...'
                          : vm.currentTitle,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_comment_rounded,
                color: Colors.black87,
              ),
              onPressed: () async {
                final titleController = TextEditingController();
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('新建对话'),
                    content: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: '请输入对话标题'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, titleController.text.trim()),
                        child: const Text('创建'),
                      ),
                    ],
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  await vm.createConversation(result);
                }
              },
            ),
          ],
        ),
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
