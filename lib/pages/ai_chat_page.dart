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
          duration: const Duration(milliseconds: 250),
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
              child: GestureDetector(
                onTap: () async {
                  final selectedId = await showConversationSelectorDialog(
                    context,
                    vm.conversations,
                  );
                  if (selectedId != null && selectedId > 0) {
                    vm.switchConversation(selectedId);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vm.isAiTyping ? '正在输入中…' : vm.currentTitle,
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
                final title = await showNewChatDialog(context);
                if (title != null && title.isNotEmpty) {
                  vm.createConversation(title);
                }
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // 顶部状态提示条（根据状态自动切换）
          if (vm.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: const Text(
                '本次咨询已结束',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else if (vm.isWaiting)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.yellow.shade50,
              child: const Text(
                '⚠ 正在等待管理员接管，请继续保持沟通…',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),
            )
          else if (vm.isHumanConsult)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade50,
              child: const Text(
                '会话已由人工咨询师接管',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),
            ),

          // 消息列表
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

          // 输入框
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: !vm.isCompleted, // 已结束不能输入
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: vm.isCompleted
                            ? '咨询已结束'
                            : vm.isHumanConsult
                            ? '向咨询师发送消息…'
                            : '输入你的想法…',
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
                    onPressed: vm.isCompleted ? null : _sendMessage,
                    icon: Icon(
                      Icons.send,
                      color: vm.isCompleted
                          ? Colors.grey
                          : const Color(0xFF6F99BF),
                    ),
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

/// 新建对话弹窗
Future<String?> showNewChatDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "新建对话",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "请输入对话标题…",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6F99BF),
                      width: 0.8,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6F99BF),
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6F99BF),
                      width: 1.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "取消",
                      style: TextStyle(color: Color(0xFF6F99BF)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F99BF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "创建",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 历史对话选择弹窗
Future<int?> showConversationSelectorDialog(
  BuildContext context,
  List<dynamic> conversations,
) {
  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 300,
          height: 380,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "选择历史对话",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final c = conversations[index];
                    final title = c['title'] ?? '未命名对话';

                    return InkWell(
                      onTap: () => Navigator.pop(context, c['id']),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color: Color(0xFF6F99BF),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF444444),
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

              const Divider(height: 1),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("关闭"),
              ),
            ],
          ),
        ),
      );
    },
  );
}
