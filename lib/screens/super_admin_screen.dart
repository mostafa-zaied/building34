import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/web_url.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../l10n/app_localizations.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/busy_overlay.dart';
import 'buildings_portal_screen.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final _superPassCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _hidePass = true;
  bool _loading = false;
  String? _superPass;
  String? _authErr;
  SuperAdminDashboardData? _dashboard;
  String _statusFilter = 'all'; // 'all' | 'active' | 'trial' | 'suspended'

  @override
  void dispose() {
    _superPassCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final cubit = context.read<BuildingCubit>();
    final s = cubit.state.s;
    final pass = _superPassCtrl.text.trim();
    if (pass.isEmpty) {
      setState(() => _authErr = s.errEmptyMessage);
      return;
    }

    setState(() {
      _loading = true;
      _authErr = null;
    });
    final res = await cubit.service.superAdminListBuildings(pass);
    if (!mounted) return;
    if (res.error != null || res.data == null) {
      setState(() {
        _loading = false;
        _authErr = res.error == 'err_wrong_super_pass'
            ? s.errWrongSuperPass
            : s.errSubmitFailed;
      });
      return;
    }
    setState(() {
      _loading = false;
      _superPass = pass;
      _dashboard = res.data;
    });
  }

  Future<void> _reload() async {
    final pass = _superPass;
    if (pass == null) return;
    setState(() => _loading = true);
    final res = await context.read<BuildingCubit>().service.superAdminListBuildings(pass);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.data != null) _dashboard = res.data;
    });
  }

  Future<void> _updateSub(
    BuildingInfo building,
    String status, {
    int? extendDays,
  }) async {
    final pass = _superPass;
    if (pass == null) return;
    final s = context.read<BuildingCubit>().state.s;
    setState(() => _loading = true);
    final err = await context.read<BuildingCubit>().service.superAdminUpdateSubscription(
          superPass: pass,
          buildingId: building.id,
          status: status,
          extendDays: extendDays,
        );
    if (!mounted) return;
    if (err != null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.errSubmitFailed),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.superAdminActionDoneToast),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  Future<void> _resetBuildingAdminPass(BuildingInfo building) async {
    final pass = _superPass;
    if (pass == null) return;
    final state = context.read<BuildingCubit>().state;
    final s = state.s;
    final isDark = state.isDarkMode;
    final ctrl = TextEditingController();
    String? errMsg;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.card(isDark),
          title: Text(
            s.superAdminResetPassTitle(building.name),
            style: AppTypography.headline.copyWith(fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: s.superAdminNewAdminPassLabel,
                  filled: true,
                  fillColor: AppColors.surface(isDark),
                ),
              ),
              if (errMsg != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  errMsg!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.dangerText(isDark),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPass = ctrl.text.trim();
                if (newPass.length < 4) {
                  setModalState(() => errMsg = s.errPassTooShort);
                  return;
                }
                final err = await context
                    .read<BuildingCubit>()
                    .service
                    .superAdminResetBuildingAdminPass(
                      superPass: pass,
                      buildingId: building.id,
                      newPass: newPass,
                    );
                if (!ctx.mounted) return;
                if (err != null) {
                  setModalState(() => errMsg = s.errSubmitFailed);
                  return;
                }
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.superAdminActionDoneToast),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                }
              },
              child: Text(s.saveAll),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 350), ctrl.dispose);
  }

  Future<void> _changeSuperPassword() async {
    final currentPass = _superPass;
    if (currentPass == null) return;
    final state = context.read<BuildingCubit>().state;
    final s = state.s;
    final isDark = state.isDarkMode;
    final nextCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    String? errMsg;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.card(isDark),
          title: Text(
            s.superAdminChangePassTitle,
            style: AppTypography.headline.copyWith(fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nextCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: s.newAdminPassLabel,
                  filled: true,
                  fillColor: AppColors.surface(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: confCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: s.confirmNewAdminPassLabel,
                  filled: true,
                  fillColor: AppColors.surface(isDark),
                ),
              ),
              if (errMsg != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  errMsg!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.dangerText(isDark),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final next = nextCtrl.text.trim();
                final conf = confCtrl.text.trim();
                if (next.length < 4) {
                  setModalState(() => errMsg = s.errPassTooShort);
                  return;
                }
                if (next != conf) {
                  setModalState(() => errMsg = s.errPassMismatch);
                  return;
                }
                final err = await context
                    .read<BuildingCubit>()
                    .service
                    .superAdminChangePassword(
                      currentPass: currentPass,
                      newPass: next,
                    );
                if (!ctx.mounted) return;
                if (err != null) {
                  setModalState(() => errMsg = s.errSubmitFailed);
                  return;
                }
                setState(() => _superPass = next);
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.superAdminChangePassSuccessToast),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                }
              },
              child: Text(s.saveAll),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      nextCtrl.dispose();
      confCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final isAuthed = _superPass != null && _dashboard != null;

        return BusyOverlay(
          busy: _loading,
          isDark: isDark,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: AppBar(
              backgroundColor: AppColors.surface(isDark),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                s.superAdminTitle,
                style: AppTypography.headline.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              centerTitle: true,
              actions: isAuthed
                  ? [
                      IconButton(
                        tooltip: s.refreshTooltip,
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      IconButton(
                        tooltip: s.portalRegisterBtn,
                        onPressed: () async {
                          final created = await showRegisterBuildingDialog(
                            context: context,
                            cubit: cubit,
                            switchIntoCreated: false,
                          );
                          if (created != null && mounted) {
                            await _reload();
                          }
                        },
                        icon: const Icon(Icons.add_business_rounded),
                      ),
                      IconButton(
                        tooltip: s.superAdminChangePassTitle,
                        onPressed: _changeSuperPassword,
                        icon: const Icon(Icons.vpn_key_outlined),
                      ),
                      IconButton(
                        tooltip: s.adminLogoutBtn,
                        onPressed: () {
                          setState(() {
                            _superPass = null;
                            _dashboard = null;
                            _superPassCtrl.clear();
                          });
                        },
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ]
                  : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.border(isDark)),
              ),
            ),
            body: !isAuthed
                ? _buildLoginGate(s, isDark)
                : _buildDashboard(cubit, s, isDark, _dashboard!),
          ),
        );
      },
    );
  }

  Widget _buildLoginGate(AppLocalizations s, bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: AppCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_rounded,
                      color: AppColors.primaryText(isDark),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  s.superAdminLoginTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    fontSize: 17,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  s.superAdminLoginSub,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(isDark),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _superPassCtrl,
                  obscureText: _hidePass,
                  onSubmitted: (_) => _unlock(),
                  onChanged: (_) {
                    if (_authErr != null) setState(() => _authErr = null);
                  },
                  decoration: InputDecoration(
                    labelText: s.superAdminPassLabel,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _hidePass = !_hidePass),
                      icon: Icon(
                        _hidePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (_authErr != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _authErr!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.dangerText(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: s.superAdminUnlockBtn,
                  icon: Icons.login_rounded,
                  loading: _loading,
                  onPressed: _loading ? null : _unlock,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildingCubit cubit,
    AppLocalizations s,
    bool isDark,
    SuperAdminDashboardData data,
  ) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = data.buildings.where((item) {
      final b = item.building;
      final matchesStatus =
          _statusFilter == 'all' || b.subscriptionStatus == _statusFilter;
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;
      return b.name.toLowerCase().contains(query) ||
          b.code.toLowerCase().contains(query) ||
          b.city.toLowerCase().contains(query);
    }).toList();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            children: [
              // 1. Platform KPI Strip
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _kpiChip(s.superAdminStatBuildings, '${data.totalBuildings}',
                      AppColors.primary, isDark),
                  _kpiChip(s.superAdminStatActive, '${data.activeBuildings}',
                      AppColors.emerald, isDark),
                  _kpiChip(s.superAdminStatTrial, '${data.trialBuildings}',
                      AppColors.amber, isDark),
                  _kpiChip(s.superAdminStatSuspended, '${data.suspendedBuildings}',
                      AppColors.danger, isDark),
                  _kpiChip(s.superAdminStatApts, '${data.totalApts}',
                      AppColors.primaryLight, isDark),
                  _kpiChip(s.superAdminStatViews, '${data.totalViews}',
                      const Color(0xFF8B5CF6), isDark),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 2. Search & Status Filter
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: s.superAdminSearchHint,
                  filled: true,
                  fillColor: AppColors.surface(isDark),
                  prefixIcon: const Icon(Icons.search_rounded, size: 19),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('all', s.superAdminFilterAll, isDark),
                    const SizedBox(width: 6),
                    _filterChip('active', s.superAdminStatActive, isDark),
                    const SizedBox(width: 6),
                    _filterChip('trial', s.superAdminStatTrial, isDark),
                    const SizedBox(width: 6),
                    _filterChip('suspended', s.superAdminStatSuspended, isDark),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. Building Cards
              if (filtered.isEmpty)
                AppCard(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
                  child: Text(
                    s.superAdminNoBuildingsMatch,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                )
              else
                for (final item in filtered) ...[
                  _buildBuildingCard(cubit, s, isDark, item),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiChip(String label, String value, Color accent, bool isDark) {
    return Container(
      width: 120,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.headline.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, bool isDark) {
    final selected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundColor: AppColors.surface(isDark),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border(isDark),
      ),
    );
  }

  Widget _buildBuildingCard(
    BuildingCubit cubit,
    AppLocalizations s,
    bool isDark,
    SuperAdminBuildingItem item,
  ) {
    final b = item.building;
    final isSuspended = b.subscriptionStatus == 'suspended';
    final isTrial = b.subscriptionStatus == 'trial';
    final statusColor = isSuspended
        ? AppColors.danger
        : (isTrial ? AppColors.amber : AppColors.emerald);
    final statusLabel = isSuspended
        ? s.subStatusSuspended
        : (isTrial ? s.subStatusTrial : s.subStatusActive);
    final endsAt = b.effectiveEndsAt;
    final expiryText = endsAt == null
        ? ''
        : (b.isExpired
            ? s.subExpiredBadge
            : '${s.subDaysRemainingBadge(b.daysRemaining)} (${DateFormat('d/M/yyyy').format(endsAt.toLocal())})');

    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name,
                      style: AppTypography.title.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.city.isNotEmpty
                          ? '${b.code} • ${b.city}'
                          : b.code,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryText(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            s.superAdminMetricsLine(
              b.aptsCount,
              item.monthsCount,
              item.paymentsCount,
              item.viewsCount,
            ),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
          if (!b.isDefaultBuilding && expiryText.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              expiryText,
              style: AppTypography.caption.copyWith(
                color: b.isExpired
                    ? AppColors.dangerText(isDark)
                    : AppColors.textSecondary(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _updateSub(b, 'active', extendDays: 30),
                icon: const Icon(Icons.verified_rounded, size: 15),
                label: Text(s.superAdminExtend30Btn),
              ),
              OutlinedButton.icon(
                onPressed: () => _updateSub(b, 'active', extendDays: 365),
                icon: const Icon(Icons.workspace_premium_rounded, size: 15),
                label: Text(s.superAdminExtendYearBtn),
              ),
              if (!b.isDefaultBuilding)
                OutlinedButton.icon(
                  onPressed: () => _updateSub(
                    b,
                    isSuspended ? 'active' : 'suspended',
                    extendDays: isSuspended ? 30 : null,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSuspended
                        ? AppColors.emeraldText(isDark)
                        : AppColors.dangerText(isDark),
                  ),
                  icon: Icon(
                    isSuspended ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 15,
                  ),
                  label: Text(
                    isSuspended
                        ? s.superAdminReactivateBtn
                        : s.superAdminSuspendBtn,
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => _resetBuildingAdminPass(b),
                icon: const Icon(Icons.vpn_key_outlined, size: 15),
                label: Text(s.superAdminResetPassBtn),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: buildBuildingShareUrl(
                        b.code,
                        isDefaultBuilding: b.isDefaultBuilding,
                      ),
                    ),
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.buildingCodeCopiedToast),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: Text(s.copyLinkBtn),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await cubit.switchToBuildingByCode(b.code);
                  if (!mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: Text(s.superAdminOpenBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
