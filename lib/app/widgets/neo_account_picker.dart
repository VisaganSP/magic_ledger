import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/account_model.dart';
import '../../app/modules/account/controllers/account_controller.dart';
import '../../app/theme/neo_brutalism_theme.dart';

/// A neo-brutalist account picker widget for use in expense/income forms.
///
/// Usage:
/// ```dart
/// NeoAccountPicker(
///   selectedAccountId: selectedAccountId, // RxnString
///   isDark: isDark,
///   label: 'ACCOUNT',
/// )
/// ```
class NeoAccountPicker extends StatelessWidget {
  final Rxn<String> selectedAccountId;
  final bool isDark;
  final String label;

  const NeoAccountPicker({
    super.key,
    required this.selectedAccountId,
    required this.isDark,
    this.label = 'ACCOUNT',
  });

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final accounts = accountController.accounts;

          if (accounts.isEmpty) {
            return GestureDetector(
              onTap: () => Get.toNamed('/accounts'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: NeoBrutalismTheme.neoBox(
                  color: isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
                  offset: 3,
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 20,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Add an account first',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Auto-select default account if nothing selected
          if (selectedAccountId.value == null) {
            final defaultAcc = accountController.getDefaultAccount();
            if (defaultAcc != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                selectedAccountId.value = defaultAcc.id;
              });
            }
          }

          return Container(
            decoration: NeoBrutalismTheme.neoBox(
              color: isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite,
              offset: 3,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Column(
              children: [
                // Horizontal scrollable account chips
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isSelected =
                          selectedAccountId.value == account.id;

                      return GestureDetector(
                        onTap: () =>
                        selectedAccountId.value = account.id,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? account.colorValue
                                : (isDark
                                ? NeoBrutalismTheme.darkBackground
                                : Colors.grey[100]),
                            border: Border.all(
                              color: isSelected
                                  ? NeoBrutalismTheme.primaryBlack
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isSelected
                                ? [
                              const BoxShadow(
                                color: NeoBrutalismTheme.primaryBlack,
                                offset: Offset(2, 2),
                              )
                            ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(account.icon,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                account.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? NeoBrutalismTheme.primaryBlack
                                      : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}