import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_button.dart';
import '../common/app_card.dart';
import '../common/busy_overlay.dart';
import 'confirm_delete_dialog.dart';

Future<void> showManageApartmentsDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ManageApartmentsScreen(cubit: cubit, state: state),
      ),
    ),
  );
}

class ManageApartmentsScreen extends StatefulWidget {
  final BuildingCubit cubit;
  final BuildingState state;

  const ManageApartmentsScreen({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  State<ManageApartmentsScreen> createState() => _ManageApartmentsScreenState();
}

class _ManageApartmentsScreenState extends State<ManageApartmentsScreen> {
  final _scrollCtrl = ScrollController();
  final Map<int, TextEditingController> _nameCtrls = {};
  final Map<int, TextEditingController> _passCtrls = {};

  List<ApartmentInfo> _apts = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await widget.cubit.fetchAdminApartments();
    if (!mounted) return;
    if (res.error != null || res.apartments == null) {
      setState(() {
        _loading = false;
        _error = res.error ?? 'Error';
      });
      return;
    }

    final apts = List<ApartmentInfo>.from(res.apartments!);
    for (final a in apts) {
      _nameCtrls[a.aptNum] = TextEditingController(text: a.displayName);
      _passCtrls[a.aptNum] = TextEditingController(text: a.passcode);
    }
    setState(() {
      _apts = apts;
      _loading = false;
    });
  }

  void _addNewApartment() {
    final nextNum = _apts.isEmpty ? 1 : _apts.last.aptNum + 1;
    final newApt = ApartmentInfo(aptNum: nextNum, passcode: '');
    _nameCtrls[nextNum] = TextEditingController(text: '');
    _passCtrls[nextNum] = TextEditingController(text: '');
    setState(() {
      _apts = [..._apts, newApt];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _deleteApartment(int index) {
    if (_apts.length <= 1) return;
    final oldCtrls = <(String, String)>[];
    for (int i = 0; i < _apts.length; i++) {
      if (i == index) continue;
      final num = _apts[i].aptNum;
      oldCtrls.add((_nameCtrls[num]?.text ?? '', _passCtrls[num]?.text ?? ''));
    }

    for (final c in _nameCtrls.values) {
      c.dispose();
    }
    for (final c in _passCtrls.values) {
      c.dispose();
    }
    _nameCtrls.clear();
    _passCtrls.clear();

    final updated = <ApartmentInfo>[];
    for (int i = 0; i < oldCtrls.length; i++) {
      final aptNum = i + 1;
      final (name, pass) = oldCtrls[i];
      _nameCtrls[aptNum] = TextEditingController(text: name);
      _passCtrls[aptNum] = TextEditingController(text: pass);
      updated.add(ApartmentInfo(aptNum: aptNum, displayName: name, passcode: pass));
    }

    setState(() {
      _apts = updated;
    });
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    final m = widget.cubit.state.currentMonth;
    final closedSet = widget.cubit.state.closedAptNums.toSet();
    final activeCount = _apts
        .where((a) => !closedSet.contains(a.aptNum))
        .length
        .clamp(1, _apts.isEmpty ? 1 : _apts.length);
    if (m != null && activeCount != m.aptsCount) {
      widget.cubit.updateCurrentMonthFields(
        water: m.water,
        elec: m.elec,
        elev: m.elev,
        clean: m.clean,
        forEmerg: m.forEmerg,
        aptsCount: activeCount,
        baseEmergency: widget.cubit.state.baseEmergency,
      );
      await widget.cubit.saveAdminChanges();
    }

    final names = {for (final a in _apts) a.aptNum: _nameCtrls[a.aptNum]?.text ?? ''};
    final passcodes = {for (final a in _apts) a.aptNum: _passCtrls[a.aptNum]?.text ?? ''};
    await widget.cubit.saveAllApartments(apts: _apts, names: names, passcodes: passcodes);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    for (final c in _nameCtrls.values) {
      c.dispose();
    }
    for (final c in _passCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, liveState) {
        final s = liveState.s;
        final isDark = liveState.isDarkMode;

        return BusyOverlay(
          busy: _saving || liveState.busy,
          isDark: isDark,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: AppBar(
              backgroundColor: AppColors.surface(isDark),
              elevation: 0,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.manageAptsTitle.replaceAll('🔑', '').trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                  if (!_loading && _error == null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${_apts.length}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline_rounded, size: 36, color: AppColors.danger),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body.copyWith(color: AppColors.danger),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Apartments List
                              Expanded(
                                child: ListView.separated(
                                  controller: _scrollCtrl,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    AppSpacing.lg,
                                    AppSpacing.md,
                                    AppSpacing.lg,
                                    AppSpacing.lg,
                                  ),
                                  itemCount: _apts.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: AppSpacing.sm),
                                  itemBuilder: (context, idx) {
                                    final a = _apts[idx];
                                    final isClosed = liveState.closedAptNums.contains(a.aptNum);
                                    return AppCard(
                                      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsetsDirectional.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withValues(alpha: 0.14),
                                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                                ),
                                                child: Text(
                                                  s.defaultAptName(a.aptNum),
                                                  style: AppTypography.caption.copyWith(
                                                    color: AppColors.primaryText(isDark),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.xs),
                                              Tooltip(
                                                message: isClosed
                                                    ? s.convertToActiveBtn
                                                    : s.convertToClosedBtn,
                                                child: InkWell(
                                                  onTap: (_saving || liveState.busy)
                                                      ? null
                                                      : () => widget.cubit.setApartmentClosed(
                                                            a.aptNum,
                                                            !isClosed,
                                                          ),
                                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                                  child: Container(
                                                    padding: const EdgeInsetsDirectional.symmetric(
                                                      horizontal: 9,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: (isClosed
                                                              ? AppColors.amber
                                                              : AppColors.emerald)
                                                          .withValues(alpha: isDark ? 0.16 : 0.10),
                                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                                      border: Border.all(
                                                        color: (isClosed
                                                                ? AppColors.amber
                                                                : AppColors.emerald)
                                                            .withValues(alpha: 0.36),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          isClosed
                                                              ? Icons.lock_outline_rounded
                                                              : Icons.home_outlined,
                                                          size: 13,
                                                          color: isClosed
                                                              ? AppColors.amber
                                                              : AppColors.emeraldText(isDark),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          isClosed
                                                              ? s.aptStatusClosed
                                                              : s.aptStatusActive,
                                                          style: AppTypography.caption.copyWith(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w800,
                                                            color: isClosed
                                                                ? AppColors.amber
                                                                : AppColors.emeraldText(isDark),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 3),
                                                        Icon(
                                                          Icons.swap_horiz_rounded,
                                                          size: 13,
                                                          color: isClosed
                                                              ? AppColors.amber
                                                              : AppColors.emeraldText(isDark),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              if (_apts.length > 1)
                                                IconButton(
                                                  tooltip: s.deleteTooltip,
                                                  visualDensity: VisualDensity.compact,
                                                  onPressed: _saving
                                                      ? null
                                                      : () async {
                                                          final label = (_nameCtrls[a.aptNum]
                                                                          ?.text
                                                                          .trim()
                                                                          .isNotEmpty ==
                                                                      true)
                                                              ? _nameCtrls[a.aptNum]!.text.trim()
                                                              : s.defaultAptName(a.aptNum);
                                                          final ok = await showConfirmDeleteDialog(
                                                            context: context,
                                                            s: s,
                                                            isDark: isDark,
                                                            message: s.confirmDeleteAptBody(label),
                                                          );
                                                          if (ok) _deleteApartment(idx);
                                                        },
                                                  icon: Icon(
                                                    Icons.delete_outline_rounded,
                                                    size: 18,
                                                    color: AppColors.dangerText(isDark),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          TextField(
                                            controller: _nameCtrls[a.aptNum],
                                            style: AppTypography.body.copyWith(
                                              color: AppColors.textPrimary(isDark),
                                            ),
                                            decoration: InputDecoration(
                                              labelText: s.optionalName,
                                              filled: true,
                                              fillColor: AppColors.surface(isDark),
                                              prefixIcon: Icon(
                                                Icons.person_outline_rounded,
                                                size: 17,
                                                color: AppColors.textSecondary(isDark),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          TextField(
                                            controller: _passCtrls[a.aptNum],
                                            style: AppTypography.body.copyWith(
                                              color: AppColors.textPrimary(isDark),
                                              fontWeight: FontWeight.w700,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                            decoration: InputDecoration(
                                              labelText: s.passcodeLabel,
                                              hintText: s.passNotSetYet,
                                              filled: true,
                                              fillColor: AppColors.surface(isDark),
                                              prefixIcon: Icon(
                                                Icons.lock_outline_rounded,
                                                size: 17,
                                                color: AppColors.textSecondary(isDark),
                                              ),
                                              suffixIcon: IconButton(
                                                tooltip: s.resetPassBtn,
                                                icon: Icon(
                                                  Icons.lock_reset_rounded,
                                                  size: 18,
                                                  color: AppColors.dangerText(isDark),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _passCtrls[a.aptNum]?.clear();
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Sticky Bottom Action Bar
                              Container(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  AppSpacing.lg,
                                  AppSpacing.sm,
                                  AppSpacing.lg,
                                  AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface(isDark),
                                  border: Border(
                                    top: BorderSide(color: AppColors.border(isDark)),
                                  ),
                                ),
                                child: SafeArea(
                                  top: false,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _TopActionButton(
                                              label: s.addApartmentBtn,
                                              icon: Icons.add_home_rounded,
                                              color: AppColors.emerald,
                                              textColor: AppColors.emeraldText(isDark),
                                              isDark: isDark,
                                              onTap: _saving ? null : _addNewApartment,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: _TopActionButton(
                                              label: s.resetAllPasswordsBtn,
                                              icon: Icons.lock_reset_rounded,
                                              color: AppColors.danger,
                                              textColor: AppColors.dangerText(isDark),
                                              isDark: isDark,
                                              onTap: _saving
                                                  ? null
                                                  : () async {
                                                      await showConfirmDeleteDialog(
                                                        context: context,
                                                        s: s,
                                                        isDark: isDark,
                                                        confirmLabel: s.resetAllPasswordsBtn,
                                                        message: s.confirmResetAllPasswordsBody,
                                                        onConfirm: () async {
                                                          final ok = await widget.cubit
                                                              .resetAllApartmentPasscodes();
                                                          if (ok && mounted) {
                                                            setState(() {
                                                              for (final ctrl in _passCtrls.values) {
                                                                ctrl.clear();
                                                              }
                                                            });
                                                          }
                                                        },
                                                      );
                                                    },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      SizedBox(
                                        width: double.infinity,
                                        child: AppPrimaryButton(
                                          label: _saving ? s.saving : s.saveAll,
                                          icon: Icons.check_circle_outline_rounded,
                                          loading: _saving,
                                          onPressed: _saving ? null : _saveAll,
                                        ),
                                      ),
                                    ],
                                  ),
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

class _TopActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool isDark;
  final VoidCallback? onTap;

  const _TopActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: textColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
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
