import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../l10n/app_localizations.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';

class FeedbackScreen extends StatefulWidget {
  final String type; // 'complaint' or 'improvement'

  const FeedbackScreen({super.key, required this.type});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _msgCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isAnonymous = true;
  int _selectedApt = 1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _msgCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildingCubit cubit) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    final ok = await cubit.submitFeedbackPost(
      type: widget.type,
      message: text,
      aptNum: _isAnonymous ? null : _selectedApt,
      passcode: _isAnonymous ? null : _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      _msgCtrl.clear();
      _passCtrl.clear();
      _tabCtrl.animateTo(0);
    }
    setState(() => _submitting = false);
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d  $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;

        final isComplaint = widget.type == 'complaint';
        final accent = isComplaint ? AppColors.amber : AppColors.emerald;
        final aptsCount = state.currentMonth?.aptsCount ?? 13;
        if (_selectedApt > aptsCount) _selectedApt = 1;

        final posts = state.feedbackPosts.where((p) => p.type == widget.type).toList();

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isComplaint ? s.complaintsTitle : s.improvementsTitle,
                          style: AppTypography.headline,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color: AppColors.surface(isDark),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border(isDark)),
                          ),
                          child: TabBar(
                            controller: _tabCtrl,
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            labelColor: AppColors.onPrimaryAction(isDark),
                            unselectedLabelColor: AppColors.textSecondary(isDark),
                            labelStyle: AppTypography.label.copyWith(fontWeight: FontWeight.w700),
                            tabs: [
                              Tab(
                                text: isComplaint
                                    ? s.tabViewComplaints(posts.length)
                                    : s.tabViewImprovements(posts.length),
                              ),
                              Tab(
                                text: isComplaint ? s.tabAddComplaint : s.tabAddImprovement,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _buildPostsList(
                          posts: posts,
                          isDark: isDark,
                          accent: accent,
                          isComplaint: isComplaint,
                          state: state,
                          cubit: cubit,
                        ),
                        _buildComposerTab(
                          isDark: isDark,
                          accent: accent,
                          isComplaint: isComplaint,
                          aptsCount: aptsCount,
                          state: state,
                          cubit: cubit,
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

  Widget _buildPostsList({
    required List<FeedbackPost> posts,
    required bool isDark,
    required Color accent,
    required bool isComplaint,
    required BuildingState state,
    required BuildingCubit cubit,
  }) {
    final s = state.s;
    if (posts.isEmpty) {
      return Center(
        child: AppCard(
          padding: const EdgeInsetsDirectional.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isComplaint ? Icons.campaign_outlined : Icons.lightbulb_outline,
                  size: 36,
                  color: accent,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                s.noPostsYet,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary(isDark)),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: isComplaint ? s.tabAddComplaint : s.tabAddImprovement,
                icon: Icons.add_rounded,
                backgroundColor: accent,
                foregroundColor: Colors.black,
                onPressed: () => _tabCtrl.animateTo(1),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final post = posts[index];
        final isAnon = post.authorLabel == null || post.authorLabel!.trim().isEmpty;
        return AppCard(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: accent.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      isAnon ? s.anonymousAuthor : '🏠 ${post.authorLabel}',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isAnon ? AppColors.textSecondary(isDark) : accent,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDate(post.createdAt),
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      if (state.isAdminOpen) ...[
                        const SizedBox(width: AppSpacing.xxs),
                        IconButton(
                          onPressed: () => _showAdminStatusDialog(
                            context: context,
                            cubit: cubit,
                            state: state,
                            post: post,
                          ),
                          icon: const Icon(Icons.edit_note_rounded, size: 19, color: AppColors.primaryLight),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                        IconButton(
                          onPressed: () => cubit.deleteFeedbackPost(post.id),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          tooltip: s.deleteTooltip,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _StatusBadge(status: post.status, s: s, isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(post.message, style: AppTypography.body),
              if (post.adminReply != null && post.adminReply!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.07),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.adminReplyLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        post.adminReply!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAdminStatusDialog({
    required BuildContext context,
    required BuildingCubit cubit,
    required BuildingState state,
    required FeedbackPost post,
  }) async {
    String selectedStatus = post.status;
    final replyCtrl = TextEditingController(text: post.adminReply ?? '');
    final isDark = state.isDarkMode;
    final s = state.s;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          backgroundColor: AppColors.card(isDark),
          title: Text(
            s.updateStatusTitle,
            style: AppTypography.headline.copyWith(fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: InputDecoration(labelText: s.statusFieldLabel),
                items: [
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text(_statusLabel('pending', s)),
                  ),
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Text(_statusLabel('in_progress', s)),
                  ),
                  DropdownMenuItem(
                    value: 'resolved',
                    child: Text(_statusLabel('resolved', s)),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setModal(() => selectedStatus = v);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: replyCtrl,
                maxLines: 3,
                decoration: InputDecoration(hintText: s.adminReplyHint),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.s.cancel)),
            ElevatedButton(
              onPressed: () async {
                await cubit.updateFeedbackStatus(
                  id: post.id,
                  status: selectedStatus,
                  adminReply: replyCtrl.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(state.s.saveAll),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 350), replyCtrl.dispose);
  }

  Widget _buildComposerTab({
    required bool isDark,
    required Color accent,
    required bool isComplaint,
    required int aptsCount,
    required BuildingState state,
    required BuildingCubit cubit,
  }) {
    final s = state.s;
    return SingleChildScrollView(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: isComplaint ? s.writeComplaintHint : s.writeImprovementHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.postAnonymously,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Switch.adaptive(
                  value: _isAnonymous,
                  onChanged: (v) => setState(() => _isAnonymous = v),
                  activeTrackColor: accent,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _isAnonymous
                  ? const SizedBox(height: AppSpacing.sm)
                  : Column(
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedApt,
                          decoration: InputDecoration(
                            labelText: s.selectApartment,
                            isDense: true,
                          ),
                          items: List.generate(aptsCount, (i) {
                            final num = i + 1;
                            return DropdownMenuItem(
                              value: num,
                              child: Text(state.aptLabel(num)),
                            );
                          }),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedApt = v);
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: s.passcodeLabel,
                            hintText: s.enterPassHint,
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
            ),
            AppPrimaryButton(
              label: _submitting ? s.saving : s.submitPostBtn,
              icon: isComplaint ? Icons.campaign_outlined : Icons.lightbulb_outline,
              backgroundColor: accent,
              foregroundColor: Colors.black,
              loading: _submitting,
              onPressed: () => _submit(cubit),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status, AppLocalizations s) {
  return switch (status) {
    'in_progress' => s.statusInProgress,
    'resolved' => s.statusResolved,
    _ => s.statusPending,
  };
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations s;
  final bool isDark;

  const _StatusBadge({
    required this.status,
    required this.s,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'in_progress' => AppColors.primaryLight,
      'resolved' => AppColors.emerald,
      _ => AppColors.amber,
    };

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        _statusLabel(status, s),
        style: AppTypography.caption.copyWith(
          color: status == 'resolved' ? AppColors.emeraldText(isDark) : color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
