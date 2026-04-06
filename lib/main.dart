import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'app/bindings/initial_binding.dart';
import 'app/data/providers/hive_provider.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/home_widget_service.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/sms_transaction_service.dart';
import 'app/modules/auth/views/lock_screen_view.dart';
import 'app/modules/auth/views/setup_pin_view.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveProvider.init();
  await NotificationService().init();
  await HomeWidgetService.init();
  await Hive.openBox('auth_settings');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      final auth = Get.find<AuthService>();

      if (state == AppLifecycleState.paused) {
        _backgroundTime = DateTime.now();
      }

      if (state == AppLifecycleState.resumed) {
        if (_backgroundTime != null && auth.isSetupComplete.value) {
          final elapsed = DateTime.now().difference(_backgroundTime!).inSeconds;
          if (elapsed >= auth.lockTimeout.value) {
            auth.lockApp();
            Get.offAllNamed('/lock');
          }
        }
        _backgroundTime = null;
      }
    } catch (_) {
      // AuthService not registered yet
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Magic Ledger',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      home: const AuthGate(),
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();

    if (!auth.isSetupComplete.value) {
      return const SetupPinView();
    } else if (auth.isLocked.value) {
      return const LockScreenView();
    } else {
      return const HomeView();
    }
  }
}