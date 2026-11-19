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
                  constraints: const BoxConstraints(maxWidth: 680),
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
                        AppCard(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  _StatBox(
                                    label: s.viewsTotalLabel,
                                    value: '${st.totalViews}',
                                    color: AppColors.primaryText(isDark),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  _StatBox(
                                    label: s.viewsUniqueLabel,
                                    value: '${st.uniqueVisitors}',
                                    color: AppColors.emeraldText(isDark),
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  _StatBox(
                                    label: s.viewsTodayLabel,
                                    value: '${st.todayViews}',
                                    color: AppColors.primaryText(isDark),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  _StatBox(
                                    label: s.viewsWeekLabel,
                                    value: '${st.weekViews}',
                                    color: AppColors.primaryText(isDark),
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              _StatBox(
                                label: s.viewsUpcomingOpensLabel,
                                value: '${st.upcomingOpens}',
                                color: AppColors.amber,
                                isDark: isDark,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _StatBox(
                                label: s.viewsUpcomingVotesLabel,
                                value: '${st.upcomingVotes}',
                                color: AppColors.emeraldText(isDark),
                                isDark: isDark,
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headline.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
