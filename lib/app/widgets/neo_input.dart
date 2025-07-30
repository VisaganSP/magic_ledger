import 'package:flutter/material.dart';

import '../theme/neo_brutalism_theme.dart';

class NeoInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final String? prefixText;
  final IconData? suffixIcon;
  final bool? isDark;

  const NeoInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixText,
    this.suffixIcon,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // If isDark is not provided, detect from theme
    final bool darkMode =
        isDark ?? Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color:
                darkMode
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: NeoBrutalismTheme.neoBox(
            color:
                darkMode
                    ? NeoBrutalismTheme.darkSurface
                    : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:
                  darkMode
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
            cursorColor:
                darkMode
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefixText,
              prefixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    darkMode
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
              ),
              suffixIcon:
                  suffixIcon != null
                      ? Icon(
                        suffixIcon,
                        color:
                            darkMode
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack,
                      )
                      : null,
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: darkMode ? Colors.grey[600] : Colors.grey[400],
                fontWeight: FontWeight.normal,
              ),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
