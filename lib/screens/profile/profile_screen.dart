import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final customer = controller.customer;
        if (customer.isEmpty) {
          return const Center(child: Text('لا توجد بيانات متاحة'));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: const FaIcon(FontAwesomeIcons.user, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                customer['name'] ?? 'بدون اسم',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                customer['phone'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(
                icon: Icons.numbers,
                title: 'رقم الاشتراك',
                value: customer['subscription_number'] ?? 'غير متوفر',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.monetization_on,
                title: 'إجمالي النقاط',
                value: '${customer['total_points'] ?? 0} نقطة',
              ),
              const SizedBox(height: 12),
              if (customer['subscription_package'] != null)
                _buildInfoCard(
                  icon: Icons.workspace_premium,
                  title: 'الباقة الحالية',
                  value: customer['subscription_package']['name'] ?? '',
                  color: Colors.amber,
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value, Color color = AppColors.primary}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
