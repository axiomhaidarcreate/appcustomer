import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      isAuthenticated.value = true;
    }
  }

  /// Get FCM token for push notifications
  Future<String?> _getFcmToken() async {
    try {
      if (kIsWeb) return null; // Skip on web to prevent VAPID key errors
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<bool> login(String phone, String password) async {
    try {
      isLoading.value = true;
      String? fcmToken = await _getFcmToken();

      final response = await _apiService.dio.post('/login', data: {
        'phone': phone,
        'password': password,
        if (fcmToken != null) 'fcm_token': fcmToken,
      });

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final token = response.data['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تسجيل الدخول، تأكد من البيانات.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name, String phone, String password, String gender, {String? nationality}) async {
    try {
      isLoading.value = true;
      String? fcmToken = await _getFcmToken();

      final response = await _apiService.dio.post('/register', data: {
        'name': name,
        'phone': phone,
        'password': password,
        'gender': gender,
        if (nationality != null && nationality.isNotEmpty) 'nationality': nationality,
        if (fcmToken != null) 'fcm_token': fcmToken,
      });

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final token = response.data['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إنشاء الحساب، قد يكون الرقم مسجلاً بالفعل.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.dio.post('/logout');
    } catch (e) {
      // Ignore error if network fails during logout
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    isAuthenticated.value = false;
  }
}
