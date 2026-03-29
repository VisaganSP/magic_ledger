/// Parses Indian bank SMS messages to extract transaction details.
///
/// Supports formats from major banks:
/// HDFC, SBI, ICICI, Axis, Kotak, PNB, BOB, IndusInd, Yes Bank,
/// and UPI apps (Google Pay, PhonePe, Paytm, etc.)
class TransactionParser {
  /// Result of parsing an SMS
  static TransactionParseResult? parse(String message) {
    if (message.isEmpty) return null;

    // Normalize the message
    final msg = message.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    // Check if it's a bank transaction message
    if (!_isBankMessage(msg)) return null;

    final type = _detectType(msg);
    if (type == null) return null;

    final amount = _extractAmount(msg);
    if (amount == null || amount <= 0) return null;

    return TransactionParseResult(
      type: type,
      amount: amount,
      accountLast4: _extractAccountLast4(msg),
      bankName: _extractBankName(msg),
      merchant: _extractMerchant(msg),
      upiId: _extractUpiId(msg),
      refNumber: _extractRefNumber(msg),
      cardType: _extractCardType(msg),
      rawMessage: message,
    );
  }

  /// Check if the SMS is likely a bank/financial message
  static bool _isBankMessage(String msg) {
    final lower = msg.toLowerCase();

    // Must contain a money indicator
    final hasMoneyKeyword = RegExp(
      r'(rs\.?|inr|rupee|credited|debited|sent|received|paid|payment|txn|transaction|withdrawn|deposit|transfer)',
      caseSensitive: false,
    ).hasMatch(lower);

    if (!hasMoneyKeyword) return false;

    // Exclude OTP / promotional / non-transactional
    final isOtp = RegExp(r'(otp|one.?time|verification|password|pin)', caseSensitive: false).hasMatch(lower);
    final isPromo = RegExp(r'(offer|cashback.*earn|apply.*now|download|install|limit.*enhance)', caseSensitive: false).hasMatch(lower);

    if (isOtp || isPromo) return false;

    return true;
  }

  /// Detect if it's a credit (income) or debit (expense)
  static String? _detectType(String msg) {
    final lower = msg.toLowerCase();

    // ─── CREDIT indicators ─────────────────────────────
    final creditPatterns = [
      r'credited',
      r'received',
      r'credit\s*alert',
      r'deposited',
      r'added\s+to\s+(?:your\s+)?(?:a/?c|account|wallet)',
      r'(?:has|have)\s+been\s+credited',
      r'credit\s+of\s+(?:rs|inr)',
      r'amount\s+credited',
      r'salary\s+credited',
      r'refund.*(?:processed|credited|successful)',
      r'(?:rs|inr)[\s.]*[\d,]+\.?\d*\s*(?:has\s+been\s+)?credited',
    ];

    // ─── DEBIT indicators ──────────────────────────────
    final debitPatterns = [
      r'debited',
      r'sent\s+rs',
      r'paid\s+(?:rs|inr)',
      r'payment\s+(?:of\s+)?(?:rs|inr)',
      r'debit\s*alert',
      r'withdrawn',
      r'purchase\s+(?:of\s+)?(?:rs|inr)',
      r'spent',
      r'(?:rs|inr)[\s.]*[\d,]+\.?\d*\s*(?:has\s+been\s+)?debited',
      r'txn\s+of\s+(?:rs|inr)',
      r'transaction\s+of\s+(?:rs|inr)',
      r'transferred\s+(?:rs|inr)',
      r'deducted',
    ];

    for (final pattern in creditPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return 'credit';
      }
    }

