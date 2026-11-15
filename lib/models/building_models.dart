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
  }) : payments = payments ?? {};

  double get totalExpenses => water + elec + elev + clean + forEmerg;

  int get sharePerApt {
    if (totalExpenses <= 0 || aptsCount <= 0) return 0;
    return (totalExpenses / aptsCount).ceil();
  }

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
  final DateTime createdAt;

  const FeedbackPost({
    required this.id,
    required this.type,
    required this.message,
    this.authorLabel,
    required this.createdAt,
  });

  factory FeedbackPost.fromJson(Map<String, dynamic> json) {
    return FeedbackPost(
      id: json['id'].toString(),
      type: (json['type'] as String?) ?? 'complaint',
      message: (json['message'] as String?) ?? '',
      authorLabel: json['author_label'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
