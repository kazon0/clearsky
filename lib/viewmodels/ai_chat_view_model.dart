import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';

class AiChatViewModel extends ChangeNotifier {
  bool isLoading = false;
  int? conversationId;
  List<Map<String, dynamic>> messages = [];

  /// 初始化：创建新会话
  Future<void> initConversation({String title = '情绪困扰咨询'}) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await AiService.createConversation(title);
      if (res['code'] == 200) {
        conversationId = res['data']['conversationId'];
        messages.add({'text': '你好呀～我是晴空AI 🌟 可以和我聊聊你的心情吗？', 'isUser': false});
      } else {
        messages.add({'text': '初始化失败：${res['message']}', 'isUser': false});
      }
    } catch (e) {
      messages.add({'text': '连接异常：$e', 'isUser': false});
    }

    isLoading = false;
    notifyListeners();
  }

  /// 发送消息
  Future<void> sendMessage(String content) async {
    if (conversationId == null || content.trim().isEmpty) return;

    // 添加用户消息
    messages.add({'text': content, 'isUser': true});
    notifyListeners();

    try {
      final res = await AiService.sendMessage(conversationId!, content);
      if (res['code'] == 200) {
        final aiReply = res['data']['content'];
        messages.add({'text': aiReply, 'isUser': false});
      } else {
        messages.add({'text': 'AI回复失败：${res['message']}', 'isUser': false});
      }
    } catch (e) {
      messages.add({'text': '网络异常：$e', 'isUser': false});
    }

    notifyListeners();
  }

  /// 获取历史消息（可选）
  Future<void> loadConversationDetail(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await AiService.getConversationDetail(id);
      if (res['code'] == 200) {
        conversationId = res['data']['id'];
        final list = res['data']['messages'] as List<dynamic>;
        messages = list
            .map(
              (m) => {
                'text': m['content'],
                'isUser': m['senderType'] == 'USER',
              },
            )
            .toList();
      }
    } catch (e) {
      messages.add({'text': '加载历史消息失败：$e', 'isUser': false});
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    messages.clear();
    conversationId = null;
    notifyListeners();
  }
}
