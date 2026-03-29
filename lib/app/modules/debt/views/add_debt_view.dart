import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/debt_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_input.dart';
import '../controllers/debt_controller.dart';

class AddDebtView extends StatefulWidget {
  const AddDebtView({super.key});
  @override
  State<AddDebtView> createState() => _AddDebtViewState();
}

class _AddDebtViewState extends State<AddDebtView> {
  final DebtController ctrl = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _principalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _emiCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedType = 'personal_loan';
  int _emiDay = 5;

  @override
  void dispose() {
    _nameCtrl.dispose(); _principalCtrl.dispose(); _rateCtrl.dispose();
    _emiCtrl.dispose(); _tenureCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final info = DebtController.debtTypes[_selectedType]!;
    final debt = DebtModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      principalAmount: double.parse(_principalCtrl.text),
      interestRate: double.tryParse(_rateCtrl.text) ?? 0,
      emiAmount: double.parse(_emiCtrl.text),
      tenureMonths: int.parse(_tenureCtrl.text),
      startDate: DateTime.now(),
      debtType: _selectedType,
      icon: info['icon'] as String,
      color: info['color'] as int,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      emiDay: _emiDay,
    );
    ctrl.addDebt(debt);
    Get.back();
    Get.snackbar('Added', '${debt.name} debt tracked',
        backgroundColor: NeoBrutalismTheme.accentGreen, colorText: NeoBrutalismTheme.primaryBlack,
        borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(title: const Text('ADD DEBT / EMI',
          style: TextStyle(fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
          foregroundColor: NeoBrutalismTheme.primaryBlack, elevation: 0),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        _buildTypeSelector(isDark),
        const SizedBox(height: 16),
        NeoInput(controller: _nameCtrl, label: 'LOAN NAME', hint: 'e.g., HDFC Home Loan', isDark: isDark,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null),
        const SizedBox(height: 16),
        _buildNumberField(_principalCtrl, 'PRINCIPAL AMOUNT', '\u{20B9} ', isDark),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildNumberField(_rateCtrl, 'INTEREST RATE %', '', isDark, isRequired: false)),
          const SizedBox(width: 12),
          Expanded(child: _buildNumberField(_tenureCtrl, 'TENURE (MONTHS)', '', isDark, isDecimal: false)),
        ]),
        const SizedBox(height: 16),
        _buildNumberField(_emiCtrl, 'EMI AMOUNT', '\u{20B9} ', isDark),
        const SizedBox(height: 16),
        _buildEmiDayPicker(isDark),
        const SizedBox(height: 16),
        NeoInput(controller: _notesCtrl, label: 'NOTES (OPTIONAL)', hint: 'Any details...', maxLines: 2, isDark: isDark),
        const SizedBox(height: 16),
        _buildPreview(isDark),
        const SizedBox(height: 32),
        NeoButton(text: 'ADD DEBT', onPressed: _save,
            color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark), height: 64, icon: Icons.save),
      ])),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('DEBT TYPE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: DebtController.debtTypes.entries.map((e) {
        final sel = _selectedType == e.key;
        return GestureDetector(
            onTap: () => setState(() { _selectedType = e.key; }),
            child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: sel ? Color(e.value['color'] as int) : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: sel ? 3 : 2)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(e.value['icon'] as String, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(e.value['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: isDark && !sel ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                ])));
      }).toList()),
    ]);
  }

  Widget _buildNumberField(TextEditingController ctrl, String label, String prefix, bool isDark,
      {bool isRequired = true, bool isDecimal = true}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      TextFormField(controller: ctrl,
          keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
          decoration: InputDecoration(hintText: '0', prefixText: prefix.isNotEmpty ? prefix : null,
              filled: true, fillColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 4))),
          validator: isRequired ? (v) {
            if (v == null || v.isEmpty) return 'Required';
            if ((double.tryParse(v) ?? 0) <= 0) return 'Must be > 0';
            return null;
          } : null),
    ]);
  }

  Widget _buildEmiDayPicker(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('EMI DUE DAY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [1, 5, 7, 10, 15, 20, 25, 28].map((d) {
        final sel = _emiDay == d;
        return GestureDetector(onTap: () => setState(() { _emiDay = d; }),
            child: Container(width: 38, height: 38,
                decoration: BoxDecoration(color: sel ? NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBlue, isDark)
                    : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: sel ? 3 : 2)),
                child: Center(child: Text('$d', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)))));
      }).toList()),
    ]);
  }

  Widget _buildPreview(bool isDark) {
    final p = double.tryParse(_principalCtrl.text) ?? 0;
    final emi = double.tryParse(_emiCtrl.text) ?? 0;
    final tenure = int.tryParse(_tenureCtrl.text) ?? 0;
    if (p <= 0 || emi <= 0 || tenure <= 0) return const SizedBox();

    final totalPayable = emi * tenure;
    final totalInterest = totalPayable - p;

    return Container(padding: const EdgeInsets.all(14),
        decoration: NeoBrutalismTheme.neoBox(
            color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark).withOpacity(0.5),
            borderColor: NeoBrutalismTheme.primaryBlack, offset: 3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack, borderRadius: BorderRadius.circular(4)),
              child: const Text('PREVIEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total payable', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              Text('\u{20B9}${totalPayable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Total interest', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              Text('\u{20B9}${totalInterest.toStringAsFixed(0)}', style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w900, color: totalInterest > 0 ? const Color(0xFFE57373) : const Color(0xFF00CC66))),
            ])),
          ]),
        ]));
  }
}