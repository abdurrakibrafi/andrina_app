
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:chatter_bee/services/notification_controller.dart';
import 'package:chatter_bee/services/notification_services.dart';
import 'package:chatter_bee/services/revenueCat_services.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/my_app.dart';
import 'feature/Profile/controller/pro_status_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔥 Step 1: Firebase init...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Step 1: Firebase done');

    print('💾 Step 2: Storage init...');
    await StorageService().init();
    print('✅ Step 2: Storage done');

    print('📡 Step 3: CommunicatorSession init...');
    await Get.putAsync(() async => CommunicatorSessionService());
    print('✅ Step 3: CommunicatorSession done');

    print('🔔 Step 4: NotificationService init...');
    await Get.putAsync(() async => await NotificationService().init());
    print('✅ Step 4: NotificationService done');

    print('🎮 Step 5: NotificationController init...');
    Get.put(NotificationController()); // ✅ শুধু put করুন, init না
    print('✅ Step 5: NotificationController done');

    print('💰 Step 6: RevenueCat init...');
    await RevenueCatService.instance.init();
    print('✅ Step 6: RevenueCat done');

    Get.put(ProStatusController(), permanent: true);

    print('✅ App initialized successfully');
    runApp(const MyApp());
  } catch (e, stack) {
    print('❌ ERROR: $e');
    print(stack);
  }
}