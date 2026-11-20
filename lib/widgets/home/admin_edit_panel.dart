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
  final TextEditingController aptsCtrl;
  final TextEditingController dueDayCtrl;
  final VoidCallback onFieldChanged;
  final VoidCallback onOpenManageApts;

  const AdminEditPanel({
    super.key,
    required this.cubit,
    required this.state,
    required this.aptsCtrl,
    required this.dueDayCtrl,
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
        Row(
          children: [
            Expanded(
              child: AdminInputField(
                label: s.aptsCountField,
                controller: aptsCtrl,
                color: AppColors.primary,
                icon: Icons.home_work_outlined,
                onFocusKey: 'apts',
                onHighlight: cubit.setHighlight,
                onChanged: onFieldChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AdminInputField(
                label: s.dueDayField,
                controller: dueDayCtrl,
                color: AppColors.amber,
                icon: Icons.event_available_rounded,
                onFocusKey: 'dueDay',
                onHighlight: cubit.setHighlight,
                onChanged: onFieldChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppPrimaryButton(
          label: s.saveChangesBtn,
          icon: Icons.check_circle_outline_rounded,
          backgroundColor: AppColors.primaryActionBg(isDark),
          foregroundColor: AppColors.onPrimaryAction(isDark),
          loading: state.busy,
          onPressed: state.busy ? null : cubit.saveAdminChanges,
        ),
      ],
    );
  }
}

class AdminActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback? onTap;

  const AdminActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final iconColor = disabled
        ? AppColors.textSecondary(isDark).withValues(alpha: 0.45)
        : (isDestructive
            ? AppColors.dangerText(isDark)
            : AppColors.primaryText(isDark));
    final textColor = disabled
        ? AppColors.textSecondary(isDark).withValues(alpha: 0.45)
        : (isDestructive
            ? AppColors.dangerText(isDark)
            : AppColors.textPrimary(isDark));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border(isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
