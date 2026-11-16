import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _ringScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _progressAnim;

  bool _minTimeElapsed = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    );

    _logoScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
    );
    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _ringScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.08, 0.72, curve: Curves.easeOutCubic),
    );
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.68, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.68, curve: Curves.easeOutCubic),
    ));
    _subtitleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.42, 0.82, curve: Curves.easeOut),
    );
    _progressAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.20, 1.0, curve: Curves.easeInOutCubic),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _minTimeElapsed = true;
        _tryNavigate(context.read<BuildingCubit>().state);
      }
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tryNavigate(BuildingState state) {
    if (_navigated || !_minTimeElapsed || state.loading || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 480),
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuildingCubit, BuildingState>(
      listenWhen: (prev, curr) => prev.loading != curr.loading,
      listener: (_, state) => _tryNavigate(state),
      builder: (context, state) {
        final isDark = state.isDarkMode;
        final s = state.s;
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
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: isDark
                      ? const [Color(0xFF0A1124), Color(0xFF0E1630), AppColors.darkBg]
                      : const [Color(0xFFEEF2FF), Color(0xFFF8FAFF), AppColors.lightBg],
                ),
              ),
              child: Stack(
                children: [
                  // Ambient top-start indigo glow
                  Positioned(
                    top: -90,
                    left: -60,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Ambient bottom-end emerald glow
                  Positioned(
                    bottom: -100,
                    right: -60,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.emerald.withValues(alpha: isDark ? 0.16 : 0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.xxl,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 3),
                            // Animated emblem with concentric halo rings
                            AnimatedBuilder(
                              animation: _ctrl,
                              builder: (_, _) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 0.75 + (_ringScale.value * 0.45),
                                      child: Opacity(
                                        opacity: (1 - _ringScale.value * 0.65).clamp(0.0, 1.0),
                                        child: Container(
                                          width: 146,
                                          height: 146,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.primary.withValues(
                                                alpha: isDark ? 0.30 : 0.22,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8 + (_ringScale.value * 0.25),
                                      child: Container(
                                        width: 118,
                                        height: 118,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary.withValues(
                                            alpha: isDark ? 0.12 : 0.08,
                                          ),
                                        ),
                                      ),
                                    ),
                                    FadeTransition(
                                      opacity: _logoFade,
                                      child: ScaleTransition(
                                        scale: _logoScale,
                                        child: Container(
                                          width: 88,
                                          height: 88,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [AppColors.primary, AppColors.accentViolet],
                                              begin: AlignmentDirectional.topStart,
                                              end: AlignmentDirectional.bottomEnd,
                                            ),
                                            borderRadius: BorderRadius.circular(26),
                                            boxShadow: [
                                              ...AppShadows.accentGlow(
                                                AppColors.primary,
                                                active: true,
                                                isDark: isDark,
                                              ),
                                              BoxShadow(
                                                color: AppColors.accentViolet.withValues(alpha: 0.28),
                                                blurRadius: 28,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.apartment_rounded,
                                            size: 44,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            // Title
                            FadeTransition(
                              opacity: _titleFade,
                              child: SlideTransition(
                                position: _titleSlide,
                                child: Text(
                                  s.appTitle,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.heroAmount.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            // Tagline
                            FadeTransition(
                              opacity: _subtitleFade,
                              child: Text(
                                s.splashTagline,
                                textAlign: TextAlign.center,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(flex: 3),
                            // Sleek progress pill
                            AnimatedBuilder(
                              animation: _progressAnim,
                              builder: (_, _) {
                                return SizedBox(
                                  width: 140,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    child: Container(
                                      height: 4,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : AppColors.primary.withValues(alpha: 0.12),
                                      child: Align(
                                        alignment: AlignmentDirectional.centerStart,
                                        child: FractionallySizedBox(
                                          widthFactor: _progressAnim.value.clamp(0.08, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.accentViolet,
                                                  AppColors.emerald,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(AppRadius.pill),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
