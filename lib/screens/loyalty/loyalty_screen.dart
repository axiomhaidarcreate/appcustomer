import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controllers/loyalty_controller.dart';
import '../../theme/app_colors.dart';

class LoyaltyScreen extends StatelessWidget {
  LoyaltyScreen({super.key});

  final LoyaltyController controller = Get.put(LoyaltyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLoyaltyDetails,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPointsCard(),
                const SizedBox(height: 24),
                
                if (controller.rewardTiers.isNotEmpty) ...[
                  const Text('مستويات المكافآت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  _buildRewardsList(),
                  const SizedBox(height: 24),
                ],

                const Text('سجل النقاط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                _buildTransactionsList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const FaIcon(FontAwesomeIcons.crown, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          const Text('رصيد النقاط الحالي', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '${controller.balance.value}',
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (controller.nextReward.value != null) ...[
            Text(
              'المكافأة القادمة: ${controller.nextReward.value!['reward_description']}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _buildProgressBar(),
            const SizedBox(height: 8),
            Text(
              'باقي ${controller.nextReward.value!['required_points'] - controller.balance.value} نقطة',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ] else if (controller.rewardTiers.isNotEmpty) ...[
            const Text(
              'أنت في أعلى مستوى! 🎉',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            )
          ] else ...[
            const Text(
              'لا توجد مكافآت محددة حالياً',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    int target = controller.nextReward.value!['required_points'];
    int current = controller.balance.value;
    double progress = (current / target).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.white.withOpacity(0.2),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 8,
      ),
    );
  }

  Widget _buildRewardsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.rewardTiers.length,
      itemBuilder: (context, index) {
        var tier = controller.rewardTiers[index];
        bool isAchieved = controller.balance.value >= tier['required_points'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAchieved ? AppColors.primary.withOpacity(0.1) : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAchieved ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAchieved ? AppColors.primary : Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAchieved ? Icons.check : Icons.lock,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier['reward_description'] ?? '',
                      style: TextStyle(
                        color: isAchieved ? AppColors.primary : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المطلوب: ${tier['required_points']} نقطة',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    if (controller.transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text('لا يوجد سجل نقاط حالياً', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        var tx = controller.transactions[index];
        bool isEarned = (tx['points'] ?? 0) > 0;
        
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEarned ? Colors.green : Colors.red).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.add : Icons.remove,
              color: isEarned ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            tx['description'] ?? (isEarned ? 'اكتساب نقاط' : 'استخدام نقاط'),
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            tx['created_at'] != null ? tx['created_at'].toString().substring(0, 10) : '',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: Text(
            '${isEarned ? '+' : ''}${tx['points']}',
            style: TextStyle(
              color: isEarned ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
