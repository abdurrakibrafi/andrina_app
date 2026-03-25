import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:chatter_bee/services/notification_services.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/my_app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize SharedPreferences
  await StorageService().init();

  // Initialize CommunicatorSessionService
  await Get.putAsync(() async => CommunicatorSessionService());

  // Initialize NotificationService
  Get.putAsync(() => NotificationService().init());

  print('✅ App initialized successfully');

  runApp(const MyApp());
}