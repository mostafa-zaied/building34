import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/expense_stat_card.dart';
import 'admin_edit_panel.dart';

class BillSummaryCard extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final MonthBill month;
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
    final isAptsHighlighted = state.highlightedKey == 'apts';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Compact Monthly Expense Categories Grid (Top)
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              ExpenseStatCard(
                label: s.waterLabel,
                value: s.currency(month.water.toInt()),
                color: AppColors.water,
                icon: Icons.water_drop_outlined,
                highlighted: state.highlightedKey == 'water',
                isEditable: state.isAdminOpen,
                controller: waterCtrl,
                onChanged: onFieldChanged,
              ),
              ExpenseStatCard(
                label: s.elecLabel,
                value: s.currency(month.elec.toInt()),
                color: AppColors.electricity,
                icon: Icons.bolt_outlined,
                highlighted: state.highlightedKey == 'elec',
                isEditable: state.isAdminOpen,
                controller: elecCtrl,
                onChanged: onFieldChanged,
              ),
              ExpenseStatCard(
                label: s.elevLabel,
                value: s.currency(month.elev.toInt()),
                color: AppColors.elevator,
                icon: Icons.elevator_outlined,
                highlighted: state.highlightedKey == 'elev',
                isEditable: state.isAdminOpen,
                controller: elevCtrl,
                onChanged: onFieldChanged,
              ),
              ExpenseStatCard(
                label: s.cleanLabel,
                value: s.currency(month.clean.toInt()),
                color: AppColors.cleaning,
                icon: Icons.cleaning_services_outlined,
                highlighted: state.highlightedKey == 'clean',
                isEditable: state.isAdminOpen,
                controller: cleanCtrl,
                onChanged: onFieldChanged,
              ),
            ];

            if (constraints.maxWidth < 500) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: cards[1]),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(child: cards[2]),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: cards[3]),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: cards[1]),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: cards[2]),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: cards[3]),
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.sm),
        _UtilityReceiptsBar(
          cubit: cubit,
          state: state,
          month: month,
        ),

        const SizedBox(height: AppSpacing.md),

        // 2. Luxury Hero Financial Summary Card (Below Services, without Emergency Strip)
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: isDark
                  ? const [Color(0xFF131C31), Color(0xFF1A1838)]
                  : const [Color(0xFFFFFFFF), Color(0xFFF2F4FF)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isAptsHighlighted
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.14)),
              width: isAptsHighlighted ? 1.6 : 1.0,
            ),
            boxShadow: isAptsHighlighted
                ? AppShadows.accentGlow(AppColors.primary, active: true, isDark: isDark)
                : AppShadows.heroCard(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      s.billTitle(month.monthNum),
                      style: AppTypography.headline.copyWith(
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.sharePerAptLabel,
                        style: AppTypography.label.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          s.currency(month.sharePerApt),
                          maxLines: 1,
                          softWrap: false,
                          style: AppTypography.heroAmount.copyWith(
                            color: isDark ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      s.totalExpensesLine(month.totalExpenses.toInt(), month.aptsCount),
                      style: AppTypography.label.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Admin Edit Panel (Animated)
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: state.isAdminOpen
              ? Container(
                  margin: const EdgeInsetsDirectional.only(top: AppSpacing.md),
                  padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.border(isDark)),
                    boxShadow: AppShadows.card(isDark),
                  ),
                  child: AdminEditPanel(
                    cubit: cubit,
                    state: state,
                    aptsCtrl: aptsCtrl,
                    onFieldChanged: onFieldChanged,
                    onOpenManageApts: onOpenManageApts,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _UtilityReceiptsBar extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final MonthBill month;

  const _UtilityReceiptsBar({
    required this.cubit,
    required this.state,
    required this.month,
  });

  Future<void> _pickAndUpload(BuildContext context, String utility) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await cubit.setUtilityReceipt(utility: utility, imageBytes: bytes);
  }

  Future<void> _viewReceipt(
    BuildContext context, {
    required String utilityKey,
    required String label,
    required String? url,
    required Uint8List? localBytes,
  }) async {
    final isDark = state.isDarkMode;
    final s = state.s;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        title: Text(
          s.utilityReceiptDialogTitle(label),
          style: AppTypography.headline.copyWith(fontSize: 15),
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: localBytes != null
                  ? Image.memory(localBytes, fit: BoxFit.contain)
                  : Image.network(url!, fit: BoxFit.contain),
            ),
          ),
        ),
        actions: [
          if (state.isAdminOpen) ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await cubit.setUtilityReceipt(utility: utilityKey, imageBytes: null);
              },
              child: Text(
                s.removeUtilityReceiptBtn,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _pickAndUpload(context, utilityKey);
              },
              child: Text(s.attachBillAfterPayBtn),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final hasWater = (month.waterReceiptUrl != null && month.waterReceiptUrl!.isNotEmpty) ||
        month.waterLocalBytes != null;
    final hasElec = (month.elecReceiptUrl != null && month.elecReceiptUrl!.isNotEmpty) ||
        month.elecLocalBytes != null;

    if (!hasWater && !hasElec && !state.isAdminOpen) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: _pill(
            context: context,
            isDark: isDark,
            icon: Icons.water_drop_outlined,
            color: AppColors.water,
            label: s.waterLabel,
            hasReceipt: hasWater,
            onTap: hasWater
                ? () => _viewReceipt(
                      context,
                      utilityKey: 'water',
                      label: s.waterLabel,
                      url: month.waterReceiptUrl,
                      localBytes: month.waterLocalBytes,
                    )
                : (state.isAdminOpen ? () => _pickAndUpload(context, 'water') : null),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _pill(
            context: context,
            isDark: isDark,
            icon: Icons.bolt_rounded,
            color: AppColors.electricity,
            label: s.elecLabel,
            hasReceipt: hasElec,
            onTap: hasElec
                ? () => _viewReceipt(
                      context,
                      utilityKey: 'elec',
                      label: s.elecLabel,
                      url: month.elecReceiptUrl,
                      localBytes: month.elecLocalBytes,
                    )
                : (state.isAdminOpen ? () => _pickAndUpload(context, 'elec') : null),
          ),
        ),
      ],
    );
  }

  Widget _pill({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color color,
    required String label,
    required bool hasReceipt,
    required VoidCallback? onTap,
  }) {
    final s = state.s;
    final badgeText = hasReceipt
        ? s.viewBillReceiptBtn
        : (state.isAdminOpen ? s.attachBillAfterPayBtn : s.utilityPendingBadge);
    final accent = hasReceipt ? AppColors.emeraldText(isDark) : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: hasReceipt
                  ? AppColors.emerald.withValues(alpha: 0.4)
                  : AppColors.border(isDark),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$label: $badgeText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: hasReceipt
                        ? AppColors.emeraldText(isDark)
                        : AppColors.textSecondary(isDark),
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
