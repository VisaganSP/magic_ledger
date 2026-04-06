import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../theme/neo_brutalism_theme.dart';

/// Recovery phrase entry screen.
/// Flow: Enter 12 words → Verify → Set new PIN → Done
class ResetPinView extends StatefulWidget {
  const ResetPinView({super.key});

  @override
  State<ResetPinView> createState() => _ResetPinViewState();
}

class _ResetPinViewState extends State<ResetPinView> {
  final AuthService _auth = Get.find<AuthService>();
  final List<TextEditingController> _wordControllers =
  List.generate(12, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(12, (_) => FocusNode());

  // Steps: 0 = enter phrase, 1 = enter new PIN, 2 = confirm PIN
  int _step = 0;
  String _newPin = '';
  String _confirmPin = '';
  String? _error;

  @override
  void dispose() {
    for (final c in _wordControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: SafeArea(
        child: _step == 0
            ? _buildPhraseEntry(isDark)
            : _buildNewPinEntry(isDark),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PHRASE ENTRY (Step 0)
  // ═══════════════════════════════════════════════════════════

  Widget _buildPhraseEntry(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(Get.context!).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: NeoBrutalismTheme.neoBox(
                  color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: Icon(Icons.arrow_back, size: 20,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: 64, height: 64,
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.getThemedColor(
                  NeoBrutalismTheme.accentYellow, isDark),
              offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Center(child: Text('🔑', style: TextStyle(fontSize: 28))),
          ).animate().scale(duration: 300.ms, begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 20),

          Text('RECOVER YOUR ACCOUNT', style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.w900, letterSpacing: 0.5,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Enter your 12-word recovery phrase',
              style: TextStyle(fontSize: 13,
                  color: isDark ? Colors.grey[500] : Colors.grey[600])),
          const SizedBox(height: 24),

          // 12 word input fields (4x3 grid)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: List.generate(12, (i) {
              return Container(
                decoration: NeoBrutalismTheme.neoBox(
                  color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      alignment: Alignment.center,
                      child: Text('${i + 1}', style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.grey[600] : Colors.grey[500])),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _wordControllers[i],
                        focusNode: _focusNodes[i],
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          isDense: true,
                        ),
                        textInputAction: i < 11 ? TextInputAction.next : TextInputAction.done,
                        onSubmitted: (_) {
                          if (i < 11) {
                            _focusNodes[i + 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Error
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                border: Border.all(color: Colors.red, width: 1.5),
              ),
              child: Text(_error!, style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: Colors.red),
                  textAlign: TextAlign.center),
            ),
          const SizedBox(height: 20),

          // Verify button
          GestureDetector(
            onTap: _verifyPhrase,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.accentGreen,
                offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: const Center(
                child: Text('VERIFY PHRASE', style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w900, letterSpacing: 0.5,
                    color: NeoBrutalismTheme.primaryBlack)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _verifyPhrase() {
    final words = _wordControllers
        .map((c) => c.text.trim().toLowerCase())
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.length < 12) {
      setState(() => _error = 'Please enter all 12 words');
      return;
    }

    // Store phrase for next step — actual verification happens when setting new PIN
    setState(() {
      _error = null;
      _step = 1;
    });
  }

  // ═══════════════════════════════════════════════════════════
  // NEW PIN ENTRY (Steps 1 & 2)
  // ═══════════════════════════════════════════════════════════

  Widget _buildNewPinEntry(bool isDark) {
    final isConfirm = _step == 2;
    final currentPin = isConfirm ? _confirmPin : _newPin;

    return Column(
      children: [
        const Spacer(flex: 2),

        Container(
          width: 64, height: 64,
          decoration: NeoBrutalismTheme.neoBox(
            color: NeoBrutalismTheme.getThemedColor(
                NeoBrutalismTheme.accentGreen, isDark),
            offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: const Center(child: Text('🔓', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 20),

        Text(isConfirm ? 'CONFIRM NEW PIN' : 'SET NEW PIN',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 8),
        Text(isConfirm ? 'Enter the same PIN again' : 'Choose a new 4-6 digit PIN',
            style: TextStyle(fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[600])),
        const SizedBox(height: 32),

        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = i < currentPin.length;
            return Container(
              width: 18, height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)
                    : Colors.transparent,
                border: Border.all(
                    color: isDark ? Colors.grey[600]! : NeoBrutalismTheme.primaryBlack, width: 2),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        if (_error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
            child: Text(_error!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red),
                textAlign: TextAlign.center),
          ),

        if (currentPin.length >= 4)
          Text('${currentPin.length} digits • tap ✓',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.green[400] : Colors.green[700])),

        const Spacer(flex: 1),

        // Number pad
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              for (var row in [['1','2','3'], ['4','5','6'], ['7','8','9'], ['⌫','0','✓']])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((key) {
                      final isBack = key == '⌫';
                      final isCheck = key == '✓';
                      final isAction = isBack || isCheck;

                      return GestureDetector(
                        onTap: () => _onNewPinKey(key, isConfirm),
                        child: Container(
                          width: 72, height: 56,
                          decoration: isAction
                              ? NeoBrutalismTheme.neoBox(
                              color: isCheck && currentPin.length >= 4
                                  ? NeoBrutalismTheme.accentGreen
                                  : (isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[200]!),
                              offset: 2, borderColor: NeoBrutalismTheme.primaryBlack)
                              : NeoBrutalismTheme.neoBox(
                              color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                              offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
                          child: Center(
                            child: isBack
                                ? Icon(Icons.backspace_outlined, size: 22,
                                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)
                                : isCheck
                                ? Icon(Icons.check, size: 24,
                                color: currentPin.length >= 4
                                    ? NeoBrutalismTheme.primaryBlack : Colors.grey)
                                : Text(key, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _onNewPinKey(String key, bool isConfirm) {
    HapticFeedback.lightImpact();
    setState(() => _error = null);

    if (key == '⌫') {
      setState(() {
        if (isConfirm && _confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else if (!isConfirm && _newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        }
      });
    } else if (key == '✓') {
      final currentPin = isConfirm ? _confirmPin : _newPin;
      if (currentPin.length < 4) {
        setState(() => _error = 'PIN must be at least 4 digits');
        return;
      }

      if (!isConfirm) {
        setState(() => _step = 2);
      } else {
        if (_confirmPin == _newPin) {
          _completeReset();
        } else {
          setState(() {
            _error = 'PINs don\'t match';
            _confirmPin = '';
          });
        }
      }
    } else {
      setState(() {
        if (isConfirm && _confirmPin.length < 6) {
          _confirmPin += key;
        } else if (!isConfirm && _newPin.length < 6) {
          _newPin += key;
        }
      });
    }
  }

  Future<void> _completeReset() async {
    final phrase = _wordControllers.map((c) => c.text.trim().toLowerCase()).join(' ');
    final success = await _auth.resetPinWithRecovery(phrase, _newPin);

    if (success) {
      Get.snackbar('PIN Reset', 'Your new PIN is active',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100], colorText: Colors.green[900]);
      Get.offAllNamed('/home');
    } else {
      setState(() {
        _error = 'Recovery phrase is incorrect';
        _step = 0;
        _newPin = '';
        _confirmPin = '';
      });
    }
  }
}