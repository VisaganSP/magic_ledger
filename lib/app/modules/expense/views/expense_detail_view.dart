import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/expense_controller.dart';

class ExpenseDetailView extends StatelessWidget {
  final ExpenseModel expense = Get.arguments;
  final CategoryController categoryController = Get.find();
  final ExpenseController expenseController = Get.find();

  ExpenseDetailView({super.key});

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Safely get category with fallback
    final category = _getCategory();
    final categoryIcon = category?.icon ?? '💰';
    final categoryName = category?.name ?? 'Unknown';
    final categoryColor = _getThemedColor(
      category?.colorValue ?? Colors.grey,
      isDark,
    );

    return Scaffold(
      backgroundColor:
          isDark
              ? NeoBrutalismTheme.darkBackground
              : NeoBrutalismTheme.primaryWhite,
      appBar: _buildAppBar(context, categoryColor, isDark),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainInfo(categoryColor, categoryIcon, categoryName, isDark),
          const SizedBox(height: 24),
          _buildDetailsSection(isDark),
          if (expense.tags != null && expense.tags!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTagsSection(isDark),
          ],
          if (expense.receiptPath != null) ...[
            const SizedBox(height: 24),
            _buildReceiptSection(isDark),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(context, isDark),
        ],
      ),
    );
  }

  CategoryModel? _getCategory() {
    try {
      return categoryController.categories.firstWhere(
        (c) => c.id == expense.categoryId,
      );
    } catch (e) {
      // Return first category as fallback
      if (categoryController.categories.isNotEmpty) {
        return categoryController.categories.first;
      }
      return null;
    }
  }

  AppBar _buildAppBar(BuildContext context, Color categoryColor, bool isDark) {
    return AppBar(
      title: const Text(
        'EXPENSE DETAILS',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack,
        ),
      ),
      backgroundColor: categoryColor,
      foregroundColor: NeoBrutalismTheme.primaryBlack,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEdit(),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteDialog(context, isDark),
        ),
      ],
    );
  }

  Widget _buildMainInfo(
    Color categoryColor,
    String categoryIcon,
    String categoryName,
    bool isDark,
  ) {
    return NeoCard(
      color: categoryColor,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        children: [
          _buildExpenseHeader(categoryIcon, categoryName),
          const SizedBox(height: 16),
          _buildDateDisplay(isDark),
        ],
      ),
    );
  }

  Widget _buildExpenseHeader(String categoryIcon, String categoryName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(categoryIcon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildAmountDisplay(),
      ],
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '-₹${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        if (expense.isRecurring) ...[
          const SizedBox(height: 4),
          _buildRecurringBadge(),
        ],
      ],
    );
  }

  Widget _buildRecurringBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.accentPurple,
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        expense.recurringType?.toUpperCase() ?? 'RECURRING',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: NeoBrutalismTheme.primaryWhite,
        ),
      ),
    );
  }

  Widget _buildDateDisplay(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: NeoBrutalismTheme.neoBox(
        color:
            isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 20,
            color:
                isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(expense.date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETAILS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          if (expense.description != null && expense.description!.isNotEmpty)
            _buildDetailRow('Description', expense.description!, isDark),
          if (expense.location != null && expense.location!.isNotEmpty)
            _buildDetailRow('Location', expense.location!, isDark),
          _buildDetailRow(
            'Amount',
            '₹${expense.amount.toStringAsFixed(2)}',
            isDark,
          ),
          _buildDetailRow(
            'Type',
            expense.isRecurring ? 'Recurring' : 'One-time',
            isDark,
          ),
          if (expense.isRecurring)
            _buildDetailRow('Frequency', _getFormattedFrequency(), isDark),
          _buildDetailRow('Created', _formatDateTime(expense.date), isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAGS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                expense.tags!
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: NeoBrutalismTheme.neoBox(
                          color: _getThemedColor(
                            NeoBrutalismTheme.accentYellow,
                            isDark,
                          ),
                          borderColor: NeoBrutalismTheme.primaryBlack,
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: NeoBrutalismTheme.primaryBlack,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECEIPT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.fullscreen,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
                onPressed: () => _showFullScreenReceipt(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showFullScreenReceipt(),
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: NeoBrutalismTheme.neoBox(
                color:
                    isDark
                        ? NeoBrutalismTheme.darkBackground
                        : NeoBrutalismTheme.primaryWhite,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(expense.receiptPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenReceipt() {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(
              File(expense.receiptPath!),
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 64,
                );
              },
            ),
          ),
        ),
      ),
      transition: Transition.fadeIn,
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NeoButton(
                text: 'DUPLICATE',
                onPressed: _duplicateExpense,
                color: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                icon: Icons.copy,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NeoButton(
                text: 'SHARE',
                onPressed: () => _shareExpense(context),
                color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                icon: Icons.share,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: NeoButton(
            text: 'EDIT EXPENSE',
            onPressed: _navigateToEdit,
            color: _getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
            icon: Icons.edit,
          ),
        ),
      ],
    );
  }

  void _navigateToEdit() {
    Get.toNamed(
      '/add-expense',
      arguments: {'expense': expense, 'isEdit': true},
    );
  }

  void _duplicateExpense() {
    final duplicatedExpense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${expense.title} (Copy)',
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: DateTime.now(),
      description: expense.description,
      location: expense.location,
      tags: expense.tags,
      receiptPath: expense.receiptPath,
      isRecurring: expense.isRecurring,
      recurringType: expense.recurringType,
    );

    expenseController.addExpense(duplicatedExpense);

    Get.snackbar(
      'Expense Duplicated',
      'A copy of "${expense.title}" has been created',
      backgroundColor: NeoBrutalismTheme.accentOrange,
      colorText: NeoBrutalismTheme.primaryBlack,
      borderWidth: 3,
      borderColor: NeoBrutalismTheme.primaryBlack,
      duration: const Duration(seconds: 2),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          Get.to(() => ExpenseDetailView(), arguments: duplicatedExpense);
        },
        child: const Text(
          'VIEW',
          style: TextStyle(
            color: NeoBrutalismTheme.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _shareExpense(BuildContext context) {
    final category = _getCategory();
    final shareText =
        '''
Expense: ${expense.title}
Amount: ₹${expense.amount.toStringAsFixed(2)}
Category: ${category?.name ?? 'Unknown'}
Date: ${_formatDate(expense.date)}
Type: ${expense.isRecurring ? 'Recurring (${expense.recurringType})' : 'One-time'}
${expense.description != null ? '\nDescription: ${expense.description}' : ''}
${expense.location != null ? 'Location: ${expense.location}' : ''}
${expense.tags != null && expense.tags!.isNotEmpty ? '\nTags: ${expense.tags!.join(', ')}' : ''}

Shared from Magic Ledger App
    '''.trim();

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));

    Get.snackbar(
      'Share Expense',
      'Expense details copied to clipboard',
      backgroundColor: NeoBrutalismTheme.accentGreen,
      colorText: NeoBrutalismTheme.primaryBlack,
      borderWidth: 3,
      borderColor: NeoBrutalismTheme.primaryBlack,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.check_circle,
        color: NeoBrutalismTheme.primaryBlack,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color:
                isDark
                    ? NeoBrutalismTheme.darkSurface
                    : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'DELETE EXPENSE?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${expense.title}"?',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkBackground
                              : NeoBrutalismTheme.primaryWhite,
                      textColor:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE',
                      onPressed: () {
                        expenseController.deleteExpense(expense.id);
                        Get.back(); // Close dialog
                        Get.back(); // Go back to previous screen
                        Get.snackbar(
                          'Expense Deleted',
                          '${expense.title} has been removed',
                          backgroundColor: Colors.red,
                          colorText: NeoBrutalismTheme.primaryWhite,
                          borderWidth: 3,
                          borderColor: NeoBrutalismTheme.primaryBlack,
                          duration: const Duration(seconds: 2),
                          icon: const Icon(
                            Icons.delete_forever,
                            color: NeoBrutalismTheme.primaryWhite,
                          ),
                        );
                      },
                      color: Colors.red,
                      textColor: NeoBrutalismTheme.primaryWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_formatDate(date)} at $hour:$minute';
  }

  String _getFormattedFrequency() {
    if (expense.recurringType == null) return 'N/A';

    switch (expense.recurringType!.toLowerCase()) {
      case 'daily':
        return 'Every Day';
      case 'weekly':
        return 'Every Week';
      case 'monthly':
        return 'Every Month';
      case 'yearly':
        return 'Every Year';
      default:
        return expense.recurringType!.toUpperCase();
    }
  }
}