    for (final pattern in debitPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return 'debit';
      }
    }

    // Fallback: "Sent Rs" = debit, "from VPA" with credit context = credit
    if (lower.contains('sent rs') || lower.contains('sent inr')) return 'debit';

    return null;
  }

  /// Extract the transaction amount
  static double? _extractAmount(String msg) {
    // Patterns for amount extraction (ordered by specificity)
    final patterns = [
      // "Rs.2,50,000.00" or "Rs 2,50,000.00" or "Rs.2.00"
      RegExp(r'(?:rs|inr)[\s.]*([0-9,]+\.?\d{0,2})', caseSensitive: false),
      // "INR 2,500" or "INR 2500.00"
      RegExp(r'(?:inr)\s*([0-9,]+\.?\d{0,2})', caseSensitive: false),
      // "₹2,500" or "₹ 2,500.00"
      RegExp(r'₹\s*([0-9,]+\.?\d{0,2})'),
      // "Rupees 2500"
      RegExp(r'rupees?\s*([0-9,]+\.?\d{0,2})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(msg);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) return amount;
      }
    }

    return null;
  }

  /// Extract last 4 digits of account number
  static String? _extractAccountLast4(String msg) {
    // "A/c XX7543" or "A/C *7543" or "Account ****7543" or "a/c no. XX1234"
    final patterns = [
      RegExp(r'a/?c\s*(?:no\.?\s*)?(?:XX|xx|\*{1,4})(\d{4})', caseSensitive: false),
      RegExp(r'account\s*(?:no\.?\s*)?(?:XX|xx|\*{1,4})(\d{4})', caseSensitive: false),
      RegExp(r'(?:card|acct)\s*(?:ending\s*)?(?:XX|xx|\*{1,4})(\d{4})', caseSensitive: false),
      // "Bank 7543" or just masked digits
      RegExp(r'(?:XX|xx|\*{2,})(\d{4})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(msg);
      if (match != null) return match.group(1);
    }

    return null;
  }

  /// Extract bank name
  static String? _extractBankName(String msg) {
    final lower = msg.toLowerCase();

    final banks = {
      'hdfc': 'HDFC',
      'icici': 'ICICI',
      'sbi': 'SBI',
      'axis': 'Axis',
      'kotak': 'Kotak',
      'pnb': 'PNB',
      'bob': 'BOB',
      'indusind': 'IndusInd',
      'yes bank': 'Yes Bank',
      'idfc': 'IDFC',
      'federal': 'Federal',
      'canara': 'Canara',
      'union': 'Union',
      'iob': 'IOB',
      'indian bank': 'Indian Bank',
      'bandhan': 'Bandhan',
      'rbl': 'RBL',
      'dbs': 'DBS',
      'citi': 'Citi',
      'hsbc': 'HSBC',
      'sc bank': 'Standard Chartered',
      'paytm': 'Paytm Payments Bank',
      'fi ': 'Fi',
      'jupiter': 'Jupiter',
      'niyo': 'Niyo',
      'slice': 'Slice',
    };

    for (final entry in banks.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    return null;
  }

  /// Extract merchant/payee name
  static String? _extractMerchant(String msg) {
    final patterns = [
      // "to S JAYA" or "to SWIGGY" or "To VPA merchant@bank"
      RegExp(r'(?:to|at|towards|for)\s+([A-Z][A-Za-z\s]{2,25}?)(?:\s+\d|\s+on|\s+ref|\s*$)', caseSensitive: false),
      // "paid to MERCHANT"
      RegExp(r'paid\s+(?:to\s+)?([A-Z][A-Za-z\s]{2,25}?)(?:\s+\d|\s+on|\s+ref)', caseSensitive: false),
      // "at STORE NAME"
      RegExp(r'at\s+([A-Z][A-Za-z\s&]{2,30}?)(?:\s+on|\s+for|\s+ref|\s*\.)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(msg);
      if (match != null) {
        final merchant = match.group(1)!.trim();
        // Skip if it's a bank name or generic word
        if (!_isGenericWord(merchant)) return merchant;
      }
    }

    return null;
  }

  /// Extract UPI ID
  static String? _extractUpiId(String msg) {
    final pattern = RegExp(r'(?:VPA|UPI|upi[:\s])\s*([a-zA-Z0-9._-]+@[a-zA-Z0-9]+)', caseSensitive: false);
    final match = pattern.firstMatch(msg);
    if (match != null) return match.group(1);

    // Also try standalone UPI pattern
    final upiPattern = RegExp(r'([a-zA-Z0-9._-]+@(?:upi|ybl|okhdfcbank|okicici|oksbi|apl|axl|paytm|ibl|axisbank|icici))', caseSensitive: false);
    final upiMatch = upiPattern.firstMatch(msg);
    if (upiMatch != null) return upiMatch.group(1);

    return null;
  }

  /// Extract reference number
  static String? _extractRefNumber(String msg) {
    final patterns = [
      RegExp(r'(?:ref|reference|txn|transaction)\s*(?:no\.?\s*)?[:# ]*(\d{6,20})', caseSensitive: false),
      RegExp(r'UPI\s*(\d{9,15})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(msg);
      if (match != null) return match.group(1);
    }

    return null;
  }

  /// Detect card type (credit card vs debit card)
  static String? _extractCardType(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('credit card')) return 'credit_card';
    if (lower.contains('debit card')) return 'debit_card';
    if (RegExp(r'card\s*(?:ending|xx|\*)', caseSensitive: false).hasMatch(lower)) return 'card';
    return null;
  }

  static bool _isGenericWord(String word) {
    final generics = {
      'bank', 'account', 'card', 'upi', 'neft', 'imps', 'rtgs',
      'the', 'your', 'from', 'with', 'for', 'has', 'been', 'not',
    };
    return generics.contains(word.toLowerCase().trim());
  }
}

/// Result of parsing a bank SMS
class TransactionParseResult {
  final String type; // 'credit' or 'debit'
  final double amount;
  final String? accountLast4;
  final String? bankName;
  final String? merchant;
  final String? upiId;
  final String? refNumber;
  final String? cardType;
  final String rawMessage;

  TransactionParseResult({
    required this.type,
    required this.amount,
    this.accountLast4,
    this.bankName,
    this.merchant,
    this.upiId,
    this.refNumber,
    this.cardType,
    required this.rawMessage,
  });

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';

  /// Try to guess a title for the transaction
  String get suggestedTitle {
    if (merchant != null && merchant!.isNotEmpty) return merchant!;
    if (upiId != null) {
      // Extract name from UPI ID: "merchant@bank" -> "Merchant"
      final name = upiId!.split('@').first.replaceAll(RegExp(r'[._-]'), ' ');
      if (name.length > 2) {
        return name.split(' ').map((w) =>
        w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : ''
        ).join(' ').trim();
      }
    }
    if (isCredit) return 'Received from ${bankName ?? 'Bank'}';
    return 'Payment${bankName != null ? ' via $bankName' : ''}';
  }

  /// Try to guess a category based on merchant/UPI
  String? get suggestedCategory {
    final merchantLower = (merchant ?? '').toLowerCase();
    final upiLower = (upiId ?? '').toLowerCase();
    final combined = '$merchantLower $upiLower';

    // Food & dining
    if (_matchesAny(combined, ['swiggy', 'zomato', 'dominos', 'pizza', 'restaurant',
      'cafe', 'food', 'kitchen', 'biryani', 'burger', 'mcdonald', 'kfc', 'subway'])) {
      return 'Food';
    }

    // Transport
    if (_matchesAny(combined, ['uber', 'ola', 'rapido', 'metro', 'irctc', 'railway',
      'petrol', 'fuel', 'parking', 'toll', 'fastag'])) {
      return 'Transport';
    }

    // Shopping
    if (_matchesAny(combined, ['amazon', 'flipkart', 'myntra', 'ajio', 'meesho',
      'nykaa', 'mall', 'store', 'shop', 'market', 'bigbasket', 'blinkit', 'zepto'])) {
      return 'Shopping';
    }

    // Groceries
    if (_matchesAny(combined, ['dmart', 'bigbasket', 'blinkit', 'zepto', 'dunzo',
      'grofers', 'jiomart', 'grocery', 'supermarket', 'kirana'])) {
      return 'Groceries';
    }

    // Bills & recharges
    if (_matchesAny(combined, ['airtel', 'jio', 'vi ', 'vodafone', 'bsnl',
      'electricity', 'water', 'gas', 'broadband', 'wifi', 'recharge', 'bill'])) {
      return 'Bills';
    }

    // Entertainment
    if (_matchesAny(combined, ['netflix', 'hotstar', 'prime', 'spotify', 'youtube',
      'bookmyshow', 'pvr', 'inox', 'movie', 'game', 'steam'])) {
      return 'Entertainment';
    }

    // Health
    if (_matchesAny(combined, ['pharmacy', 'medical', 'hospital', 'clinic', 'doctor',
      'apollo', 'medplus', 'netmeds', 'pharmeasy', '1mg'])) {
      return 'Health';
    }

    // Subscriptions
    if (_matchesAny(combined, ['subscription', 'premium', 'plan', 'membership',
      'annual', 'monthly', 'renewal'])) {
      return 'Subscriptions';
    }

    // Education
    if (_matchesAny(combined, ['school', 'college', 'university', 'course', 'udemy',
      'coursera', 'tuition', 'coaching', 'book', 'education'])) {
      return 'Education';
    }

    return null;
  }

  static bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  /// Generate a description from parsed data
  String get suggestedDescription {
    final parts = <String>[];
    if (bankName != null) parts.add(bankName!);
    if (accountLast4 != null) parts.add('A/c **$accountLast4');
    if (upiId != null) parts.add('UPI: $upiId');
    if (refNumber != null) parts.add('Ref: $refNumber');
    return parts.join(' • ');
  }

  @override
  String toString() {
    return 'TransactionParseResult(type: $type, amount: $amount, bank: $bankName, '
        'account: $accountLast4, merchant: $merchant, upi: $upiId, ref: $refNumber)';
  }
}