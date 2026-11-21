import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final RxString selectedGender = 'ذكر'.obs;
    final RxString selectedNationality = 'سعودي'.obs;
    final List<String> nationalities = [
      'سعودي', 'يمني', 'مصري', 'كويتي', 'إماراتي', 'قطري',
      'عماني', 'عراقي', 'سوري', 'أردني', 'لبناني', 'سوداني', 'مغربي', 'أخرى'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.person_add,
                size: 60,
                color: AppColors.primary,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الجوال',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => DropdownButtonFormField<String>(
                value: selectedNationality.value,
                decoration: const InputDecoration(
                  labelText: 'الجنسية',
                  prefixIcon: Icon(Icons.flag),
                ),
                items: nationalities.map((nat) {
                  return DropdownMenuItem<String>(
                    value: nat,
                    child: Text(nat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedNationality.value = val;
                },
              )),
              const SizedBox(height: 20),
              Text('الجنس:', style: Theme.of(context).textTheme.bodyLarge),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('ذكر'),
                      value: 'ذكر',
                      groupValue: selectedGender.value,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        if (value != null) selectedGender.value = value;
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('أنثى'),
                      value: 'أنثى',
                      groupValue: selectedGender.value,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        if (value != null) selectedGender.value = value;
                      },
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 40),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        final password = passwordController.text.trim();
                        final gender = selectedGender.value;
                        final nationality = selectedNationality.value;
                        
                        if (name.isEmpty || phone.isEmpty || password.isEmpty) {
                          Get.snackbar('تنبيه', 'الرجاء إدخال جميع الحقول الأساسية');
                          return;
                        }
                        
                        final success = await authController.register(
                          name,
                          phone,
                          password,
                          gender,
                          nationality: nationality,
                        );
                        if (success) {
                          Get.offAllNamed('/main');
                        }
                      },
                child: authController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تسجيل الحساب'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
