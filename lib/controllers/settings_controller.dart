import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  var isDarkMode = true.obs;
  var notificationSound = true.obs;
  var language = 'ar'.obs;
  var fontSize = 1.0.obs; // 0.8 small, 1.0 medium, 1.2 large

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? true;
    notificationSound.value = prefs.getBool('notificationSound') ?? true;
    language.value = prefs.getString('language') ?? 'ar';
    fontSize.value = prefs.getDouble('fontSize') ?? 1.0;
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    
    // Apply theme
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleNotificationSound(bool value) async {
    notificationSound.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationSound', value);
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  Future<void> setFontSize(double size) async {
    fontSize.value = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }
}
