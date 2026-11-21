import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageController controller = Get.put(MessageController(), tag: 'messages');

  @override
  void initState() {
    super.initState();
    controller.fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text('رسائل النظام', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF222222),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            );
          }

          if (controller.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('لا توجد رسائل حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchMessages,
            color: const Color(0xFFD4AF37),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: controller.messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                var message = controller.messages[index];
                return _buildMessageBubble(message);
              },
            ),
          );
        }),
    );
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour;
    String period = hour >= 12 ? 'م' : 'ص';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    String minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Widget _buildMessageBubble(dynamic message) {
    String msgText = message['message'] ?? '';
    String createdAt = message['created_at'] ?? '';
    
    String timeString = '';
    try {
      DateTime dt = DateTime.parse(createdAt).toLocal();
      timeString = _formatTime(dt);
    } catch (e) {
      timeString = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFD4AF37),
            radius: 16,
            child: Icon(Icons.support_agent, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF2B2B2B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msgText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      timeString,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

