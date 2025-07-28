import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 2)
class TodoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  int priority; // 1: Low, 2: Medium, 3: High

  @HiveField(6)
  List<String>? tags;

  @HiveField(7)
  String? linkedExpenseId;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  bool hasReminder;

  @HiveField(10)
  DateTime? reminderTime;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.priority = 1,
    this.tags,
    this.linkedExpenseId,
    required this.createdAt,
    this.hasReminder = false,
    this.reminderTime,
  });
}
