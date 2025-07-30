import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/todo_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_date_range_picker.dart';
import '../controllers/todo_controller.dart';

class TodoView extends GetView<TodoController> {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? NeoBrutalismTheme.darkBackground
              : NeoBrutalismTheme.primaryWhite,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-todo'),
        backgroundColor: _getThemedColor(
          NeoBrutalismTheme.accentPurple,
          isDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: const Icon(
          Icons.add,
          size: 32,
          color: NeoBrutalismTheme.primaryBlack,
        ),
      ).animate().scale(delay: 500.ms),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildStats(isDark),
            _buildFilterTabs(isDark),
            _buildDateFilterSection(isDark),
            _buildTodoList(isDark),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  // Helper method to get muted colors for dark theme
  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    if (color == NeoBrutalismTheme.accentYellow) {
      return Color(0xFFE6B800); // Slightly darker yellow
    } else if (color == NeoBrutalismTheme.accentPink) {
      return Color(0xFFE667A0); // Slightly darker pink
    } else if (color == NeoBrutalismTheme.accentBlue) {
      return Color(0xFF4D94FF); // Slightly darker blue
    } else if (color == NeoBrutalismTheme.accentGreen) {
      return Color(0xFF00CC66); // Slightly darker green
    } else if (color == NeoBrutalismTheme.accentOrange) {
      return Color(0xFFFF8533); // Slightly darker orange
    } else if (color == NeoBrutalismTheme.accentPurple) {
      return Color(0xFF9966FF); // Slightly darker purple
    }
    return color;
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        'TODOS',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color:
              isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'PENDING',
                controller.pendingCount.value.toString(),
                _getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
                Icons.pending_actions,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'COMPLETED',
                controller.completedCount.value.toString(),
                _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                Icons.check_circle,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'OVERDUE',
                controller.overdueCount.value.toString(),
                _getThemedColor(NeoBrutalismTheme.accentPink, isDark),
                Icons.warning,
                isDark,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return NeoCard(
      color: color,
      padding: const EdgeInsets.all(12),
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        children: [
          Icon(icon, size: 24, color: NeoBrutalismTheme.primaryBlack),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildFilterTab(
                'ALL',
                'all',
                controller.selectedFilter.value == 'all',
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterTab(
                'PENDING',
                'pending',
                controller.selectedFilter.value == 'pending',
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterTab(
                'COMPLETED',
                'completed',
                controller.selectedFilter.value == 'completed',
                isDark,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildFilterTab(
    String label,
    String value,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => controller.changeFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: NeoBrutalismTheme.neoBox(
          color:
              isSelected
                  ? _getThemedColor(NeoBrutalismTheme.accentBlue, isDark)
                  : (isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite),
          offset: isSelected ? 2 : 5,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color:
                  isSelected
                      ? NeoBrutalismTheme.primaryBlack
                      : (isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ),
      ),
    );
  }

  // New date filter section
  Widget _buildDateFilterSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final dateFilter = controller.dateFilter.value;
        final hasDateFilter =
            dateFilter['start'] != null || dateFilter['end'] != null;

        return GestureDetector(
          onTap: () => _showDateRangePicker(Get.context!, isDark),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: NeoBrutalismTheme.neoBox(
              color:
                  hasDateFilter
                      ? _getThemedColor(
                        Color(0xFF00FFFF),
                        isDark,
                      ).withOpacity(0.3)
                      : (isDark
                          ? NeoBrutalismTheme.darkSurface
                          : NeoBrutalismTheme.primaryWhite),
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasDateFilter
                        ? _formatDateRange(
                          dateFilter['start'],
                          dateFilter['end'],
                        )
                        : 'Filter by date range',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                ),
                if (hasDateFilter)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                    ),
                    onPressed: () => controller.clearDateFilter(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
          ),
        );
      }),
    ).animate().fadeIn(delay: 500.ms);
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'Filter by date range';

    final format = (DateTime date) => '${date.day}/${date.month}/${date.year}';

