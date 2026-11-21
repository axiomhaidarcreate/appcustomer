import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controllers/subscription_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';

class SubscriptionsScreen extends StatelessWidget {
  SubscriptionsScreen({super.key});

  final SubscriptionController controller = Get.put(SubscriptionController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final packages = controller.packages;

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchPackages();
            await profileController.fetchProfile();
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildCurrentSubscription(),
              const SizedBox(height: 24),
              const Text(
                'الباقات المتاحة للاشتراك',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (packages.isEmpty)
                const Center(child: Text('لا توجد باقات متاحة حالياً'))
              else
                ...packages.map((package) => _buildPackageCard(package)),

              const SizedBox(height: 24),
              const Text(
                'عروض الولاء المتاحة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.loyaltyOffers.isEmpty) {
                  return const Center(child: Text('لا توجد عروض ولاء متاحة حالياً'));
                }
                return Column(
                  children: controller.loyaltyOffers.map((offer) => _buildLoyaltyOfferCard(offer)).toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentSubscription() {
    return Obx(() {
      final customer = profileController.customer;
      final currentPackage = customer['subscription_package'];

      if (currentPackage == null) {
        return Card(
          elevation: 2,
          color: Colors.grey.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                FaIcon(FontAwesomeIcons.circleExclamation, size: 40, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'ليس لديك اشتراك فعّال حالياً',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        elevation: 4,
        color: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primary, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.crown, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'اشتراكك الحالي',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                currentPackage['name'] ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(currentPackage['description'] ?? '', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPackageCard(dynamic package) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package['name'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              package['description'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${package['price'] ?? 0} ريال',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'تأكيد الاشتراك',
                      middleText: 'هل أنت متأكد من رغبتك في إرسال طلب اشتراك في باقة ${package['name']}؟',
                      textConfirm: 'نعم',
                      textCancel: 'إلغاء',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                        controller.subscribe(package['id']);
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('طلب اشتراك'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyOfferCard(dynamic offer) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  offer['name'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'اكتسب ${offer['points_per_order']} نقطة لكل طلب، و ${offer['points_per_visit']} نقطة لكل زيارة.',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'تأكيد الاشتراك',
                    middleText: 'هل ترغب في تفعيل ${offer['name']} لبدء جمع النقاط؟',
                    textConfirm: 'نعم، اشترك',
                    textCancel: 'إلغاء',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back();
                      controller.subscribeToLoyaltyOffer(offer['id']);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('تفعيل العرض'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
