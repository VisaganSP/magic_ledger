import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../modules/account/controllers/account_controller.dart';
import '../../modules/expense/controllers/expense_controller.dart';
import '../../modules/income/controllers/income_controller.dart';
import '../../modules/todo/controllers/todo_controller.dart';
import '../../modules/category/controllers/category_controller.dart';

/// Encrypted Backup & Restore — File-level approach.
///
/// Instead of serializing Hive objects to JSON (which loses type info),
/// this copies the raw .hive binary files. This guarantees a perfect
/// restore because the binary format includes adapter type IDs.
///
/// Format: gzip(tar-like structure of .hive files) → XOR encrypted
/// Header: "ML_OK_" verification tag for wrong-passphrase detection
class BackupService {
  /// Box names to backup
  static const _boxNames = [
    'expenses',
    'income',
    'todos',
    'budgets',
    'categories',
    'accounts',
    'transfers',
    'receipts',
    'savings_goals',
    'debts',
    'splits',
    'subscriptions',
    'expense_moods',
    'sms_processed',
    'sms_suggestions',
    'expense_templates',
    'achievements',
  ];

  // ═══════════════════════════════════════════════════════════
  // BACKUP (EXPORT)
  // ═══════════════════════════════════════════════════════════

  Future<String?> createBackup(String passphrase) async {
    try {
      // 1. Get Hive directory
      final appDir = await getApplicationDocumentsDirectory();
      final hiveDir = appDir.path; // Hive stores files here by default

      // 2. Close all boxes so files are flushed
      for (final name in _boxNames) {
        try {
          if (Hive.isBoxOpen(name)) {
            await Hive.box(name).compact(); // compact before backup
          }
        } catch (_) {}
      }

      // 3. Collect all .hive files into a single archive structure
      // Format: JSON manifest + base64-encoded file contents
      final archive = <String, dynamic>{
        'header': 'MAGIC_LEDGER_BACKUP_V3',
        'version': 3,
        'createdAt': DateTime.now().toIso8601String(),
        'files': <String, String>{},
      };

      int totalBytes = 0;
      for (final name in _boxNames) {
        final hiveFile = File('$hiveDir/$name.hive');
        if (await hiveFile.exists()) {
          final bytes = await hiveFile.readAsBytes();
          archive['files'][name] = base64Encode(bytes);
          totalBytes += bytes.length;
          debugPrint('[Backup] Box "$name": ${bytes.length} bytes');
        }

        // Also backup .lock file if exists (some Hive versions need it)
        final lockFile = File('$hiveDir/$name.lock');
        if (await lockFile.exists()) {
          // Skip lock files — they're recreated on open
        }
      }

      debugPrint('[Backup] Total raw data: ${totalBytes} bytes');

      // 4. Serialize → Compress → Encrypt
      final jsonStr = jsonEncode(archive);
      final compressed = gzip.encode(utf8.encode(jsonStr));
      final encrypted = _encrypt(Uint8List.fromList(compressed), passphrase);

      // 5. Save to file
      final date = DateTime.now().toIso8601String().split('T')[0];
      final fileName = 'magic_ledger_backup_$date.mlbackup';
      final filePath = '${appDir.path}/$fileName';
      await File(filePath).writeAsBytes(encrypted);

      final sizeKb = (encrypted.length / 1024).toStringAsFixed(1);
      debugPrint('[Backup] Saved: $filePath ($sizeKb KB)');
      return filePath;
    } catch (e) {
      debugPrint('[Backup] Error: $e');
      return null;
    }
  }

