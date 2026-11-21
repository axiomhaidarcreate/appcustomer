import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
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

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                const Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          color: const Color(0xFFD4AF37),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              var notification = controller.notifications[index];
              bool isEvent = notification['type'] == 'event';
              bool isLoyalty = notification['type'] == 'loyalty';
              bool isOrder = notification['type'] == 'order';

              IconData icon = Icons.notifications;
              Color iconColor = Colors.grey;
              Color bgColor = const Color(0xFF2A2A2A);

              if (isEvent) {
                icon = Icons.event;
                iconColor = const Color(0xFFE91E63);
                bgColor = const Color(0xFFE91E63).withValues(alpha: 0.05);
              } else if (isLoyalty) {
                icon = Icons.star;
                iconColor = const Color(0xFFD4AF37);
                bgColor = const Color(0xFFD4AF37).withValues(alpha: 0.05);
              } else if (isOrder) {
                icon = Icons.restaurant;
                iconColor = Colors.greenAccent;
                bgColor = Colors.greenAccent.withValues(alpha: 0.05);
              }

              return GestureDetector(
                onTap: () {
                  if (isEvent) {
                    Get.offAllNamed('/main', arguments: {'tab': 1});
                  } else if (isOrder) {
                    Get.offAllNamed('/main', arguments: {'tab': 0});
                  } else if (isLoyalty) {
                    Get.offAllNamed('/main', arguments: {'tab': 3});
                  } else {
                    Get.back(); // just close notifications
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['title'] ?? 'إشعار',
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification['message'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(notification['created_at']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
