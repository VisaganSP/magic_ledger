import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/savings_goal_model.dart';

class SavingsController extends GetxController {
  final Box<SavingsGoalModel> _box = Hive.box('savings_goals');
  final RxList<SavingsGoalModel> goals = <SavingsGoalModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  void loadGoals() {
    try {
      isLoading.value = true;
      goals.value = _box.values.toList()
        ..sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          return b.createdAt.compareTo(a.createdAt);
        });
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addGoal(SavingsGoalModel g) async {
    await _box.put(g.id, g);
    loadGoals();
  }

  Future<void> updateGoal(SavingsGoalModel g) async {
    await _box.put(g.id, g);
    loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
    loadGoals();
  }

  /// Add money to a savings goal
  Future<void> contribute(String goalId, double amount) async {
    final g = _box.get(goalId);
    if (g == null) return;
    g.savedAmount += amount;
    if (g.savedAmount >= g.targetAmount) g.isCompleted = true;
    await g.save();
    loadGoals();
  }

  /// Withdraw money from a savings goal
  Future<void> withdraw(String goalId, double amount) async {
    final g = _box.get(goalId);
    if (g == null) return;
    g.savedAmount = (g.savedAmount - amount).clamp(0, double.infinity);
    if (g.savedAmount < g.targetAmount) g.isCompleted = false;
    await g.save();
    loadGoals();
  }

  // Aggregates
  double get totalSaved => goals.where((g) => !g.isCompleted).fold(0.0, (s, g) => s + g.savedAmount);
  double get totalTarget => goals.where((g) => !g.isCompleted).fold(0.0, (s, g) => s + g.targetAmount);
  int get activeCount => goals.where((g) => !g.isCompleted).length;
  int get completedCount => goals.where((g) => g.isCompleted).length;
  double get overallProgress => totalTarget > 0 ? (totalSaved / totalTarget * 100).clamp(0, 100) : 0;

  /// Goal closest to completion (by %)
  SavingsGoalModel? get nearestGoal {
    final active = goals.where((g) => !g.isCompleted).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.progress.compareTo(a.progress));
    return active.first;
  }
}