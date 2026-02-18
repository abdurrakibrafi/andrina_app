import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivitiesController extends GetxController {
  var selectedActivity = ''.obs;

  final List<ActivityModel> activities = [
    ActivityModel(
      imagePath: ImagesLink.playImg,
      label: 'Play',
    ),
    ActivityModel(
      imagePath: ImagesLink.readImg,
      label: 'Read',
    ),
    ActivityModel(
      imagePath: ImagesLink.drawImg,
      label: 'Draw',
    ),
    ActivityModel(
      imagePath: ImagesLink.watchTvImg,
      label: 'Watch TV',
    ),
  ];

  void selectActivity(String activity) {
    selectedActivity.value = activity;
  }

  void speakActivity() {
    if (selectedActivity.value.isNotEmpty) {
      // TODO: Implement text-to-speech functionality
      Get.snackbar(
        'Speaking',
        'I want to ${selectedActivity.value.toLowerCase()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select an activity first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearActivity() {
    selectedActivity.value = '';
  }
}

class ActivityModel {
  final String imagePath;
  final String label;

  ActivityModel({
    required this.imagePath,
    required this.label,
  });
}