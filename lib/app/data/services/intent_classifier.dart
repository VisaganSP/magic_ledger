import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// On-device intent classifier using TFLite.
/// Loads a ~200KB model and classifies user queries into intents
/// like "affordability", "category_spending", "balance", etc.
class IntentClassifier {
  static IntentClassifier? _instance;
  factory IntentClassifier() => _instance ??= IntentClassifier._();
  IntentClassifier._();

  Interpreter? _interpreter;
  Map<String, int> _vocab = {};
  List<String> _intentNames = [];
  int _maxLen = 20;
  bool _isReady = false;

  bool get isReady => _isReady;

  /// Load model, vocabulary, and intent mapping from assets
  Future<void> init() async {
    if (_isReady) return;

    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset('assets/ml/money_coach_model.tflite');
      debugPrint('[IntentClassifier] Model loaded');

      // Load vocabulary
      final vocabStr = await rootBundle.loadString('assets/ml/vocab.json');
      final vocabMap = jsonDecode(vocabStr) as Map<String, dynamic>;
      _vocab = vocabMap.map((k, v) => MapEntry(k, v as int));
      debugPrint('[IntentClassifier] Vocab loaded: ${_vocab.length} words');

      // Load intent names
      final intentsStr = await rootBundle.loadString('assets/ml/intents.json');
      final intentsMap = jsonDecode(intentsStr) as Map<String, dynamic>;
      _intentNames = List<String>.from(intentsMap['intent_names'] as List);
      _maxLen = intentsMap['max_sequence_length'] as int? ?? 20;
      debugPrint('[IntentClassifier] Intents loaded: ${_intentNames.length}');

      _isReady = true;
    } catch (e) {
      debugPrint('[IntentClassifier] Init error: $e');
      _isReady = false;
    }
  }

  /// Classify a query into an intent
  /// Returns (intent_name, confidence) or null if not ready
  IntentResult? classify(String query) {
    if (!_isReady || _interpreter == null) return null;

    try {
      // Preprocess — must match Python preprocessing exactly
      final cleaned = _cleanText(query);
      final sequence = _textToSequence(cleaned);

      // Run inference
      final input = [sequence.map((e) => e.toDouble()).toList()];
      final output = List.filled(_intentNames.length, 0.0).reshape([1, _intentNames.length]);

      _interpreter!.run(input, output);

      // Get results
      final probabilities = output[0] as List<double>;
      int maxIdx = 0;
      double maxProb = 0;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIdx = i;
        }
      }

      // Get top 3 for debugging
      final indexed = probabilities.asMap().entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top3 = indexed.take(3).map((e) =>
      '${_intentNames[e.key]}(${(e.value * 100).toStringAsFixed(1)}%)').join(', ');
      debugPrint('[Intent] "$query" → ${_intentNames[maxIdx]} (${(maxProb * 100).toStringAsFixed(1)}%) | Top3: $top3');

      return IntentResult(
        intent: _intentNames[maxIdx],
        confidence: maxProb,
        allScores: Map.fromEntries(
            probabilities.asMap().entries.map((e) =>
                MapEntry(_intentNames[e.key], e.value))),
      );
    } catch (e) {
      debugPrint('[IntentClassifier] Classify error: $e');
      return null;
    }
  }

  /// Clean text — must match Python clean_text() exactly
  String _cleanText(String text) {
    var t = text.toLowerCase().trim();
    t = t.replaceAll(RegExp(r'[₹\$€£]'), '');
    t = t.replaceAll(RegExp(r'[^\w\s]'), ' ');
    t = t.replaceAll(RegExp(r'\d+'), ' NUM ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }

  /// Convert text to padded integer sequence — matches Python exactly
  List<int> _textToSequence(String text) {
    final words = text.split(' ');
    final seq = <int>[];
    for (final word in words.take(_maxLen)) {
      seq.add(_vocab[word] ?? 1); // 1 = <UNK>
    }
    // Pad to maxLen
    while (seq.length < _maxLen) {
      seq.add(0); // 0 = <PAD>
    }
    return seq;
  }

  void dispose() {
    _interpreter?.close();
    _instance = null;
  }
}

/// Result of intent classification
class IntentResult {
  final String intent;
  final double confidence;
  final Map<String, double> allScores;

  IntentResult({
    required this.intent,
    required this.confidence,
    required this.allScores,
  });

  /// Is the classification confident enough to act on?
  bool get isConfident => confidence > 0.4;

  /// Get second-best intent (for ambiguous queries)
  String? get secondBest {
    final sorted = allScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.length > 1 && sorted[1].value > 0.2) {
      return sorted[1].key;
    }
    return null;
  }

  @override
  String toString() => 'IntentResult($intent, ${(confidence * 100).toStringAsFixed(1)}%)';
}