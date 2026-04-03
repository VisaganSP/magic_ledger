import 'dart:math' as math;

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
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: Obx(() => SliverList(delegate: SliverChildListDelegate([
              _buildProductivityDashboard(isDark),
              const SizedBox(height: 16),
              _buildQuickStats(isDark),
              const SizedBox(height: 16),
              _buildFilterRow(isDark),
              const SizedBox(height: 12),
              _buildGroupedTodoList(isDark),
              const SizedBox(height: 100),
            ]))),
          ),
        ],
      ),
      floatingActionButton: _buildFab(isDark),
    );
  }

  // ─── APP BAR ─────────────────────────────────────────────

  SliverAppBar _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 90, pinned: true,
      backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
      foregroundColor: NeoBrutalismTheme.primaryBlack,
      flexibleSpace: const FlexibleSpaceBar(
        title: Text('TODOS', style: TextStyle(fontWeight: FontWeight.w900,
            fontSize: 20, color: NeoBrutalismTheme.primaryBlack)),
        titlePadding: EdgeInsets.only(left: 56, bottom: 14),
      ),
      actions: [
        Obx(() {
          final overdue = controller.overdueCount.value;
          return overdue > 0 ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
              child: Text('$overdue OVERDUE', style: const TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w900, color: Colors.white)),
            )),
          ) : const SizedBox();
        }),
      ],
    );
  }

  // ─── PRODUCTIVITY DASHBOARD ──────────────────────────────

  Widget _buildProductivityDashboard(bool isDark) {
    final progress = controller.todayProgress;
    final grade = controller.productivityGrade;
    final streakVal = controller.streak.value;
    final completed = controller.todayCompleted.value;
    final goal = controller.dailyGoal.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 5),
      child: Row(children: [
        // Progress ring
        SizedBox(width: 80, height: 80, child: CustomPaint(
          painter: _ProgressRingPainter(progress / 100, _gradeColor(grade)),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(grade, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                color: _gradeColor(grade))),
            Text('${progress.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10,
                fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
          ])),
        )),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack,
                  borderRadius: BorderRadius.circular(4)),
              child: const Text('TODAY', style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.w900, color: Colors.white)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showGoalDialog(isDark),
              child: Row(children: [
                const Icon(Icons.flag, size: 14, color: NeoBrutalismTheme.primaryBlack),
                const SizedBox(width: 4),
                Text('Goal: $goal', style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w700, color: NeoBrutalismTheme.primaryBlack)),
              ]),
            ),
          ]),
          const SizedBox(height: 8),
          Text('$completed of $goal tasks done', style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 6),
          Row(children: [
            _miniPill('\u{1F525} $streakVal day streak', const Color(0xFFFFB49A), isDark),
            const SizedBox(width: 8),
            _miniPill('${controller.pendingCount.value} pending', const Color(0xFFBFE3F0), isDark),
          ]),
        ])),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _miniPill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
          color: NeoBrutalismTheme.primaryBlack)),
    );
  }

  Color _gradeColor(String g) {
    switch (g) {
      case 'S': return const Color(0xFFFF6B9D);
      case 'A': return const Color(0xFF00CC66);
      case 'B': return const Color(0xFF4D94FF);
      case 'C': return const Color(0xFFFF8533);
      default: return Colors.grey;
    }
  }

  // ─── QUICK STATS ─────────────────────────────────────────

  Widget _buildQuickStats(bool isDark) {
    return Row(children: [
      _statChip('${controller.pendingCount.value}', 'Pending',
          Icons.pending_actions, const Color(0xFFFFB49A), isDark),
      const SizedBox(width: 10),
      _statChip('${controller.completedCount.value}', 'Done',
          Icons.check_circle, const Color(0xFFB8E994), isDark),
      const SizedBox(width: 10),
      _statChip('${controller.overdueCount.value}', 'Overdue',
          Icons.warning_amber, const Color(0xFFE57373), isDark),
    ]).animate().fadeIn(delay: 100.ms);
  }

  Widget _statChip(String val, String label, IconData icon, Color color, bool isDark) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: NeoBrutalismTheme.neoBox(color: color,
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 3),
      child: Row(children: [
        Icon(icon, size: 18, color: NeoBrutalismTheme.primaryBlack),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.5))),
        ]),
      ]),
    ));
  }

  // ─── FILTER ROW ──────────────────────────────────────────

  Widget _buildFilterRow(bool isDark) {
    return SizedBox(height: 34, child: ListView(
      scrollDirection: Axis.horizontal,
      children: ['all', 'pending', 'completed', 'overdue'].map((f) {
        final isActive = controller.selectedFilter.value == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => controller.changeFilter(f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? NeoBrutalismTheme.primaryBlack
                    : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
              ),
              child: Text(f.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white
                      : (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
            ),
          ),
        );
      }).toList(),
    )).animate().fadeIn(delay: 200.ms);
  }

  // ─── GROUPED TODO LIST ───────────────────────────────────

  Widget _buildGroupedTodoList(bool isDark) {
    final groups = controller.getGroupedTodos();

    if (groups.isEmpty) return _buildEmptyState(isDark);

    final groupColors = {
      'Overdue': const Color(0xFFE57373),
      'Today': const Color(0xFFFDD663),
      'Tomorrow': const Color(0xFFBFE3F0),
      'This week': const Color(0xFFB8E994),
      'Later': const Color(0xFFDCC9E8),
      'No date': const Color(0xFFB0BEC5),
      'Completed': const Color(0xFFD4E4D1),
    };

    final groupIcons = {
      'Overdue': Icons.warning_amber,
      'Today': Icons.today,
      'Tomorrow': Icons.calendar_today,
      'This week': Icons.date_range,
      'Later': Icons.schedule,
      'No date': Icons.remove_circle_outline,
      'Completed': Icons.check_circle,
    };

    return Column(children: groups.entries.map((entry) {
      final name = entry.key;
      final items = entry.value;
      final color = groupColors[name] ?? const Color(0xFFB0BEC5);
      final icon = groupIcons[name] ?? Icons.list;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 12),
        // Group header
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 14, color: NeoBrutalismTheme.primaryBlack),
              const SizedBox(width: 6),
              Text('${name.toUpperCase()} (${items.length})',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.primaryBlack)),
            ]),
          ),
          if (name != 'Completed' && items.length > 1) ...[
            const Spacer(),
            GestureDetector(
              onTap: () { controller.completeAll(items); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFB8E994),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
                child: const Text('DONE ALL', style: TextStyle(fontSize: 9,
                    fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildTodoCard(e.value, e.key, isDark),
        )),
      ]);
    }).toList());
  }

  // ─── TODO CARD ───────────────────────────────────────────

  Widget _buildTodoCard(TodoModel todo, int index, bool isDark) {
    final isOverdue = todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20),
        decoration: NeoBrutalismTheme.neoBox(color: const Color(0xFFB8E994),
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: const Row(children: [
          Icon(Icons.check, color: NeoBrutalismTheme.primaryBlack, size: 28),
          SizedBox(width: 8),
          Text('COMPLETE', style: TextStyle(fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
        ]),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        decoration: NeoBrutalismTheme.neoBox(color: const Color(0xFFE57373),
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          SizedBox(width: 8),
          Icon(Icons.delete, color: Colors.white, size: 28),
        ]),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          controller.toggleTodo(todo);
          return false;
        }
        return true;
      },
      onDismissed: (_) => controller.deleteTodo(todo.id),
      child: GestureDetector(
        onTap: () => Get.toNamed('/todo-detail', arguments: todo),
        child: Container(
          decoration: NeoBrutalismTheme.neoBox(
              color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
          child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            // Checkbox
            GestureDetector(
              onTap: () => controller.toggleTodo(todo),
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: todo.isCompleted
                      ? NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark)
                      : (isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: todo.isCompleted
                    ? const Icon(Icons.check, size: 16, color: NeoBrutalismTheme.primaryBlack) : null,
              ),
            ),
            const SizedBox(width: 12),

            // Priority bar
            Container(width: 4, height: 40, decoration: BoxDecoration(
                color: _priorityColor(todo.priority), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),

            // Content
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(todo.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null)),
              if (todo.description != null && todo.description!.isNotEmpty)
                Text(todo.description!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                if (todo.dueDate != null) _datePill(todo, isOverdue, isDark),
                if (todo.hasReminder) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.notifications_active, size: 12, color: Color(0xFFFF8533)),
                ],
                if (todo.tags != null && todo.tags!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text('\u{1F3F7} ${todo.tags!.length}', style: TextStyle(fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
                const Spacer(),
                _priorityBadge(todo.priority, isDark),
              ]),
            ])),

            // Snooze button (only for pending with due date)
            if (!todo.isCompleted && todo.dueDate != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showSnoozeMenu(todo, isDark),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? NeoBrutalismTheme.darkBackground : const Color(0xFFF0EEEB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
                  ),
                  child: const Icon(Icons.snooze, size: 16, color: NeoBrutalismTheme.primaryBlack),
                ),
              ),
            ],
          ])),
        ),
      ),
    ).animate().fadeIn(delay: (60 * index).ms);
  }

  Widget _datePill(TodoModel todo, bool isOverdue, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOverdue ? const Color(0xFFE57373) : const Color(0xFFBFE3F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
      ),
      child: Text('${todo.dueDate!.day}/${todo.dueDate!.month}',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
              color: isOverdue ? Colors.white : NeoBrutalismTheme.primaryBlack)),
    );
  }

  Widget _priorityBadge(int p, bool isDark) {
    final labels = {3: 'HIGH', 2: 'MED', 1: 'LOW'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _priorityColor(p), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
      child: Text(labels[p] ?? 'LOW', style: const TextStyle(fontSize: 8,
          fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
    );
  }

  Color _priorityColor(int p) {
    switch (p) { case 3: return const Color(0xFFE57373); case 2: return const Color(0xFFFDD663); default: return const Color(0xFFB8E994); }
  }

  // ─── SNOOZE MENU ─────────────────────────────────────────

  void _showSnoozeMenu(TodoModel todo, bool isDark) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
            left: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
            right: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('SNOOZE "${todo.title.toUpperCase()}"', style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w900, color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 16),
        Row(children: [
          _snoozeOption('1 HOUR', const Duration(hours: 1), todo, Icons.schedule, isDark),
          const SizedBox(width: 8),
          _snoozeOption('3 HOURS', const Duration(hours: 3), todo, Icons.access_time, isDark),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _snoozeOption('TOMORROW', const Duration(days: 1), todo, Icons.calendar_today, isDark),
          const SizedBox(width: 8),
          _snoozeOption('NEXT WEEK', const Duration(days: 7), todo, Icons.date_range, isDark),
        ]),
        const SizedBox(height: 8),
      ]),
    ));
  }

  Widget _snoozeOption(String label, Duration dur, TodoModel todo, IconData icon, bool isDark) {
    return Expanded(child: GestureDetector(
      onTap: () {
        controller.snoozeTodo(todo, dur);
        Get.back();
        Get.snackbar('Snoozed', '${todo.title} snoozed: $label',
            backgroundColor: const Color(0xFFBFE3F0),
            colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 2));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkBackground : const Color(0xFFF0EEEB),
            borderColor: NeoBrutalismTheme.primaryBlack, offset: 3),
        child: Column(children: [
          Icon(icon, size: 22, color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        ]),
      ),
    ));
  }

  // ─── EMPTY STATE ─────────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        Container(width: 80, height: 80,
          decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
              borderColor: NeoBrutalismTheme.primaryBlack, offset: 5),
          child: const Center(child: Icon(Icons.task_alt, size: 40, color: NeoBrutalismTheme.primaryBlack)),
        ),
        const SizedBox(height: 20),
        Text('NO TODOS YET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 8),
        Text('Tap + to create your first task', style: TextStyle(fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600])),
      ]),
    );
  }

  // ─── GOAL DIALOG ─────────────────────────────────────────

  void _showGoalDialog(bool isDark) {
    int goal = controller.dailyGoal.value;
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(builder: (ctx, setS) => Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('DAILY GOAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('How many tasks per day?', style: TextStyle(fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () { if (goal > 1) setS(() => goal--); },
              child: Container(width: 40, height: 40,
                  decoration: NeoBrutalismTheme.neoBox(borderColor: NeoBrutalismTheme.primaryBlack, offset: 3),
                  child: const Center(child: Icon(Icons.remove, color: NeoBrutalismTheme.primaryBlack))),
            ),
            const SizedBox(width: 20),
            Text('$goal', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () { if (goal < 20) setS(() => goal++); },
              child: Container(width: 40, height: 40,
                  decoration: NeoBrutalismTheme.neoBox(borderColor: NeoBrutalismTheme.primaryBlack, offset: 3),
                  child: const Center(child: Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack))),
            ),
          ]),
          const SizedBox(height: 24),
          NeoButton(text: 'SET GOAL', onPressed: () {
            controller.setDailyGoal(goal);
            Get.back();
          }, color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark)),
        ]),
      )),
    ));
  }

  // ─── FAB ─────────────────────────────────────────────────

  Widget _buildFab(bool isDark) {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/add-todo'),
      backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
      label: const Text('NEW TASK', style: TextStyle(fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack)),
      icon: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
    );
  }
}

// ─── PROGRESS RING PAINTER ─────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ProgressRingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background ring
    canvas.drawCircle(center, radius, Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = 8 ..color = Colors.grey.withOpacity(0.2));

    // Progress arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * progress.clamp(0, 1), false,
        Paint()..style = PaintingStyle.stroke ..strokeWidth = 8
          ..strokeCap = StrokeCap.round ..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}