import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorHomeController extends GetxController {
  var selectedQuickSpeak = ''.obs;
  var quickSpeakText = ''.obs;

  // Quick Speak Items
  final List<CategoryItemModel> quickSpeakItems = [
    CategoryItemModel(
      imagePath: ImagesLink.textToSpeakImg,
      label: 'Text-to-Speak',
      id: 'text_to_speak',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.hungryImg,
      label: "I'm Hungry",
      id: 'hungry',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.breakImg,
      label: 'I need a break',
      id: 'break',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.helpMeImg,
      label: 'Help me',
      id: 'help',
    ),
  ];

  // Tap to Talk Items
  final List<CategoryItemModel> tapToTalkItems = [
    CategoryItemModel(
      imagePath: ImagesLink.emotions,
      label: 'Emotions',
      id: 'emotions',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.activities,
      label: 'Activities',
      id: 'activities',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.people,
      label: 'People',
      id: 'people',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.places,
      label: 'Places',
      id: 'places',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.foodDrink,
      label: 'Food & Drink',
      id: 'food_drink',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.health,
      label: 'Health',
      id: 'health',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.greetings,
      label: 'Greetings',
      id: 'greetings',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.question,
      label: 'Question',
      id: 'question',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.action,
      label: 'Action',
      id: 'action',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.things,
      label: 'Things',
      id: 'things',
    ),
    CategoryItemModel(
      imagePath: ImagesLink.coreWords,
      label: 'Core Words',
      id: 'core_words',
    ),
  ];

  // Explore More Items
  final List<CategoryItemModel> exploreMoreItems = [
    CategoryItemModel(
      imagePath: ImagesLink.mySchedule,
      label: 'My Schedule',
      id: 'my_schedule',
    ),
  ];

  void onQuickSpeakTap(String action) {
    // Handle Text-to-Speak navigation
    if (action == 'Text-to-Speak') {
      Get.toNamed(AppRoutes.TEXT_TO_SPEAK);
      return;
    }

    // Handle other Quick Speak items
    if (selectedQuickSpeak.value == action) {
      // Deselect if already selected
      selectedQuickSpeak.value = '';
      quickSpeakText.value = '';
    } else {
      // Select and set text
      selectedQuickSpeak.value = action;
      quickSpeakText.value = action;
    }
  }

  void speakQuickSpeak() {
    if (quickSpeakText.value.isNotEmpty) {
      // TODO: Implement text-to-speech functionality
      // You can use flutter_tts package here
      Get.snackbar(
        'Speaking',
        quickSpeakText.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select a Quick Speak option first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearQuickSpeak() {
    selectedQuickSpeak.value = '';
    quickSpeakText.value = '';
  }

  void onCategoryTap(String category) {
    switch (category) {
      case 'Emotions':
        Get.toNamed(AppRoutes.EMOTIONS);
        break;
      case 'Activities':
        Get.toNamed(AppRoutes.ACTIVITIES);
        break;
      case 'People':
        Get.toNamed(AppRoutes.PEOPLE);
        break;
      case 'Places':
        Get.toNamed(AppRoutes.PLACES);
        break;
      case 'Food & Drink':
        Get.toNamed(AppRoutes.FOOD_DRINK);
        break;
      case 'Health':
        Get.toNamed(AppRoutes.HEALTH);
        break;
      case 'Greetings':
        Get.toNamed(AppRoutes.GREETINGS);
        break;
      case 'Question':
        Get.toNamed(AppRoutes.QUESTION);
        break;
      case 'Action':
        Get.toNamed(AppRoutes.ACTION);
        break;
      case 'Things':
        Get.toNamed(AppRoutes.THINGS);
        break;
      case 'Core Words':
        Get.toNamed(AppRoutes.CORE_WORDS);
        break;
      case 'My Schedule':
        Get.toNamed(AppRoutes.VISUAL_SCHEDULES);
        break;
      default:
        Get.snackbar('Category', category);
    }
  }
}

class CategoryItemModel {
  final String imagePath;
  final String label;
  final String id;

  CategoryItemModel({
    required this.imagePath,
    required this.label,
    required this.id,
  });
}