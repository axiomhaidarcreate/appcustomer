import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'controllers/data_controller.dart';
import 'controllers/settings_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/main_screen.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Setup background message handler (might throw on unsupported platforms like Web without SW)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Request notification permissions
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    print('Firebase initialization warning: $e');
  }
  
  // Initialize settings before app starts so theme is ready
  final settingsController = Get.put(SettingsController());
  await settingsController.loadSettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find<SettingsController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'Shash App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaler: TextScaler.linear(settings.fontSize.value),
            ),
            child: child!,
          );
        },
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const SplashScreen()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/register', page: () => const RegisterScreen()),
          GetPage(
            name: '/main', 
            page: () => const MainScreen(),
            binding: BindingsBuilder(() {
              Get.put(DataController());
            }),
          ),
        ],
        unknownRoute: GetPage(name: '/notfound', page: () => const SplashScreen()),
      );
    });
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_cafe,
              size: 100,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(height: 20),
            Text(
              'شـــاش',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'تطبيق العملاء',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
