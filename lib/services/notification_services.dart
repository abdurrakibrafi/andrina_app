import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────
// Background handler — must be top-level function (outside class)
// ─────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 [BG] Message received: ${message.messageId}');
  // Note: Do NOT call Get.find() or Navigator here — app may not be ready
}

// ─────────────────────────────────────────────────────────────
// Notification Payload Model
// ─────────────────────────────────────────────────────────────
class NotificationPayload {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const NotificationPayload({
    this.title,
    this.body,
    this.data = const {},
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }

  @override
  String toString() => 'NotificationPayload(title: $title, body: $body, data: $data)';
}

// ─────────────────────────────────────────────────────────────
// NotificationService
// Usage: await Get.putAsync(() => NotificationService().init());
// Access: NotificationService.to
// ─────────────────────────────────────────────────────────────
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // ── Observable token (use Obx to watch this in UI) ────────
  final RxnString fcmToken = RxnString();

  // ── Tap callback — set from your controller ───────────────
  // Example:
  //   NotificationService.to.onNotificationTap = (payload) {
  //     Get.toNamed('/chat', arguments: payload.data);
  //   };
  void Function(NotificationPayload payload)? onNotificationTap;

  // ── Android Notification Channel ──────────────────────────
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',          // id
    'High Importance Notifications',    // name
    description: 'Used for important notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ─────────────────────────────────────────────────────────
  // PUBLIC INIT — call in main() after Firebase.initializeApp()
  // ─────────────────────────────────────────────────────────
  Future<NotificationService> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _initLocalNotifications();
    await _createAndroidChannel();
    await _initFcmToken();
    _listenForeground();
    _listenBackgroundTap();
    await _handleTerminatedLaunch();

