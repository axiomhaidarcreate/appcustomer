import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var customer = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getProfile();
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        customer.value = response.data['data']['customer'];
      }
    } on DioException catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء جلب البيانات الشخصية');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
