// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'MABNA CARE';

  @override
  String get demoBanner =>
      'وضع التجربة المحلي — أضف بيانات Supabase في lib/config.dart للنشر الفعلي';

  @override
  String monthOption(int monthNum, int yearNum) {
    return 'شهر $monthNum ($yearNum)';
  }

  @override
  String get editBtn => 'تعديل';

  @override
  String get closeBtn => 'إغلاق';

  @override
  String billTitle(int monthNum) {
    return 'مصاريف العمارة لشهر $monthNum:';
  }

  @override
  String get copyWhatsAppBtn => 'نسخ للواتساب';

  @override
  String get waterLabel => 'مياه';

  @override
  String get elecLabel => 'كهرباء';

  @override
  String get elevLabel => 'أسانسير';

  @override
  String get cleanLabel => 'منظفات';

  @override
  String totalExpensesLine(int total, int apts) {
    return '• إجمالي المصاريف: $total ج (÷ $apts شقة)';
  }

  @override
  String get sharePerAptLabel => 'نصيب الشقة';

  @override
  String currency(int amount) {
    return '$amount ج';
  }

  @override
  String get copiedTitle => 'الرسالة المنسوخة للواتساب:';

  @override
  String get copiedToast => 'تم نسخ تفاصيل الشهر المحدثة للواتساب';

  @override
  String get aptsCountField => 'عدد الشقق:';

  @override
  String get saveChangesBtn => 'حفظ التعديلات';

  @override
  String get manageAptsBtn => 'أسماء وباسورد الشقق';

  @override
  String get tapAptTitle => 'اضغط على شقتك لتسجيل الدفع';

  @override
  String paidCounter(int paid, int total) {
    return 'دفع $paid من $total';
  }

  @override
  String defaultAptName(int num) {
    return 'شقة $num';
  }

  @override
  String get paidBadge => 'دفعت';

  @override
  String get adminLoginTitle => 'دخول المسؤول';

  @override
  String get adminPassHint => 'أدخل كلمة سر المسؤول...';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get login => 'دخول';

  @override
  String get manageAptsTitle => 'إدارة أسماء وكلمات سر الشقق';

  @override
  String get optionalName => 'الاسم (اختياري)';

  @override
  String nameHint(int num) {
    return 'مثلاً: شقة $num - د. كريم';
  }

  @override
  String get passcodeLabel => 'كلمة السر';

  @override
  String get saveAll => 'حفظ الكل';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String fileLabel(String name) {
    return 'الملف: $name';
  }

  @override
  String get cancelPaymentAdmin => 'إلغاء الدفع (المسؤول)';

  @override
  String step1Passcode(String demoHint) {
    return '1. كلمة سر الشقة$demoHint';
  }

  @override
  String get enterPassHint => 'اكتب كلمة السر...';

  @override
  String get step2Image => '2. إرفاق صورة التحويل (اختياري)';

  @override
  String get confirmPaidCheckbox => 'أؤكد أنني قمت بسداد نصيب هذا الشهر';

  @override
  String get errConfirmCheckbox => 'يرجى تفعيل علامة تأكيد الدفع أولاً!';

  @override
  String get noReceiptAttached => 'تم تأكيد الدفع بدون إرفاق صورة';

  @override
  String get pickImagePrompt => 'اضغط هنا لاختيار صورة الإيصال';

  @override
  String chosenFile(String name) {
    return 'تم اختيار: $name';
  }

  @override
  String get confirmPaymentBtn => 'تأكيد الدفع';

  @override
  String get uploadingBtn => 'جاري الرفع...';

  @override
  String get addApartmentBtn => '+ إضافة شقة جديدة';

  @override
  String get navExpenses => 'المصاريف';

  @override
  String get navEmergency => 'الطوارئ';

  @override
  String get navComplaints => 'شكاوى';

  @override
  String get navImprovements => 'مقترحات';

  @override
  String get complaintsTitle => 'شكاوى السكان';

  @override
  String get improvementsTitle => 'المقترحات';

  @override
  String get writeComplaintHint => 'اكتب الشكوى هنا...';

  @override
  String get writeImprovementHint => 'اكتب اقتراحك لتحسين العمارة...';

  @override
  String get postAnonymously => 'إرسال بدون اسم (مجهول)';

  @override
  String get selectApartment => 'اختر الشقة';

  @override
  String get submitPostBtn => 'إرسال';

  @override
  String get anonymousAuthor => 'بدون اسم (مجهول)';

  @override
  String get noPostsYet => 'لا توجد مشاركات بعد';

  @override
  String get postAddedToast => 'تم الإرسال بنجاح';

  @override
  String tabViewComplaints(int count) {
    return 'الشكاوى ($count)';
  }

  @override
  String get tabAddComplaint => 'إضافة شكوى';

  @override
  String tabViewImprovements(int count) {
    return 'المقترحات ($count)';
  }

  @override
  String get tabAddImprovement => 'إضافة مقترح';

  @override
  String get languageTooltip => 'اللغة';

  @override
  String get deleteTooltip => 'حذف';

  @override
  String errLoadData(String err) {
    return 'تعذر تحميل البيانات: $err';
  }

  @override
  String get monthSavedToast => 'تم حفظ تعديلات الشهر بنجاح';

  @override
  String get paymentCancelledToast => 'تم إلغاء الدفع';

  @override
  String get aptsSavedToast => 'تم حفظ أسماء وكلمات سر الشقق بنجاح';

  @override
  String get errNoMonth => 'لا يوجد شهر محدد';

  @override
  String get errWrongAdminPass => 'كلمة سر المسؤول غير صحيحة';

  @override
  String get errWrongAptPass => 'كلمة سر الشقة غير صحيحة';

  @override
  String errWrongAptPassHint(String hint) {
    return 'كلمة سر الشقة غير صحيحة (جرب $hint)';
  }

  @override
  String get errPaymentFailed => 'تعذر تسجيل الدفع';

  @override
  String get errCancelFailed => 'تعذر إلغاء الدفع';

  @override
  String get errAptLoadFailed => 'تعذر تحميل بيانات الشقق';

  @override
  String get errAptSaveFailed => 'تعذر حفظ بيانات الشقة';

  @override
  String get errEmptyMessage => 'الرسالة فارغة';

  @override
  String get errSubmitFailed => 'تعذر إرسال المشاركة';

  @override
  String get errDeleteFailed => 'تعذر الحذف';

  @override
  String get addNextMonthBtn => 'إضافة الشهر القادم';

  @override
  String get monthAddedToast => 'تم إضافة الشهر القادم بنجاح';

  @override
  String get pinAptPrompt => 'ثبّت رقم شقتك للدفع السريع';

  @override
  String get selectAptBtn => 'اختر شقتك';

  @override
  String get myAptPrefix => 'شقتي';

  @override
  String get payNowBtn => 'ادفع الآن';

  @override
  String get changeAptTooltip => 'تغيير الشقة';

  @override
  String get emergencyLogTitle => 'سجل حركات صندوق الطوارئ';

  @override
  String get emergencyLogEmpty => 'لا توجد مصروفات مسجلة من الصندوق حتى الآن.';

  @override
  String get emergencyAmountHint => 'المبلغ';

  @override
  String get emergencyReasonHint => 'السبب (مثال: صيانة موتور المياه)';

  @override
  String get recordExpenseBtn => 'تسجيل صرف من الطوارئ';

  @override
  String get errEmergencyInput => 'من فضلك اكتب المبلغ والسبب أولاً.';

  @override
  String get errEmergencySave =>
      'تعذر تسجيل الحركة. تأكد من تشغيل supabase_updates.sql';

  @override
  String get unpaidReminderBtn => 'تذكير المتبقين';

  @override
  String get pinNoticeBtn => 'تثبيت إعلان';

  @override
  String get noticeDialogTitle => 'تثبيت إعلان أو تنبيه هام';

  @override
  String get noticeDialogHint => 'مثال: صيانة الأسانسير يوم الخميس من 10 لـ 12';

  @override
  String get hideNoticeBtn => 'إخفاء الإعلان';

  @override
  String get adminReplyLabel => 'رد الإدارة:';

  @override
  String get updateStatusTitle => 'تحديث الحالة والرد';

  @override
  String get statusFieldLabel => 'الحالة';

  @override
  String get adminReplyHint => 'رد الإدارة (اختياري)...';

  @override
  String get statusPending => 'قيد المراجعة';

  @override
  String get statusInProgress => 'جاري التنفيذ';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get adminLogoutBtn => 'تسجيل خروج المدير';

  @override
  String get emergencyTabWithdraw => 'صرف';

  @override
  String get emergencyTabDeposit => 'إضافة';

  @override
  String get emergencyDepositReasonHint =>
      'السبب (مثال: مساهمة إضافية أو فائض)';

  @override
  String get recordDepositBtn => 'تسجيل إضافة للطوارئ';

  @override
  String get removeMonthBtn => 'حذف الشهر';

  @override
  String get monthDeletedToast => 'تم حذف الشهر بنجاح';

  @override
  String get errCannotDeleteLastMonth => 'لا يمكن حذف آخر شهر متبقي';

  @override
  String get deleteMonthConfirmTitle => 'حذف الشهر الحالي؟';

  @override
  String deleteMonthConfirmBody(int month, int year) {
    return 'سيتم حذف شهر $month ($year) وجميع مدفوعاته نهائياً.';
  }

  @override
  String get splashTagline => 'عمارتك.. مسؤوليتنا.';

  @override
  String get savedPassBadge => 'تم حفظ كلمة سر شقتك تلقائياً';

  @override
  String get changePassBtn => 'تغيير';

  @override
  String get confirmDeleteTitle => 'تأكيد الحذف';

  @override
  String get confirmDeleteBtn => 'حذف';

  @override
  String confirmDeleteAptBody(String apt) {
    return 'هل تريد حذف \"$apt\"؟';
  }

  @override
  String confirmDeleteTxBody(String amount) {
    return 'هل تريد حذف هذه الحركة ($amount)؟';
  }

  @override
  String get confirmDeletePostBody => 'هل تريد حذف هذه المشاركة نهائياً؟';

  @override
  String confirmCancelPaymentBody(String apt) {
    return 'هل تريد إلغاء تسجيل دفع \"$apt\"؟';
  }

  @override
  String get instapayTitle => 'التحويل عبر InstaPay';

  @override
  String get instapaySubtitle => 'حوّل على الرقم التالي ثم ارفع الإيصال';

  @override
  String get openInstapayBtn => 'فتح InstaPay';

  @override
  String get extraChargesBtn => 'رسوم إضافية لشقق';

  @override
  String get extraChargesTitle => 'رسوم إضافية خاصة بشقق';

  @override
  String get selectAptsLabel => 'اختر الشقة أو الشقق:';

  @override
  String get extraAmountHint => 'المبلغ الإضافي لكل شقة';

  @override
  String get extraReasonHint => 'السبب (مثال: تصليح كالون أو محبس)';

  @override
  String get addExtraChargeBtn => 'إضافة الرسوم';

  @override
  String get extraChargesListTitle => 'الرسوم الإضافية المسجلة لهذا الشهر:';

  @override
  String get noExtraChargesYet => 'لا توجد رسوم إضافية مسجلة لهذا الشهر.';

  @override
  String get monthShareLine => 'نصيب الشهر';

  @override
  String get totalDueLabel => 'الإجمالي المطلوب';

  @override
  String confirmDeleteExtraBody(String amount) {
    return 'هل تريد حذف هذا البند الإضافي ($amount)؟';
  }

  @override
  String get extraChargeAddedToast => 'تم إضافة الرسوم الإضافية';
}
