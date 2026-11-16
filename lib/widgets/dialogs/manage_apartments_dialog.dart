import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_button.dart';

Future<void> showManageApartmentsDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ManageApartmentsDialog(cubit: cubit, state: state),
  );
}

class _ManageApartmentsDialog extends StatefulWidget {
  final BuildingCubit cubit;
  final BuildingState state;

  const _ManageApartmentsDialog({
    required this.cubit,
    required this.state,
  });

  @override
  State<_ManageApartmentsDialog> createState() => _ManageApartmentsDialogState();
}

class _ManageApartmentsDialogState extends State<_ManageApartmentsDialog> {
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
    final newApt = ApartmentInfo(aptNum: nextNum, passcode: '${1000 + nextNum}');
    _nameCtrls[nextNum] = TextEditingController(text: '');
    _passCtrls[nextNum] = TextEditingController(text: newApt.passcode);
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
      oldCtrls.add((_nameCtrls[num]?.text ?? '', _passCtrls[num]?.text ?? '${1000 + num}'));
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
    final m = widget.state.currentMonth;
    if (m != null && _apts.length != m.aptsCount) {
      widget.cubit.updateCurrentMonthFields(
        water: m.water,
        elec: m.elec,
        elev: m.elev,
        clean: m.clean,
        forEmerg: m.forEmerg,
        aptsCount: _apts.length,
        baseEmergency: widget.state.baseEmergency,
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
    final s = widget.state.s;
    final isDark = widget.state.isDarkMode;
    final maxH = MediaQuery.sizeOf(context).height * 0.84;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      backgroundColor: AppColors.card(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: AppColors.border(isDark)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxH),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      s.manageAptsTitle,
                      style: AppTypography.headline.copyWith(
                        fontSize: 16,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textSecondary(isDark),
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: AppColors.border(isDark)),
              const SizedBox(height: AppSpacing.md),

              // Body
              if (_loading)
                const Padding(
                  padding: EdgeInsetsDirectional.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 32),
                  child: SelectableText(
                    '❌ $_error',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(color: AppColors.danger),
                  ),
                )
              else ...[
                Flexible(
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    shrinkWrap: true,
                    itemCount: _apts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, idx) {
                      final a = _apts[idx];
                      return Container(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface(isDark),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border(isDark)),
                          boxShadow: AppShadows.card(isDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card top bar: Apartment badge + Delete icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: Text(
                                    s.defaultAptName(a.aptNum),
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.primaryText(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _saving || _apts.length <= 1
                                      ? null
                                      : () => _deleteApartment(idx),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                                  color: AppColors.danger,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  tooltip: s.deleteTooltip,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // Card inputs row: Spacious Name + Passcode fields
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _nameCtrls[a.aptNum],
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textPrimary(isDark),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: s.optionalName,
                                      hintText: s.nameHint(a.aptNum),
                                      filled: true,
                                      fillColor: AppColors.card(isDark),
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        size: 17,
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                      contentPadding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.md,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _passCtrls[a.aptNum],
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textPrimary(isDark),
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                    decoration: InputDecoration(
                                      labelText: s.passcodeLabel,
                                      filled: true,
                                      fillColor: AppColors.card(isDark),
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        size: 17,
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                      contentPadding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.md,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Add Apartment Button
                InkWell(
                  onTap: _saving ? null : _addNewApartment,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_home_rounded,
                          size: 18,
                          color: AppColors.emeraldText(isDark),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          s.addApartmentBtn,
                          style: AppTypography.label.copyWith(
                            color: AppColors.emeraldText(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _saving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          s.cancel,
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: AppPrimaryButton(
                        label: _saving ? s.saving : s.saveAll,
                        icon: Icons.check_rounded,
                        loading: _saving,
                        onPressed: _saving ? null : _saveAll,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
