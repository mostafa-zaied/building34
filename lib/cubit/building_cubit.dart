import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/building_models.dart';
import '../services/building_service.dart';
import 'building_state.dart';

class BuildingCubit extends Cubit<BuildingState> {
  final BuildingService _service;

  BuildingCubit(this._service) : super(const BuildingState());

  Future<void> loadData({int? preserveMonthIndex}) async {
    emit(state.copyWith(loading: true));
    try {
      final data = await _service.fetchAll();
      final posts = await _service.fetchFeedbackPosts();
      int targetIdx = preserveMonthIndex ?? state.selectedMonthIndex;
      if (preserveMonthIndex == null && state.months.isEmpty) {
        final novIndex = data.months.indexWhere((m) => m.monthNum == 11);
        targetIdx = novIndex >= 0
            ? novIndex
            : (data.months.isNotEmpty ? data.months.length - 1 : 0);
      }
      if (targetIdx >= data.months.length) {
        targetIdx = data.months.isNotEmpty ? data.months.length - 1 : 0;
      }

      emit(state.copyWith(
        loading: false,
        baseEmergency: data.baseEmergencyFund,
        months: data.months,
        apartmentNames: data.apartmentNames,
        selectedMonthIndex: targetIdx,
        feedbackPosts: posts,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        feedbackMessage: () => state.s.errLoadData('$e'),
        feedbackIsError: true,
      ));
    }
  }

  String _localizeError(String err) {
    final s = state.s;
    if (err.startsWith('err_wrong_apt_pass_hint:')) {
      final hint = err.substring('err_wrong_apt_pass_hint:'.length);
      return s.errWrongAptPassHint(hint);
    }
    switch (err) {
      case 'err_wrong_admin_pass':
      case 'كلمة سر المدير غير صحيحة':
      case 'كلمة سر المسؤول غير صحيحة':
        return s.errWrongAdminPass;
      case 'err_wrong_apt_pass':
      case 'كلمة سر الشقة غير صحيحة':
        return s.errWrongAptPass;
      case 'err_payment_failed':
        return s.errPaymentFailed;
      case 'err_cancel_failed':
        return s.errCancelFailed;
      case 'err_apt_load_failed':
        return s.errAptLoadFailed;
      case 'err_apt_save_failed':
        return s.errAptSaveFailed;
      case 'err_empty_message':
        return s.errEmptyMessage;
      case 'err_submit_failed':
        return s.errSubmitFailed;
      case 'err_delete_failed':
        return s.errDeleteFailed;
      default:
        return err;
    }
  }

  void selectMonth(int index) {
    emit(state.copyWith(
      selectedMonthIndex: index,
      copiedPreview: () => null,
    ));
  }

  void selectNav(int index) {
    emit(state.copyWith(selectedNavIndex: index));
  }

