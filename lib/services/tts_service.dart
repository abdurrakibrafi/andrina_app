// lib/services/tts_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsService extends GetxService {
  static TtsService get to => Get.find();

  final FlutterTts _tts = FlutterTts();

  final RxBool isSpeaking = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _tts.setSharedInstance(true); // iOS audio session sharing
    await _tts.setSpeechRate(0.5);      // শিশুদের জন্য ধীর গতি
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((_) => isSpeaking.value = false);
  }

  /// ডিভাইসের ভাষা অনুযায়ী TTS language সেট করে বলবে
  Future<void> speak(String text, {String lang = 'en'}) async {
    if (text.trim().isEmpty) return;

    await stop(); // আগের টা থামাও

    final ttsLang = _mapLang(lang);
    await _tts.setLanguage(ttsLang);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
  }

  /// app language code → TTS locale
  String _mapLang(String lang) {
    switch (lang) {
      case 'es': return 'es-ES';
      case 'ar': return 'ar-SA';
      default:   return 'en-US';
    }
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}