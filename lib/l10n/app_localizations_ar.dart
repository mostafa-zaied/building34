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
  String get navEmergency => 'صندوق الطوارئ';

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
  String get adminViewsTitle => 'إحصائيات';

  @override
  String get refreshTooltip => 'تحديث';

  @override
  String get viewsStatsLoadingHint =>
      'اضغط تحديث لعرض الإحصائيات (تأكد من تشغيل SQL في Supabase)';

  @override
  String get viewsHeroSubtitle => 'متابعة حية لنشاط وزيارات السكان على التطبيق';

  @override
  String get viewsTotalLabel => 'إجمالي الفتح';

  @override
  String get viewsTotalSubtitle => 'إجمالي مرات فتح التطبيق منذ الإطلاق';

  @override
  String get viewsUniqueLabel => 'زوار فريدون';

  @override
  String get viewsUniqueSubtitle => 'أجهزة مختلفة فتحت التطبيق';

  @override
  String get viewsTodayLabel => 'زيارات اليوم';

  @override
  String get viewsTodaySubtitle => 'مرات الفتح خلال اليوم الحالي';

  @override
  String get viewsAvgPerVisitorLabel => 'متوسط الفتح لكل زائر';

  @override
  String get navFeedback => 'آراء';

  @override
  String get navFeedbackFull => 'الشكاوى والمقترحات';

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

  @override
  String get viewBillReceiptBtn => 'عرض الفاتورة';

  @override
  String get attachBillAfterPayBtn => 'إرفاق بعد الدفع';

  @override
  String get utilityPendingBadge => 'بانتظار السداد';

  @override
  String utilityReceiptDialogTitle(String utility) {
    return 'صورة $utility';
  }

  @override
  String get removeUtilityReceiptBtn => 'حذف الفاتورة';

  @override
  String get utilityReceiptSavedToast => 'تم حفظ صورة الفاتورة بنجاح';

  @override
  String get utilityReceiptRemovedToast => 'تم حذف صورة الفاتورة';

  @override
  String get navContactsFull => 'أرقام الصيانة';

  @override
  String get contactsTitle => 'أرقام الصيانة للعمارة';

  @override
  String get contactsSubtitle =>
      'يمكن لأي ساكن إضافة رقم فني أو صيانة معتمد للعمارة.';

  @override
  String get addContactBtn => 'إضافة رقم';

  @override
  String get addContactTitle => 'إضافة رقم صيانة';

  @override
  String get contactNameLabel => 'الاسم / الجهة';

  @override
  String get contactNameHint => 'مثال: م/ خالد — كهربائي';

  @override
  String get contactRoleLabel => 'التخصص / الوصف';

  @override
  String get contactRoleHint => 'مثال: أعطال السلم والموتور';

  @override
  String get contactPhoneLabel => 'رقم الهاتف';

  @override
  String get contactPhoneHint => '01012345678';

  @override
  String get callBtn => 'اتصال';

  @override
  String get whatsappBtn => 'واتساب';

  @override
  String get errContactFields => 'برجاء كتابة الاسم ورقم الهاتف أولاً.';

  @override
  String get contactAddedToast => 'تمت إضافة الرقم بنجاح';

  @override
  String confirmDeleteContactBody(String name) {
    return 'هل تريد حذف \"$name\" من قائمة الأرقام؟';
  }

  @override
  String get noContactsYet => 'لا توجد أرقام مسجلة بعد.';

  @override
  String get deleteAllExtraChargesBtn => 'حذف الكل';

  @override
  String get confirmDeleteAllExtraBody =>
      'هل تريد حذف جميع الرسوم الإضافية المسجلة لهذا الشهر من كل الشقق؟';

  @override
  String get selectAllBtn => 'تحديد الكل';

  @override
  String get deselectAllBtn => 'إلغاء الكل';

  @override
  String get errSelectAtLeastOneApt =>
      'من فضلك اختر شقة على الأقل لإضافة الرسوم.';

  @override
  String get setupAptPassSubtitle => 'تعيين كلمة سر شقتك لأول مرة';

  @override
  String get setupAptPassHint =>
      'اختر كلمة سر خاصة بشقتك (4 أحرف أو أرقام على الأقل). ستُحفظ على جهازك، وإذا نسيتها تواصل مع مدير العمارة.';

  @override
  String get newPasscodeLabel => 'كلمة السر الجديدة';

  @override
  String get confirmPasscodeLabel => 'تأكيد كلمة السر';

  @override
  String get saveAndUnlockBtn => 'حفظ وفتح الشقة';

  @override
  String get errPassTooShort => 'كلمة السر يجب أن تكون 4 أحرف/أرقام على الأقل.';

  @override
  String get errPassMismatch => 'كلمتا السر غير متطابقتين.';

  @override
  String get errPassAlreadySet => 'تم تعيين كلمة سر لهذه الشقة بالفعل.';

  @override
  String get forgotPassHint =>
      'نسيت كلمة السر؟ تواصل مع مدير العمارة لإعادة تعيينها.';

  @override
  String get resetPassBtn => 'إعادة تعيين';

  @override
  String get passNotSetYet => 'لم يُعيّنها الساكن بعد';

  @override
  String get resetAllPasswordsBtn => 'إعادة تعيين كل كلمات السر';

  @override
  String get confirmResetAllPasswordsBody =>
      'هل تريد إعادة تعيين كلمة السر لجميع الشقق؟ سيُطلب من كل ساكن تعيين كلمة سر جديدة.';

  @override
  String get allPasswordsResetToast =>
      'تمت إعادة تعيين كلمات السر لجميع الشقق بنجاح';

  @override
  String get drawerExtraSections => 'أقسام إضافية';

  @override
  String get drawerPreferences => 'تفضيلات التطبيق';

  @override
  String get drawerThemeLabel => 'المظهر';

  @override
  String get drawerThemeDark => 'ليلي';

  @override
  String get drawerThemeLight => 'نهاري';

  @override
  String get drawerLanguageLabel => 'اللغة';

  @override
  String get drawerAdminSection => 'الإدارة';

  @override
  String get drawerAdminLogin => 'دخول المسؤول';

  @override
  String get contactManagerBtn => 'تواصل مع المسؤول';

  @override
  String drawerMyAptLabel(String apt) {
    return 'شقتك: $apt';
  }

  @override
  String get digitalReceiptTitle => 'إيصال الدفع الإلكتروني';

  @override
  String get digitalReceiptBrand => 'MABNA CARE • إيصال سداد معتمد';

  @override
  String get digitalReceiptStatus => 'تم السداد بنجاح';

  @override
  String get receiptAptLabel => 'الشقة';

  @override
  String get receiptMonthLabel => 'عن شهر';

  @override
  String get receiptPaidAtLabel => 'تاريخ السداد';

  @override
  String get receiptTotalPaidLabel => 'الإجمالي المدفوع';

  @override
  String get receiptStampTitle => 'معتمد إلكترونياً';

  @override
  String get receiptSaveImageBtn => 'حفظ كصورة';

  @override
  String get receiptSavedToast => 'تم حفظ صورة الإيصال بنجاح';

  @override
  String get receiptSaveNotSupported =>
      'يمكنك أخذ لقطة شاشة (Screenshot) لحفظ الإيصال';

  @override
  String get viewDigitalReceiptBtn => 'عرض إيصال MABNA CARE الإلكتروني';

  @override
  String get navAnalytics => 'التحليلات';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get analyticsAvgShare => 'متوسط الشقة';

  @override
  String get analyticsCollectionRate => 'نسبة التحصيل';

  @override
  String get analyticsEmergencyBalance => 'رصيد الطوارئ';

  @override
  String get analyticsChartTitle => 'مقارنة مصاريف الشهور';

  @override
  String get analyticsChartHint => 'اضغط على أي شهر لعرض توزيع مصاريفه';

  @override
  String analyticsBreakdownTitle(String month) {
    return 'توزيع مصاريف شهر $month';
  }

  @override
  String analyticsCollectionCardTitle(String month) {
    return 'حالة تحصيل شهر $month';
  }

  @override
  String get analyticsCollectedLabel => 'تم تحصيله';

  @override
  String get analyticsRemainingLabel => 'المتبقي';

  @override
  String analyticsInsightLower(String month, String pct, String diff) {
    return 'مصاريف $month أقل بنسبة $pct% عن الشهر السابق (وفر $diff ج)';
  }

  @override
  String analyticsInsightHigher(String month, String pct, String diff) {
    return 'مصاريف $month أعلى بنسبة $pct% عن الشهر السابق (+$diff ج)';
  }

  @override
  String analyticsInsightSame(String month) {
    return 'مصاريف $month مطابقة تماماً للشهر السابق';
  }

  @override
  String analyticsInsightSingle(
    String month,
    String share,
    int paid,
    int total,
  ) {
    return 'نصيب الشقة في $month: $share ج • دفع $paid من $total';
  }

  @override
  String get analyticsNoData => 'لا توجد بيانات شهور كافية للتحليل بعد.';

  @override
  String get pushCardTitle => 'إرسال إشعار فوري للسكان';

  @override
  String get pushCardSubtitle =>
      'أرسل تنبيهاً مباشراً لكل السكان المسجلين من هنا.';

  @override
  String get pushTitleLabel => 'عنوان الإشعار';

  @override
  String get pushTitleHint => 'مثال: تذكير بمصاريف الشهر أو صيانة الأسانسير';

  @override
  String get pushBodyLabel => 'نص الإشعار';

  @override
  String get pushBodyHint => 'اكتب تفاصيل الإشعار هنا...';

  @override
  String get pushSendAllBtn => 'إرسال لكل السكان 🚀';

  @override
  String get errPushFieldsRequired => 'برجاء كتابة عنوان الإشعار والنص أولاً.';

  @override
  String get pushSentSuccessToast => 'تم إرسال الإشعار بنجاح';

  @override
  String get pushNoDevicesToast => 'لا توجد أجهزة مفعّلة للإشعارات بعد';

  @override
  String get pushNotConfiguredToast =>
      'تم تجهيز الإشعارات — يتبقى فقط إضافة مفتاح Firebase في Supabase';

  @override
  String get pushSendFailedToast => 'تعذر إرسال الإشعار حالياً';

  @override
  String get pushAutoAnnouncementTitle => '📢 إعلان هام من إدارة العمارة';

  @override
  String get pushAutoNewMonthTitle => '🗓️ نزول مصاريف الشهر الجديد';

  @override
  String pushAutoNewMonthBody(String month) {
    return 'تم إضافة مصاريف $month — ادخل على MABNA CARE لمعرفة نصيب شقتك.';
  }

  @override
  String get pushAutoPaymentTitle => '🧾 تم تسجيل دفع جديد';

  @override
  String pushAutoPaymentBody(String apt) {
    return '$apt رفعت إيصال سداد مصاريف الشهر.';
  }

  @override
  String get pushAutoFeedbackTitle => '💬 مشاركة جديدة من السكان';

  @override
  String get drawerNotificationsLabel => 'الإشعارات';

  @override
  String get pushEnabledBadge => 'مُفعّلة';

  @override
  String get pushEnableAction => 'غير مفعّلة';

  @override
  String get pushEnabledToast => '🔔 تم تفعيل الإشعارات على جهازك بنجاح';

  @override
  String get pushBlockedToast =>
      'تعذر تفعيل الإشعارات (تأكد من السماح للإشعارات من إعدادات المتصفح أو إضافة التطبيق للشاشة الرئيسية في iPhone)';

  @override
  String get pushAudienceAdminOnly => 'للمدير فقط (تجربة)';

  @override
  String get pushAudienceAll => 'لكل السكان';

  @override
  String get pushSendAdminTestBtn => 'إرسال تجربة للمدير 🛡️';

  @override
  String get offlineBannerMsg => 'لا يوجد اتصال بالإنترنت حالياً';

  @override
  String get onlineRestoredToast => 'عاد الاتصال بالإنترنت بنجاح';

  @override
  String get noNetworkTitle => 'تعذر الاتصال بالإنترنت';

  @override
  String get noNetworkSubtitle =>
      'تأكد من اتصالك بالإنترنت ثم اضغط إعادة المحاولة.';

  @override
  String get retryBtn => 'إعادة المحاولة';

  @override
  String get installAppNavLabel => 'طريقة تثبيت التطبيق';

  @override
  String get installAppTitle => 'طريقة تثبيت MABNA CARE كتطبيق';

  @override
  String get installAppSubtitle =>
      'ثبّت التطبيق على شاشة موبايلك الرئيسية ليفتح بضغطة واحدة بدون متصفح ويستقبل الإشعارات الفورية.';

  @override
  String get installAppNowBtn => 'تثبيت التطبيق الآن';

  @override
  String get installAppAlreadyInstalled => 'التطبيق مثبّت بالفعل على جهازك ✅';

  @override
  String get installAndroidTitle => 'طريقة التثبيت على أندرويد (Chrome)';

  @override
  String get installAndroidStep1 =>
      'اضغط على النقاط الثلاث (⋮) أعلى يسار أو يمين متصفح Chrome.';

  @override
  String get installAndroidStep2 =>
      'اختر \"Install app\" أو \"Install and create shortcut\" ثم اختر \"Install\".';

  @override
  String get installAndroidStep3 =>
      'اضغط \"Install\" في النافذة التي ستظهر — وسيُضاف التطبيق بأيقونته على شاشتك الرئيسية.';

  @override
  String get installIosTitle => 'طريقة التثبيت على آيفون (Safari)';

  @override
  String get installIosStep1 => 'تأكد من فتح الرابط في متصفح Safari.';

  @override
  String get installIosStep2 =>
      'اضغط على أيقونة المشاركة (Share) في أسفل الشاشة.';

  @override
  String get installIosStep3 =>
      'اختر \"Add to Home Screen\" (إضافة إلى الشاشة الرئيسية) ثم اضغط \"Add\".';

  @override
  String get notifHistoryTitle => 'سجل الإشعارات';

  @override
  String get notifMarkAllReadBtn => 'تحديد الكل كمقروء ✓';

  @override
  String notifFilterAll(int count) {
    return 'الكل ($count)';
  }

  @override
  String notifFilterUnread(int count) {
    return 'غير مقروء ($count)';
  }

  @override
  String get notifEmptyAll => 'لا توجد إشعارات مرسلة حتى الآن.';

  @override
  String get notifEmptyUnread => 'لا توجد إشعارات غير مقروءة 🎉';

  @override
  String get notifTypeAnnouncement => 'إعلان هام';

  @override
  String get notifTypeNewMonth => 'مصاريف الشهر';

  @override
  String get notifTypePayment => 'سداد شقة';

  @override
  String get notifTypeFeedback => 'شكاوى ومقترحات';

  @override
  String get notifTypeGeneral => 'تنبيه الإدارة';

  @override
  String get confirmDeleteNotifBody => 'هل تريد حذف هذا الإشعار من السجل؟';

  @override
  String get addCustomExpenseBtn => 'إضافة بند مصاريف';

  @override
  String get addCustomExpenseTitle => 'إضافة بند مصاريف جديد';

  @override
  String get customExpenseNameLabel => 'اسم البند';

  @override
  String get customExpenseNameHint => 'مثال: بواب، صيانة موتور، غاز...';

  @override
  String get customExpenseAmountLabel => 'المبلغ (ج)';

  @override
  String get customExpenseAddedToast => 'تم إضافة البند وحسابه ضمن المصاريف';

  @override
  String get customExpenseRemovedToast => 'تم حذف البند وتحديث الحسابات';

  @override
  String get addBtn => 'إضافة';

  @override
  String get deleteOwnReceiptBtn => 'حذف الإيصال وإعادة الرفع';

  @override
  String get confirmDeleteOwnReceiptBody =>
      'هل تريد حذف صورة الإيصال وإعادة الشقة لحالة غير مدفوع لرفع صورة جديدة؟';

  @override
  String get paymentReceiptDeletedToast =>
      'تم حذف الإيصال، يمكنك الآن رفع صورة جديدة';

  @override
  String dueDateBanner(int month, int day) {
    return 'آخر موعد لسداد مصاريف شهر $month هو يوم $day';
  }

  @override
  String dueDatePassedBanner(int month, int day) {
    return 'انتهى موعد سداد مصاريف شهر $month (يوم $day) — يرجى سرعة السداد';
  }

  @override
  String get overdueBadge => 'متأخر عن السداد';

  @override
  String overdueCountPill(int count) {
    return '$count متأخر';
  }

  @override
  String get dueDayField => 'آخر موعد (يوم)';

  @override
  String get pushAudienceSpecificApt => 'لشقة محددة';

  @override
  String get pushAudienceUnpaid => 'للمتأخرين فقط';

  @override
  String get pushSelectAptsHint =>
      'اختر الشقة أو الشقق (🔔 تعني أن الإشعارات مفعّلة لديها):';

  @override
  String pushUnpaidSummary(int count, int month) {
    return 'سيتم الإرسال لـ $count شقة لم تسدد مصاريف شهر $month';
  }

  @override
  String get pushAllPaidHint => 'جميع الشقق سددت مصاريف الشهر الحالي 🎉';

  @override
  String get pushErrSelectApt => 'اختر شقة واحدة على الأقل للإرسال';

  @override
  String pushSendSelectedBtn(int count) {
    return 'إرسال للشقق المختارة ($count)';
  }

  @override
  String pushSendUnpaidBtn(int count) {
    return 'إرسال تذكير للمتأخرين ($count)';
  }

  @override
  String pushDefaultUnpaidTitle(int month) {
    return 'تذكير بسداد مصاريف شهر $month';
  }

  @override
  String pushDefaultUnpaidBody(int month) {
    return 'يرجى التكرم بسداد مصاريف العمارة لشهر $month ورفع صورة الإيصال عبر التطبيق.';
  }

  @override
  String get adminPrankBioTitle => '🔐 نظام الحماية البيومتري';

  @override
  String get adminPrankBioSub =>
      'ضع إصبعك على الماسح للتحقق من بصمة مدير العمارة';

  @override
  String get adminPrankBioPrompt => 'اضغط على البصمة للتحقق...';

  @override
  String get adminPrankBioScanning =>
      'جاري مطابقة البصمة مع ملفات المخابرات... ⏳';

  @override
  String get adminPrankBioSkip => 'دخول بكلمة السر (للمدير)';

  @override
  String get adminPrankCaughtTitle => 'قفشناك يا جار!';

  @override
  String get adminPrankCaughtBody =>
      'تم تسجيل محاولة انقلاب على الإدارة، وهيتضاف 10 جنيه رسوم فضول على شقتك الشهر الجاي!';

  @override
  String get adminPrankCaughtBackBtn => 'خلاص توبت، ارجع للرئيسية';

  @override
  String get adminPrankCaughtRealBtn => 'أنا المدير فعلاً (إدخال كلمة السر)';

  @override
  String get adminPrankRoast1 => 'غلط يا فندم، بتجرب حظك ولا إيه؟';

  @override
  String get adminPrankRoast2 =>
      'غلط للمرة التانية! واضح إنك حافظ طريق زرار الدخول مش كلمة السر.';

  @override
  String adminPrankRoast3(String attempt) {
    return '🚨 قفشناك تاني! واضح إنك مصمم تهكّر العمارة — الباسورد مش $attempt أكيد';
  }

  @override
  String get adminPrankRoast4 =>
      'خلاص يا نجم ارحم الكيبورد، واضح إنك مش المدير فعلاً!';

  @override
  String adminPrankCooldown(int seconds) {
    return 'استنى $seconds ثواني تهدى وترجع لوعيك';
  }

  @override
  String get changeAdminPassTitle => 'تغيير كلمة سر المدير';

  @override
  String get changeAdminPassSubtitle =>
      'حدّث كلمة السر مباشرة من التطبيق بأمان';

  @override
  String get currentAdminPassLabel => 'كلمة السر الحالية';

  @override
  String get newAdminPassLabel => 'كلمة السر الجديدة';

  @override
  String get confirmNewAdminPassLabel => 'تأكيد كلمة السر الجديدة';

  @override
  String get changeAdminPassSecurityNote =>
      'بمجرد الحفظ، يتم تحديث كلمة السر في قاعدة البيانات وتسجيل خروج أي جهاز آخر تلقائياً.';

  @override
  String get changeAdminPassBtn => 'حفظ كلمة السر الجديدة';

  @override
  String get changeAdminPassFieldsRequired =>
      'يرجى إدخال كلمة السر الحالية والجديدة وتأكيدها.';

  @override
  String get changeAdminPassSuccessToast => '✅ تم تغيير كلمة سر المدير بنجاح';

  @override
  String get passStrengthWeak => 'ضعيفة';

  @override
  String get passStrengthMedium => 'متوسطة';

  @override
  String get passStrengthStrong => 'قوية ✓';

  @override
  String get monthlyReportBtn => 'كشف الحساب (صورة)';

  @override
  String get monthlyReportScreenTitle => 'كشف الحساب الشهري';

  @override
  String get reportDocSubtitle => 'كشف الحساب المالي الشهري للعمارة';

  @override
  String reportIssuedLabel(String date) {
    return 'تاريخ الإصدار: $date';
  }

  @override
  String get reportSectionExpenses => 'تفصيل مصاريف الشهر';

  @override
  String get reportSectionApts => 'كشف سداد الشقق';

  @override
  String get reportColApt => 'الشقة';

  @override
  String get reportColDue => 'المطلوب';

  @override
  String get reportColStatus => 'الحالة';

  @override
  String get reportTotalRow => 'الإجمالي';

  @override
  String get reportTotalExpensesKpi => 'إجمالي المصاريف';

  @override
  String get reportEmergencyBalanceTitle => 'رصيد صندوق الطوارئ الحالي';

  @override
  String get reportSavePngBtn => 'حفظ كشف الحساب كصورة للواتساب';

  @override
  String get reportSavedToast => '✅ تم حفظ صورة كشف الحساب بنجاح';

  @override
  String get reportChipExpenses => 'المصاريف';

  @override
  String get reportChipApts => 'الشقق';

  @override
  String get reportChipEmergency => 'الطوارئ';

  @override
  String reportAptsCountUnit(int count) {
    return '$count شقة';
  }

  @override
  String get errBuildingNotFound => 'لم يتم العثور على عمارة بهذا الكود';

  @override
  String get errWrongSuperPass => 'كلمة سر مالك المنصة غير صحيحة';

  @override
  String get buildingProfileSavedToast => '✅ تم حفظ بيانات العمارة بنجاح';

  @override
  String get copyInstapayNumberBtn => 'نسخ رقم إنستاباي';

  @override
  String get buildingsPortalNavLabel => 'بوابة العمارات (SaaS)';

  @override
  String buildingCodeBadge(String code) {
    return 'كود: $code';
  }

  @override
  String get buildingCodeCopiedToast => '✅ تم نسخ رابط وكود العمارة';

  @override
  String get buildingNotFoundTitle => 'العمارة غير موجودة';

  @override
  String get buildingNotFoundBody =>
      'تأكد من كود العمارة أو ارجع للعمارة الرئيسية أو سجّل عمارة جديدة.';

  @override
  String get returnDefaultBuildingBtn => 'العودة للعمارة الرئيسية';

  @override
  String get openBuildingsPortalBtn => 'فتح بوابة العمارات';

  @override
  String get suspendedTitle => 'انتهت صلاحية الاشتراك مؤقتاً';

  @override
  String suspendedBody(String name, String code) {
    return 'تم إيقاف لوحة عمارة $name (كود: $code) مؤقتاً لانتهاء الفترة التجريبية أو الاشتراك. تواصل مع إدارة MABNA CARE للتفعيل الفوري.';
  }

  @override
  String get contactSupportWhatsappBtn => 'تواصل مع دعم MABNA CARE عبر واتساب';

  @override
  String get switchBuildingBtn => 'تبديل إلى عمارة أخرى';

  @override
  String get buildingProfileTitle => 'هوية وبيانات العمارة';

  @override
  String get buildingProfileSubtitle =>
      'تخصيص اسم العمارة ورقم التحويل والواتساب الخاص بها';

  @override
  String get buildingNameLabel => 'اسم العمارة';

  @override
  String get buildingCityLabel => 'المدينة / المنطقة (اختياري)';

  @override
  String get instapayPhoneLabel => 'رقم تحويل إنستاباي (اختياري)';

  @override
  String get instapayUrlLabel => 'رابط إنستاباي المباشر (اختياري)';

  @override
  String get managerWhatsappLabel => 'رقم واتساب المسؤول (اختياري)';

  @override
  String get saveBuildingProfileBtn => 'حفظ بيانات العمارة';

  @override
  String get shareLinkLabel => 'رابط العمارة للسكان';

  @override
  String get copyLinkBtn => 'نسخ الرابط';

  @override
  String get shareWhatsappBtn => 'مشاركة واتساب';

  @override
  String buildingShareWhatsappMsg(String name, String url, String code) {
    return 'أهلاً بكم في تطبيق $name لمتابعة مصاريف العمارة والمدفوعات:\n$url\nكود العمارة: $code';
  }

  @override
  String get subStatusActive => 'اشتراك نشط';

  @override
  String get subStatusTrial => 'تجربة مجانية';

  @override
  String get subStatusSuspended => 'موقوف';

  @override
  String subDaysRemainingBadge(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String get subExpiredBadge => 'منتهي';

  @override
  String get portalTitle => 'بوابة العمارات — MABNA CARE';

  @override
  String get portalCurrentLabel => 'العمارة المفتوحة حالياً';

  @override
  String get portalJoinTitle => 'الدخول بكود عمارة أخرى';

  @override
  String get portalJoinHint => 'مثال: MBN-A4K2';

  @override
  String get portalJoinBtn => 'دخول';

  @override
  String get portalRegisterCardTitle =>
      'سجّل عمارتك الآن — تجربة 30 يوم مجاناً';

  @override
  String get portalRegisterCardSub =>
      'أنشئ لوحة مستقلة لعمارتك في 30 ثانية برقم سري خاص ورابط مستقل لكل السكان';

  @override
  String get portalRegisterBtn => '+ تسجيل عمارة جديدة';

  @override
  String get portalSavedTitle => 'عمارات تم فتحها مؤخراً';

  @override
  String get portalSavedEmpty => 'لا توجد عمارات إضافية محفوظة بعد.';

  @override
  String get portalDefaultBadge => 'العمارة الرئيسية';

  @override
  String get portalSuperAdminBtn => 'إدارة المنصة • Super Admin';

  @override
  String get registerWizardTitle => 'تسجيل عمارة جديدة';

  @override
  String get registerAptsCountLabel => 'عدد الشقق (1 - 50)';

  @override
  String get registerAdminPassLabel => 'كلمة سر مدير العمارة (4 أحرف فأكثر)';

  @override
  String get registerConfirmPassLabel => 'تأكيد كلمة سر المدير';

  @override
  String get registerSubmitBtn => 'إنشاء العمارة مجاناً (30 يوم)';

  @override
  String get registerNameRequiredErr => 'يرجى إدخال اسم العمارة';

  @override
  String get registerAptsInvalidErr => 'أدخل عدد شقق صحيح بين 1 و 50';

  @override
  String get registerWelcomeTitle => '✅ تم إنشاء عمارتك بنجاح!';

  @override
  String registerWelcomeSub(String name) {
    return 'تم إنشاء لوحة عمارة $name مع تفعيل فترة التجربة المجانية 30 يوم ودخولك كمدير تلقائياً.';
  }

  @override
  String get registerStartManagingBtn => 'ابدأ إدارة عمارتك الآن';

  @override
  String get superAdminTitle => 'لوحة مالك المنصة — Super Admin';

  @override
  String get superAdminLoginTitle => 'دخول مالك منصة MABNA CARE';

  @override
  String get superAdminLoginSub =>
      'أدخل كلمة سر مالك المنصة للتحكم في جميع العمارات وتفعيل أو إيقاف الاشتراكات';

  @override
  String get superAdminPassLabel => 'كلمة سر مالك المنصة';

  @override
  String get superAdminUnlockBtn => 'فتح لوحة المنصة';

  @override
  String get superAdminStatBuildings => 'العمارات';

  @override
  String get superAdminStatActive => 'نشط';

  @override
  String get superAdminStatTrial => 'تجربة';

  @override
  String get superAdminStatSuspended => 'موقوف';

  @override
  String get superAdminStatApts => 'إجمالي الشقق';

  @override
  String get superAdminStatViews => 'زيارات المنصة';

  @override
  String get superAdminSearchHint => 'ابحث باسم العمارة أو الكود أو المدينة...';

  @override
  String get superAdminFilterAll => 'الكل';

  @override
  String get superAdminExtend30Btn => '+30 يوم (تفعيل)';

  @override
  String get superAdminExtendYearBtn => '+سنة';

  @override
  String get superAdminSuspendBtn => 'إيقاف';

  @override
  String get superAdminReactivateBtn => 'إعادة تفعيل';

  @override
  String get superAdminResetPassBtn => 'باسورد المدير';

  @override
  String get superAdminOpenBtn => 'فتح';

  @override
  String superAdminMetricsLine(int apts, int months, int payments, int views) {
    return '$apts شقة • $months شهر • $payments إيصال • $views زيارة';
  }

  @override
  String superAdminResetPassTitle(String name) {
    return 'تغيير كلمة سر مدير $name';
  }

  @override
  String get superAdminNewAdminPassLabel => 'كلمة سر المدير الجديدة';

  @override
  String get superAdminChangePassTitle => 'تغيير كلمة سر مالك المنصة';

  @override
  String get superAdminChangePassSuccessToast =>
      '✅ تم تحديث كلمة سر مالك المنصة';

  @override
  String get superAdminActionDoneToast => '✅ تم تنفيذ العملية بنجاح';

  @override
  String get superAdminNoBuildingsMatch => 'لا توجد عمارات مطابقة للبحث';
}
