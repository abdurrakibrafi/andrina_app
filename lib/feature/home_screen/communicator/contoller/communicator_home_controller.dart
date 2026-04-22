// lib/feature/home_screen/communicator/contoller/communicator_home_controller.dart

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorHomeController extends GetxController {
  final CommunicatorRepository _repo = CommunicatorRepository();
  final AuthRepository _authRepository = AuthRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── State ─────────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isBuddyMode = false.obs;

  // ── Data ──────────────────────────────────────────────────────────────────
  final RxList<CommCategoryModel> categories = <CommCategoryModel>[].obs;
  final RxList<CommQuickSpeakModel> quickSpeaks = <CommQuickSpeakModel>[].obs;

  // ── Quick Speak bar ───────────────────────────────────────────────────────
  final RxString quickSpeakText = ''.obs;
  final RxInt selectedQsId = (-1).obs;

  // ── Audio ─────────────────────────────────────────────────────────────────
  final RxInt playingId = (-1).obs;

  // ── Speak button cooldown ─────────────────────────────────────────────────
  /// true while the 2-second cooldown is running (button disabled)
  final RxBool isSpeakCooldown = false.obs;

  /// countdown display value: 5 → 4 → 3 → 2 → 1 → 0
  final RxInt cooldownCount = 5.obs;

  Timer? _cooldownTimer;

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  // ── Current language code (en / es / ar) ──────────────────────────────────
  String get _currentLang {
    try {
      return LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  // ── API call with buddy mode + lang routing ────────────────────────────────
  Future<void> loadContent() async {
    isLoading.value = true;

    // 1️⃣ Profile থেকে buddy_mode check করো
    try {
      final profileRes = await _authRepository.getProfile();
      if (profileRes.isSuccess && profileRes.data != null) {
        final data = profileRes.data!['data'] ?? profileRes.data!;
        isBuddyMode.value = data['buddy_mode'] ?? false;
      }
    } catch (e) {
      debugPrint('CommunicatorHomeController: profile fetch error: $e');
    }

    // 2️⃣ Current language নাও
    final lang = _currentLang;

    // 3️⃣ Buddy mode অনুযায়ী সঠিক endpoint hit করো
    final res = isBuddyMode.value
        ? await _repo.getBuddyModeContent(lang: lang)
        : await _repo.getContent(lang: lang);

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

  // ── Quick speak tap ────────────────────────────────────────────────────────
  void onQuickSpeakTap(CommQuickSpeakModel qs) {
    if (selectedQsId.value == qs.id) {
      selectedQsId.value = -1;
      quickSpeakText.value = '';
    } else {
      selectedQsId.value = qs.id;
      quickSpeakText.value = qs.word ?? '';
    }
  }

  // ── Speak button ───────────────────────────────────────────────────────────
  /// Plays audio + calls pressed API + starts 2-second cooldown
  void speakQuickSpeak() {
    // Cooldown চলাকালীন click ignore করো
    if (isSpeakCooldown.value) return;

    if (quickSpeakText.value.isEmpty) {
      Get.snackbar('select_first'.tr, 'tap_quick_speak_first'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final selected =
    quickSpeaks.firstWhereOrNull((q) => q.id == selectedQsId.value);
    if (selected == null) return;

    // 1️⃣ Audio play করো
    if (selected.speak != null) {
      _playAudioInternal(selected.id, selected.speak);
    }

    // 2️⃣ Pressed API hit করো (fire-and-forget)
    _repo.pressContent(contentType: 'quickspeak', contentId: selected.id);

    // 3️⃣ Cooldown start করো
    _startCooldown();
  }

  void clearQuickSpeak() {
    // Audio বন্ধ করো
    _stopAudio();

    selectedQsId.value = -1;
    quickSpeakText.value = '';

    // চলমান cooldown বাতিল করো
    _cancelCooldown();
  }

  // ── Cooldown helpers ───────────────────────────────────────────────────────
  void _startCooldown() {
    _cancelCooldown(); // আগের timer থাকলে বাতিল করো

    cooldownCount.value = 5;
    isSpeakCooldown.value = true;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownCount.value > 0) {
        cooldownCount.value--;
      } else {
        timer.cancel();
        isSpeakCooldown.value = false;
        cooldownCount.value = 5; // reset for next use
      }
    });
  }

  void _cancelCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    isSpeakCooldown.value = false;
    cooldownCount.value = 5;
  }

  // ── Audio ──────────────────────────────────────────────────────────────────
  Future<void> _playAudioInternal(int id, String? audioPath) async {
    final url = AppUrl.mediaUrl(audioPath);
    if (url == null) return;

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

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    playingId.value = -1;
  }

  /// Public — sub-screens may call this if they share the same AudioPlayer
  Future<void> playAudio(int id, String? audioPath) async {
    final url = AppUrl.mediaUrl(audioPath);
    if (url == null) return;

    if (playingId.value == id) {
      await _stopAudio();
      return;
    }
    await _playAudioInternal(id, audioPath);
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void onCategoryTap(CommCategoryModel category) {
    Get.toNamed(AppRoutes.COMMUNICATOR_SUB_CATEGORY, arguments: category);
  }

  @override
  void onClose() {
    _cancelCooldown();
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