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
import '../widgets/dialogs/apartment_statement_dialog.dart';
import '../widgets/dialogs/manage_apartments_dialog.dart';
import '../widgets/home/apartments_grid.dart';
import '../widgets/home/bill_summary_card.dart';
import '../widgets/home/my_apartment_banner.dart';
import '../widgets/home/top_bar.dart';

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
  final _forEmergCtrl = TextEditingController();
  final _aptsCtrl = TextEditingController();
  final _baseEmergCtrl = TextEditingController();

  int? _syncedMonthId;
  double? _syncedBaseEmergency;

  @override
  void dispose() {
    _waterCtrl.dispose();
    _elecCtrl.dispose();
    _elevCtrl.dispose();
    _cleanCtrl.dispose();
    _forEmergCtrl.dispose();
    _aptsCtrl.dispose();
    _baseEmergCtrl.dispose();
    super.dispose();
  }

  void _syncControllersIfNeeded(BuildingState state) {
    final m = state.currentMonth;
    if (m == null) return;
    if (_syncedMonthId != m.id || (!state.isAdminOpen && _syncedBaseEmergency != state.baseEmergency)) {
      _syncedMonthId = m.id;
      _syncedBaseEmergency = state.baseEmergency;
      _waterCtrl.text = m.water.toInt().toString();
      _elecCtrl.text = m.elec.toInt().toString();
      _elevCtrl.text = m.elev.toInt().toString();
      _cleanCtrl.text = m.clean.toInt().toString();
      _forEmergCtrl.text = m.forEmerg.toInt().toString();
      _aptsCtrl.text = m.aptsCount.toString();
      _baseEmergCtrl.text = state.baseEmergency.toInt().toString();
    }
  }

  void _onAdminFieldChanged(BuildingCubit cubit) {
    cubit.updateCurrentMonthFields(
      water: double.tryParse(_waterCtrl.text) ?? 0,
      elec: double.tryParse(_elecCtrl.text) ?? 0,
      elev: double.tryParse(_elevCtrl.text) ?? 0,
      clean: double.tryParse(_cleanCtrl.text) ?? 0,
      forEmerg: double.tryParse(_forEmergCtrl.text) ?? 0,
      aptsCount: int.tryParse(_aptsCtrl.text) ?? 1,
      baseEmergency: double.tryParse(_baseEmergCtrl.text) ?? 0,
    );
  }

  Future<void> _copyWhatsApp(BuildingCubit cubit) async {
    final text = cubit.buildWhatsAppMessage();
    await Clipboard.setData(ClipboardData(text: text));
    cubit.setCopiedPreview(text);
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

    final pass = await showAdminLoginDialog(context, state.s);
    if (pass != null && pass.trim().isNotEmpty) {
      cubit.openAdmin(pass.trim());
    }
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

        if (state.loading || m == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final billCard = BillSummaryCard(
          cubit: cubit,
          state: state,
          month: m,
          onCopyWhatsApp: () => _copyWhatsApp(cubit),
          waterCtrl: _waterCtrl,
          elecCtrl: _elecCtrl,
          elevCtrl: _elevCtrl,
          cleanCtrl: _cleanCtrl,
          forEmergCtrl: _forEmergCtrl,
          aptsCtrl: _aptsCtrl,
          baseEmergCtrl: _baseEmergCtrl,
          onFieldChanged: () => _onAdminFieldChanged(cubit),
          onOpenManageApts: () => showManageApartmentsDialog(
            context: context,
            cubit: cubit,
            state: state,
          ),
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
          onTapStatement: (aptNum) => showApartmentStatementDialog(
            context: context,
            state: state,
            aptNum: aptNum,
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
