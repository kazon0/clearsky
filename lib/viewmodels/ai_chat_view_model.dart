import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../services/api_config.dart';

class AiChatViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isAiTyping = false;

  bool isHumanConsult = false; // 已被接管
  bool isWaiting = false; // 高风险等待管理员接管
  bool isCompleted = false; // 对话已结束

  String currentTitle = 'AI 心理陪伴';

  int? conversationId;
  List<Map<String, dynamic>> messages = [];
  List<dynamic> conversations = [];

  /// 初始化：加载上次对话或创建新对话
  Future<void> initChat() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getInt('lastConversationId');

    if (lastId != null) {
      await loadConversationDetail(lastId);
    } else {
      await createConversation('新的对话');
    }

    await loadConversationList();
    isLoading = false;
    notifyListeners();
  }

  /// 创建新会话
  Future<void> createConversation(String title) async {
    final res = await AiService.createConversation(title);

    if (res['code'] == 200) {
      conversationId = res['data']['conversationId'];
      currentTitle = title;

      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('lastConversationId', conversationId!);

      messages.clear();
      isHumanConsult = false;
      isWaiting = false;
      isCompleted = false;

      await loadConversationList();
      notifyListeners();
    } else {
      messages.add({'text': '初始化失败：${res['message']}', 'isUser': false});
      notifyListeners();
    }
  }

  /// 加载会话详情
  Future<void> loadConversationDetail(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await AiService.getConversationDetail(id);

      if (res['code'] == 200) {
        final data = res['data'];

        conversationId = data['id'];
        currentTitle = data['title'] ?? 'AI 心理陪伴';

        // 根据状态判断
        final status = data['status'];

        isHumanConsult = status == 'ESCALATED';
        isCompleted = status == 'COMPLETED';

        // 高风险但还没接管 = 等待接管
        final risk = data['riskLevel'];
        if (!isHumanConsult && !isCompleted && risk == "CRITICAL") {
          isWaiting = true;
        } else {
          isWaiting = false;
        }

        // 加载历史消息
        final list = data['messages'] as List<dynamic>;
        messages = list
            .map(
              (m) => {
                'text': m['content'],
                'isUser': m['senderType'] == 'USER',
              },
            )
            .toList();

        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('lastConversationId', id);
      }
    } catch (e) {
      messages.add({'text': '加载历史消息失败：$e', 'isUser': false});
    }

    isLoading = false;
    notifyListeners();
  }

  /// 发送消息（区分 AI / 人工 / 等待接管 / 已结束）
  Future<void> sendMessage(String content) async {
    if (conversationId == null || content.trim().isEmpty) return;

    /// 已结束 —— 禁止发送
    if (isCompleted) {
      messages.add({'text': '该会话已结束，无法继续发送消息。', 'isUser': false});
      notifyListeners();
      return;
    }

    /// 等待接管 —— 不能发送消息
    if (isWaiting && !isHumanConsult) {
      messages.add({'text': '⚠ 系统检测到高风险内容，正在等待管理员接管，请稍等片刻…', 'isUser': false});
      notifyListeners();
      return;
    }

    messages.add({'text': content, 'isUser': true});
    notifyListeners();

    isAiTyping = true;
    notifyListeners();

    try {
      Map<String, dynamic> res;

      /// 已接管 → 发到人工接口
      if (isHumanConsult) {
        res = await AiService.sendHumanMessage(conversationId!, content);
      } else {
        /// 正常 → 发 AI 消息
        res = await AiService.sendMessage(conversationId!, content);
      }

      /// 后端没返回 data（可能是空字符串） → 人工处理中
      if (res['data'] == null) {
        isWaiting = true;
        messages.add({'text': '管理员正在处理您的对话，请耐心等待…', 'isUser': false});
        return;
      }

      final reply = res['data']['content'] ?? '';
      messages.add({'text': reply, 'isUser': false});

      /// 风险高 → 等待接管
      final risk = res['data']['riskLevel'];
      final status = res['data']['status'];

      if (!isHumanConsult && risk == "CRITICAL") {
        isWaiting = true;
        messages.add({'text': '⚠ 已检测到高风险内容，正在等待管理员接管…', 'isUser': false});
      }

      /// 状态改变为 ESCALATED → 切人工
      if (status == "ESCALATED") {
        isWaiting = false;
        isHumanConsult = true;
        messages.add({'text': '⚠ 当前对话已由人工咨询师接管，将继续为您服务。', 'isUser': false});
      }

      /// 状态改变为 COMPLETED → 结束
      if (status == "COMPLETED") {
        isCompleted = true;
        messages.add({'text': '本次咨询已结束，感谢您的信任。', 'isUser': false});
      }
    } catch (e) {
      messages.add({'text': '网络异常：$e', 'isUser': false});
    } finally {
      isAiTyping = false;
      notifyListeners();
    }
  }

  /// 加载会话列表
  Future<void> loadConversationList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final url = Uri.parse('$baseUrl/ai/conversations');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.body.isEmpty) {
        conversations = [];
        notifyListeners();
        return;
      }

      final data = json.decode(res.body);

      if (data['code'] == 200) {
        conversations = data['data']['list'] ?? [];
      } else {
        conversations = [];
      }
    } catch (_) {
      conversations = [];
    }

    notifyListeners();
  }

  Future<void> switchConversation(int id) async {
    await loadConversationDetail(id);
  }

  void clear() {
    messages.clear();
    conversationId = null;
    notifyListeners();
  }
}
