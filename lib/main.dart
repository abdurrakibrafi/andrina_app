import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await StorageService().init();

  print('✅ App initialized successfully');

  runApp(const MyApp());
}