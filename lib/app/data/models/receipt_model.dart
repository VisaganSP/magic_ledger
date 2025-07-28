import 'package:hive/hive.dart';

part 'receipt_model.g.dart';

@HiveType(typeId: 4)
class ReceiptModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String expenseId;

  @HiveField(2)
  String imagePath;

  @HiveField(3)
  DateTime uploadDate;

  @HiveField(4)
  String? extractedText;

  @HiveField(5)
  Map<String, dynamic>? extractedData;

  ReceiptModel({
    required this.id,
    required this.expenseId,
    required this.imagePath,
    required this.uploadDate,
    this.extractedText,
    this.extractedData,
  });
}
