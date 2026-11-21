import 'package:get/get.dart';
import 'dart:async';
import '../services/api_service.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var notifications = [].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
    fetchNotifications();
    startPolling();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startPolling() {
    // Poll every 30 seconds for unread count
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchUnreadCount();
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.getUnreadNotificationCount();
      if (response.statusCode == 200 && response.data['success']) {
        unreadCount.value = response.data['unread_count'] ?? 0;
      }
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getNotifications();

      if (response.statusCode == 200 && response.data['success']) {
        notifications.value = response.data['notifications'];
        // Backend marks them as read, so reset local count
        unreadCount.value = 0;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
