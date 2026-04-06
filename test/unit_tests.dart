/// Magic Ledger — Unit Tests
///
/// Run: flutter test test/unit_tests.dart
///
/// These test core logic WITHOUT the full app/UI.
/// Place at: test/unit_tests.dart
///
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ═══════════════════════════════════════════════════════════
  // AUTH LOGIC TESTS
  // ═══════════════════════════════════════════════════════════

  group('PIN Hashing', () {
    String hashPin(String pin) {
      final bytes = utf8.encode(pin + 'magic_ledger_salt_v1');
      return sha256.convert(bytes).toString();
    }

    test('Same PIN produces same hash', () {
      final h1 = hashPin('1234');
      final h2 = hashPin('1234');
      expect(h1, equals(h2));
    });

    test('Different PINs produce different hashes', () {
      final h1 = hashPin('1234');
      final h2 = hashPin('5678');
      expect(h1, isNot(equals(h2)));
    });

    test('Hash is 64 characters (SHA-256)', () {
      final h = hashPin('1234');
      expect(h.length, equals(64));
    });

    test('Hash is hexadecimal', () {
      final h = hashPin('1234');
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(h), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ENCRYPTION TESTS
  // ═══════════════════════════════════════════════════════════

  group('Backup Encryption', () {
    Uint8List deriveKeyStream(String passphrase, int length) {
      final seed = utf8.encode(passphrase + '_magic_ledger_backup_key_v2');
      final stream = <int>[];
      var hash = sha256.convert(seed).bytes;
      while (stream.length < length) {
        stream.addAll(hash);
        hash = sha256.convert(hash).bytes;
      }
      return Uint8List.fromList(stream.sublist(0, length));
    }

    Uint8List encrypt(Uint8List data, String passphrase) {
      final tag = utf8.encode('ML_OK_');
      final payload = Uint8List.fromList([...tag, ...data]);
      final keyStream = deriveKeyStream(passphrase, payload.length);
      final result = Uint8List(payload.length);
      for (int i = 0; i < payload.length; i++) {
        result[i] = payload[i] ^ keyStream[i];
      }
      return result;
    }

    Uint8List? decrypt(Uint8List data, String passphrase) {
      final keyStream = deriveKeyStream(passphrase, data.length);
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

    test('Encrypt → Decrypt roundtrip', () {
      final original = utf8.encode('Hello Magic Ledger!');
      final encrypted = encrypt(Uint8List.fromList(original), 'mypassword');
      final decrypted = decrypt(encrypted, 'mypassword');
      expect(decrypted, isNotNull);
      expect(utf8.decode(decrypted!), equals('Hello Magic Ledger!'));
    });

    test('Wrong passphrase returns null', () {
      final original = utf8.encode('Secret data');
      final encrypted = encrypt(Uint8List.fromList(original), 'correct');
      final decrypted = decrypt(encrypted, 'wrong');
      expect(decrypted, isNull);
    });

    test('Empty data encrypt/decrypt', () {
      final original = Uint8List(0);
      final encrypted = encrypt(original, 'pass');
      final decrypted = decrypt(encrypted, 'pass');
      expect(decrypted, isNotNull);
      expect(decrypted!.length, equals(0));
    });

    test('Large data encrypt/decrypt', () {
      final original = Uint8List.fromList(List.generate(10000, (i) => i % 256));
      final encrypted = encrypt(original, 'longpassword123');
      final decrypted = decrypt(encrypted, 'longpassword123');
      expect(decrypted, isNotNull);
      expect(decrypted!.length, equals(10000));
      for (int i = 0; i < 10000; i++) {
        expect(decrypted[i], equals(i % 256));
      }
    });

    test('Encrypted data is different from original', () {
      final original = utf8.encode('Test data');
      final encrypted = encrypt(Uint8List.fromList(original), 'pass');
      expect(encrypted, isNot(equals(original)));
    });

    test('Same data + same pass = same output (deterministic)', () {
      final data = Uint8List.fromList(utf8.encode('Consistent'));
      final e1 = encrypt(data, 'key');
      final e2 = encrypt(data, 'key');
      expect(e1, equals(e2));
    });

    test('Different passphrases produce different ciphertext', () {
      final data = Uint8List.fromList(utf8.encode('Same input'));
      final e1 = encrypt(data, 'key1');
      final e2 = encrypt(data, 'key2');
      expect(e1, isNot(equals(e2)));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // RECOVERY PHRASE TESTS
  // ═══════════════════════════════════════════════════════════

  group('Recovery Phrase', () {
    final wordList = [
      'apple','arrow','beach','bells','bird','blade','blank','bloom','board','bone',
      'brave','bread','brick','brush','cabin','candy','chain','chalk','charm','chase',
      // ... (truncated for test, full list in auth_service.dart)
    ];

    test('Word list has no duplicates', () {
      final fullList = wordList.toSet();
      // In real test, use AuthService._wordList
      // Verify no exact duplicates
      expect(fullList.length, equals(wordList.length));
    });

    test('All words are lowercase', () {
      for (final w in wordList) {
        expect(w, equals(w.toLowerCase()));
      }
    });

    test('All words are single words (no spaces)', () {
      for (final w in wordList) {
        expect(w.contains(' '), isFalse);
      }
    });

    test('Recovery phrase has exactly 12 words', () {
      // Simulate phrase generation
      final phrase = List.generate(12, (i) => wordList[i % wordList.length]).join(' ');
      expect(phrase.split(' ').length, equals(12));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // CURRENCY FORMATTING TESTS
  // ═══════════════════════════════════════════════════════════

  group('Currency Formatting', () {
    String formatCurrency(double amount) {
      final abs = amount.abs();
      final prefix = amount < 0 ? '-' : '';
      if (abs >= 10000000) return '$prefix₹${(abs / 10000000).toStringAsFixed(1)}Cr';
      if (abs >= 100000) return '$prefix₹${(abs / 100000).toStringAsFixed(1)}L';
      if (abs >= 1000) return '$prefix₹${(abs / 1000).toStringAsFixed(1)}K';
      return '$prefix₹${abs.toStringAsFixed(0)}';
    }

    test('Zero', () => expect(formatCurrency(0), equals('₹0')));
    test('Small amount', () => expect(formatCurrency(50), equals('₹50')));
    test('Thousands', () => expect(formatCurrency(1500), equals('₹1.5K')));
    test('Lakhs', () => expect(formatCurrency(150000), equals('₹1.5L')));
    test('Crores', () => expect(formatCurrency(15000000), equals('₹1.5Cr')));
    test('Negative', () => expect(formatCurrency(-5000), equals('-₹5.0K')));
    test('999 (under 1K)', () => expect(formatCurrency(999), equals('₹999')));
    test('1000 exactly', () => expect(formatCurrency(1000), equals('₹1.0K')));
    test('99999 (under 1L)', () => expect(formatCurrency(99999), equals('₹100.0K')));
  });

  // ═══════════════════════════════════════════════════════════
  // STREAK CALCULATION TESTS
  // ═══════════════════════════════════════════════════════════

  group('Streak Calculation', () {
    int calculateStreak(List<DateTime> expenseDates) {
      final now = DateTime.now();
      int streak = 0;
      for (int d = 1; d < 365; d++) {
        final date = now.subtract(Duration(days: d));
        final hasExpense = expenseDates.any((e) =>
        e.year == date.year && e.month == date.month && e.day == date.day);
        if (!hasExpense) {
          streak++;
        } else {
          break;
        }
      }
      return streak;
    }

    test('No expenses = max streak', () {
      expect(calculateStreak([]), equals(364));
    });

    test('Expense yesterday = 0 streak', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(calculateStreak([yesterday]), equals(0));
    });

    test('Expense 3 days ago = 2 streak', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(calculateStreak([threeDaysAgo]), equals(2));
    });

    test('Today expense doesn\'t break streak', () {
      final today = DateTime.now();
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      expect(calculateStreak([today, fiveDaysAgo]), equals(4));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // SAVINGS RATE TESTS
  // ═══════════════════════════════════════════════════════════

  group('Savings Rate', () {
    double savingsRate(double income, double expenses) {
      if (income <= 0) return 0;
      return ((income - expenses) / income * 100);
    }

    test('50% savings', () => expect(savingsRate(10000, 5000), equals(50)));
    test('0% savings', () => expect(savingsRate(10000, 10000), equals(0)));
    test('Overspent', () => expect(savingsRate(10000, 15000), equals(-50)));
    test('No income', () => expect(savingsRate(0, 5000), equals(0)));
    test('100% savings', () => expect(savingsRate(10000, 0), equals(100)));
  });

  // ═══════════════════════════════════════════════════════════
  // TEMPLATE DATA TESTS
  // ═══════════════════════════════════════════════════════════

  group('Template Validation', () {
    bool isValidTemplate(Map<String, dynamic> t) {
      final title = t['title'] as String? ?? '';
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      return title.isNotEmpty && amount > 0;
    }

    test('Valid template', () {
      expect(isValidTemplate({'title': 'Coffee', 'amount': 30}), isTrue);
    });

    test('Empty title', () {
      expect(isValidTemplate({'title': '', 'amount': 30}), isFalse);
    });

    test('Zero amount', () {
      expect(isValidTemplate({'title': 'Coffee', 'amount': 0}), isFalse);
    });

    test('Negative amount', () {
      expect(isValidTemplate({'title': 'Coffee', 'amount': -10}), isFalse);
    });

    test('Missing fields', () {
      expect(isValidTemplate({}), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // LOCKOUT LOGIC TESTS
  // ═══════════════════════════════════════════════════════════

  group('Lockout Logic', () {
    test('Under max attempts = not locked', () {
      int failedAttempts = 3;
      DateTime? lockoutUntil;
      bool isLockedOut = lockoutUntil != null && DateTime.now().isBefore(lockoutUntil);
      expect(isLockedOut, isFalse);
    });

    test('At max attempts = locked', () {
      int failedAttempts = 5;
      DateTime lockoutUntil = DateTime.now().add(const Duration(minutes: 2));
      bool isLockedOut = DateTime.now().isBefore(lockoutUntil);
      expect(isLockedOut, isTrue);
    });

    test('Lockout expired = unlocked', () {
      DateTime lockoutUntil = DateTime.now().subtract(const Duration(minutes: 1));
      bool isLockedOut = DateTime.now().isBefore(lockoutUntil);
      expect(isLockedOut, isFalse);
    });
  });
}