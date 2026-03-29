import 'package:hive/hive.dart';

part 'income_model.g.dart';

@HiveType(typeId: 5)
class IncomeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String source; // salary, freelance, investment, etc.

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? description;

  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  String? recurringType; // monthly, weekly, etc.

  // ─── NEW FIELDS (Phase 1) ────────────────────────────────

  @HiveField(8)
  String? accountId; // null = unassigned (backward compatible)

  @HiveField(9)
  String? parentRecurringId; // links auto-generated recurring entries to parent

  IncomeModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.source,
    required this.date,
    this.description,
    this.isRecurring = false,
    this.recurringType,
    this.accountId, // NEW
    this.parentRecurringId, // NEW
  });
}