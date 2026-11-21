import 'package:get/get.dart';
import '../services/api_service.dart';

class MessageController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var messages = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getMessages();

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        messages.value = response.data['data']['messages'];
      }
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
