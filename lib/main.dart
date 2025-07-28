import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/data/providers/hive_provider.dart';
import 'app/data/services/notification_service.dart';
import 'app/routes/app_pages.dart'; // Make sure this import is correct
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveProvider.init();

  // Initialize Notifications
  await NotificationService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Neo Expense Tracker',
      theme: AppTheme.neoBrutalismTheme,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
