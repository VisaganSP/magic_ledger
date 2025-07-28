import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/income_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/income_controller.dart';

class IncomeDetailView extends StatelessWidget {
  final IncomeModel income = Get.arguments;
  final IncomeController incomeController = Get.find();

  IncomeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainInfo(),
          const SizedBox(height: 24),
          _buildDetailsSection(),
          const SizedBox(height: 32),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'INCOME DETAILS',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      backgroundColor: NeoBrutalismTheme.accentGreen,
      foregroundColor: NeoBrutalismTheme.primaryBlack,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEdit(),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteDialog(context),
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return NeoCard(
      color: NeoBrutalismTheme.accentGreen,
      child: Column(
        children: [
          _buildIncomeHeader(),
          const SizedBox(height: 16),
          _buildDateDisplay(),
        ],
      ),
    );
  }

  Widget _buildIncomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                income.title,
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
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 24,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      income.source,
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
          '+₹${income.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        if (income.isRecurring) ...[
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
        income.recurringType?.toUpperCase() ?? 'RECURRING',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: NeoBrutalismTheme.primaryWhite,
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: NeoBrutalismTheme.neoBox(
        color: NeoBrutalismTheme.primaryWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 20,
            color: NeoBrutalismTheme.primaryBlack,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(income.date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETAILS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          if (income.description != null && income.description!.isNotEmpty)
            _buildDetailRow('Description', income.description!),
          _buildDetailRow('Source', income.source),
          _buildDetailRow(
            'Type',
            income.isRecurring ? 'Recurring' : 'One-time',
          ),
          if (income.isRecurring)
            _buildDetailRow('Frequency', _getFormattedFrequency()),
          _buildDetailRow('Created', _formatDateTime(income.date)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NeoButton(
                text: 'DUPLICATE',
                onPressed: _duplicateIncome,
                color: NeoBrutalismTheme.accentBlue,
                icon: Icons.copy,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NeoButton(
                text: 'SHARE',
                onPressed: () => _shareIncome(context),
                color: NeoBrutalismTheme.accentPurple,
                icon: Icons.share,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: NeoButton(
            text: 'EDIT INCOME',
            onPressed: _navigateToEdit,
            color: NeoBrutalismTheme.accentGreen,
            icon: Icons.edit,
          ),
        ),
      ],
    );
  }

  void _navigateToEdit() {
    Get.toNamed('/add-income', arguments: {'income': income, 'isEdit': true});
  }

  void _duplicateIncome() {
    final duplicatedIncome = IncomeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${income.title} (Copy)',
      amount: income.amount,
      source: income.source,
      date: DateTime.now(),
      description: income.description,
      isRecurring: income.isRecurring,
      recurringType: income.recurringType,
    );

    incomeController.addIncome(duplicatedIncome);

    Get.snackbar(
      'Income Duplicated',
      'A copy of "${income.title}" has been created',
      backgroundColor: NeoBrutalismTheme.accentGreen,
      colorText: NeoBrutalismTheme.primaryBlack,
      borderWidth: 3,
      borderColor: NeoBrutalismTheme.primaryBlack,
      duration: const Duration(seconds: 2),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          Get.to(() => IncomeDetailView(), arguments: duplicatedIncome);
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

  void _shareIncome(BuildContext context) {
    final shareText =
        '''
Income: ${income.title}
Amount: ₹${income.amount.toStringAsFixed(2)}
Source: ${income.source}
Date: ${_formatDate(income.date)}
Type: ${income.isRecurring ? 'Recurring (${income.recurringType})' : 'One-time'}
${income.description != null ? '\nDescription: ${income.description}' : ''}

Shared from Magic Ledger App
    '''.trim();

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));

    Get.snackbar(
      'Share Income',
      'Income details copied to clipboard',
      backgroundColor: NeoBrutalismTheme.accentPurple,
      colorText: NeoBrutalismTheme.primaryWhite,
      borderWidth: 3,
      borderColor: NeoBrutalismTheme.primaryBlack,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.check_circle,
        color: NeoBrutalismTheme.primaryWhite,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color: NeoBrutalismTheme.primaryWhite,
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
              const Text(
                'DELETE INCOME?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${income.title}"?',
                style: const TextStyle(
                  fontSize: 16,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
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
                      color: NeoBrutalismTheme.primaryWhite,
                      textColor: NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE',
                      onPressed: () {
                        incomeController.deleteIncome(income.id);
                        Get.back(); // Close dialog
                        Get.back(); // Go back to previous screen
                        Get.snackbar(
                          'Income Deleted',
                          '${income.title} has been removed',
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
    if (income.recurringType == null) return 'N/A';

    switch (income.recurringType!.toLowerCase()) {
      case 'daily':
        return 'Every Day';
      case 'weekly':
        return 'Every Week';
      case 'monthly':
        return 'Every Month';
      case 'yearly':
        return 'Every Year';
      default:
        return income.recurringType!.toUpperCase();
    }
  }
}
