import 'package:hive/hive.dart';

part 'transfer_model.g.dart';

@HiveType(typeId: 7)
class TransferModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fromAccountId;

  @HiveField(2)
  String toAccountId;

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? description;

  @HiveField(6)
  DateTime createdAt;

  TransferModel({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.description,
    required this.createdAt,
  });
}