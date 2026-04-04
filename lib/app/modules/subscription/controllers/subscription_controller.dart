import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/subscription_model.dart';
import '../../../data/services/notification_service.dart';

class SubscriptionController extends GetxController {
  final Box<SubscriptionModel> _subBox = Hive.box('subscriptions');
  final RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  final RxBool isLoading = false.obs;
  final NotificationService _notif = NotificationService();

  // Stats
  final RxDouble monthlyTotal = 0.0.obs;
  final RxDouble yearlyTotal = 0.0.obs;
  final RxInt activeCount = 0.obs;
  final RxInt renewingSoonCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptions();
  }

  void loadSubscriptions() {
    try {
      isLoading.value = true;
      subscriptions.value = _subBox.values.toList()
        ..sort((a, b) => a.nextRenewal.compareTo(b.nextRenewal));
      _updateStats();
      _advanceOverdueRenewals();
    } catch (e) {
      debugPrint('Error loading subscriptions: $e');
      subscriptions.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStats() {
    final active = subscriptions.where((s) => s.isActive).toList();
    monthlyTotal.value = active.fold(0.0, (s, sub) => s + sub.monthlyCost);
    yearlyTotal.value = active.fold(0.0, (s, sub) => s + sub.yearlyCost);
    activeCount.value = active.length;
    renewingSoonCount.value = active.where((s) => s.isRenewingSoon()).length;
  }

  /// Auto-advance overdue renewals to next cycle date
  void _advanceOverdueRenewals() {
    for (final sub in subscriptions) {
      if (sub.isActive && sub.isOverdue) {
        final next = sub.calculateNextRenewal();
        sub.nextRenewal = next;
        sub.save();
      }
    }
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    await _subBox.put(sub.id, sub);
    _scheduleRenewalReminder(sub);
    loadSubscriptions();
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    await _subBox.put(sub.id, sub);
    _scheduleRenewalReminder(sub);
    loadSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    await _notif.cancelNotification(id.hashCode);
    await _subBox.delete(id);
    loadSubscriptions();
  }

  Future<void> toggleActive(String id) async {
    final sub = _subBox.get(id);
    if (sub == null) return;
    sub.isActive = !sub.isActive;
    await sub.save();
    if (!sub.isActive) {
      await _notif.cancelNotification(id.hashCode);
    } else {
      _scheduleRenewalReminder(sub);
    }
    loadSubscriptions();
  }

  void _scheduleRenewalReminder(SubscriptionModel sub) {
    if (!sub.isActive) return;
    // Schedule reminder 2 days before renewal
    final reminderDate = sub.nextRenewal.subtract(const Duration(days: 2));
    if (reminderDate.isAfter(DateTime.now())) {
      _notif.scheduleNotification(
        id: sub.id.hashCode,
        title: '🔄 ${sub.name} renews in 2 days',
        body: '₹${sub.amount.toStringAsFixed(0)} ${sub.cycle} subscription renews on '
            '${sub.nextRenewal.day}/${sub.nextRenewal.month}',
        scheduledDate: reminderDate,
        payload: 'subscription:${sub.id}',
      );
    }
  }

  /// Schedule reminders for all active subscriptions (call on app start)
  void scheduleAllReminders() {
    for (final sub in subscriptions.where((s) => s.isActive)) {
      _scheduleRenewalReminder(sub);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════

  List<SubscriptionModel> get active =>
      subscriptions.where((s) => s.isActive).toList();

  List<SubscriptionModel> get inactive =>
      subscriptions.where((s) => !s.isActive).toList();

  List<SubscriptionModel> get renewingSoon =>
      active.where((s) => s.isRenewingSoon()).toList();

  /// Group active subscriptions by cycle
  Map<String, List<SubscriptionModel>> get groupedByCycle {
    final groups = <String, List<SubscriptionModel>>{};
    for (final s in active) {
      groups.putIfAbsent(s.cycle, () => []).add(s);
    }
    return groups;
  }

  /// Get total cost for a specific cycle
  double getTotalForCycle(String cycle) {
    return active
        .where((s) => s.cycle == cycle)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  /// Daily cost of all subscriptions
  double get dailyCost => yearlyTotal.value / 365;

  /// Get the most expensive subscription
  SubscriptionModel? get mostExpensive {
    if (active.isEmpty) return null;
    return active.reduce((a, b) => a.monthlyCost > b.monthlyCost ? a : b);
  }
}