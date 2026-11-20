import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController dueDayCtrl;
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
    required this.dueDayCtrl,
    required this.baseEmergCtrl,
    required this.onFieldChanged,
    required this.onOpenManageApts,
  });

  static const List<Color> _customAccentColors = [
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  Future<void> _showAddCustomExpenseDialog(BuildContext context) async {
    final s = state.s;
    final isDark = state.isDarkMode;
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    final result = await showDialog<({String name, double amount})>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primaryText(isDark),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                s.addCustomExpenseTitle,
                style: AppTypography.headline.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: s.customExpenseNameLabel,
                hintText: s.customExpenseNameHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                labelText: s.customExpenseAmountLabel,
                hintText: '0',
              ),
              onSubmitted: (_) {
                final cleanName = nameCtrl.text.trim();
                if (cleanName.isNotEmpty) {
                  Navigator.pop(ctx, (
                    name: cleanName,
                    amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
                  ));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              final cleanName = nameCtrl.text.trim();
              if (cleanName.isEmpty) return;
              Navigator.pop(ctx, (
                name: cleanName,
                amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
              ));
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(s.addBtn),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      nameCtrl.dispose();
      amountCtrl.dispose();
    });

    if (result != null) {
      await cubit.addCustomExpense(name: result.name, amount: result.amount);
    }
  }

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
            final cards = <Widget>[
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
              for (int i = 0; i < month.customExpenses.length; i++)
                ExpenseStatCard(
                  key: ValueKey('custom_${month.id}_${month.customExpenses[i].id}'),
                  label: month.customExpenses[i].name,
                  value: s.currency(month.customExpenses[i].amount.toInt()),
                  color: _customAccentColors[i % _customAccentColors.length],
                  icon: Icons.receipt_long_outlined,
                  highlighted: false,
                  isEditable: state.isAdminOpen,
                  initialEditText: month.customExpenses[i].amount.toInt().toString(),
                  onTextChanged: (val) => cubit.updateCustomExpenseAmount(
                    month.customExpenses[i].id,
                    double.tryParse(val.trim()) ?? 0,
                  ),
                  onDelete: () => cubit.removeCustomExpense(month.customExpenses[i].id),
                ),
            ];

            final perRow = constraints.maxWidth < 500 ? 2 : 4;
            final rows = <Widget>[];
            for (int start = 0; start < cards.length; start += perRow) {
              final end = (start + perRow) > cards.length ? cards.length : (start + perRow);
              final slice = cards.sublist(start, end);
              if (rows.isNotEmpty) {
                rows.add(const SizedBox(height: AppSpacing.xs));
              }
              rows.add(
                Row(
                  children: [
                    for (int j = 0; j < slice.length; j++) ...[
                      if (j > 0) const SizedBox(width: AppSpacing.xs),
                      Expanded(child: slice[j]),
                    ],
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...rows,
                if (state.isAdminOpen) ...[
                  const SizedBox(height: AppSpacing.xs),
                  InkWell(
                    onTap: () => _showAddCustomExpenseDialog(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.06),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 16,
                            color: AppColors.primaryText(isDark),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.addCustomExpenseBtn,
                            style: AppTypography.label.copyWith(
                              color: AppColors.primaryText(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    dueDayCtrl: dueDayCtrl,
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
