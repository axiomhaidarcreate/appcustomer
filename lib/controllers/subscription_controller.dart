import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class SubscriptionController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var isSubscribing = false.obs;
  var packages = [].obs;
  var loyaltyOffers = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
    fetchLoyaltyOffers();
  }

  Future<void> fetchPackages() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getSubscriptions();
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        packages.value = response.data['data']['packages'];
      }
    } on DioException catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء جلب الباقات');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLoyaltyOffers() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getLoyaltyOffers();
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        loyaltyOffers.value = response.data['data']['offers'];
      }
    } on DioException catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> subscribe(int packageId) async {
    isSubscribing.value = true;
    try {
      final response = await _apiService.subscribe(packageId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('نجاح', response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        Get.snackbar('تنبيه', e.response?.data['message'] ?? 'فشل تقديم طلب الاشتراك');
      } else {
        Get.snackbar('خطأ', 'حدث خطأ أثناء طلب الاشتراك');
      }
      print(e);
    } finally {
      isSubscribing.value = false;
    }
  }

  Future<void> subscribeToLoyaltyOffer(int offerId) async {
    isSubscribing.value = true;
    try {
      final response = await _apiService.subscribeToLoyaltyOffer(offerId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('نجاح', response.data['message'], backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } on DioException catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الاشتراك بعرض الولاء');
      print(e);
    } finally {
      isSubscribing.value = false;
    }
  }
}
