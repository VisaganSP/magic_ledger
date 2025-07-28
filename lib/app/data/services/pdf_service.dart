import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/todo_model.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  Future<void> generateAnalyticsReport(
    List<ExpenseModel> expenses,
    List<CategoryModel> categories,
    String period,
  ) async {
    final pdf = pw.Document();

    // Load custom font
    final fontData = await rootBundle.load('fonts/SpaceGrotesk-Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final regularFontData = await rootBundle.load(
      'fonts/SpaceGrotesk-Regular.ttf',
    );
    final regularTtf = pw.Font.ttf(regularFontData);

    // Calculate analytics data
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final avgExpense = expenses.isNotEmpty ? totalSpent / expenses.length : 0;
    final categoryData = _calculateCategoryData(
      expenses,
      categories,
      totalSpent,
    );
    final monthlyData = _calculateMonthlyData(expenses);

    // Fix: Ensure topExpenses is properly typed
    final List<ExpenseModel> topExpenses = List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final List<ExpenseModel> topExpensesList = topExpenses.take(10).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              _buildHeader(ttf, period),
              pw.SizedBox(height: 20),
              _buildSummarySection(
                ttf,
                regularTtf,
                totalSpent,
                expenses.length,
                avgExpense.toDouble(),
              ),
              pw.SizedBox(height: 30),
              _buildCategoryBreakdown(ttf, regularTtf, categoryData),
              pw.SizedBox(height: 30),
              _buildMonthlyTrend(ttf, regularTtf, monthlyData),
              pw.SizedBox(height: 30),
              _buildTopExpensesTable(
                ttf,
                regularTtf,
                topExpensesList,
                categories,
              ),
              pw.SizedBox(height: 30),
              _buildInsights(ttf, regularTtf, expenses, categoryData),
              pw.SizedBox(height: 40),
              _buildFooter(ttf),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'expense_report_${period.replaceAll(' ', '_')}.pdf',
    );
  }

  Future<void> generateExpenseReceipt(
    ExpenseModel expense,
    CategoryModel category,
  ) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('fonts/SpaceGrotesk-Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final regularFontData = await rootBundle.load(
      'fonts/SpaceGrotesk-Regular.ttf',
    );
    final regularTtf = pw.Font.ttf(regularFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildReceiptHeader(ttf),
                pw.SizedBox(height: 40),
                _buildReceiptDetails(ttf, regularTtf, expense, category),
                pw.SizedBox(height: 40),
                _buildReceiptFooter(ttf, regularTtf),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'receipt_${expense.id}.pdf',
    );
  }

  Future<void> generateTodoReport(List<TodoModel> todos, String period) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('fonts/SpaceGrotesk-Bold.ttf');
    final ttf = pw.Font.ttf(fontData);

    final regularFontData = await rootBundle.load(
      'fonts/SpaceGrotesk-Regular.ttf',
    );
    final regularTtf = pw.Font.ttf(regularFontData);

    final completedTodos = todos.where((t) => t.isCompleted).toList();
    final pendingTodos = todos.where((t) => !t.isCompleted).toList();
    final overdueTodos =
        pendingTodos
            .where(
              (t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now()),
            )
            .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              _buildTodoHeader(ttf, period),
              pw.SizedBox(height: 20),
              _buildTodoSummary(
                ttf,
                regularTtf,
                todos.length,
                completedTodos.length,
                pendingTodos.length,
                overdueTodos.length,
              ),
              pw.SizedBox(height: 30),
              if (pendingTodos.isNotEmpty) ...[
                _buildTodoSection(
                  ttf,
                  regularTtf,
                  'PENDING TODOS',
                  pendingTodos,
                  PdfColors.orange,
                ),
                pw.SizedBox(height: 20),
              ],
              if (overdueTodos.isNotEmpty) ...[
                _buildTodoSection(
                  ttf,
                  regularTtf,
                  'OVERDUE TODOS',
                  overdueTodos,
                  PdfColors.red,
                ),
                pw.SizedBox(height: 20),
              ],
              if (completedTodos.isNotEmpty) ...[
                _buildTodoSection(
                  ttf,
                  regularTtf,
                  'COMPLETED TODOS',
                  completedTodos,
                  PdfColors.green,
                ),
              ],
              pw.SizedBox(height: 40),
              _buildFooter(ttf),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'todo_report_${period.replaceAll(' ', '_')}.pdf',
    );
  }

  pw.Widget _buildHeader(pw.Font font, String period) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow,
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'NEO EXPENSE REPORT',
            style: pw.TextStyle(
              font: font,
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Period: $period', style: pw.TextStyle(fontSize: 16)),
          pw.Text(
            'Generated: ${_dateFormat.format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection(
    pw.Font font,
    pw.Font regularFont,
    double total,
    int count,
    double average,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryCard(
          font,
          'TOTAL SPENT',
          _currencyFormat.format(total),
          PdfColors.pink,
        ),
        _buildSummaryCard(
          font,
          'TRANSACTIONS',
          count.toString(),
          PdfColors.blue,
        ),
        _buildSummaryCard(
          font,
          'AVG EXPENSE',
          _currencyFormat.format(average),
          PdfColors.green,
        ),
      ],
    );
  }

  pw.Widget _buildSummaryCard(
    pw.Font font,
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: color,
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCategoryBreakdown(
    pw.Font font,
    pw.Font regularFont,
    List<Map<String, dynamic>> categoryData,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CATEGORY BREAKDOWN',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          ...categoryData.map((data) {
            final amount =
                (data['amount'] as num).toDouble(); // Convert num to double
            final percentage = data['percentage'] as int;
            final name = data['name'] as String;
            final color = data['color'] as Color;

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 20,
                        height: 20,
                        color: PdfColor.fromHex(
                          color.value
                              .toRadixString(16)
                              .padLeft(8, '0')
                              .substring(2),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Text(name, style: pw.TextStyle(font: regularFont)),
                    ],
                  ),
                  pw.Text(
                    '$percentage% - ${_currencyFormat.format(amount)}',
                    style: pw.TextStyle(
                      font: font,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildMonthlyTrend(
    pw.Font font,
    pw.Font regularFont,
    Map<String, double> monthlyData,
  ) {
    if (monthlyData.isEmpty) return pw.SizedBox();

    final maxValue = monthlyData.values.reduce(math.max);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MONTHLY TREND',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            height: 150,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children:
                  monthlyData.entries.map((entry) {
                    final height =
                        maxValue > 0 ? (entry.value / maxValue) * 120 : 0;
                    return pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Container(
                          width: 40,
                          height: height.toDouble(),
                          color: PdfColors.pink,
                          margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          entry.key.split('/')[0], // Month number
                          style: pw.TextStyle(fontSize: 10, font: regularFont),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTopExpensesTable(
    pw.Font font,
    pw.Font regularFont,
    List<ExpenseModel> expenses,
    List<CategoryModel> categories,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            color: PdfColors.orange,
            child: pw.Text(
              'TOP EXPENSES',
              style: pw.TextStyle(
                font: font,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 2),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableHeader(font, '#'),
                  _buildTableHeader(font, 'TITLE'),
                  _buildTableHeader(font, 'CATEGORY'),
                  _buildTableHeader(font, 'DATE'),
                  _buildTableHeader(font, 'AMOUNT'),
                ],
              ),
              ...expenses.asMap().entries.map((entry) {
                final index = entry.key;
                final expense = entry.value;
                final category = categories.firstWhere(
                  (c) => c.id == expense.categoryId,
                );

                return pw.TableRow(
                  children: [
                    _buildTableCell(regularFont, (index + 1).toString()),
                    _buildTableCell(regularFont, expense.title),
                    _buildTableCell(regularFont, category.name),
                    _buildTableCell(
                      regularFont,
                      _dateFormat.format(expense.date),
                    ),
                    _buildTableCell(
                      regularFont,
                      _currencyFormat.format(expense.amount),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInsights(
    pw.Font font,
    pw.Font regularFont,
    List<ExpenseModel> expenses,
    List<Map<String, dynamic>> categoryData,
  ) {
    final highestExpense =
        expenses.isNotEmpty
            ? expenses.reduce((a, b) => a.amount > b.amount ? a : b)
            : null;

    final mostFrequentCategory =
        categoryData.isNotEmpty ? categoryData.first['name'] : 'N/A';

    final avgDailySpend =
        expenses.isNotEmpty ? _calculateDailyAverage(expenses) : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'KEY INSIGHTS',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (highestExpense != null)
            _buildInsightRow(
              regularFont,
              '• Highest expense: ${highestExpense.title} (${_currencyFormat.format(highestExpense.amount)})',
            ),
          _buildInsightRow(
            regularFont,
            '• Most spent category: $mostFrequentCategory',
          ),
          _buildInsightRow(
            regularFont,
            '• Average daily spending: ${_currencyFormat.format(avgDailySpend)}',
          ),
          if (expenses.length > 10)
            _buildInsightRow(
              regularFont,
              '• You made ${expenses.length} transactions in this period',
            ),
        ],
      ),
    );
  }

  pw.Widget _buildInsightRow(pw.Font font, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 12)),
    );
  }

  pw.Widget _buildReceiptHeader(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(color: PdfColors.black),
      child: pw.Center(
        child: pw.Column(
          children: [
            pw.Text(
              'NEO TRACKER',
              style: pw.TextStyle(
                font: font,
                fontSize: 32,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'EXPENSE RECEIPT',
              style: pw.TextStyle(
                font: font,
                fontSize: 16,
                color: PdfColors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildReceiptDetails(
    pw.Font font,
    pw.Font regularFont,
    ExpenseModel expense,
    CategoryModel category,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildReceiptRow(font, regularFont, 'Receipt ID:', expense.id),
          _buildReceiptRow(
            font,
            regularFont,
            'Date:',
            _dateFormat.format(expense.date),
          ),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 10),
          _buildReceiptRow(font, regularFont, 'Description:', expense.title),
          _buildReceiptRow(
            font,
            regularFont,
            'Category:',
            '${category.icon} ${category.name}',
          ),
          if (expense.location != null)
            _buildReceiptRow(font, regularFont, 'Location:', expense.location!),
          if (expense.tags != null && expense.tags!.isNotEmpty)
            _buildReceiptRow(
              font,
              regularFont,
              'Tags:',
              expense.tags!.join(', '),
            ),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TOTAL AMOUNT:',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                _currencyFormat.format(expense.amount),
                style: pw.TextStyle(
                  font: font,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReceiptRow(
    pw.Font boldFont,
    pw.Font regularFont,
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: boldFont,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: regularFont)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReceiptFooter(pw.Font font, pw.Font regularFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        children: [
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),
          pw.Text(
            'Thank you for using Neo Tracker!',
            style: pw.TextStyle(font: regularFont, fontSize: 12),
          ),
          pw.Text(
            'Track. Save. Achieve.',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTodoHeader(pw.Font font, String period) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple,
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TODO REPORT',
            style: pw.TextStyle(
              font: font,
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Period: $period',
            style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
          ),
          pw.Text(
            'Generated: ${_dateFormat.format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey300),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTodoSummary(
    pw.Font font,
    pw.Font regularFont,
    int total,
    int completed,
    int pending,
    int overdue,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryCard(font, 'TOTAL', total.toString(), PdfColors.blue),
        _buildSummaryCard(
          font,
          'COMPLETED',
          completed.toString(),
          PdfColors.green,
        ),
        _buildSummaryCard(
          font,
          'PENDING',
          pending.toString(),
          PdfColors.orange,
        ),
        _buildSummaryCard(font, 'OVERDUE', overdue.toString(), PdfColors.red),
      ],
    );
  }

  pw.Widget _buildTodoSection(
    pw.Font font,
    pw.Font regularFont,
    String title,
    List<TodoModel> todos,
    PdfColor color,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            color: color,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: font,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              children:
                  todos
                      .map(
                        (todo) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 20,
                                height: 20,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 2,
                                  ),
                                  color:
                                      todo.isCompleted
                                          ? PdfColors.black
                                          : PdfColors.white,
                                ),
                                child:
                                    todo.isCompleted
                                        ? pw.Center(
                                          child: pw.Text(
                                            '✓',
                                            style: pw.TextStyle(
                                              color: PdfColors.white,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        )
                                        : pw.SizedBox(),
                              ),
                              pw.SizedBox(width: 12),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      todo.title,
                                      style: pw.TextStyle(
                                        font: font,
                                        fontWeight: pw.FontWeight.bold,
                                        decoration:
                                            todo.isCompleted
                                                ? pw.TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                    if (todo.description != null)
                                      pw.Text(
                                        todo.description!,
                                        style: pw.TextStyle(
                                          font: regularFont,
                                          fontSize: 10,
                                          color: PdfColors.grey700,
                                        ),
                                      ),
                                    if (todo.dueDate != null)
                                      pw.Text(
                                        'Due: ${_dateFormat.format(todo.dueDate!)}',
                                        style: pw.TextStyle(
                                          font: regularFont,
                                          fontSize: 10,
                                          color:
                                              todo.dueDate!.isBefore(
                                                        DateTime.now(),
                                                      ) &&
                                                      !todo.isCompleted
                                                  ? PdfColors.red
                                                  : PdfColors.grey600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: _getPriorityColor(todo.priority),
                                  border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 2,
                                  ),
                                ),
                                child: pw.Text(
                                  _getPriorityLabel(todo.priority),
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(pw.Font font, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(pw.Font font, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }

  pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple,
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Center(
        child: pw.Text(
          'Generated by NEO TRACKER - Track. Save. Achieve.',
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateCategoryData(
    List<ExpenseModel> expenses,
    List<CategoryModel> categories,
    double total,
  ) {
    final Map<String, double> categoryTotals = <String, double>{};

    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
    }

    final List<Map<String, dynamic>> result =
        categoryTotals.entries.map((entry) {
          final category = categories.firstWhere((c) => c.id == entry.key);
          final int percentage =
              total > 0 ? (entry.value / total * 100).round() : 0;

          return <String, dynamic>{
            'name': category.name,
            'amount': entry.value,
            'percentage': percentage,
            'color': category.colorValue,
            'icon': category.icon,
          };
        }).toList();

    result.sort((a, b) {
      final aAmount = a['amount'] as double;
      final bAmount = b['amount'] as double;
      return bAmount.compareTo(aAmount);
    });

    return result;
  }

  Map<String, double> _calculateMonthlyData(List<ExpenseModel> expenses) {
    final Map<String, double> monthlyData = <String, double>{};

    for (final expense in expenses) {
      final monthKey = '${expense.date.month}/${expense.date.year}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0.0) + expense.amount;
    }

    return monthlyData;
  }

  double _calculateDailyAverage(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return 0;

    final dates =
        expenses
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet();

    final totalDays = dates.length;
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return totalDays > 0 ? totalSpent / totalDays : 0;
  }

  PdfColor _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return PdfColors.red;
      case 2:
        return PdfColors.orange;
      default:
        return PdfColors.green;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'HIGH';
      case 2:
        return 'MED';
      default:
        return 'LOW';
    }
  }
}
