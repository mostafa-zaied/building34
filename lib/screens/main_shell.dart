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
import '../widgets/common/desktop_sidebar.dart';
import '../widgets/common/network_banner.dart';
import 'analytics_screen.dart';
import 'contacts_screen.dart';
import 'emergency_screen.dart';
import 'feedback_screen.dart';
import 'home_screen.dart';
import 'upcoming_directory_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  late final AnimationController _drawerCtrl;
  late final Animation<double> _drawerAnim;

  @override
  void initState() {
    super.initState();
    _drawerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _drawerAnim = CurvedAnimation(
      parent: _drawerCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _drawerCtrl.dispose();
    super.dispose();
  }

  bool get _isDrawerOpen =>
      _drawerCtrl.status == AnimationStatus.completed ||
      _drawerCtrl.status == AnimationStatus.forward;

  void _openDrawer() => _drawerCtrl.forward();
  void _closeDrawer() => _drawerCtrl.reverse();
  void _toggleDrawer() => _isDrawerOpen ? _closeDrawer() : _openDrawer();

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
          child: NetworkStatusWrapper(
            s: s,
            onReconnect: () => cubit.loadData(
              preserveMonthIndex: state.months.isNotEmpty ? state.selectedMonthIndex : null,
            ),
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
                          DesktopSidebar(
                            cubit: cubit,
                            state: state,
                            extended: isExtended,
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

            final isRtl = Directionality.of(context) == TextDirection.rtl;
            final menuWidth = (constraints.maxWidth * 0.72).clamp(250.0, 305.0);
            final slideDistance = (constraints.maxWidth * 0.66).clamp(235.0, 290.0);

            final frontScaffold = Scaffold(
              extendBody: true,
              backgroundColor: isDark ? const Color(0xFF0A1124) : const Color(0xFFEEF2FF),
              appBar: AppBar(
                backgroundColor: isDark
                    ? const Color(0xFF0A1124)
                    : const Color(0xFFEEF2FF),
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 50,
                leading: IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _drawerAnim,
                    color: AppColors.textPrimary(isDark),
                  ),
                  onPressed: _toggleDrawer,
                ),
                title: Text(
                  s.appTitle,
                  style: AppTypography.headline.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                centerTitle: true,
                actions: constraints.maxWidth >= 140
                    ? [
                        IconButton(
                          tooltip: s.navAnalytics,
                          icon: Icon(
                            Icons.bar_chart_rounded,
                            color: AppColors.primaryText(isDark),
                          ),
                          onPressed: () {
                            if (_isDrawerOpen) _closeDrawer();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AnalyticsScreen(),
                              ),
                            );
                          },
                        ),
                      ]
                    : null,
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

            return AnimatedBuilder(
              animation: _drawerAnim,
              builder: (context, child) {
                final t = _drawerAnim.value;
                final isOpen = t > 0.01;
                final dirSign = isRtl ? -1.0 : 1.0;

                // 3D Perspective Tilt transform for the main screen
                final slideX = dirSign * slideDistance * t;
                final scale = 1.0 - (0.16 * t);
                final tiltY = -dirSign * 0.26 * t;
                final radius = 28.0 * t;

                final matrix = Matrix4.identity();
                if (isOpen) {
                  matrix
                    ..setEntry(3, 2, 0.0012)
                    ..translateByDouble(slideX, 0.0, 0.0, 1.0)
                    ..scaleByDouble(scale, scale, 1.0, 1.0)
                    ..rotateY(tiltY);
                }

                return PopScope(
                  canPop: !isOpen,
                  onPopInvokedWithResult: (didPop, _) {
                    if (!didPop && isOpen) _closeDrawer();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: isDark
                            ? const [Color(0xFF0E1B36), Color(0xFF060B18)]
                            : const [Color(0xFFE3ECFA), Color(0xFFF3F6FC)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Layer 1: Side Menu Canvas (behind the tilted screen)
                        IgnorePointer(
                          ignoring: !isOpen,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: SizedBox(
                              width: menuWidth,
                              child: Opacity(
                                opacity: t.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(-dirSign * 22.0 * (1.0 - t), 0),
                                  child: AppSideMenu(
                                    cubit: cubit,
                                    state: state,
                                    onClose: _closeDrawer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Layer 2: Main App Screen with 3D Perspective Tilt
                        Transform(
                          alignment: Alignment.center,
                          transform: matrix,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(radius),
                              boxShadow: isOpen
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: (isDark ? 0.55 : 0.22) * t,
                                        ),
                                        blurRadius: 42 * t,
                                        spreadRadius: 4 * t,
                                        offset: Offset(-dirSign * 14 * t, 14 * t),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              child: Stack(
                                children: [
                                  child!,
                                  if (isOpen)
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: _closeDrawer,
                                        onHorizontalDragEnd: (details) {
                                          final vx = details.primaryVelocity ?? 0;
                                          if ((isRtl && vx > 150) || (!isRtl && vx < -150)) {
                                            _closeDrawer();
                                          }
                                        },
                                        child: Container(
                                          color: Colors.black.withValues(alpha: 0.08 * t),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: frontScaffold,
            );
            },
          ),
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

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
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
                    child: Center(
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
