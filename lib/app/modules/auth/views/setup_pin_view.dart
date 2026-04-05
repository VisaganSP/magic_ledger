import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../theme/neo_brutalism_theme.dart';

class SetupPinView extends StatefulWidget {
  const SetupPinView({super.key});

  @override
  State<SetupPinView> createState() => _SetupPinViewState();
}

class _SetupPinViewState extends State<SetupPinView> {
  final AuthService _auth = Get.find<AuthService>();

  int _step = 0;
  String _pin = '';
  String _confirmPin = '';
  String _recoveryPhrase = '';
  bool _phraseWrittenDown = false;
  String? _error;
  String? _pressedKey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: SafeArea(
        child: _step == 2
            ? _buildRecoveryPhrasePage(isDark)
            : _buildPinEntryPage(isDark),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PIN ENTRY PAGE
  // ═══════════════════════════════════════════════════════════

  Widget _buildPinEntryPage(bool isDark) {
    final isConfirm = _step == 1;
    final currentPin = isConfirm ? _confirmPin : _pin;

    return Column(
      children: [
        const Spacer(flex: 2),
        _buildLogo(isDark),
        const SizedBox(height: 20),

        Text(isConfirm ? 'CONFIRM YOUR PIN' : 'CREATE YOUR PIN',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 8),
        Text(isConfirm ? 'Enter the same PIN again' : 'Choose a 4-6 digit PIN to secure your data',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[600])),
        const SizedBox(height: 28),

        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = i < currentPin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: filled ? 20 : 18,
              height: filled ? 20 : 18,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                border: Border.all(color: Colors.red, width: 1.5),
                borderRadius: BorderRadius.circular(4)),
            child: Text(_error!, style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w700, color: Colors.red), textAlign: TextAlign.center),
          ),
        const SizedBox(height: 8),

