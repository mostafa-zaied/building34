import 'dart:typed_data';

class BuildingInfo {
  final int id;
  final String code;
  final String name;
  final String city;
  final int aptsCount;
  final String instapayPhone;
  final String instapayUrl;
  final String managerWhatsapp;
  final String subscriptionStatus; // 'trial' | 'active' | 'suspended'
  final DateTime? trialEndsAt;
  final DateTime? subscriptionEndsAt;
  final DateTime? createdAt;

  const BuildingInfo({
    required this.id,
    required this.code,
    required this.name,
    this.city = '',
    this.aptsCount = 13,
    this.instapayPhone = '',
    this.instapayUrl = '',
    this.managerWhatsapp = '',
    this.subscriptionStatus = 'active',
    this.trialEndsAt,
    this.subscriptionEndsAt,
    this.createdAt,
  });

  static const BuildingInfo defaultDemo = BuildingInfo(
    id: 1,
    code: 'MABNA-1',
    name: 'MABNA CARE',
    city: '',
    aptsCount: 13,
    instapayPhone: '01021950445',
    instapayUrl: 'https://ipn.eg/S/mostafazaied/instapay/6nvhpw',
    managerWhatsapp: '201021950445',
    subscriptionStatus: 'active',
  );

  bool get isDefaultBuilding => id == 1;
  bool get isTrial => subscriptionStatus == 'trial';

  DateTime? get effectiveEndsAt =>
      subscriptionStatus == 'trial' ? trialEndsAt : subscriptionEndsAt;

  bool get isExpired {
    if (isDefaultBuilding) return false;
    final ends = effectiveEndsAt;
    if (ends == null) return false;
    return DateTime.now().isAfter(ends);
  }

  bool get isSuspended {
    if (isDefaultBuilding) return false;
    return subscriptionStatus == 'suspended' || isExpired;
  }

  int get daysRemaining {
    final ends = effectiveEndsAt;
    if (ends == null) return 999;
    final diff = ends.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  String get normalizedWhatsapp {
    final digits = managerWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('01')) return '2$digits';
    if (digits.startsWith('0')) return '2$digits';
    return digits;
  }

