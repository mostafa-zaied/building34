import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/busy_overlay.dart';

class AdminViewsScreen extends StatefulWidget {
  const AdminViewsScreen({super.key});

  @override
  State<AdminViewsScreen> createState() => _AdminViewsScreenState();
}

class _AdminViewsScreenState extends State<AdminViewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BuildingCubit>().refreshPageViewStats(showBusy: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final st = state.pageViewStats;

        if (!state.isAdminAuthenticated) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: AppBar(
              backgroundColor: AppColors.surface(isDark),
              elevation: 0,
              title: Text(s.adminViewsTitle),
            ),
            body: Center(
              child: Text(s.adminOnlyPageMsg, style: AppTypography.body),
            ),
          );
        }

        final avgOpens = (st != null && st.uniqueVisitors > 0)
            ? (st.totalViews / st.uniqueVisitors).toStringAsFixed(1)
            : '0.0';

        return BusyOverlay(
          busy: state.busy,
          isDark: isDark,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: AppBar(
              backgroundColor: AppColors.surface(isDark),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                s.adminViewsTitle,
                style: AppTypography.headline.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: s.refreshTooltip,
                  onPressed: () => cubit.refreshPageViewStats(),
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: AppColors.primaryText(isDark),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.border(isDark)),
              ),
            ),
            body: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    children: [
                      if (st == null)
                        AppCard(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
                          child: Text(
                            s.viewsStatsLoadingHint,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        )
                      else ...[
                        // 1. Hero Featured Card: Total Opens
                        Container(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                              colors: isDark
                                  ? const [Color(0xFF172554), Color(0xFF0F172A)]
                                  : const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: isDark ? 0.22 : 0.25,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.viewsTotalLabel,
                                      style: AppTypography.label.copyWith(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${st.totalViews}',
                                      style: AppTypography.headline.copyWith(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.05,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      s.viewsTotalSubtitle,
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.white.withValues(alpha: 0.72),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.insights_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // 2. Two-Column Metric Cards: Unique Visitors & Today's Visits
                        Row(
                          children: [
                            Expanded(
                              child: _RichStatCard(
                                icon: Icons.people_alt_rounded,
                                accentColor: AppColors.emerald,
                                valueColor: AppColors.emeraldText(isDark),
                                value: '${st.uniqueVisitors}',
                                label: s.viewsUniqueLabel,
                                subtitle: s.viewsUniqueSubtitle,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _RichStatCard(
                                icon: Icons.today_rounded,
                                accentColor: AppColors.amber,
                                valueColor: AppColors.amber,
                                value: '${st.todayViews}',
                                label: s.viewsTodayLabel,
                                subtitle: s.viewsTodaySubtitle,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // 3. Average Opens per Visitor Summary Card
                        AppCard(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  Icons.repeat_rounded,
                                  size: 20,
                                  color: AppColors.primaryText(isDark),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.viewsAvgPerVisitorLabel,
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.textPrimary(isDark),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.viewsHeroSubtitle,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  '${avgOpens}x',
                                  style: AppTypography.title.copyWith(
                                    color: AppColors.primaryText(isDark),
                                    fontWeight: FontWeight.w900,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RichStatCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final Color valueColor;
  final String value;
  final String label;
  final String subtitle;
  final bool isDark;

  const _RichStatCard({
    required this.icon,
    required this.accentColor,
    required this.valueColor,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.05,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(isDark),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
