// lib/feature/notification/controller/notification_controller.dart

import 'package:chatter_bee/Repository/notification/notification_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';

class NotificationControllerFCM extends GetxController {
  static NotificationControllerFCM get to => Get.find();

  final FcmTokenRepository _fcmRepo = FcmTokenRepository();
  final SecureStorageService _secureStorage = SecureStorageService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final RxString fcmToken = ''.obs;
  final RxBool isTokenRegistered = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getCurrentFcmToken();
  }

  /// 1️⃣ Current FCM Token নাও
  Future<void> _getCurrentFcmToken() async {
    try {
      final token = await _fcm.getToken();
      fcmToken.value = token ?? '';
      if (kDebugMode) print('📱 Current FCM Token: ${fcmToken.value}');
    } catch (e) {
      if (kDebugMode) print('❌ Get token error: $e');
    }
  }

  /// 2️⃣ Register FCM Token (Login成功后 call করবেন)
  Future<bool> registerFcmToken() async {
    try {
      // Check token আছে কিনা
      if (fcmToken.value.isEmpty) {
        await _getCurrentFcmToken();
      }

      if (fcmToken.value.isEmpty) {
        if (kDebugMode) print('⚠️ No FCM token available');
        return false;
      }

      // Check আগে থেকে register করা আছে কিনা
      final existingId = await _secureStorage.getFcmTokenId();
      if (existingId != null && existingId.isNotEmpty) {
        if (kDebugMode) print('✅ FCM token already registered with ID: $existingId');
        isTokenRegistered.value = true;
        return true;
      }

      // Backend এ register করি
      final deviceType = FcmTokenRepository.getDeviceType();
      final response = await _fcmRepo.registerFcmToken(
        deviceToken: fcmToken.value,
        deviceType: deviceType,
      );

      if (response.isSuccess && response.data != null) {
        final tokenId = response.data!['id']?.toString();
        if (tokenId != null && tokenId.isNotEmpty) {
          await _secureStorage.saveFcmTokenId(tokenId);
          isTokenRegistered.value = true;
          if (kDebugMode) {
            print('✅ FCM Token registered successfully');
            print('📌 Token ID: $tokenId');
          }
          return true;
        }
      }

      if (kDebugMode) print('❌ FCM registration failed: ${response.message}');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ registerFcmToken error: $e');
      return false;
    }
  }

  /// 3️⃣ Delete FCM Token (Logout করার আগে call করবেন)
  Future<bool> deleteFcmToken() async {
    try {
      final tokenId = await _secureStorage.getFcmTokenId();

      if (tokenId == null || tokenId.isEmpty) {
        if (kDebugMode) print('⚠️ No FCM token ID found to delete');
        isTokenRegistered.value = false;
        return true;
      }

      final response = await _fcmRepo.deleteFcmToken(tokenId: tokenId);

      if (response.isSuccess || response.statusCode == 204) {
        await _secureStorage.deleteFcmTokenId();
        isTokenRegistered.value = false;
        if (kDebugMode) print('✅ FCM token deleted successfully');
        return true;
      } else {
        if (kDebugMode) print('❌ Delete failed: ${response.message}');
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ deleteFcmToken error: $e');
      return false;
    }
  }

  /// 4️⃣ Forcefully re-register (Token refresh এর জন্য)
  Future<void> refreshAndReRegister() async {
    await _fcm.deleteToken();
    final newToken = await _fcm.getToken();
    if (newToken != null) {
      fcmToken.value = newToken;
      await _secureStorage.deleteFcmTokenId();
      await registerFcmToken();
    }
  }
}