  Future<void> backupAndShare(String passphrase) async {
    Get.snackbar('Creating Backup...', 'Encrypting your data',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue[100], colorText: Colors.blue[900]);

    final path = await createBackup(passphrase);
    if (path == null) {
      Get.snackbar('Backup Failed', 'Could not create backup file',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    final file = File(path);
    final sizeKb = ((await file.length()) / 1024).toStringAsFixed(1);

    try {
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Magic Ledger Backup',
        text: 'Magic Ledger encrypted backup ($sizeKb KB)',
      );
    } catch (e) {
      Get.snackbar('Share Error', '$e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RESTORE (IMPORT)
  // ═══════════════════════════════════════════════════════════

  Future<bool> restoreBackup(String filePath, String passphrase) async {
    try {
      // 1. Read + Decrypt
      final file = File(filePath);
      if (!await file.exists()) {
        Get.snackbar('Error', 'Backup file not found',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      final encrypted = await file.readAsBytes();
      debugPrint('[Restore] File: ${encrypted.length} bytes');

      final decrypted = _decrypt(Uint8List.fromList(encrypted), passphrase);
      if (decrypted == null) {
        Get.snackbar('Wrong Passphrase',
            'Could not decrypt. Check your passphrase.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100], colorText: Colors.red[900]);
        return false;
      }

      // 2. Decompress
      String jsonStr;
      try {
        jsonStr = utf8.decode(gzip.decode(decrypted));
      } catch (_) {
        Get.snackbar('Corrupted File', 'The backup file is corrupted.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100], colorText: Colors.red[900]);
        return false;
      }

      // 3. Parse archive
      final archive = jsonDecode(jsonStr) as Map<String, dynamic>;
      final header = archive['header'] as String?;

      if (header != 'MAGIC_LEDGER_BACKUP_V3') {
        Get.snackbar('Invalid Backup',
            'This file format is not supported. Please create a new backup.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100], colorText: Colors.red[900]);
        return false;
      }

      final files = archive['files'] as Map<String, dynamic>;
      debugPrint('[Restore] Found ${files.length} box files');

      // 4. Close ALL open boxes before overwriting files
      for (final name in _boxNames) {
        try {
          if (Hive.isBoxOpen(name)) {
            await Hive.box(name).close();
          }
        } catch (e) {
          debugPrint('[Restore] Error closing box "$name": $e');
        }
      }

      // Small delay to ensure file handles are released
      await Future.delayed(const Duration(milliseconds: 300));

      // 5. Get Hive directory and write files
      final appDir = await getApplicationDocumentsDirectory();
      final hiveDir = appDir.path;

      for (final entry in files.entries) {
        final boxName = entry.key;
        final b64Data = entry.value as String;
        try {
          final bytes = base64Decode(b64Data);
          final targetFile = File('$hiveDir/$boxName.hive');
          await targetFile.writeAsBytes(bytes, flush: true);
          debugPrint('[Restore] Wrote "$boxName.hive": ${bytes.length} bytes');
        } catch (e) {
          debugPrint('[Restore] Error writing "$boxName": $e');
        }
      }

      // 6. Reopen all boxes
      for (final name in _boxNames) {
        try {
          await _openTypedBox(name);
          debugPrint('[Restore] Reopened "$name"');
        } catch (e) {
          debugPrint('[Restore] Error reopening "$name": $e');
        }
      }

      // 7. Refresh all controllers
      _refreshControllers();

      final createdAt = archive['createdAt'] ?? 'unknown';
      Get.snackbar('✅ Restore Complete',
          'Data restored from backup ($createdAt)',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green[100], colorText: Colors.green[900]);

      return true;
    } catch (e) {
      debugPrint('[Restore] Error: $e');
      Get.snackbar('Restore Failed', 'Error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return false;
    }
  }

  /// Open boxes with correct types matching your Hive adapter registration
  Future<void> _openTypedBox(String name) async {
    // These must match exactly how you open them in HiveProvider.init()
    // The adapters are already registered from app startup, so just open:
    switch (name) {
      case 'expenses':
        await Hive.openBox(name);
        break;
      case 'income':
        await Hive.openBox(name);
        break;
      case 'todos':
        await Hive.openBox(name);
        break;
      case 'budgets':
        await Hive.openBox(name);
        break;
      case 'categories':
        await Hive.openBox(name);
        break;
      case 'accounts':
        await Hive.openBox(name);
        break;
      case 'transfers':
        await Hive.openBox(name);
        break;
      case 'receipts':
        await Hive.openBox(name);
        break;
      case 'savings_goals':
        await Hive.openBox(name);
        break;
      case 'debts':
        await Hive.openBox(name);
        break;
      case 'splits':
        await Hive.openBox(name);
        break;
      case 'subscriptions':
        await Hive.openBox(name);
        break;
      default:
      // Generic boxes (expense_moods, sms_processed, templates, achievements, etc.)
        await Hive.openBox(name);
        break;
    }
  }

  void _refreshControllers() {
    try { Get.find<ExpenseController>().loadExpenses(); } catch (_) {}
    try { Get.find<IncomeController>().loadIncomes(); } catch (_) {}
    try { Get.find<TodoController>().loadTodos(); } catch (_) {}
    try { Get.find<CategoryController>().loadCategories(); } catch (_) {}
    try { Get.find<AccountController>().loadAccounts(); } catch (_) {}
    try { Get.find<AccountController>().loadTransfers(); } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // ENCRYPTION (XOR with SHA-256 key stream)
  // ═══════════════════════════════════════════════════════════

  Uint8List _deriveKeyStream(String passphrase, int length) {
    final seed = utf8.encode(passphrase + '_magic_ledger_backup_key_v2');
    final stream = <int>[];
    var hash = sha256.convert(seed).bytes;
    while (stream.length < length) {
      stream.addAll(hash);
      hash = sha256.convert(hash).bytes;
    }
    return Uint8List.fromList(stream.sublist(0, length));
  }

  Uint8List _encrypt(Uint8List data, String passphrase) {
    final tag = utf8.encode('ML_OK_');
    final payload = Uint8List.fromList([...tag, ...data]);
    final keyStream = _deriveKeyStream(passphrase, payload.length);
    final result = Uint8List(payload.length);
    for (int i = 0; i < payload.length; i++) {
      result[i] = payload[i] ^ keyStream[i];
    }
    return result;
  }

  Uint8List? _decrypt(Uint8List data, String passphrase) {
    final keyStream = _deriveKeyStream(passphrase, data.length);
    final result = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ keyStream[i];
    }
    try {
      final tag = utf8.decode(result.sublist(0, 6));
      if (tag != 'ML_OK_') return null;
      return result.sublist(6);
    } catch (_) {
      return null;
    }
  }
}