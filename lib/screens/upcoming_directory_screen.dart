import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/common/app_card.dart';

class UpcomingDirectoryScreen extends StatelessWidget {
  const UpcomingDirectoryScreen({super.key});

  static const List<String> _categoriesAr = [
    '🍽️ مطاعم وكافيهات',
    '💊 صيدليات',
    '🛒 سوبر ماركت وبقالة',
    '🥬 خضار وفاكهة',
    '🥖 مخبز وحلواني',
    '🔧 صيانة وفنيين',
    '🧺 مغسلة وكوي',
    '🚗 خدمات سيارات',
    '📚 مكتبة وتصوير',
    '📌 خدمات أخرى',
  ];

  static const List<String> _categoriesEn = [
    '🍽️ Restaurants & Cafes',
    '💊 Pharmacies',
    '🛒 Supermarkets',
    '🥬 Fruits & Vegetables',
    '🥖 Bakery & Sweets',
    '🔧 Maintenance & Techs',
    '🧺 Laundry',
    '🚗 Car Services',
    '📚 Stationery & Print',
    '📌 Other Services',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;
        final isAr = state.localeCode == 'ar';
        final voted = state.hasVotedUpcomingDirectory;
        final categories = isAr ? _categoriesAr : _categoriesEn;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              110,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        isAr
                            ? '🚀 قريباً في التحديث القادم — Upcoming'
                            : '🚀 Coming Soon — Upcoming',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      isAr
                          ? 'دليل خدمات المنطقة بمشاركة السكان'
                          : 'Neighborhood Services Directory',
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isAr
                          ? 'قريباً ستتمكن من إضافة وتصفح أفضل المطاعم، الصيدليات، وفنيي الصيانة المجرّبين حول عمارتنا والتواصل معهم بضغطة واحدة.'
                          : 'Soon you will be able to add and browse trusted local restaurants, pharmacies, and technicians around the building in one tap.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary(isDark),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: categories
                          .map(
                            (cat) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface(isDark),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: AppColors.border(isDark),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textPrimary(isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: voted
                            ? null
                            : () => context
                                .read<BuildingCubit>()
                                .voteUpcomingDirectory(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: voted
                              ? AppColors.emerald
                              : AppColors.primaryActionBg(isDark),
                          disabledBackgroundColor: AppColors.emerald,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: Icon(
                          voted
                              ? Icons.check_circle_rounded
                              : Icons.thumb_up_alt_outlined,
                          size: 18,
                        ),
                        label: Text(
                          voted
                              ? (isAr
                                  ? 'تم تسجيل اهتمامك بنجاح'
                                  : 'Interest recorded')
                              : (isAr
                                  ? 'أنا مهتم بهذه الخدمة 👍'
                                  : 'I am interested 👍'),
                          style: AppTypography.label.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      voted
                          ? (isAr
                              ? 'شكراً لك! صوتك وصل وسيساعدنا في إطلاق الدليل قريباً.'
                              : 'Thank you! Your vote helps us launch this directory soon.')
                          : (isAr
                              ? 'تصويتك يساعدنا في إطلاق الميزة أسرع لسكان العمارة'
                              : 'Your vote helps us prioritize launching this feature'),
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(isDark),
                      ),
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
