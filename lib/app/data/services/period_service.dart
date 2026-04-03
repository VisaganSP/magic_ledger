import 'package:get/get.dart';

/// Manages the currently selected time period across the app.
/// Used by HomeController, AnalyticsController, etc. to filter data.
class PeriodService extends GetxService {
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  /// Whether we're viewing the current month
  bool get isCurrentPeriod {
    final now = DateTime.now();
    return selectedYear.value == now.year &&
        selectedMonth.value == now.month;
  }

  /// Start of the selected month
  DateTime get periodStart =>
      DateTime(selectedYear.value, selectedMonth.value, 1);

  /// End of the selected month (last day, 23:59:59)
  DateTime get periodEnd =>
      DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);

  /// Start of the previous month relative to selected
  DateTime get previousPeriodStart {
    final prev = DateTime(selectedYear.value, selectedMonth.value - 1, 1);
    return prev;
  }

  /// End of the previous month relative to selected
  DateTime get previousPeriodEnd {
    return DateTime(selectedYear.value, selectedMonth.value, 0, 23, 59, 59);
  }

  /// Navigate to next month
  void nextMonth() {
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value++;
    } else {
      selectedMonth.value++;
    }
  }

  /// Navigate to previous month
  void previousMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value--;
    } else {
      selectedMonth.value--;
    }
  }

  /// Jump to current month
  void goToCurrentMonth() {
    final now = DateTime.now();
    selectedYear.value = now.year;
    selectedMonth.value = now.month;
  }

  /// Jump to a specific month/year
  void goTo(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
  }

  /// Whether we can navigate forward (don't go past current month)
  bool get canGoForward {
    final now = DateTime.now();
    if (selectedYear.value < now.year) return true;
    if (selectedYear.value == now.year && selectedMonth.value < now.month) {
      return true;
    }
    return false;
  }

  /// Month name for display
  String get monthName => _monthNames[selectedMonth.value - 1];

  /// Short month name
  String get monthNameShort => _monthNamesShort[selectedMonth.value - 1];

  /// "March 2026" style display
  String get periodLabel => '$monthName ${selectedYear.value}';

  /// "Mar 2026" style display
  String get periodLabelShort => '$monthNameShort ${selectedYear.value}';

  /// Previous period label for comparison display
  String get previousPeriodLabel {
    final prevMonth = selectedMonth.value == 1 ? 12 : selectedMonth.value - 1;
    final prevYear =
    selectedMonth.value == 1 ? selectedYear.value - 1 : selectedYear.value;
    return '${_monthNamesShort[prevMonth - 1]} $prevYear';
  }

  // ─── WEEK HELPERS ────────────────────────────────────────

  /// Get the start of the current week (Monday)
  DateTime get currentWeekStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  /// Get the start of last week
  DateTime get lastWeekStart => currentWeekStart.subtract(const Duration(days: 7));

  /// Get the end of last week
  DateTime get lastWeekEnd =>
      currentWeekStart.subtract(const Duration(days: 1));

  // ─── YEAR HELPERS ────────────────────────────────────────

  DateTime get yearStart => DateTime(selectedYear.value, 1, 1);

  DateTime get yearEnd => DateTime(selectedYear.value, 12, 31, 23, 59, 59);

  DateTime get previousYearStart => DateTime(selectedYear.value - 1, 1, 1);

  DateTime get previousYearEnd =>
      DateTime(selectedYear.value - 1, 12, 31, 23, 59, 59);

  // ─── PRIVATE ─────────────────────────────────────────────

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _monthNamesShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}