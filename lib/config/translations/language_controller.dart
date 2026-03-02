
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  // ✅ তোমার existing StorageService use করছি
  final _storage = StorageService();

  final List<Map<String, String>> supportedLanguages = [
    {'name': 'English',  'code': 'en', 'country': 'US', 'flag': '🇺🇸'},
    {'name': 'العربية',  'code': 'ar', 'country': 'SA', 'flag': '🇸🇦'},
    {'name': 'Español',  'code': 'es', 'country': 'ES', 'flag': '🇪🇸'},
  ];

  var currentLocale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    // ✅ StorageService এর getLanguage() use করছি
    // default 'en' return করে — তোমার code এ already আছে
    final savedLang = _storage.getLanguage(); // 'en' / 'ar' / 'es'

    final match = supportedLanguages.firstWhere(
          (l) => l['code'] == savedLang,
      orElse: () => supportedLanguages[0],
    );

    currentLocale.value = Locale(match['code']!, match['country']!);
    Get.updateLocale(currentLocale.value);
  }

  Future<void> changeLanguage(String langCode) async {
    final match = supportedLanguages.firstWhere(
          (l) => l['code'] == langCode,
      orElse: () => supportedLanguages[0],
    );

    currentLocale.value = Locale(match['code']!, match['country']!);
    Get.updateLocale(currentLocale.value);

    // ✅ StorageService এর saveLanguage() use করছি
    await _storage.saveLanguage(langCode); // 'en' / 'ar' / 'es' save হবে
  }

  bool isRTL() => currentLocale.value.languageCode == 'ar';

  String get currentFlag {
    final match = supportedLanguages.firstWhere(
          (l) => l['code'] == currentLocale.value.languageCode,
      orElse: () => supportedLanguages[0],
    );
    return '${match['flag']} ${match['name']}';
  }
}