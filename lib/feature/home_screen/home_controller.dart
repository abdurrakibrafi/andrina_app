import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedQuickSpeak = ''.obs;
  var isEditMode = false.obs;
  var selectedItems = <String>[].obs;

  // Constant for My Schedule ID
  static const String myScheduleId = 'my_schedule';

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
    CategoryItemModel(
      imagePath: ImagesLink.moreWords,
      label: 'More words',
      id: 'more_words',
    ),
  ];

  // Explore More Items
  final List<CategoryItemModel> exploreMoreItems = [
    CategoryItemModel(
      imagePath: ImagesLink.mySchedule,
      label: 'My Schedule',
      id: myScheduleId,
    ),
  ];

  // Enter Edit Mode
  void enterEditMode() {
    isEditMode.value = true;
    Get.snackbar('Edit Mode', 'Edit mode activated');
  }

  // Exit Edit Mode
  void exitEditMode() {
    isEditMode.value = false;
    selectedItems.clear();
    Get.snackbar('Edit Mode', 'Edit mode deactivated');
  }

  // Toggle Item Selection (My Schedule কে ignore করবে)
  void toggleItemSelection(String itemId) {
    // My Schedule select করতে দেবে না
    if (itemId == myScheduleId) {
      return;
    }

    if (selectedItems.contains(itemId)) {
      selectedItems.remove(itemId);
    } else {
      selectedItems.add(itemId);
    }
  }

  // Check if item is selected (My Schedule সবসময় false return করবে)
  bool isItemSelected(String itemId) {
    // My Schedule কখনো selected দেখাবে না
    if (itemId == myScheduleId) {
      return false;
    }
    return selectedItems.contains(itemId);
  }

  // Get Selected Item Details
  CategoryItemModel? getSelectedItemDetails() {
    if (selectedItems.isEmpty) return null;

    final selectedId = selectedItems.first;

    // Search in Quick Speak
    for (var item in quickSpeakItems) {
      if (item.id == selectedId) return item;
    }

    // Search in Tap to Talk
    for (var item in tapToTalkItems) {
      if (item.id == selectedId) return item;
    }

    // Search in Explore More
    for (var item in exploreMoreItems) {
      if (item.id == selectedId) return item;
    }

    return null;
  }

  // Add Button Handler
  void onAddButton() {
    Get.toNamed(AppRoutes.ADD_BUTTON);
  }

  // Edit Mode Actions
  void handleUndo() {
    Get.snackbar('Undo', 'Undo last action');
  }

  void handleDelete() {
    if (selectedItems.isEmpty) {
      Get.snackbar('Delete', 'No items selected');
    } else {
      Get.snackbar('Delete', '${selectedItems.length} items deleted');
      selectedItems.clear();
    }
  }

  void handleSelectAll() {
    if (selectedItems.length ==
        (quickSpeakItems.length + tapToTalkItems.length)) {
      selectedItems.clear();
    } else {
      selectedItems.clear();
      // Quick Speak items add করা
      for (var item in quickSpeakItems) {
        selectedItems.add(item.id);
      }
      // Tap to Talk items add করা
      for (var item in tapToTalkItems) {
        selectedItems.add(item.id);
      }
      // Explore More items add করা (My Schedule বাদে)
      for (var item in exploreMoreItems) {
        if (item.id != myScheduleId) {
          selectedItems.add(item.id);
        }
      }
    }
  }

  void handleSaveChanges() {
    // Check if any item is selected
    if (selectedItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one item to edit',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Check if only one item is selected
    if (selectedItems.length > 1) {
      Get.snackbar(
        'Error',
        'Please select only one item to edit',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    // Get selected item details
    final selectedItem = getSelectedItemDetails();

    if (selectedItem != null) {
      // Navigate to Edit Button Screen with item data
      Get.toNamed(
        AppRoutes.EDIT_BUTTON,
        arguments: selectedItem,
      );
    } else {
      Get.snackbar(
        'Error',
        'Item not found',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Quick Speak Tap Handler
  void onQuickSpeakTap(String action) {
    if (selectedQuickSpeak.value == action) {
      selectedQuickSpeak.value = '';
    } else {
      selectedQuickSpeak.value = action;
    }
    Get.snackbar('Quick Speak', action);
  }

  // Category Tap Handler
  void onCategoryTap(String category) {
    Get.snackbar('Category', category);
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