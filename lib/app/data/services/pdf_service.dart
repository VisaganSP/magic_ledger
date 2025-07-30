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
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹');

  // Neo Brutalism Color Palette
  static const PdfColor primaryYellow = PdfColor.fromInt(0xFFFFE066);
  static const PdfColor primaryPink = PdfColor.fromInt(0xFFFF6B9D);
  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF4ECDC4);
  static const PdfColor primaryGreen = PdfColor.fromInt(0xFF95E1D3);
  static const PdfColor primaryOrange = PdfColor.fromInt(0xFFFFA726);
  static const PdfColor primaryPurple = PdfColor.fromInt(0xFF9C88FF);
  static const PdfColor primaryRed = PdfColor.fromInt(0xFFFF6B6B);
  static const PdfColor darkBg = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF8F9FA);

  Future<void> generateAnalyticsReport(
    List<ExpenseModel> expenses,
    List<CategoryModel> categories,
    String period,
  ) async {
    final pdf = pw.Document();

    // Load custom fonts
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

    final List<ExpenseModel> topExpenses = List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final List<ExpenseModel> topExpensesList = topExpenses.take(10).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => [
              _buildBrutalistHeader(
                ttf,
                regularTtf,
                period,
                'EXPENSE ANALYTICS',
              ),
              pw.SizedBox(height: 24),
              _buildBrutalistSummarySection(
                ttf,
                regularTtf,
                totalSpent,
                expenses.length,
                avgExpense.toDouble(),
              ),
              pw.SizedBox(height: 32),
              _buildBrutalistCategoryBreakdown(ttf, regularTtf, categoryData),
              pw.SizedBox(height: 32),
              _buildBrutalistMonthlyTrend(ttf, regularTtf, monthlyData),
              pw.SizedBox(height: 32),
              _buildBrutalistTopExpensesTable(
                ttf,
                regularTtf,
                topExpensesList,
                categories,
              ),
              pw.SizedBox(height: 32),
              _buildBrutalistInsights(ttf, regularTtf, expenses, categoryData),
              pw.SizedBox(height: 40),
              _buildBrutalistFooter(ttf, regularTtf),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'magic_ledger_expense_report_${period.replaceAll(' ', '_')}.pdf',
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
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildBrutalistReceiptHeader(ttf, regularTtf),
                pw.SizedBox(height: 32),
                _buildBrutalistReceiptDetails(
                  ttf,
                  regularTtf,
                  expense,
                  category,
                ),
                pw.SizedBox(height: 32),
                _buildBrutalistReceiptFooter(ttf, regularTtf),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'magic_ledger_receipt_${expense.id}.pdf',
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
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => [
              _buildBrutalistHeader(ttf, regularTtf, period, 'TODO TRACKER'),
              pw.SizedBox(height: 24),
              _buildBrutalistTodoSummary(
                ttf,
                regularTtf,
                todos.length,
                completedTodos.length,
                pendingTodos.length,
                overdueTodos.length,
              ),
              pw.SizedBox(height: 32),
              if (pendingTodos.isNotEmpty) ...[
                _buildBrutalistTodoSection(
                  ttf,
                  regularTtf,
                  'PENDING TASKS',
                  pendingTodos,
                  primaryOrange,
                  'PENDING',
                ),
                pw.SizedBox(height: 24),
              ],
              if (overdueTodos.isNotEmpty) ...[
                _buildBrutalistTodoSection(
                  ttf,
                  regularTtf,
                  'OVERDUE TASKS',
                  overdueTodos,
                  primaryRed,
                  'OVERDUE',
                ),
                pw.SizedBox(height: 24),
              ],
              if (completedTodos.isNotEmpty) ...[
                _buildBrutalistTodoSection(
                  ttf,
                  regularTtf,
                  'COMPLETED TASKS',
                  completedTodos,
                  primaryGreen,
                  'DONE',
                ),
              ],
              pw.SizedBox(height: 40),
              _buildBrutalistFooter(ttf, regularTtf),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'magic_ledger_todo_report_${period.replaceAll(' ', '_')}.pdf',
    );
  }

  // Enhanced Neo Brutalist Header
  pw.Widget _buildBrutalistHeader(
    pw.Font boldFont,
    pw.Font regularFont,
    String period,
    String reportType,
  ) {
    return pw.Stack(
      children: [
        // Background pattern
        pw.Container(
          height: 120,
          decoration: pw.BoxDecoration(
            color: darkBg,
            border: pw.Border.all(color: PdfColors.black, width: 4),
          ),
        ),
        // Colorful accent blocks
        pw.Positioned(
          top: 8,
          right: 8,
          child: pw.Container(
            width: 60,
            height: 20,
            color: primaryYellow,
            child: pw.Transform.rotate(
              angle: 0.1,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 3),
                ),
              ),
            ),
          ),
        ),
        pw.Positioned(
          top: 35,
          right: 30,
          child: pw.Container(
            width: 40,
            height: 15,
            color: primaryPink,
            child: pw.Transform.rotate(
              angle: -0.1,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 3),
                ),
              ),
            ),
          ),
        ),
        // Main content
        pw.Container(
          height: 120,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: primaryYellow,
                    child: pw.Text(
                      'MAGIC',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: primaryBlue,
                    child: pw.Text(
                      'LEDGER',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                reportType,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text(
                    'Period: $period',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 12,
                      color: primaryYellow,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    'Generated: ${_dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 12,
                      color: PdfColors.grey300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Enhanced Summary Section with Neo Brutalist Cards
  pw.Widget _buildBrutalistSummarySection(
    pw.Font boldFont,
    pw.Font regularFont,
    double total,
    int count,
    double average,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _buildBrutalistSummaryCard(
          boldFont,
          regularFont,
          'TOTAL SPENT',
          _currencyFormat.format(total),
          primaryPink,
          'TOTAL',
        ),
        _buildBrutalistSummaryCard(
          boldFont,
          regularFont,
          'TRANSACTIONS',
          count.toString(),
          primaryBlue,
          'COUNT',
        ),
        _buildBrutalistSummaryCard(
          boldFont,
          regularFont,
          'AVG EXPENSE',
          _currencyFormat.format(average),
          primaryGreen,
          'AVG',
        ),
      ],
    );
  }

  pw.Widget _buildBrutalistSummaryCard(
    pw.Font boldFont,
    pw.Font regularFont,
    String label,
    String value,
    PdfColor color,
    String badge,
  ) {
    return pw.Container(
      width: 160,
      height: 100,
      child: pw.Stack(
        children: [
          // Shadow effect
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(width: 154, height: 94, color: PdfColors.black),
          ),
          // Main card
          pw.Container(
            width: 154,
            height: 94,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: color,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.black,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(2),
                    ),
                  ),
                  child: pw.Text(
                    badge,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  value,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Category Breakdown
  pw.Widget _buildBrutalistCategoryBreakdown(
    pw.Font boldFont,
    pw.Font regularFont,
    List<Map<String, dynamic>> categoryData,
  ) {
    return pw.Container(
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(
              width: 500,
              height: math.max(200.0, categoryData.length * 60.0 + 100),
              color: PdfColors.black,
            ),
          ),
          // Main container
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: lightBg,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.black,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(2),
                        ),
                      ),
                      child: pw.Text(
                        'CAT',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'CATEGORY BREAKDOWN',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                ...categoryData.map((data) {
                  final amount = (data['amount'] as num).toDouble();
                  final percentage = data['percentage'] as int;
                  final name = data['name'] as String;
                  final color = data['color'] as Color;

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Stack(
                      children: [
                        // Progress bar background
                        pw.Container(
                          height: 40,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            border: pw.Border.all(
                              color: PdfColors.black,
                              width: 2,
                            ),
                          ),
                        ),
                        // Progress bar fill
                        pw.Container(
                          height: 40,
                          width: math.max(
                            0.0,
                            math.min(400.0, (percentage / 100) * 400),
                          ),
                          color: PdfColor.fromHex(
                            color.value
                                .toRadixString(16)
                                .padLeft(8, '0')
                                .substring(2),
                          ),
                        ),
                        // Content
                        pw.Container(
                          height: 40,
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                name,
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '$percentage% • ${_currencyFormat.format(amount)}',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Monthly Trend Chart
  pw.Widget _buildBrutalistMonthlyTrend(
    pw.Font boldFont,
    pw.Font regularFont,
    Map<String, double> monthlyData,
  ) {
    if (monthlyData.isEmpty) return pw.SizedBox();

    final maxValue =
        monthlyData.values.isNotEmpty
            ? monthlyData.values.reduce(math.max)
            : 0.0;
    if (maxValue <= 0 || maxValue.isInfinite || maxValue.isNaN) {
      return pw.SizedBox();
    }

    final colors = [
      primaryPink,
      primaryBlue,
      primaryYellow,
      primaryGreen,
      primaryOrange,
      primaryPurple,
    ];

    return pw.Container(
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(
              width: 500,
              height: 250,
              color: PdfColors.black,
            ),
          ),
          // Main container
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: lightBg,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.black,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(2),
                        ),
                      ),
                      child: pw.Text(
                        'TREND',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'MONTHLY SPENDING TREND',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  height: 150,
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children:
                        monthlyData.entries.map((entry) {
                          final index = monthlyData.keys.toList().indexOf(
                            entry.key,
                          );
                          final value = entry.value;

                          // Ensure safe calculations
                          if (value.isInfinite ||
                              value.isNaN ||
                              maxValue <= 0) {
                            return pw.SizedBox();
                          }

                          final height = math.max(
                            0.0,
                            math.min(120.0, (value / maxValue) * 120),
                          );
                          final barColor = colors[index % colors.length];

                          return pw.Container(
                            child: pw.Stack(
                              children: [
                                pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    // Shadow for bar
                                    pw.Container(
                                      width: 45,
                                      height: height + 3,
                                      margin: const pw.EdgeInsets.only(
                                        left: 3,
                                        bottom: -3,
                                      ),
                                      color: PdfColors.black,
                                    ),
                                  ],
                                ),
                                pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    // Main bar
                                    pw.Container(
                                      width: 45,
                                      height: height,
                                      decoration: pw.BoxDecoration(
                                        color: barColor,
                                        border: pw.Border.all(
                                          color: PdfColors.black,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(height: 8),
                                    pw.Text(
                                      entry.key.split('/')[0],
                                      style: pw.TextStyle(
                                        font: boldFont,
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Top Expenses Table
  pw.Widget _buildBrutalistTopExpensesTable(
    pw.Font boldFont,
    pw.Font regularFont,
    List<ExpenseModel> expenses,
    List<CategoryModel> categories,
  ) {
    return pw.Container(
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(
              width: 500,
              height: math.max(400.0, expenses.length * 30.0 + 100),
              color: PdfColors.black,
            ),
          ),
          // Main container
          pw.Container(
            decoration: pw.BoxDecoration(
              color: lightBg,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  color: primaryOrange,
                  child: pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.black,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(2),
                          ),
                        ),
                        child: pw.Text(
                          'TOP',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        'TOP EXPENSES',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 2),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: darkBg),
                      children: [
                        _buildBrutalistTableHeader(boldFont, '#'),
                        _buildBrutalistTableHeader(boldFont, 'EXPENSE'),
                        _buildBrutalistTableHeader(boldFont, 'CATEGORY'),
                        _buildBrutalistTableHeader(boldFont, 'DATE'),
                        _buildBrutalistTableHeader(boldFont, 'AMOUNT'),
                      ],
                    ),
                    ...expenses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final expense = entry.value;
                      final category = categories.firstWhere(
                        (c) => c.id == expense.categoryId,
                        orElse: () => categories.first,
                      );
                      final rowColor =
                          index % 2 == 0 ? lightBg : PdfColors.white;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(color: rowColor),
                        children: [
                          _buildBrutalistTableCell(
                            regularFont,
                            (index + 1).toString(),
                          ),
                          _buildBrutalistTableCell(regularFont, expense.title),
                          _buildBrutalistTableCell(regularFont, category.name),
                          _buildBrutalistTableCell(
                            regularFont,
                            _dateFormat.format(expense.date),
                          ),
                          _buildBrutalistTableCell(
                            boldFont,
                            _currencyFormat.format(expense.amount),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Insights Section
  pw.Widget _buildBrutalistInsights(
    pw.Font boldFont,
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
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(
              width: 500,
              height: 180,
              color: PdfColors.black,
            ),
          ),
          // Main container
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: primaryYellow,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.black,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(2),
                        ),
                      ),
                      child: pw.Text(
                        'INFO',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'KEY INSIGHTS',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Column(
                  children: [
                    if (highestExpense != null)
                      _buildBrutalistInsightBubble(
                        boldFont,
                        regularFont,
                        'HIGHEST EXPENSE',
                        '${highestExpense.title} • ${_currencyFormat.format(highestExpense.amount)}',
                        primaryPink,
                      ),
                    pw.SizedBox(height: 8),
                    _buildBrutalistInsightBubble(
                      boldFont,
                      regularFont,
                      'TOP CATEGORY',
                      mostFrequentCategory,
                      primaryBlue,
                    ),
                    pw.SizedBox(height: 8),
                    _buildBrutalistInsightBubble(
                      boldFont,
                      regularFont,
                      'DAILY AVERAGE',
                      _currencyFormat.format(avgDailySpend),
                      primaryGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBrutalistInsightBubble(
    pw.Font boldFont,
    pw.Font regularFont,
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: pw.BoxDecoration(
        color: color,
        border: pw.Border.all(color: PdfColors.black, width: 3),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Receipt Components
  pw.Widget _buildBrutalistReceiptHeader(
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(
              width: 500,
              height: 100,
              color: PdfColors.black,
            ),
          ),
          // Main header
          pw.Container(
            height: 100,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: darkBg,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: primaryYellow,
                        child: pw.Text(
                          'MAGIC',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: primaryBlue,
                        child: pw.Text(
                          'LEDGER',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'EXPENSE RECEIPT',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 14,
                      color: primaryYellow,
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

  pw.Widget _buildBrutalistReceiptDetails(
    pw.Font boldFont,
    pw.Font regularFont,
    ExpenseModel expense,
    CategoryModel category,
  ) {
    return pw.Container(
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(
              width: 500,
              height: 300,
              color: PdfColors.black,
            ),
          ),
          // Main container
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: lightBg,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildBrutalistReceiptRow(
                  boldFont,
                  regularFont,
                  'Receipt ID',
                  expense.id,
                  primaryBlue,
                ),
                pw.SizedBox(height: 12),
                _buildBrutalistReceiptRow(
                  boldFont,
                  regularFont,
                  'Date',
                  _dateFormat.format(expense.date),
                  primaryGreen,
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: double.infinity,
                  height: 2,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 20),
                _buildBrutalistReceiptRow(
                  boldFont,
                  regularFont,
                  'Description',
                  expense.title,
                  primaryYellow,
                ),
                pw.SizedBox(height: 12),
                _buildBrutalistReceiptRow(
                  boldFont,
                  regularFont,
                  'Category',
                  category.name,
                  primaryPink,
                ),
                if (expense.location != null) ...[
                  pw.SizedBox(height: 12),
                  _buildBrutalistReceiptRow(
                    boldFont,
                    regularFont,
                    'Location',
                    expense.location!,
                    primaryOrange,
                  ),
                ],
                pw.SizedBox(height: 24),
                pw.Container(
                  width: double.infinity,
                  height: 4,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 20),
                // Total amount with special styling
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: primaryRed,
                    border: pw.Border.all(color: PdfColors.black, width: 4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL AMOUNT',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        _currencyFormat.format(expense.amount),
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBrutalistReceiptRow(
    pw.Font boldFont,
    pw.Font regularFont,
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: color,
          child: pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBrutalistReceiptFooter(
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: darkBg,
        border: pw.Border.all(color: PdfColors.black, width: 4),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for using Magic Ledger!',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 14,
              color: primaryYellow,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Track • Analyze • Achieve',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Todo Components
  pw.Widget _buildBrutalistTodoSummary(
    pw.Font boldFont,
    pw.Font regularFont,
    int total,
    int completed,
    int pending,
    int overdue,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _buildBrutalistSummaryCard(
          boldFont,
          regularFont,
          'TOTAL',
          total.toString(),
          primaryBlue,
          'ALL',
        ),
        _buildBrutalistSummaryCard(
          boldFont,
          regularFont,
          'COMPLETED',
          completed.toString(),
          primaryGreen,
          'DONE',
        ),
        _buildBrutalistSummaryCard(
          boldFont,
          regularFont,
          'PENDING',
          pending.toString(),
          primaryOrange,
          'WAIT',
        ),
        _buildBrutalistSummaryCard(
          boldFont,
          regularFont,
          'OVERDUE',
          overdue.toString(),
          primaryRed,
          'LATE',
        ),
      ],
    );
  }

  pw.Widget _buildBrutalistTodoSection(
    pw.Font boldFont,
    pw.Font regularFont,
    String title,
    List<TodoModel> todos,
    PdfColor color,
    String badge,
  ) {
    return pw.Container(
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(
              width: 500,
              height: math.max(200.0, todos.length * 80.0 + 100),
              color: PdfColors.black,
            ),
          ),
          // Main container
          pw.Container(
            decoration: pw.BoxDecoration(
              color: lightBg,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  color: color,
                  child: pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.black,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(2),
                          ),
                        ),
                        child: pw.Text(
                          badge,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    children:
                        todos
                            .map(
                              (todo) => pw.Container(
                                margin: const pw.EdgeInsets.only(bottom: 12),
                                padding: const pw.EdgeInsets.all(12),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.white,
                                  border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 2,
                                  ),
                                ),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Container(
                                      width: 20,
                                      height: 20,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          color: PdfColors.black,
                                          width: 3,
                                        ),
                                        color:
                                            todo.isCompleted
                                                ? primaryGreen
                                                : PdfColors.white,
                                      ),
                                      child:
                                          todo.isCompleted
                                              ? pw.Center(
                                                child: pw.Text(
                                                  'X',
                                                  style: pw.TextStyle(
                                                    color: PdfColors.black,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 12,
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
                                              font: boldFont,
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold,
                                              decoration:
                                                  todo.isCompleted
                                                      ? pw
                                                          .TextDecoration
                                                          .lineThrough
                                                      : null,
                                            ),
                                          ),
                                          if (todo.description != null) ...[
                                            pw.SizedBox(height: 4),
                                            pw.Text(
                                              todo.description!,
                                              style: pw.TextStyle(
                                                font: regularFont,
                                                fontSize: 10,
                                                color: PdfColors.grey700,
                                              ),
                                            ),
                                          ],
                                          if (todo.dueDate != null) ...[
                                            pw.SizedBox(height: 4),
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
                                                        ? primaryRed
                                                        : PdfColors.grey600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: pw.BoxDecoration(
                                        color: _getBrutalistPriorityColor(
                                          todo.priority,
                                        ),
                                        border: pw.Border.all(
                                          color: PdfColors.black,
                                          width: 2,
                                        ),
                                      ),
                                      child: pw.Text(
                                        _getPriorityLabel(todo.priority),
                                        style: pw.TextStyle(
                                          font: boldFont,
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
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
          ),
        ],
      ),
    );
  }

  // Enhanced Table Components
  pw.Widget _buildBrutalistTableHeader(pw.Font font, String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildBrutalistTableCell(pw.Font font, String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.black),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Enhanced Footer
  pw.Widget _buildBrutalistFooter(pw.Font boldFont, pw.Font regularFont) {
    return pw.Container(
      child: pw.Stack(
        children: [
          // Shadow
          pw.Positioned(
            top: 6,
            left: 6,
            child: pw.Container(width: 500, height: 60, color: PdfColors.black),
          ),
          // Main footer
          pw.Container(
            height: 60,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryPurple,
              border: pw.Border.all(color: PdfColors.black, width: 4),
            ),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Generated by MAGIC LEDGER',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Track • Analyze • Achieve',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Visagan • Visainnovations',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 10,
                      color: PdfColors.black,
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

  // Helper Methods (unchanged functionality)
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
          final category = categories.firstWhere(
            (c) => c.id == entry.key,
            orElse: () => categories.first,
          );
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
    if (expenses.isEmpty) return 0.0;

    final dates =
        expenses
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet();

    final totalDays = dates.length;
    if (totalDays <= 0) return 0.0;

    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final average = totalSpent / totalDays;

    // Return safe value
    return average.isFinite ? average : 0.0;
  }

  PdfColor _getBrutalistPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return primaryRed;
      case 2:
        return primaryOrange;
      default:
        return primaryGreen;
    }
  }

  PdfColor _getPriorityColor(int priority) {
    return _getBrutalistPriorityColor(priority);
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
