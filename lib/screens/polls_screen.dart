import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/dialogs/confirm_delete_dialog.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  /// 0 = Open polls, 1 = Closed polls
  int _selectedTab = 0;
  final Set<String> _expandedVoters = {};

  Future<void> _showCreatePollDialog(
    BuildContext context,
    BuildingCubit cubit,
    BuildingState state,
  ) async {
    final s = state.s;
    final isDark = state.isDarkMode;
    final questionCtrl = TextEditingController();
    final optionCtrls = <TextEditingController>[
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    bool allowMultiple = false;
    bool showVotersPublicly = true;
    bool notifyResidents = true;
    String? errMsg;
    bool saving = false;

    void applyPreset(
      List<String> preset,
      void Function(VoidCallback) setModalState,
    ) {
      for (final c in optionCtrls) {
        c.dispose();
      }
      optionCtrls
        ..clear()
        ..addAll(preset.map((t) => TextEditingController(text: t)));
      setModalState(() => errMsg = null);
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Row(
            children: [
              Icon(
                Icons.how_to_vote_rounded,
                color: AppColors.primaryText(isDark),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  s.createPollTitle,
                  style: AppTypography.headline.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: questionCtrl,
                    enabled: !saving,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: s.pollQuestionLabel,
                      hintText: s.pollQuestionHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    s.pollPresetsLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _presetChip(
                        label: s.pollPresetYesNo,
                        isDark: isDark,
                        onTap: saving
                            ? null
                            : () => applyPreset(
                                  state.localeCode == 'ar'
                                      ? ['نعم، موافق', 'لا، غير موافق']
                                      : ['Yes, I agree', 'No, I disagree'],
                                  setModalState,
                                ),
                      ),
                      _presetChip(
                        label: s.pollPresetAgree3,
                        isDark: isDark,
                        onTap: saving
                            ? null
                            : () => applyPreset(
                                  state.localeCode == 'ar'
                                      ? ['موافق', 'غير موافق', 'محايد']
                                      : ['Agree', 'Disagree', 'Neutral'],
                                  setModalState,
                                ),
                      ),
                      _presetChip(
                        label: s.pollPresetDays,
                        isDark: isDark,
                        onTap: saving
                            ? null
                            : () => applyPreset(
                                  state.localeCode == 'ar'
                                      ? ['الجمعة صباحاً', 'السبت صباحاً', 'الخميس مساءً']
                                      : ['Friday morning', 'Saturday morning', 'Thursday evening'],
                                  setModalState,
                                ),
                      ),
                      _presetChip(
                        label: s.pollPresetBudget,
                        isDark: isDark,
                        onTap: saving
                            ? null
                            : () => applyPreset(
                                  state.localeCode == 'ar'
                                      ? [
                                          'الصرف من صندوق الطوارئ',
                                          'تقسيم التكلفة على الشقق',
                                          'تأجيل للشهر القادم',
                                        ]
                                      : [
                                          'Pay from emergency fund',
                                          'Split across apartments',
                                          'Postpone to next month',
                                        ],
                                  setModalState,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    s.pollOptionsLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (int i = 0; i < optionCtrls.length; i++) ...[
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primaryText(isDark),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: TextField(
                            controller: optionCtrls[i],
                            enabled: !saving,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: s.pollOptionHint(i + 1),
                            ),
                          ),
                        ),
                        if (optionCtrls.length > 2) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: saving
                                ? null
                                : () => setModalState(() {
                                      final removed = optionCtrls.removeAt(i);
                                      removed.dispose();
                                    }),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.dangerText(isDark),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  if (optionCtrls.length < 8)
                    OutlinedButton.icon(
                      onPressed: saving
                          ? null
                          : () => setModalState(() {
                                optionCtrls.add(TextEditingController());
                              }),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        size: 16,
                        color: AppColors.primaryText(isDark),
                      ),
                      label: Text(
                        s.pollAddOptionBtn,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      s.pollAllowMultipleLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    value: allowMultiple,
                    onChanged: saving
                        ? null
                        : (v) => setModalState(() => allowMultiple = v),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      s.pollShowVotersLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    value: showVotersPublicly,
                    onChanged: saving
                        ? null
                        : (v) => setModalState(() => showVotersPublicly = v),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      s.pollNotifyResidentsLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    value: notifyResidents,
                    onChanged: saving
                        ? null
                        : (v) => setModalState(() => notifyResidents = v),
                  ),
                  if (errMsg != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      errMsg!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryActionBg(isDark),
                foregroundColor: AppColors.onPrimaryAction(isDark),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      final q = questionCtrl.text.trim();
                      final opts = optionCtrls
                          .map((c) => c.text.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();
                      if (q.isEmpty) {
                        setModalState(() => errMsg = s.errPollQuestionRequired);
                        return;
                      }
                      if (opts.length < 2) {
                        setModalState(() => errMsg = s.errPollMinTwoOptions);
                        return;
                      }
                      setModalState(() {
                        saving = true;
                        errMsg = null;
                      });
                      final ok = await cubit.createBuildingPoll(
                        question: q,
                        optionTexts: opts,
                        allowMultiple: allowMultiple,
                        showVotersPublicly: showVotersPublicly,
                        notifyResidents: notifyResidents,
                      );
                      if (ok && ctx.mounted) {
                        Navigator.pop(ctx);
                      } else if (ctx.mounted) {
                        setModalState(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.pollPublishBtn),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      questionCtrl.dispose();
      for (final c in optionCtrls) {
        c.dispose();
      }
    });
  }

  Widget _presetChip({
    required String label,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.30),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText(isDark),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final aptsCount = state.currentMonth?.aptsCount ?? 13;
        final openPolls =
            state.buildingPolls.where((p) => !p.isClosed).toList();
        final closedPolls =
            state.buildingPolls.where((p) => p.isClosed).toList();
        final visiblePolls = _selectedTab == 0 ? openPolls : closedPolls;

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
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.how_to_vote_rounded,
                            size: 20,
                            color: AppColors.emeraldText(isDark),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.pollsTitle,
                                style:
                                    AppTypography.headline.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.pollsSubtitle,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.isAdminAuthenticated) ...[
                          const SizedBox(width: AppSpacing.sm),
                          AppPrimaryButton(
                            label: s.newPollBtn,
                            icon: Icons.add_rounded,
                            backgroundColor: AppColors.primaryActionBg(isDark),
                            foregroundColor: AppColors.onPrimaryAction(isDark),
                            onPressed: () =>
                                _showCreatePollDialog(context, cubit, state),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                          child: _PollTabPill(
                            icon: Icons.radio_button_checked_rounded,
                            label: s.pollsTabOpen,
                            count: openPolls.length,
                            selected: _selectedTab == 0,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _PollTabPill(
                            icon: Icons.lock_outline_rounded,
                            label: s.pollsTabClosed,
                            count: closedPolls.length,
                            selected: _selectedTab == 1,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: cubit.refreshData,
                      color: AppColors.primary,
                      child: visiblePolls.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: AppCard(
                                    padding: const EdgeInsetsDirectional.all(
                                      AppSpacing.xxxl,
                                    ),
                                    child: Text(
                                      _selectedTab == 0
                                          ? s.pollNoOpenYet
                                          : s.pollNoClosedYet,
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsetsDirectional.only(bottom: 90),
                              itemCount: visiblePolls.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final poll = visiblePolls[index];
                                final expanded =
                                    _expandedVoters.contains(poll.id);
                                return _PollCard(
                                  poll: poll,
                                  state: state,
                                  aptsCount: aptsCount,
                                  votersExpanded: expanded,
                                  onToggleVoters: () => setState(() {
                                    if (expanded) {
                                      _expandedVoters.remove(poll.id);
                                    } else {
                                      _expandedVoters.add(poll.id);
                                    }
                                  }),
                                  onVote: (optId) => cubit.castPollVote(
                                    pollId: poll.id,
                                    optionId: optId,
                                  ),
                                  onToggleClose: state.isAdminAuthenticated
                                      ? () => cubit.togglePollClosed(
                                            poll.id,
                                            !poll.isClosed,
                                          )
                                      : null,
                                  onDelete: state.isAdminAuthenticated
                                      ? () => showConfirmDeleteDialog(
                                            context: context,
                                            s: s,
                                            isDark: isDark,
                                            message: s.confirmDeletePollBody,
                                            onConfirm: () =>
                                                cubit.deleteBuildingPoll(poll.id),
                                          )
                                      : null,
                                );
                              },
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

class _PollTabPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _PollTabPill({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  final BuildingPoll poll;
  final BuildingState state;
  final int aptsCount;
  final bool votersExpanded;
  final VoidCallback onToggleVoters;
  final ValueChanged<String> onVote;
  final VoidCallback? onToggleClose;
  final VoidCallback? onDelete;

  const _PollCard({
    required this.poll,
    required this.state,
    required this.aptsCount,
    required this.votersExpanded,
    required this.onToggleVoters,
    required this.onVote,
    this.onToggleClose,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final uniqueCount = poll.uniqueVoters.length;
    final totalSelections = poll.totalSelections;
    final denom = poll.allowMultiple
        ? (uniqueCount > 0 ? uniqueCount : 1)
        : (totalSelections > 0 ? totalSelections : 1);
    final maxVotes = poll.maxOptionVotes;
    final canSeeVoters = state.isAdminAuthenticated || poll.showVotersPublicly;
    final dateStr = DateFormat('d/M/yyyy').format(poll.createdAt.toLocal());

    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badges row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _badge(
                label: poll.isClosed ? s.pollClosedBadge : s.pollOpenBadge,
                color: poll.isClosed
                    ? AppColors.textSecondary(isDark)
                    : AppColors.emeraldText(isDark),
                bg: poll.isClosed
                    ? AppColors.surface(isDark)
                    : AppColors.emerald.withValues(alpha: 0.14),
              ),
              _badge(
                label:
                    poll.allowMultiple ? s.pollMultiBadge : s.pollSingleBadge,
                color: poll.allowMultiple
                    ? const Color(0xFFA78BFA)
                    : AppColors.primaryText(isDark),
                bg: (poll.allowMultiple
                        ? const Color(0xFF8B5CF6)
                        : AppColors.primary)
                    .withValues(alpha: 0.14),
              ),
              if (!poll.showVotersPublicly)
                _badge(
                  label: s.pollSecretBadge,
                  color: AppColors.amber,
                  bg: AppColors.amber.withValues(alpha: 0.14),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Question
          Text(
            poll.question,
            style: AppTypography.headline.copyWith(
              fontSize: 15,
              color: AppColors.textPrimary(isDark),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateStr • ${s.pollOptionsCount(poll.options.length)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Dynamic Options
          for (int i = 0; i < poll.options.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xs),
            _buildOptionTile(
              option: poll.options[i],
              denom: denom,
              totalSelections: totalSelections,
              maxVotes: maxVotes,
              canSeeVoters: canSeeVoters,
              isDark: isDark,
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.border(isDark)),
          const SizedBox(height: AppSpacing.sm),

          // Footer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_2_outlined,
                    size: 15,
                    color: AppColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    s.pollParticipation(uniqueCount, aptsCount),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (canSeeVoters && uniqueCount > 0)
                    _miniActionBtn(
                      label: votersExpanded
                          ? s.pollHideVotersBtn
                          : s.pollShowVotersBtn,
                      color: AppColors.textPrimary(isDark),
                      isDark: isDark,
                      onTap: onToggleVoters,
                    ),
                  if (onToggleClose != null)
                    _miniActionBtn(
                      label: poll.isClosed ? s.pollReopenBtn : s.pollCloseBtn,
                      color: AppColors.primaryText(isDark),
                      isDark: isDark,
                      onTap: onToggleClose!,
                    ),
                  if (onDelete != null)
                    _miniActionBtn(
                      label: s.confirmDeleteBtn,
                      color: AppColors.dangerText(isDark),
                      isDark: isDark,
                      onTap: onDelete!,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required PollOption option,
    required int denom,
    required int totalSelections,
    required int maxVotes,
    required bool canSeeVoters,
    required bool isDark,
  }) {
    final s = state.s;
    final voters = poll.votersFor(option.id);
    final count = voters.length;
    final pct = totalSelections > 0 ? ((count / denom) * 100).round().clamp(0, 100) : 0;
    final isSelected = poll.hasVoted(state.myAptNum, option.id);
    final isWinner = poll.isClosed && maxVotes > 0 && count == maxVotes;

    final accent = isWinner ? AppColors.emerald : AppColors.primary;
    final borderColor = isWinner
        ? AppColors.emerald
        : (isSelected ? AppColors.primary : AppColors.border(isDark));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: poll.isClosed ? null : () => onVote(option.id),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width: (isSelected || isWinner) ? 1.5 : 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: pct / 100.0,
                    heightFactor: 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 11,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: (isSelected || isWinner)
                                ? accent
                                : Colors.transparent,
                            shape: poll.allowMultiple
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: poll.allowMultiple
                                ? BorderRadius.circular(5)
                                : null,
                            border: Border.all(
                              color: (isSelected || isWinner)
                                  ? accent
                                  : AppColors.textSecondary(isDark),
                              width: 1.6,
                            ),
                          ),
                          child: isWinner
                              ? const Icon(
                                  Icons.emoji_events_rounded,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : (isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    )
                                  : null),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            option.text,
                            style: AppTypography.label.copyWith(
                              color: AppColors.textPrimary(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card(isDark).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            s.pollVotesCount(count),
                            style: AppTypography.caption.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textSecondary(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$pct%',
                          style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isWinner
                                ? AppColors.emeraldText(isDark)
                                : AppColors.primaryText(isDark),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    if (votersExpanded && canSeeVoters && voters.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: voters.map((apt) {
                          final isMe = apt == state.myAptNum;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppColors.primary.withValues(alpha: 0.18)
                                  : AppColors.card(isDark),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: isMe
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : AppColors.border(isDark),
                              ),
                            ),
                            child: Text(
                              state.aptLabel(apt),
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isMe
                                    ? AppColors.primaryText(isDark)
                                    : AppColors.textSecondary(isDark),
                              ),
                            ),
                          );
                        }).toList(),
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
  }

  Widget _badge({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _miniActionBtn({
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
