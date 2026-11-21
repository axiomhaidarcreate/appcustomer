import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final List<TextEditingController> otpControllers = 
        List.generate(6, (_) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من الرقم'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            authController.resetOtpState();
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.sms,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 30),
              Text(
                'أدخل رمز التحقق',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'تم إرسال رمز التحقق المكون من 6 أرقام\nإلى رقم جوالك',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 40),
              // OTP Input Fields
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.textMuted),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            focusNodes[index - 1].requestFocus();
                          }
                          // Auto-submit when all 6 digits entered
                          if (index == 5 && value.isNotEmpty) {
                            String otp = otpControllers.map((c) => c.text).join();
                            if (otp.length == 6) {
                              _verifyOtp(authController, otp);
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 40),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () {
                        String otp = otpControllers.map((c) => c.text).join();
                        if (otp.length != 6) {
                          Get.snackbar('تنبيه', 'الرجاء إدخال رمز التحقق كاملاً');
                          return;
                        }
                        _verifyOtp(authController, otp);
                      },
                child: authController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تأكيد'),
              )),
              const SizedBox(height: 20),
              // Resend OTP button
              Obx(() {
                if (authController.otpResendSeconds.value > 0) {
                  return Text(
                    'إعادة إرسال الرمز بعد ${authController.otpResendSeconds.value} ثانية',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  );
                }
                return TextButton(
                  onPressed: () {
                    String phone = authController.pendingPhone ?? '';
                    if (phone.isNotEmpty) {
                      authController.sendOtp(phone);
                    }
                  },
                  child: const Text(
                    'إعادة إرسال الرمز',
                    style: TextStyle(color: AppColors.primary),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOtp(AuthController authController, String otp) async {
    final success = await authController.verifyOtp(otp);
    if (success) {
      Get.offAllNamed('/main');
    }
  }
}
