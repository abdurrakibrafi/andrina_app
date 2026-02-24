// lib/feature/home_screen/communicator/controller/communicator_item_controller.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorItemController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final CommSubCategoryModel parentSubCategory;

  final RxList<CommItemModel> items = <CommItemModel>[].obs;
  final RxInt playingId = (-1).obs;

  // ── Quick speak bar (top of item screen) ──────────────────────────────────
  final RxString selectedWord = ''.obs;
  final RxInt selectedItemId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    parentSubCategory = Get.arguments as CommSubCategoryModel;
    items.value = parentSubCategory.items;
  }

  // ─── Tap item → show word in bar ──────────────────────────────────────────
  void onItemTap(CommItemModel item) {
    if (selectedItemId.value == item.id) {
      selectedItemId.value = -1;
      selectedWord.value = '';
    } else {
      selectedItemId.value = item.id;
      selectedWord.value = item.word ?? '';
    }
  }

  // ─── Speak button ─────────────────────────────────────────────────────────
  void speakSelected() {
    if (selectedWord.value.isEmpty) return;
    final item =
    items.firstWhereOrNull((i) => i.id == selectedItemId.value);
    if (item?.speak != null) {
      playAudio(item!.id, item.speak);
    } else {
      Get.snackbar('Speak', selectedWord.value,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  void clearSelection() {
    selectedItemId.value = -1;
    selectedWord.value = '';
  }

  // ─── Audio ────────────────────────────────────────────────────────────────
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