import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../theme/neo_brutalism_theme.dart';

class LockScreenView extends StatefulWidget {
  const LockScreenView({super.key});

  @override
  State<LockScreenView> createState() => _LockScreenViewState();
}

class _LockScreenViewState extends State<LockScreenView> {
  final AuthService _auth = Get.find<AuthService>();
  String _pin = '';
  String? _error;
  bool _shaking = false;
  Timer? _lockoutTimer;

  // Track which key is currently pressed for tap effect
  String? _pressedKey;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_auth.biometricEnabled.value && !_auth.isLockedOut) _tryBiometric();
    });
    if (_auth.isLockedOut) _startLockoutTimer();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_auth.isLockedOut) {
        _lockoutTimer?.cancel();
        setState(() => _error = null);
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _tryBiometric() async {
    final success = await _auth.authenticateWithBiometric();
    if (success) Get.offAllNamed('/home');
  }

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    if (_auth.isLockedOut) {
      setState(() => _error = 'Too many attempts. Wait ${_auth.lockoutRemainingSeconds}s');
      return;
    }
    setState(() {
      _error = null;
      _pressedKey = key;
    });

    // Reset press effect after short delay
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _pressedKey = null);
    });

    if (key == '⌫') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
    } else if (key == '🔐') {
      _tryBiometric();
    } else {
      setState(() => _pin += key);
      if (_pin.length >= 4) {
        Future.delayed(const Duration(milliseconds: 100), () => _verifyPin());
      }
    }
  }

  void _verifyPin() {
    if (_auth.verifyPin(_pin)) {
      HapticFeedback.mediumImpact();
      Get.offAllNamed('/home');
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _shaking = true;
        _pin = '';
        if (_auth.isLockedOut) {
          _error = 'Too many attempts. Locked for ${AuthService.lockoutMinutes} minutes.';
          _startLockoutTimer();
        } else {
          _error = 'Wrong PIN (${AuthService.maxFailedAttempts - _auth.failedAttempts.value} attempts left)';
        }
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _shaking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLockedOut = _auth.isLockedOut;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            _buildLogo(isDark),
            const SizedBox(height: 12),
            Text('Enter your PIN to unlock', style: TextStyle(fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[600])),
            const SizedBox(height: 28),

            // PIN dots
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: Matrix4.translationValues(
                  _shaking ? 12 * (_pin.isEmpty ? 1 : -1).toDouble() : 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: filled ? 20 : 18,
                    height: filled ? 20 : 18,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? (_error != null ? Colors.red
                          : (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))
                          : Colors.transparent,
                      border: Border.all(
                          color: _error != null ? Colors.red
                              : (isDark ? Colors.grey[600]! : NeoBrutalismTheme.primaryBlack), width: 2),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Error
            SizedBox(
              height: 36,
              child: _error != null
                  ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(_error!, style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w700, color: Colors.red),
                      textAlign: TextAlign.center))
                  : (isLockedOut
                  ? Text('Locked — ${_auth.lockoutRemainingSeconds}s remaining',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: Colors.red[400]))
                  : const SizedBox.shrink()),
            ),

            const Spacer(flex: 1),
            _buildNumberPad(isDark, isLockedOut),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => Get.toNamed('/reset-pin'),
              child: Text('Forgot PIN?', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 16),

            // Visainnovations branding
            _buildBranding(isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
        const SizedBox(height: 14),
        Text('MAGIC LEDGER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 2),
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

  Widget _buildNumberPad(bool isDark, bool isLockedOut) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          for (var row in [['1','2','3'], ['4','5','6'], ['7','8','9'], ['🔐','0','⌫']])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) => _buildKey(key, isDark, isLockedOut)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String key, bool isDark, bool isLockedOut) {
    final isBio = key == '🔐';
    final isBack = key == '⌫';
    final isAction = isBio || isBack;
    final bioAvailable = _auth.biometricEnabled.value && _auth.biometricAvailable.value;
    final isPressed = _pressedKey == key;

    // Determine colors
    Color bgColor;
    if (isBio && bioAvailable) {
      bgColor = NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentSkyBlue, isDark);
    } else if (isAction) {
      bgColor = isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[200]!;
    } else {
      bgColor = isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite;
    }

    // Shadow offset changes on press
    final normalOffset = isAction ? 2.0 : 3.0;
    final pressedOffset = 0.0;
    final currentOffset = isPressed ? pressedOffset : normalOffset;

    return GestureDetector(
      onTapDown: (_) {
        if (!(isLockedOut && !isBio)) {
          setState(() => _pressedKey = key);
        }
      },
      onTapUp: (_) {
        setState(() => _pressedKey = null);
        if (!(isLockedOut && !isBio)) _onKeyTap(key);
      },
      onTapCancel: () => setState(() => _pressedKey = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 72, height: 56,
        // Move down-right when pressed (shadow collapses)
        transform: Matrix4.translationValues(
          isPressed ? normalOffset : 0,
          isPressed ? normalOffset : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: NeoBrutalismTheme.primaryBlack,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: NeoBrutalismTheme.primaryBlack,
              offset: Offset(currentOffset, currentOffset),
            ),
          ],
        ),
        child: Center(
          child: isBio
              ? Icon(Icons.fingerprint, size: 26,
              color: bioAvailable ? NeoBrutalismTheme.primaryBlack
                  : (isDark ? Colors.grey[700] : Colors.grey[400]))
              : isBack
              ? Icon(Icons.backspace_outlined, size: 22,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)
              : Text(key, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
              color: isLockedOut ? Colors.grey
                  : (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
        ),
      ),
    );
  }
}