  Future<bool> submitFeedbackPost({
    required String type,
    required String message,
    int? aptNum,
    String? passcode,
  }) async {
    final authorLabel = aptNum != null ? state.aptLabel(aptNum) : null;
    final err = await _service.submitFeedbackPost(
      type: type,
      message: message,
      aptNum: aptNum,
      passcode: passcode,
      authorLabel: authorLabel,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    final posts = await _service.fetchFeedbackPosts();
    emit(state.copyWith(
      feedbackPosts: posts,
      feedbackMessage: () => state.s.postAddedToast,
      feedbackIsError: false,
    ));
    return true;
  }

  Future<void> deleteFeedbackPost(String id) async {
    if (!state.isAdminOpen) return;
    final err = await _service.deleteFeedbackPost(
      adminPass: state.adminPass,
      id: id,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return;
    }
    final posts = await _service.fetchFeedbackPosts();
    emit(state.copyWith(feedbackPosts: posts));
  }

  Future<void> openAdmin(String pass) async {
    final clean = pass.trim();
    final err = await _service.verifyAdminPass(clean);
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
        isAdminOpen: false,
      ));
      return;
    }
    emit(state.copyWith(
      adminPass: clean,
      isAdminOpen: true,
    ));
  }

  void closeAdmin() {
    emit(state.copyWith(isAdminOpen: false));
  }

  void setHighlight(String? key) {
    emit(state.copyWith(highlightedKey: () => key));
  }

  void setLocale(String localeCode) {
    emit(state.copyWith(localeCode: localeCode, copiedPreview: () => null));
  }

  void toggleTheme() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void clearFeedback() {
    emit(state.copyWith(feedbackMessage: () => null));
  }

  void setCopiedPreview(String? text) {
    emit(state.copyWith(
      copiedPreview: () => text,
      feedbackMessage: text != null ? () => state.s.copiedToast : null,
      feedbackIsError: false,
    ));
  }

  void updateCurrentMonthFields({
    required double water,
    required double elec,
    required double elev,
    required double clean,
    required double forEmerg,
    required int aptsCount,
    required double baseEmergency,
  }) {
    final m = state.currentMonth;
    if (m == null) return;
    m.water = water;
    m.elec = elec;
    m.elev = elev;
    m.clean = clean;
    m.forEmerg = forEmerg;
    m.aptsCount = aptsCount.clamp(1, 50);

    emit(state.copyWith(
      baseEmergency: baseEmergency,
      months: List<MonthBill>.from(state.months),
    ));
  }

  Future<void> saveAdminChanges() async {
    final m = state.currentMonth;
    if (m == null) return;
    final err = await _service.updateMonthAsAdmin(
      adminPass: state.adminPass,
      month: m,
      baseEmergency: state.baseEmergency,
    );
    emit(state.copyWith(
      feedbackMessage: () => err != null ? '❌ ${_localizeError(err)}' : state.s.monthSavedToast,
      feedbackIsError: err != null,
    ));
  }

  Future<void> addNextMonth() async {
    if (!state.isAdminOpen) return;
    final err = await _service.addNextMonthAsAdmin(state.adminPass);
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return;
    }
    await loadData(preserveMonthIndex: state.months.length);
    emit(state.copyWith(
      feedbackMessage: () => state.s.monthAddedToast,
      feedbackIsError: false,
    ));
  }

  Future<String?> submitPayment({
    required int aptNum,
    required String passcode,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final m = state.currentMonth;
    if (m == null) return state.s.errNoMonth;
    final err = await _service.submitApartmentPayment(
      month: m,
      aptNum: aptNum,
      passcode: passcode,
      imageBytes: imageBytes,
      fileName: fileName,
    );
    if (err == null) {
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      return null;
    }
    return _localizeError(err);
  }

  Future<void> cancelPayment(int aptNum) async {
    final m = state.currentMonth;
    if (m == null) return;
    final err = await _service.cancelPaymentAsAdmin(
      adminPass: state.adminPass,
      month: m,
      aptNum: aptNum,
    );
    emit(state.copyWith(
      months: List<MonthBill>.from(state.months),
      feedbackMessage: () => err != null ? '❌ ${_localizeError(err)}' : state.s.paymentCancelledToast,
      feedbackIsError: err != null,
    ));
  }

  Future<({List<ApartmentInfo>? apartments, String? error})> fetchAdminApartments() async {
    final m = state.currentMonth;
    if (m == null) {
      return (apartments: null, error: state.s.errNoMonth);
    }
    final res = await _service.fetchAdminApartments(
      adminPass: state.adminPass,
      aptsCount: m.aptsCount,
    );
    return (
      apartments: res.apartments,
      error: res.error != null ? _localizeError(res.error!) : null,
    );
  }

  Future<void> saveAllApartments({
    required List<ApartmentInfo> apts,
    required Map<int, String> names,
    required Map<int, String> passcodes,
  }) async {
    String? firstErr;
    for (final a in apts) {
      final err = await _service.updateApartmentAsAdmin(
        adminPass: state.adminPass,
        aptNum: a.aptNum,
        displayName: names[a.aptNum] ?? '',
        passcode: passcodes[a.aptNum] ?? '',
      );
      if (err != null) {
        firstErr = err;
        break;
      }
    }
    await loadData(preserveMonthIndex: state.selectedMonthIndex);
    emit(state.copyWith(
      feedbackMessage: () => firstErr != null ? '❌ ${_localizeError(firstErr)}' : state.s.aptsSavedToast,
      feedbackIsError: firstErr != null,
    ));
  }

  String buildWhatsAppMessage() {
    final m = state.currentMonth;
    if (m == null) return '';

    final paidList = <int>[];
    final unpaidList = <int>[];
    for (int i = 1; i <= m.aptsCount; i++) {
      if (m.payments.containsKey(i)) {
        paidList.add(i);
      } else {
        unpaidList.add(i);
      }
    }
    if (state.localeCode == 'en') {
      final lines = <String>[
        'Building Expenses — Month ${m.monthNum}:',
        '------------------',
        '✅ Paid (${paidList.length}/${m.aptsCount}): ${paidList.isEmpty ? 'None yet' : paidList.map(state.aptLabel).join(', ')}',
      ];
      if (unpaidList.isNotEmpty) {
        lines.add('⏳ Remaining (${unpaidList.length}): ${unpaidList.map(state.aptLabel).join(', ')}');
      }
      return lines.join('\n');
    }

    if (state.localeCode == 'de') {
      final lines = <String>[
        'Hauskosten — Monat ${m.monthNum}:',
        '------------------',
        '✅ Bezahlt (${paidList.length}/${m.aptsCount}): ${paidList.isEmpty ? 'Noch keine' : paidList.map(state.aptLabel).join(', ')}',
      ];
      if (unpaidList.isNotEmpty) {
        lines.add('⏳ Offen (${unpaidList.length}): ${unpaidList.map(state.aptLabel).join(', ')}');
      }
      return lines.join('\n');
    }

    final lines = <String>[
      'مصاريف العمارة لشهر ${m.monthNum}:',
      '------------------',
      '✅ تم السداد (${paidList.length} من ${m.aptsCount} شقة): ${paidList.isEmpty ? 'لا يوجد بعد' : paidList.map(state.aptLabel).join('، ')}',
    ];
    if (unpaidList.isNotEmpty) {
      lines.add('⏳ متبقي (${unpaidList.length} شقة): ${unpaidList.map(state.aptLabel).join('، ')}');
    }
    return lines.join('\n');
  }
}
