import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../models/building_models.dart';

class BuildingDataState {
  final double baseEmergencyFund;
  final List<MonthBill> months;
  final Map<int, String> apartmentNames;

  BuildingDataState({
    required this.baseEmergencyFund,
    required this.months,
    required this.apartmentNames,
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
  static final List<FeedbackPost> _demoFeedbackPosts = [];
  static final Map<int, ApartmentInfo> _demoApartments = {
    for (int i = 1; i <= 30; i++)
      i: ApartmentInfo(aptNum: i, displayName: '', passcode: '${1000 + i}'),
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

    return BuildingDataState(
      baseEmergencyFund: baseEmerg,
      months: monthsMap.values.toList(),
      apartmentNames: aptNamesMap,
    );
  }

  Future<String?> submitApartmentPayment({
    required MonthBill month,
    required int aptNum,
    required String passcode,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (!_useSupabase) {
      final expected = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
      if (passcode.trim() != expected) {
        return 'err_wrong_apt_pass_hint:$expected';
      }
      month.payments[aptNum] = PaymentRecord(
        aptNum: aptNum,
        localBytes: imageBytes,
        fileName: fileName,
        paidAt: DateTime.now(),
      );
      return null;
    }

    final client = Supabase.instance.client;
    final ext = fileName.split('.').last.toLowerCase();
    final storagePath = '${month.yearNum}_${month.monthNum}/apt_${aptNum}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await client.storage.from('receipts').uploadBinary(
          storagePath,
          imageBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = client.storage.from('receipts').getPublicUrl(storagePath);

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
          .select('id, type, message, author_label, created_at')
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
}
