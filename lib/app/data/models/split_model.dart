import 'package:hive/hive.dart';

part 'split_model.g.dart';

@HiveType(typeId: 10)
class SplitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title; // "Dinner at Barbeque Nation"

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  String? expenseId; // linked to an existing expense, nullable

  @HiveField(4)
  String paidBy; // name of who paid

  @HiveField(5)
  List<String> participants; // list of names

  @HiveField(6)
  List<double> shares; // amount each person owes (same order as participants)

  @HiveField(7)
  List<bool> settled; // whether each person has settled (same order)

  @HiveField(8)
  String splitType; // 'equal', 'custom', 'percentage'

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  String? categoryId;

  SplitModel({
    required this.id,
    required this.title,
    required this.totalAmount,
    this.expenseId,
    required this.paidBy,
    required this.participants,
    required this.shares,
    required this.settled,
    required this.splitType,
    required this.createdAt,
    this.notes,
    this.categoryId,
  });

  double get settledAmount {
    double total = 0;
    for (int i = 0; i < participants.length; i++) {
      if (settled[i] && participants[i] != paidBy) total += shares[i];
    }
    return total;
  }

  double get pendingAmount {
    double total = 0;
    for (int i = 0; i < participants.length; i++) {
      if (!settled[i] && participants[i] != paidBy) total += shares[i];
    }
    return total;
  }

  int get settledCount => settled.where((s) => s).length;
  int get pendingCount => settled.where((s) => !s).length;
  bool get isFullySettled => settled.every((s) => s);

  /// Get the share for a specific person
  double getShareFor(String name) {
    final idx = participants.indexOf(name);
    if (idx == -1) return 0;
    return shares[idx];
  }

  /// Check if a specific person has settled
  bool isSettled(String name) {
    final idx = participants.indexOf(name);
    if (idx == -1) return false;
    return settled[idx];
  }
}