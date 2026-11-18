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
  String get paidBadge => 'تم الدفع';

  @override
  String get pendingPaymentBadge => 'قيد الانتظار';

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
  String get step2Image => 'إرفاق صورة الإيصال (إجباري)';

  @override
  String get unlockAptSubtitle =>
      'أدخل كلمة سر الشقة لفتح التفاصيل (تُحفظ تلقائياً بعد أول مرة)';

  @override
  String get unlockAptBtn => 'فتح الشقة';

  @override
  String get receiptRequiredNote =>
      'يُرجى إرفاق صورة الإيصال للتحقق من المبلغ المدفوع (سواء كان مطابقاً أو أكثر أو أقل من المطلوب).';

  @override
  String get errReceiptRequired =>
      'برجاء إرفاق صورة الإيصال أولاً قبل تأكيد الدفع.';

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

  @override
  String extraBadge(int amount) {
    return '+$amount إضافي';
  }

  @override
  String get upcomingBadge => '🚀 قريباً — Upcoming';

  @override
  String get upcomingDirTitle => 'دليل خدمات المنطقة بمشاركة السكان';

  @override
  String get upcomingDirSubtitle =>
      'قريباً ستتمكن من إضافة وتصفح أفضل المطاعم، الصيدليات، وفنيي الصيانة المجرّبين حول عمارتنا والتواصل معهم بضغطة واحدة.';

  @override
  String get upcomingInterestedBtn => 'أنا مهتم بهذه الخدمة 👍';

  @override
  String get upcomingVotedBtn => 'تم تسجيل اهتمامك بنجاح';

  @override
  String get upcomingHintBefore => 'شاركنا برأيك هل الخدمة دي مفيدة ليك؟';

  @override
  String get upcomingHintAfter => 'شكراً لمشاركتك! رأيك مهم جداً لينا.';

  @override
  String get catRestaurants => '🍽️ مطاعم وكافيهات';

  @override
  String get catPharmacies => '💊 صيدليات';

  @override
  String get catSupermarket => '🛒 سوبر ماركت وبقالة';

  @override
  String get catProduce => '🥬 خضار وفاكهة';

  @override
  String get catBakery => '🥖 مخبز وحلواني';

  @override
  String get catMaintenance => '🔧 صيانة وفنيين';

  @override
  String get catLaundry => '🧺 مغسلة وكوي';

  @override
  String get catCars => '🚗 خدمات سيارات';

  @override
  String get catStationery => '📚 مكتبة وتصوير';

  @override
  String get catOther => '📌 خدمات أخرى';

  @override
  String get settingsBtn => 'الإعدادات (Settings)';

  @override
  String get settingsTitle => 'إعدادات المدير (Settings)';

  @override
  String get settingsShortTitle => 'الإعدادات';

  @override
  String get adminOnlyPageMsg => 'هذه الصفحة متاحة للمدير فقط.';

  @override
  String get requirePassOnOpenTitle => 'طلب كلمة سر الشقة قبل فتح التفاصيل';

  @override
  String get statusEnabled => 'مُفعّل حالياً';

  @override
  String get statusDisabled => 'مُعطّل حالياً';

  @override
  String get requirePassOnOpenDescOn =>
      'عند التفعيل: يُجبر الساكن على إدخال كلمة سر الشقة من الخارج أول مرة قبل رؤية تفاصيل شقته أو الدفع، ولا يمكنه فتح شقق أخرى.';

  @override
  String get requirePassOnOpenDescOff =>
      'عند الإيقاف: تفتح تفاصيل أي شقة مباشرة بدون طلب كلمة سر من الخارج، ويتم إدخال كلمة السر داخل نافذة الدفع فقط.';

  @override
  String get buildingMonthMgmtTitle => 'إدارة العمارة والشهور';

  @override
  String selectedMonthBadge(String monthName, int monthNum, int yearNum) {
    return 'المحدد: $monthName ($monthNum/$yearNum)';
  }

  @override
  String get addNextMonthConfirmTitle => 'إضافة شهر جديد؟';

  @override
  String addNextMonthConfirmBody(String monthName, int monthNum, int yearNum) {
    return 'سيتم إضافة شهر $monthName ($monthNum / $yearNum) إلى قائمة الشهور. هل تريد المتابعة؟';
  }

  @override
  String addNextMonthConfirmBtn(String monthName, int monthNum, int yearNum) {
    return 'إضافة $monthName ($monthNum/$yearNum)';
  }

  @override
  String monthAddedNamedToast(String monthName, int monthNum, int yearNum) {
    return '✅ تم إضافة شهر $monthName ($monthNum/$yearNum) بنجاح';
  }

  @override
  String get adminViewsTitle => 'إحصائيات الزيارات (للمدير فقط)';

  @override
  String get refreshTooltip => 'تحديث';

  @override
  String get viewsStatsLoadingHint =>
      'اضغط تحديث لعرض الإحصائيات (تأكد من تشغيل SQL في Supabase)';

  @override
  String get viewsTotalLabel => 'إجمالي الفتح';

  @override
  String get viewsUniqueLabel => 'زوار فريدون';

  @override
  String get viewsTodayLabel => 'اليوم';

  @override
  String get viewsWeekLabel => '7 أيام';

  @override
  String get viewsUpcomingOpensLabel => 'فتحوا تبويب \"قريباً\"';

  @override
  String get viewsUpcomingVotesLabel => 'مهتمون بخدمات المنطقة 👍';

  @override
  String get navFeedback => 'شكاوى ومقترحات';

  @override
  String get navFeedbackFull => 'الشكاوى والمقترحات';

  @override
  String get navServices => 'خدمات';

  @override
  String get navServicesFull => 'خدمات المنطقة';

  @override
  String get soonBadge => 'قريباً';

  @override
  String tabViewAllPosts(int count) {
    return 'عرض المشاركات ($count)';
  }

  @override
  String get tabAddPost => 'إضافة شكوى / مقترح';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterComplaints => '📢 الشكاوى';

  @override
  String get filterSuggestions => '💡 المقترحات';

  @override
  String get postTypeLabel => 'النوع';

  @override
  String get typeComplaint => '📢 شكوى';

  @override
  String get typeSuggestion => '💡 مقترح';

  @override
  String get errEmptyFeedbackMsg => 'يجب إدخال نص الشكوى أو المقترح أولاً';
}
