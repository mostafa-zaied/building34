import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
import 'super_admin_screen.dart';

class BuildingsPortalScreen extends StatefulWidget {
  const BuildingsPortalScreen({super.key});

  @override
  State<BuildingsPortalScreen> createState() => _BuildingsPortalScreenState();
}

class _BuildingsPortalScreenState extends State<BuildingsPortalScreen> {
  final _codeCtrl = TextEditingController();
  bool _switching = false;
  String? _joinErr;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyBuildingLink(
    BuildContext context,
    AppLocalizations s,
    BuildingInfo b,
  ) async {
    final url = buildBuildingShareUrl(b.code, isDefaultBuilding: b.isDefaultBuilding);
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.buildingCodeCopiedToast),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  Future<void> _switchByCode(String code) async {
    final cubit = context.read<BuildingCubit>();
    final s = cubit.state.s;
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) {
      setState(() => _joinErr = s.errEmptyMessage);
      return;
    }

    setState(() {
      _switching = true;
      _joinErr = null;
    });
    final err = await cubit.switchToBuildingByCode(clean);
    if (!mounted) return;
    setState(() => _switching = false);
    if (err != null) {
      setState(() => _joinErr = err);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _openRegisterWizard() async {
    final cubit = context.read<BuildingCubit>();
    final created = await showRegisterBuildingDialog(
      context: context,
      cubit: cubit,
    );
    if (!mounted || created == null) return;
    await _showWelcomeCreatedDialog(created);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showWelcomeCreatedDialog(BuildingInfo created) async {
    final state = context.read<BuildingCubit>().state;
    final s = state.s;
    final isDark = state.isDarkMode;
    final shareUrl = buildBuildingShareUrl(created.code);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.45)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 30,
                      color: AppColors.emeraldText(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  s.registerWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  s.registerWelcomeSub(created.name),
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(isDark),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.buildingCodeBadge(created.code),
                        textAlign: TextAlign.center,
                        style: AppTypography.title.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: SelectableText(
                          shareUrl,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppSecondaryButton(
                        label: s.copyLinkBtn,
                        icon: Icons.copy_rounded,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: shareUrl));
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(s.buildingCodeCopiedToast),
                              backgroundColor: AppColors.emerald,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppSecondaryButton(
                        label: s.shareWhatsappBtn,
                        icon: Icons.share_rounded,
                        accentColor: AppColors.emerald,
                        onPressed: () async {
                          final text = s.buildingShareWhatsappMsg(
                            created.name,
                            shareUrl,
                            created.code,
                          );
                          final uri = Uri.parse(
                            'https://wa.me/?text=${Uri.encodeComponent(text)}',
                          );
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: s.registerStartManagingBtn,
                  icon: Icons.rocket_launch_rounded,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
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
        final b = state.building;
        final isBusy = _switching || state.busy;

        return BusyOverlay(
          busy: isBusy,
          isDark: isDark,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: AppBar(
              backgroundColor: AppColors.surface(isDark),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                s.portalTitle,
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
            body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                  children: [
                    // 1. Current Active Building Card
                    if (!state.buildingNotFound)
                      AppCard(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              s.portalCurrentLabel,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.emerald],
                                    ),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: const Icon(
                                    Icons.apartment_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.displayBuildingName,
                                        style: AppTypography.title.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary(isDark),
                                        ),
                                      ),
                                      if (b.city.isNotEmpty)
                                        Text(
                                          b.city,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textSecondary(isDark),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                _SubscriptionStatusBadge(
                                  building: b,
                                  s: s,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface(isDark),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    border: Border.all(color: AppColors.border(isDark)),
                                  ),
                                  child: Text(
                                    s.buildingCodeBadge(b.code),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primaryText(isDark),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => _copyBuildingLink(context, s, b),
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: Text(s.copyLinkBtn),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // 2. Join Building by Code
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            s.portalJoinTitle,
                            style: AppTypography.headline.copyWith(
                              fontSize: 15,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeCtrl,
                                  textCapitalization: TextCapitalization.characters,
                                  textDirection: TextDirection.ltr,
                                  onSubmitted: _switchByCode,
                                  onChanged: (_) {
                                    if (_joinErr != null) {
                                      setState(() => _joinErr = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: s.portalJoinHint,
                                    filled: true,
                                    fillColor: AppColors.surface(isDark),
                                    prefixIcon: const Icon(Icons.qr_code_rounded, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              SizedBox(
                                width: 96,
                                child: AppPrimaryButton(
                                  label: s.portalJoinBtn,
                                  onPressed: isBusy
                                      ? null
                                      : () => _switchByCode(_codeCtrl.text),
                                ),
                              ),
                            ],
                          ),
                          if (_joinErr != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _joinErr!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.dangerText(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 3. Register New Building Hero CTA
                    Container(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: isDark
                              ? const [Color(0xFF1E3A8A), Color(0xFF064E3B)]
                              : const [Color(0xFF2563EB), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            s.portalRegisterCardTitle,
                            style: AppTypography.headline.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            s.portalRegisterCardSub,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton.icon(
                            onPressed: isBusy ? null : _openRegisterWizard,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            icon: const Icon(Icons.add_business_rounded, size: 19),
                            label: Text(
                              s.portalRegisterBtn,
                              style: AppTypography.label.copyWith(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 4. Saved / Recent Buildings List
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            s.portalSavedTitle,
                            style: AppTypography.headline.copyWith(
                              fontSize: 15,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (!b.isDefaultBuilding || state.buildingNotFound)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.14),
                                child: Icon(
                                  Icons.home_rounded,
                                  color: AppColors.primaryText(isDark),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                s.appTitle,
                                style: AppTypography.label.copyWith(
                                  color: AppColors.textPrimary(isDark),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                s.portalDefaultBadge,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () async {
                                setState(() => _switching = true);
                                await cubit.switchToDefaultBuilding();
                                if (!context.mounted) return;
                                setState(() => _switching = false);
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                            ),
                          if (state.savedBuildings.isEmpty && b.isDefaultBuilding)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              child: Text(
                                s.portalSavedEmpty,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            )
                          else
                            for (final saved in state.savedBuildings)
                              if (saved.id != b.id || state.buildingNotFound)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.emerald.withValues(alpha: 0.14),
                                    child: Icon(
                                      Icons.apartment_rounded,
                                      color: AppColors.emeraldText(isDark),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    saved.name,
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.textPrimary(isDark),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    saved.city.isNotEmpty
                                        ? '${saved.code} • ${saved.city}'
                                        : saved.code,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded),
                                  onTap: () => _switchByCode(saved.code),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 5. Discreet Platform Owner Super Admin Console Entry
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SuperAdminScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 16,
                          color: AppColors.textSecondary(isDark),
                        ),
                        label: Text(
                          s.portalSuperAdminBtn,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                            fontWeight: FontWeight.w700,
                          ),
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

class _SubscriptionStatusBadge extends StatelessWidget {
  final BuildingInfo building;
  final AppLocalizations s;
  final bool isDark;

  const _SubscriptionStatusBadge({
    required this.building,
    required this.s,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSuspended = building.isSuspended;
    final isTrial = building.isTrial;
    final Color color = isSuspended
        ? AppColors.danger
        : (isTrial ? AppColors.amber : AppColors.emerald);
    final Color fg = isSuspended
        ? AppColors.dangerText(isDark)
        : (isTrial ? AppColors.warningText(isDark) : AppColors.emeraldText(isDark));
    final label = isSuspended
        ? s.subStatusSuspended
        : (isTrial
            ? '${s.subStatusTrial} • ${s.subDaysRemainingBadge(building.daysRemaining)}'
            : s.subStatusActive);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Shared Self-Serve Building Registration Wizard Dialog.
/// Used by both [BuildingsPortalScreen] and [SuperAdminScreen].
Future<BuildingInfo?> showRegisterBuildingDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  bool switchIntoCreated = true,
}) async {
  final state = cubit.state;
  final s = state.s;
  final isDark = state.isDarkMode;

  final nameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final aptsCtrl = TextEditingController(text: '12');
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final instaCtrl = TextEditingController();
  final waCtrl = TextEditingController();

  bool hidePass = true;
  bool saving = false;
  String? errMsg;
  BuildingInfo? result;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Dialog(
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 460,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.emerald],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.add_business_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        s.registerWizardTitle,
                        style: AppTypography.headline.copyWith(
                          fontSize: 16,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: saving ? null : () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: nameCtrl,
                  enabled: !saving,
                  decoration: InputDecoration(
                    labelText: s.buildingNameLabel,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: const Icon(Icons.apartment_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: cityCtrl,
                        enabled: !saving,
                        decoration: InputDecoration(
                          labelText: s.buildingCityLabel,
                          filled: true,
                          fillColor: AppColors.surface(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: aptsCtrl,
                        enabled: !saving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: InputDecoration(
                          labelText: s.registerAptsCountLabel,
                          filled: true,
                          fillColor: AppColors.surface(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: passCtrl,
                  enabled: !saving,
                  obscureText: hidePass,
                  decoration: InputDecoration(
                    labelText: s.registerAdminPassLabel,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: const Icon(Icons.vpn_key_outlined, size: 18),
                    suffixIcon: IconButton(
                      onPressed: () => setModalState(() => hidePass = !hidePass),
                      icon: Icon(
                        hidePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: confirmCtrl,
                  enabled: !saving,
                  obscureText: hidePass,
                  decoration: InputDecoration(
                    labelText: s.registerConfirmPassLabel,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: const Icon(Icons.verified_user_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: instaCtrl,
                  enabled: !saving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: InputDecoration(
                    labelText: s.instapayPhoneLabel,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: waCtrl,
                  enabled: !saving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: InputDecoration(
                    labelText: s.managerWhatsappLabel,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: const Icon(Icons.chat_outlined, size: 18),
                  ),
                ),
                if (errMsg != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    errMsg!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.dangerText(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: s.registerSubmitBtn,
                  icon: Icons.check_rounded,
                  loading: saving,
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final apts = int.tryParse(aptsCtrl.text.trim()) ?? 0;
                          final pass = passCtrl.text.trim();
                          final conf = confirmCtrl.text.trim();
                          if (name.isEmpty) {
                            setModalState(() => errMsg = s.registerNameRequiredErr);
                            return;
                          }
                          if (apts < 1 || apts > 50) {
                            setModalState(() => errMsg = s.registerAptsInvalidErr);
                            return;
                          }
                          if (pass.length < 4) {
                            setModalState(() => errMsg = s.errPassTooShort);
                            return;
                          }
                          if (pass != conf) {
                            setModalState(() => errMsg = s.errPassMismatch);
                            return;
                          }

                          setModalState(() {
                            saving = true;
                            errMsg = null;
                          });

                          if (switchIntoCreated) {
                            final res = await cubit.registerNewBuilding(
                              name: name,
                              city: cityCtrl.text.trim(),
                              aptsCount: apts,
                              adminPass: pass,
                              instapayPhone: instaCtrl.text.trim(),
                              managerWhatsapp: waCtrl.text.trim(),
                            );
                            if (res.error != null || res.building == null) {
                              setModalState(() {
                                saving = false;
                                errMsg = res.error ?? s.errSubmitFailed;
                              });
                              return;
                            }
                            result = res.building;
                          } else {
                            final res = await cubit.service.registerBuilding(
                              name: name,
                              city: cityCtrl.text.trim(),
                              aptsCount: apts,
                              adminPass: pass,
                              instapayPhone: instaCtrl.text.trim(),
                              managerWhatsapp: waCtrl.text.trim(),
                            );
                            if (res.error != null || res.building == null) {
                              setModalState(() {
                                saving = false;
                                errMsg = s.errSubmitFailed;
                              });
                              return;
                            }
                            result = res.building;
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future.delayed(const Duration(milliseconds: 350), () {
    nameCtrl.dispose();
    cityCtrl.dispose();
    aptsCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    instaCtrl.dispose();
    waCtrl.dispose();
  });

  return result;
}