        if (currentPin.length >= 4)
          Text('${currentPin.length} digits • tap ✓ to continue',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.green[400] : Colors.green[700])),

        const Spacer(flex: 1),
        _buildNumberPad(isDark, currentPin, isConfirm),
        const SizedBox(height: 12),

        // Visainnovations branding
        _buildBranding(isDark),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLogo(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: NeoBrutalismTheme.neoBox(
            color: NeoBrutalismTheme.getThemedColor(
                NeoBrutalismTheme.accentPurple, isDark),
            offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 60, height: 60, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                  child: Text('✦', style: TextStyle(fontSize: 36,
                      fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack))),
            ),
          ),
        ).animate().scale(duration: 300.ms, begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 12),
        Text('MAGIC LEDGER', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        Text('Track. Save. Achieve.', style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[600] : Colors.grey[500])),
      ],
    );
  }

  Widget _buildBranding(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('Visainnovations', style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w700, letterSpacing: 0.5,
            color: isDark ? Colors.grey[600] : Colors.grey[400])),
        const SizedBox(width: 4),
        Text('— Making Tomorrow Magical', style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.w500, fontStyle: FontStyle.italic,
            color: isDark ? Colors.grey[700] : Colors.grey[400])),
      ],
    );
  }

  Widget _buildNumberPad(bool isDark, String currentPin, bool isConfirm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          for (var row in [['1','2','3'], ['4','5','6'], ['7','8','9'], ['⌫','0','✓']])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) => _buildKey(key, isDark, currentPin, isConfirm)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String key, bool isDark, String currentPin, bool isConfirm) {
    final isBack = key == '⌫';
    final isCheck = key == '✓';
    final isAction = isBack || isCheck;
    final isPressed = _pressedKey == key;

    Color bgColor;
    if (isCheck && currentPin.length >= 4) {
      bgColor = NeoBrutalismTheme.accentGreen;
    } else if (isAction) {
      bgColor = isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[200]!;
    } else {
      bgColor = isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite;
    }

    final normalOffset = isAction ? 2.0 : 3.0;
    final currentOffset = isPressed ? 0.0 : normalOffset;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedKey = key),
      onTapUp: (_) {
        setState(() => _pressedKey = null);
        _onKeyTap(key, isConfirm);
      },
      onTapCancel: () => setState(() => _pressedKey = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 72, height: 56,
        transform: Matrix4.translationValues(
          isPressed ? normalOffset : 0,
          isPressed ? normalOffset : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
          boxShadow: [
            BoxShadow(
              color: NeoBrutalismTheme.primaryBlack,
              offset: Offset(currentOffset, currentOffset),
            ),
          ],
        ),
        child: Center(
          child: isBack
              ? Icon(Icons.backspace_outlined, size: 22,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)
              : isCheck
              ? Icon(Icons.check, size: 24,
              color: currentPin.length >= 4
                  ? NeoBrutalismTheme.primaryBlack
                  : (isDark ? Colors.grey[700] : Colors.grey[400]))
              : Text(key, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        ),
      ),
    );
  }

  void _onKeyTap(String key, bool isConfirm) {
    HapticFeedback.lightImpact();
    setState(() => _error = null);

    if (key == '⌫') {
      setState(() {
        if (isConfirm && _confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else if (!isConfirm && _pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      });
    } else if (key == '✓') {
      final currentPin = isConfirm ? _confirmPin : _pin;
      if (currentPin.length < 4) {
        setState(() => _error = 'PIN must be at least 4 digits');
        return;
      }
      if (!isConfirm) {
        setState(() => _step = 1);
      } else {
        if (_confirmPin == _pin) {
          _completeSetup();
        } else {
          setState(() { _error = 'PINs don\'t match. Try again.'; _confirmPin = ''; });
        }
      }
    } else {
      setState(() {
        if (isConfirm && _confirmPin.length < 6) _confirmPin += key;
        else if (!isConfirm && _pin.length < 6) _pin += key;
      });
    }
  }

  Future<void> _completeSetup() async {
    final phrase = await _auth.setupPin(_pin);
    setState(() { _recoveryPhrase = phrase; _step = 2; });
  }

  // ═══════════════════════════════════════════════════════════
  // RECOVERY PHRASE PAGE
  // ═══════════════════════════════════════════════════════════

  Widget _buildRecoveryPhrasePage(bool isDark) {
    final words = _recoveryPhrase.split(' ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 72, height: 72,
            decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
                offset: 4, borderColor: NeoBrutalismTheme.primaryBlack),
            child: const Center(child: Text('🔑', style: TextStyle(fontSize: 32))),
          ).animate().scale(duration: 300.ms, begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 20),

          Text('YOUR RECOVERY PHRASE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Write these 12 words down on paper.\nThis is the ONLY way to recover your PIN.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5,
                  color: isDark ? Colors.grey[500] : Colors.grey[600])),
          const SizedBox(height: 24),

          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red, width: 2)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 24),
                const SizedBox(width: 10),
                Expanded(child: Text(
                    'Do NOT screenshot or share this. Write it on paper and keep it safe.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.red[300] : Colors.red[700]))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                offset: 4, borderColor: NeoBrutalismTheme.primaryBlack),
            child: Wrap(
              spacing: 10, runSpacing: 10,
              children: words.asMap().entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: NeoBrutalismTheme.neoBox(
                      color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBeige, isDark),
                      offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
                  child: Text('${entry.key + 1}. ${entry.value}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => setState(() => _phraseWrittenDown = !_phraseWrittenDown),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _phraseWrittenDown
                      ? NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark)
                      : (isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[100]),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                        color: _phraseWrittenDown ? NeoBrutalismTheme.primaryBlack : Colors.transparent,
                        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                        borderRadius: BorderRadius.circular(4)),
                    child: _phraseWrittenDown
                        ? const Icon(Icons.check, size: 16, color: NeoBrutalismTheme.primaryWhite) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('I have written down my recovery phrase',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _phraseWrittenDown ? () {
              _auth.unlockApp();
              Get.offAllNamed('/home');
            } : null,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: NeoBrutalismTheme.neoBox(
                  color: _phraseWrittenDown ? NeoBrutalismTheme.accentGreen
                      : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                  offset: _phraseWrittenDown ? 4 : 0,
                  borderColor: NeoBrutalismTheme.primaryBlack),
              child: Center(child: Text('CONTINUE TO APP',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                      color: _phraseWrittenDown ? NeoBrutalismTheme.primaryBlack
                          : (isDark ? Colors.grey[600] : Colors.grey[500])))),
            ),
          ),
          const SizedBox(height: 24),

          // Branding at bottom of recovery page too
          _buildBranding(isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}