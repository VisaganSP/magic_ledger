import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.08),
                _buildLogo(isDark),
                SizedBox(height: screenHeight * 0.06),
                _buildLoginForm(isDark),
                SizedBox(height: screenHeight * 0.04),
                _buildQuickLoginOptions(isDark),
                SizedBox(height: screenHeight * 0.06),
                _buildSkipOption(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    if (color == NeoBrutalismTheme.accentYellow) {
      return Color(0xFFE6B800);
    } else if (color == NeoBrutalismTheme.accentPink) {
      return Color(0xFFE667A0);
    } else if (color == NeoBrutalismTheme.accentBlue) {
      return Color(0xFF4D94FF);
    } else if (color == NeoBrutalismTheme.accentGreen) {
      return Color(0xFF00CC66);
    } else if (color == NeoBrutalismTheme.accentOrange) {
      return Color(0xFFFF8533);
    } else if (color == NeoBrutalismTheme.accentPurple) {
      return Color(0xFF9966FF);
    }
    return color;
  }

  Widget _buildLogo(bool isDark) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: NeoBrutalismTheme.neoBox(
            color: _getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
            borderColor: NeoBrutalismTheme.primaryBlack,
            offset: 8,
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 60,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'MAGIC LEDGER',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          'Track. Save. Achieve.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildLoginForm(bool isDark) {
    return NeoCard(
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WELCOME BACK',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            'USERNAME',
            controller.usernameController,
            Icons.person,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'PIN',
            controller.pinController,
            Icons.lock,
            isDark,
            isPin: true,
            maxLength: 4,
          ),
          const SizedBox(height: 24),
          Obx(() => controller.isLoading.value
              ? Center(
            child: CircularProgressIndicator(
              color: _getThemedColor(
                  NeoBrutalismTheme.accentPurple, isDark),
            ),
          )
              : NeoButton(
            text: 'LOGIN',
            onPressed: () => controller.login(),
            color: _getThemedColor(
                NeoBrutalismTheme.accentGreen, isDark),
            icon: Icons.arrow_forward,
            width: double.infinity,
          )),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _showCreateAccountDialog(isDark),
              child: Text(
                'CREATE NEW ACCOUNT',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: _getThemedColor(
                      NeoBrutalismTheme.accentBlue, isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      bool isDark, {
        bool isPin = false,
        int? maxLength,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: NeoBrutalismTheme.neoBox(
            color: isDark
                ? NeoBrutalismTheme.darkBackground
                : NeoBrutalismTheme.lightBackground,
            borderColor: NeoBrutalismTheme.primaryBlack,
            offset: 4,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPin,
            keyboardType: isPin ? TextInputType.number : TextInputType.text,
            maxLength: maxLength,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
              hintText: isPin ? '••••' : 'Enter $label',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLoginOptions(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => controller.biometricAvailable.value
            ? NeoButton(
          text: 'USE BIOMETRICS',
          onPressed: () => controller.authenticateWithBiometrics(),
          color: _getThemedColor(
              NeoBrutalismTheme.accentPurple, isDark),
          icon: Icons.fingerprint,
          width: double.infinity,
        )
            : const SizedBox()),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildSkipOption(bool isDark) {
    return TextButton(
      onPressed: () => controller.skipLogin(),
      child: Text(
        'SKIP FOR NOW',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
          decoration: TextDecoration.underline,
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  void _showCreateAccountDialog(bool isDark) {
    final newUsernameController = TextEditingController();
    final newPinController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBox(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
            offset: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: NeoBrutalismTheme.neoBox(
                  color: _getThemedColor(
                      NeoBrutalismTheme.accentBlue, isDark),
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 32,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'USERNAME',
                newUsernameController,
                Icons.person,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'CREATE PIN',
                newPinController,
                Icons.lock,
                isDark,
                isPin: true,
                maxLength: 4,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color: isDark
                          ? NeoBrutalismTheme.darkBackground
                          : NeoBrutalismTheme.lightBackground,
                      textColor: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'CREATE',
                      onPressed: () {
                        controller.createAccount(
                          newUsernameController.text,
                          newPinController.text,
                        );
                      },
                      color: _getThemedColor(
                          NeoBrutalismTheme.accentGreen, isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}