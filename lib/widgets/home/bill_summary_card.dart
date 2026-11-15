import 'package:flutter/material.dart';

import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/expense_stat_card.dart';
import '../common/glow_box.dart';
import 'admin_edit_panel.dart';

class BillSummaryCard extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final MonthBill month;
  final VoidCallback onCopyWhatsApp;
  final TextEditingController waterCtrl;
  final TextEditingController elecCtrl;
  final TextEditingController elevCtrl;
  final TextEditingController cleanCtrl;
  final TextEditingController forEmergCtrl;
  final TextEditingController aptsCtrl;
  final TextEditingController baseEmergCtrl;
  final VoidCallback onFieldChanged;
  final VoidCallback onOpenManageApts;

  const BillSummaryCard({
    super.key,
    required this.cubit,
    required this.state,
    required this.month,
    required this.onCopyWhatsApp,
    required this.waterCtrl,
    required this.elecCtrl,
    required this.elevCtrl,
    required this.cleanCtrl,
    required this.forEmergCtrl,
    required this.aptsCtrl,
    required this.baseEmergCtrl,
    required this.onFieldChanged,
    required this.onOpenManageApts,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final cardBg = Theme.of(context).cardColor;
    final borderCol = isDark ? Colors.white12 : Colors.black12;
    final newEmergTotal = (state.baseEmergency + month.forEmerg).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(s.billTitle(month.monthNum), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: onCopyWhatsApp,
                icon: const Icon(Icons.copy, size: 14),
                label: Text(s.copyWhatsAppBtn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                ExpenseStatCard(label: s.waterLabel, value: '${month.water.toInt()}', color: const Color(0xFF38BDF8), highlighted: state.highlightedKey == 'water'),
                ExpenseStatCard(label: s.elecLabel, value: '${month.elec.toInt()}', color: const Color(0xFFFACC15), highlighted: state.highlightedKey == 'elec'),
                ExpenseStatCard(label: s.elevLabel, value: '${month.elev.toInt()}', color: const Color(0xFFA855F7), highlighted: state.highlightedKey == 'elev'),
                ExpenseStatCard(label: s.cleanLabel, value: '${month.clean.toInt()}', color: const Color(0xFFF472B6), highlighted: state.highlightedKey == 'clean'),
                ExpenseStatCard(label: s.forEmergLabel, value: '${month.forEmerg.toInt()}', color: const Color(0xFF22C55E), highlighted: state.highlightedKey == 'emerg'),
              ];

              if (constraints.maxWidth < 460) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 6),
                        Expanded(child: cards[1]),
                        const SizedBox(width: 6),
                        Expanded(child: cards[2]),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: cards[3]),
                        const SizedBox(width: 6),
                        Expanded(child: cards[4]),
                        const SizedBox(width: 6),
                        const Spacer(),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 6),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 6),
                  Expanded(child: cards[2]),
                  const SizedBox(width: 6),
                  Expanded(child: cards[3]),
                  const SizedBox(width: 6),
                  Expanded(child: cards[4]),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          GlowBox(
            glowColor: const Color(0xFF6366F1),
            isHighlighted: state.highlightedKey == 'apts',
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.totalExpensesLine(month.totalExpenses.toInt(), month.aptsCount),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.emergencySummaryLine(newEmergTotal, state.baseEmergency.toInt(), month.forEmerg.toInt()),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF22C55E) : const Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(s.sharePerAptLabel, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
                    Text(
                      s.currency(month.sharePerApt),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.copiedPreview != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF22C55E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.copiedTitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF22C55E) : const Color(0xFF15803D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => cubit.setCopiedPreview(null),
                        child: Icon(Icons.close, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(state.copiedPreview!, style: const TextStyle(fontSize: 11, height: 1.5)),
                ],
              ),
            ),
          ],
          if (state.isAdminOpen)
            AdminEditPanel(
              cubit: cubit,
              state: state,
              waterCtrl: waterCtrl,
              elecCtrl: elecCtrl,
              elevCtrl: elevCtrl,
              cleanCtrl: cleanCtrl,
              forEmergCtrl: forEmergCtrl,
              aptsCtrl: aptsCtrl,
              baseEmergCtrl: baseEmergCtrl,
              onFieldChanged: onFieldChanged,
              onOpenManageApts: onOpenManageApts,
            ),
        ],
      ),
    );
  }
}
