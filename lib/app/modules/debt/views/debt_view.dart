import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/debt_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../controllers/debt_controller.dart';

class DebtView extends GetView<DebtController> {
  const DebtView({super.key});

  String _cur(double v) => NumberFormat.currency(symbol: '\u{20B9}', decimalDigits: 0).format(v);
  String _dateFmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 90, pinned: true,
            backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
            foregroundColor: NeoBrutalismTheme.primaryBlack,
            flexibleSpace: const FlexibleSpaceBar(
                title: Text('DEBT TRACKER', style: TextStyle(fontWeight: FontWeight.w900,
                    fontSize: 20, color: NeoBrutalismTheme.primaryBlack)),
                titlePadding: EdgeInsets.only(left: 56, bottom: 14))),
        SliverPadding(padding: const EdgeInsets.all(16),
            sliver: Obx(() => SliverList(delegate: SliverChildListDelegate([
              _buildOverview(isDark),
              const SizedBox(height: 16),
              if (controller.activeDebts.isNotEmpty) _buildNextEmi(isDark),
              if (controller.activeDebts.isNotEmpty) const SizedBox(height: 16),
              if (controller.debts.isEmpty) _buildEmpty(isDark)
              else ...controller.debts.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildDebtCard(e.value, isDark, e.key))),
              const SizedBox(height: 100),
            ])))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/add-debt'),
          backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
          label: const Text('ADD DEBT', style: TextStyle(fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
          icon: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3))),
    );
  }

  Widget _buildOverview(bool isDark) {
    final freeDate = controller.debtFreeDate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack, borderRadius: BorderRadius.circular(4)),
              child: const Text('DEBT OVERVIEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white))),
          const Spacer(),
          Text('${controller.activeDebts.length} active', style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: NeoBrutalismTheme.primaryBlack)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('REMAINING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
            Text(_cur(controller.totalDebt), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                color: controller.totalDebt > 0 ? const Color(0xFFE57373) : const Color(0xFF00CC66))),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('EMI/MONTH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
            Text(_cur(controller.totalEmiPerMonth), style: const TextStyle(fontSize: 22,
                fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          ])),
        ]),
        if (freeDate != null) ...[
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD4E4D1), borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
              child: Row(children: [
                const Icon(Icons.celebration, size: 18, color: NeoBrutalismTheme.primaryBlack),
                const SizedBox(width: 8),
                Text('Debt-free by ${_dateFmt(freeDate)}', style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
              ])),
        ],
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildNextEmi(bool isDark) {
    final next = controller.nextEmiDue;
    if (next == null) return const SizedBox();
    final info = DebtController.debtTypes[next.debtType] ?? DebtController.debtTypes['other']!;
    final days = next.daysUntilNextEmi ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: NeoBrutalismTheme.neoBox(
          color: days <= 3 ? const Color(0xFFFFE0E0) : const Color(0xFFBFE3F0),
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
      child: Row(children: [
        Text(info['icon'], style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEXT EMI: ${next.name.toUpperCase()}', style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          Text('${_cur(next.emiAmount)} due in $days days', style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.6))),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack, borderRadius: BorderRadius.circular(10)),
            child: Text('$days d', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white))),
      ]),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildDebtCard(DebtModel debt, bool isDark, int index) {
    final info = DebtController.debtTypes[debt.debtType] ?? DebtController.debtTypes['other']!;
    return Container(
      decoration: NeoBrutalismTheme.neoBox(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
      child: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Color(info['color'] as int),
                border: const Border(bottom: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3))),
            child: Row(children: [
              Text(info['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(debt.name.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.primaryBlack)),
                Text('${info['label']} \u2022 ${debt.monthsRemaining} months left',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.5))),
              ])),
              if (debt.isCompleted) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFB8E994), borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
                  child: const Text('PAID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.primaryBlack))),
              PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'payment') _showPaymentDialog(debt, isDark);
                    else if (v == 'schedule') _showAmortization(debt, isDark);
                    else if (v == 'extra') _showExtraPaymentCalc(debt, isDark);
                    else if (v == 'payoff') { controller.markPaidOff(debt.id); }
                    else if (v == 'delete') { controller.deleteDebt(debt.id); }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'payment', child: Text('Record payment')),
                    const PopupMenuItem(value: 'schedule', child: Text('Amortization schedule')),
                    const PopupMenuItem(value: 'extra', child: Text('Extra payment calculator')),
                    const PopupMenuItem(value: 'payoff', child: Text('Mark paid off')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                  child: const Icon(Icons.more_vert, size: 20, color: NeoBrutalismTheme.primaryBlack)),
            ])),

        Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PRINCIPAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              Text(_cur(debt.principalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Text('PAID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              Text(_cur(debt.totalPaid), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: Color(0xFF00CC66))),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('EMI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              Text(_cur(debt.emiAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack)),
            ])),
          ]),
          const SizedBox(height: 12),
          _progressBar(debt.progressPercent, isDark),
          const SizedBox(height: 12),
          Row(children: [
            _insightTile('${debt.interestRate.toStringAsFixed(1)}%', 'Rate', const Color(0xFFFDD663), isDark),
            const SizedBox(width: 8),
            _insightTile(_cur(debt.totalInterest), 'Total interest', const Color(0xFFE57373), isDark),
            const SizedBox(width: 8),
            _insightTile(_cur(debt.remainingAmount), 'Remaining', const Color(0xFFBFE3F0), isDark),
          ]),
          if (debt.isActive && !debt.isCompleted) ...[
            const SizedBox(height: 12),
            NeoButton(text: 'RECORD PAYMENT', onPressed: () => _showPaymentDialog(debt, isDark),
                color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark), icon: Icons.payment),
          ],
        ])),
      ]),
    ).animate().fadeIn(delay: (150 * index).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _insightTile(String value, String label, Color color, bool isDark) {
    return Expanded(child: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.2 : 0.4),
            borderRadius: BorderRadius.circular(8), border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          Text(label, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ])));
  }

  Widget _progressBar(double pct, bool isDark) {
    return Container(height: 14,
        decoration: BoxDecoration(border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
            borderRadius: BorderRadius.circular(7)),
        child: ClipRRect(borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(value: (pct / 100).clamp(0, 1),
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(pct >= 100 ? const Color(0xFF00CC66) : const Color(0xFF4D94FF)),
                minHeight: 14)));
  }

  Widget _buildEmpty(bool isDark) {
    return Container(padding: const EdgeInsets.all(40),
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
        child: Column(children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No debts tracked!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 4),
          Text('Add loans, credit cards, or EMIs', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]));
  }

  void _showPaymentDialog(DebtModel debt, bool isDark) {
    final tc = TextEditingController(text: debt.emiAmount.toStringAsFixed(0));
    Get.dialog(Dialog(backgroundColor: Colors.transparent, child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('PAYMENT: ${debt.name.toUpperCase()}', style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w900, color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 16),
          TextField(controller: tc, keyboardType: TextInputType.number, autofocus: true,
              decoration: InputDecoration(hintText: '0', prefixText: '\u{20B9} ',
                  border: OutlineInputBorder(borderSide: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Navigator.of(Get.context!).pop(), color: NeoBrutalismTheme.primaryWhite)),
            const SizedBox(width: 12),
            Expanded(child: NeoButton(text: 'PAY', onPressed: () {
              final amt = double.tryParse(tc.text) ?? 0;
              if (amt > 0) { controller.makePayment(debt.id, amt); Navigator.of(Get.context!).pop();
              Get.snackbar('Paid!', '${_cur(amt)} recorded for ${debt.name}',
                  backgroundColor: const Color(0xFFB8E994), colorText: NeoBrutalismTheme.primaryBlack); }
            }, color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark))),
          ]),
        ]))));
  }

  void _showAmortization(DebtModel debt, bool isDark) {
    final schedule = controller.getAmortizationSchedule(debt);
    Get.bottomSheet(Container(
      height: MediaQuery.of(Get.context!).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: const Border(top: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3))),
      child: Column(children: [
        Text('AMORTIZATION: ${debt.name.toUpperCase()}', style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w900, color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 12),
        Expanded(child: ListView.builder(itemCount: schedule.length, itemBuilder: (ctx, i) {
          final s = schedule[i]; final isPaid = i < debt.monthsPaid;
          return Container(margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFD4E4D1) : (isDark ? NeoBrutalismTheme.darkBackground : const Color(0xFFFAF8F6)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1)),
              child: Row(children: [
                SizedBox(width: 30, child: Text('#${s['month']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                Expanded(child: Text('P: ${_cur(s['principal'])}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                Expanded(child: Text('I: ${_cur(s['interest'])}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Bal: ${_cur(s['balance'])}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                if (isPaid) const Icon(Icons.check_circle, size: 14, color: Color(0xFF00CC66)),
              ]));
        })),
      ]),
    ), isScrollControlled: true);
  }

  void _showExtraPaymentCalc(DebtModel debt, bool isDark) {
    final tc = TextEditingController(text: '2000');
    Get.dialog(StatefulBuilder(builder: (ctx, setS) {
      final extra = double.tryParse(tc.text) ?? 0;
      final savings = controller.calcExtraPaymentSavings(debt, extra);
      return Dialog(backgroundColor: Colors.transparent, child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
              color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              borderColor: NeoBrutalismTheme.primaryBlack),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('EXTRA PAYMENT CALCULATOR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(height: 8),
            Text('Pay extra each month on "${debt.name}"', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextField(controller: tc, keyboardType: TextInputType.number,
                onChanged: (_) => setS(() {}),
                decoration: InputDecoration(hintText: '0', prefixText: '\u{20B9} ', labelText: 'Extra/month',
                    border: OutlineInputBorder(borderSide: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)))),
            const SizedBox(height: 16),
            if (extra > 0) Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFD4E4D1), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Months saved', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('${savings['monthsSaved']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                        color: Color(0xFF00CC66))),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Interest saved', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(_cur(savings['interestSaved']), style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w900, color: Color(0xFF00CC66))),
                  ]),
                ])),
            const SizedBox(height: 16),
            NeoButton(text: 'CLOSE', onPressed: () => Navigator.of(Get.context!).pop(), color: NeoBrutalismTheme.primaryWhite),
          ])));
    }));
  }
}