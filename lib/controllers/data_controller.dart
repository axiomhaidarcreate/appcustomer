import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class DataController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var categories = [].obs;
  var products = [].obs;
  var events = [].obs;
  var eventTables = [].obs;
  var bookedChairs = [].obs;
  var subscriptions = [].obs;
  
  // Profile Data
  var loyaltyPoints = 0.obs;
  var userMessages = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
      fetchEvents(),
      fetchSubscriptions(),
      fetchLoyalty(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _apiService.dio.get('/categories');
      if (res.data['status'] == 'success') {
        categories.value = res.data['data']['categories'];
      }
    } catch (e) {
      print('❌ fetchCategories error: $e');
    }
  }

  Future<void> fetchProducts() async {
    try {
      final res = await _apiService.dio.get('/products');
      if (res.data['status'] == 'success') {
        products.value = res.data['data']['products'];
      }
    } catch (e) {
      print('❌ fetchProducts error: $e');
    }
  }

  Future<void> fetchEvents() async {
    try {
      final res = await _apiService.dio.get('/events');
      if (res.data['status'] == 'success') {
        events.value = res.data['data']['events'];
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> fetchSubscriptions() async {
    try {
      final res = await _apiService.dio.get('/subscriptions');
      if (res.data['status'] == 'success') {
        subscriptions.value = res.data['data']['packages'];
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchLoyalty() async {
    try {
      final res = await _apiService.dio.get('/loyalty');
      if (res.data['status'] == 'success') {
        loyaltyPoints.value = res.data['data']['balance'];
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> fetchEventTables(int eventId) async {
    try {
      isLoading.value = true;
      final res = await _apiService.dio.get('/events/$eventId/tables');
      if (res.data['status'] == 'success') {
        eventTables.value = res.data['data']['tables'];
        bookedChairs.value = res.data['data']['booked_chairs'];
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الطاولات.');
    } finally {
      isLoading.value = false;
    }
  }

  // Actions
  Future<bool> bookEvent(int eventId, String gender, int tableId, int chairId) async {
    try {
      final res = await _apiService.dio.post('/events/$eventId/book', data: {
        'gender': gender,
        'table_id': tableId,
        'chair_id': chairId,
      });
      if (res.statusCode == 200) {
        fetchEventTables(eventId);
        return true;
      }
    } on DioException catch (e) {
      print('❌ bookEvent DioException: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMsg = 'حدث خطأ أثناء الحجز.';
      if (e.response?.data != null && e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      Get.snackbar('تنبيه', errorMsg);
    } catch (e) {
      print('❌ bookEvent error: $e');
      Get.snackbar('تنبيه', 'حدث خطأ غير متوقع.');
    }
    return false;
  }
  
  Future<bool> subscribe(int packageId) async {
    try {
      final res = await _apiService.dio.post('/subscriptions/$packageId/subscribe');
      if (res.statusCode == 200) {
        Get.snackbar('نجاح', 'تم إرسال طلب الاشتراك بنجاح!');
        return true;
      }
    } catch (e) {
      Get.snackbar('تنبيه', 'لديك طلب قيد المراجعة لهذه الباقة.');
    }
    return false;
  }
}
