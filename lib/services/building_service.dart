import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../models/building_models.dart';

class BuildingDataState {
  final double baseEmergencyFund;
  final List<MonthBill> months;
  final Map<int, String> apartmentNames;
  final String announcement;
  final List<EmergencyTransaction> emergencyTransactions;
  final bool requireAptPassOnOpen;
  final List<BuildingContact> buildingContacts;
  final Map<int, bool> apartmentHasPasscode;

  BuildingDataState({
    required this.baseEmergencyFund,
    required this.months,
    required this.apartmentNames,
    this.announcement = '',
    this.emergencyTransactions = const [],
    this.requireAptPassOnOpen = true,
    this.buildingContacts = const [],
    this.apartmentHasPasscode = const {},
  });
}

class BuildingService {
  bool get _useSupabase {
    if (!AppConfig.isSupabaseConfigured) return false;
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Local Demo state (used when Supabase keys are not yet configured or in tests)
  static double _demoBaseEmergency = 2550;
  static String _demoAnnouncement = '';
  static bool _demoRequireAptPassOnOpen = true;
  static final List<EmergencyTransaction> _demoEmergencyTx = [];
  static final List<FeedbackPost> _demoFeedbackPosts = [];
  static final List<({String visitorId, DateTime createdAt})> _demoPageViews = [];
  static final List<BuildingContact> _demoContacts = [
    BuildingContact(
      id: '1',
      name: 'طوارئ الغاز الطبيعي',
      roleDesc: 'الخط الساخن 24 ساعة',
      phone: '129',
      createdAt: DateTime(2026, 11, 1),
    ),
    BuildingContact(
      id: '2',
      name: 'طوارئ الكهرباء',
      roleDesc: 'الخط الساخن للأعطال',
      phone: '121',
      createdAt: DateTime(2026, 11, 1),
    ),
  ];
  static const List<String> _defaultResidentNames = [
    'أستاذ حازم',
    'د. أبو بكر',
    'أستاذ مصطفى بركة',
    'أستاذ محمد مجدي',
    'أستاذ مروان',
    'أستاذة مروة',
    'أستاذ علاء',
    'د. أحمد خطاب',
    'أستاذ أحمد ياسر',
    'م. مصطفى',
    'أستاذ محمد جمال',
    'م. شيماء',
    'أستاذ معتز',
  ];

  static final Map<int, ApartmentInfo> _demoApartments = {
    for (int i = 1; i <= 30; i++)
      i: ApartmentInfo(
        aptNum: i,
        displayName: i <= _defaultResidentNames.length ? _defaultResidentNames[i - 1] : '',
        passcode: '${1000 + i}',
      ),
  };
  static final List<MonthBill> _demoMonths = [
    MonthBill(id: 7, monthNum: 7, yearNum: 2026, water: 1080, elec: 1500, elev: 400, clean: 240, forEmerg: 0, aptsCount: 13, payments: _archivedPayments(7)),
    MonthBill(id: 8, monthNum: 8, yearNum: 2026, water: 1100, elec: 1590, elev: 400, clean: 240, forEmerg: 50, aptsCount: 13, payments: _archivedPayments(8)),
    MonthBill(id: 9, monthNum: 9, yearNum: 2026, water: 1150, elec: 1620, elev: 400, clean: 240, forEmerg: 100, aptsCount: 13, payments: _archivedPayments(9)),
    MonthBill(id: 10, monthNum: 10, yearNum: 2026, water: 1210, elec: 1700, elev: 400, clean: 240, forEmerg: 90, aptsCount: 13, payments: _archivedPayments(10)),
    MonthBill(
      id: 11,
      monthNum: 11,
      yearNum: 2026,
      water: 1281,
      elec: 1803,
      elev: 400,
      clean: 240,
      forEmerg: 176,
      aptsCount: 13,
      payments: {
        1: PaymentRecord(aptNum: 1, fileName: 'InstaPay_Apt1.jpg', paidAt: DateTime(2026, 11, 14, 20, 15)),
        3: PaymentRecord(aptNum: 3, fileName: 'InstaPay_Apt3.jpg', paidAt: DateTime(2026, 11, 15, 18, 40)),
      },
    ),
    MonthBill(id: 12, monthNum: 12, yearNum: 2026, water: 0, elec: 0, elev: 400, clean: 240, forEmerg: 0, aptsCount: 13),
  ];

  static Map<int, PaymentRecord> _archivedPayments(int monthNum) {
    return {
      for (int i = 1; i <= 13; i++)
        i: PaymentRecord(aptNum: i, fileName: 'مؤرشف.jpg', paidAt: DateTime(2026, monthNum, 10)),
    };
  }

  Future<BuildingDataState> fetchAll() async {
    if (!_useSupabase) {
      return BuildingDataState(
        baseEmergencyFund: _demoBaseEmergency,
        months: _demoMonths,
        apartmentNames: {
          for (final entry in _demoApartments.entries)
            if (entry.value.displayName.trim().isNotEmpty)
              entry.key: entry.value.displayName.trim(),
        },
        announcement: _demoAnnouncement,
        emergencyTransactions: List<EmergencyTransaction>.from(_demoEmergencyTx),
        requireAptPassOnOpen: _demoRequireAptPassOnOpen,
        buildingContacts: List<BuildingContact>.from(_demoContacts),
        apartmentHasPasscode: {
          for (final entry in _demoApartments.entries)
            entry.key: entry.value.passcode.trim().isNotEmpty,
        },
      );
    }

    final client = Supabase.instance.client;
    try {
      await client.rpc('ensure_current_month');
    } catch (_) {
      // Ignore if function not yet deployed
    }
    final baseEmergResp = await client.rpc('get_base_emergency_fund');
    final baseEmerg = (baseEmergResp as num?)?.toDouble() ?? 2550;

    final aptNamesMap = <int, String>{};
    try {
      final aptRows = await client.rpc('get_apartment_names');
      if (aptRows is List) {
        for (final r in aptRows) {
          final num = r['apt_num'] as int;
          final name = (r['display_name'] as String?)?.trim() ?? '';
          if (name.isNotEmpty) {
            aptNamesMap[num] = name;
          }
        }
      }
    } catch (_) {
      // Fallback gracefully if get_apartment_names RPC hasn't been created yet
    }

    final monthsRows = await client
        .from('months')
        .select()
        .order('year_num', ascending: true)
        .order('month_num', ascending: true);

    final paymentRows = await client.from('payments').select();

    final monthsMap = <int, MonthBill>{};
    for (final row in monthsRows) {
      final bill = MonthBill.fromJson(row);
      monthsMap[bill.id] = bill;
    }

    for (final pRow in paymentRows) {
      final monthId = pRow['month_id'] as int;
      final record = PaymentRecord.fromJson(pRow);
      monthsMap[monthId]?.payments[record.aptNum] = record;
    }

    String announcement = '';
    try {
      final annResp = await client.rpc('get_announcement');
      announcement = (annResp as String?) ?? '';
    } catch (_) {
      try {
        final settingsRows = await client.from('building_settings').select('announcement').limit(1);
        if (settingsRows.isNotEmpty) {
          announcement = (settingsRows.first['announcement'] as String?) ?? '';
        }
      } catch (_) {}
    }

    var emergencyTx = <EmergencyTransaction>[];
    try {
      final txRows = await client
          .from('emergency_transactions')
          .select()
          .order('created_at', ascending: false);
      emergencyTx = (txRows as List)
          .map((r) => EmergencyTransaction.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {
      // Fallback if emergency_transactions table hasn't been created yet
    }

    try {
      final extraRows = await client
          .from('apartment_extra_charges')
          .select()
          .order('created_at', ascending: false);
      for (final row in (extraRows as List)) {
        final charge = ApartmentExtraCharge.fromJson(Map<String, dynamic>.from(row as Map));
        monthsMap[charge.monthId]?.extraCharges.add(charge);
      }
    } catch (_) {}

    bool requireAptPassOnOpen = true;
    try {
      final resp = await client.rpc('get_require_apt_pass_on_open');
      if (resp is bool) {
        requireAptPassOnOpen = resp;
      }
    } catch (_) {}

    var contactsList = <BuildingContact>[];
    try {
      final cRows = await client
          .from('building_contacts')
          .select()
          .order('created_at', ascending: false);
      contactsList = (cRows as List)
          .map((r) => BuildingContact.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {}

    final aptHasPassMap = <int, bool>{};
    try {
      final passRows = await client.rpc('get_apartments_passcode_status');
      if (passRows is List) {
        for (final r in passRows) {
          final num = r['apt_num'] as int;
          aptHasPassMap[num] = r['has_passcode'] == true;
        }
      }
    } catch (_) {}

    return BuildingDataState(
      baseEmergencyFund: baseEmerg,
      months: monthsMap.values.toList(),
      apartmentNames: aptNamesMap,
      announcement: announcement,
      emergencyTransactions: emergencyTx,
      requireAptPassOnOpen: requireAptPassOnOpen,
      buildingContacts: contactsList,
      apartmentHasPasscode: aptHasPassMap,
    );
  }

  Future<String?> submitApartmentPayment({
    required MonthBill month,
    required int aptNum,
    required String passcode,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    if (!_useSupabase) {
      if (_demoRequireAptPassOnOpen) {
        final expected = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
        if (passcode.trim() != expected) {
          return 'err_wrong_apt_pass_hint:$expected';
        }
      }
      month.payments[aptNum] = PaymentRecord(
        aptNum: aptNum,
        localBytes: imageBytes,
        fileName: fileName ?? '',
        paidAt: DateTime.now(),
      );
      return null;
    }

    final client = Supabase.instance.client;
    String? publicUrl;
    if (imageBytes != null) {
      final safeName = fileName ?? 'receipt.jpg';
      final ext = safeName.split('.').last.toLowerCase();
      final storagePath = '${month.yearNum}_${month.monthNum}/apt_${aptNum}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from('receipts').uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      publicUrl = client.storage.from('receipts').getPublicUrl(storagePath);
    }

    final res = await client.rpc('verify_apt_and_record_payment', params: {
      'p_month_id': month.id,
      'p_apt_num': aptNum,
      'p_passcode': passcode.trim(),
      'p_receipt_url': publicUrl,
    });

    if (res is Map && res['ok'] == true) {
      return null;
    }
    return (res is Map ? res['error']?.toString() : null) ?? 'err_payment_failed';
  }

  Future<String?> updateMonthAsAdmin({
    required String adminPass,
    required MonthBill month,
    required double baseEmergency,
  }) async {
    if (!_useSupabase) {
      _demoBaseEmergency = baseEmergency;
      return null;
    }

    final client = Supabase.instance.client;
    final res = await client.rpc('admin_update_month', params: {
      'p_admin_pass': adminPass,
      'p_month_id': month.id,
      'p_water': month.water,
      'p_elec': month.elec,
      'p_elev': month.elev,
      'p_clean': month.clean,
      'p_for_emerg': month.forEmerg,
      'p_apts_count': month.aptsCount,
      'p_base_emerg': baseEmergency,
    });

    if (res is Map && res['ok'] == true) return null;
    return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass';
  }

  Future<String?> cancelPaymentAsAdmin({
    required String adminPass,
    required MonthBill month,
    required int aptNum,
  }) async {
    if (!_useSupabase) {
      month.payments.remove(aptNum);
      return null;
    }

    final client = Supabase.instance.client;
    final res = await client.rpc('admin_cancel_payment', params: {
      'p_admin_pass': adminPass,
      'p_month_id': month.id,
      'p_apt_num': aptNum,
    });

    if (res is Map && res['ok'] == true) {
      month.payments.remove(aptNum);
      return null;
    }
    return (res is Map ? res['error']?.toString() : null) ?? 'err_cancel_failed';
  }

  Future<String?> verifyAdminPass(String adminPass) async {
    final clean = adminPass.trim();
    if (!_useSupabase) {
      if (clean == 'admin123' || clean == 'zaied123') return null;
      return 'err_wrong_admin_pass';
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_get_apartments', params: {
        'p_admin_pass': clean,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass';
    } catch (e) {
      return 'err_wrong_admin_pass';
    }
  }

  Future<({List<ApartmentInfo>? apartments, String? error})> fetchAdminApartments({
    required String adminPass,
    required int aptsCount,
  }) async {
    if (!_useSupabase) {
      final list = <ApartmentInfo>[];
      for (int i = 1; i <= aptsCount; i++) {
        list.add(_demoApartments[i] ?? ApartmentInfo(aptNum: i, passcode: '${1000 + i}'));
      }
      return (apartments: list, error: null);
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_get_apartments', params: {
        'p_admin_pass': adminPass,
      });

      if (res is Map && res['ok'] == true) {
        final rawList = (res['apartments'] as List?) ?? [];
        final byNum = <int, ApartmentInfo>{};
        for (final item in rawList) {
          final info = ApartmentInfo.fromJson(Map<String, dynamic>.from(item as Map));
          byNum[info.aptNum] = info;
        }
        final result = <ApartmentInfo>[];
        for (int i = 1; i <= aptsCount; i++) {
          result.add(byNum[i] ?? ApartmentInfo(aptNum: i, passcode: '${1000 + i}'));
        }
        return (apartments: result, error: null);
      }

      return (
        apartments: null,
        error: (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass',
      );
    } catch (e) {
      return (apartments: null, error: 'err_apt_load_failed');
    }
  }

  Future<String?> updateApartmentAsAdmin({
    required String adminPass,
    required int aptNum,
    required String displayName,
    required String passcode,
  }) async {
    if (!_useSupabase) {
      _demoApartments[aptNum] = ApartmentInfo(
        aptNum: aptNum,
        displayName: displayName.trim(),
        passcode: passcode.trim(),
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_update_apartment', params: {
        'p_admin_pass': adminPass,
        'p_apt_num': aptNum,
        'p_display_name': displayName.trim(),
        'p_passcode': passcode.trim(),
      });

      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_apt_save_failed';
    } catch (e) {
      return 'err_apt_save_failed';
    }
  }

  Future<List<FeedbackPost>> fetchFeedbackPosts() async {
    if (!_useSupabase) {
      return List<FeedbackPost>.from(_demoFeedbackPosts);
    }
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('feedback_posts')
          .select()
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => FeedbackPost.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> submitFeedbackPost({
    required String type,
    required String message,
    int? aptNum,
    String? passcode,
    String? authorLabel,
  }) async {
    final cleanMsg = message.trim();
    if (cleanMsg.isEmpty) return 'err_empty_message';

    if (!_useSupabase) {
      if (aptNum != null) {
        final expectedPass = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
        if ((passcode ?? '').trim() != expectedPass) {
          return 'err_wrong_apt_pass';
        }
      }
      _demoFeedbackPosts.insert(
        0,
        FeedbackPost(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          type: type,
          message: cleanMsg,
          authorLabel: aptNum != null ? authorLabel : null,
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      if (aptNum != null) {
        final res = await client.rpc('submit_feedback_with_passcode', params: {
          'p_type': type,
          'p_message': cleanMsg,
          'p_apt_num': aptNum,
          'p_passcode': (passcode ?? '').trim(),
          'p_author_label': authorLabel,
        });
        if (res is Map && res['ok'] == true) return null;
        return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_apt_pass';
      }

      await client.from('feedback_posts').insert({
        'type': type,
        'message': cleanMsg,
        'author_label': null,
      });
      return null;
    } catch (e) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteFeedbackPost({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      _demoFeedbackPosts.removeWhere((p) => p.id == id);
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_feedback', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (e) {
      return 'err_delete_failed';
    }
  }

  Future<String?> addNextMonthAsAdmin(String adminPass) async {
    if (!_useSupabase) {
      final last = _demoMonths.last;
      final nextMonth = last.monthNum == 12 ? 1 : last.monthNum + 1;
      final nextYear = last.monthNum == 12 ? last.yearNum + 1 : last.yearNum;
      _demoMonths.add(MonthBill(
        id: last.id + 1,
        monthNum: nextMonth,
        yearNum: nextYear,
        water: 0,
        elec: 0,
        elev: 400,
        clean: 240,
        forEmerg: 0,
        aptsCount: last.aptsCount,
      ));
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_add_next_month', params: {
        'p_admin_pass': adminPass,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass';
    } catch (e) {
      return 'err_apt_save_failed';
    }
  }

  Future<String?> deleteMonthAsAdmin({
    required String adminPass,
    required int monthId,
  }) async {
    if (!_useSupabase) {
      if (_demoMonths.length <= 1) return 'err_cannot_delete_last_month';
      _demoMonths.removeWhere((m) => m.id == monthId);
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_month', params: {
        'p_admin_pass': adminPass,
        'p_month_id': monthId,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (e) {
      return 'err_delete_failed';
    }
  }

  Future<String?> saveAnnouncement({
    required String adminPass,
    required String announcement,
  }) async {
    final clean = announcement.trim();
    if (!_useSupabase) {
      _demoAnnouncement = clean;
      return null;
    }
    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_set_announcement', params: {
        'p_admin_pass': adminPass,
        'p_announcement': clean,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_apt_save_failed';
    } catch (e) {
      return 'err_apt_save_failed';
    }
  }

  Future<String?> addEmergencyTransaction({
    required String adminPass,
    required double amount,
    required String reason,
  }) async {
    final cleanReason = reason.trim();
    if (amount == 0 || cleanReason.isEmpty) return 'err_empty_message';

    if (!_useSupabase) {
      _demoBaseEmergency = (_demoBaseEmergency - amount).clamp(0, double.infinity);
      _demoEmergencyTx.insert(
        0,
        EmergencyTransaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          amount: amount,
          reason: cleanReason,
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_add_emergency_tx', params: {
        'p_admin_pass': adminPass,
        'p_amount': amount,
        'p_reason': cleanReason,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (e) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteEmergencyTransaction({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      final idx = _demoEmergencyTx.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        _demoBaseEmergency += _demoEmergencyTx[idx].amount;
        _demoEmergencyTx.removeAt(idx);
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_emergency_tx', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (e) {
      return 'err_delete_failed';
    }
  }

  Future<String?> updateFeedbackPostStatus({
    required String adminPass,
    required String id,
    required String status,
    String? adminReply,
  }) async {
    final cleanReply = (adminReply ?? '').trim();
    if (!_useSupabase) {
      final idx = _demoFeedbackPosts.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        final old = _demoFeedbackPosts[idx];
        _demoFeedbackPosts[idx] = FeedbackPost(
          id: old.id,
          type: old.type,
          message: old.message,
          authorLabel: old.authorLabel,
          status: status,
          adminReply: cleanReply.isEmpty ? null : cleanReply,
          createdAt: old.createdAt,
        );
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_update_feedback_status', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
        'p_status': status,
        'p_admin_reply': cleanReply.isEmpty ? null : cleanReply,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (e) {
      return 'err_submit_failed';
    }
  }

  Future<String?> addExtraChargesAsAdmin({
    required String adminPass,
    required int monthId,
    required List<int> aptNums,
    required double amount,
    required String reason,
  }) async {
    final cleanReason = reason.trim();
    if (aptNums.isEmpty || amount <= 0 || cleanReason.isEmpty) {
      return 'err_empty_message';
    }

    if (!_useSupabase) {
      final idx = _demoMonths.indexWhere((m) => m.id == monthId);
      if (idx >= 0) {
        final now = DateTime.now();
        for (final apt in aptNums) {
          _demoMonths[idx].extraCharges.insert(
            0,
            ApartmentExtraCharge(
              id: '${now.microsecondsSinceEpoch}_$apt',
              monthId: monthId,
              aptNum: apt,
              amount: amount,
              reason: cleanReason,
              createdAt: now,
            ),
          );
        }
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_add_extra_charge', params: {
        'p_admin_pass': adminPass,
        'p_month_id': monthId,
        'p_apt_nums': aptNums,
        'p_amount': amount,
        'p_reason': cleanReason,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteExtraChargeAsAdmin({
    required String adminPass,
    required int monthId,
    required String id,
  }) async {
    if (!_useSupabase) {
      final idx = _demoMonths.indexWhere((m) => m.id == monthId);
      if (idx >= 0) {
        _demoMonths[idx].extraCharges.removeWhere((e) => e.id == id);
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_extra_charge', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  Future<void> recordPageView(String visitorId) async {
    final clean = visitorId.trim();
    if (clean.isEmpty) return;

    if (!_useSupabase) {
      _demoPageViews.add((visitorId: clean, createdAt: DateTime.now()));
      return;
    }

    try {
      await Supabase.instance.client.rpc('record_page_view', params: {
        'p_visitor_id': clean,
      });
    } catch (_) {
      // Ignore silently if analytics RPC isn't deployed yet
    }
  }

  Future<PageViewStats?> fetchPageViewStatsAsAdmin(String adminPass) async {
    if (!_useSupabase) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final unique = _demoPageViews.map((e) => e.visitorId).toSet().length;
      final today = _demoPageViews.where((e) => !e.createdAt.isBefore(todayStart)).length;
      return PageViewStats(
        totalViews: _demoPageViews.length,
        uniqueVisitors: unique,
        todayViews: today,
      );
    }

    try {
      final res = await Supabase.instance.client.rpc('admin_get_page_view_stats', params: {
        'p_admin_pass': adminPass,
      });
      if (res is Map && res['ok'] == true) {
        return PageViewStats.fromJson(Map<String, dynamic>.from(res));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> verifyApartmentPasscode(int aptNum, String passcode) async {
    final clean = passcode.trim();
    if (!_useSupabase) {
      final expected = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
      if (clean != expected) return 'err_wrong_apt_pass';
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc('verify_apartment_passcode', params: {
        'p_apt_num': aptNum,
        'p_passcode': clean,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_apt_pass';
    } catch (_) {
      return 'err_wrong_apt_pass';
    }
  }

  Future<String?> setRequireAptPassOnOpenAsAdmin({
    required String adminPass,
    required bool enabled,
  }) async {
    if (!_useSupabase) {
      _demoRequireAptPassOnOpen = enabled;
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_set_require_apt_pass_on_open',
        params: {
          'p_admin_pass': adminPass,
          'p_enabled': enabled,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> setUtilityReceiptAsAdmin({
    required String adminPass,
    required MonthBill month,
    required String utility,
    Uint8List? imageBytes,
  }) async {
    if (!_useSupabase) {
      if (utility == 'water') {
        month.waterLocalBytes = imageBytes;
        month.waterReceiptUrl = imageBytes != null ? 'local' : null;
      } else {
        month.elecLocalBytes = imageBytes;
        month.elecReceiptUrl = imageBytes != null ? 'local' : null;
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      String publicUrl = '';
      if (imageBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'utility_${month.id}_${utility}_$ts.jpg';
        await client.storage.from('receipts').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        publicUrl = client.storage.from('receipts').getPublicUrl(storagePath);
      }

      final res = await client.rpc('admin_set_utility_receipt', params: {
        'p_admin_pass': adminPass,
        'p_month_id': month.id,
        'p_utility': utility,
        'p_receipt_url': publicUrl,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> addBuildingContact({
    required String name,
    required String roleDesc,
    required String phone,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    if (cleanName.isEmpty || cleanPhone.isEmpty) return 'err_submit_failed';

    if (!_useSupabase) {
      _demoContacts.insert(
        0,
        BuildingContact(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: cleanName,
          roleDesc: roleDesc.trim(),
          phone: cleanPhone,
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      await Supabase.instance.client.from('building_contacts').insert({
        'name': cleanName,
        'role_desc': roleDesc.trim(),
        'phone': cleanPhone,
      });
      return null;
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteBuildingContactAsAdmin({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      _demoContacts.removeWhere((c) => c.id == id);
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_delete_building_contact',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  Future<String?> deleteAllExtraChargesAsAdmin({
    required String adminPass,
    required int monthId,
  }) async {
    if (!_useSupabase) {
      final idx = _demoMonths.indexWhere((m) => m.id == monthId);
      if (idx >= 0) {
        _demoMonths[idx].extraCharges.clear();
      }
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_delete_all_extra_charges',
        params: {
          'p_admin_pass': adminPass,
          'p_month_id': monthId,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  Future<String?> setInitialApartmentPasscode(int aptNum, String passcode) async {
    final clean = passcode.trim();
    if (clean.length < 4) return 'err_pass_too_short';

    if (!_useSupabase) {
      final existing = _demoApartments[aptNum]?.passcode.trim() ?? '';
      if (existing.isNotEmpty) return 'err_pass_already_set';
      final prev = _demoApartments[aptNum];
      _demoApartments[aptNum] = ApartmentInfo(
        aptNum: aptNum,
        displayName: prev?.displayName ?? '',
        passcode: clean,
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'set_initial_apartment_passcode',
        params: {
          'p_apt_num': aptNum,
          'p_passcode': clean,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> resetApartmentPasscodeAsAdmin({
    required String adminPass,
    required int aptNum,
  }) async {
    if (!_useSupabase) {
      final prev = _demoApartments[aptNum];
      if (prev != null) {
        _demoApartments[aptNum] = ApartmentInfo(
          aptNum: aptNum,
          displayName: prev.displayName,
          passcode: '',
        );
      }
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_reset_apartment_passcode',
        params: {
          'p_admin_pass': adminPass,
          'p_apt_num': aptNum,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> resetAllApartmentPasscodesAsAdmin(String adminPass) async {
    if (!_useSupabase) {
      for (final key in _demoApartments.keys.toList()) {
        final prev = _demoApartments[key]!;
        _demoApartments[key] = ApartmentInfo(
          aptNum: prev.aptNum,
          displayName: prev.displayName,
          passcode: '',
        );
      }
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_reset_all_apartment_passcodes',
        params: {
          'p_admin_pass': adminPass,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  /// Registers or updates an FCM web push token in Supabase `push_tokens`.
  Future<bool> registerPushToken({
    required String token,
    int? aptNum,
    bool isAdmin = false,
  }) async {
    final clean = token.trim();
    if (clean.isEmpty) return false;
    if (!_useSupabase) return true;

    try {
      await Supabase.instance.client.rpc('register_push_token', params: {
        'p_token': clean,
        'p_apt_num': aptNum,
        'p_is_admin': isAdmin,
        'p_platform': 'web',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Invokes the Supabase `send-push` Edge Function.
  /// Returns `(ok, sentCount, notConfigured, error)`.
  Future<({bool ok, int sent, bool notConfigured, String? error})> sendPushNotification({
    required String title,
    required String body,
    String audience = 'all',
    String? adminPass,
    String? eventType,
  }) async {
    if (!_useSupabase) {
      return (ok: true, sent: 1, notConfigured: false, error: null);
    }

    try {
      final resp = await Supabase.instance.client.functions.invoke(
        'send-push',
        body: {
          'title': title.trim(),
          'body': body.trim(),
          'audience': audience,
          if (adminPass != null && adminPass.isNotEmpty) 'admin_pass': adminPass,
          'event_type': ?eventType,
        },
      );
      final data = resp.data;
      if (data is Map) {
        if (data['not_configured'] == true) {
          return (ok: false, sent: 0, notConfigured: true, error: null);
        }
        if (data['ok'] == true) {
          final sent = (data['sent'] as num?)?.toInt() ?? 0;
          return (ok: true, sent: sent, notConfigured: false, error: null);
        }
        return (
          ok: false,
          sent: 0,
          notConfigured: false,
          error: data['error']?.toString() ?? 'err_submit_failed',
        );
      }
      return (ok: false, sent: 0, notConfigured: false, error: 'err_submit_failed');
    } catch (_) {
      return (ok: false, sent: 0, notConfigured: false, error: 'err_submit_failed');
    }
  }
}
