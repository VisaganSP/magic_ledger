import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';

class CalculatorDialog extends StatefulWidget {
  final bool isDark;
  final double initialAmount;

  const CalculatorDialog({
    super.key,
    required this.isDark,
    this.initialAmount = 0,
  });

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _display = '0';
  String _previousValue = '';
  String _operator = '';
  bool _shouldResetDisplay = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount > 0) {
      _display = widget.initialAmount.toString();
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldResetDisplay || _display == '0') {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display += number;
      }
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      if (_previousValue.isNotEmpty && !_shouldResetDisplay) {
        _calculate();
      }
      _previousValue = _display;
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _calculate() {
    if (_previousValue.isEmpty || _operator.isEmpty) return;

    final double prev = double.tryParse(_previousValue) ?? 0;
    final double current = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = prev + current;
        break;
      case '-':
        result = prev - current;
        break;
      case '×':
        result = prev * current;
        break;
      case '÷':
        result = current != 0 ? prev / current : 0;
        break;
    }

    setState(() {
      _display = result.toString();
      _previousValue = '';
      _operator = '';
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPressed() {
    _calculate();
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _previousValue = '';
      _operator = '';
      _shouldResetDisplay = false;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onApply() {
    final double amount = double.tryParse(_display) ?? 0;
    if (amount > 0) {
      Get.back(result: amount);
    } else {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid amount greater than 0',
        backgroundColor: Colors.red,
        colorText: NeoBrutalismTheme.primaryWhite,
        borderWidth: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: NeoBrutalismTheme.neoBoxRounded(
          color: widget.isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDisplay(),
            const SizedBox(height: 16),
            _buildCalculatorButtons(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'CALCULATOR',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: widget.isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.close,
            color: widget.isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(
        color: widget.isDark
            ? NeoBrutalismTheme.darkBackground
            : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_previousValue.isNotEmpty && _operator.isNotEmpty)
            Text(
              '$_previousValue $_operator',
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark ? Colors.grey[400] : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            '₹ $_display',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: widget.isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButtons() {
    return Column(
      children: [
        _buildButtonRow(['7', '8', '9', '÷']),
        const SizedBox(height: 8),
        _buildButtonRow(['4', '5', '6', '×']),
        const SizedBox(height: 8),
        _buildButtonRow(['1', '2', '3', '-']),
        const SizedBox(height: 8),
        _buildButtonRow(['C', '0', '.', '+']),
        const SizedBox(height: 8),
        _buildSpecialButtonRow(),
      ],
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      children: buttons.map((button) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCalculatorButton(button),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecialButtonRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCalculatorButton('⌫'),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCalculatorButton('='),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatorButton(String value) {
    final isOperator = ['+', '-', '×', '÷'].contains(value);
    final isSpecial = ['C', '=', '⌫'].contains(value);

    Color buttonColor;
    if (isOperator) {
      buttonColor = widget.isDark
          ? Color(0xFF4D94FF)
          : NeoBrutalismTheme.accentBlue;
    } else if (isSpecial) {
      if (value == 'C') {
        buttonColor = widget.isDark ? Color(0xFFE667A0) : NeoBrutalismTheme.accentPink;
      } else if (value == '=') {
        buttonColor = widget.isDark ? Color(0xFF00CC66) : NeoBrutalismTheme.accentGreen;
      } else {
        buttonColor = widget.isDark ? Color(0xFFFF8533) : NeoBrutalismTheme.accentOrange;
      }
    } else {
      buttonColor = widget.isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.primaryWhite;
    }

    return GestureDetector(
      onTap: () {
        if (value == 'C') {
          _onClearPressed();
        } else if (value == '=') {
          _onEqualsPressed();
        } else if (value == '⌫') {
          _onBackspacePressed();
        } else if (value == '.') {
          _onDecimalPressed();
        } else if (isOperator) {
          _onOperatorPressed(value);
        } else {
          _onNumberPressed(value);
        }
      },
      child: Container(
        height: 60,
        decoration: NeoBrutalismTheme.neoBox(
          color: buttonColor,
          borderColor: NeoBrutalismTheme.primaryBlack,
          offset: 3,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: value == '⌫' ? 20 : 24,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: NeoButton(
            text: 'CANCEL',
            onPressed: () => Get.back(),
            color: widget.isDark
                ? NeoBrutalismTheme.darkBackground
                : NeoBrutalismTheme.primaryWhite,
            textColor: widget.isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NeoButton(
            text: 'APPLY',
            onPressed: _onApply,
            color: widget.isDark
                ? Color(0xFF00CC66)
                : NeoBrutalismTheme.accentGreen,
          ),
        ),
      ],
    );
  }
}