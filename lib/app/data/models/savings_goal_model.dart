import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'savings_goal_model.g.dart';

@HiveType(typeId: 8)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double savedAmount;

  @HiveField(4)
  String icon;

  @HiveField(5)
  int color;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? targetDate;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  bool isCompleted;

  @HiveField(10)
  String? linkedAccountId;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    this.icon = '🎯',
    required this.color,
    required this.createdAt,
    this.targetDate,
    this.notes,
    this.isCompleted = false,
    this.linkedAccountId,
  });

  double get progress => targetAmount > 0 ? (savedAmount / targetAmount * 100).clamp(0, 100) : 0;
  double get remaining => (targetAmount - savedAmount).clamp(0, double.infinity);
  bool get isReached => savedAmount >= targetAmount;

  Color get colorValue => Color(color);

  /// Days remaining to target date
  int? get daysLeft => targetDate != null ? targetDate!.difference(DateTime.now()).inDays : null;

  /// Required daily savings to reach goal on time
  double? get dailyRequired {
    if (targetDate == null) return null;
    final days = daysLeft ?? 0;
    if (days <= 0) return remaining;
    return remaining / days;
  }
}