    debugPrint('✅ NotificationService ready | token: ${fcmToken.value}');
    return this;
  }

  // ─────────────────────────────────────────────────────────
  // 1. Permission (iOS + Android 13+)
  // ─────────────────────────────────────────────────────────
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    debugPrint('🔐 Permission: ${settings.authorizationStatus}');
  }

  // ─────────────────────────────────────────────────────────
  // 2. Local Notifications Init (flutter_local_notifications ^18)
  // ─────────────────────────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already handled by FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onLocalNotificationTap,
    );
  }

  // ─────────────────────────────────────────────────────────
  // 3. Android Channel
  // ─────────────────────────────────────────────────────────
  Future<void> _createAndroidChannel() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  // ─────────────────────────────────────────────────────────
  // 4. FCM Token
  // ─────────────────────────────────────────────────────────
  // Future<void> _initFcmToken() async {
  //   // iOS needs APNS token first
  //   if (Platform.isIOS) {
  //     final apns = await _fcm.getAPNSToken();
  //     debugPrint('📱 APNS: $apns');
  //   }
  //
  //   fcmToken.value = await _fcm.getToken();
  //   debugPrint('🔑 FCM Token: ${fcmToken.value}');
  //
  //   // Auto-refresh
  //   _fcm.onTokenRefresh.listen((newToken) {
  //     fcmToken.value = newToken;
  //     debugPrint('🔄 Token refreshed: $newToken');
  //     // TODO: send newToken to your backend
  //   });
  // }

  // Future<void> _initFcmToken() async {
  //   if (Platform.isIOS) {
  //     String? apnsToken;
  //     // Wait until APNS token is available
  //     for (int i = 0; i < 10; i++) {
  //       apnsToken = await _fcm.getAPNSToken();
  //       debugPrint('📱 APNS 1: $apnsToken');
  //       if (apnsToken != null) break;
  //       debugPrint('📱 APNS 2: $apnsToken');
  //       await Future.delayed(const Duration(seconds: 1));
  //     }
  //
  //     debugPrint('📱 APNS 3: $apnsToken');
  //   }
  //
  //   try {
  //     fcmToken.value = await _fcm.getToken();
  //     debugPrint('🔑 FCM Token: ${fcmToken.value}');
  //   } catch (e) {
  //     debugPrint('❌ FCM error: $e');
  //   }
  //
  //   _fcm.onTokenRefresh.listen((newToken) {
  //     fcmToken.value = newToken;
  //     debugPrint('🔄 Token refreshed: $newToken');
  //   });
  // }

  Future<void> _initFcmToken() async {
    // Listen for token refreshes first — catches late APNS arrival too
    _fcm.onTokenRefresh.listen((newToken) {
      fcmToken.value = newToken;
      debugPrint('🔄 Token refreshed: $newToken');
      // TODO: send newToken to your backend
    });

    if (Platform.isIOS) {
      String? apns;
      // Increase attempts to 15, with 2-second gaps (30 s total)
      for (int i = 0; i < 15; i++) {
        apns = await _fcm.getAPNSToken();
        debugPrint('📱 APNS attempt ${i + 1}: $apns');
        if (apns != null) break;
        await Future.delayed(const Duration(seconds: 2));
      }

      if (apns == null) {
        debugPrint('⚠️ APNS token unavailable — FCM token will arrive via onTokenRefresh');
        return; // ← exit cleanly; token will come via the stream above
      }
    }

    try {
      fcmToken.value = await _fcm.getToken();
      debugPrint('🔑 FCM Token: ${fcmToken.value}');
    } catch (e) {
      debugPrint('❌ FCM getToken() failed: $e — will retry via onTokenRefresh');
    }
  }


  // ─────────────────────────────────────────────────────────
  // 5. Foreground — FCM does NOT auto-show on Android/iOS
  //    so we show manually via local notifications
  // ─────────────────────────────────────────────────────────
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 [FG] ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  // ─────────────────────────────────────────────────────────
  // 6. Background tap (app in background, user taps notification)
  // ─────────────────────────────────────────────────────────
  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 [BG Tap] ${message.messageId}');
      _handlePayload(NotificationPayload.fromRemoteMessage(message));
    });
  }

  // ─────────────────────────────────────────────────────────
  // 7. Terminated tap (app was closed, opened via notification)
  // ─────────────────────────────────────────────────────────
  Future<void> _handleTerminatedLaunch() async {
    final message = await _fcm.getInitialMessage();
    if (message != null) {
      debugPrint('🚀 [Terminated] ${message.messageId}');
      // Delay so navigators are ready
      Future.delayed(const Duration(milliseconds: 500), () {
        _handlePayload(NotificationPayload.fromRemoteMessage(message));
      });
    }
  }

  // ─────────────────────────────────────────────────────────
  // Internal: show local notification (for foreground FCM)
  // ─────────────────────────────────────────────────────────
  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   final notification = message.notification;
  //   if (notification == null) return;
  //
  //   await _localNotifications.show(
  //     notification.hashCode,
  //     notification.title,
  //     notification.body,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         _channel.id,
  //         _channel.name,
  //         channelDescription: _channel.description,
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         icon: '@mipmap/ic_launcher',
  //         playSound: true,
  //         enableVibration: true,
  //       ),
  //       iOS: const DarwinNotificationDetails(
  //         presentAlert: true,
  //         presentBadge: true,
  //         presentSound: true,
  //       ),
  //     ),
  //   );
  // }
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'];
    final body  = message.notification?.body  ?? message.data['body'];

    debugPrint('🔔 [FG] title: $title | body: $body'); // ← এটা কী print করে দেখো

    try {
      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      debugPrint('✅ Local notification shown successfully');
    } catch (e, stack) {
      debugPrint('❌ Local notification error: $e');
      debugPrint('❌ Stack: $stack');
    }
  }
  // ─────────────────────────────────────────────────────────
  // PUBLIC: Show a local notification manually (testing etc.)
  // ─────────────────────────────────────────────────────────
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // PUBLIC: Topic subscribe / unsubscribe
  // ─────────────────────────────────────────────────────────
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint('📌 Subscribed: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint('📌 Unsubscribed: $topic');
  }

  // ─────────────────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────────────────
  void _handlePayload(NotificationPayload payload) {
    onNotificationTap?.call(payload);
  }

  // Local notification tap handler — must be top-level or static
  // for background isolate support (^18.0.0 requirement)
  @pragma('vm:entry-point')
  static void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint('👆 Local tap: ${response.payload}');
    // Safe to use Get here since app is in foreground/background
    if (Get.isRegistered<NotificationService>()) {
      NotificationService.to._handlePayload(
        NotificationPayload(data: {'payload': response.payload ?? ''}),
      );
    }
  }
}