import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../config.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/dialogs/admin_login_dialog.dart';
import '../widgets/dialogs/apartment_payment_dialog.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/copyright_footer.dart';
import '../widgets/home/apartments_grid.dart';
import '../widgets/home/bill_summary_card.dart';
import '../widgets/home/my_apartment_banner.dart';
import '../widgets/home/top_bar.dart';
import '../widgets/home/whatsapp_share_section.dart';

class BuildingHomePage extends StatefulWidget {
  const BuildingHomePage({super.key});

  @override
  State<BuildingHomePage> createState() => _BuildingHomePageState();
}

class _BuildingHomePageState extends State<BuildingHomePage> {
  final ImagePicker _picker = ImagePicker();

  final _waterCtrl = TextEditingController();
  final _elecCtrl = TextEditingController();
  final _elevCtrl = TextEditingController();
  final _cleanCtrl = TextEditingController();
  final _aptsCtrl = TextEditingController();
  final _dueDayCtrl = TextEditingController();

  int? _syncedMonthId;

  @override
  void dispose() {
    _waterCtrl.dispose();
    _elecCtrl.dispose();
    _elevCtrl.dispose();
    _cleanCtrl.dispose();
    _aptsCtrl.dispose();
    _dueDayCtrl.dispose();
    super.dispose();
  }

  void _syncControllersIfNeeded(BuildingState state) {
    final m = state.currentMonth;
    if (m == null) return;
    if (_syncedMonthId != m.id) {
      _syncedMonthId = m.id;
      _waterCtrl.text = m.water.toInt().toString();
      _elecCtrl.text = m.elec.toInt().toString();
      _elevCtrl.text = m.elev.toInt().toString();
      _cleanCtrl.text = m.clean.toInt().toString();
      _aptsCtrl.text = m.aptsCount.toString();
      _dueDayCtrl.text = m.dueDay.toString();
    }
  }

  void _onAdminFieldChanged(BuildingCubit cubit) {
    cubit.updateCurrentMonthFields(
      water: double.tryParse(_waterCtrl.text) ?? 0,
      elec: double.tryParse(_elecCtrl.text) ?? 0,
      elev: double.tryParse(_elevCtrl.text) ?? 0,
      clean: double.tryParse(_cleanCtrl.text) ?? 0,
      aptsCount: int.tryParse(_aptsCtrl.text) ?? 1,
      dueDay: int.tryParse(_dueDayCtrl.text) ?? 0,
    );
  }

  Future<void> _copyWhatsApp(BuildingCubit cubit) async {
    final text = cubit.buildWhatsAppMessage();
    cubit.setCopiedPreview(text);
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (_) {}
  }

