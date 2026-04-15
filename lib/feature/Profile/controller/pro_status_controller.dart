// lib/controllers/pro_status_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ProStatusController extends GetxController {
  // ── Singleton access ───────────────────────────────────────
  static ProStatusController get to => Get.find();

  static const String _entitlementId = 'ChaterBee_Pro';

  // ── Reactive state ─────────────────────────────────────────
  final isProUser    = false.obs;
  final isChecking   = true.obs;   // initial load spinner এর জন্য

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initStatus();
    _listenToStream();
  }

  // ── 1. App launch-এ একবার current status fetch ────────────
  Future<void> _initStatus() async {
    isChecking.value = true;
    try {
      final info = await Purchases.getCustomerInfo();
      _updateStatus(info, source: 'INIT');
    } catch (e) {
      debugPrint('[PRO] ❌ Init check failed: $e');
    } finally {
      isChecking.value = false;
    }
  }

  // ── 2. RevenueCat stream → auto update ────────────────────
  //    Subscription expire হলে RevenueCat নিজেই এই listener call করবে
  void _listenToStream() {
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    debugPrint('[PRO] ✅ Stream listener attached');
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _updateStatus(info, source: 'STREAM');
  }

  // ── Core update logic ──────────────────────────────────────
  void _updateStatus(CustomerInfo info, {required String source}) {
    final active = info.entitlements.active.containsKey(_entitlementId);
    isProUser.value = active;

    // ── Console log ────────────────────────────────────────
    debugPrint('');
    debugPrint('┌────────────────────────────────────────┐');
    debugPrint('│  [PRO STATUS] source: $source');
    debugPrint('│  isProUser   → $active');
    debugPrint('│  Entitlement → $_entitlementId');
    if (info.entitlements.active.isNotEmpty) {
      info.entitlements.active.forEach((key, value) {
        debugPrint('│  ✅ $key');
        debugPrint('│     expires : ${value.expirationDate ?? 'lifetime'}');
        debugPrint('│     store   : ${value.store.name}');
      });
    } else {
      debugPrint('│  ⚠️  No active entitlements');
    }
    debugPrint('└────────────────────────────────────────┘');
    debugPrint('');
  }

  // ── Manual refresh (Pull-to-refresh বা debug-এ কাজে লাগবে) ─
  Future<void> refresh() => _initStatus();

  // ── Cleanup ────────────────────────────────────────────────
  // permanent: true হওয়ায় এটা normally call হবে না
  // কিন্তু safety-এর জন্য রাখা ভালো
  @override
  void onClose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    super.onClose();
  }
}