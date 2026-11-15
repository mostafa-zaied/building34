import 'package:flutter/material.dart';

import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import 'admin_input_field.dart';

class AdminEditPanel extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final TextEditingController waterCtrl;
  final TextEditingController elecCtrl;
  final TextEditingController elevCtrl;
  final TextEditingController cleanCtrl;
  final TextEditingController forEmergCtrl;
  final TextEditingController aptsCtrl;
  final TextEditingController baseEmergCtrl;
  final VoidCallback onFieldChanged;
  final VoidCallback onOpenManageApts;

  const AdminEditPanel({
    super.key,
    required this.cubit,
    required this.state,
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
    final borderCol = isDark ? Colors.white12 : Colors.black12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 24, color: borderCol),
        Text(
          s.adminSectionHint,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.1,
          children: [
            AdminInputField(
              label: '${s.waterLabel}:',
              controller: waterCtrl,
              color: const Color(0xFF38BDF8),
              onFocusKey: 'water',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.elecLabel}:',
              controller: elecCtrl,
              color: const Color(0xFFFACC15),
              onFocusKey: 'elec',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.elevLabel}:',
              controller: elevCtrl,
              color: const Color(0xFFA855F7),
              onFocusKey: 'elev',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.cleanLabel}:',
              controller: cleanCtrl,
              color: const Color(0xFFF472B6),
              onFocusKey: 'clean',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.forEmergLabel}:',
              controller: forEmergCtrl,
              color: const Color(0xFF22C55E),
              onFocusKey: 'emerg',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: s.aptsCountField,
              controller: aptsCtrl,
              color: const Color(0xFF6366F1),
              onFocusKey: 'apts',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        AdminInputField(
          label: s.baseEmergField,
          controller: baseEmergCtrl,
          color: const Color(0xFF22C55E),
          onFocusKey: 'top-emerg',
          onHighlight: cubit.setHighlight,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: cubit.saveAdminChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(s.saveChangesBtn, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenManageApts,
                icon: const Icon(Icons.vpn_key_outlined, size: 16),
                label: Text(s.manageAptsBtn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
