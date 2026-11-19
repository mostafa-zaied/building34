import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/common/app_side_menu.dart';
import '../widgets/common/busy_overlay.dart';
import 'contacts_screen.dart';
import 'emergency_screen.dart';
import 'feedback_screen.dart';
import 'home_screen.dart';
import 'upcoming_directory_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuildingCubit, BuildingState>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage && curr.feedbackMessage != null,
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
          EmergencyScreen(),
          ContactsScreen(),
          FeedbackScreen(),
          UpcomingDirectoryScreen(),
        ];

        final bgDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF0A1124), AppColors.darkBg]
                : const [Color(0xFFEEF2FF), AppColors.lightBg],
            stops: const [0.0, 0.35],
          ),
        );

        final overlayStyle = isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: AppColors.darkBg,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: AppColors.lightBg,
                systemNavigationBarIconBrightness: Brightness.dark,
              );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: BusyOverlay(
            busy: state.busy,
            isDark: isDark,
            child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final isExtended = constraints.maxWidth >= 1024;

              if (isWide) {
                return Scaffold(
                  backgroundColor: isDark ? const Color(0xFF0A1124) : const Color(0xFFEEF2FF),
                  body: Container(
                    decoration: bgDecoration,
                    child: SafeArea(
                      child: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: state.selectedNavIndex,
                        onDestinationSelected: cubit.selectNav,
                        extended: isExtended,
                        minExtendedWidth: 215,
                        backgroundColor: AppColors.surface(isDark),
                        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
                        selectedIconTheme: IconThemeData(color: AppColors.primaryText(isDark)),
                        unselectedIconTheme: IconThemeData(color: AppColors.textSecondary(isDark)),
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
                                    colors: [AppColors.primary, AppColors.primaryLight],
                                    begin: AlignmentDirectional.topStart,
                                    end: AlignmentDirectional.bottomEnd,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(
                                  Icons.apartment_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
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
                            icon: const Icon(Icons.account_balance_wallet_outlined),
                            selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
                            label: Text(s.navExpenses),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.shield_outlined),
                            selectedIcon: const Icon(Icons.shield_rounded),
                            label: Text(s.navEmergency),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.contact_phone_outlined),
                            selectedIcon: const Icon(Icons.contact_phone_rounded),
                            label: Text(s.navContactsFull),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.forum_outlined),
                            selectedIcon: const Icon(Icons.forum_rounded),
                            label: Text(s.navFeedbackFull),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.explore_outlined),
                            selectedIcon: const Icon(Icons.explore_rounded),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s.navServicesFull),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.amber,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: Text(
                                    s.soonBadge,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
              ),
              );
            }

            final mobileBottomNavIndex = switch (state.selectedNavIndex) {
              0 => 0,
              1 => 1,
              3 => 2,
              _ => -1,
            };

            return Scaffold(
              extendBody: true,
              backgroundColor: isDark ? const Color(0xFF0A1124) : const Color(0xFFEEF2FF),
              drawer: AppSideMenu(cubit: cubit, state: state),
              appBar: AppBar(
                backgroundColor: isDark
                    ? const Color(0xFF0A1124)
                    : const Color(0xFFEEF2FF),
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 50,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: AppColors.textPrimary(isDark),
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.appTitle,
                      style: AppTypography.headline.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
              ),
              body: Container(
                decoration: bgDecoration,
                child: IndexedStack(
                  index: state.selectedNavIndex,
                  children: screens,
                ),
              ),
              bottomNavigationBar: _FloatingBottomNav(
                selectedIndex: mobileBottomNavIndex,
                onSelect: (idx) {
                  if (idx == 0) cubit.selectNav(0);
                  if (idx == 1) cubit.selectNav(1);
                  if (idx == 2) cubit.selectNav(3);
                },
                isDark: isDark,
                items: [
                  _NavItemData(
                    icon: Icons.account_balance_wallet_outlined,
                    selectedIcon: Icons.account_balance_wallet_rounded,
                    label: s.navExpenses,
                  ),
                  _NavItemData(
                    icon: Icons.shield_outlined,
                    selectedIcon: Icons.shield_rounded,
                    label: s.navEmergency,
                  ),
                  _NavItemData(
                    icon: Icons.forum_outlined,
                    selectedIcon: Icons.forum_rounded,
                    label: s.navFeedback,
                  ),
                ],
              ),
            );
            },
          ),
          ),
        );
      },
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });
}

class _FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isDark;
  final List<_NavItemData> items;

  const _FloatingBottomNav({
    required this.selectedIndex,
    required this.onSelect,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Container(
          height: 66,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCardElevated.withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.lightBorder,
            ),
            boxShadow: AppShadows.floatingNav(isDark),
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.14),
                                AppColors.primaryLight.withValues(alpha: isDark ? 0.16 : 0.08),
                              ],
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: selected
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.32),
                            )
                          : null,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                selected ? item.selectedIcon : item.icon,
                                size: 20,
                                color: selected
                                    ? AppColors.primaryText(isDark)
                                    : AppColors.textSecondary(isDark),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                  color: selected
                                      ? AppColors.primaryText(isDark)
                                      : AppColors.textSecondary(isDark),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (item.badge != null)
                          PositionedDirectional(
                            top: 2,
                            end: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.amber,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                item.badge!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
