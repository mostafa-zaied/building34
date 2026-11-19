import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/pwa_install.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';

class InstallAppScreen extends StatefulWidget {
  const InstallAppScreen({super.key});

  @override
  State<InstallAppScreen> createState() => _InstallAppScreenState();
}

class _InstallAppScreenState extends State<InstallAppScreen> {
  bool _installing = false;
  bool _installed = false;

  @override
  void initState() {
    super.initState();
    _installed = isPwaStandalone();
  }

  Future<void> _triggerInstall() async {
    setState(() => _installing = true);
    final accepted = await triggerPwaInstallPrompt();
    if (!mounted) return;
    setState(() {
      _installing = false;
      if (accepted) _installed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final s = state.s;
        final isDark = state.isDarkMode;
        final canPrompt = !_installed && canPromptPwaInstall();

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface(isDark),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              s.installAppTitle,
              style: AppTypography.headline.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            centerTitle: true,
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
                    // Hero Banner Card
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.emerald],
                                begin: AlignmentDirectional.topStart,
                                end: AlignmentDirectional.bottomEnd,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.install_mobile_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            s.installAppTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.headline.copyWith(
                              fontSize: 17,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            s.installAppSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary(isDark),
                              height: 1.5,
                            ),
                          ),
                          if (_installed) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: AppColors.emerald.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                s.installAppAlreadyInstalled,
                                textAlign: TextAlign.center,
                                style: AppTypography.label.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ] else if (canPrompt) ...[
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: AppPrimaryButton(
                                label: s.installAppNowBtn,
                                icon: Icons.download_rounded,
                                loading: _installing,
                                onPressed: _installing ? null : _triggerInstall,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Android Chrome Steps
                    _PlatformStepsCard(
                      icon: Icons.android_rounded,
                      iconColor: AppColors.emerald,
                      title: s.installAndroidTitle,
                      isDark: isDark,
                      steps: [
                        (icon: Icons.more_vert_rounded, text: s.installAndroidStep1),
                        (icon: Icons.add_to_home_screen_rounded, text: s.installAndroidStep2),
                        (icon: Icons.check_circle_outline_rounded, text: s.installAndroidStep3),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // iPhone Safari Steps
                    _PlatformStepsCard(
                      icon: Icons.phone_iphone_rounded,
                      iconColor: AppColors.primary,
                      title: s.installIosTitle,
                      isDark: isDark,
                      steps: [
                        (icon: Icons.explore_outlined, text: s.installIosStep1),
                        (icon: Icons.ios_share_rounded, text: s.installIosStep2),
                        (icon: Icons.add_box_outlined, text: s.installIosStep3),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlatformStepsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDark;
  final List<({IconData icon, String text})> steps;

  const _PlatformStepsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: AppTypography.caption.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      steps[i].text,
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary(isDark),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    steps[i].icon,
                    size: 18,
                    color: AppColors.textSecondary(isDark),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
