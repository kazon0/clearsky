import 'dart:async';
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
  bool isWaiting = false; // 正在等待接管
  bool isCompleted = false; // 对话已结束

  Timer? statusTimer; // 定时器（每秒检查一次是否被接管）
  Timer? messageTimer;
  String currentTitle = 'AI 心理陪伴';

  int? conversationId;
  List<Map<String, dynamic>> messages = [];
  List<dynamic> conversations = [];

  /// 初始化
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
      _resetStatus();
      notifyListeners();
    }
  }

  /// 重置状态
  void _resetStatus() {
    isHumanConsult = false;
    isWaiting = false;
    isCompleted = false;
    statusTimer?.cancel();
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

        _applyStatus(data);

        // 历史消息
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
    } catch (_) {}

    isLoading = false;
    notifyListeners();
  }

  /// 应用状态
  void _applyStatus(Map<String, dynamic> data) {
    final status = data['status'];
    final risk = data['riskLevel'];

    isCompleted = status == 'COMPLETED';
    isHumanConsult = status == 'ESCALATED';

    // 触发等待状态（但允许继续与 AI 聊天）
    if (!isHumanConsult && !isCompleted && risk == 'CRITICAL') {
      isWaiting = true;
      _startWaitingMonitor(); // 开始轮询接管状态
    }

    // 已接管 → 停止轮询
    if (isHumanConsult) {
      isWaiting = false;
      statusTimer?.cancel();
      _startMessagePolling();
    }
  }

  /// 启动 1秒定时器检查是否已经被接管
  void _startWaitingMonitor() {
    statusTimer?.cancel();
    statusTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (conversationId == null) return;
      final res = await AiService.getConversationDetail(conversationId!);
      if (res['code'] == 200) {
        final status = res['data']['status'];

        // 被接管！
        if (status == 'ESCALATED') {
          isHumanConsult = true;
          isWaiting = false;
          messages.add({'text': '⚠ 咨询师已接管对话。', 'isUser': false});
          statusTimer?.cancel();
          notifyListeners();
        }

        // 已结束
        if (status == 'COMPLETED') {
          isCompleted = true;
          isWaiting = false;
          statusTimer?.cancel();
          notifyListeners();
        }
      }
    });
  }

  void _startMessagePolling() {
    messageTimer?.cancel();

    // 仅在人工接管时轮询
    if (!isHumanConsult) return;

    messageTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      if (conversationId == null) return;

      final res = await AiService.getConversationDetail(conversationId!);
      if (res['code'] == 200) {
        final list = res['data']['messages'] as List<dynamic>;
        final newMessages = list
            .map(
              (m) => {
                'text': m['content'],
                'isUser': m['senderType'] == 'USER',
              },
            )
            .toList();

        // 只有当消息数量变化才更新，防止重复刷新
        if (newMessages.length != messages.length) {
          messages = newMessages;
          notifyListeners();
        }
      }
    });
  }

  /// 发送消息
  Future<void> sendMessage(String content) async {
    if (conversationId == null || content.trim().isEmpty) return;

    // 会话已结束 → 禁止发送
    if (isCompleted) {
      messages.add({'text': '本次咨询已结束，无法继续发送消息。', 'isUser': false});
      notifyListeners();
      return;
    }

    // 加入本地消息
    messages.add({'text': content, 'isUser': true});
    notifyListeners();

    isAiTyping = true;
    notifyListeners();

    try {
      Map<String, dynamic> res;

      /// 情况 1：已经接管 → 发人工接口
      if (isHumanConsult) {
        res = await AiService.sendHumanMessage(conversationId!, content);
      } else {
        /// 情况 2：尚未接管 → 发 AI 接口（允许继续与 AI 对话）
        res = await AiService.sendMessage(conversationId!, content);
      }

      if (res['data'] == null) {
        messages.add({'text': '正在等待接管...', 'isUser': false});
        return;
      }

      final data = res['data'];
      final reply = data['content'];
      final senderType = data['senderType'];

      // 只有当不是用户发的消息时，才把它当成“对方回复”展示出来
      if (reply != null &&
          reply.toString().trim().isNotEmpty &&
          senderType != 'USER') {
        messages.add({'text': reply, 'isUser': false});
      }

      /// 更新状态
      _applyStatus(data);
    } catch (e) {
      messages.add({'text': '网络异常：$e', 'isUser': false});
    } finally {
      isAiTyping = false;
      notifyListeners();
    }
  }

  /// 会话列表
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

      if (res.body.isNotEmpty) {
        final data = json.decode(res.body);
        conversations = data['data']['list'] ?? [];
      }
    } catch (_) {
      conversations = [];
    }

    notifyListeners();
  }

  /// 切换会话
  Future<void> switchConversation(int id) async {
    await loadConversationDetail(id);
  }

  void clear() {
    messages.clear();
    conversationId = null;
    _resetStatus();
    messageTimer?.cancel();
    notifyListeners();
  }
}
