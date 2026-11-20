import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';
import '../widgets/common/app_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int? _selectedMonthId;

  String _shortMonthName(MonthBill m, String locale) {
    final dt = DateTime(m.yearNum, m.monthNum, 1);
    return DateFormat.MMM(locale).format(dt);
  }

  String _fullMonthName(MonthBill m, String locale) {
    final dt = DateTime(m.yearNum, m.monthNum, 1);
    return DateFormat.MMMM(locale).format(dt);
  }

  String _formatCompactAmount(double val) {
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    }
    return val.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final s = state.s;
        final isDark = state.isDarkMode;
        final locale = state.localeCode;

        // Sort months chronologically (oldest -> newest) and take up to last 6 months
        final sortedAll = [...state.months]
          ..sort((a, b) {
            final y = a.yearNum.compareTo(b.yearNum);
            return y != 0 ? y : a.monthNum.compareTo(b.monthNum);
          });
        final chartMonths = sortedAll.length > 6
            ? sortedAll.sublist(sortedAll.length - 6)
            : sortedAll;

        if (chartMonths.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
              child: Text(
                s.analyticsNoData,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
          );
        }

        // Determine currently selected month (defaults to latest month)
        final selectedMonth = chartMonths.firstWhere(
          (m) => m.id == _selectedMonthId,
          orElse: () => chartMonths.last,
        );
        final selectedIdx = chartMonths.indexOf(selectedMonth);
        final prevMonth = selectedIdx > 0 ? chartMonths[selectedIdx - 1] : null;

        // Real calculations across all available months
        final avgShare = (sortedAll.fold<int>(0, (sum, m) => sum + m.sharePerApt) /
                sortedAll.length)
            .round();
        final expected = selectedMonth.totalExpected;
        final collected = selectedMonth.totalCollected;
        final remaining = selectedMonth.totalRemaining;
        final collectionRate =
            expected > 0 ? ((collected / expected) * 100).round().clamp(0, 100) : 0;
        final emergencyBalance = state.baseEmergency.round();

        // Month-over-month real comparison
        final selectedTotal = selectedMonth.totalExpenses;
        final selectedMonthFull = _fullMonthName(selectedMonth, locale);
        String insightText;
        IconData insightIcon;
        Color insightColor;
        if (prevMonth != null && prevMonth.totalExpenses > 0) {
          final diff = selectedTotal - prevMonth.totalExpenses;
          final pct = ((diff.abs() / prevMonth.totalExpenses) * 100).toStringAsFixed(1);
          if (diff < -0.5) {
            insightText = s.analyticsInsightLower(
              selectedMonthFull,
              pct,
              diff.abs().round().toString(),
            );
            insightIcon = Icons.trending_down_rounded;
            insightColor = AppColors.emerald;
          } else if (diff > 0.5) {
            insightText = s.analyticsInsightHigher(
              selectedMonthFull,
              pct,
              diff.round().toString(),
            );
            insightIcon = Icons.trending_up_rounded;
            insightColor = AppColors.amber;
          } else {
            insightText = s.analyticsInsightSame(selectedMonthFull);
            insightIcon = Icons.horizontal_rule_rounded;
            insightColor = AppColors.primary;
          }
        } else {
          final paidCount = selectedMonth.payments.keys
              .where((k) => k >= 1 && k <= selectedMonth.aptsCount)
              .length;
          insightText = s.analyticsInsightSingle(
            selectedMonthFull,
            selectedMonth.sharePerApt.toString(),
            paidCount,
            selectedMonth.aptsCount,
          );
          insightIcon = Icons.insights_rounded;
          insightColor = AppColors.primary;
        }

        final maxChartTotal = chartMonths
            .map((m) => m.totalExpenses)
            .fold<double>(0, (a, b) => a > b ? a : b);

        const customColors = [
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
          Color(0xFF14B8A6),
          Color(0xFFF97316),
        ];

        final utilities = [
          (
            icon: Icons.water_drop_rounded,
            label: s.waterLabel,
            amount: selectedMonth.water,
            color: const Color(0xFF06B6D4),
          ),
          (
            icon: Icons.bolt_rounded,
            label: s.elecLabel,
            amount: selectedMonth.elec,
            color: AppColors.amber,
          ),
          (
            icon: Icons.elevator_rounded,
            label: s.elevLabel,
            amount: selectedMonth.elev,
            color: AppColors.primary,
          ),
          (
            icon: Icons.cleaning_services_rounded,
            label: s.cleanLabel,
            amount: selectedMonth.clean,
            color: AppColors.emerald,
          ),
          for (int i = 0; i < selectedMonth.customExpenses.length; i++)
            (
              icon: Icons.receipt_long_rounded,
              label: selectedMonth.customExpenses[i].name,
              amount: selectedMonth.customExpenses[i].amount,
              color: customColors[i % customColors.length],
            ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideNav = constraints.maxWidth >= 720;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    isWideNav ? AppSpacing.xxl : 104,
                  ),
                  children: [
                    // Screen Header
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.bar_chart_rounded,
                              size: 20,
                              color: AppColors.primaryText(isDark),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            s.analyticsTitle,
                            style: AppTypography.headline.copyWith(
                              fontSize: 17,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 1. Top KPI Strip
                    Row(
                      children: [
                        Expanded(
                          child: _KpiTile(
                            value: s.currency(avgShare),
                            label: s.analyticsAvgShare,
                            color: AppColors.primaryText(isDark),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _KpiTile(
                            value: '$collectionRate%',
                            label: s.analyticsCollectionRate,
                            color: AppColors.emeraldText(isDark),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _KpiTile(
                            value: s.currency(emergencyBalance),
                            label: s.analyticsEmergencyBalance,
                            color: AppColors.amber,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 2. Smart Month-over-Month Insight Banner
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: insightColor.withValues(alpha: isDark ? 0.14 : 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: insightColor.withValues(alpha: isDark ? 0.30 : 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(insightIcon, size: 19, color: insightColor),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              insightText,
                              style: AppTypography.caption.copyWith(
                                color: isDark ? Colors.white : AppColors.textPrimary(false),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 3. Interactive Monthly Bar Chart
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.analyticsChartTitle,
                                      style: AppTypography.title.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary(isDark),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.analyticsChartHint,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  selectedMonthFull,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primaryText(isDark),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            height: 168,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: chartMonths.map((m) {
                                final isSelected = m.id == selectedMonth.id;
                                final ratio = maxChartTotal > 0
                                    ? (m.totalExpenses / maxChartTotal).clamp(0.08, 1.0)
                                    : 0.1;
                                return Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => setState(() => _selectedMonthId = m.id),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatCompactAmount(m.totalExpenses),
                                            style: AppTypography.caption.copyWith(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected
                                                  ? AppColors.primaryText(isDark)
                                                  : AppColors.textSecondary(isDark),
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  color: AppColors.surface(isDark),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.bottomCenter,
                                                child: FractionallySizedBox(
                                                  heightFactor: ratio,
                                                  widthFactor: 1,
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 280,
                                                    ),
                                                    curve: Curves.easeOutCubic,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                      gradient: isSelected
                                                          ? const LinearGradient(
                                                              begin: Alignment.topCenter,
                                                              end: Alignment.bottomCenter,
                                                              colors: [
                                                                AppColors.primary,
                                                                AppColors.emerald,
                                                              ],
                                                            )
                                                          : null,
                                                      color: isSelected
                                                          ? null
                                                          : AppColors.primary
                                                              .withValues(alpha: 0.30),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _shortMonthName(m, locale),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption.copyWith(
                                              fontSize: 11,
                                              fontWeight: isSelected
                                                  ? FontWeight.w900
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.textPrimary(isDark)
                                                  : AppColors.textSecondary(isDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 4. Real Utility Breakdown Card
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.analyticsBreakdownTitle(selectedMonthFull),
                                  style: AppTypography.title.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                              ),
                              Text(
                                s.currency(selectedTotal.round()),
                                style: AppTypography.title.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryText(isDark),
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          for (final u in utilities) ...[
                            _UtilityProgressRow(
                              icon: u.icon,
                              label: u.label,
                              amountLabel: s.currency(u.amount.round()),
                              fraction: selectedTotal > 0
                                  ? (u.amount / selectedTotal).clamp(0.0, 1.0)
                                  : 0.0,
                              color: u.color,
                              isDark: isDark,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 5. Real Monthly Collection Progress Card
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.analyticsCollectionCardTitle(selectedMonthFull),
                                style: AppTypography.title.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              Text(
                                '$collectionRate%',
                                style: AppTypography.title.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.emeraldText(isDark),
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: collectionRate / 100.0,
                              minHeight: 10,
                              backgroundColor: AppColors.surface(isDark),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.emerald,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${s.analyticsCollectedLabel}: ${s.currency(collected)}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${s.analyticsRemainingLabel}: ${s.currency(remaining)}',
                                style: AppTypography.caption.copyWith(
                                  color: remaining > 0
                                      ? AppColors.amber
                                      : AppColors.textSecondary(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _KpiTile({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.title.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilityProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amountLabel;
  final double fraction;
  final Color color;
  final bool isDark;

  const _UtilityProgressRow({
    required this.icon,
    required this.label,
    required this.amountLabel,
    required this.fraction,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (fraction * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($pct%)',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              amountLabel,
              style: AppTypography.label.copyWith(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: fraction),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (_, val, _) => LinearProgressIndicator(
              value: val,
              minHeight: 8,
              backgroundColor: AppColors.surface(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
