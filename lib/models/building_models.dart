import 'dart:typed_data';

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
  final Map<int, PaymentRecord> payments;
  final List<ApartmentExtraCharge> extraCharges;

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
    Map<int, PaymentRecord>? payments,
    List<ApartmentExtraCharge>? extraCharges,
  })  : payments = payments ?? {},
        extraCharges = extraCharges ?? [];

  double get totalExpenses => water + elec + elev + clean;

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

  factory MonthBill.fromJson(Map<String, dynamic> json) {
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
  final int weekViews;
  final int upcomingOpens;
  final int upcomingVotes;

  const PageViewStats({
    this.totalViews = 0,
    this.uniqueVisitors = 0,
    this.todayViews = 0,
    this.weekViews = 0,
    this.upcomingOpens = 0,
    this.upcomingVotes = 0,
  });

  factory PageViewStats.fromJson(Map<String, dynamic> json) {
    return PageViewStats(
      totalViews: (json['total_views'] as num?)?.toInt() ?? 0,
      uniqueVisitors: (json['unique_visitors'] as num?)?.toInt() ?? 0,
      todayViews: (json['today_views'] as num?)?.toInt() ?? 0,
      weekViews: (json['week_views'] as num?)?.toInt() ?? 0,
      upcomingOpens: (json['upcoming_opens'] as num?)?.toInt() ?? 0,
      upcomingVotes: (json['upcoming_votes'] as num?)?.toInt() ?? 0,
    );
  }
}
