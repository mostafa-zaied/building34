import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import 'feedback_screen.dart';
import 'home_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuildingCubit, BuildingState>(
      listenWhen: (prev, curr) => prev.feedbackMessage != curr.feedbackMessage && curr.feedbackMessage != null,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: state.feedbackIsError ? AppColors.danger : AppColors.emerald,
            ),
          );
          context.read<BuildingCubit>().clearFeedback();
        }
      },
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;

        const screens = [
          BuildingHomePage(),
          FeedbackScreen(type: 'complaint'),
          FeedbackScreen(type: 'improvement'),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final isExtended = constraints.maxWidth >= 1024;

            if (isWide) {
              return Scaffold(
                body: SafeArea(
                  child: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: state.selectedNavIndex,
                        onDestinationSelected: cubit.selectNav,
                        extended: isExtended,
                        minExtendedWidth: 215,
                        backgroundColor: AppColors.card(isDark),
                        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
                        selectedIconTheme: IconThemeData(color: AppColors.primaryText(isDark)),
                        selectedLabelTextStyle: AppTypography.label.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelTextStyle: AppTypography.label.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                        leading: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: AppSpacing.lg,
                            horizontal: AppSpacing.md,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.emerald],
                                    begin: AlignmentDirectional.topStart,
                                    end: AlignmentDirectional.bottomEnd,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(Icons.apartment_rounded, size: 20, color: Colors.white),
                              ),
                              if (isExtended) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  s.appTitle,
                                  style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ],
                          ),
                        ),
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.receipt_long_outlined),
                            selectedIcon: const Icon(Icons.receipt_long_rounded),
                            label: Text(s.navExpenses),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.campaign_outlined),
                            selectedIcon: const Icon(Icons.campaign_rounded),
                            label: Text(s.navComplaints),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.lightbulb_outline),
                            selectedIcon: const Icon(Icons.lightbulb_rounded),
                            label: Text(s.navImprovements),
                          ),
                        ],
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.border(isDark),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: state.selectedNavIndex,
                          children: screens,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              body: SafeArea(
                child: IndexedStack(
                  index: state.selectedNavIndex,
                  children: screens,
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border(isDark))),
                ),
                child: NavigationBar(
                  selectedIndex: state.selectedNavIndex,
                  onDestinationSelected: cubit.selectNav,
                  backgroundColor: AppColors.card(isDark),
                  indicatorColor: AppColors.primary.withValues(alpha: 0.16),
                  height: 68,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primaryText(isDark)),
                      label: s.navExpenses,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.campaign_outlined),
                      selectedIcon: Icon(Icons.campaign_rounded, color: AppColors.primaryText(isDark)),
                      label: s.navComplaints,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.lightbulb_outline),
                      selectedIcon: Icon(Icons.lightbulb_rounded, color: AppColors.primaryText(isDark)),
                      label: s.navImprovements,
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
