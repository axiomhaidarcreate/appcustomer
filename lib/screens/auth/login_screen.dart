import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(
                Icons.local_cafe,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'مرحباً بك في شاش',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'سجل دخولك لمتابعة طلباتك ونقاطك',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
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
              const SizedBox(height: 40),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () async {
                        final phone = phoneController.text.trim();
                        final password = passwordController.text.trim();
                        if (phone.isEmpty || password.isEmpty) {
                          Get.snackbar('تنبيه', 'الرجاء إدخال جميع الحقول');
                          return;
                        }
                        final success = await authController.login(phone, password);
                        if (success) {
                          Get.offAllNamed('/main');
                        }
                      },
                child: authController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تسجيل الدخول'),
              )),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.toNamed('/register');
                },
                child: const Text('ليس لديك حساب؟ إنشاء حساب جديد', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
