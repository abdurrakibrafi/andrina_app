// lib/feature/home_screen/communicator/controller/communicator_sub_category_controller.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorSubCategoryController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final CommCategoryModel parentCategory;

  final RxList<CommSubCategoryModel> subCategories =
      <CommSubCategoryModel>[].obs;
  final RxInt playingId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    parentCategory = Get.arguments as CommCategoryModel;
    subCategories.value = parentCategory.subCategories;
  }

  void onSubCategoryTap(CommSubCategoryModel sub) {
    Get.toNamed(AppRoutes.COMMUNICATOR_ITEM, arguments: sub);
  }

  Future<void> playAudio(int id, String? audioPath) async {
    final url = AppUrl.mediaUrl(audioPath);
    if (url == null) return;

    if (playingId.value == id) {
      await _audioPlayer.stop();
      playingId.value = -1;
      return;
    }
    try {
      playingId.value = id;
      await _audioPlayer.play(UrlSource(url));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (playingId.value == id) playingId.value = -1;
      });
    } catch (e) {
      debugPrint('Audio error: $e');
      playingId.value = -1;
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}