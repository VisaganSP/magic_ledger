import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'sms_transaction_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATION TAP ROUTER — handles ALL notification types
  // ═══════════════════════════════════════════════════════════

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('[Notification] Tapped with payload: $payload');

    if (payload == null || payload.isEmpty) {
      // No payload — just open the app home
      _navigateToHome();
      return;
    }

    // ── 1. SMS transaction (JSON with "type":"credit"/"debit") ──
    if (payload.contains('"type"') &&
        (payload.contains('"credit"') || payload.contains('"debit"'))) {
      SmsTransactionService.handleNotificationTap(payload);
      return;
    }

    // ── 2. Todo reminder (payload = "todo:{id}") ──
    if (payload.startsWith('todo:')) {
      final todoId = payload.substring(5);
      _navigateToTodoDetail(todoId);
      return;
    }

    // ── 3. Budget alert (payload = "budget:{categoryName}") ──
    if (payload.startsWith('budget:')) {
      _navigateToBudgets();
      return;
    }

    // ── 4. SMS scan summary (payload = "sms_scan_summary") ──
    if (payload == 'sms_scan_summary') {
      _navigateToHome();
      return;
    }

    // ── 5. Recurring engine summary (payload = "recurring_summary") ──
    if (payload == 'recurring_summary') {
      _navigateToHome();
      return;
    }

    // ── Fallback — unknown payload, go home ──
    debugPrint('[Notification] Unknown payload: $payload');
    _navigateToHome();
  }

  // ── Navigation helpers (use Future.microtask to avoid mid-build nav) ──

  void _navigateToHome() {
    Future.microtask(() {
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    });
  }

  void _navigateToTodoDetail(String todoId) {
    Future.microtask(() {
      try {
        final todoController = Get.find<dynamic>();
        final todos = todoController.todos as List;
        final todo = todos.firstWhere(
              (t) => t.id == todoId,
          orElse: () => null,
        );

        if (todo != null) {
          Get.toNamed('/todo-detail', arguments: todo);
        } else {
          debugPrint('[Notification] Todo $todoId not found');
          _navigateToHome();
        }
      } catch (e) {
        debugPrint('[Notification] Error navigating to todo: $e');
        _navigateToHome();
      }
    });
  }

  void _navigateToBudgets() {
    Future.microtask(() {
      Get.toNamed('/budgets');
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW NOTIFICATION
  // ═══════════════════════════════════════════════════════════

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'magic_ledger_channel',
      'Magic Ledger Notifications',
      channelDescription: 'Notifications for Magic Ledger app',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Show a transaction notification with action-style formatting
  Future<void> showTransactionNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required bool isCredit,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'magic_ledger_transactions',
      'Transaction Alerts',
      channelDescription: 'Auto-detected bank transaction alerts',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
      color: isCredit ? const Color(0xFFB8E994) : const Color(0xFFFFB49A),
      category: AndroidNotificationCategory.recommendation,
    );

    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // ═══════════════════════════════════════════════════════════
  // SCHEDULE NOTIFICATION
  // ═══════════════════════════════════════════════════════════

  Future<bool> _checkAndRequestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final canSchedule =
            await androidPlugin.canScheduleExactNotifications() ?? false;
        if (!canSchedule) {
          Get.dialog(
            AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'To set reminders at exact times, this app needs the '
                    '"Alarms & reminders" permission. Please enable it in settings.',
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('Later')),
                TextButton(
                  onPressed: () async {
                    Get.back();
                    await AppSettings.openAppSettings(
                        type: AppSettingsType.notification);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
            barrierDismissible: false,
          );
          return false;
        }
      }
    }
    return true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      if (scheduledDate.isBefore(DateTime.now())) {
        Get.snackbar('Invalid Time', 'Cannot set reminder for past time',
            backgroundColor: Colors.orange, colorText: Colors.white,
            duration: const Duration(seconds: 3));
        return;
      }

      final hasPermission = await _checkAndRequestExactAlarmPermission();

      if (!hasPermission) {
        await _scheduleInexactNotification(
            id: id, title: title, body: body,
            scheduledDate: scheduledDate, payload: payload);
        Get.snackbar('Approximate Reminder',
            'Reminder will notify around the scheduled time.',
            backgroundColor: Colors.orange, colorText: Colors.white,
            duration: const Duration(seconds: 4));
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'magic_ledger_scheduled',
        'Scheduled Notifications',
        channelDescription: 'Scheduled notifications for reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const details = NotificationDetails(
          android: androidDetails, iOS: const DarwinNotificationDetails());
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(id, title, body, tzDate, details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload);

      Get.snackbar('Reminder Set',
          'You will be notified at ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}',
          backgroundColor: Colors.green, colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.alarm_on, color: Colors.white));
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      if (e.toString().contains('exact_alarms_not_permitted')) {
        await _scheduleInexactNotification(
            id: id, title: title, body: body,
            scheduledDate: scheduledDate, payload: payload);
      } else {
        Get.snackbar('Error', 'Failed to schedule notification',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  Future<void> _scheduleInexactNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'magic_ledger_scheduled',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
        android: androidDetails, iOS: const DarwinNotificationDetails());

    await _notifications.zonedSchedule(id, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local), details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload);
  }

  Future<void> cancelNotification(int id) async => await _notifications.cancel(id);
  Future<void> cancelAllNotifications() async => await _notifications.cancelAll();
}