import 'package:get/get.dart';

class LanguageController extends GetxController {
  // Selected language
  var selectedLanguage = 'English (US)'.obs;

  // List of suggested languages
  final List<String> suggestedLanguages = [
    'English (US)',
  ];

  // List of all languages
  final List<String> allLanguages = [
    'English',
  ];

  // Method to select language
  void selectLanguage(String language) {
    selectedLanguage.value = language;
    // Add your logic to save the selected language
    // For example: Save to SharedPreferences or update user settings
  }

  // Check if language is selected
  bool isSelected(String language) {
    return selectedLanguage.value == language;
  }
}