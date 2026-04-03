import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 6)
class AccountModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // e.g. "SBI Savings", "HDFC Current"

  @HiveField(2)
  String bankName; // e.g. "SBI", "HDFC", "Cash"

  @HiveField(3)
  String accountType; // savings, current, cash, wallet, upi

  @HiveField(4)
  int color;

  @HiveField(5)
  String icon; // emoji icon

  @HiveField(6)
  double initialBalance;

  @HiveField(7)
  bool isDefault;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? description;

  @HiveField(10)
  bool isActive;

  AccountModel({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountType,
    required this.color,
    required this.icon,
    this.initialBalance = 0.0,
    this.isDefault = false,
    required this.createdAt,
    this.description,
    this.isActive = true,
  });

  Color get colorValue => Color(color);

  /// Display label for account type
  String get accountTypeLabel {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return 'Savings';
      case 'current':
        return 'Current';
      case 'cash':
        return 'Cash';
      case 'wallet':
        return 'Wallet';
      case 'upi':
        return 'UPI';
      case 'credit':
        return 'Credit Card';
      default:
        return accountType;
    }
  }
}