import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

class AuthController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  final Box settingsBox = Hive.box('settings');

  final usernameController = TextEditingController();
  final pinController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool biometricAvailable = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkBiometricAvailability();
    checkExistingAuth();
  }

  @override
  void onClose() {
    usernameController.dispose();
    pinController.dispose();
    super.onClose();
  }

  Future<void> checkBiometricAvailability() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      biometricAvailable.value = isAvailable && isDeviceSupported;
    } catch (e) {
      biometricAvailable.value = false;
    }
  }

  void checkExistingAuth() {
    // Check if user is already logged in
    final isLoggedIn = settingsBox.get('isLoggedIn', defaultValue: false);
    if (isLoggedIn) {
      isAuthenticated.value = true;
      Get.offAllNamed('/home');
    }
  }

  Future<void> login() async {
    if (usernameController.text.isEmpty || pinController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter username and PIN',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderWidth: 3,
        borderColor: Colors.black,
      );
      return;
    }

    if (pinController.text.length != 4) {
      Get.snackbar(
        'Error',
        'PIN must be 4 digits',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderWidth: 3,
        borderColor: Colors.black,
      );
      return;
    }

    isLoading.value = true;

    // Simulate login process
    await Future.delayed(const Duration(seconds: 1));

    // Check stored credentials
    final storedUsername = settingsBox.get('username');
    final storedPin = settingsBox.get('pin');

    if (storedUsername == null || storedPin == null) {
      isLoading.value = false;
      Get.snackbar(
        'No Account',
        'Please create an account first',
        backgroundColor: Colors.orange,
        colorText: Colors.black,
        borderWidth: 3,
        borderColor: Colors.black,
      );
      return;
    }

    if (storedUsername == usernameController.text &&
        storedPin == pinController.text) {
      // Successful login
      await settingsBox.put('isLoggedIn', true);
      await settingsBox.put('lastLogin', DateTime.now().toIso8601String());
      isAuthenticated.value = true;
      isLoading.value = false;

      Get.snackbar(
        'Welcome Back!',
        'Login successful',
        backgroundColor: const Color(0xFF00CC66),
        colorText: Colors.black,
        borderWidth: 3,
        borderColor: Colors.black,
      );

      Get.offAllNamed('/home');
    } else {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Invalid username or PIN',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderWidth: 3,
        borderColor: Colors.black,
      );
    }
  }

  Future<void> createAccount(String username, String pin) async {
    if (username.isEmpty || pin.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderWidth: 3,
        borderColor: Colors.black,
      );
      return;
    }

    if (pin.length != 4 || !RegExp(r'^\d+$').hasMatch(pin)) {
      Get.snackbar(
        'Error',
        'PIN must be 4 digits',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderWidth: 3,
        borderColor: Colors.black,
      );
      return;
    }

    // Save credentials
    await settingsBox.put('username', username);
    await settingsBox.put('pin', pin);
    await settingsBox.put('isLoggedIn', true);
    await settingsBox.put('accountCreated', DateTime.now().toIso8601String());

    isAuthenticated.value = true;

    Get.back(); // Close dialog

    Get.snackbar(
      'Success',
      'Account created successfully!',
      backgroundColor: const Color(0xFF00CC66),
      colorText: Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
    );

    Get.offAllNamed('/home');
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access Magic Ledger',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Check if account exists
        final hasAccount = settingsBox.get('username') != null;

        if (hasAccount) {
          await settingsBox.put('isLoggedIn', true);
          isAuthenticated.value = true;

          Get.snackbar(
            'Success',
            'Biometric authentication successful',
            backgroundColor: const Color(0xFF00CC66),
            colorText: Colors.black,
            borderWidth: 3,
            borderColor: Colors.black,
          );

          Get.offAllNamed('/home');
        } else {
          Get.snackbar(
            'No Account',
            'Please create an account first',
            backgroundColor: Colors.orange,
            colorText: Colors.black,
            borderWidth: 3,
            borderColor: Colors.black,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Biometric authentication failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderWidth: 3,
        borderColor: Colors.black,
      );
    }
  }

  void skipLogin() {
    Get.offAllNamed('/home');
  }

  Future<void> logout() async {
    await settingsBox.put('isLoggedIn', false);
    isAuthenticated.value = false;

    // Clear controllers
    usernameController.clear();
    pinController.clear();

    Get.offAllNamed('/login');
  }

  bool get hasAccount => settingsBox.get('username') != null;

  String? get currentUsername => settingsBox.get('username');
}
