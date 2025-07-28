import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String period; // monthly, weekly, yearly

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime endDate;

  @HiveField(6)
  bool isActive;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });
}
