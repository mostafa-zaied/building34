import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/common/app_card.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final isDark = state.isDarkMode;
        final isAr = state.localeCode == 'ar';

        if (!state.isAdminAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isAr ? 'الإعدادات' : 'Settings'),
            ),
            body: Center(
              child: Text(
                isAr ? 'هذه الصفحة متاحة للمدير فقط.' : 'Admin access only.',
                style: AppTypography.body,
              ),
            ),
          );
        }

        final enabled = state.requireAptPassOnOpen;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface(isDark),
            elevation: 0,
            title: Text(
              isAr ? 'إعدادات المدير (Settings)' : 'Admin Settings',
              style: AppTypography.headline.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                children: [
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                Icons.lock_person_outlined,
                                color: AppColors.primaryText(isDark),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr
                                        ? 'طلب كلمة سر الشقة قبل فتح التفاصيل'
                                        : 'Require Apartment Passcode Before Opening',
                                    style: AppTypography.headline.copyWith(
                                      fontSize: 15,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    enabled
                                        ? (isAr ? 'مُفعّل حالياً' : 'Currently Enabled')
                                        : (isAr ? 'مُعطّل حالياً' : 'Currently Disabled'),
                                    style: AppTypography.caption.copyWith(
                                      color: enabled
                                          ? AppColors.emeraldText(isDark)
                                          : AppColors.textSecondary(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: enabled,
                              onChanged: (v) => cubit.setRequireAptPassOnOpen(v),
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface(isDark),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border(isDark)),
                          ),
                          child: Text(
                            enabled
                                ? (isAr
                                    ? 'عند التفعيل: يُجبر الساكن على إدخال كلمة سر الشقة من الخارج أول مرة قبل رؤية تفاصيل شقته أو الدفع، ولا يمكنه فتح شقق أخرى.'
                                    : 'When enabled: Residents must enter their apartment passcode from outside before viewing details or paying.')
                                : (isAr
                                    ? 'عند الإيقاف: تفتح تفاصيل أي شقة مباشرة بدون طلب كلمة سر من الخارج، ويتم إدخال كلمة السر داخل نافذة الدفع فقط.'
                                    : 'When disabled: Apartment details open directly, and the passcode is entered inside the payment dialog.'),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
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
