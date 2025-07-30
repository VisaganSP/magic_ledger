import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../theme/neo_brutalism_theme.dart';
import '../widgets/neo_button.dart';

class NeoDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;
  final DateTime firstDate;
  final DateTime lastDate;

  const NeoDateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  State<NeoDateRangePicker> createState() => _NeoDateRangePickerState();
}

class _NeoDateRangePickerState extends State<NeoDateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _currentMonth;
  final _monthPageController = PageController();

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _currentMonth = DateTime(
      _startDate?.year ?? DateTime.now().year,
      _startDate?.month ?? DateTime.now().month,
    );
  }

  // Helper method to get muted colors for dark theme
  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    final hslColor = HSLColor.fromColor(color);

    // Reduce lightness and saturation for dark theme
    final mutedHsl = hslColor
        .withLightness((hslColor.lightness * 0.8).clamp(0.0, 1.0))
        .withSaturation((hslColor.saturation * 0.85).clamp(0.0, 1.0));

    return mutedHsl.toColor();
  }

  // Define specific colors for the date picker
  Color _getHeaderColor(bool isDark) {
    // Use a specific blue that works well in both themes
    final blue = Color(0xFF5DADE2);
    return isDark ? Color(0xFF4D94FF) : blue;
  }

  Color _getSelectionColor(bool isDark) {
    // Use cyan for date selection
    final cyan = Color(0xFF00FFFF);
    return isDark ? Color(0xFF00CCCC) : cyan;
  }

  Color _getSuccessColor(bool isDark) {
    // Use green for selected dates and save button
    final green = Color(0xFF4ADE80);
    return isDark ? Color(0xFF00CC66) : green;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Make dialog responsive to screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 450 ? screenWidth * 0.9 : 400.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 450 ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: NeoBrutalismTheme.neoBox(
          color:
              isDark
                  ? NeoBrutalismTheme.darkBackground
                  : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack,
          offset: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark),
            _buildDateRangeDisplay(isDark),
            _buildCalendar(isDark),
            _buildActions(isDark),
          ],
        ),
      ).animate().scale(duration: 200.ms),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getHeaderColor(isDark),
        border: Border(
          bottom: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'SELECT DATE RANGE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: NeoBrutalismTheme.primaryBlack),
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeDisplay(bool isDark) {
    final startText =
        _startDate != null
            ? '${_startDate!.day} ${_getMonthName(_startDate!.month)}'
            : 'Start date';
    final endText =
        _endDate != null
            ? '${_endDate!.day} ${_getMonthName(_endDate!.month)}'
            : 'End date';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: NeoBrutalismTheme.neoBox(
                color:
                    _startDate != null
                        ? _getSuccessColor(isDark)
                        : (isDark
                            ? NeoBrutalismTheme.darkSurface
                            : NeoBrutalismTheme.primaryWhite),
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color:
                        _startDate != null
                            ? NeoBrutalismTheme.primaryBlack
                            : (isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      startText,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color:
                            _startDate != null
                                ? NeoBrutalismTheme.primaryBlack
                                : (isDark
                                    ? NeoBrutalismTheme.darkText
                                    : NeoBrutalismTheme.primaryBlack),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              size: 20,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: NeoBrutalismTheme.neoBox(
                color:
                    _endDate != null
                        ? _getSuccessColor(isDark)
                        : (isDark
                            ? NeoBrutalismTheme.darkSurface
                            : NeoBrutalismTheme.primaryWhite),
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color:
                        _endDate != null
                            ? NeoBrutalismTheme.primaryBlack
                            : (isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      endText,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color:
                            _endDate != null
                                ? NeoBrutalismTheme.primaryBlack
                                : (isDark
                                    ? NeoBrutalismTheme.darkText
                                    : NeoBrutalismTheme.primaryBlack),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthSelector(isDark),
          const SizedBox(height: 16),
          _buildWeekDays(isDark),
          const SizedBox(height: 8),
          _buildCalendarGrid(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(
            Icons.chevron_left,
            color:
                isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
          ),
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(8),
        ),
        Flexible(
          child: Text(
            '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: Icon(
            Icons.chevron_right,
            color:
                isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
          ),
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(8),
        ),
      ],
    );
  }

  Widget _buildWeekDays(bool isDark) {
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          weekDays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Add days of month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      dayWidgets.add(_buildDayCell(date, isDark));
    }

    // Calculate the number of rows needed
    final totalCells = startingWeekday + lastDayOfMonth.day;
    final rows = (totalCells / 7).ceil();

    return Container(
      height: rows * 48.0, // Dynamic height based on number of rows
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildDayCell(DateTime date, bool isDark) {
    final isSelected = _isDateSelected(date);
    final isInRange = _isDateInRange(date);
    final isToday = isSameDay(date, DateTime.now());
    final isDisabled =
        date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

    Color backgroundColor;
    Color textColor;
    BoxDecoration? decoration;

    if (isDisabled) {
      backgroundColor = Colors.transparent;
      textColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;
    } else if (isSelected) {
      backgroundColor = _getSelectionColor(isDark);
      textColor = NeoBrutalismTheme.primaryBlack;
      decoration = BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
      );
    } else if (isInRange) {
      backgroundColor = _getSelectionColor(isDark).withOpacity(0.3);
      textColor =
          isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack;
    } else {
      backgroundColor = Colors.transparent;
      textColor =
          isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _selectDate(date),
      child: Container(
        decoration:
            decoration ??
            BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected || isToday ? FontWeight.w900 : FontWeight.w600,
                color: textColor,
              ),
            ),
            if (isToday && !isSelected)
              Positioned(
                bottom: 2,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Color(0xFFE667A0) // Muted pink for dark theme
                            : NeoBrutalismTheme.accentPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: NeoButton(
              text: 'CANCEL',
              onPressed: () => Get.back(),
              color:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
              textColor:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
              width: 100,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: NeoButton(
              text: 'SAVE',
              onPressed: () {
                widget.onDateRangeSelected(_startDate, _endDate);
                Get.back();
              },
              color: _getSuccessColor(isDark),
              textColor: NeoBrutalismTheme.primaryBlack,
              width: 100,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start new selection
        _startDate = date;
        _endDate = null;
      } else if (date.isBefore(_startDate!)) {
        // Selected date is before start date, make it the new start
        _endDate = _startDate;
        _startDate = date;
      } else {
        // Set end date
        _endDate = date;
      }
    });
  }

  bool _isDateSelected(DateTime date) {
    return (_startDate != null && isSameDay(date, _startDate!)) ||
        (_endDate != null && isSameDay(date, _endDate!));
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
        date.isBefore(_endDate!.add(Duration(days: 1)));
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }
}

// Usage example in your analytics view or wherever you need it:
void showNeoDateRangePicker(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => NeoDateRangePicker(
          initialStartDate: DateTime.now().subtract(Duration(days: 30)),
          initialEndDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateRangeSelected: (start, end) {
            if (start != null && end != null) {
              // Handle the selected date range
              print('Selected range: $start to $end');
              // Update your controller or state
            }
          },
        ),
  );
}
