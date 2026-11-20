import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/push_notifications.dart';
import '../models/building_models.dart';
import '../services/building_service.dart';
import 'building_state.dart';

class BuildingCubit extends Cubit<BuildingState> {
  final BuildingService _service;
  bool _viewRecordedThisSession = false;
  String _visitorId = '';

  BuildingCubit(this._service) : super(const BuildingState());

  Future<T> _withBusy<T>(Future<T> Function() action) async {
    emit(state.copyWith(busy: true));
    try {
      return await action();
    } finally {
      emit(state.copyWith(busy: false));
    }
  }

  Future<void> loadData({int? preserveMonthIndex}) async {
    emit(state.copyWith(loading: true));
    try {
      late final BuildingDataState data;
      try {
        data = await _service.fetchAll().timeout(const Duration(seconds: 15));
      } catch (_) {
        // Silent 1-time auto-retry for transient server/DNS blips
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        data = await _service.fetchAll().timeout(const Duration(seconds: 15));
      }
      final posts = await _service.fetchFeedbackPosts().timeout(const Duration(seconds: 12));
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

      int? savedAptNum = state.myAptNum;
      String? savedAptPass = state.savedAptPass;
      bool isAdminAuthed = state.isAdminAuthenticated;
      String adminPass = state.adminPass;
      String visitorId = _visitorId;
      Set<String> readNotifIds = state.readNotificationIds;
      try {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(milliseconds: 250),
        );
        savedAptNum = prefs.getInt('my_apt_num');
        savedAptPass = savedAptNum != null ? prefs.getString('my_apt_pass') : null;
        final savedRead = prefs.getStringList('read_notif_ids');
        if (savedRead != null) {
          readNotifIds = savedRead.toSet();
        }
        visitorId = prefs.getString('visitor_id') ?? '';
        if (visitorId.isEmpty) {
          final rnd = Random().nextInt(999999);
          visitorId = 'v_${DateTime.now().microsecondsSinceEpoch}_$rnd';
          await prefs.setString('visitor_id', visitorId);
        }
        final savedAdminPass = prefs.getString('admin_pass');
        if (savedAdminPass != null && savedAdminPass.isNotEmpty) {
          final err = await _service.verifyAdminPass(savedAdminPass);
          if (err == null) {
            isAdminAuthed = true;
            adminPass = savedAdminPass;
          } else {
            await prefs.remove('admin_pass');
            isAdminAuthed = false;
          }
        }
      } catch (_) {}

      _visitorId = visitorId.isNotEmpty
          ? visitorId
          : 'v_${DateTime.now().microsecondsSinceEpoch}';
      if (!_viewRecordedThisSession) {
        _viewRecordedThisSession = true;
        unawaited(_service.recordPageView(_visitorId));
      }

      PageViewStats? viewStats = state.pageViewStats;
      if (isAdminAuthed) {
        viewStats = await _service.fetchPageViewStatsAsAdmin(adminPass);
      }
      final notifs = await _service
          .fetchAppNotifications(adminPass: isAdminAuthed ? adminPass : null)
          .timeout(const Duration(seconds: 10), onTimeout: () => state.notifications);

      emit(state.copyWith(
        loading: false,
        isAdminAuthenticated: isAdminAuthed,
        adminPass: adminPass,
        baseEmergency: data.baseEmergencyFund,
        months: data.months,
        apartmentNames: data.apartmentNames,
        selectedMonthIndex: targetIdx,
        feedbackPosts: posts,
        myAptNum: () => savedAptNum,
        savedAptPass: () => savedAptPass,
        announcement: data.announcement,
        emergencyTransactions: data.emergencyTransactions,
        pageViewStats: () => viewStats,
        requireAptPassOnOpen: data.requireAptPassOnOpen,
        buildingContacts: data.buildingContacts,
        apartmentHasPasscode: data.apartmentHasPasscode,
        notifications: notifs,
        readNotificationIds: readNotifIds,
      ));
      unawaited(syncPushTokenIfGranted());
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
      case 'err_cannot_delete_last_month':
        return s.errCannotDeleteLastMonth;
      case 'err_pass_too_short':
        return s.errPassTooShort;
      case 'err_pass_already_set':
        return s.errPassAlreadySet;
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
      if (aptNum != null &&
          aptNum == state.myAptNum &&
          (err == 'err_wrong_apt_pass' || err.startsWith('err_wrong_apt_pass_hint:'))) {
        await _clearSavedAptPass();
      }
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    if (aptNum != null && passcode != null && passcode.trim().isNotEmpty) {
      await _saveAptSession(aptNum, passcode.trim());
    }
    final posts = await _service.fetchFeedbackPosts();
    emit(state.copyWith(
      feedbackPosts: posts,
      feedbackMessage: () => state.s.postAddedToast,
      feedbackIsError: false,
    ));
    // Auto-notify admins (fire-and-forget)
    final preview = message.trim();
    final senderPrefix = authorLabel != null ? '$authorLabel: ' : '';
    _triggerAutoPush(
      title: state.s.pushAutoFeedbackTitle,
      body: '$senderPrefix$preview',
      audience: 'admins',
      eventType: 'feedback_submitted',
    );
    return true;
  }