  Future<void> _toggleAdminPanel(BuildingCubit cubit, BuildingState state) async {
    if (state.isAdminAuthenticated) {
      cubit.toggleAdminEditMode();
      return;
    }

    if (!AppConfig.isSupabaseConfigured) {
      cubit.openAdmin('admin123');
      return;
    }

    await showAdminLoginDialog(
      context,
      state.s,
      startWithBiometric: false,
      onVerifyPassword: (pass) => cubit.openAdmin(pass, showErrorToast: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuildingCubit, BuildingState>(
      listener: (context, state) {
        _syncControllersIfNeeded(state);
      },
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final m = state.currentMonth;
        final s = state.s;

        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (m == null) {
          final isDark = state.isDarkMode;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 32,
                        color: AppColors.dangerText(isDark),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      s.noNetworkTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.headline.copyWith(
                        fontSize: 17,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      s.noNetworkSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: s.retryBtn,
                      icon: Icons.refresh_rounded,
                      onPressed: () => cubit.loadData(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final billCard = BillSummaryCard(
          cubit: cubit,
          state: state,
          month: m,
          waterCtrl: _waterCtrl,
          elecCtrl: _elecCtrl,
          elevCtrl: _elevCtrl,
          cleanCtrl: _cleanCtrl,
          aptsCtrl: _aptsCtrl,
          dueDayCtrl: _dueDayCtrl,
          onFieldChanged: () => _onAdminFieldChanged(cubit),
        );

        final apartmentsCard = ApartmentsGrid(
          state: state,
          month: m,
          onTapApartment: (aptNum) => showApartmentPaymentDialog(
            context: context,
            cubit: cubit,
            state: state,
            month: m,
            aptNum: aptNum,
            picker: _picker,
          ),
        );

        final myAptBanner = MyApartmentBanner(
          cubit: cubit,
          state: state,
          month: m,
          onTapPay: (aptNum) => showApartmentPaymentDialog(
            context: context,
            cubit: cubit,
            state: state,
            month: m,
            aptNum: aptNum,
            picker: _picker,
          ),
        );

        final apartmentsSection = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            myAptBanner,
            const SizedBox(height: AppSpacing.md),
            apartmentsCard,
          ],
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopDash = constraints.maxWidth >= 900;
            final isWideNav = constraints.maxWidth >= 720;
            final isDark = state.isDarkMode;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [Color(0xFF0A1124), AppColors.darkBg]
                      : const [Color(0xFFEEF2FF), AppColors.lightBg],
                  stops: const [0.0, 0.35],
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktopDash ? 1120 : 600),
                  child: SingleChildScrollView(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      isWideNav ? AppSpacing.xxl : 104,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!AppConfig.isSupabaseConfigured)
                          Container(
                            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card(isDark),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              s.demoBanner,
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.amber : AppColors.amberDarkText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        TopBar(
                          cubit: cubit,
                          state: state,
                          month: m,
                          onToggleAdmin: () => _toggleAdminPanel(cubit, state),
                        ),
                        if (m.hasDueDate && m.unpaidCount > 0) ...[
                          const SizedBox(height: AppSpacing.md),
                          Builder(
                            builder: (_) {
                              final pastDue = m.isPastDue;
                              final bannerColor = pastDue ? AppColors.danger : AppColors.primary;
                              final textColor = pastDue
                                  ? AppColors.dangerText(isDark)
                                  : AppColors.primaryText(isDark);
                              return Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm + 2,
                                ),
                                decoration: BoxDecoration(
                                  color: bannerColor.withValues(alpha: isDark ? 0.14 : 0.09),
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: bannerColor.withValues(alpha: pastDue ? 0.5 : 0.35),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      pastDue
                                          ? Icons.warning_amber_rounded
                                          : Icons.event_available_rounded,
                                      size: 18,
                                      color: textColor,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        pastDue
                                            ? s.dueDatePassedBanner(m.monthNum, m.dueDay)
                                            : s.dueDateBanner(m.monthNum, m.dueDay),
                                        style: AppTypography.label.copyWith(
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (pastDue) ...[
                                      const SizedBox(width: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.danger.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(AppRadius.pill),
                                          border: Border.all(
                                            color: AppColors.danger.withValues(alpha: 0.45),
                                          ),
                                        ),
                                        child: Text(
                                          s.overdueCountPill(m.unpaidCount),
                                          style: AppTypography.caption.copyWith(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.dangerText(isDark),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        if (state.announcement.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm + 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: isDark ? 0.14 : 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: AppColors.amber.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.campaign_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.amber : AppColors.amberDarkText,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    state.announcement.trim(),
                                    style: AppTypography.label.copyWith(
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        if (isDesktopDash)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: billCard),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(flex: 5, child: apartmentsSection),
                            ],
                          )
                        else ...[
                          billCard,
                          const SizedBox(height: AppSpacing.lg),
                          apartmentsSection,
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        WhatsAppShareSection(
                          cubit: cubit,
                          state: state,
                          onCopyWhatsApp: () => _copyWhatsApp(cubit),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CopyrightFooter(isDark: isDark),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
