import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await StorageService().init();

  // Initialize CommunicatorSessionService
  await Get.putAsync(() async => CommunicatorSessionService());

  print('✅ App initialized successfully');

  runApp(const MyApp());
}