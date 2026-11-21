import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../events/events_screen.dart';
import '../orders/orders_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import '../profile/profile_screen.dart';
import '../loyalty/loyalty_screen.dart';
import '../notifications/notifications_screen.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screen.dart';
import '../../controllers/notification_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final NotificationController notifController = Get.put(NotificationController());

  final List<Widget> _widgetOptions = <Widget>[
    OrdersScreen(), // Orders (Home)
    const EventsScreen(), // Events
    SubscriptionsScreen(), // Subscriptions
    LoyaltyScreen(), // Loyalty points and rewards
    ProfileScreen(), // Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['tab'] != null) {
      _selectedIndex = Get.arguments['tab'];
    }
    _setupPushNotifications();
  }

  void _setupPushNotifications() async {
    // 1. Handle app opened from terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }

    // 2. Handle app opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // 3. Handle notifications while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Refresh notifications list
      notifController.fetchNotifications();
      notifController.fetchUnreadCount();

      // Show in-app snackbar
      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'إشعار جديد',
          message.notification!.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.9),
          colorText: Colors.black,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.notifications_active, color: Colors.black),
          onTap: (_) {
            _handleNotificationClick(message);
          },
        );
      }
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'event') {
      // 1 is the index for Events (الحفلات) in the bottom navigation bar
      setState(() {
        _selectedIndex = 1;
      });
    } else {
      // General notifications can be routed to the NotificationsScreen
      Get.to(() => NotificationsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شـــاش'),
        actions: [
          // Notifications
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  notifController.fetchNotifications();
                  Get.to(() => NotificationsScreen())?.then((_) {
                    notifController.fetchUnreadCount();
                  });
                },
              ),
              Obx(() {
                if (notifController.unreadCount.value > 0) {
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${notifController.unreadCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          // Messages
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.envelope, size: 20),
            onPressed: () {
              Get.to(() => const MessagesScreen());
            },
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings, size: 22),
            onPressed: () {
              Get.to(() => SettingsScreen());
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.ticket),
            label: 'الحفلات',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.crown),
            label: 'الاشتراكات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'الولاء',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'حسابي',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

