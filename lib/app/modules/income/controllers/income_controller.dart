import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/income_model.dart';
import '../../../data/services/notification_service.dart';

class IncomeController extends GetxController {
  final Box<IncomeModel> _incomeBox = Hive.box('income');
  final RxList<IncomeModel> incomes = <IncomeModel>[].obs;
  final NotificationService _notificationService = NotificationService();

  // Loading state
  final RxBool isLoading = false.obs;

  // Error handling
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadIncomes();
    checkRecurringIncomes();
  }

  void loadIncomes() {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      incomes.value =
          _incomeBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error loading incomes: $e');
      errorMessage.value = 'Failed to load incomes';
      incomes.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addIncome(IncomeModel income) async {
    try {
      await _incomeBox.put(income.id, income);
      loadIncomes();

      // Show notification
      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Income Added',
        body: '${income.title}: ₹${income.amount.toStringAsFixed(2)}',
      );
    } catch (e) {
      print('Error adding income: $e');
      Get.snackbar(
        'Error',
        'Failed to add income. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateIncome(IncomeModel income) async {
    try {
      await _incomeBox.put(income.id, income);
      loadIncomes();

      // Show notification
      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Income Updated',
        body: '${income.title} has been updated',
      );
    } catch (e) {
      print('Error updating income: $e');
      Get.snackbar(
        'Error',
        'Failed to update income. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      await _incomeBox.delete(id);
      loadIncomes();
    } catch (e) {
      print('Error deleting income: $e');
      Get.snackbar(
        'Error',
        'Failed to delete income. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Date range calculations
  double getTotalIncomeByDateRange(DateTime start, DateTime end) {
    try {
      return incomes
          .where(
            (income) =>
                income.date.isAfter(start.subtract(const Duration(days: 1))) &&
                income.date.isBefore(end.add(const Duration(days: 1))),
          )
          .fold(0.0, (sum, income) => sum + income.amount);
    } catch (e) {
      print('Error getting total income by date range: $e');
      return 0.0;
    }
  }

  // Recurring income handling
  void checkRecurringIncomes() {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final recurringIncomes = incomes.where((i) => i.isRecurring).toList();

      for (final income in recurringIncomes) {
        if (income.recurringType == null) continue;

        switch (income.recurringType!.toLowerCase()) {
          case 'daily':
            _handleDailyRecurringIncome(income, today);
            break;
          case 'weekly':
            _handleWeeklyRecurringIncome(income, today);
            break;
          case 'monthly':
            _handleMonthlyRecurringIncome(income, today);
            break;
          case 'yearly':
            _handleYearlyRecurringIncome(income, today);
            break;
        }
      }
    } catch (e) {
      print('Error checking recurring incomes: $e');
    }
  }

  void _handleDailyRecurringIncome(IncomeModel income, DateTime today) {
    final lastIncomeDate = DateTime(
      income.date.year,
      income.date.month,
      income.date.day,
    );

    if (lastIncomeDate.isBefore(today)) {
      final daysDifference = today.difference(lastIncomeDate).inDays;

      // Create missing daily incomes
      for (int i = 1; i <= daysDifference; i++) {
        final newDate = lastIncomeDate.add(Duration(days: i));
        _createRecurringIncome(income, newDate);
      }
    }
  }

  void _handleWeeklyRecurringIncome(IncomeModel income, DateTime today) {
    final lastIncomeDate = DateTime(
      income.date.year,
      income.date.month,
      income.date.day,
    );

    if (lastIncomeDate.isBefore(today)) {
      final weeksDifference = today.difference(lastIncomeDate).inDays ~/ 7;

      // Create missing weekly incomes
      for (int i = 1; i <= weeksDifference; i++) {
        final newDate = lastIncomeDate.add(Duration(days: i * 7));
        if (newDate.isBefore(today) || newDate.isAtSameMomentAs(today)) {
          _createRecurringIncome(income, newDate);
        }
      }
    }
  }

  void _handleMonthlyRecurringIncome(IncomeModel income, DateTime today) {
    final lastIncomeDate = DateTime(
      income.date.year,
      income.date.month,
      income.date.day,
    );

    // Calculate months difference
    int monthsDiff =
        (today.year - lastIncomeDate.year) * 12 +
        (today.month - lastIncomeDate.month);

    if (monthsDiff > 0) {
      for (int i = 1; i <= monthsDiff; i++) {
        var newDate = DateTime(
          lastIncomeDate.year,
          lastIncomeDate.month + i,
          lastIncomeDate.day,
        );

        // Handle month overflow
        while (newDate.month > 12) {
          newDate = DateTime(newDate.year + 1, newDate.month - 12, newDate.day);
        }

        if (newDate.isBefore(today) || newDate.isAtSameMomentAs(today)) {
          _createRecurringIncome(income, newDate);
        }
      }
    }
  }

  void _handleYearlyRecurringIncome(IncomeModel income, DateTime today) {
    final lastIncomeDate = DateTime(
      income.date.year,
      income.date.month,
      income.date.day,
    );

    final yearsDiff = today.year - lastIncomeDate.year;

    if (yearsDiff > 0) {
      for (int i = 1; i <= yearsDiff; i++) {
        final newDate = DateTime(
          lastIncomeDate.year + i,
          lastIncomeDate.month,
          lastIncomeDate.day,
        );

        if (newDate.isBefore(today) || newDate.isAtSameMomentAs(today)) {
          _createRecurringIncome(income, newDate);
        }
      }
    }
  }

  void _createRecurringIncome(IncomeModel baseIncome, DateTime date) {
    // Check if income already exists for this date
    final existingIncome = incomes.any(
      (i) =>
          i.title == baseIncome.title &&
          i.amount == baseIncome.amount &&
          i.source == baseIncome.source &&
          _isSameDay(i.date, date),
    );

    if (!existingIncome) {
      final newIncome = IncomeModel(
        id: '${baseIncome.id}_${date.millisecondsSinceEpoch}',
        title: baseIncome.title,
        amount: baseIncome.amount,
        source: baseIncome.source,
        date: date,
        description: baseIncome.description,
        isRecurring: true,
        recurringType: baseIncome.recurringType,
      );

      // Add without notification to avoid spam
      _incomeBox.put(newIncome.id, newIncome);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Filter methods
  List<IncomeModel> getTodayIncomes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return incomes.where((income) => _isSameDay(income.date, today)).toList();
  }

  List<IncomeModel> getThisWeekIncomes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return incomes.where((income) {
      final incomeDate = DateTime(
        income.date.year,
        income.date.month,
        income.date.day,
      );
      return incomeDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          incomeDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  List<IncomeModel> getThisMonthIncomes() {
    final now = DateTime.now();
    return incomes
        .where(
          (income) =>
              income.date.year == now.year && income.date.month == now.month,
        )
        .toList();
  }

  List<IncomeModel> getIncomesBySource(String source) {
    try {
      return incomes
          .where((i) => i.source.toLowerCase() == source.toLowerCase())
          .toList();
    } catch (e) {
      print('Error getting incomes by source: $e');
      return [];
    }
  }

  List<IncomeModel> getIncomesByDateRange(DateTime start, DateTime end) {
    try {
      return incomes
          .where(
            (i) =>
                i.date.isAfter(start.subtract(const Duration(days: 1))) &&
                i.date.isBefore(end.add(const Duration(days: 1))),
          )
          .toList();
    } catch (e) {
      print('Error getting incomes by date range: $e');
      return [];
    }
  }

  double getTotalIncomeBySource(String source) {
    try {
      return getIncomesBySource(source).fold(0.0, (sum, i) => sum + i.amount);
    } catch (e) {
      print('Error getting total income by source: $e');
      return 0.0;
    }
  }

  Map<String, double> getSourceWiseIncomes() {
    try {
      final Map<String, double> sourceIncomes = {};

      for (final income in incomes) {
        sourceIncomes[income.source] =
            (sourceIncomes[income.source] ?? 0) + income.amount;
      }

      return sourceIncomes;
    } catch (e) {
      print('Error getting source wise incomes: $e');
      return {};
    }
  }

  // Statistics
  Map<String, dynamic> getIncomeStats() {
    try {
      final now = DateTime.now();
      final thisMonth = getThisMonthIncomes();
      final thisWeek = getThisWeekIncomes();
      final today = getTodayIncomes();
      final thisYear = incomes.where((i) => i.date.year == now.year).toList();

      // Calculate last month for comparison
      final lastMonth = DateTime(now.year, now.month - 1);
      final lastMonthIncomes =
          incomes
              .where(
                (i) =>
                    i.date.year == lastMonth.year &&
                    i.date.month == lastMonth.month,
              )
              .toList();

      final thisMonthTotal = thisMonth.fold(0.0, (sum, i) => sum + i.amount);
      final lastMonthTotal = lastMonthIncomes.fold(
        0.0,
        (sum, i) => sum + i.amount,
      );

      return {
        'total': incomes.fold(0.0, (sum, i) => sum + i.amount),
        'thisMonth': thisMonthTotal,
        'thisWeek': thisWeek.fold(0.0, (sum, i) => sum + i.amount),
        'today': today.fold(0.0, (sum, i) => sum + i.amount),
        'thisYear': thisYear.fold(0.0, (sum, i) => sum + i.amount),
        'count': incomes.length,
        'thisMonthCount': thisMonth.length,
        'averageIncome':
            incomes.isNotEmpty
                ? incomes.fold(0.0, (sum, i) => sum + i.amount) / incomes.length
                : 0.0,
        'recurringCount': incomes.where((i) => i.isRecurring).length,
        'oneTimeCount': incomes.where((i) => !i.isRecurring).length,
        'monthlyGrowth':
            lastMonthTotal > 0
                ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
                : 0.0,
        'topSource': _getTopSource(),
        'sourcesCount': getSourceWiseIncomes().length,
      };
    } catch (e) {
      print('Error getting income stats: $e');
      return {
        'total': 0.0,
        'thisMonth': 0.0,
        'thisWeek': 0.0,
        'today': 0.0,
        'thisYear': 0.0,
        'count': 0,
        'thisMonthCount': 0,
        'averageIncome': 0.0,
        'recurringCount': 0,
        'oneTimeCount': 0,
        'monthlyGrowth': 0.0,
        'topSource': 'N/A',
        'sourcesCount': 0,
      };
    }
  }

  String _getTopSource() {
    final sourceIncomes = getSourceWiseIncomes();
    if (sourceIncomes.isEmpty) return 'N/A';

    return sourceIncomes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Search functionality
  List<IncomeModel> searchIncomes(String query) {
    if (query.isEmpty) return incomes;

    final lowerQuery = query.toLowerCase();
    return incomes
        .where(
          (income) =>
              income.title.toLowerCase().contains(lowerQuery) ||
              income.source.toLowerCase().contains(lowerQuery) ||
              (income.description?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }
}