    if (start != null && end != null) {
      return '${format(start)} - ${format(end)}';
    } else if (start != null) {
      return 'From ${format(start)}';
    } else {
      return 'Until ${format(end!)}';
    }
  }

  void _showDateRangePicker(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder:
          (context) => NeoDateRangePicker(
            initialStartDate: controller.dateFilter.value['start'],
            initialEndDate: controller.dateFilter.value['end'],
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateRangeSelected: (start, end) {
              controller.setDateFilter(start, end);
            },
          ),
    );
  }

  Widget _buildTodoList(bool isDark) {
    return Obx(() {
      final todos = controller.getFilteredTodos();

      if (todos.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(), // Disable inner scroll
        shrinkWrap: true, // Allow ListView to size itself
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTodoCard(todo, index, isDark),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: 400, // Fixed height for empty state
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: NeoBrutalismTheme.neoBox(
                color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: const Icon(
                Icons.task_alt,
                size: 60,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ).animate().scale(duration: 500.ms),
            const SizedBox(height: 24),
            Text(
              'NO TODOS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color:
                    isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first todo',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            NeoButton(
              text: 'ADD TODO',
              onPressed: () => Get.toNamed('/add-todo'),
              color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(TodoModel todo, int index, bool isDark) {
    final isOverdue =
        todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    // Enhanced color scheme for better visibility
    Color cardColor = _getTodoCardColor(todo, isDark);

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: NeoBrutalismTheme.neoBox(
          color: _getThemedColor(NeoBrutalismTheme.accentPink, isDark),
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: const Icon(
          Icons.delete,
          color: NeoBrutalismTheme.primaryWhite,
          size: 32,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteTodo(todo.id);
      },
      child: NeoCard(
        color: cardColor,
        onTap: () => Get.toNamed('/todo-detail', arguments: todo),
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Row(
          children: [
            // Custom Neo Brutalism Checkbox
            GestureDetector(
              onTap: () => controller.toggleTodo(todo),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      todo.isCompleted
                          ? _getThemedColor(
                            NeoBrutalismTheme.accentGreen,
                            isDark,
                          )
                          : (isDark
                              ? NeoBrutalismTheme.darkSurface
                              : NeoBrutalismTheme.primaryWhite),
                  border: Border.all(
                    color: NeoBrutalismTheme.primaryBlack,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.black
                              : NeoBrutalismTheme.primaryBlack,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child:
                    todo.isCompleted
                        ? const Icon(
                          Icons.check,
                          size: 18,
                          color: NeoBrutalismTheme.primaryBlack,
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _getTextColor(cardColor, isDark),
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (todo.description != null &&
                      todo.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(
                          cardColor,
                          isDark,
                        ).withOpacity(0.8),
                        decoration:
                            todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (todo.dueDate != null) ...[
                        GestureDetector(
                          onTap:
                              () => _showSingleDatePicker(
                                Get.context!,
                                todo,
                                isDark,
                              ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isOverdue
                                      ? NeoBrutalismTheme.primaryWhite
                                      : _getThemedColor(
                                        NeoBrutalismTheme.accentBlue,
                                        isDark,
                                      ),
                              border: Border.all(
                                color: NeoBrutalismTheme.primaryBlack,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: NeoBrutalismTheme.primaryBlack,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${todo.dueDate!.day}/${todo.dueDate!.month}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: NeoBrutalismTheme.primaryBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (todo.hasReminder) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: NeoBrutalismTheme.primaryWhite,
                            border: Border.all(
                              color: NeoBrutalismTheme.primaryBlack,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            size: 12,
                            color: NeoBrutalismTheme.primaryBlack,
                          ),
                        ),
                      ],
                      const Spacer(),
                      _buildPriorityIndicator(todo.priority, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
  }

  void _showSingleDatePicker(
    BuildContext context,
    TodoModel todo,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => NeoDateRangePicker(
            initialStartDate: todo.dueDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
            onDateRangeSelected: (start, end) {
              if (start != null) {
                controller.updateTodoDueDate(todo, start);
              }
            },
          ),
    );
  }

  Color _getTodoCardColor(TodoModel todo, bool isDark) {
    // If completed, use bright green
    if (todo.isCompleted) {
      return _getThemedColor(NeoBrutalismTheme.accentGreen, isDark);
    }

    // Check if overdue
    final isOverdue =
        todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    if (isOverdue) {
      return _getThemedColor(NeoBrutalismTheme.accentPink, isDark);
    }

    // Priority-based colors - bright and readable
    switch (todo.priority) {
      case 3: // High priority
        return _getThemedColor(NeoBrutalismTheme.accentOrange, isDark);
      case 2: // Medium priority
        return _getThemedColor(NeoBrutalismTheme.accentYellow, isDark);
      default: // Low priority
        return isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite;
    }
  }

  Color _getTextColor(Color backgroundColor, bool isDark) {
    // For accent colors (including muted versions), always use black text
    if (backgroundColor != NeoBrutalismTheme.darkSurface &&
        backgroundColor != NeoBrutalismTheme.primaryWhite) {
      return NeoBrutalismTheme.primaryBlack;
    }

    // For dark surface or white background
    return isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack;
  }

  Widget _buildPriorityIndicator(int priority, bool isDark) {
    String label;
    Color color;

    switch (priority) {
      case 3:
        label = 'HIGH';
        color = _getThemedColor(NeoBrutalismTheme.accentPink, isDark);
        break;
      case 2:
        label = 'MED';
        color = _getThemedColor(NeoBrutalismTheme.accentOrange, isDark);
        break;
      default:
        label = 'LOW';
        color = _getThemedColor(NeoBrutalismTheme.accentGreen, isDark);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : NeoBrutalismTheme.primaryBlack,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack,
        ),
      ),
    );
  }
}
