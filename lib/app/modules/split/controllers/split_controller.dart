import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/split_model.dart';

class SplitController extends GetxController {
  final Box<SplitModel> _splitBox = Hive.box('splits');
  final RxList<SplitModel> splits = <SplitModel>[].obs;
  final RxBool isLoading = false.obs;

  // Stats
  final RxDouble totalOwedToYou = 0.0.obs;
  final RxDouble totalYouOwe = 0.0.obs;
  final RxInt activeSplits = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSplits();
  }

  void loadSplits() {
    try {
      isLoading.value = true;
      splits.value = _splitBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _calculateStats();
    } catch (e) {
      debugPrint('Error loading splits: $e');
      splits.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    double owed = 0;
    double owe = 0;
    int active = 0;

    for (final s in splits) {
      if (!s.isFullySettled) active++;
      owed += s.pendingAmount;
    }

    totalOwedToYou.value = owed;
    totalYouOwe.value = owe;
    activeSplits.value = active;
  }

  Future<void> addSplit(SplitModel split) async {
    await _splitBox.put(split.id, split);
    loadSplits();
  }

  Future<void> updateSplit(SplitModel split) async {
    await _splitBox.put(split.id, split);
    loadSplits();
  }

  Future<void> deleteSplit(String id) async {
    await _splitBox.delete(id);
    loadSplits();
  }

  Future<void> toggleSettled(String splitId, int participantIndex) async {
    final split = _splitBox.get(splitId);
    if (split == null) return;

    final newSettled = List<bool>.from(split.settled);
    newSettled[participantIndex] = !newSettled[participantIndex];

    final updated = SplitModel(
      id: split.id,
      title: split.title,
      totalAmount: split.totalAmount,
      expenseId: split.expenseId,
      paidBy: split.paidBy,
      participants: split.participants,
      shares: split.shares,
      settled: newSettled,
      splitType: split.splitType,
      createdAt: split.createdAt,
      notes: split.notes,
      categoryId: split.categoryId,
    );

    await _splitBox.put(splitId, updated);
    loadSplits();
  }

  /// Calculate equal split amounts
  static List<double> calculateEqualSplit(double total, int count) {
    if (count <= 0) return [];
    final share = total / count;
    return List.filled(count, double.parse(share.toStringAsFixed(2)));
  }

  /// Calculate percentage-based split
  static List<double> calculatePercentageSplit(
      double total, List<double> percentages) {
    return percentages
        .map((p) => double.parse((total * p / 100).toStringAsFixed(2)))
        .toList();
  }

  List<SplitModel> get pendingSplits =>
      splits.where((s) => !s.isFullySettled).toList();

  List<SplitModel> get settledSplits =>
      splits.where((s) => s.isFullySettled).toList();

  /// Get all unique participant names across all splits
  List<String> get allParticipants {
    final names = <String>{};
    for (final s in splits) {
      names.addAll(s.participants);
    }
    return names.toList()..sort();
  }
}