  Future<void> deleteFeedbackPost(String id) async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
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
    });
  }

  Future<void> openAdmin(String pass) async {
    await _withBusy(() async {
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
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_pass', clean);
      } catch (_) {}
      final viewStats = await _service.fetchPageViewStatsAsAdmin(clean);
      final notifs = await _service.fetchAppNotifications(adminPass: clean);
      emit(state.copyWith(
        adminPass: clean,
        isAdminAuthenticated: true,
        isAdminOpen: true,
        pageViewStats: () => viewStats,
        notifications: notifs,
      ));
      unawaited(syncPushTokenIfGranted());
    });
  }

  void toggleAdminEditMode() {
    if (!state.isAdminAuthenticated) return;
    final nextOpen = !state.isAdminOpen;
    emit(state.copyWith(isAdminOpen: nextOpen));
    if (nextOpen) {
      unawaited(refreshPageViewStats(showBusy: false));
    }
  }

  Future<void> refreshPageViewStats({bool showBusy = true}) async {
    if (!state.isAdminAuthenticated) return;
    Future<void> run() async {
      final stats = await _service.fetchPageViewStatsAsAdmin(state.adminPass);
      if (stats != null) {
        emit(state.copyWith(pageViewStats: () => stats));
      }
    }

    if (showBusy) {
      await _withBusy(run);
    } else {
      await run();
    }
  }

  Future<void> setRequireAptPassOnOpen(bool enabled) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final prev = state.requireAptPassOnOpen;
      emit(state.copyWith(requireAptPassOnOpen: enabled));
      final err = await _service.setRequireAptPassOnOpenAsAdmin(
        adminPass: state.adminPass,
        enabled: enabled,
      );
      if (err != null) {
        emit(state.copyWith(
          requireAptPassOnOpen: prev,
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
      }
    });
  }

  void closeAdmin() {
    emit(state.copyWith(isAdminOpen: false));
  }

  Future<void> logoutAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_pass');
    } catch (_) {}
    final notifs = await _service.fetchAppNotifications();
    emit(state.copyWith(
      isAdminAuthenticated: false,
      isAdminOpen: false,
      pageViewStats: () => null,
      notifications: notifs,
    ));
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
    await _withBusy(() async {
      final err = await _service.updateMonthAsAdmin(
        adminPass: state.adminPass,
        month: m,
        baseEmergency: state.baseEmergency,
      );
      emit(state.copyWith(
        feedbackMessage: () => err != null ? '❌ ${_localizeError(err)}' : state.s.monthSavedToast,
        feedbackIsError: err != null,
      ));
    });
  }

  Future<void> addNextMonth() async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
      final err = await _service.addNextMonthAsAdmin(state.adminPass);
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.months.length);
      final added = state.currentMonth;
      final msg = added != null
          ? state.s.monthAddedNamedToast(
              localizedMonthName(added.monthNum, state.localeCode == 'ar'),
              added.monthNum,
              added.yearNum,
            )
          : state.s.monthAddedToast;
      emit(state.copyWith(
        feedbackMessage: () => msg,
        feedbackIsError: false,
      ));
      if (added != null) {
        final monthLabel =
            '${localizedMonthName(added.monthNum, state.localeCode == 'ar')} (${added.monthNum}/${added.yearNum})';
        _triggerAutoPush(
          title: state.s.pushAutoNewMonthTitle,
          body: state.s.pushAutoNewMonthBody(monthLabel),
          audience: 'all',
          adminPass: state.adminPass,
          eventType: 'new_month',
        );
      }
    });
  }

  Future<void> deleteCurrentMonth() async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.deleteMonthAsAdmin(
        adminPass: state.adminPass,
        monthId: m.id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final nextIdx = state.selectedMonthIndex > 0 ? state.selectedMonthIndex - 1 : 0;
      await loadData(preserveMonthIndex: nextIdx);
      emit(state.copyWith(
        feedbackMessage: () => state.s.monthDeletedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<String?> submitPayment({
    required int aptNum,
    required String passcode,
    Uint8List? imageBytes,
    String? fileName,
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
      await _saveAptSession(aptNum, passcode.trim());
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      // Auto-notify admins that an apartment uploaded a payment receipt
      _triggerAutoPush(
        title: state.s.pushAutoPaymentTitle,
        body: state.s.pushAutoPaymentBody(state.aptLabel(aptNum)),
        audience: 'admins',
        eventType: 'payment_uploaded',
      );
      return null;
    }
    if (aptNum == state.myAptNum &&
        (err == 'err_wrong_apt_pass' || err.startsWith('err_wrong_apt_pass_hint:'))) {
      await _clearSavedAptPass();
    }
    return _localizeError(err);
  }

  Future<void> cancelPayment(int aptNum) async {
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
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
    });
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
      if (m.extraCharges.isNotEmpty) {
        lines.add('➕ Extra charges:');
        for (final e in m.extraCharges) {
          lines.add('• ${state.aptLabel(e.aptNum)}: +${e.amount.toInt()} EGP (${e.reason})');
        }
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
    if (m.extraCharges.isNotEmpty) {
      lines.add('➕ رسوم إضافية:');
      for (final e in m.extraCharges) {
        lines.add('• ${state.aptLabel(e.aptNum)}: +${e.amount.toInt()} ج (${e.reason})');
      }
    }
    return lines.join('\n');
  }

  Future<String?> unlockApartment(int aptNum, String passcode) async {
    final err = await _service.verifyApartmentPasscode(aptNum, passcode);
    if (err != null) {
      return _localizeError(err);
    }
    await _saveAptSession(aptNum, passcode.trim());
    return null;
  }

  Future<String?> setInitialApartmentPasscode(int aptNum, String passcode) async {
    final err = await _service.setInitialApartmentPasscode(aptNum, passcode);
    if (err != null) {
      return _localizeError(err);
    }
    final nextMap = Map<int, bool>.from(state.apartmentHasPasscode);
    nextMap[aptNum] = true;
    emit(state.copyWith(apartmentHasPasscode: nextMap));
    await _saveAptSession(aptNum, passcode.trim());
    return null;
  }

  Future<void> resetApartmentPasscode(int aptNum) async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
      final err = await _service.resetApartmentPasscodeAsAdmin(
        adminPass: state.adminPass,
        aptNum: aptNum,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final nextMap = Map<int, bool>.from(state.apartmentHasPasscode);
      nextMap[aptNum] = false;
      emit(state.copyWith(
        apartmentHasPasscode: nextMap,
        feedbackMessage: () => state.s.monthSavedToast,
        feedbackIsError: false,
      ));
      if (state.myAptNum == aptNum) {
        await _clearSavedAptPass();
      }
    });
  }

  Future<bool> resetAllApartmentPasscodes() async {
    if (!state.isAdminOpen) return false;
    return _withBusy(() async {
      final err = await _service.resetAllApartmentPasscodesAsAdmin(
        state.adminPass,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      await _clearSavedAptPass();
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.allPasswordsResetToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<void> _saveAptSession(int aptNum, String passcode) async {
    emit(state.copyWith(
      myAptNum: () => aptNum,
      savedAptPass: () => passcode,
    ));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('my_apt_num', aptNum);
      await prefs.setString('my_apt_pass', passcode);
    } catch (_) {}
  }

  Future<void> _clearSavedAptPass() async {
    emit(state.copyWith(savedAptPass: () => null));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('my_apt_pass');
    } catch (_) {}
  }

  Future<void> setMyApt(int? aptNum) async {
    final changed = aptNum != state.myAptNum;
    emit(state.copyWith(
      myAptNum: () => aptNum,
      savedAptPass: changed ? () => null : null,
    ));
    try {
      final prefs = await SharedPreferences.getInstance();
      if (aptNum == null) {
        await prefs.remove('my_apt_num');
        await prefs.remove('my_apt_pass');
      } else {
        await prefs.setInt('my_apt_num', aptNum);
        if (changed) {
          await prefs.remove('my_apt_pass');
        }
      }
    } catch (_) {}
  }

  Future<void> saveAnnouncement(String text) async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
      final err = await _service.saveAnnouncement(
        adminPass: state.adminPass,
        announcement: text,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      emit(state.copyWith(
        announcement: text.trim(),
        feedbackMessage: () => state.s.monthSavedToast,
        feedbackIsError: false,
      ));
      if (text.trim().isNotEmpty) {
        _triggerAutoPush(
          title: state.s.pushAutoAnnouncementTitle,
          body: text.trim(),
          audience: 'all',
          adminPass: state.adminPass,
          eventType: 'announcement',
        );
      }
    });
  }

  /// Requests browser push notification permission and registers the FCM token.
  Future<bool> enablePushNotifications() async {
    var ok = false;
    await _withBusy(() async {
      final token = await requestPushToken(silentOnly: false);
      if (token == null || token.isEmpty) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${state.s.pushBlockedToast}',
          feedbackIsError: true,
        ));
        return;
      }
      final saved = await _service.registerPushToken(
        token: token,
        aptNum: state.myAptNum,
        isAdmin: state.isAdminAuthenticated,
      );
      ok = saved;
      emit(state.copyWith(
        feedbackMessage: () => saved
            ? state.s.pushEnabledToast
            : '❌ ${state.s.pushBlockedToast}',
        feedbackIsError: !saved,
      ));
    });
    return ok;
  }

  /// Automatically requests push permission on app open (or syncs if already granted)
  /// and registers the device token in Supabase.
  Future<void> syncPushTokenIfGranted() async {
    try {
      final token = await autoPromptPushTokenOnOpen();
      if (token == null || token.isEmpty) return;
      await _service.registerPushToken(
        token: token,
        aptNum: state.myAptNum,
        isAdmin: state.isAdminAuthenticated,
      );
      if (!isClosed) {
        emit(state.copyWith());
      }
    } catch (_) {}
  }

  /// Fire-and-forget automatic push notification trigger.
  void _triggerAutoPush({
    required String title,
    required String body,
    required String audience,
    String? adminPass,
    String? eventType,
  }) {
    _service
        .sendPushNotification(
          title: title,
          body: body,
          audience: audience,
          adminPass: adminPass,
          eventType: eventType,
        )
        .then((_) => refreshNotifications())
        .catchError((_) {});
  }

  Future<void> refreshNotifications() async {
    try {
      final notifs = await _service.fetchAppNotifications(
        adminPass: state.isAdminAuthenticated ? state.adminPass : null,
      );
      if (!isClosed) {
        emit(state.copyWith(notifications: notifs));
      }
    } catch (_) {}
  }

  Future<void> markNotificationRead(String id) async {
    if (state.readNotificationIds.contains(id)) return;
    final updated = {...state.readNotificationIds, id};
    emit(state.copyWith(readNotificationIds: updated));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notif_ids', updated.toList());
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    if (state.notifications.isEmpty) return;
    final updated = {
      ...state.readNotificationIds,
      ...state.notifications.map((n) => n.id),
    };
    emit(state.copyWith(readNotificationIds: updated));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notif_ids', updated.toList());
    } catch (_) {}
  }

  Future<bool> deleteAppNotification(String id) async {
    if (!state.isAdminAuthenticated) return false;
    final err = await _service.deleteAppNotificationAsAdmin(
      adminPass: state.adminPass,
      id: id,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    final notifs = await _service.fetchAppNotifications(
      adminPass: state.adminPass,
    );
    emit(state.copyWith(notifications: notifs));
    return true;
  }

  /// Sends a manual broadcast notification from Admin Settings.
  /// Defaults to `adminsOnly: true` so the admin can safely test on their own device first.
  Future<bool> sendManualPushNotification({
    required String title,
    required String body,
    bool adminsOnly = true,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    final cleanTitle = title.trim();
    final cleanBody = body.trim();
    if (cleanTitle.isEmpty || cleanBody.isEmpty) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errPushFieldsRequired}',
        feedbackIsError: true,
      ));
      return false;
    }

    var success = false;
    await _withBusy(() async {
      final res = await _service.sendPushNotification(
        title: cleanTitle,
        body: cleanBody,
        audience: adminsOnly ? 'admins' : 'all',
        adminPass: state.adminPass,
        eventType: adminsOnly ? 'admin_test' : 'manual_broadcast',
      );
      if (res.notConfigured) {
        emit(state.copyWith(
          feedbackMessage: () => 'ℹ️ ${state.s.pushNotConfiguredToast}',
          feedbackIsError: false,
        ));
        return;
      }
      if (!res.ok) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${state.s.pushSendFailedToast}',
          feedbackIsError: true,
        ));
        return;
      }
      success = true;
      final notifs = await _service.fetchAppNotifications(
        adminPass: state.adminPass,
      );
      emit(state.copyWith(
        notifications: notifs,
        feedbackMessage: () => res.hasRecipients
            ? state.s.pushSentSuccessToast
            : state.s.pushNoDevicesToast,
        feedbackIsError: false,
      ));
    });
    return success;
  }

  Future<bool> addEmergencyTransaction(double amount, String reason) async {
    if (!state.isAdminOpen) return false;
    final err = await _service.addEmergencyTransaction(
      adminPass: state.adminPass,
      amount: amount,
      reason: reason,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    await loadData(preserveMonthIndex: state.selectedMonthIndex);
    return true;
  }

  Future<void> deleteEmergencyTransaction(String id) async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
      final err = await _service.deleteEmergencyTransaction(
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
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    });
  }

  Future<bool> updateFeedbackStatus({
    required String id,
    required String status,
    String? adminReply,
  }) async {
    if (!state.isAdminOpen) return false;
    return _withBusy(() async {
      final err = await _service.updateFeedbackPostStatus(
        adminPass: state.adminPass,
        id: id,
        status: status,
        adminReply: adminReply,
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
        feedbackMessage: () => state.s.monthSavedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<bool> addExtraCharges({
    required List<int> aptNums,
    required double amount,
    required String reason,
  }) async {
    if (!state.isAdminOpen) return false;
    final m = state.currentMonth;
    if (m == null) return false;
    final err = await _service.addExtraChargesAsAdmin(
      adminPass: state.adminPass,
      monthId: m.id,
      aptNums: aptNums,
      amount: amount,
      reason: reason,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    await loadData(preserveMonthIndex: state.selectedMonthIndex);
    emit(state.copyWith(
      feedbackMessage: () => state.s.extraChargeAddedToast,
      feedbackIsError: false,
    ));
    return true;
  }

  Future<void> deleteExtraCharge(String id) async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.deleteExtraChargeAsAdmin(
        adminPass: state.adminPass,
        monthId: m.id,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    });
  }

  Future<void> setUtilityReceipt({
    required String utility,
    Uint8List? imageBytes,
  }) async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.setUtilityReceiptAsAdmin(
        adminPass: state.adminPass,
        month: m,
        utility: utility,
        imageBytes: imageBytes,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => imageBytes != null
            ? state.s.utilityReceiptSavedToast
            : state.s.utilityReceiptRemovedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<bool> addBuildingContact({
    required String name,
    required String roleDesc,
    required String phone,
  }) async {
    return _withBusy(() async {
      final err = await _service.addBuildingContact(
        name: name,
        roleDesc: roleDesc,
        phone: phone,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.contactAddedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<void> deleteBuildingContact(String id) async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
      final err = await _service.deleteBuildingContactAsAdmin(
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
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    });
  }

  Future<void> deleteAllExtraCharges() async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.deleteAllExtraChargesAsAdmin(
        adminPass: state.adminPass,
        monthId: m.id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    });
  }
}
