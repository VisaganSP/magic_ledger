import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/backup_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';

class BackupRestoreView extends StatefulWidget {
  const BackupRestoreView({super.key});

  @override
  State<BackupRestoreView> createState() => _BackupRestoreViewState();
}

class _BackupRestoreViewState extends State<BackupRestoreView> {
  final BackupService _backupService = BackupService();
  final TextEditingController _passphraseCtrl = TextEditingController();
  bool _isProcessing = false;
  bool _obscurePass = true;

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
          _buildHeader(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Passphrase input
                  _buildPassphraseSection(isDark),
                  const SizedBox(height: 24),

                  // Backup section
                  _buildBackupSection(isDark),
                  const SizedBox(height: 24),

                  // Restore section
                  _buildRestoreSection(isDark),
                  const SizedBox(height: 24),

                  // Info section
                  _buildInfoSection(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(NeoBrutalismTheme.accentSkyBlue, isDark),
        border: const Border(bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(Get.context!).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(Icons.arrow_back,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BACKUP & RESTORE', style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w900, letterSpacing: -0.5,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              Text('Encrypted • Offline • Secure', style: TextStyle(fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[700])),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildPassphraseSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PASSPHRASE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 6),
        Text('Used to encrypt and decrypt your backup. Remember this!',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600])),
        const SizedBox(height: 10),
        Container(
          decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: TextField(
            controller: _passphraseCtrl,
            obscureText: _obscurePass,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            decoration: InputDecoration(
              hintText: 'Enter passphrase (e.g. your PIN)',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[600] : Colors.grey[400]),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.grey[500] : Colors.grey[600]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackupSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(
        color: _t(NeoBrutalismTheme.accentGreen, isDark),
        offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.primaryBlack,
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                ),
                child: const Icon(Icons.cloud_upload, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CREATE BACKUP', style: TextStyle(fontSize: 17,
                        fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
                    const Text('Export all data as encrypted file',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Includes: expenses, incomes, todos, budgets, categories, accounts, '
              'savings goals, debts, splits, subscriptions, templates, and moods.',
              style: TextStyle(fontSize: 11, height: 1.5, color: Colors.black54)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: NeoButton(
              text: _isProcessing ? 'CREATING...' : 'BACKUP & SHARE',
              onPressed: _isProcessing ? () {} : _createBackup,
              color: NeoBrutalismTheme.primaryWhite,
              icon: Icons.share,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(
        color: _t(NeoBrutalismTheme.accentPurple, isDark),
        offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.primaryBlack,
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                ),
                child: const Icon(Icons.cloud_download, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RESTORE FROM BACKUP', style: TextStyle(fontSize: 17,
                        fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
                    const Text('Import an encrypted .mlbackup file',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              border: Border.all(color: Colors.red, width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('This will REPLACE all current data. Create a backup first!',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: NeoButton(
              text: _isProcessing ? 'RESTORING...' : 'SELECT FILE & RESTORE',
              onPressed: _isProcessing ? () {} : _restoreBackup,
              color: NeoBrutalismTheme.primaryWhite,
              icon: Icons.file_open,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[100],
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HOW IT WORKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.grey[400] : Colors.grey[700])),
          const SizedBox(height: 8),
          Text(
            '• Your data is compressed and encrypted with your passphrase\n'
                '• The .mlbackup file can be saved to Drive, email, or anywhere\n'
                '• To restore, use the same passphrase — wrong passphrase = no access\n'
                '• No data is sent to any server — everything stays on your device\n'
                '• Back up regularly to avoid data loss!',
            style: TextStyle(fontSize: 12, height: 1.6,
                color: isDark ? Colors.grey[500] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    final pass = _passphraseCtrl.text.trim();
    if (pass.isEmpty) {
      Get.snackbar('Passphrase Required', 'Enter a passphrase to encrypt your backup',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100], colorText: Colors.orange[900]);
      return;
    }
    if (pass.length < 4) {
      Get.snackbar('Too Short', 'Passphrase must be at least 4 characters',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100], colorText: Colors.orange[900]);
      return;
    }

    setState(() => _isProcessing = true);
    await _backupService.backupAndShare(pass);
    setState(() => _isProcessing = false);
  }

  Future<void> _restoreBackup() async {
    final pass = _passphraseCtrl.text.trim();
    if (pass.isEmpty) {
      Get.snackbar('Passphrase Required', 'Enter the passphrase used during backup',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100], colorText: Colors.orange[900]);
      return;
    }

    try {
      const typeGroup = XTypeGroup(
        label: 'Magic Ledger Backup',
        extensions: ['mlbackup'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;

      // Confirm
      final confirmed = await Get.dialog<bool>(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: NeoBrutalismTheme.neoBoxRounded(
              color: Theme.of(context).brightness == Brightness.dark
                  ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text('RESTORE DATA?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                const SizedBox(height: 8),
                Text('This will replace ALL current data with the backup. This cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Get.back(result: false),
                        color: NeoBrutalismTheme.primaryWhite)),
                    const SizedBox(width: 12),
                    Expanded(child: NeoButton(text: 'RESTORE', onPressed: () => Get.back(result: true),
                        color: Colors.red, textColor: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed != true) return;

      setState(() => _isProcessing = true);
      await _backupService.restoreBackup(file.path, pass);
      setState(() => _isProcessing = false);
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar('Error', 'Could not open file: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    _passphraseCtrl.dispose();
    super.dispose();
  }
}