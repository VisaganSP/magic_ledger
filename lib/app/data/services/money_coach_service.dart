import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'intent_classifier.dart';
import '../../modules/account/controllers/account_controller.dart';
import '../../modules/budget/controllers/budget_controller.dart';
import '../../modules/category/controllers/category_controller.dart';
import '../../modules/expense/controllers/expense_controller.dart';
import '../../modules/income/controllers/income_controller.dart';

/// AI Money Coach — powered by on-device TFLite intent classifier.
///
/// Flow:
/// 1. User types a question
/// 2. IntentClassifier runs TFLite model (~1ms) to detect intent
/// 3. Intent is routed to the correct handler
/// 4. Handler queries real Hive data and builds a smart response
///
/// Falls back to keyword matching if model isn't loaded.
class MoneyCoachService {
  final ExpenseController _exp = Get.find<ExpenseController>();
  final IncomeController _inc = Get.find<IncomeController>();
  final CategoryController _cat = Get.find<CategoryController>();
  final AccountController _acc = Get.find<AccountController>();
  final IntentClassifier _classifier = IntentClassifier();

  /// Initialize the classifier (call once at startup)
  Future<void> init() async {
    await _classifier.init();
  }

  bool get isModelReady => _classifier.isReady;

  double get _accountBalance => _acc.getTotalBalance();

  /// Process a user question and return a smart response
  String ask(String question) {
    final q = question.toLowerCase().trim();
    if (q.isEmpty) return _greeting();

    // ── Try TFLite classifier first ──
    final result = _classifier.classify(question);
    if (result != null && result.isConfident) {
      return _routeIntent(result.intent, q);
    }

    // ── Fallback to keyword matching ──
    return _keywordFallback(q);
  }

  /// Route classified intent to handler
  String _routeIntent(String intent, String query) {
    switch (intent) {
      case 'greeting':
        return _greeting();
      case 'affordability':
        return _affordability(query);
      case 'balance':
        return _balanceInfo();
      case 'category_spending':
        return _categorySpending(query);
      case 'comparison':
        return _comparison(query);
      case 'budget_status':
        return _budgetStatus();
      case 'income_query':
        return _incomeInfo();
      case 'savings_query':
        return _savingsInfo();
      case 'where_money_goes':
        return _whereMoneyGoes();
      case 'daily_average':
        return _dailyAverage();
      case 'projection':
        return _projection();
      case 'total_spent':
        return _totalSpent(query);
      case 'extremes':
        return _extremes(query);
      case 'today_info':
        return _todayInfo();
      case 'week_info':
        return _weekInfo();
      case 'transaction_count':
        return _transactionCount();
      case 'tips':
        return _personalizedTips();
      case 'summary':
        return _fullSummary();
      default:
        return _fullSummary();
    }
  }

  /// Keyword-based fallback when model isn't available
  String _keywordFallback(String q) {
    if (q.contains('afford') || q.contains('can i buy')) return _affordability(q);
    if (q.contains('balance') || q.contains('account')) return _balanceInfo();
    if (_hasCategoryQuery(q)) return _categorySpending(q);
    if (q.contains(' vs ') || q.contains('compare')) return _comparison(q);
    if (q.contains('budget')) return _budgetStatus();
    if (q.contains('earn') || q.contains('income') || q.contains('salary')) return _incomeInfo();
    if (q.contains('saving') || q.contains('saved')) return _savingsInfo();
    if (q.contains('where') || q.contains('bleeding') || q.contains('going')) return _whereMoneyGoes();
    if (q.contains('daily') || q.contains('average') || q.contains('per day')) return _dailyAverage();
    if (q.contains('project') || q.contains('predict') || q.contains('end of month')) return _projection();
    if (q.contains('biggest') || q.contains('largest') || q.contains('smallest')) return _extremes(q);
    if (q.contains('today')) return _todayInfo();
    if (q.contains('week')) return _weekInfo();
    if (q.contains('how many') || q.contains('count')) return _transactionCount();
    if (q.contains('tip') || q.contains('advice') || q.contains('suggest')) return _personalizedTips();
    if (q.contains('total') || q.contains('spent') || q.contains('how much')) return _totalSpent(q);
    if (q.contains('summary') || q.contains('overview') || q.contains('how am i')) return _fullSummary();
    if (q.contains('hi') || q.contains('hello') || q.contains('hey')) return _greeting();
    return _smartFallback(q);
  }

