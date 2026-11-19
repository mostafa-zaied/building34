import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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
    final paidCount = month.payments.length;
    final progress = month.aptsCount > 0
        ? (paidCount / month.aptsCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border(isDark)),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title + Paid progress counter pill + percentage
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: AppColors.primaryText(isDark),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    s.tapAptTitle,
                    style: AppTypography.headline.copyWith(
                      fontSize: 15,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  s.paidCounter(paidCount, month.aptsCount),
                  style: AppTypography.label.copyWith(
                    color: AppColors.emeraldText(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Sleek animated gradient progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (_, val, _) => Container(
                height: 7,
                width: double.infinity,
                color: AppColors.surface(isDark),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: val,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.emerald, AppColors.emeraldLight],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Responsive Apartment Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final crossAxisCount = w < 640 ? 2 : 4;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: month.aptsCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisExtent: 74,
                ),
                itemBuilder: (context, idx) {
                  final aptNum = idx + 1;
                  final payment = month.payments[aptNum];
                  final isPaid = payment != null;

                  final extraTotal = month.extraTotalFor(aptNum);
                  IconData? lockIcon;
                  Color? lockIconColor;
                  if (state.requireAptPassOnOpen && !state.isAdminOpen) {
                    final unlockedHere = state.myAptNum == aptNum &&
                        state.savedAptPass != null &&
                        state.savedAptPass!.isNotEmpty;
                    final hasPass = state.apartmentHasPasscode[aptNum] ?? false;
                    if (unlockedHere && hasPass) {
                      lockIcon = Icons.lock_open_rounded;
                      lockIconColor = AppColors.emeraldText(isDark);
                    } else if (hasPass) {
                      lockIcon = Icons.lock_outline_rounded;
                      lockIconColor = AppColors.textSecondary(isDark);
                    } else {
                      lockIcon = Icons.vpn_key_outlined;
                      lockIconColor = AppColors.amber;
                    }
                  }
                  return ApartmentCard(
                    aptNum: aptNum,
                    label: state.aptLabel(aptNum),
                    amountText: s.currency(month.dueFor(aptNum)),
                    paidLabel: s.paidBadge,
                    pendingLabel: s.pendingPaymentBadge,
                    isPaid: isPaid,
                    hasReceipt: payment?.receiptUrl != null,
                    extraBadgeText: extraTotal > 0 ? s.extraBadge(extraTotal) : null,
                    lockIcon: lockIcon,
                    lockIconColor: lockIconColor,
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
