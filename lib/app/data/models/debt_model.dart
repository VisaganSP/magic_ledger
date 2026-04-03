import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 9)
class DebtModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double principalAmount;

  @HiveField(3)
  double interestRate; // Annual %

  @HiveField(4)
  double emiAmount;

  @HiveField(5)
  int tenureMonths;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  double totalPaid;

  @HiveField(8)
  String debtType; // home_loan, car_loan, personal_loan, credit_card, education_loan, other

  @HiveField(9)
  String icon;

  @HiveField(10)
  int color;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  bool isActive;

  @HiveField(13)
  String? linkedAccountId;

  @HiveField(14)
  int? emiDay; // Day of month EMI is due

  DebtModel({
    required this.id,
    required this.name,
    required this.principalAmount,
    this.interestRate = 0,
    required this.emiAmount,
    required this.tenureMonths,
    required this.startDate,
    this.totalPaid = 0,
    this.debtType = 'other',
    this.icon = '🏦',
    required this.color,
    this.notes,
    this.isActive = true,
    this.linkedAccountId,
    this.emiDay,
  });

  Color get colorValue => Color(color);

  double get remainingAmount => (principalAmount - totalPaid).clamp(0, double.infinity);

  double get progressPercent =>
      principalAmount > 0 ? (totalPaid / principalAmount * 100).clamp(0, 100) : 0;

  int get monthsPaid {
    if (emiAmount <= 0) return 0;
    return (totalPaid / emiAmount).floor();
  }

  int get monthsRemaining => (tenureMonths - monthsPaid).clamp(0, tenureMonths);

  DateTime get estimatedEndDate =>
      DateTime(startDate.year, startDate.month + tenureMonths, startDate.day);

  double get totalInterest {
    final totalPayable = emiAmount * tenureMonths;
    return (totalPayable - principalAmount).clamp(0, double.infinity);
  }

  double get totalPayable => emiAmount * tenureMonths;

  bool get isCompleted => totalPaid >= principalAmount || !isActive;

  /// Next EMI due date
  DateTime? get nextEmiDate {
    if (isCompleted) return null;
    final now = DateTime.now();
    final day = emiDay ?? startDate.day;
    var next = DateTime(now.year, now.month, day.clamp(1, 28));
    if (next.isBefore(now)) next = DateTime(now.year, now.month + 1, day.clamp(1, 28));
    return next;
  }

  /// Days until next EMI
  int? get daysUntilNextEmi {
    final next = nextEmiDate;
    if (next == null) return null;
    return next.difference(DateTime.now()).inDays;
  }
}