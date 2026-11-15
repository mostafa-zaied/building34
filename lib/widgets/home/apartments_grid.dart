import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_card.dart';
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
    final progress = month.aptsCount > 0 ? (paidCount / month.aptsCount).clamp(0.0, 1.0) : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Text(s.tapAptTitle, style: AppTypography.title),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
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
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (_, val, _) => LinearProgressIndicator(
                value: val,
                minHeight: 5,
                backgroundColor: AppColors.surface(isDark),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final aspect = constraints.maxWidth < 400 ? 1.25 : 1.45;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: month.aptsCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
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
