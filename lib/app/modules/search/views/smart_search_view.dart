import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_card.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../../todo/controllers/todo_controller.dart';

class SmartSearchView extends StatefulWidget {
  const SmartSearchView({super.key});

  @override
  State<SmartSearchView> createState() => _SmartSearchViewState();
}

class _SmartSearchViewState extends State<SmartSearchView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildSearchHeader(isDark),
          _buildFilterChips(isDark),
          Expanded(child: _buildResults(isDark)),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        border: const Border(bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
                offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(Icons.arrow_back, size: 20,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                onChanged: (v) => setState(() => _query = v.trim()),
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
                ),
                decoration: InputDecoration(
                  hintText: 'Search anything — title, tag, amount, category...',
                  prefixIcon: Icon(Icons.search, size: 20,
                      color: isDark ? Colors.grey[500] : Colors.grey[500]),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    child: Icon(Icons.close, size: 18,
                        color: isDark ? Colors.grey[500] : Colors.grey[500]),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'key': 'all', 'label': 'ALL', 'icon': Icons.search},
      {'key': 'expenses', 'label': 'EXPENSES', 'icon': Icons.arrow_upward},
      {'key': 'incomes', 'label': 'INCOME', 'icon': Icons.arrow_downward},
      {'key': 'todos', 'label': 'TODOS', 'icon': Icons.task_alt},
      {'key': 'tags', 'label': 'TAGS', 'icon': Icons.label},
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (ctx, i) {
          final f = filters[i];
          final sel = _filter == f['key'];
          return GestureDetector(
            onTap: () => setState(() => _filter = f['key'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: sel
                  ? NeoBrutalismTheme.neoBox(
                  color: _t(NeoBrutalismTheme.accentPink, isDark),
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack)
                  : BoxDecoration(
                  color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
              child: Row(
                children: [
                  Icon(f['icon'] as IconData, size: 14,
                      color: sel ? NeoBrutalismTheme.primaryBlack
                          : (isDark ? Colors.grey[500] : Colors.grey[600])),
                  const SizedBox(width: 4),
                  Text(f['label'] as String, style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: sel ? NeoBrutalismTheme.primaryBlack
                          : (isDark ? Colors.grey[500] : Colors.grey[600]))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    if (_query.isEmpty) return _buildSuggestions(isDark);

    final results = _search();
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[200]!,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(Icons.search_off, size: 32,
                  color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text('No results for "$_query"', style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 6),
            Text('Try different keywords, a tag name, or amount',
                style: TextStyle(fontSize: 12,
                    color: isDark ? Colors.grey[600] : Colors.grey[500])),
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    // Group results by type
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final r in results) {
      grouped.putIfAbsent(r['type'] as String, () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Result count
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('${results.length} results', style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.grey[500] : Colors.grey[600])),
        ),
        // Show grouped
        ...grouped.entries.expand((entry) {
          final typeName = entry.key == 'expense' ? 'EXPENSES'
              : entry.key == 'income' ? 'INCOME'
              : entry.key == 'todo' ? 'TODOS' : entry.key.toUpperCase();
          return [
            if (grouped.length > 1) ...[
              _buildResultSection(typeName, entry.value.length, isDark),
              const SizedBox(height: 8),
            ],
            ...entry.value.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildResultCard(e.value, isDark)
                  .animate().fadeIn(delay: (30 + e.key * 20).ms),
            )),
            const SizedBox(height: 8),
          ];
        }),
      ],
    );
  }

  List<Map<String, dynamic>> _search() {
    final results = <Map<String, dynamic>>[];
    final q = _query.toLowerCase();

    // Check if query is an amount search (starts with ₹ or is a number)
    final isAmountSearch = RegExp(r'^[₹]?\d+\.?\d*$').hasMatch(_query.replaceAll(',', ''));
    double? searchAmount;
    if (isAmountSearch) {
      searchAmount = double.tryParse(_query.replaceAll('₹', '').replaceAll(',', ''));
    }

    final expCtrl = Get.find<ExpenseController>();
    final incCtrl = Get.find<IncomeController>();
    final todoCtrl = Get.find<TodoController>();
    final catCtrl = Get.find<CategoryController>();
    final accCtrl = Get.find<AccountController>();

    // Search expenses
    if (_filter == 'all' || _filter == 'expenses' || _filter == 'tags') {
      for (final e in expCtrl.expenses) {
        final cat = catCtrl.getCategoryForExpense(e.categoryId);
        final acc = accCtrl.getAccountForDisplay(e.accountId);
        final tags = e.tags ?? [];
        final tagsStr = tags.join(' ').toLowerCase();

        // Build comprehensive searchable string
        final searchable = '${e.title} ${e.description ?? ''} ${cat.name} ${cat.icon} '
            '$tagsStr ${acc.name} ${acc.bankName} ${e.location ?? ''} '
            '${e.amount.toStringAsFixed(0)} ${e.amount.toStringAsFixed(2)} '
            '${e.date.day}/${e.date.month}/${e.date.year}'.toLowerCase();

        bool match = false;

        // Tag-specific filter
        if (_filter == 'tags') {
          match = tags.any((t) => t.toLowerCase().contains(q));
        }
        // Amount search
        else if (searchAmount != null) {
          match = (e.amount - searchAmount).abs() < 1 ||
              e.amount.toStringAsFixed(0) == searchAmount.toStringAsFixed(0);
        }
        // General search
        else {
          match = searchable.contains(q);
        }

        if (match) {
          // Build subtitle with matched context
          final subtitleParts = <String>[];
          subtitleParts.add('${cat.icon} ${cat.name}');
          subtitleParts.add(acc.name);
          subtitleParts.add('${e.date.day}/${e.date.month}');
          if (tags.isNotEmpty) subtitleParts.add('🏷️ ${tags.join(", ")}');
          if (e.location != null && e.location!.isNotEmpty) subtitleParts.add('📍 ${e.location}');

          results.add({
            'type': 'expense',
            'data': e,
            'title': e.title,
            'subtitle': subtitleParts.join(' • '),
            'amount': -e.amount,
            'date': e.date,
            'tags': tags,
            'matchedTag': _filter == 'tags'
                ? tags.firstWhere((t) => t.toLowerCase().contains(q), orElse: () => '')
                : null,
          });
        }
      }
    }

    // Search incomes
    if (_filter == 'all' || _filter == 'incomes' || _filter == 'tags') {
      for (final i in incCtrl.incomes) {
        final acc = accCtrl.getAccountForDisplay(i.accountId);

        final searchable = '${i.title} ${i.source} ${i.description ?? ''} ${acc.name} ${acc.bankName} '
            '${i.amount.toStringAsFixed(0)} ${i.amount.toStringAsFixed(2)} '
            '${i.date.day}/${i.date.month}/${i.date.year}'.toLowerCase();

        bool match = false;

        if (_filter == 'tags') {
          match = false; // Incomes don't have tags typically
        } else if (searchAmount != null) {
          match = (i.amount - searchAmount).abs() < 1 ||
              i.amount.toStringAsFixed(0) == searchAmount.toStringAsFixed(0);
        } else {
          match = searchable.contains(q);
        }

        if (match) {
          results.add({
            'type': 'income',
            'data': i,
            'title': i.title,
            'subtitle': '${i.source} • ${acc.name} • ${i.date.day}/${i.date.month}',
            'amount': i.amount,
            'date': i.date,
            'tags': <String>[],
          });
        }
      }
    }

    // Search todos
    if (_filter == 'all' || _filter == 'todos' || _filter == 'tags') {
      for (final t in todoCtrl.todos) {
        final tags = t.tags ?? [];
        final tagsStr = tags.join(' ').toLowerCase();

        final searchable = '${t.title} ${t.description ?? ''} $tagsStr'.toLowerCase();

        bool match = false;

        if (_filter == 'tags') {
          match = tags.any((tag) => tag.toLowerCase().contains(q));
        } else {
          match = searchable.contains(q);
        }

        if (match) {
          final subtitleParts = <String>[];
          subtitleParts.add(t.isCompleted ? '✓ Done' : 'Pending');
          subtitleParts.add('P${t.priority}');
          if (t.dueDate != null) subtitleParts.add('Due ${t.dueDate!.day}/${t.dueDate!.month}');
          if (tags.isNotEmpty) subtitleParts.add('🏷️ ${tags.join(", ")}');

          results.add({
            'type': 'todo',
            'data': t,
            'title': t.title,
            'subtitle': subtitleParts.join(' • '),
            'amount': null,
            'date': t.dueDate ?? t.createdAt,
            'tags': tags,
          });
        }
      }
    }

    // Sort by date
    results.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return results;
  }

  Widget _buildResultSection(String title, int count, bool isDark) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[500] : Colors.grey[600])),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, bool isDark) {
    final type = result['type'] as String;
    final amount = result['amount'] as double?;
    final tags = result['tags'] as List<String>? ?? [];

    Color iconColor;
    IconData icon;
    switch (type) {
      case 'expense':
        iconColor = _t(NeoBrutalismTheme.accentOrange, isDark);
        icon = Icons.arrow_upward;
        break;
      case 'income':
        iconColor = _t(NeoBrutalismTheme.accentGreen, isDark);
        icon = Icons.arrow_downward;
        break;
      default:
        iconColor = _t(NeoBrutalismTheme.accentBlue, isDark);
        icon = Icons.task_alt;
    }

    return GestureDetector(
      onTap: () {
        switch (type) {
          case 'expense':
            Get.toNamed('/expense-detail', arguments: result['data']);
            break;
          case 'income':
            Get.toNamed('/income-detail', arguments: result['data']);
            break;
          case 'todo':
            Get.toNamed('/todo-detail', arguments: result['data']);
            break;
        }
      },
      child: NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: iconColor,
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                  ),
                  child: Icon(icon, size: 18, color: NeoBrutalismTheme.primaryBlack),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result['title'] as String, style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(result['subtitle'] as String, style: TextStyle(fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[600]),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (amount != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${amount < 0 ? '-' : '+'}₹${amount.abs().toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                        color: amount < 0
                            ? (isDark ? Colors.red[400] : Colors.red[700])
                            : (isDark ? Colors.green[400] : Colors.green[700])),
                  ),
                ],
              ],
            ),
            // Show tags if present and query matches a tag
            if (tags.isNotEmpty && (_filter == 'tags' || _query.isNotEmpty)) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: tags.map((tag) {
                  final isMatchedTag = tag.toLowerCase().contains(_query.toLowerCase());
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isMatchedTag
                          ? _t(NeoBrutalismTheme.accentYellow, isDark)
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(3),
                      border: isMatchedTag
                          ? Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)
                          : null,
                    ),
                    child: Text('🏷️ $tag', style: TextStyle(fontSize: 10,
                        fontWeight: isMatchedTag ? FontWeight.w900 : FontWeight.w600,
                        color: isMatchedTag
                            ? NeoBrutalismTheme.primaryBlack
                            : (isDark ? Colors.grey[400] : Colors.grey[600]))),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(bool isDark) {
    final expCtrl = Get.find<ExpenseController>();
    final catCtrl = Get.find<CategoryController>();

    // Collect all tags
    final allTags = <String>{};
    for (final e in expCtrl.expenses) {
      if (e.tags != null) allTags.addAll(e.tags!);
    }
    try {
      final todoCtrl = Get.find<TodoController>();
      for (final t in todoCtrl.todos) {
        if (t.tags != null) allTags.addAll(t.tags!);
      }
    } catch (_) {}

    final catNames = catCtrl.categories.map((c) => '${c.icon} ${c.name}').take(10).toList();
    final recentTitles = expCtrl.expenses.take(8).map((e) => e.title).toSet().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          if (allTags.isNotEmpty) ...[
            Text('TAGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[500] : Colors.grey[600])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: allTags.take(15).map((tag) => GestureDetector(
                onTap: () {
                  _searchCtrl.text = tag;
                  setState(() { _query = tag; _filter = 'tags'; });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: NeoBrutalismTheme.neoBox(
                    color: _t(NeoBrutalismTheme.accentYellow, isDark),
                    offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                  ),
                  child: Text('🏷️ $tag', style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Categories
          if (catNames.isNotEmpty) ...[
            Text('CATEGORIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[500] : Colors.grey[600])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: catNames.map((name) => GestureDetector(
                onTap: () {
                  _searchCtrl.text = name.split(' ').last; // Just the name, not emoji
                  setState(() { _query = name.split(' ').last; _filter = 'all'; });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: NeoBrutalismTheme.neoBox(
                    color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                    offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                  ),
                  child: Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Recent
          if (recentTitles.isNotEmpty) ...[
            Text('RECENT EXPENSES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[500] : Colors.grey[600])),
            const SizedBox(height: 8),
            ...recentTitles.map((title) => GestureDetector(
              onTap: () {
                _searchCtrl.text = title;
                setState(() { _query = title; _filter = 'all'; });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 16,
                        color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(title, style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            )),
          ],

          // Amount search hint
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[100],
              border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SEARCH TIPS', style: TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w900, letterSpacing: 0.3,
                    color: isDark ? Colors.grey[500] : Colors.grey[600])),
                const SizedBox(height: 6),
                Text('• Type a number to find by amount (e.g. "500")\n'
                    '• Search by tag name (e.g. "office", "trip")\n'
                    '• Search by category, bank, or location\n'
                    '• Use the TAGS filter to search tags only',
                    style: TextStyle(fontSize: 11, height: 1.5,
                        color: isDark ? Colors.grey[500] : Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}