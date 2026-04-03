import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/savings_goal_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_input.dart';
import '../controllers/savings_controller.dart';

class AddSavingsGoalView extends StatefulWidget {
  const AddSavingsGoalView({super.key});
  @override
  State<AddSavingsGoalView> createState() => _AddSavingsGoalViewState();
}

class _AddSavingsGoalViewState extends State<AddSavingsGoalView> {
  final SavingsController ctrl = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedIcon = '🎯';
  Color _selectedColor = const Color(0xFFBFE3F0);
  DateTime? _targetDate;

  static const _icons = ['🎯','🏠','🚗','✈️','💻','📱','👕','🎓','💍','🏖️','🎸','🏋️','📷','🎮','💎','🏥','👶','🐕','🎨','🔑'];
  static const _colors = [
    Color(0xFFBFE3F0), Color(0xFFB8E994), Color(0xFFFDB5D6), Color(0xFFFDD663),
    Color(0xFFFFB49A), Color(0xFF9DB4FF), Color(0xFFDCC9E8), Color(0xFFD4E4D1),
    Color(0xFFA7C7E7), Color(0xFFE57373), Color(0xFF4DB6AC), Color(0xFFF5E6D3),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final goal = SavingsGoalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      targetAmount: double.parse(_amountController.text),
      icon: _selectedIcon,
      color: _selectedColor.value,
      createdAt: DateTime.now(),
      targetDate: _targetDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    ctrl.addGoal(goal);
    Get.back();
    Get.snackbar('Created!', '${goal.name} savings goal added',
        backgroundColor: NeoBrutalismTheme.accentGreen, colorText: NeoBrutalismTheme.primaryBlack,
        borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(title: const Text('NEW SAVINGS GOAL',
          style: TextStyle(fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
          foregroundColor: NeoBrutalismTheme.primaryBlack, elevation: 0),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        // Preview
        Center(child: Container(width: 100, height: 100,
            decoration: NeoBrutalismTheme.neoBox(color: _selectedColor, borderColor: NeoBrutalismTheme.primaryBlack, offset: 5),
            child: Center(child: Text(_selectedIcon, style: const TextStyle(fontSize: 40))))),
        const SizedBox(height: 16),
        NeoInput(controller: _nameController, label: 'GOAL NAME', hint: 'e.g., New MacBook', isDark: isDark,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null),
        const SizedBox(height: 16),
        _buildAmountField(isDark),
        const SizedBox(height: 16),
        _buildDatePicker(isDark),
        const SizedBox(height: 16),
        _buildIconGrid(isDark),
        const SizedBox(height: 16),
        _buildColorGrid(isDark),
        const SizedBox(height: 16),
        NeoInput(controller: _notesController, label: 'NOTES (OPTIONAL)', hint: 'Why this goal?', maxLines: 2, isDark: isDark),
        const SizedBox(height: 32),
        NeoButton(text: 'CREATE GOAL', onPressed: _save,
            color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark), height: 64, icon: Icons.save),
      ])),
    );
  }

  Widget _buildAmountField(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('TARGET AMOUNT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      TextFormField(controller: _amountController, keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
          decoration: InputDecoration(hintText: '0.00', prefixText: '\u{20B9} ',
              filled: true, fillColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 4))),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter an amount';
            if ((double.tryParse(v) ?? 0) <= 0) return 'Must be greater than 0';
            return null;
          }),
    ]);
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context,
              initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 90)),
              firstDate: DateTime.now(), lastDate: DateTime(2035));
          if (picked != null) setState(() { _targetDate = picked; });
        },
        child: NeoCard(color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TARGET DATE (OPTIONAL)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                const SizedBox(height: 4),
                Text(_targetDate != null ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}' : 'No deadline',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                        color: _targetDate != null
                            ? (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)
                            : Colors.grey)),
              ]),
              Icon(Icons.calendar_today, color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ])));
  }

  Widget _buildIconGrid(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ICON', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _icons.map((icon) {
        final sel = _selectedIcon == icon;
        return GestureDetector(onTap: () => setState(() { _selectedIcon = icon; }),
            child: AnimatedContainer(duration: const Duration(milliseconds: 150), width: 44, height: 44,
                decoration: BoxDecoration(
                    color: sel ? NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: sel ? Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2) : null),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 24)))));
      }).toList()),
    ]);
  }

  Widget _buildColorGrid(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('COLOR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _colors.map((c) {
        final sel = _selectedColor.value == c.value;
        return GestureDetector(onTap: () => setState(() { _selectedColor = c; }),
            child: AnimatedContainer(duration: const Duration(milliseconds: 150), width: 36, height: 36,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                    border: Border.all(color: sel ? NeoBrutalismTheme.primaryBlack : Colors.transparent, width: sel ? 3 : 0)),
                child: sel ? const Icon(Icons.check, size: 16, color: NeoBrutalismTheme.primaryBlack) : null));
      }).toList()),
    ]);
  }
}