  // ═══════════════════════════════════════════════════════════
  // HANDLERS — same logic, powered by real data
  // ═══════════════════════════════════════════════════════════

  String _greeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    final ai = _classifier.isReady ? '🧠 AI-powered' : '⚡ Smart engine';

    return '$greeting! 👋\n\n'
        '$ai coach ready.\n\n'
        '• Account balance: ₹${_accountBalance.toStringAsFixed(0)}\n'
        '• Spent this month: ₹${_monthSpent().toStringAsFixed(0)}\n'
        '• Earned: ₹${_monthEarned().toStringAsFixed(0)}\n\n'
        'Ask me anything naturally:\n'
        '• "Can I afford a new phone?"\n'
        '• "Where is all my cash going?"\n'
        '• "Show me food vs transport"\n'
        '• "Am I saving enough?"';
  }

  String _balanceInfo() {
    final balance = _accountBalance;
    final accounts = _acc.accounts;
    final netFlow = _monthEarned() - _monthSpent();

    final lines = <String>['💰 Account Balance: ₹${balance.toStringAsFixed(0)}\n'];
    if (accounts.isNotEmpty) {
      lines.add('By account:');
      for (final a in accounts) {
        lines.add('  ${a.icon} ${a.name}: ₹${_acc.getAccountBalance(a.id).toStringAsFixed(0)}');
      }
    }
    lines.add('\n📊 Month net flow: ${netFlow >= 0 ? '+' : ''}₹${netFlow.toStringAsFixed(0)}');
    return lines.join('\n');
  }

  String _affordability(String q) {
    final amount = _extractAmount(q);
    if (amount == null) return 'Tell me the amount! Try "Can I afford ₹5000?"';

    final balance = _accountBalance;
    String emoji, verdict, detail;

    if (amount > balance) {
      emoji = '🚫';
      verdict = 'Not enough across all accounts.';
      detail = 'Balance: ₹${balance.toStringAsFixed(0)}. Short by ₹${(amount - balance).toStringAsFixed(0)}.';
    } else if (amount > balance * 0.5) {
      emoji = '⚠️';
      verdict = 'You can, but it\'s more than half your balance.';
      detail = 'After: ₹${(balance - amount).toStringAsFixed(0)} remaining.';
    } else if (amount > balance * 0.25) {
      emoji = '🤔';
      verdict = 'Yes, but a significant chunk.';
      detail = '₹${balance.toStringAsFixed(0)} → ₹${(balance - amount).toStringAsFixed(0)} (${((balance - amount) / balance * 100).toStringAsFixed(0)}% left).';
    } else {
      emoji = '✅';
      verdict = 'Absolutely! Fits comfortably.';
      detail = '₹${(balance - amount).toStringAsFixed(0)} remaining (${((balance - amount) / balance * 100).toStringAsFixed(0)}% of balance).';
    }

    return '$emoji ₹${amount.toStringAsFixed(0)} purchase:\n\n$verdict\n$detail\n\n'
        '💰 Balance: ₹${balance.toStringAsFixed(0)}';
  }

  String _categorySpending(String q) {
    final cat = _findCategory(q);
    if (cat == null) return _whereMoneyGoes();

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final prevStart = DateTime(now.year, now.month - 1, 1);

    final thisMonth = _exp.expenses
        .where((e) => e.categoryId == cat.id && !e.date.isBefore(monthStart))
        .fold(0.0, (s, e) => s + e.amount);
    final lastMonth = _exp.expenses
        .where((e) => e.categoryId == cat.id && !e.date.isBefore(prevStart) && e.date.isBefore(monthStart))
        .fold(0.0, (s, e) => s + e.amount);
    final txCount = _exp.expenses.where((e) => e.categoryId == cat.id && !e.date.isBefore(monthStart)).length;
    final total = _monthSpent();
    final pct = total > 0 ? (thisMonth / total * 100) : 0.0;

    String trend = '';
    if (lastMonth > 0) {
      final change = ((thisMonth - lastMonth) / lastMonth * 100);
      trend = change > 0
          ? '\n📈 Up ${change.toStringAsFixed(0)}% from last month (₹${lastMonth.toStringAsFixed(0)})'
          : '\n📉 Down ${change.abs().toStringAsFixed(0)}% from last month (₹${lastMonth.toStringAsFixed(0)})';
    }

    return '${cat.icon} ${cat.name} this month:\n\n'
        '₹${thisMonth.toStringAsFixed(0)} across $txCount transactions\n'
        '${pct.toStringAsFixed(0)}% of total spending$trend';
  }

  String _comparison(String q) {
    final found = <dynamic>[];
    for (final c in _cat.categories) {
      if (q.contains(c.name.toLowerCase())) found.add(c);
    }
    if (found.length < 2) return _monthVsMonth();

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final a = found[0], b = found[1];
    final aT = _exp.expenses.where((e) => e.categoryId == a.id && !e.date.isBefore(monthStart)).fold(0.0, (s, e) => s + e.amount);
    final bT = _exp.expenses.where((e) => e.categoryId == b.id && !e.date.isBefore(monthStart)).fold(0.0, (s, e) => s + e.amount);

    return '${a.icon} ${a.name}: ₹${aT.toStringAsFixed(0)}\n'
        '${b.icon} ${b.name}: ₹${bT.toStringAsFixed(0)}\n\n'
        '${aT > bT ? '${a.icon} ${a.name}' : '${b.icon} ${b.name}'} is higher by ₹${(aT - bT).abs().toStringAsFixed(0)}';
  }

  String _monthVsMonth() {
    final now = DateTime.now();
    final thisStart = DateTime(now.year, now.month, 1);
    final lastStart = DateTime(now.year, now.month - 1, 1);
    final thisS = _monthSpent();
    final lastS = _exp.expenses.where((e) => !e.date.isBefore(lastStart) && e.date.isBefore(thisStart)).fold(0.0, (s, e) => s + e.amount);
    final change = lastS > 0 ? ((thisS - lastS) / lastS * 100) : 0.0;

    return '📊 This month vs last:\n\n'
        'Spending: ₹${thisS.toStringAsFixed(0)} vs ₹${lastS.toStringAsFixed(0)} (${change >= 0 ? '+' : ''}${change.toStringAsFixed(0)}%)\n'
        '${change > 10 ? '⚠️ Spending is up.' : change < -10 ? '✅ Spending is down!' : '➡️ About the same.'}';
  }

  String _budgetStatus() {
    try {
      final bc = Get.find<BudgetController>();
      final active = bc.activeBudgets;
      if (active.isEmpty) return '📋 No active budgets. Set one up to track spending limits!';
      final lines = <String>['📋 Budget status:\n'];
      for (final b in active) {
        final spent = bc.getSpentAmount(b);
        final pct = bc.getPercentageUsed(b);
        final name = b.categoryId != null ? (_cat.getCategoryForExpense(b.categoryId!)?.name ?? 'Category') : 'Overall';
        lines.add('${pct >= 100 ? '🔴' : pct >= 75 ? '🟡' : '🟢'} $name: ₹${spent.toStringAsFixed(0)}/₹${b.amount.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)');
      }
      return lines.join('\n');
    } catch (_) {
      return '📋 Budget feature available — create budgets to get status updates!';
    }
  }

  String _incomeInfo() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final earned = _monthEarned();
    final sources = <String, double>{};
    for (final i in _inc.incomes.where((i) => !i.date.isBefore(monthStart))) {
      sources[i.source] = (sources[i.source] ?? 0) + i.amount;
    }
    final sourceStr = (sources.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(5).map((e) => '  • ${e.key}: ₹${e.value.toStringAsFixed(0)}').join('\n');

    return '💰 Income this month: ₹${earned.toStringAsFixed(0)}\n\n'
        '${sourceStr.isNotEmpty ? 'By source:\n$sourceStr' : 'No income recorded yet.'}';
  }

  String _savingsInfo() {
    final netFlow = _monthEarned() - _monthSpent();
    final rate = _monthEarned() > 0 ? (netFlow / _monthEarned() * 100) : 0.0;
    final grade = rate >= 50 ? 'S' : rate >= 30 ? 'A' : rate >= 20 ? 'B' : rate >= 10 ? 'C' : rate >= 0 ? 'D' : 'F';

    return '💎 Savings: ${netFlow >= 0 ? '+' : ''}₹${netFlow.toStringAsFixed(0)}\n'
        'Rate: ${rate.toStringAsFixed(0)}% (Grade: $grade)\n'
        'Balance: ₹${_accountBalance.toStringAsFixed(0)}\n\n'
        '${rate < 20 ? '💡 Target 20% — cut ₹${((_monthEarned() * 0.2) - netFlow).abs().toStringAsFixed(0)} more.' : '🎉 Above 20% benchmark!'}';
  }

  String _whereMoneyGoes() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final catTotals = <String, double>{};
    for (final e in _exp.expenses.where((e) => !e.date.isBefore(monthStart))) {
      catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
    }
    if (catTotals.isEmpty) return '📊 No expenses this month yet!';

    final sorted = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = _monthSpent();
    final lines = sorted.take(6).map((e) {
      final cat = _cat.getCategoryForExpense(e.key);
      final pct = total > 0 ? (e.value / total * 100) : 0.0;
      return '${cat.icon} ${cat.name}: ₹${e.value.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)';
    }).join('\n');

    return '📊 Where your money goes:\n\n$lines';
  }

  String _dailyAverage() {
    final now = DateTime.now();
    final avg = now.day > 0 ? _monthSpent() / now.day : 0.0;
    return '📅 Daily average: ₹${avg.toStringAsFixed(0)}/day\n'
        'Total: ₹${_monthSpent().toStringAsFixed(0)} over ${now.day} days';
  }

  String _projection() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final projected = now.day > 0 ? (_monthSpent() / now.day) * daysInMonth : 0.0;
    final earned = _monthEarned();

    return '🔮 Projected: ₹${projected.toStringAsFixed(0)} by month-end\n'
        'Income: ₹${earned.toStringAsFixed(0)}\n'
        'Balance: ₹${_accountBalance.toStringAsFixed(0)}\n\n'
        '${projected > earned && earned > 0 ? '⚠️ May overspend by ₹${(projected - earned).toStringAsFixed(0)}' : '✅ On track to save ₹${(earned - projected).toStringAsFixed(0)}'}';
  }

  String _totalSpent(String q) {
    if (q.contains('today')) return _todayInfo();
    if (q.contains('week')) return _weekInfo();
    return '💸 Spent this month: ₹${_monthSpent().toStringAsFixed(0)}\n💰 Balance: ₹${_accountBalance.toStringAsFixed(0)}';
  }

  String _extremes(String q) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final exps = _exp.expenses.where((e) => !e.date.isBefore(monthStart)).toList();
    if (exps.isEmpty) return 'No expenses this month!';

    if (q.contains('small') || q.contains('cheap') || q.contains('least')) {
      final s = exps.reduce((a, b) => a.amount < b.amount ? a : b);
      return '🔍 Smallest: "${s.title}" ₹${s.amount.toStringAsFixed(0)} on ${s.date.day}/${s.date.month}';
    }
    final b = exps.reduce((a, b) => a.amount > b.amount ? a : b);
    return '💎 Biggest: "${b.title}" ₹${b.amount.toStringAsFixed(0)} on ${b.date.day}/${b.date.month}';
  }

  String _todayInfo() {
    final now = DateTime.now();
    final exps = _exp.expenses.where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day);
    final total = exps.fold(0.0, (s, e) => s + e.amount);
    if (exps.isEmpty) return '✨ Zero spending today! Balance: ₹${_accountBalance.toStringAsFixed(0)}';
    return '📅 Today: ₹${total.toStringAsFixed(0)} (${exps.length} transactions)\n\n'
        '${exps.map((e) => '  • ${e.title}: ₹${e.amount.toStringAsFixed(0)}').join('\n')}';
  }

  String _weekInfo() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final exps = _exp.expenses.where((e) => !e.date.isBefore(start));
    final total = exps.fold(0.0, (s, e) => s + e.amount);
    return '📅 This week: ₹${total.toStringAsFixed(0)} across ${exps.length} transactions';
  }

  String _transactionCount() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final e = _exp.expenses.where((e) => !e.date.isBefore(monthStart)).length;
    final i = _inc.incomes.where((i) => !i.date.isBefore(monthStart)).length;
    return '📊 This month: $e expenses + $i incomes = ${e + i} total';
  }

  String _personalizedTips() {
    final tips = <String>[];
    final spent = _monthSpent();
    final earned = _monthEarned();
    final rate = earned > 0 ? ((earned - spent) / earned * 100) : 0.0;

    if (rate < 20 && earned > 0) tips.add('💡 Savings rate: ${rate.toStringAsFixed(0)}%. Target 20% with the 50/30/20 rule.');
    if (earned - spent < 0) tips.add('🚨 Spending exceeds income. Balance is ₹${_accountBalance.toStringAsFixed(0)} — watch the drain.');

    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final catTotals = <String, double>{};
    for (final e in _exp.expenses.where((e) => !e.date.isBefore(monthStart))) {
      catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
    }
    if (catTotals.isNotEmpty) {
      final top = catTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final cat = _cat.getCategoryForExpense(top.key);
      final pct = spent > 0 ? (top.value / spent * 100) : 0.0;
      if (pct > 40) tips.add('📊 ${cat.icon} ${cat.name} is ${pct.toStringAsFixed(0)}% of spending. Cut 10% there?');
    }

    tips.add('🎯 Daily limit: ₹${(spent / DateTime.now().day * 0.8).toStringAsFixed(0)} to save 20% more.');
    tips.add('📱 Review subscriptions — one unused ₹200/month sub = ₹2,400/year wasted.');

    return '💡 Tips:\n\n${tips.take(4).join('\n\n')}';
  }

  String _fullSummary() {
    final spent = _monthSpent();
    final earned = _monthEarned();
    final netFlow = earned - spent;
    final rate = earned > 0 ? (netFlow / earned * 100) : 0.0;

    return '📊 Monthly Overview:\n\n'
        '💰 Balance: ₹${_accountBalance.toStringAsFixed(0)}\n'
        '━━━━━━━━━━━━━━━━\n'
        'Earned: ₹${earned.toStringAsFixed(0)}\n'
        'Spent: ₹${spent.toStringAsFixed(0)}\n'
        'Net: ${netFlow >= 0 ? '+' : ''}₹${netFlow.toStringAsFixed(0)} (${rate.toStringAsFixed(0)}%)\n\n'
        '${rate >= 20 ? '✅ Great month!' : '💡 Cut spending to hit 20%.'}';
  }

  String _smartFallback(String q) {
    return '🤔 Not sure about "$q".\n\n${_fullSummary()}\n\n'
        'Try: "Can I afford ₹X?", "Where is money going?", "Tips"';
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  double _monthSpent() {
    final s = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return _exp.expenses.where((e) => !e.date.isBefore(s)).fold(0.0, (s, e) => s + e.amount);
  }

  double _monthEarned() {
    final s = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return _inc.incomes.where((i) => !i.date.isBefore(s)).fold(0.0, (s, i) => s + i.amount);
  }

  double? _extractAmount(String q) {
    final m = RegExp(r'[\₹]?\s?(\d[\d,]*\.?\d*)').firstMatch(q);
    return m != null ? double.tryParse(m.group(1)!.replaceAll(',', '')) : null;
  }

  bool _hasCategoryQuery(String q) => _cat.categories.any((c) => q.contains(c.name.toLowerCase()));

  dynamic _findCategory(String q) {
    try { return _cat.categories.firstWhere((c) => q.contains(c.name.toLowerCase())); }
    catch (_) { return null; }
  }
}