  BuildingInfo copyWith({
    int? id,
    String? code,
    String? name,
    String? city,
    int? aptsCount,
    String? instapayPhone,
    String? instapayUrl,
    String? managerWhatsapp,
    String? subscriptionStatus,
    DateTime? trialEndsAt,
    DateTime? subscriptionEndsAt,
    DateTime? createdAt,
  }) {
    return BuildingInfo(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      city: city ?? this.city,
      aptsCount: aptsCount ?? this.aptsCount,
      instapayPhone: instapayPhone ?? this.instapayPhone,
      instapayUrl: instapayUrl ?? this.instapayUrl,
      managerWhatsapp: managerWhatsapp ?? this.managerWhatsapp,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      subscriptionEndsAt: subscriptionEndsAt ?? this.subscriptionEndsAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BuildingInfo.fromJson(Map<String, dynamic> json) {
    return BuildingInfo(
      id: (json['id'] as num?)?.toInt() ?? 1,
      code: (json['code'] as String?)?.trim() ?? 'MABNA-1',
      name: (json['name'] as String?)?.trim() ?? 'MABNA CARE',
      city: (json['city'] as String?)?.trim() ?? '',
      aptsCount: (json['apts_count'] as num?)?.toInt() ?? 13,
      instapayPhone: (json['instapay_phone'] as String?)?.trim() ?? '',
      instapayUrl: (json['instapay_url'] as String?)?.trim() ?? '',
      managerWhatsapp: (json['manager_whatsapp'] as String?)?.trim() ?? '',
      subscriptionStatus:
          (json['subscription_status'] as String?)?.trim() ?? 'active',
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.tryParse(json['trial_ends_at'].toString())
          : null,
      subscriptionEndsAt: json['subscription_ends_at'] != null
          ? DateTime.tryParse(json['subscription_ends_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class SavedBuildingRef {
  final int id;
  final String code;
  final String name;
  final String city;

  const SavedBuildingRef({
    required this.id,
    required this.code,
    required this.name,
    this.city = '',
  });

  factory SavedBuildingRef.fromBuilding(BuildingInfo b) => SavedBuildingRef(
        id: b.id,
        code: b.code,
        name: b.name,
        city: b.city,
      );

  factory SavedBuildingRef.fromJson(Map<String, dynamic> json) {
    return SavedBuildingRef(
      id: (json['id'] as num?)?.toInt() ?? 1,
      code: (json['code'] as String?)?.trim() ?? 'MABNA-1',
      name: (json['name'] as String?)?.trim() ?? 'MABNA CARE',
      city: (json['city'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'city': city,
      };
}

class SuperAdminBuildingItem {
  final BuildingInfo building;
  final int monthsCount;
  final int paymentsCount;
  final int viewsCount;

  const SuperAdminBuildingItem({
    required this.building,
    this.monthsCount = 0,
    this.paymentsCount = 0,
    this.viewsCount = 0,
  });

  factory SuperAdminBuildingItem.fromJson(Map<String, dynamic> json) {
    return SuperAdminBuildingItem(
      building: BuildingInfo.fromJson(
        Map<String, dynamic>.from((json['building'] as Map?) ?? {}),
      ),
      monthsCount: (json['months_count'] as num?)?.toInt() ?? 0,
      paymentsCount: (json['payments_count'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class SuperAdminDashboardData {
  final List<SuperAdminBuildingItem> buildings;
  final int totalBuildings;
  final int activeBuildings;
  final int trialBuildings;
  final int suspendedBuildings;
  final int totalApts;
  final int totalViews;

  const SuperAdminDashboardData({
    required this.buildings,
    required this.totalBuildings,
    required this.activeBuildings,
    required this.trialBuildings,
    required this.suspendedBuildings,
    required this.totalApts,
    required this.totalViews,
  });

  factory SuperAdminDashboardData.fromJson(Map<String, dynamic> json) {
    final rawList = (json['buildings'] as List?) ?? const [];
    final stats = Map<String, dynamic>.from((json['stats'] as Map?) ?? {});
    return SuperAdminDashboardData(
      buildings: rawList
          .whereType<Map>()
          .map((e) => SuperAdminBuildingItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      totalBuildings: (stats['total_buildings'] as num?)?.toInt() ?? rawList.length,
      activeBuildings: (stats['active_buildings'] as num?)?.toInt() ?? 0,
      trialBuildings: (stats['trial_buildings'] as num?)?.toInt() ?? 0,
      suspendedBuildings: (stats['suspended_buildings'] as num?)?.toInt() ?? 0,
      totalApts: (stats['total_apts'] as num?)?.toInt() ?? 0,
      totalViews: (stats['total_views'] as num?)?.toInt() ?? 0,
    );
  }
}

class ApartmentInfo {
  final int aptNum;
  String displayName;
  String passcode;

  ApartmentInfo({
    required this.aptNum,
    this.displayName = '',
    this.passcode = '',
  });

  String get label => displayName.trim().isNotEmpty ? displayName.trim() : 'شقة $aptNum';

  factory ApartmentInfo.fromJson(Map<String, dynamic> json) {
    return ApartmentInfo(
      aptNum: json['apt_num'] as int,
      displayName: (json['display_name'] as String?) ?? '',
      passcode: (json['passcode'] as String?) ?? '',
    );
  }
}

class PaymentRecord {
  final int aptNum;
  final String? receiptUrl;
  final Uint8List? localBytes; // Used in local demo mode
  final String fileName;
  final DateTime paidAt;

  PaymentRecord({
    required this.aptNum,
    this.receiptUrl,
    this.localBytes,
    required this.fileName,
    required this.paidAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      aptNum: json['apt_num'] as int,
      receiptUrl: json['receipt_url'] as String?,
      fileName: 'إيصال_التحويل.jpg',
      paidAt: DateTime.tryParse(json['paid_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class ApartmentExtraCharge {
  final String id;
  final int monthId;
  final int aptNum;
  final double amount;
  final String reason;
  final DateTime createdAt;

  const ApartmentExtraCharge({
    required this.id,
    required this.monthId,
    required this.aptNum,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  factory ApartmentExtraCharge.fromJson(Map<String, dynamic> json) {
    return ApartmentExtraCharge(
      id: json['id'].toString(),
      monthId: json['month_id'] as int? ?? 0,
      aptNum: json['apt_num'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      reason: (json['reason'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class CustomExpenseItem {
  final String id;
  String name;
  double amount;

  CustomExpenseItem({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory CustomExpenseItem.fromJson(Map<String, dynamic> json) {
    return CustomExpenseItem(
      id: (json['id']?.toString() ?? '').trim().isNotEmpty
          ? json['id'].toString()
          : 'ce_${DateTime.now().microsecondsSinceEpoch}',
      name: (json['name'] as String?)?.trim() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };
}

class MonthBill {
  final int id;
  final int monthNum;
  final int yearNum;
  double water;
  double elec;
  double elev;
  double clean;
  double forEmerg;
  int aptsCount;
  int dueDay;
  String? waterReceiptUrl;
  Uint8List? waterLocalBytes;
  String? elecReceiptUrl;
  Uint8List? elecLocalBytes;
  final Map<int, PaymentRecord> payments;
  final List<ApartmentExtraCharge> extraCharges;
  final List<CustomExpenseItem> customExpenses;

  MonthBill({
    required this.id,
    required this.monthNum,
    required this.yearNum,
    required this.water,
    required this.elec,
    required this.elev,
    required this.clean,
    required this.forEmerg,
    required this.aptsCount,
    this.dueDay = 10,
    this.waterReceiptUrl,
    this.waterLocalBytes,
    this.elecReceiptUrl,
    this.elecLocalBytes,
    Map<int, PaymentRecord>? payments,
    List<ApartmentExtraCharge>? extraCharges,
    List<CustomExpenseItem>? customExpenses,
  })  : payments = payments ?? {},
        extraCharges = extraCharges ?? [],
        customExpenses = customExpenses ?? [];

  double get customExpensesTotal =>
      customExpenses.fold<double>(0, (sum, item) => sum + item.amount);

  double get totalExpenses => water + elec + elev + clean + customExpensesTotal;

  int get sharePerApt {
    if (totalExpenses <= 0 || aptsCount <= 0) return 0;
    return (totalExpenses / aptsCount).ceil();
  }

  List<ApartmentExtraCharge> extraChargesFor(int aptNum) =>
      extraCharges.where((e) => e.aptNum == aptNum).toList();

  int extraTotalFor(int aptNum) => extraCharges
      .where((e) => e.aptNum == aptNum)
      .fold<double>(0, (sum, e) => sum + e.amount)
      .round();

  int dueFor(int aptNum) => sharePerApt + extraTotalFor(aptNum);

  int get totalCollected {
    int sum = 0;
    for (final aptNum in payments.keys) {
      if (aptNum >= 1 && aptNum <= aptsCount) {
        sum += dueFor(aptNum);
      }
    }
    return sum;
  }

  int get totalExpected {
    int sum = 0;
    for (int i = 1; i <= aptsCount; i++) {
      sum += dueFor(i);
    }
    return sum;
  }

  int get totalRemaining => (totalExpected - totalCollected).clamp(0, totalExpected);

  bool get hasDueDate => dueDay >= 1 && dueDay <= 31;

  DateTime? get dueDate {
    if (!hasDueDate) return null;
    final lastDayOfMonth = DateTime(yearNum, monthNum + 1, 0).day;
    final clampedDay = dueDay.clamp(1, lastDayOfMonth);
    return DateTime(yearNum, monthNum, clampedDay);
  }

  bool get isPastDue {
    final due = dueDate;
    if (due == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(due);
  }

  int get unpaidCount {
    int count = 0;
    for (int i = 1; i <= aptsCount; i++) {
      if (!payments.containsKey(i)) count++;
    }
    return count;
  }

  factory MonthBill.fromJson(Map<String, dynamic> json) {
    final rawCustom = json['custom_expenses'];
    final customList = <CustomExpenseItem>[];
    if (rawCustom is List) {
      for (final item in rawCustom) {
        if (item is Map) {
          final parsed = CustomExpenseItem.fromJson(Map<String, dynamic>.from(item));
          if (parsed.name.isNotEmpty) {
            customList.add(parsed);
          }
        }
      }
    }
    return MonthBill(
      id: json['id'] as int,
      monthNum: json['month_num'] as int,
      yearNum: json['year_num'] as int? ?? 2026,
      water: (json['water'] as num?)?.toDouble() ?? 0,
      elec: (json['elec'] as num?)?.toDouble() ?? 0,
      elev: (json['elev'] as num?)?.toDouble() ?? 400,
      clean: (json['clean'] as num?)?.toDouble() ?? 240,
      forEmerg: (json['for_emerg'] as num?)?.toDouble() ?? 0,
      aptsCount: json['apts_count'] as int? ?? 13,
      dueDay: (json['due_day'] as num?)?.toInt() ?? 10,
      waterReceiptUrl: (json['water_receipt_url'] as String?)?.trim(),
      elecReceiptUrl: (json['elec_receipt_url'] as String?)?.trim(),
      customExpenses: customList,
    );
  }
}

class BuildingContact {
  final String id;
  final String name;
  final String roleDesc;
  final String phone;
  final DateTime createdAt;

  const BuildingContact({
    required this.id,
    required this.name,
    required this.roleDesc,
    required this.phone,
    required this.createdAt,
  });

  bool get supportsWhatsApp =>
      phone.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;

  String get whatsappNumber {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) return '2$digits';
    return digits;
  }

  factory BuildingContact.fromJson(Map<String, dynamic> json) {
    return BuildingContact(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? '',
      roleDesc: (json['role_desc'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class FeedbackPost {
  final String id;
  final String type; // 'complaint' or 'improvement'
  final String message;
  final String? authorLabel; // null when anonymous
  final String status; // 'pending', 'in_progress', 'resolved'
  final String? adminReply;
  final DateTime createdAt;

  const FeedbackPost({
    required this.id,
    required this.type,
    required this.message,
    this.authorLabel,
    this.status = 'pending',
    this.adminReply,
    required this.createdAt,
  });

  factory FeedbackPost.fromJson(Map<String, dynamic> json) {
    return FeedbackPost(
      id: json['id'].toString(),
      type: (json['type'] as String?) ?? 'complaint',
      message: (json['message'] as String?) ?? '',
      authorLabel: json['author_label'] as String?,
      status: (json['status'] as String?) ?? 'pending',
      adminReply: json['admin_reply'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class EmergencyTransaction {
  final String id;
  final double amount;
  final String reason;
  final DateTime createdAt;

  const EmergencyTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  factory EmergencyTransaction.fromJson(Map<String, dynamic> json) {
    return EmergencyTransaction(
      id: json['id'].toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      reason: (json['reason'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PageViewStats {
  final int totalViews;
  final int uniqueVisitors;
  final int todayViews;

  const PageViewStats({
    this.totalViews = 0,
    this.uniqueVisitors = 0,
    this.todayViews = 0,
  });

  factory PageViewStats.fromJson(Map<String, dynamic> json) {
    return PageViewStats(
      totalViews: (json['total_views'] as num?)?.toInt() ?? 0,
      uniqueVisitors: (json['unique_visitors'] as num?)?.toInt() ?? 0,
      todayViews: (json['today_views'] as num?)?.toInt() ?? 0,
    );
  }
}

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String audience;
  final String eventType;
  final DateTime createdAt;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.audience = 'all',
    this.eventType = 'manual_broadcast',
    required this.createdAt,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: json['id'].toString(),
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      audience: (json['audience'] as String?) ?? 'all',
      eventType: (json['event_type'] as String?) ?? 'manual_broadcast',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

String localizedMonthName(int monthNum, bool isAr) {
  const arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  const enMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  if (monthNum < 1 || monthNum > 12) return '$monthNum';
  return isAr ? arMonths[monthNum - 1] : enMonths[monthNum - 1];
}
