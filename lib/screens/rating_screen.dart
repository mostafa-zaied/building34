import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../l10n/app_localizations.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/dialogs/confirm_delete_dialog.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final TextEditingController _commentCtrl = TextEditingController();
  int _selectedStars = 5;
  final Set<String> _selectedTags = {};
  int? _hydratedForApt;
  /// 0 = Add/Edit Rating Form, 1 = Reviews List
  int _selectedTab = 0;

  static const List<String> _arTags = [
    'سهل الاستخدام',
    'شفافية الحسابات',
    'سرعة الإيصالات',
    'أرقام الصيانة',
    'التصويتات',
    'توفير الوقت',
  ];

  static const List<String> _enTags = [
    'Easy to use',
    'Transparent billing',
    'Fast receipts',
    'Maintenance directory',
    'Building polls',
    'Time saving',
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _hydrateFromExisting(BuildingState state) {
    final myApt = state.myAptNum;
    if (myApt == null || _hydratedForApt == myApt) return;
    _hydratedForApt = myApt;
    final existing = state.appRatings.where((r) => r.aptNum == myApt).firstOrNull;
    if (existing != null) {
      _selectedStars = existing.stars;
      _selectedTags
        ..clear()
        ..addAll(existing.tags);
      _commentCtrl.text = existing.comment;
    }
  }

  String _moodLabel(int stars, AppLocalizations s) {
    return switch (stars) {
      1 => s.ratingMood1,
      2 => s.ratingMood2,
      3 => s.ratingMood3,
      4 => s.ratingMood4,
      5 => s.ratingMood5,
      _ => s.ratingPickStarsHint,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        _hydrateFromExisting(state);
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final aptsCount = state.currentMonth?.aptsCount ?? 13;
        final ratings = state.appRatings;
        final count = ratings.length;
        final avg = count > 0
            ? ratings.map((r) => r.stars).reduce((a, b) => a + b) / count
            : 0.0;
        final tagsList = state.localeCode == 'ar' ? _arTags : _enTags;
        final myExisting = state.myAptNum != null
            ? ratings.where((r) => r.aptNum == state.myAptNum).firstOrNull
            : null;
        final canRate = state.canResidentMutate && state.myAptNum != null;

        final ratedAptNums = ratings.map((r) => r.aptNum).toSet();
        final unratedApts = <int>[
          for (int i = 1; i <= aptsCount; i++)
            if (!ratedAptNums.contains(i)) i,
        ];

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: RefreshIndicator(
              onRefresh: cubit.refreshData,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  104,
                ),
                children: [
                  // 1. Overall Score Summary Card
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                size: 22,
                                color: AppColors.amber,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.ratingScreenTitle,
                                    style: AppTypography.headline.copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    s.ratingScreenSubtitle,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                s.ratingParticipationLabel(count, aptsCount),
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emeraldText(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Container(
                              width: 112,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: isDark ? 0.12 : 0.08),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                  color: AppColors.amber.withValues(alpha: 0.30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    avg.toStringAsFixed(1),
                                    style: AppTypography.heroAmount.copyWith(
                                      fontSize: 30,
                                      color: AppColors.amber,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < avg.round()
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 14,
                                        color: AppColors.amber,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    s.ratingCountLabel(count),
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                children: [
                                  for (int star = 5; star >= 1; star--) ...[
                                    _distRow(
                                      star: star,
                                      count: ratings
                                          .where((r) => r.stars == star)
                                          .length,
                                      total: count,
                                      isDark: isDark,
                                    ),
                                    if (star > 1) const SizedBox(height: 5),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // 1.5. 2-Tab Segmented Switcher: Add Rating vs Reviews List
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border(isDark)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ratingTabPill(
                            icon: Icons.rate_review_outlined,
                            label: s.ratingTabAdd,
                            selected: _selectedTab == 0,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _ratingTabPill(
                            icon: Icons.reviews_outlined,
                            label: s.ratingTabList,
                            count: count,
                            selected: _selectedTab == 1,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 2. Tab 0: Rating Form (verified residents only) OR Lock Card
                  if (_selectedTab == 0)
                    if (canRate)
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  myExisting != null
                                      ? s.ratingFormTitleEdit
                                      : s.ratingFormTitleNew,
                                  style: AppTypography.title.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  state.aptLabel(state.myAptNum!),
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryText(isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.ratingFormSubtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final n = i + 1;
                                final lit = n <= _selectedStars;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedStars = n),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 160),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: lit
                                            ? AppColors.amber.withValues(alpha: 0.16)
                                            : AppColors.surface(isDark),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: lit
                                              ? AppColors.amber
                                              : AppColors.border(isDark),
                                          width: lit ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Icon(
                                        lit
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 26,
                                        color: lit
                                            ? AppColors.amber
                                            : AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _moodLabel(_selectedStars, s),
                            textAlign: TextAlign.center,
                            style: AppTypography.label.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tagsList.map((tag) {
                              final selected = _selectedTags.contains(tag);
                              return FilterChip(
                                label: Text(tag),
                                selected: selected,
                                onSelected: (v) => setState(() {
                                  if (v) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                }),
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.18),
                                checkmarkColor: AppColors.primaryText(isDark),
                                labelStyle: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppColors.primaryText(isDark)
                                      : AppColors.textSecondary(isDark),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _commentCtrl,
                            maxLines: 3,
                            minLines: 2,
                            decoration: InputDecoration(
                              hintText: s.ratingCommentHint,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppPrimaryButton(
                            label: s.ratingSubmitBtn,
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: AppColors.primaryActionBg(isDark),
                            foregroundColor: AppColors.onPrimaryAction(isDark),
                            loading: state.busy,
                            onPressed: state.busy
                                ? null
                                : () async {
                                    final ok = await cubit.submitAppRating(
                                      stars: _selectedStars,
                                      tags: _selectedTags.toList(),
                                      comment: _commentCtrl.text,
                                    );
                                    if (ok && mounted) {
                                      setState(() => _selectedTab = 1);
                                    }
                                  },
                          ),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 24,
                              color: AppColors.amber,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            s.residentAuthRequiredTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.headline.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.residentAuthRequiredBody,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppPrimaryButton(
                            label: s.residentAuthGoHomeBtn,
                            icon: Icons.home_rounded,
                            backgroundColor: AppColors.primaryActionBg(isDark),
                            foregroundColor: AppColors.onPrimaryAction(isDark),
                            onPressed: () => cubit.selectNav(0),
                          ),
                        ],
                      ),
                    ),

                  // 3. Tab 1: Reviews List (Admin sees apartment details + unrated list)
                  if (_selectedTab == 1)
                    AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.isAdminAuthenticated
                                    ? s.ratingReviewsAdminTitle
                                    : s.ratingReviewsPublicTitle,
                                style: AppTypography.title.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ),
                            if (state.isAdminAuthenticated)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  s.ratingAdminOnlyBadge,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryText(isDark),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (ratings.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: Text(
                              s.ratingNoReviewsYet,
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          )
                        else
                          for (int i = 0; i < ratings.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.sm),
                            _reviewTile(
                              context: context,
                              rating: ratings[i],
                              state: state,
                              cubit: cubit,
                              isDark: isDark,
                            ),
                          ],
                        if (state.isAdminAuthenticated && unratedApts.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: isDark ? 0.10 : 0.07),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.amber.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.ratingUnratedAptsTitle(unratedApts.length),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.amber,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: unratedApts.map((apt) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface(isDark),
                                        borderRadius: BorderRadius.circular(AppRadius.pill),
                                        border: Border.all(
                                          color: AppColors.border(isDark),
                                        ),
                                      ),
                                      child: Text(
                                        state.aptLabel(apt),
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 10.5,
                                          color: AppColors.textSecondary(isDark),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _ratingTabPill({
    required IconData icon,
    required String label,
    int? count,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final fg = selected
        ? AppColors.onPrimaryAction(isDark)
        : AppColors.textSecondary(isDark);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryActionBg(isDark)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected
                        ? fg.withValues(alpha: 0.18)
                        : AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _distRow({
    required int star,
    required int count,
    required int total,
    required bool isDark,
  }) {
    final fraction = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(
            '$star ★',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 7,
              backgroundColor: AppColors.surface(isDark),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 22,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewTile({
    required BuildContext context,
    required AppRating rating,
    required BuildingState state,
    required BuildingCubit cubit,
    required bool isDark,
  }) {
    final s = state.s;
    final showAptIdentity =
        state.isAdminAuthenticated || rating.aptNum == state.myAptNum;
    final dateStr = DateFormat('d/M/yyyy').format(rating.updatedAt.toLocal());

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        showAptIdentity
                            ? state.aptLabel(rating.aptNum)
                            : s.ratingVerifiedResident,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                    ),
                    if (showAptIdentity) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          s.defaultAptName(rating.aptNum),
                          style: AppTypography.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText(isDark),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(5, (i) {
                    return Icon(
                      i < rating.stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 15,
                      color: AppColors.amber,
                    );
                  }),
                  if (state.isAdminAuthenticated)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      onPressed: () => showConfirmDeleteDialog(
                        context: context,
                        s: s,
                        isDark: isDark,
                        message: s.confirmDeleteRatingBody(
                          state.aptLabel(rating.aptNum),
                        ),
                        onConfirm: () => cubit.deleteAppRating(rating.aptNum),
                      ),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: AppColors.dangerText(isDark),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (rating.tags.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: rating.tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: AppColors.emerald.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(
                    t,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emeraldText(isDark),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (rating.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              rating.comment,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: AppTypography.caption.copyWith(
              fontSize: 10.5,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
