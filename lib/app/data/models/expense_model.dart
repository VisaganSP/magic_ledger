import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? description;

  @HiveField(6)
  String? receiptPath;

  @HiveField(7)
  List<String>? tags;

  @HiveField(8)
  String? location;

  @HiveField(9)
  bool isRecurring;

  @HiveField(10)
  String? recurringType; // daily, weekly, monthly

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.description,
    this.receiptPath,
    this.tags,
    this.location,
    this.isRecurring = false,
    this.recurringType,
  });
}
