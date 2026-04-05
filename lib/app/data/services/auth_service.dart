import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

/// Core authentication service for Magic Ledger.
///
/// Features:
/// - 4-6 digit PIN with SHA-256 hashing
/// - Biometric (fingerprint/face) via local_auth
/// - 12-word recovery phrase (crypto-wallet style)
/// - Auto-lock on app background
/// - Configurable lock timeout
/// - Failed attempt tracking with lockout
class AuthService extends GetxService {
  static const String _boxName = 'auth_settings';
  static const String _pinHashKey = 'pin_hash';
  static const String _recoveryHashKey = 'recovery_hash';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lockTimeoutKey = 'lock_timeout';
  static const String _isSetupCompleteKey = 'setup_complete';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutUntilKey = 'lockout_until';
  static const int maxFailedAttempts = 5;
  static const int lockoutMinutes = 2;

  late Box _authBox;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Reactive state
  final RxBool isLocked = true.obs;
  final RxBool isSetupComplete = false.obs;
  final RxBool biometricEnabled = false.obs;
  final RxBool biometricAvailable = false.obs;
  final RxInt failedAttempts = 0.obs;
  final RxInt lockTimeout = 0.obs; // 0 = immediate, seconds otherwise
  final Rxn<DateTime> lockoutUntil = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _initBox();
  }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _authBox = await Hive.openBox(_boxName);
    } else {
      _authBox = Hive.box(_boxName);
    }

    isSetupComplete.value = _authBox.get(_isSetupCompleteKey, defaultValue: false);
    biometricEnabled.value = _authBox.get(_biometricEnabledKey, defaultValue: false);
    lockTimeout.value = _authBox.get(_lockTimeoutKey, defaultValue: 0);
    failedAttempts.value = _authBox.get(_failedAttemptsKey, defaultValue: 0);

    final lockoutStr = _authBox.get(_lockoutUntilKey) as String?;
    if (lockoutStr != null) {
      lockoutUntil.value = DateTime.tryParse(lockoutStr);
    }

    // Check biometric availability
    try {
      biometricAvailable.value = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      biometricAvailable.value = false;
    }

    // If not set up, don't lock
    if (!isSetupComplete.value) {
      isLocked.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PIN MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Hash a PIN using SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin + 'magic_ledger_salt_v1');
    return sha256.convert(bytes).toString();
  }

  /// Set up PIN for the first time. Returns the 12-word recovery phrase.
  Future<String> setupPin(String pin) async {
    final pinHash = _hashPin(pin);
    final recoveryPhrase = _generateRecoveryPhrase();
    final recoveryHash = _hashPin(recoveryPhrase);

    await _authBox.put(_pinHashKey, pinHash);
    await _authBox.put(_recoveryHashKey, recoveryHash);
    await _authBox.put(_isSetupCompleteKey, true);
    await _authBox.put(_failedAttemptsKey, 0);

    isSetupComplete.value = true;
    isLocked.value = false;
    failedAttempts.value = 0;

    return recoveryPhrase;
  }

  /// Verify PIN. Returns true if correct.
  bool verifyPin(String pin) {
    // Check lockout
    if (isLockedOut) {
      return false;
    }

    final storedHash = _authBox.get(_pinHashKey) as String?;
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    if (inputHash == storedHash) {
      // Success — reset attempts
      failedAttempts.value = 0;
      _authBox.put(_failedAttemptsKey, 0);
      _authBox.delete(_lockoutUntilKey);
      lockoutUntil.value = null;
      isLocked.value = false;
      return true;
    } else {
      // Failed — increment attempts
      failedAttempts.value++;
      _authBox.put(_failedAttemptsKey, failedAttempts.value);

      if (failedAttempts.value >= maxFailedAttempts) {
        final until = DateTime.now().add(const Duration(minutes: lockoutMinutes));
        lockoutUntil.value = until;
        _authBox.put(_lockoutUntilKey, until.toIso8601String());
      }
      return false;
    }
  }

  /// Check if currently locked out due to failed attempts
  bool get isLockedOut {
    if (lockoutUntil.value == null) return false;
    if (DateTime.now().isAfter(lockoutUntil.value!)) {
      // Lockout expired
      lockoutUntil.value = null;
      _authBox.delete(_lockoutUntilKey);
      failedAttempts.value = 0;
      _authBox.put(_failedAttemptsKey, 0);
      return false;
    }
    return true;
  }

  /// Remaining lockout seconds
  int get lockoutRemainingSeconds {
    if (lockoutUntil.value == null) return 0;
    final remaining = lockoutUntil.value!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Change PIN (requires old PIN verification)
  Future<bool> changePin(String oldPin, String newPin) async {
    if (!verifyPin(oldPin)) return false;
    final pinHash = _hashPin(newPin);
    await _authBox.put(_pinHashKey, pinHash);
    isLocked.value = false;
    return true;
  }

  /// Reset PIN using recovery phrase. Returns true if phrase matches.
  Future<bool> resetPinWithRecovery(String recoveryPhrase, String newPin) async {
    final storedRecoveryHash = _authBox.get(_recoveryHashKey) as String?;
    if (storedRecoveryHash == null) return false;

    final inputHash = _hashPin(recoveryPhrase.trim().toLowerCase());
    if (inputHash == storedRecoveryHash) {
      final pinHash = _hashPin(newPin);
      await _authBox.put(_pinHashKey, pinHash);
      failedAttempts.value = 0;
      await _authBox.put(_failedAttemptsKey, 0);
      await _authBox.delete(_lockoutUntilKey);
      lockoutUntil.value = null;
      isLocked.value = false;
      return true;
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // BIOMETRIC
  // ═══════════════════════════════════════════════════════════

  /// Enable/disable biometric auth
  Future<void> setBiometric(bool enabled) async {
    biometricEnabled.value = enabled;
    await _authBox.put(_biometricEnabledKey, enabled);
  }

  /// Attempt biometric authentication
  Future<bool> authenticateWithBiometric() async {
    if (!biometricEnabled.value || !biometricAvailable.value) return false;

    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Unlock Magic Ledger',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (result) {
        isLocked.value = false;
        failedAttempts.value = 0;
        _authBox.put(_failedAttemptsKey, 0);
      }
      return result;
    } catch (e) {
      debugPrint('[Auth] Biometric error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LOCK MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Lock the app (called when going to background)
  void lockApp() {
    if (isSetupComplete.value) {
      isLocked.value = true;
    }
  }

  /// Unlock the app
  void unlockApp() {
    isLocked.value = false;
  }

  /// Set lock timeout in seconds (0 = immediate)
  Future<void> setLockTimeout(int seconds) async {
    lockTimeout.value = seconds;
    await _authBox.put(_lockTimeoutKey, seconds);
  }

  /// Check if setup is needed
  bool get needsSetup => !isSetupComplete.value;

  // ═══════════════════════════════════════════════════════════
  // RECOVERY PHRASE GENERATION
  // ═══════════════════════════════════════════════════════════

  /// Generate a 12-word recovery phrase from curated word list
  String _generateRecoveryPhrase() {
    final random = Random.secure();
    final words = <String>[];
    for (int i = 0; i < 12; i++) {
      words.add(_wordList[random.nextInt(_wordList.length)]);
    }
    return words.join(' ');
  }

  /// Curated word list — 256 simple, unambiguous English words
  static const _wordList = [
    'apple','arrow','beach','bells','bird','blade','blank','bloom','board','bone',
    'brave','bread','brick','brush','cabin','candy','chain','chalk','charm','chase',
    'chess','chief','child','clean','climb','clock','cloud','coach','coast','coral',
    'craft','crane','creek','crown','dance','delta','depth','disco','dream','drift',
    'eagle','earth','enjoy','equal','fairy','feast','field','flame','flash','float',
    'flood','floor','focus','forge','frame','fresh','frost','fruit','glass','globe',
    'grace','grain','grape','green','grove','guard','guide','happy','heart','honey',
    'house','ivory','jewel','juice','karma','knack','lance','lemon','light','lilac',
    'magic','maple','marsh','medal','melon','merry','metal','might','model','month',
    'moose','mount','music','noble','north','ocean','olive','onion','orbit','oxide',
    'paint','palm','panel','paper','patch','peace','pearl','penny','piano','pilot',
    'pixel','pizza','place','plain','plant','plaza','plumb','point','polar','pride',
    'prime','prize','proof','pulse','queen','quest','quick','quiet','radar','ranch',
    'raven','reach','realm','rider','ridge','river','robin','rocky','royal','ruby',
    'saint','scale','scene','scout','shade','shape','shelf','shell','shift','shine',
    'shore','sigma','silk','silver','skate','skill','slate','sleep','slice','slope',
    'smile','smoke','solar','solid','south','space','spark','spear','spice','spine',
    'spoke','spray','squad','stack','stage','stamp','stand','steam','steel','stern',
    'stone','storm','stove','sugar','super','surge','sweet','swift','swing','table',
    'tenor','theta','tiger','toast','token','tower','trace','track','trade','trail',
    'train','trend','tribe','trout','trunk','trust','tulip','tuner','ultra','uncle',
    'unity','upper','urban','valve','vapor','vault','verse','video','vigor','vinyl',
    'viola','voice','wagon','water','whale','wheat','wheel','white','width','world',
    'yacht','youth','zebra','zesty','bloom','brave','cedar','charm','coral','delta',
    'ember','faith','gleam','haven','ivory','jewel',
  ];

  /// Complete reset — clears all auth data
  Future<void> resetAll() async {
    await _authBox.clear();
    isSetupComplete.value = false;
    isLocked.value = false;
    biometricEnabled.value = false;
    failedAttempts.value = 0;
    lockoutUntil.value = null;
  }
}