import 'dart:math' as math;

import 'package:flutter/material.dart' show Color;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/todo_model.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');
  final NumberFormat _curFmt = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 0);
  final NumberFormat _curFmtDec = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 2);

  static const _black = PdfColor.fromInt(0xFF000000);
  static const _white = PdfColor.fromInt(0xFFFFFFFF);
  static const _offWhite = PdfColor.fromInt(0xFFFAF8F6);
  static const _lightGrey = PdfColor.fromInt(0xFFF0EEEB);
  static const _midGrey = PdfColor.fromInt(0xFFB0AEA8);
  static const _darkGrey = PdfColor.fromInt(0xFF3D3D3A);
  static const _pink = PdfColor.fromInt(0xFFFDB5D6);
  static const _orange = PdfColor.fromInt(0xFFFFB49A);
  static const _green = PdfColor.fromInt(0xFFB8E994);
  static const _blue = PdfColor.fromInt(0xFF9DB4FF);
  static const _purple = PdfColor.fromInt(0xFFFDD663);
  static const _skyBlue = PdfColor.fromInt(0xFFBFE3F0);
  static const _sage = PdfColor.fromInt(0xFFD4E4D1);
  static const _lilac = PdfColor.fromInt(0xFFDCC9E8);
  static const _beige = PdfColor.fromInt(0xFFF5E6D3);
  static const _red = PdfColor.fromInt(0xFFE57373);

  late pw.Font _bold;
  late pw.Font _regular;

  Future<void> _loadFonts() async {
    final boldData = await rootBundle.load('fonts/SpaceGrotesk-Bold.ttf');
    _bold = pw.Font.ttf(boldData);
    final regData = await rootBundle.load('fonts/SpaceGrotesk-Regular.ttf');
    _regular = pw.Font.ttf(regData);
  }

  Future<void> generateAnalyticsReport(
      List<ExpenseModel> expenses,
      List<CategoryModel> categories,
      String period, {
        List<IncomeModel>? incomes,
        List<AccountModel>? accounts,
        double? prevPeriodSpent,
        double? prevPeriodEarned,
        double? projectedMonthEnd,
        double? spendingVelocity,
        int? daysRemaining,
      }) async {
    await _loadFonts();
    final pdf = pw.Document();
    final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
    final totalEarned = (incomes ?? []).fold(0.0, (s, i) => s + i.amount);
    final netFlow = totalEarned - totalSpent;
    final expCount = expenses.length;
    final incCount = (incomes ?? []).length;
    final avgExpense = expCount > 0 ? totalSpent / expCount : 0.0;
    final savingsRate = totalEarned > 0 ? (netFlow / totalEarned * 100) : 0.0;
    final categoryData = _calcCategoryData(expenses, categories, totalSpent);
    final monthlyExpData = _calcMonthlyData(expenses);
    final monthlyIncData = incomes != null ? _calcMonthlyIncomeData(incomes) : <String, double>{};
    final topExpenses = (List<ExpenseModel>.from(expenses)..sort((a, b) => b.amount.compareTo(a.amount))).take(10).toList();
    final accountBreakdown = _calcAccountBreakdown(expenses, incomes ?? [], accounts ?? []);
    final spendChange = (prevPeriodSpent != null && prevPeriodSpent > 0) ? ((totalSpent - prevPeriodSpent) / prevPeriodSpent * 100) : null;
    final incChange = (prevPeriodEarned != null && prevPeriodEarned > 0) ? ((totalEarned - prevPeriodEarned) / prevPeriodEarned * 100) : null;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (ctx) => [
        _header(period),
        pw.SizedBox(height: 20),
        _financialSummary(totalSpent, totalEarned, netFlow, savingsRate, expCount, incCount),
        pw.SizedBox(height: 20),
        if (spendChange != null || incChange != null) _comparisonSection(spendChange, incChange, prevPeriodSpent ?? 0, prevPeriodEarned ?? 0),
        if (spendChange != null || incChange != null) pw.SizedBox(height: 20),
        if (projectedMonthEnd != null && projectedMonthEnd > 0) _projectionSection(projectedMonthEnd, spendingVelocity ?? 0, daysRemaining ?? 0),
        if (projectedMonthEnd != null && projectedMonthEnd > 0) pw.SizedBox(height: 20),
        _categoryBreakdown(categoryData),
        pw.SizedBox(height: 20),
        if (accountBreakdown.isNotEmpty) _accountBreakdown(accountBreakdown),
        if (accountBreakdown.isNotEmpty) pw.SizedBox(height: 20),
        _monthlyTrend(monthlyExpData, monthlyIncData),
        pw.SizedBox(height: 20),
        _topExpensesTable(topExpenses, categories),
        pw.SizedBox(height: 20),
        _insightsSection(expenses, incomes ?? [], categoryData, avgExpense),
        pw.SizedBox(height: 28),
        _footer(),
      ],
    ));
    await Printing.layoutPdf(onLayout: (fmt) async => pdf.save(), name: 'magic_ledger_report_${period.replaceAll(' ', '_')}.pdf');
  }

  Future<void> generateExpenseReceipt(ExpenseModel expense, CategoryModel category, {AccountModel? account}) async {
    await _loadFonts();
    final pdf = pw.Document();
    pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(28),
        build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          _receiptHeader(), pw.SizedBox(height: 28), _receiptBody(expense, category, account), pw.SizedBox(height: 28), _footer(),
        ])));
    await Printing.layoutPdf(onLayout: (fmt) async => pdf.save(), name: 'magic_ledger_receipt_${expense.id}.pdf');
  }

  Future<void> generateTodoReport(List<TodoModel> todos, String period) async {
    await _loadFonts();
    final pdf = pw.Document();
    final completed = todos.where((t) => t.isCompleted).toList();
    final pending = todos.where((t) => !t.isCompleted).toList();
    final overdue = pending.where((t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now())).toList();
    pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(28),
        build: (ctx) => [
          _header(period, reportType: 'TODO TRACKER'), pw.SizedBox(height: 20),
          _todoSummary(todos.length, completed.length, pending.length, overdue.length), pw.SizedBox(height: 20),
          if (overdue.isNotEmpty) _todoSection('OVERDUE', overdue, _red),
          if (overdue.isNotEmpty) pw.SizedBox(height: 16),
          if (pending.isNotEmpty) _todoSection('PENDING', pending, _orange),
          if (pending.isNotEmpty) pw.SizedBox(height: 16),
          if (completed.isNotEmpty) _todoSection('COMPLETED', completed, _green),
          pw.SizedBox(height: 28), _footer(),
        ]));
    await Printing.layoutPdf(onLayout: (fmt) async => pdf.save(), name: 'magic_ledger_todos_${period.replaceAll(' ', '_')}.pdf');
  }

  pw.Widget _header(String period, {String reportType = 'FINANCIAL REPORT'}) {
    return pw.Container(padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(color: _black, border: pw.Border.all(color: _black, width: 3)),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Row(children: [_pill('MAGIC', _purple), pw.SizedBox(width: 6), _pill('LEDGER', _skyBlue)]),
            pw.SizedBox(height: 8),
            pw.Text(reportType, style: pw.TextStyle(font: _bold, fontSize: 24, color: _white)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('Period', style: pw.TextStyle(font: _regular, fontSize: 10, color: _midGrey)),
            pw.Text(period.toUpperCase(), style: pw.TextStyle(font: _bold, fontSize: 13, color: _purple)),
            pw.SizedBox(height: 4),
            pw.Text('Generated', style: pw.TextStyle(font: _regular, fontSize: 10, color: _midGrey)),
            pw.Text(_dateFmt.format(DateTime.now()), style: pw.TextStyle(font: _bold, fontSize: 11, color: _white)),
          ]),
        ]));
  }

  pw.Widget _financialSummary(double spent, double earned, double net, double savings, int ec, int ic) {
    return pw.Row(children: [
      _summaryCard('TOTAL SPENT', _curFmt.format(spent), _orange, '$ec expenses'), pw.SizedBox(width: 10),
      _summaryCard('TOTAL EARNED', _curFmt.format(earned), _green, '$ic incomes'), pw.SizedBox(width: 10),
      _summaryCard('NET FLOW', _curFmt.format(net), net >= 0 ? _sage : _pink, '${savings.toStringAsFixed(0)}% saved'),
    ]);
  }

  pw.Widget _summaryCard(String label, String value, PdfColor color, String sub) {
    return pw.Expanded(child: pw.Container(height: 78, padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(color: color, border: pw.Border.all(color: _black, width: 3),
            boxShadow: [pw.BoxShadow(color: _black, offset: const PdfPoint(4, 4))]),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(label, style: pw.TextStyle(font: _bold, fontSize: 9, color: _black, letterSpacing: 0.5)),
          pw.Text(value, style: pw.TextStyle(font: _bold, fontSize: 18, color: _black)),
          pw.Text(sub, style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)),
        ])));
  }

  pw.Widget _comparisonSection(double? sc, double? ic, double ps, double pe) {
    return _card(title: 'VS PREVIOUS PERIOD', badge: 'CMP', badgeColor: _lilac, child: pw.Row(children: [
      if (sc != null) pw.Expanded(child: _cmpItem('Spending', sc, _curFmt.format(ps), sc <= 0)),
      if (sc != null && ic != null) pw.SizedBox(width: 12),
      if (ic != null) pw.Expanded(child: _cmpItem('Income', ic, _curFmt.format(pe), ic >= 0)),
    ]));
  }

  pw.Widget _cmpItem(String label, double chg, String prev, bool good) {
    final arrow = chg > 0 ? '\u2191' : (chg < 0 ? '\u2193' : '\u2192');
    return pw.Container(padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(color: good ? _sage : PdfColor.fromInt(0xFFFFE0E0), border: pw.Border.all(color: _black, width: 2)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label.toUpperCase(), style: pw.TextStyle(font: _bold, fontSize: 9, color: _darkGrey)),
          pw.SizedBox(height: 4),
          pw.Text('$arrow ${chg.abs().toStringAsFixed(1)}%', style: pw.TextStyle(font: _bold, fontSize: 16, color: _black)),
          pw.Text('Prev: $prev', style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)),
        ]));
  }

  pw.Widget _projectionSection(double projected, double velocity, int daysLeft) {
    return pw.Container(padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(color: _beige, border: pw.Border.all(color: _black, width: 3)),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Row(children: [_pill('PROJECTION', _black, textColor: _white), pw.SizedBox(width: 8),
              pw.Text('Month-end estimate', style: pw.TextStyle(font: _regular, fontSize: 10, color: _darkGrey))]),
            pw.SizedBox(height: 8),
            pw.Text(_curFmt.format(projected), style: pw.TextStyle(font: _bold, fontSize: 22, color: _black)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('${_curFmt.format(velocity)}/day', style: pw.TextStyle(font: _bold, fontSize: 12, color: _black)),
            pw.Text('$daysLeft days remaining', style: pw.TextStyle(font: _regular, fontSize: 10, color: _darkGrey)),
          ]),
        ]));
  }

  pw.Widget _categoryBreakdown(List<Map<String, dynamic>> data) {
    return _card(title: 'CATEGORY BREAKDOWN', badge: 'CAT', badgeColor: _pink,
        child: pw.Column(children: data.take(8).map((d) {
          final pct = d['percentage'] as int;
          final color = _flutterToPdf(d['color'] as Color);
          return pw.Container(margin: const pw.EdgeInsets.only(bottom: 8), child: pw.Row(children: [
            pw.Container(width: 16, height: 16, decoration: pw.BoxDecoration(color: color, border: pw.Border.all(color: _black, width: 2))),
            pw.SizedBox(width: 10),
            pw.Expanded(flex: 3, child: pw.Text(d['name'] as String, style: pw.TextStyle(font: _bold, fontSize: 11, color: _black))),
            pw.Expanded(flex: 4, child: pw.Stack(children: [
              pw.Container(height: 12, decoration: pw.BoxDecoration(color: _lightGrey, border: pw.Border.all(color: _black, width: 1))),
              pw.Container(height: 12, width: math.max(0, math.min(200, (pct / 100) * 200)), color: color),
            ])),
            pw.SizedBox(width: 8),
            pw.SizedBox(width: 35, child: pw.Text('$pct%', style: pw.TextStyle(font: _bold, fontSize: 10, color: _black), textAlign: pw.TextAlign.right)),
            pw.SizedBox(width: 6),
            pw.SizedBox(width: 70, child: pw.Text(_curFmt.format((d['amount'] as num).toDouble()), style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey), textAlign: pw.TextAlign.right)),
          ]));
        }).toList()));
  }

  pw.Widget _accountBreakdown(List<Map<String, dynamic>> data) {
    return _card(title: 'ACCOUNT BREAKDOWN', badge: 'ACC', badgeColor: _skyBlue,
        child: pw.Column(children: data.map((d) {
          final spent = (d['spent'] as num).toDouble();
          final earned = (d['earned'] as num).toDouble();
          final net = earned - spent;
          return pw.Container(margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: _offWhite, border: pw.Border.all(color: _black, width: 2)),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(d['name'] as String, style: pw.TextStyle(font: _bold, fontSize: 12, color: _black)),
                  pw.SizedBox(height: 2),
                  pw.Text('In: ${_curFmt.format(earned)}  Out: ${_curFmt.format(spent)}', style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)),
                ]),
                pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(color: net >= 0 ? _sage : PdfColor.fromInt(0xFFFFE0E0), border: pw.Border.all(color: _black, width: 2)),
                    child: pw.Text('${net >= 0 ? '+' : ''}${_curFmt.format(net)}', style: pw.TextStyle(font: _bold, fontSize: 11, color: _black))),
              ]));
        }).toList()));
  }

  pw.Widget _monthlyTrend(Map<String, double> expData, Map<String, double> incData) {
    final allKeys = {...expData.keys, ...incData.keys}.toList()..sort();
    if (allKeys.isEmpty) return pw.SizedBox();
    final maxVal = math.max(expData.values.fold(0.0, (a, b) => math.max(a, b)), incData.values.fold(0.0, (a, b) => math.max(a, b)));
    if (maxVal <= 0) return pw.SizedBox();
    return _card(title: 'MONTHLY TREND', badge: 'TREND', badgeColor: _blue, child: pw.Column(children: [
      pw.Row(children: [
        pw.Container(width: 12, height: 12, color: _pink), pw.SizedBox(width: 4),
        pw.Text('Expenses', style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)), pw.SizedBox(width: 16),
        pw.Container(width: 12, height: 12, color: _green), pw.SizedBox(width: 4),
        pw.Text('Income', style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)),
      ]),
      pw.SizedBox(height: 12),
      pw.Container(height: 120, child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: allKeys.map((key) {
            final eH = math.min(100.0, ((expData[key] ?? 0) / maxVal) * 100);
            final iH = math.min(100.0, ((incData[key] ?? 0) / maxVal) * 100);
            final label = key.contains('/') ? key.split('/')[0] : key;
            return pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Container(width: 16, height: math.max(2, eH), decoration: pw.BoxDecoration(color: _pink, border: pw.Border.all(color: _black, width: 1.5))),
                pw.SizedBox(width: 2),
                pw.Container(width: 16, height: math.max(2, iH), decoration: pw.BoxDecoration(color: _green, border: pw.Border.all(color: _black, width: 1.5))),
              ]),
              pw.SizedBox(height: 6),
              pw.Text(label, style: pw.TextStyle(font: _bold, fontSize: 8, color: _darkGrey)),
            ]);
          }).toList())),
    ]));
  }

  pw.Widget _topExpensesTable(List<ExpenseModel> expenses, List<CategoryModel> categories) {
    if (expenses.isEmpty) return pw.SizedBox();
    return _card(title: 'TOP EXPENSES', badge: 'TOP', badgeColor: _orange,
        child: pw.Table(border: pw.TableBorder.all(color: _black, width: 2),
            columnWidths: {0: const pw.FixedColumnWidth(28), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(2), 3: const pw.FlexColumnWidth(1.5), 4: const pw.FlexColumnWidth(2)},
            children: [
              pw.TableRow(decoration: const pw.BoxDecoration(color: _black),
                  children: ['#', 'EXPENSE', 'CATEGORY', 'DATE', 'AMOUNT'].map((h) => pw.Container(padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(h, style: pw.TextStyle(font: _bold, fontSize: 9, color: _white), textAlign: pw.TextAlign.center))).toList()),
              ...expenses.asMap().entries.map((entry) {
                final i = entry.key; final e = entry.value;
                final cat = categories.firstWhere((c) => c.id == e.categoryId, orElse: () => categories.first);
                return pw.TableRow(decoration: pw.BoxDecoration(color: i % 2 == 0 ? _offWhite : _white), children: [
                  _tCell('${i + 1}', isBold: true), _tCell(e.title), _tCell(cat.name), _tCell(_dateFmt.format(e.date)), _tCell(_curFmt.format(e.amount), isBold: true),
                ]);
              }),
            ]));
  }

  pw.Widget _insightsSection(List<ExpenseModel> expenses, List<IncomeModel> incomes, List<Map<String, dynamic>> catData, double avgExp) {
    final highest = expenses.isNotEmpty ? expenses.reduce((a, b) => a.amount > b.amount ? a : b) : null;
    final topCat = catData.isNotEmpty ? catData.first['name'] as String : 'N/A';
    final dailyAvg = _calcDailyAvg(expenses);
    final recExp = expenses.where((e) => e.isRecurring).length;
    final recInc = incomes.where((i) => i.isRecurring).length;
    final dayTotals = <int, double>{};
    for (final e in expenses) { dayTotals[e.date.weekday] = (dayTotals[e.date.weekday] ?? 0) + e.amount; }
    String biggestDay = 'N/A';
    if (dayTotals.isNotEmpty) {
      final mx = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      const dn = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      biggestDay = dn[mx.key];
    }
    return pw.Container(padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(color: _purple, border: pw.Border.all(color: _black, width: 3)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(children: [_pill('INSIGHTS', _black, textColor: _white), pw.SizedBox(width: 10),
            pw.Text('KEY TAKEAWAYS', style: pw.TextStyle(font: _bold, fontSize: 16, color: _black))]),
          pw.SizedBox(height: 14),
          pw.Row(children: [
            pw.Expanded(child: _bubble('BIGGEST EXPENSE', highest != null ? '${highest.title} (${_curFmt.format(highest.amount)})' : 'N/A', _pink)),
            pw.SizedBox(width: 8), pw.Expanded(child: _bubble('TOP CATEGORY', topCat, _blue)),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Expanded(child: _bubble('DAILY AVERAGE', _curFmt.format(dailyAvg), _green)),
            pw.SizedBox(width: 8), pw.Expanded(child: _bubble('AVG TRANSACTION', _curFmt.format(avgExp), _skyBlue)),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Expanded(child: _bubble('BIGGEST SPEND DAY', biggestDay, _orange)),
            pw.SizedBox(width: 8), pw.Expanded(child: _bubble('RECURRING', '$recExp exp \u00B7 $recInc inc', _lilac)),
          ]),
        ]));
  }

  pw.Widget _bubble(String label, String value, PdfColor color) {
    return pw.Container(padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(color: color, border: pw.Border.all(color: _black, width: 2)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label, style: pw.TextStyle(font: _bold, fontSize: 8, color: _black, letterSpacing: 0.3)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(font: _regular, fontSize: 10, color: _black)),
        ]));
  }

  pw.Widget _receiptHeader() {
    return pw.Container(padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(color: _black, border: pw.Border.all(color: _black, width: 3)),
        child: pw.Center(child: pw.Column(children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [_pill('MAGIC', _purple), pw.SizedBox(width: 6), _pill('LEDGER', _skyBlue)]),
          pw.SizedBox(height: 8),
          pw.Text('EXPENSE RECEIPT', style: pw.TextStyle(font: _bold, fontSize: 18, color: _white)),
        ])));
  }

  pw.Widget _receiptBody(ExpenseModel expense, CategoryModel category, AccountModel? account) {
    return pw.Container(padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(color: _offWhite, border: pw.Border.all(color: _black, width: 3)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          _receiptRow('Receipt ID', expense.id, _skyBlue), pw.SizedBox(height: 10),
          _receiptRow('Date', _dateFmt.format(expense.date), _green),
          if (account != null) ...[pw.SizedBox(height: 10), _receiptRow('Account', account.name, _lilac)],
          pw.SizedBox(height: 16), pw.Container(height: 2, color: _black), pw.SizedBox(height: 16),
          _receiptRow('Description', expense.title, _purple), pw.SizedBox(height: 10),
          _receiptRow('Category', category.name, _pink),
          if (expense.location != null) ...[pw.SizedBox(height: 10), _receiptRow('Location', expense.location!, _orange)],
          if (expense.tags != null && expense.tags!.isNotEmpty) ...[pw.SizedBox(height: 10), _receiptRow('Tags', expense.tags!.join(', '), _beige)],
          pw.SizedBox(height: 20), pw.Container(height: 3, color: _black), pw.SizedBox(height: 16),
          pw.Container(padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(color: _orange, border: pw.Border.all(color: _black, width: 3)),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('TOTAL', style: pw.TextStyle(font: _bold, fontSize: 18, color: _black)),
                pw.Text(_curFmtDec.format(expense.amount), style: pw.TextStyle(font: _bold, fontSize: 22, color: _black)),
              ])),
        ]));
  }

  pw.Widget _receiptRow(String label, String value, PdfColor color) {
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Container(width: 100, padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3), color: color,
          child: pw.Text(label.toUpperCase(), style: pw.TextStyle(font: _bold, fontSize: 9, color: _black))),
      pw.SizedBox(width: 12),
      pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: _regular, fontSize: 11, color: _black))),
    ]);
  }

  pw.Widget _todoSummary(int total, int done, int pending, int overdue) {
    return pw.Row(children: [
      _summaryCard('TOTAL', '$total', _blue, 'tasks'), pw.SizedBox(width: 10),
      _summaryCard('DONE', '$done', _green, '${total > 0 ? (done / total * 100).toStringAsFixed(0) : 0}%'), pw.SizedBox(width: 10),
      _summaryCard('PENDING', '$pending', _orange, 'remaining'), pw.SizedBox(width: 10),
      _summaryCard('OVERDUE', '$overdue', _red, 'late'),
    ]);
  }

  pw.Widget _todoSection(String title, List<TodoModel> todos, PdfColor color) {
    return _card(title: title, badge: title.substring(0, 3), badgeColor: color,
        child: pw.Column(children: todos.map((t) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: _white, border: pw.Border.all(color: _black, width: 2)),
            child: pw.Row(children: [
              pw.Container(width: 16, height: 16, decoration: pw.BoxDecoration(
                  color: t.isCompleted ? _green : _white, border: pw.Border.all(color: _black, width: 2)),
                  child: t.isCompleted ? pw.Center(child: pw.Text('\u2713', style: pw.TextStyle(font: _bold, fontSize: 10, color: _black))) : pw.SizedBox()),
              pw.SizedBox(width: 10),
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(t.title, style: pw.TextStyle(font: _bold, fontSize: 11, color: _black, decoration: t.isCompleted ? pw.TextDecoration.lineThrough : null)),
                if (t.dueDate != null) pw.Text('Due: ${_dateFmt.format(t.dueDate!)}', style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)),
              ])),
              pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(color: _priorityColor(t.priority), border: pw.Border.all(color: _black, width: 1.5)),
                  child: pw.Text(_priorityLabel(t.priority), style: pw.TextStyle(font: _bold, fontSize: 8, color: _black))),
            ]))).toList()));
  }

  pw.Widget _footer() {
    return pw.Container(padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(color: _lilac, border: pw.Border.all(color: _black, width: 3)),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Generated by MAGIC LEDGER', style: pw.TextStyle(font: _bold, fontSize: 11, color: _black)),
            pw.Text('Track \u00B7 Save \u00B7 Achieve', style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('Visagan S', style: pw.TextStyle(font: _bold, fontSize: 10, color: _black)),
            pw.Text('Visainnovations', style: pw.TextStyle(font: _regular, fontSize: 9, color: _darkGrey)),
          ]),
        ]));
  }

  pw.Widget _card({required String title, required String badge, required PdfColor badgeColor, required pw.Widget child}) {
    return pw.Container(padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(color: _offWhite, border: pw.Border.all(color: _black, width: 3),
            boxShadow: [pw.BoxShadow(color: _black, offset: const PdfPoint(4, 4))]),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(children: [_pill(badge, badgeColor), pw.SizedBox(width: 10),
            pw.Text(title, style: pw.TextStyle(font: _bold, fontSize: 16, color: _black))]),
          pw.SizedBox(height: 14), child,
        ]));
  }

  pw.Widget _pill(String text, PdfColor bg, {PdfColor textColor = _black}) {
    return pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: pw.BoxDecoration(color: bg, border: pw.Border.all(color: _black, width: 2)),
        child: pw.Text(text, style: pw.TextStyle(font: _bold, fontSize: 9, color: textColor, letterSpacing: 0.3)));
  }

  pw.Widget _tCell(String text, {bool isBold = false}) {
    return pw.Container(padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: pw.TextStyle(font: isBold ? _bold : _regular, fontSize: 9, color: _black), textAlign: pw.TextAlign.center));
  }

  List<Map<String, dynamic>> _calcCategoryData(List<ExpenseModel> exp, List<CategoryModel> cats, double total) {
    final Map<String, double> t = {};
    for (final e in exp) { t[e.categoryId] = (t[e.categoryId] ?? 0) + e.amount; }
    return t.entries.map((e) {
      final c = cats.firstWhere((c) => c.id == e.key, orElse: () => cats.first);
      return {'name': c.name, 'amount': e.value, 'percentage': total > 0 ? (e.value / total * 100).round() : 0, 'color': c.colorValue, 'icon': c.icon};
    }).toList()..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }

  Map<String, double> _calcMonthlyData(List<ExpenseModel> exp) {
    final Map<String, double> d = {};
    for (final e in exp) { final k = '${e.date.month}/${e.date.year}'; d[k] = (d[k] ?? 0) + e.amount; }
    return d;
  }

  Map<String, double> _calcMonthlyIncomeData(List<IncomeModel> inc) {
    final Map<String, double> d = {};
    for (final i in inc) { final k = '${i.date.month}/${i.date.year}'; d[k] = (d[k] ?? 0) + i.amount; }
    return d;
  }

  List<Map<String, dynamic>> _calcAccountBreakdown(List<ExpenseModel> exp, List<IncomeModel> inc, List<AccountModel> accs) {
    if (accs.isEmpty) return [];
    return accs.map((a) {
      final s = exp.where((e) => e.accountId == a.id).fold(0.0, (sum, e) => sum + e.amount);
      final e = inc.where((i) => i.accountId == a.id).fold(0.0, (sum, i) => sum + i.amount);
      return {'name': a.name, 'spent': s, 'earned': e};
    }).where((d) => (d['spent'] as double) > 0 || (d['earned'] as double) > 0).toList();
  }

  double _calcDailyAvg(List<ExpenseModel> exp) {
    if (exp.isEmpty) return 0;
    final days = exp.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet().length;
    if (days <= 0) return 0;
    final avg = exp.fold(0.0, (s, e) => s + e.amount) / days;
    return avg.isFinite ? avg : 0;
  }

  PdfColor _flutterToPdf(Color c) => PdfColor.fromInt(c.value);
  PdfColor _priorityColor(int p) { switch (p) { case 3: return _red; case 2: return _orange; default: return _green; } }
  String _priorityLabel(int p) { switch (p) { case 3: return 'HIGH'; case 2: return 'MED'; default: return 'LOW'; } }
}