import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

    // Request notification permission for Android 13+
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Navigate to relevant screen based on payload
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'neo_tracker_channel',
      'Neo Tracker Notifications',
      channelDescription: 'Notifications for Neo Tracker app',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<bool> _checkAndRequestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        final canScheduleExactAlarms =
            await androidPlugin.canScheduleExactNotifications() ?? false;

        if (!canScheduleExactAlarms) {
          // Show dialog to guide user
          Get.dialog(
            AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'To set reminders at exact times, this app needs the "Alarms & reminders" permission. '
                'Please enable it in your device settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Later'),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back();
                    // Use app_settings package for better reliability
                    await AppSettings.openAppSettings(
                      type: AppSettingsType.notification,
                    );
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
      // Check if the scheduled date is in the past
      if (scheduledDate.isBefore(DateTime.now())) {
        Get.snackbar(
          'Invalid Time',
          'Cannot set reminder for past time',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Check for exact alarm permission first
      final hasPermission = await _checkAndRequestExactAlarmPermission();

      if (!hasPermission) {
        // Show message and try with inexact alarm as fallback
        Get.snackbar(
          'Using Approximate Reminder',
          'Exact alarm permission not granted. Reminder will notify around the scheduled time.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () async {
              await AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              );
            },
            child: const Text(
              'SETTINGS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        await _scheduleInexactNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: payload,
        );
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'neo_tracker_scheduled',
        'Scheduled Notifications',
        channelDescription: 'Scheduled notifications for reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      // Show success message
      Get.snackbar(
        'Reminder Set',
        'You will be notified at ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.alarm_on, color: Colors.white),
      );
    } catch (e) {
      print('Error in scheduleNotification: $e');

      if (e.toString().contains('exact_alarms_not_permitted')) {
        // Fallback to inexact alarm
        await _scheduleInexactNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: payload,
        );

        Get.snackbar(
          'Reminder Set (Approximate)',
          'Exact alarm permission not available. Reminder will notify around the scheduled time.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error Setting Reminder',
          'Failed to schedule notification: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
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
      'neo_tracker_scheduled',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
