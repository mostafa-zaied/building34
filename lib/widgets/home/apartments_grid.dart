import 'package:flutter/material.dart';

import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import 'apartment_card.dart';

class ApartmentsGrid extends StatelessWidget {
  final BuildingState state;
  final MonthBill month;
  final ValueChanged<int> onTapApartment;

  const ApartmentsGrid({
    super.key,
    required this.state,
    required this.month,
    required this.onTapApartment,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final cardBg = Theme.of(context).cardColor;
    final chipBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderCol = isDark ? Colors.white12 : Colors.black12;
    final paidCount = month.payments.length;

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
              Text(s.tapAptTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                ),
                child: Text(
                  s.paidCounter(paidCount, month.aptsCount),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF22C55E) : const Color(0xFF15803D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final aspect = constraints.maxWidth < 400 ? 1.25 : 1.45;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: month.aptsCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: aspect,
                ),
                itemBuilder: (context, idx) {
                  final aptNum = idx + 1;
                  final isPaid = month.payments.containsKey(aptNum);
                  return ApartmentCard(
                    aptNum: aptNum,
                    label: state.aptLabel(aptNum),
                    statusText: isPaid ? s.paidBadge : '⏳ ${s.currency(month.sharePerApt)}',
                    isPaid: isPaid,
                    onTap: () => onTapApartment(aptNum),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
