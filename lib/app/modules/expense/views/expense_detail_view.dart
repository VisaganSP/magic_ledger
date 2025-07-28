import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';

class ExpenseDetailView extends StatelessWidget {
  final ExpenseModel expense = Get.arguments;
  final CategoryController categoryController = Get.find();

  const ExpenseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final category = categoryController.categories.firstWhere(
      (c) => c.id == expense.categoryId,
    );

    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('EXPENSE DETAILS'),
        backgroundColor: category.colorValue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainInfo(category),
          const SizedBox(height: 24),
          _buildDetailsSection(),
          if (expense.tags != null && expense.tags!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTagsSection(),
          ],
          if (expense.receiptPath != null) ...[
            const SizedBox(height: 24),
            _buildReceiptSection(),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMainInfo(CategoryModel category) {
    return NeoCard(
      color: category.colorValue,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.primaryWhite,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          if (expense.description != null && expense.description!.isNotEmpty)
            _buildDetailRow('Description', expense.description!),
          if (expense.location != null && expense.location!.isNotEmpty)
            _buildDetailRow('Location', expense.location!),
          if (expense.isRecurring)
            _buildDetailRow('Recurring', expense.recurringType!.toUpperCase()),
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
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TAGS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                          color: NeoBrutalismTheme.accentYellow,
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECEIPT',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: NeoBrutalismTheme.neoBox(),
            child: ClipRRect(
              child: Image.file(File(expense.receiptPath!), fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: NeoButton(
            text: 'DUPLICATE',
            onPressed: () {
              // Duplicate expense
            },
            color: NeoBrutalismTheme.accentBlue,
            icon: Icons.copy,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeoButton(
            text: 'SHARE',
            onPressed: () {
              // Share expense
            },
            color: NeoBrutalismTheme.accentGreen,
            icon: Icons.share,
          ),
        ),
      ],
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
              const Text(
                'DELETE EXPENSE?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color: NeoBrutalismTheme.primaryWhite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE',
                      onPressed: () {
                        Get.back();
                        Get.back();
                        // Delete expense
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
}
