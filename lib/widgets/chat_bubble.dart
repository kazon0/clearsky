import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser
        ? const Color(0xFFEAF2F3)
        : const Color(0xFFFFF6E5);

    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- AI头像 ---
          if (!isUser)
            CircleAvatar(
              radius: 22,
              backgroundImage: const AssetImage('assets/images/icon.png'), // AI头像
              backgroundColor: Colors.white,
            ),

          if (!isUser) const SizedBox(width: 12),

          // --- 聊天气泡 ---
          Flexible(
            child:ConstrainedBox(constraints: const BoxConstraints(
              maxWidth: 250,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6, 
                          offset: const Offset(2, 2), 
                  )
                ]
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
            ),
            )
          ),

          if (isUser) const SizedBox(width: 12),

          // --- 用户头像 ---
          if (isUser)
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/musicbg.jpg'),
              backgroundColor: Color(0xFFEAF2F3),
            ),
        ],
      ),
    );
  }
}
