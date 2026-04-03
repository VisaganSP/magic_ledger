import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? categoryId; // null means overall budget

  @HiveField(2)
  double amount;

  @HiveField(3)
  String period; // monthly, weekly, yearly

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime? endDate;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String? notes;

  BudgetModel({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes,
  });
}