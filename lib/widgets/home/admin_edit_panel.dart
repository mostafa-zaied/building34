import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../common/app_button.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: AppSpacing.xxl, color: AppColors.border(isDark)),
        Text(
          s.adminSectionHint,
          style: AppTypography.label.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 3.1,
          children: [
            AdminInputField(
              label: '${s.waterLabel}:',
              controller: waterCtrl,
              color: AppColors.water,
              onFocusKey: 'water',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.elecLabel}:',
              controller: elecCtrl,
              color: AppColors.electricity,
              onFocusKey: 'elec',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.elevLabel}:',
              controller: elevCtrl,
              color: AppColors.elevator,
              onFocusKey: 'elev',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.cleanLabel}:',
              controller: cleanCtrl,
              color: AppColors.cleaning,
              onFocusKey: 'clean',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: '${s.forEmergLabel}:',
              controller: forEmergCtrl,
              color: AppColors.reserve,
              onFocusKey: 'emerg',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
            AdminInputField(
              label: s.aptsCountField,
              controller: aptsCtrl,
              color: AppColors.primary,
              onFocusKey: 'apts',
              onHighlight: cubit.setHighlight,
              onChanged: onFieldChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AdminInputField(
          label: s.baseEmergField,
          controller: baseEmergCtrl,
          color: AppColors.reserve,
          onFocusKey: 'top-emerg',
          onHighlight: cubit.setHighlight,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppPrimaryButton(
                label: s.saveChangesBtn,
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.black,
                onPressed: cubit.saveAdminChanges,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppSecondaryButton(
                label: s.manageAptsBtn,
                icon: Icons.vpn_key_outlined,
                onPressed: onOpenManageApts,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
