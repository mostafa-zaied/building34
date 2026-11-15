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
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        feedbackMessage: () => '❌ تعذر تحميل البيانات: $e',
        feedbackIsError: true,
      ));
    }
  }

  void selectMonth(int index) {
    emit(state.copyWith(
      selectedMonthIndex: index,
      copiedPreview: () => null,
    ));
  }

  void openAdmin(String pass) {
    emit(state.copyWith(
      adminPass: pass.trim(),
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
      feedbackMessage: () => err ?? '✅ تم حفظ تعديلات الشهر بنجاح',
      feedbackIsError: err != null,
    ));
  }

  Future<String?> submitPayment({
    required int aptNum,
    required String passcode,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final m = state.currentMonth;
    if (m == null) return 'لا يوجد شهر محدد';
    final err = await _service.submitApartmentPayment(
      month: m,
      aptNum: aptNum,
      passcode: passcode,
      imageBytes: imageBytes,
      fileName: fileName,
    );
    if (err == null) {
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    }
    return err;
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
      feedbackMessage: err != null ? () => err : () => '✅ تم إلغاء الدفع',
      feedbackIsError: err != null,
    ));
  }

  Future<({List<ApartmentInfo>? apartments, String? error})> fetchAdminApartments() async {
    final m = state.currentMonth;
    if (m == null) {
      return (apartments: null, error: 'لا يوجد شهر محدد');
    }
    return _service.fetchAdminApartments(
      adminPass: state.adminPass,
      aptsCount: m.aptsCount,
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
      feedbackMessage: () => firstErr ?? '✅ تم حفظ أسماء وكلمات سر الشقق بنجاح',
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
    final newEmergTotal = (state.baseEmergency + m.forEmerg).toInt();

    if (state.localeCode == 'en') {
      final lines = <String>[
        'Building Expenses — Month ${m.monthNum}:',
        '* Water: ${m.water.toInt()} | Elec: ${m.elec.toInt()} | Elevator: ${m.elev.toInt()} | Cleaning: ${m.clean.toInt()}${m.forEmerg > 0 ? ' | Reserve: ${m.forEmerg.toInt()}' : ''} EGP',
        '* Total Expenses: ${m.totalExpenses.toInt()} EGP',
        '(Divided by ${m.aptsCount} apts = ${m.sharePerApt} EGP/apt)',
        '* Emergency Fund: $newEmergTotal EGP (${state.baseEmergency.toInt()} prev + ${m.forEmerg.toInt()} this month)',
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
        '* Wasser: ${m.water.toInt()} | Strom: ${m.elec.toInt()} | Aufzug: ${m.elev.toInt()} | Reinigung: ${m.clean.toInt()}${m.forEmerg > 0 ? ' | Rücklage: ${m.forEmerg.toInt()}' : ''} EGP',
        '* Gesamtkosten: ${m.totalExpenses.toInt()} EGP',
        '(Geteilt durch ${m.aptsCount} Whg. = ${m.sharePerApt} EGP/Whg.)',
        '* Notfallfonds: $newEmergTotal EGP (${state.baseEmergency.toInt()} vorher + ${m.forEmerg.toInt()} diesen Monat)',
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
      '* مياه: ${m.water.toInt()} ج | كهرباء: ${m.elec.toInt()} ج | أسانسير: ${m.elev.toInt()} ج | منظفات: ${m.clean.toInt()} ج${m.forEmerg > 0 ? ' | للطوارئ: ${m.forEmerg.toInt()} ج' : ''}',
      '* إجمالي المصاريف: ${m.totalExpenses.toInt()} ج',
      '(مقسومة على ${m.aptsCount} شقة = نصيب الشقة ${m.sharePerApt} ج)',
      '* إجمالي صندوق الطوارئ: $newEmergTotal ج (المتاح سابقاً ${state.baseEmergency.toInt()} ج + ${m.forEmerg.toInt()} ج هذا الشهر)',
      '------------------',
      '✅ تم السداد (${paidList.length} من ${m.aptsCount} شقة): ${paidList.isEmpty ? 'لا يوجد بعد' : paidList.map(state.aptLabel).join('، ')}',
    ];
    if (unpaidList.isNotEmpty) {
      lines.add('⏳ متبقي (${unpaidList.length} شقة): ${unpaidList.map(state.aptLabel).join('، ')}');
    }
    return lines.join('\n');
  }
}
