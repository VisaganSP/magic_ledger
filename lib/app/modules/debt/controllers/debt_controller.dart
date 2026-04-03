import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/debt_model.dart';

class DebtController extends GetxController {
  final Box<DebtModel> _box = Hive.box('debts');
  final RxList<DebtModel> debts = <DebtModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  void loadDebts() {
    try {
      isLoading.value = true;
      debts.value = _box.values.toList()
        ..sort((a, b) {
          if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
          return a.remainingAmount.compareTo(b.remainingAmount);
        });
    } catch (e) {
      debugPrint('Error loading debts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addDebt(DebtModel d) async {
    await _box.put(d.id, d);
    loadDebts();
  }

  Future<void> updateDebt(DebtModel d) async {
    await _box.put(d.id, d);
    loadDebts();
  }

  Future<void> deleteDebt(String id) async {
    await _box.delete(id);
    loadDebts();
  }

  /// Record an EMI payment
  Future<void> makePayment(String debtId, double amount) async {
    final d = _box.get(debtId);
    if (d == null) return;
    d.totalPaid += amount;
    if (d.totalPaid >= d.principalAmount) d.isActive = false;
    await d.save();
    loadDebts();
  }

  /// Mark debt as paid off
  Future<void> markPaidOff(String debtId) async {
    final d = _box.get(debtId);
    if (d == null) return;
    d.totalPaid = d.principalAmount;
    d.isActive = false;
    await d.save();
    loadDebts();
  }

  // ─── AGGREGATES ──────────────────────────────────────────

  List<DebtModel> get activeDebts => debts.where((d) => d.isActive).toList();

  double get totalDebt => activeDebts.fold(0.0, (s, d) => s + d.remainingAmount);
  double get totalEmiPerMonth => activeDebts.fold(0.0, (s, d) => s + d.emiAmount);
  double get totalPaid => debts.fold(0.0, (s, d) => s + d.totalPaid);
  double get totalInterest => debts.fold(0.0, (s, d) => s + d.totalInterest);

  /// Next upcoming EMI across all debts
  DebtModel? get nextEmiDue {
    final active = activeDebts.where((d) => d.nextEmiDate != null).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => a.nextEmiDate!.compareTo(b.nextEmiDate!));
    return active.first;
  }

  /// Overall debt-free date (furthest end date among active debts)
  DateTime? get debtFreeDate {
    if (activeDebts.isEmpty) return null;
    return activeDebts.map((d) => d.estimatedEndDate).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // ─── AMORTIZATION SCHEDULE ───────────────────────────────

  /// Generate amortization schedule for a debt
  List<Map<String, dynamic>> getAmortizationSchedule(DebtModel debt) {
    final schedule = <Map<String, dynamic>>[];
    double balance = debt.principalAmount;
    final monthlyRate = debt.interestRate / 12 / 100;

    for (int m = 1; m <= debt.tenureMonths; m++) {
      final interest = balance * monthlyRate;
      final principal = debt.emiAmount - interest;
      balance = math.max(0, balance - principal);

      schedule.add({
        'month': m,
        'emi': debt.emiAmount,
        'principal': principal.clamp(0, debt.emiAmount),
        'interest': interest,
        'balance': balance,
        'date': DateTime(debt.startDate.year, debt.startDate.month + m, debt.startDate.day.clamp(1, 28)),
      });

      if (balance <= 0) break;
    }
    return schedule;
  }

  /// Calculate savings from extra payment
  Map<String, dynamic> calcExtraPaymentSavings(DebtModel debt, double extraPerMonth) {
    if (extraPerMonth <= 0) return {'monthsSaved': 0, 'interestSaved': 0.0};

    final monthlyRate = debt.interestRate / 12 / 100;
    double balance = debt.remainingAmount;
    int monthsNormal = 0;
    double interestNormal = 0;

    // Normal schedule
    double tempBalance = balance;
    while (tempBalance > 0 && monthsNormal < 600) {
      final interest = tempBalance * monthlyRate;
      tempBalance -= (debt.emiAmount - interest);
      interestNormal += interest;
      monthsNormal++;
    }

    // With extra payment
    int monthsExtra = 0;
    double interestExtra = 0;
    tempBalance = balance;
    while (tempBalance > 0 && monthsExtra < 600) {
      final interest = tempBalance * monthlyRate;
      tempBalance -= (debt.emiAmount + extraPerMonth - interest);
      interestExtra += interest;
      monthsExtra++;
    }

    return {
      'monthsSaved': monthsNormal - monthsExtra,
      'interestSaved': interestNormal - interestExtra,
    };
  }

  /// Debt type display info
  static Map<String, Map<String, dynamic>> debtTypes = {
    'home_loan': {'label': 'Home Loan', 'icon': '🏠', 'color': 0xFFA7C7E7},
    'car_loan': {'label': 'Car Loan', 'icon': '🚗', 'color': 0xFF9DB4FF},
    'personal_loan': {'label': 'Personal Loan', 'icon': '💰', 'color': 0xFFFDD663},
    'credit_card': {'label': 'Credit Card', 'icon': '💳', 'color': 0xFFE57373},
    'education_loan': {'label': 'Education Loan', 'icon': '📚', 'color': 0xFFBFE3F0},
    'other': {'label': 'Other', 'icon': '🏦', 'color': 0xFFB0BEC5},
  };
}