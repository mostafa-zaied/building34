import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../config.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/dialogs/admin_login_dialog.dart';
import '../widgets/dialogs/apartment_payment_dialog.dart';
import '../widgets/dialogs/manage_apartments_dialog.dart';
import '../widgets/home/apartments_grid.dart';
import '../widgets/home/bill_summary_card.dart';
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
    if (state.isAdminOpen) {
      cubit.closeAdmin();
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
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: state.feedbackIsError ? Colors.redAccent : const Color(0xFF22C55E),
            ),
          );
          context.read<BuildingCubit>().clearFeedback();
        }
      },
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final m = state.currentMonth;
        final s = state.s;

        return Scaffold(
          body: SafeArea(
            child: state.loading || m == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!AppConfig.isSupabaseConfigured)
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFACC15).withValues(alpha: 0.6)),
                                ),
                                child: Text(
                                  s.demoBanner,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: state.isDarkMode ? const Color(0xFFFACC15) : const Color(0xFFB45309),
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
                            const SizedBox(height: 12),
                            BillSummaryCard(
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
                            ),
                            const SizedBox(height: 12),
                            ApartmentsGrid(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
