import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../services/api_config.dart';

class AiChatViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isAiTyping = false;
  bool isHumanConsult = false; // 是否当前会话已被人工接管
  String currentTitle = 'AI 心理陪伴';

  int? conversationId;
  List<Map<String, dynamic>> messages = [];
  List<dynamic> conversations = [];

  /// 初始化：加载上次对话或创建新会话
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

      await loadConversationList();
      notifyListeners();
    } else {
      //messages.add({'text': '初始化失败：${res['message']}', 'isUser': false});
      notifyListeners();
    }
  }

  /// 加载单个会话详情
  Future<void> loadConversationDetail(int id) async {
    isLoading = true;
    isHumanConsult = false;
    notifyListeners();

    try {
      final res = await AiService.getConversationDetail(id);
      if (res['code'] == 200) {
        conversationId = res['data']['id'];
        currentTitle = res['data']['title'] ?? 'AI 心理陪伴';

        final esc = res['data']['escalatedTo'];

        if (esc != null && esc != 0) {
          isHumanConsult = true;
        } else {
          isHumanConsult = false;
        }

        final list = res['data']['messages'] as List<dynamic>;
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

  /// 发送消息（自动区分 AI / 人工）
  Future<void> sendMessage(String content) async {
    if (conversationId == null || content.trim().isEmpty) return;

    messages.add({'text': content, 'isUser': true});
    notifyListeners();

    isAiTyping = true;
    notifyListeners();

    try {
      Map<String, dynamic> res;

      if (isHumanConsult) {
        // 人工咨询模式
        res = await AiService.sendHumanMessage(conversationId!, content);
      } else {
        // AI 模式
        res = await AiService.sendMessage(conversationId!, content);
      }

      if (res['code'] == 200) {
        final reply = res['data']['content'];
        final risk = res['data']['riskLevel']; // 后端会返回的风险等级

        messages.add({'text': reply, 'isUser': false});

        // 自动切换为人工模式
        if (risk == "HIGH" || risk == "CRITICAL") {
          isHumanConsult = true;

          // 给用户一个提示消息
          messages.add({'text': '⚠ 当前对话已升级，由人工咨询师继续为您服务。', 'isUser': false});
        }
      } else {
        messages.add({'text': '消息发送失败：${res['message']}', 'isUser': false});
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

      final data = json.decode(res.body);

      if (data['code'] == 200) {
        final obj = data['data'];
        List<dynamic> list = [];

        if (obj is List) {
          list = obj;
        } else if (obj is Map<String, dynamic>) {
          if (obj['records'] is List) {
            list = obj['records'];
          } else if (obj.values.any((v) => v is List)) {
            list = (obj.values.firstWhere((v) => v is List) as List);
          }
        }

        conversations = list;
      } else {
        conversations = [];
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
    notifyListeners();
  }
}
