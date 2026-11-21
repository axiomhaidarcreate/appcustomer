import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class OrderController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var orders = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getOrders();
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        orders.value = response.data['data']['orders'];
      }
    } on DioException catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء جلب الطلبات');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createOrder(List<Map<String, dynamic>> items, {int? tableId, String? ticketBarcode}) async {
    try {
      final response = await _apiService.createOrder(items, tableId: tableId, ticketBarcode: ticketBarcode);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('نجاح', 'تم إرسال طلبك بنجاح', backgroundColor: Get.theme.primaryColor.withOpacity(0.8), colorText: Get.theme.colorScheme.onPrimary);
        fetchOrders();
        return true;
      }
    } on DioException catch (e) {
      String msg = 'حدث خطأ أثناء إرسال الطلب';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        msg = e.response?.data['message'];
      }
      Get.snackbar('خطأ', msg, backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8), colorText: Get.theme.colorScheme.onError);
    }
    return false;
  }

  Future<Map<String, dynamic>?> checkTicket(String barcode) async {
    try {
      final response = await _apiService.checkTicket(barcode);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'];
      }
    } on DioException catch (e) {
      String msg = 'التذكرة غير صالحة';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        msg = e.response?.data['message'];
      }
      Get.snackbar('تنبيه', msg, backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8), colorText: Get.theme.colorScheme.onError);
    }
    return null;
  }
}
