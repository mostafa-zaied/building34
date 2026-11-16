import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';

class WhatsAppShareSection extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final VoidCallback onCopyWhatsApp;

  const WhatsAppShareSection({
    super.key,
    required this.cubit,
    required this.state,
    required this.onCopyWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onCopyWhatsApp,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Ink(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryActionBg(isDark),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.accentGlow(
                  AppColors.primaryActionBg(isDark),
                  active: false,
                  isDark: isDark,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_rounded,
                    size: 15,
                    color: AppColors.onPrimaryAction(isDark),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    s.copyWhatsAppBtn,
                    style: AppTypography.label.copyWith(
                      color: AppColors.onPrimaryAction(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: state.copiedPreview == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsetsDirectional.only(top: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.45),
                      ),
                      boxShadow: AppShadows.card(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.copiedTitle,
                              style: AppTypography.label.copyWith(
                                color: AppColors.emeraldText(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            InkWell(
                              onTap: () => cubit.setCopiedPreview(null),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(
                          state.copiedPreview!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
