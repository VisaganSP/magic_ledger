import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 11)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // "Netflix", "Spotify"

  @HiveField(2)
  double amount;

  @HiveField(3)
  String cycle; // 'monthly', 'yearly', 'weekly', 'quarterly'

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime nextRenewal;

  @HiveField(6)
  String? categoryId;

  @HiveField(7)
  String? accountId;

  @HiveField(8)
  String? icon; // emoji

  @HiveField(9)
  String? color; // hex string

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  bool autoDeducted; // auto-pay from bank

  @HiveField(13)
  String? url; // subscription management URL

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.startDate,
    required this.nextRenewal,
    this.categoryId,
    this.accountId,
    this.icon,
    this.color,
    this.isActive = true,
    this.notes,
    this.autoDeducted = false,
    this.url,
  });

  /// Monthly cost regardless of actual cycle
  double get monthlyCost {
    switch (cycle) {
      case 'weekly':
        return amount * 4.33;
      case 'quarterly':
        return amount / 3;
      case 'yearly':
        return amount / 12;
      default:
        return amount;
    }
  }

  /// Yearly cost regardless of actual cycle
  double get yearlyCost {
    switch (cycle) {
      case 'weekly':
        return amount * 52;
      case 'monthly':
        return amount * 12;
      case 'quarterly':
        return amount * 4;
      default:
        return amount;
    }
  }

  /// Days until next renewal
  int get daysUntilRenewal {
    return nextRenewal.difference(DateTime.now()).inDays;
  }

  /// Is renewal coming up within N days?
  bool isRenewingSoon({int days = 7}) {
    return daysUntilRenewal <= days && daysUntilRenewal >= 0;
  }

  /// Is overdue (past renewal date)?
  bool get isOverdue => nextRenewal.isBefore(DateTime.now());

  /// Calculate next renewal from current
  DateTime calculateNextRenewal() {
    var next = nextRenewal;
    final now = DateTime.now();
    while (next.isBefore(now)) {
      switch (cycle) {
        case 'weekly':
          next = next.add(const Duration(days: 7));
          break;
        case 'quarterly':
          next = DateTime(next.year, next.month + 3, next.day);
          break;
        case 'yearly':
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        default:
          next = DateTime(next.year, next.month + 1, next.day);
      }
    }
    return next;
  }
}