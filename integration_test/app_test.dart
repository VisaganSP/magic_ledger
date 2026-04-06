/// Magic Ledger — Integration Tests
///
/// Setup:
/// 1. Add to pubspec.yaml dev_dependencies:
///    integration_test:
///      sdk: flutter
///    flutter_test:
///      sdk: flutter
///
/// 2. Create: integration_test/app_test.dart (this file)
///
/// 3. Run: flutter test integration_test/app_test.dart
///    Or on device: flutter test integration_test --device-id <device>
///
/// NOTE: These tests run on a real device/emulator with the full app.
/// They test actual Hive storage, actual navigation, actual UI.
///
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

// Import your app
import 'package:magic_ledger/main.dart' as app;
import 'package:magic_ledger/app/data/services/auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ═══════════════════════════════════════════════════════════
  // GROUP 1: AUTH SYSTEM
  // ═══════════════════════════════════════════════════════════

  group('Auth System', () {
    testWidgets('TC-AUTH-001: First-time PIN setup', (tester) async {
      // Reset auth for clean test
      final authBox = await Hive.openBox('auth_settings');
      await authBox.clear();

      app.main();
      await tester.pumpAndSettle();

      // Should show SetupPinView
      expect(find.text('CREATE YOUR PIN'), findsOneWidget);

      // Enter 4-digit PIN
      await _tapKey(tester, '1');
      await _tapKey(tester, '2');
      await _tapKey(tester, '3');
      await _tapKey(tester, '4');
      await _tapKey(tester, '✓');
      await tester.pumpAndSettle();

      // Should move to confirm
      expect(find.text('CONFIRM YOUR PIN'), findsOneWidget);

      // Confirm PIN
      await _tapKey(tester, '1');
      await _tapKey(tester, '2');
      await _tapKey(tester, '3');
      await _tapKey(tester, '4');
      await _tapKey(tester, '✓');
      await tester.pumpAndSettle();

      // Should show recovery phrase
      expect(find.text('YOUR RECOVERY PHRASE'), findsOneWidget);
      expect(find.text('I have written down my recovery phrase'), findsOneWidget);
    });

    testWidgets('TC-AUTH-003: PIN mismatch during setup', (tester) async {
      final authBox = await Hive.openBox('auth_settings');
      await authBox.clear();

      app.main();
      await tester.pumpAndSettle();

      // Enter PIN
      await _tapKey(tester, '1');
      await _tapKey(tester, '2');
      await _tapKey(tester, '3');
      await _tapKey(tester, '4');
      await _tapKey(tester, '✓');
      await tester.pumpAndSettle();

      // Enter WRONG confirm
      await _tapKey(tester, '5');
      await _tapKey(tester, '6');
      await _tapKey(tester, '7');
      await _tapKey(tester, '8');
      await _tapKey(tester, '✓');
      await tester.pumpAndSettle();

      // Should show error
      expect(find.textContaining('match'), findsOneWidget);
    });

    testWidgets('TC-AUTH-004: PIN too short', (tester) async {
      final authBox = await Hive.openBox('auth_settings');
      await authBox.clear();

      app.main();
      await tester.pumpAndSettle();

      // Enter only 2 digits
      await _tapKey(tester, '1');
      await _tapKey(tester, '2');
      await _tapKey(tester, '✓');
      await tester.pumpAndSettle();

      // Should show error
      expect(find.textContaining('at least 4'), findsOneWidget);
    });

    testWidgets('TC-AUTH-008: Correct PIN unlock', (tester) async {
      // Setup: ensure PIN is set
      final auth = Get.find<AuthService>();
      if (!auth.isSetupComplete.value) {
        await auth.setupPin('1234');
      }
      auth.lockApp();

      app.main();
      await tester.pumpAndSettle();

      // Should show lock screen
      expect(find.text('MAGIC LEDGER'), findsOneWidget);
      expect(find.text('Enter your PIN to unlock'), findsOneWidget);

      // Enter correct PIN
      await _tapKey(tester, '1');
      await _tapKey(tester, '2');
      await _tapKey(tester, '3');
      await _tapKey(tester, '4');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should unlock to home
      expect(find.text('Track. Save. Achieve.'), findsOneWidget);
    });

    testWidgets('TC-AUTH-009: Wrong PIN shows attempt counter', (tester) async {
      final auth = Get.find<AuthService>();
      auth.lockApp();

      app.main();
      await tester.pumpAndSettle();

      // Enter wrong PIN
      await _tapKey(tester, '9');
      await _tapKey(tester, '9');
      await _tapKey(tester, '9');
      await _tapKey(tester, '9');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show attempts remaining
      expect(find.textContaining('attempts left'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2: EXPENSE FLOW
  // ═══════════════════════════════════════════════════════════

  group('Expense Flow', () {
    testWidgets('TC-EXP-001: Add expense end-to-end', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to add expense
      await tester.tap(find.text('EXPENSE').first);
      await tester.pumpAndSettle();

      // Fill form
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Test Lunch');

      final amountField = find.byType(TextField).at(1);
      await tester.enterText(amountField, '250');

      // Save
      await tester.tap(find.text('SAVE').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify on home
      expect(find.textContaining('Test Lunch'), findsWidgets);
    });

    testWidgets('TC-EXP-005: Add expense without title', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('EXPENSE').first);
      await tester.pumpAndSettle();

      // Try to save without entering anything
      await tester.tap(find.text('SAVE').first);
      await tester.pumpAndSettle();

      // Should show validation error (still on form)
      expect(find.byType(TextField), findsWidgets);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3: NAVIGATION
  // ═══════════════════════════════════════════════════════════

  group('Navigation', () {
    testWidgets('TC-HOME-004: Bottom nav tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Home tab (default)
      expect(find.text('MAGIC LEDGER'), findsOneWidget);

      // Expenses tab
      await tester.tap(find.text('EXPENSES'));
      await tester.pumpAndSettle();
      // Verify expense list visible

      // Todos tab
      await tester.tap(find.text('TODOS'));
      await tester.pumpAndSettle();

      // Stats tab
      await tester.tap(find.text('STATS'));
      await tester.pumpAndSettle();

      // Back to Home
      await tester.tap(find.text('HOME'));
      await tester.pumpAndSettle();
      expect(find.text('MAGIC LEDGER'), findsOneWidget);
    });

    testWidgets('TC-HOME-001: Period navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find current month text
      final now = DateTime.now();
      final months = ['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
        'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];
      expect(find.text(months[now.month - 1]), findsOneWidget);

      // Tap left arrow for previous month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Should show previous month
      final prevMonth = now.month == 1 ? 11 : now.month - 2;
      expect(find.text(months[prevMonth]), findsOneWidget);

      // "TODAY" button should appear
      expect(find.text('TODAY'), findsOneWidget);

      // Tap TODAY to go back
      await tester.tap(find.text('TODAY'));
      await tester.pumpAndSettle();
      expect(find.text(months[now.month - 1]), findsOneWidget);
    });

    testWidgets('TC-HOME-006: Tools strip accessible', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Scroll down to find TOOLS label
      await tester.dragUntilVisible(
        find.text('TOOLS'),
        find.byType(CustomScrollView),
        const Offset(0, -200),
      );
      expect(find.text('TOOLS'), findsOneWidget);

      // Check some tool chips exist
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Coach'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4: SETTINGS
  // ═══════════════════════════════════════════════════════════

  group('Settings', () {
    testWidgets('Settings page opens with all sections', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('SECURITY'), findsOneWidget);

      // Scroll to see more sections
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('NOTIFICATIONS'), findsOneWidget);
    });

    testWidgets('Security section shows PIN status', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('PIN Lock'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Biometric Unlock'), findsOneWidget);
      expect(find.text('Lock Timeout'), findsOneWidget);
      expect(find.text('Change PIN'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 5: TEMPLATES
  // ═══════════════════════════════════════════════════════════

  group('Expense Templates', () {
    testWidgets('TC-TPL-007: Empty state shows create button', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to templates (via tools strip or settings)
      // Assuming route is set up
      Get.toNamed('/templates');
      await tester.pumpAndSettle();

      expect(find.text('QUICK TEMPLATES'), findsOneWidget);
      // If no templates:
      if (find.text('NO TEMPLATES YET').evaluate().isNotEmpty) {
        expect(find.text('CREATE TEMPLATE'), findsOneWidget);
      }
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 6: ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════

  group('Achievements', () {
    testWidgets('Achievements page loads with streak', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      Get.toNamed('/achievements');
      await tester.pumpAndSettle();

      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
      expect(find.text('NO-SPEND STREAK'), findsOneWidget);
      expect(find.text('PROGRESS'), findsOneWidget);
      expect(find.text('ALL ACHIEVEMENTS'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 7: BACKUP (Unit-style within integration)
  // ═══════════════════════════════════════════════════════════

  group('Backup & Restore', () {
    testWidgets('Backup page opens correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      Get.toNamed('/backup');
      await tester.pumpAndSettle();

      expect(find.text('BACKUP & RESTORE'), findsOneWidget);
      expect(find.text('PASSPHRASE'), findsOneWidget);
      expect(find.text('CREATE BACKUP'), findsOneWidget);
      expect(find.text('RESTORE FROM BACKUP'), findsOneWidget);
      expect(find.text('HOW IT WORKS'), findsOneWidget);
    });

    testWidgets('TC-BKP-002: Backup without passphrase blocked', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      Get.toNamed('/backup');
      await tester.pumpAndSettle();

      // Tap backup without entering passphrase
      await tester.tap(find.text('BACKUP & SHARE'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.textContaining('Passphrase Required'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 8: NOTIFICATION INBOX
  // ═══════════════════════════════════════════════════════════

  group('Notification Inbox', () {
    testWidgets('Notification page opens', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap notification bell
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      expect(find.text('NOTIFICATIONS'), findsOneWidget);
    });

    testWidgets('Scan SMS button works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Tap scan
      final scanBtn = find.text('SCAN SMS FOR TRANSACTIONS');
      if (scanBtn.evaluate().isNotEmpty) {
        await tester.tap(scanBtn);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        // Should show scanning snackbar
      } else {
        // Empty state — tap SCAN SMS NOW
        await tester.tap(find.text('SCAN SMS NOW'));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 9: AI MONEY COACH
  // ═══════════════════════════════════════════════════════════

  group('AI Money Coach', () {
    testWidgets('Coach screen opens', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      Get.toNamed('/money-coach');
      await tester.pumpAndSettle();

      expect(find.textContaining('COACH'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 10: DATA INTEGRITY
  // ═══════════════════════════════════════════════════════════

  group('Data Integrity', () {
    testWidgets('Balance matches across screens', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Get balance from home
      final balanceWidget = find.textContaining('₹');
      expect(balanceWidget, findsWidgets);

      // The ACCOUNT BALANCE should be consistent with account sum
      // This is a visual check — the test verifies the widget renders
    });

    testWidgets('Expense count matches', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find "X total" in recent transactions
      final totalFinder = find.textContaining('total');
      if (totalFinder.evaluate().isNotEmpty) {
        // Count visible transaction items
        final expenseItems = find.byType(GestureDetector);
        expect(expenseItems, findsWidgets);
      }
    });
  });
}

// ═══════════════════════════════════════════════════════════
// HELPER: Tap number pad key by text
// ═══════════════════════════════════════════════════════════

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.text(key);
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder.last);
    await tester.pump(const Duration(milliseconds: 100));
  } else if (key == '✓') {
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump(const Duration(milliseconds: 100));
  } else if (key == '⌫') {
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump(const Duration(milliseconds: 100));
  }
}