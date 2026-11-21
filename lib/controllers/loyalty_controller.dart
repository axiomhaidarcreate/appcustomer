import 'package:get/get.dart';
import '../services/api_service.dart';

class LoyaltyController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  
  var totalPoints = 0.obs;
  var usedPoints = 0.obs;
  var balance = 0.obs;
  
  var offer = {}.obs;
  var rewardTiers = [].obs;
  var nextReward = Rxn<Map<String, dynamic>>();
  var transactions = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLoyaltyDetails();
  }

  Future<void> fetchLoyaltyDetails() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getLoyaltyDetails();
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        totalPoints.value = data['total_points'] ?? 0;
        usedPoints.value = data['used_points'] ?? 0;
        balance.value = data['balance'] ?? 0;
        
        offer.value = data['offer'] ?? {};
        rewardTiers.value = data['reward_tiers'] ?? [];
        nextReward.value = data['next_reward'] != null ? Map<String, dynamic>.from(data['next_reward']) : null;
        transactions.value = data['transactions'] ?? [];
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل بيانات الولاء');
      print('Error fetching loyalty details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
