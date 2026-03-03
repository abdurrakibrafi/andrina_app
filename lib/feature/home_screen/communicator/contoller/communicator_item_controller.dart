// lib/feature/home_screen/communicator/contoller/communicator_item_controller.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorItemController extends GetxController {
  final CommunicatorRepository _repo = CommunicatorRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final CommSubCategoryModel parentSubCategory;

  final RxList<CommItemModel> items = <CommItemModel>[].obs;
  final RxInt playingId = (-1).obs;

  // ── Quick speak bar ───────────────────────────────────────────
  final RxString selectedWord = ''.obs;
  final RxInt selectedItemId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    parentSubCategory = Get.arguments as CommSubCategoryModel;
    items.value = parentSubCategory.items;
  }

  // ── Current language ──────────────────────────────────────────
  String get _currentLang {
    try {
      return LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  // ── Buddy mode — CommunicatorHomeController থেকে নাও ─────────
  bool get _isBuddyMode {
    try {
      return Get.find<CommunicatorHomeController>().isBuddyMode.value;
    } catch (_) {
      return false;
    }
  }

  // ── Refresh — buddy mode + lang দিয়ে সঠিক endpoint ──────────
  Future<void> refresh() async {
    final lang = _currentLang;

    final res = _isBuddyMode
        ? await _repo.getBuddyModeContent(lang: lang)
        : await _repo.getContent(lang: lang);

    if (res.isSuccess && res.data != null) {
      for (final cat in res.data!.categories) {
        final sub = cat.subCategories
            .firstWhereOrNull((s) => s.id == parentSubCategory.id);
        if (sub != null) {
          items.value = sub.items;
          break;
        }
      }

      // Home controller ও update করো
      if (Get.isRegistered<CommunicatorHomeController>()) {
        Get.find<CommunicatorHomeController>().loadContent();
      }
    }
  }

  // ── Item tap → word bar ────────────────────────────────────────
  void onItemTap(CommItemModel item) {
    if (selectedItemId.value == item.id) {
      selectedItemId.value = -1;
      selectedWord.value = '';
    } else {
      selectedItemId.value = item.id;
      selectedWord.value = item.word ?? '';
    }
  }

  // ── Speak button ───────────────────────────────────────────────
  void speakSelected() {
    if (selectedWord.value.isEmpty) return;
    final item = items.firstWhereOrNull((i) => i.id == selectedItemId.value);
    if (item?.speak != null) {
      playAudio(item!.id, item.speak);
    } else {
      Get.snackbar(
        'speak'.tr,
        selectedWord.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void clearSelection() {
    selectedItemId.value = -1;
    selectedWord.value = '';
  }

  // ── Audio ──────────────────────────────────────────────────────
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