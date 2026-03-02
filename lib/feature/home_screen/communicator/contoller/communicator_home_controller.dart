// lib/feature/home_screen/communicator_home_controller.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorHomeController extends GetxController {
  final CommunicatorRepository _repo = CommunicatorRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── Loading ───────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;

  // ── Data from API ─────────────────────────────────────────────────────────
  final RxList<CommCategoryModel> categories = <CommCategoryModel>[].obs;
  final RxList<CommQuickSpeakModel> quickSpeaks = <CommQuickSpeakModel>[].obs;

  // ── Quick Speak bar ───────────────────────────────────────────────────────
  final RxString quickSpeakText = ''.obs;
  final RxInt selectedQsId = (-1).obs;

  // ── Audio player state ────────────────────────────────────────────────────
  final RxInt playingId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  // ─── API call ──────────────────────────────────────────────────────────────
  Future<void> loadContent() async {
    isLoading.value = true;
    final res = await _repo.getContent();
    isLoading.value = false;

    if (res.isSuccess && res.data != null) {
      categories.value = res.data!.categories;
      quickSpeaks.value = res.data!.quickSpeaks;
    } else {
      Get.snackbar(
        'error'.tr,
        res.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> refresh() => loadContent();

  // ─── Quick speak tap ───────────────────────────────────────────────────────
  void onQuickSpeakTap(CommQuickSpeakModel qs) {
    if (selectedQsId.value == qs.id) {
      selectedQsId.value = -1;
      quickSpeakText.value = '';
    } else {
      selectedQsId.value = qs.id;
      quickSpeakText.value = qs.word ?? '';
    }
  }

  // ─── Speak button ──────────────────────────────────────────────────────────
  void speakQuickSpeak() {
    if (quickSpeakText.value.isEmpty) {
      Get.snackbar(
        'select_first'.tr,
        'tap_quick_speak_first'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final selected =
    quickSpeaks.firstWhereOrNull((q) => q.id == selectedQsId.value);
    if (selected?.speak != null) {
      playAudio(selected!.id, selected.speak);
    } else {
      Get.snackbar(
        'speak'.tr,
        quickSpeakText.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ─── Clear bar ─────────────────────────────────────────────────────────────
  void clearQuickSpeak() {
    selectedQsId.value = -1;
    quickSpeakText.value = '';
  }

  // ─── Play audio ────────────────────────────────────────────────────────────
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
      debugPrint('Audio play error: $e');
      playingId.value = -1;
    }
  }

  // ─── Navigation ────────────────────────────────────────────────────────────
  void onCategoryTap(CommCategoryModel category) {
    Get.toNamed(
      AppRoutes.COMMUNICATOR_SUB_CATEGORY,
      arguments: category,
    );
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
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