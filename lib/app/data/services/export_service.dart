import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';

/// Exports expenses and incomes as CSV files.
/// Users can share via email, WhatsApp, save to Drive, etc.
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _dateFmt = DateFormat('dd/MM/yyyy');
  final _curFmt = NumberFormat.currency(symbol: '', decimalDigits: 2);

  /// Export expenses as CSV
  Future<void> exportExpenses({
    required List<ExpenseModel> expenses,
    required List<CategoryModel> categories,
    List<AccountModel>? accounts,
    DateTime? from,
    DateTime? to,
  }) async {
    var filtered = expenses;
    if (from != null) filtered = filtered.where((e) => !e.date.isBefore(from)).toList();
    if (to != null) filtered = filtered.where((e) => !e.date.isAfter(to.add(const Duration(days: 1)))).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));

    final rows = <List<String>>[
      ['Date', 'Title', 'Amount', 'Category', 'Account', 'Description', 'Location', 'Tags', 'Recurring', 'Type'],
    ];

    for (final e in filtered) {
      final cat = categories.firstWhere((c) => c.id == e.categoryId,
          orElse: () => CategoryModel(id: '', name: 'Unknown', icon: '', color: 0, isDefault: false));
      String accName = '';
      if (accounts != null && e.accountId != null) {
        try { accName = accounts.firstWhere((a) => a.id == e.accountId).name; } catch (_) {}
      }
      rows.add([
        _dateFmt.format(e.date),
        e.title,
        _curFmt.format(e.amount),
        cat.name,
        accName,
        e.description ?? '',
        e.location ?? '',
        (e.tags ?? []).join('; '),
        e.isRecurring ? e.recurringType ?? 'yes' : '',
        'Expense',
      ]);
    }

    await _shareCSV(rows, 'magic_ledger_expenses');
  }

  /// Export incomes as CSV
  Future<void> exportIncomes({
    required List<IncomeModel> incomes,
    List<AccountModel>? accounts,
    DateTime? from,
    DateTime? to,
  }) async {
    var filtered = incomes;
    if (from != null) filtered = filtered.where((i) => !i.date.isBefore(from)).toList();
    if (to != null) filtered = filtered.where((i) => !i.date.isAfter(to.add(const Duration(days: 1)))).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));

    final rows = <List<String>>[
      ['Date', 'Title', 'Amount', 'Source', 'Account', 'Description', 'Recurring', 'Type'],
    ];

    for (final i in filtered) {
      String accName = '';
      if (accounts != null && i.accountId != null) {
        try { accName = accounts.firstWhere((a) => a.id == i.accountId).name; } catch (_) {}
      }
      rows.add([
        _dateFmt.format(i.date),
        i.title,
        _curFmt.format(i.amount),
        i.source,
        accName,
        i.description ?? '',
        i.isRecurring ? i.recurringType ?? 'yes' : '',
        'Income',
      ]);
    }

    await _shareCSV(rows, 'magic_ledger_incomes');
  }

  /// Export combined (expenses + incomes)
  Future<void> exportAll({
    required List<ExpenseModel> expenses,
    required List<IncomeModel> incomes,
    required List<CategoryModel> categories,
    List<AccountModel>? accounts,
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = <List<String>>[
      ['Date', 'Type', 'Title', 'Amount', 'Category/Source', 'Account', 'Description', 'Tags'],
    ];

    // Merge and sort by date
    final all = <Map<String, dynamic>>[];
    for (final e in expenses) {
      if (from != null && e.date.isBefore(from)) continue;
      if (to != null && e.date.isAfter(to.add(const Duration(days: 1)))) continue;
      final cat = categories.firstWhere((c) => c.id == e.categoryId,
          orElse: () => CategoryModel(id: '', name: 'Unknown', icon: '', color: 0, isDefault: false));
      all.add({'date': e.date, 'type': 'Expense', 'title': e.title, 'amount': -e.amount,
        'catSource': cat.name, 'accountId': e.accountId, 'desc': e.description ?? '',
        'tags': (e.tags ?? []).join('; ')});
    }
    for (final i in incomes) {
      if (from != null && i.date.isBefore(from)) continue;
      if (to != null && i.date.isAfter(to.add(const Duration(days: 1)))) continue;
      all.add({'date': i.date, 'type': 'Income', 'title': i.title, 'amount': i.amount,
        'catSource': i.source, 'accountId': i.accountId, 'desc': i.description ?? '', 'tags': ''});
    }

    all.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    for (final item in all) {
      String accName = '';
      if (accounts != null && item['accountId'] != null) {
        try { accName = accounts.firstWhere((a) => a.id == item['accountId']).name; } catch (_) {}
      }
      rows.add([
        _dateFmt.format(item['date']),
        item['type'],
        item['title'],
        _curFmt.format(item['amount']),
        item['catSource'],
        accName,
        item['desc'],
        item['tags'],
      ]);
    }

    await _shareCSV(rows, 'magic_ledger_all');
  }

  Future<void> _shareCSV(List<List<String>> rows, String filePrefix) async {
    try {
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final date = DateFormat('yyyyMMdd').format(DateTime.now());
      final path = '${dir.path}/${filePrefix}_$date.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'Magic Ledger Export');
    } catch (e) {
      debugPrint('Export error: $e');
      Get.snackbar('Export Failed', 'Could not generate CSV: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}