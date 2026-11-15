import 'package:flutter/material.dart';

import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/glow_box.dart';

class TopBar extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final MonthBill month;
  final VoidCallback onToggleAdmin;

  const TopBar({
    super.key,
    required this.cubit,
    required this.state,
    required this.month,
    required this.onToggleAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final cardBg = Theme.of(context).cardColor;
    final chipBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderCol = isDark ? Colors.white12 : Colors.black12;
    final newEmergTotal = (state.baseEmergency + month.forEmerg).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏢', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: state.selectedMonthIndex,
                  dropdownColor: cardBg,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  items: List.generate(state.months.length, (i) {
                    final item = state.months[i];
                    return DropdownMenuItem(
                      value: i,
                      child: Text(s.monthOption(item.monthNum, item.yearNum)),
                    );
                  }),
                  onChanged: (idx) {
                    if (idx != null) cubit.selectMonth(idx);
                  },
                ),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              GlowBox(
                glowColor: const Color(0xFF22C55E),
                isHighlighted: state.highlightedKey == 'top-emerg' || state.highlightedKey == 'emerg',
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  s.emergencyBadge(newEmergTotal),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF22C55E) : const Color(0xFF15803D),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Language',
                onSelected: cubit.setLocale,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'ar', child: Text('🇪🇬 العربية (AR)')),
                  PopupMenuItem(value: 'en', child: Text('🇺🇸 English (EN)')),
                  PopupMenuItem(value: 'de', child: Text('🇩🇪 Deutsch (DE)')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: Text(
                    state.localeCode.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              InkWell(
                onTap: cubit.toggleTheme,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFFFACC15) : const Color(0xFF4F46E5),
                  ),
                ),
              ),
              InkWell(
                onTap: onToggleAdmin,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: Text(
                    state.isAdminOpen ? s.closeBtn : s.editBtn,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
