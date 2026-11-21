import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('الإعدادات',
            style: TextStyle(
                color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // -- APPEARANCE SECTION --
              _buildSectionHeader('المظهر'),
              const SizedBox(height: 8),
              _buildSettingCard(context: context,
                icon: Icons.dark_mode,
                iconColor: const Color(0xFF7C4DFF),
                title: 'الوضع الداكن',
                subtitle: controller.isDarkMode.value
                    ? 'مفعّل - الوضع الداكن'
                    : 'معطّل - الوضع الفاتح',
                trailing: Switch(
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleDarkMode,
                  activeColor: const Color(0xFFD4AF37),
                  activeTrackColor:
                      const Color(0xFFD4AF37).withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 10),
              _buildSettingCard(context: context,
                icon: Icons.text_fields,
                iconColor: const Color(0xFF00BCD4),
                title: 'حجم الخط',
                subtitle: _fontSizeLabel(controller.fontSize.value),
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: controller.fontSize.value,
                    min: 0.8,
                    max: 1.4,
                    divisions: 3,
                    activeColor: const Color(0xFFD4AF37),
                    inactiveColor: Colors.grey.withValues(alpha: 0.3),
                    onChanged: controller.setFontSize,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // -- NOTIFICATIONS SECTION --
              _buildSectionHeader('الإشعارات'),
              const SizedBox(height: 8),
              _buildSettingCard(context: context,
                icon: Icons.volume_up,
                iconColor: const Color(0xFF4CAF50),
                title: 'صوت الإشعارات',
                subtitle: controller.notificationSound.value
                    ? 'مفعّل - سيتم تشغيل صوت عند وصول إشعار'
                    : 'معطّل - بدون صوت',
                trailing: Switch(
                  value: controller.notificationSound.value,
                  onChanged: controller.toggleNotificationSound,
                  activeColor: const Color(0xFFD4AF37),
                  activeTrackColor:
                      const Color(0xFFD4AF37).withValues(alpha: 0.4),
                ),
              ),

              const SizedBox(height: 24),

              // -- LANGUAGE SECTION --
              _buildSectionHeader('اللغة'),
              const SizedBox(height: 8),
              _buildSettingCard(context: context,
                icon: Icons.language,
                iconColor: const Color(0xFFFF9800),
                title: 'لغة التطبيق',
                subtitle: controller.language.value == 'ar'
                    ? 'العربية'
                    : 'English',
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                  ),
                  child: DropdownButton<String>(
                    value: controller.language.value,
                    dropdownColor: const Color(0xFF2B2B2B),
                    underline: const SizedBox(),
                    isDense: true,
                    style: const TextStyle(
                        color: Color(0xFFD4AF37), fontSize: 14),
                    items: const [
                      DropdownMenuItem(
                          value: 'ar', child: Text('العربية')),
                      DropdownMenuItem(
                          value: 'en', child: Text('English')),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.setLanguage(val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // -- ABOUT SECTION --
              _buildSectionHeader('حول التطبيق'),
              const SizedBox(height: 8),
              _buildSettingCard(context: context,
                icon: Icons.info_outline,
                iconColor: const Color(0xFF2196F3),
                title: 'الإصدار',
                subtitle: 'الإصدار 1.0.0',
                trailing: const SizedBox(),
              ),
              const SizedBox(height: 10),
              _buildSettingCard(context: context,
                icon: Icons.support_agent,
                iconColor: const Color(0xFFE91E63),
                title: 'الدعم الفني',
                subtitle: 'تواصل معنا للمساعدة',
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16),
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('الدعم الفني', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('تواصل معنا عبر القنوات التالية:', textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.phone, color: Colors.green),
                            title: const Text('رقم الهاتف'),
                            subtitle: const Text('+966 50 000 0000', textDirection: TextDirection.ltr),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.email, color: Colors.blue),
                            title: const Text('البريد الإلكتروني'),
                            subtitle: const Text('support@shash.com'),
                            onTap: () {},
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('إغلاق', style: TextStyle(color: Color(0xFFD4AF37))),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSettingCard(context: context,
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF009688),
                title: 'سياسة الخصوصية',
                subtitle: 'اطلع على سياسة الخصوصية',
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16),
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('سياسة الخصوصية', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      content: const SingleChildScrollView(
                        child: Text(
                          'نحن في تطبيق شاش نولي اهتماماً كبيراً لخصوصية مستخدمينا. جميع بياناتك محمية ومشفرة وفق أعلى معايير الأمان. لا نقوم بمشاركة بياناتك الشخصية مع أي طرف ثالث دون موافقتك الصريحة.\n\nلمزيد من التفاصيل، يرجى زيارة موقعنا الإلكتروني.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(height: 1.5),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('موافق', style: TextStyle(color: Color(0xFFD4AF37))),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // -- LOGOUT BUTTON --
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade700,
                      Colors.red.shade900,
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text('تسجيل الخروج',
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.displayLarge?.color,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          content: Text(
                              'هل أنت متأكد من تسجيل الخروج؟',
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                              textAlign: TextAlign.center),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('إلغاء',
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                try {
                                  final authController =
                                      Get.find<AuthController>();
                                  authController.logout();
                                } catch (_) {
                                  Get.offAllNamed('/login');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                              child: const Text('تسجيل خروج',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 10),
                          Text('تسجيل الخروج',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          )),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  String _fontSizeLabel(double size) {
    if (size <= 0.85) return 'صغير';
    if (size <= 1.05) return 'متوسط';
    if (size <= 1.25) return 'كبير';
    return 'كبير جداً';
  }
}
