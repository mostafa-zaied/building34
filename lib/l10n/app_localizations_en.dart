// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MABNA CARE';

  @override
  String get demoBanner =>
      'Local Demo Mode — Add Supabase keys in lib/config.dart for live deployment';

  @override
  String monthOption(int monthNum, int yearNum) {
    return 'Month $monthNum ($yearNum)';
  }

  @override
  String get editBtn => 'Edit';

  @override
  String get closeBtn => 'Close';

  @override
  String billTitle(int monthNum) {
    return 'Building Expenses — Month $monthNum:';
  }

  @override
  String get copyWhatsAppBtn => 'Copy for WhatsApp';

  @override
  String get waterLabel => 'Water';

  @override
  String get elecLabel => 'Elec';

  @override
  String get elevLabel => 'Elevator';

  @override
  String get cleanLabel => 'Cleaning';

  @override
  String totalExpensesLine(int total, int apts) {
    return '• Total Expenses: $total EGP (÷ $apts apts)';
  }

  @override
  String get sharePerAptLabel => 'Per Apt';

  @override
  String currency(int amount) {
    return '$amount EGP';
  }

  @override
  String get copiedTitle => 'Copied for WhatsApp:';

  @override
  String get copiedToast => 'Updated monthly report copied for WhatsApp';

  @override
  String get aptsCountField => 'Apts:';

  @override
  String get saveChangesBtn => 'Save Changes';

  @override
  String get manageAptsBtn => 'Apts & Passwords';

  @override
  String get tapAptTitle => 'Tap your apartment to record payment';

  @override
  String paidCounter(int paid, int total) {
    return 'Paid $paid of $total';
  }

  @override
  String defaultAptName(int num) {
    return 'Apt $num';
  }

  @override
  String get paidBadge => 'Paid';

  @override
  String get pendingPaymentBadge => 'Pending';

  @override
  String get adminLoginTitle => 'Admin Login';

  @override
  String get adminPassHint => 'Enter admin password...';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get login => 'Login';

  @override
  String get manageAptsTitle => 'Manage Apartment Names & Passwords';

  @override
  String get optionalName => 'Name (optional)';

  @override
  String nameHint(int num) {
    return 'e.g. Apt $num - John';
  }

  @override
  String get passcodeLabel => 'Passcode';

  @override
  String get saveAll => 'Save All';

  @override
  String get saving => 'Saving...';

  @override
  String fileLabel(String name) {
    return 'File: $name';
  }

  @override
  String get cancelPaymentAdmin => 'Cancel Payment (Admin)';

  @override
  String step1Passcode(String demoHint) {
    return '1. Apartment Passcode$demoHint';
  }

  @override
  String get enterPassHint => 'Enter passcode...';

  @override
  String get step2Image => 'Transfer Screenshot (Required)';

  @override
  String get unlockAptSubtitle =>
      'Enter apartment passcode to open details (saved after first time)';

  @override
  String get unlockAptBtn => 'Unlock Apartment';

  @override
  String get receiptRequiredNote =>
      'Please attach the receipt screenshot to verify the paid amount (whether exact, higher, or lower).';

  @override
  String get errReceiptRequired =>
      'Please attach the receipt screenshot before confirming payment.';

  @override
  String get noReceiptAttached => 'Confirmed without receipt image';

  @override
  String get pickImagePrompt => 'Tap here to select receipt image';

  @override
  String chosenFile(String name) {
    return 'Selected: $name';
  }

  @override
  String get confirmPaymentBtn => 'Confirm Payment';

  @override
  String get uploadingBtn => 'Uploading...';

  @override
  String get addApartmentBtn => '+ Add Apartment';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navEmergency => 'Emergency';

  @override
  String get navComplaints => 'Complaints';

  @override
  String get navImprovements => 'Suggestions';

  @override
  String get complaintsTitle => 'Resident Complaints';

  @override
  String get improvementsTitle => 'Suggestions';

  @override
  String get writeComplaintHint => 'Write your complaint clearly...';

  @override
  String get writeImprovementHint =>
      'Share your suggestion to improve the building...';

  @override
  String get postAnonymously => 'Post anonymously (hide apartment name)';

  @override
  String get selectApartment => 'Apartment';

  @override
  String get submitPostBtn => 'Submit';

  @override
  String get anonymousAuthor => 'Anonymous';

  @override
  String get noPostsYet => 'No entries yet';

  @override
  String get postAddedToast => 'Submitted successfully';

  @override
  String tabViewComplaints(int count) {
    return 'Complaints ($count)';
  }

  @override
  String get tabAddComplaint => 'New Complaint';

  @override
  String tabViewImprovements(int count) {
    return 'Suggestions ($count)';
  }

  @override
  String get tabAddImprovement => 'New Suggestion';

  @override
  String get languageTooltip => 'Language';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String errLoadData(String err) {
    return 'Failed to load data: $err';
  }

  @override
  String get monthSavedToast => 'Month changes saved successfully';

  @override
  String get paymentCancelledToast => 'Payment cancelled';

  @override
  String get aptsSavedToast => 'Apartment names & passwords saved';

  @override
  String get errNoMonth => 'No month selected';

  @override
  String get errWrongAdminPass => 'Incorrect admin password';

  @override
  String get errWrongAptPass => 'Incorrect apartment passcode';

  @override
  String errWrongAptPassHint(String hint) {
    return 'Incorrect apartment passcode (try $hint)';
  }

  @override
  String get errPaymentFailed => 'Could not record payment';

  @override
  String get errCancelFailed => 'Could not cancel payment';

  @override
  String get errAptLoadFailed => 'Could not load apartments';

  @override
  String get errAptSaveFailed => 'Could not save apartment';

  @override
  String get errEmptyMessage => 'Message cannot be empty';

  @override
  String get errSubmitFailed => 'Could not submit post';

  @override
  String get errDeleteFailed => 'Could not delete post';

  @override
  String get addNextMonthBtn => 'Next Month';

  @override
  String get monthAddedToast => 'Next month added';

  @override
  String get pinAptPrompt => 'Pin your apartment for quick payment';

  @override
  String get selectAptBtn => 'Select Apt';

  @override
  String get myAptPrefix => 'My Apt';

  @override
  String get payNowBtn => 'Pay Now';

  @override
  String get changeAptTooltip => 'Change apartment';

  @override
  String get emergencyLogTitle => 'Emergency Fund Log';

  @override
  String get emergencyLogEmpty => 'No withdrawals recorded yet.';

  @override
  String get emergencyAmountHint => 'Amount';

  @override
  String get emergencyReasonHint => 'Reason (e.g. water pump repair)';

  @override
  String get recordExpenseBtn => 'Record Expense';

  @override
  String get errEmergencyInput => 'Please enter a valid amount and reason.';

  @override
  String get errEmergencySave => 'Failed to save transaction.';

  @override
  String get pinNoticeBtn => 'Pin Notice';

  @override
  String get noticeDialogTitle => 'Important Building Notice';

  @override
  String get noticeDialogHint => 'e.g. Elevator maintenance on Thursday 10–12';

  @override
  String get hideNoticeBtn => 'Hide';

  @override
  String get adminReplyLabel => 'Admin Reply:';

  @override
  String get updateStatusTitle => 'Update Status & Reply';

  @override
  String get statusFieldLabel => 'Status';

  @override
  String get adminReplyHint => 'Short admin reply (optional)...';

  @override
  String get statusPending => 'Under Review';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get adminLogoutBtn => 'Admin Logout';

  @override
  String get emergencyTabWithdraw => 'Withdraw';

  @override
  String get emergencyTabDeposit => 'Deposit';

  @override
  String get emergencyDepositReasonHint =>
      'Reason (e.g. extra contribution or surplus)';

  @override
  String get recordDepositBtn => 'Record Deposit';

  @override
  String get removeMonthBtn => 'Remove Month';

  @override
  String get monthDeletedToast => 'Month removed successfully';

  @override
  String get errCannotDeleteLastMonth =>
      'Cannot remove the last remaining month';

  @override
  String get deleteMonthConfirmTitle => 'Remove Current Month?';

  @override
  String deleteMonthConfirmBody(int month, int year) {
    return 'Month $month ($year) and all its payments will be permanently deleted.';
  }

  @override
  String get splashTagline => 'Your Building, Our Care.';

  @override
  String get savedPassBadge => 'Your apartment passcode is saved';

  @override
  String get changePassBtn => 'Change';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteBtn => 'Delete';

  @override
  String confirmDeleteAptBody(String apt) {
    return 'Do you want to delete \"$apt\"?';
  }

  @override
  String confirmDeleteTxBody(String amount) {
    return 'Do you want to delete this transaction ($amount)?';
  }

  @override
  String get confirmDeletePostBody =>
      'Do you want to permanently delete this post?';

  @override
  String confirmCancelPaymentBody(String apt) {
    return 'Do you want to cancel the payment for \"$apt\"?';
  }

  @override
  String get instapayTitle => 'InstaPay Transfer';

  @override
  String get instapaySubtitle => 'Transfer to this number, then upload receipt';

  @override
  String get openInstapayBtn => 'Open InstaPay';

  @override
  String get extraChargesBtn => 'Extra Apt Charges';

  @override
  String get extraChargesTitle => 'Extra Apartment Charges';

  @override
  String get selectAptsLabel => 'Select apartment(s):';

  @override
  String get extraAmountHint => 'Extra amount per apartment';

  @override
  String get extraReasonHint => 'Reason (e.g. lock or valve repair)';

  @override
  String get addExtraChargeBtn => 'Add Charge';

  @override
  String get extraChargesListTitle => 'Recorded extra charges this month:';

  @override
  String get noExtraChargesYet => 'No extra charges recorded for this month.';

  @override
  String get monthShareLine => 'Monthly Share';

  @override
  String get totalDueLabel => 'Total Due';

  @override
  String confirmDeleteExtraBody(String amount) {
    return 'Do you want to delete this extra charge ($amount)?';
  }

  @override
  String get extraChargeAddedToast => 'Extra charge added';

  @override
  String extraBadge(int amount) {
    return '+$amount extra';
  }

  @override
  String get upcomingBadge => '🚀 Coming Soon — Upcoming';

  @override
  String get upcomingDirTitle => 'Neighborhood Services Directory';

  @override
  String get upcomingDirSubtitle =>
      'Soon you will be able to add and browse trusted local restaurants, pharmacies, and technicians around the building in one tap.';

  @override
  String get catRestaurants => '🍽️ Restaurants & Cafes';

  @override
  String get catPharmacies => '💊 Pharmacies';

  @override
  String get catSupermarket => '🛒 Supermarkets';

  @override
  String get catProduce => '🥬 Fruits & Vegetables';

  @override
  String get catBakery => '🥖 Bakery & Sweets';

  @override
  String get catMaintenance => '🔧 Maintenance & Techs';

  @override
  String get catLaundry => '🧺 Laundry';

  @override
  String get catCars => '🚗 Car Services';

  @override
  String get catStationery => '📚 Stationery & Print';

  @override
  String get catOther => '📌 Other Services';

  @override
  String get settingsBtn => 'Settings';

  @override
  String get settingsTitle => 'Admin Settings';

  @override
  String get settingsShortTitle => 'Settings';

  @override
  String get adminOnlyPageMsg => 'Admin access only.';

  @override
  String get requirePassOnOpenTitle =>
      'Require Apartment Passcode Before Opening';

  @override
  String get statusEnabled => 'Currently Enabled';

  @override
  String get statusDisabled => 'Currently Disabled';

  @override
  String get requirePassOnOpenDescOn =>
      'When enabled: Residents must enter their apartment passcode from outside before viewing details or paying.';

  @override
  String get requirePassOnOpenDescOff =>
      'When disabled: Apartment details open directly, and the passcode is entered inside the payment dialog.';

  @override
  String get buildingMonthMgmtTitle => 'Building & Month Management';

  @override
  String selectedMonthBadge(String monthName, int monthNum, int yearNum) {
    return 'Selected: $monthName ($monthNum/$yearNum)';
  }

  @override
  String get addNextMonthConfirmTitle => 'Add Next Month?';

  @override
  String addNextMonthConfirmBody(String monthName, int monthNum, int yearNum) {
    return 'Month $monthName ($monthNum/$yearNum) will be added. Do you want to continue?';
  }

  @override
  String addNextMonthConfirmBtn(String monthName, int monthNum, int yearNum) {
    return 'Add $monthName ($monthNum/$yearNum)';
  }

  @override
  String monthAddedNamedToast(String monthName, int monthNum, int yearNum) {
    return '✅ Added $monthName ($monthNum/$yearNum)';
  }

  @override
  String get adminViewsTitle => 'Statistics';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get viewsStatsLoadingHint =>
      'Tap refresh to load stats (ensure Supabase SQL is applied)';

  @override
  String get viewsHeroSubtitle =>
      'Live overview of resident visits and app activity';

  @override
  String get viewsTotalLabel => 'Total Opens';

  @override
  String get viewsTotalSubtitle => 'Total app launches since release';

  @override
  String get viewsUniqueLabel => 'Unique Visitors';

  @override
  String get viewsUniqueSubtitle => 'Distinct devices that opened the app';

  @override
  String get viewsTodayLabel => 'Today\'s Visits';

  @override
  String get viewsTodaySubtitle => 'Launches recorded today';

  @override
  String get viewsAvgPerVisitorLabel => 'Average Opens per Visitor';

  @override
  String get navFeedback => 'Opinions';

  @override
  String get navFeedbackFull => 'Complaints & Suggestions';

  @override
  String get navServices => 'Services';

  @override
  String get navServicesFull => 'Services';

  @override
  String get soonBadge => 'Soon';

  @override
  String tabViewAllPosts(int count) {
    return 'View Posts ($count)';
  }

  @override
  String get tabAddPost => 'Add Post';

  @override
  String get filterAll => 'All';

  @override
  String get filterComplaints => '📢 Complaints';

  @override
  String get filterSuggestions => '💡 Suggestions';

  @override
  String get postTypeLabel => 'Type';

  @override
  String get typeComplaint => '📢 Complaint';

  @override
  String get typeSuggestion => '💡 Suggestion';

  @override
  String get errEmptyFeedbackMsg =>
      'Please enter your complaint or suggestion first';

  @override
  String get viewBillReceiptBtn => 'View Receipt';

  @override
  String get attachBillAfterPayBtn => 'Attach Receipt';

  @override
  String get utilityPaidBadge => 'Paid';

  @override
  String get utilityPendingBadge => 'Pending';

  @override
  String utilityReceiptDialogTitle(String utility) {
    return '$utility Receipt';
  }

  @override
  String get removeUtilityReceiptBtn => 'Remove Receipt';

  @override
  String get utilityReceiptSavedToast => 'Utility receipt saved';

  @override
  String get utilityReceiptRemovedToast => 'Utility receipt removed';

  @override
  String get navContacts => 'Maintenance';

  @override
  String get navContactsFull => 'Maintenance Contacts';

  @override
  String get contactsTitle => 'Building Maintenance Numbers';

  @override
  String get contactsSubtitle =>
      'Any resident can add a trusted technician or maintenance number.';

  @override
  String get addContactBtn => 'Add Number';

  @override
  String get addContactTitle => 'Add Maintenance Number';

  @override
  String get contactNameLabel => 'Name / Service';

  @override
  String get contactNameHint => 'e.g. Eng. Khaled — Electrician';

  @override
  String get contactRoleLabel => 'Role / Description';

  @override
  String get contactRoleHint => 'e.g. Staircase & motor repair';

  @override
  String get contactPhoneLabel => 'Phone Number';

  @override
  String get contactPhoneHint => '01012345678';

  @override
  String get callBtn => 'Call';

  @override
  String get whatsappBtn => 'WhatsApp';

  @override
  String get errContactFields => 'Please enter name and phone number.';

  @override
  String get contactAddedToast => 'Contact added';

  @override
  String confirmDeleteContactBody(String name) {
    return 'Do you want to delete \"$name\" from contacts?';
  }

  @override
  String get noContactsYet => 'No contacts added yet.';

  @override
  String get deleteAllExtraChargesBtn => 'Delete All';

  @override
  String get confirmDeleteAllExtraBody =>
      'Do you want to delete all extra charges for this month from all apartments?';

  @override
  String get selectAllBtn => 'Select All';

  @override
  String get deselectAllBtn => 'Deselect All';

  @override
  String get errSelectAtLeastOneApt =>
      'Please select at least one apartment to add the charge.';

  @override
  String get setupAptPassSubtitle =>
      'Set your apartment passcode for the first time';

  @override
  String get setupAptPassHint =>
      'Choose a passcode for your apartment (at least 4 characters). It will be saved on your device; contact the admin if forgotten.';

  @override
  String get newPasscodeLabel => 'New Passcode';

  @override
  String get confirmPasscodeLabel => 'Confirm Passcode';

  @override
  String get saveAndUnlockBtn => 'Save & Unlock';

  @override
  String get errPassTooShort => 'Passcode must be at least 4 characters.';

  @override
  String get errPassMismatch => 'Passcodes do not match.';

  @override
  String get errPassAlreadySet =>
      'A passcode is already set for this apartment.';

  @override
  String get forgotPassHint =>
      'Forgot passcode? Contact the building admin to reset it.';

  @override
  String get resetPassBtn => 'Reset';

  @override
  String get passNotSetYet => 'Not set yet';

  @override
  String get resetAllPasswordsBtn => 'Reset All Passwords';

  @override
  String get confirmResetAllPasswordsBody =>
      'Do you want to reset passwords for all apartments? Each resident will be asked to set a new passcode.';

  @override
  String get allPasswordsResetToast =>
      'All apartment passwords have been reset';

  @override
  String get drawerExtraSections => 'More Sections';

  @override
  String get drawerPreferences => 'App Preferences';

  @override
  String get drawerThemeLabel => 'Theme';

  @override
  String get drawerThemeDark => 'Dark';

  @override
  String get drawerThemeLight => 'Light';

  @override
  String get drawerLanguageLabel => 'Language';

  @override
  String get drawerAdminSection => 'Administration';

  @override
  String get drawerAdminLogin => 'Admin Login';

  @override
  String get contactManagerBtn => 'Contact Manager';

  @override
  String drawerMyAptLabel(String apt) {
    return 'Your Apt: $apt';
  }

  @override
  String get digitalReceiptTitle => 'Digital Payment Receipt';

  @override
  String get digitalReceiptBrand => 'MABNA CARE • Verified Receipt';

  @override
  String get digitalReceiptStatus => 'Payment Confirmed';

  @override
  String get receiptAptLabel => 'Apartment';

  @override
  String get receiptMonthLabel => 'Billing Month';

  @override
  String get receiptPaidAtLabel => 'Paid At';

  @override
  String get receiptTotalPaidLabel => 'Total Paid';

  @override
  String get receiptStampTitle => 'Electronically Verified';

  @override
  String get receiptSaveImageBtn => 'Save Image';

  @override
  String get receiptSavedToast => 'Receipt image saved successfully';

  @override
  String get receiptSaveNotSupported =>
      'Take a screenshot to save this receipt';

  @override
  String get viewDigitalReceiptBtn => 'View MABNA CARE Digital Receipt';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsAvgShare => 'Avg / Apt';

  @override
  String get analyticsCollectionRate => 'Collected';

  @override
  String get analyticsEmergencyBalance => 'Emergency';

  @override
  String get analyticsChartTitle => 'Monthly Expenses Comparison';

  @override
  String get analyticsChartHint => 'Tap any month to inspect its breakdown';

  @override
  String analyticsBreakdownTitle(String month) {
    return 'Expenses Breakdown — $month';
  }

  @override
  String analyticsCollectionCardTitle(String month) {
    return 'Collection Status — $month';
  }

  @override
  String get analyticsCollectedLabel => 'Collected';

  @override
  String get analyticsRemainingLabel => 'Remaining';

  @override
  String analyticsInsightLower(String month, String pct, String diff) {
    return '$month expenses are $pct% lower than the previous month (saved $diff EGP)';
  }

  @override
  String analyticsInsightHigher(String month, String pct, String diff) {
    return '$month expenses are $pct% higher than the previous month (+$diff EGP)';
  }

  @override
  String analyticsInsightSame(String month) {
    return '$month expenses match the previous month exactly';
  }

  @override
  String analyticsInsightSingle(
    String month,
    String share,
    int paid,
    int total,
  ) {
    return '$month share: $share EGP • $paid of $total paid';
  }

  @override
  String get analyticsNoData => 'Not enough monthly data to analyze yet.';

  @override
  String get pushCardTitle => 'Send Push Notification';

  @override
  String get pushCardSubtitle =>
      'Send an instant alert directly to all subscribed residents.';

  @override
  String get pushTitleLabel => 'Notification Title';

  @override
  String get pushTitleHint =>
      'e.g., Monthly dues reminder or elevator maintenance';

  @override
  String get pushBodyLabel => 'Notification Message';

  @override
  String get pushBodyHint => 'Write your notification details here...';

  @override
  String get pushSendAllBtn => 'Send to All Residents 🚀';

  @override
  String get errPushFieldsRequired =>
      'Please enter both a title and message first.';

  @override
  String get pushSentSuccessToast => 'Notification sent successfully';

  @override
  String get pushNoDevicesToast => 'No devices subscribed to notifications yet';

  @override
  String get pushNotConfiguredToast =>
      'Push system ready — only the Firebase key in Supabase is pending';

  @override
  String get pushSendFailedToast => 'Could not send notification right now';

  @override
  String get pushAutoAnnouncementTitle => '📢 Important Building Announcement';

  @override
  String get pushAutoNewMonthTitle => '🗓️ New Monthly Bill Available';

  @override
  String pushAutoNewMonthBody(String month) {
    return 'Expenses for $month are now live on MABNA CARE.';
  }

  @override
  String get pushAutoPaymentTitle => '🧾 New Payment Uploaded';

  @override
  String pushAutoPaymentBody(String apt) {
    return '$apt uploaded a monthly payment receipt.';
  }

  @override
  String get pushAutoFeedbackTitle => '💬 New Resident Feedback';

  @override
  String get drawerNotificationsLabel => 'Notifications';

  @override
  String get pushEnabledBadge => 'Enabled';

  @override
  String get pushEnableAction => 'Off';

  @override
  String get pushEnabledToast => '🔔 Push notifications enabled on this device';

  @override
  String get pushBlockedToast =>
      'Could not enable notifications (allow notifications in browser settings, or Add to Home Screen on iPhone)';

  @override
  String get pushAudienceAdminOnly => 'Admin Only (Test)';

  @override
  String get pushAudienceAll => 'All Residents';

  @override
  String get pushSendAdminTestBtn => 'Send Test to Admin 🛡️';

  @override
  String get offlineBannerMsg => 'No internet connection';

  @override
  String get onlineRestoredToast => 'Back online — connection restored';

  @override
  String get noNetworkTitle => 'No Internet Connection';

  @override
  String get noNetworkSubtitle =>
      'Check your connection and tap Retry to reload.';

  @override
  String get retryBtn => 'Retry';

  @override
  String get installAppNavLabel => 'How to Install App';

  @override
  String get installAppTitle => 'How to Install MABNA CARE';

  @override
  String get installAppSubtitle =>
      'Install the app on your home screen for 1-tap access without a browser bar and instant notifications.';

  @override
  String get installAppNowBtn => 'Install App Now';

  @override
  String get installAppAlreadyInstalled =>
      'App is already installed on your device ✅';

  @override
  String get installAndroidTitle => 'How to install on Android (Chrome)';

  @override
  String get installAndroidStep1 =>
      'Tap the three dots menu (⋮) at the top corner of Chrome.';

  @override
  String get installAndroidStep2 =>
      'Select \"Install app\" or \"Install and create shortcut\" → \"Install\".';

  @override
  String get installAndroidStep3 =>
      'Tap \"Install\" on the confirmation popup — the app icon will appear on your home screen.';

  @override
  String get installIosTitle => 'How to install on iPhone (Safari)';

  @override
  String get installIosStep1 => 'Make sure you open the link in Safari.';

  @override
  String get installIosStep2 =>
      'Tap the Share icon at the bottom of the screen.';

  @override
  String get installIosStep3 =>
      'Select \"Add to Home Screen\" and then tap \"Add\".';

  @override
  String get notifHistoryTitle => 'Notifications';

  @override
  String get notifMarkAllReadBtn => 'Mark all read ✓';

  @override
  String notifFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String notifFilterUnread(int count) {
    return 'Unread ($count)';
  }

  @override
  String get notifEmptyAll => 'No notifications sent yet.';

  @override
  String get notifEmptyUnread => 'No unread notifications 🎉';

  @override
  String get notifTypeAnnouncement => 'Announcement';

  @override
  String get notifTypeNewMonth => 'Monthly Bill';

  @override
  String get notifTypePayment => 'Payment Alert';

  @override
  String get notifTypeFeedback => 'Resident Feedback';

  @override
  String get notifTypeGeneral => 'Admin Alert';

  @override
  String get confirmDeleteNotifBody =>
      'Do you want to delete this notification from history?';

  @override
  String get addCustomExpenseBtn => 'Add Expense Field';

  @override
  String get addCustomExpenseTitle => 'Add New Expense Field';

  @override
  String get customExpenseNameLabel => 'Field Name';

  @override
  String get customExpenseNameHint => 'e.g. Doorman, Motor Repair, Gas...';

  @override
  String get customExpenseAmountLabel => 'Amount (EGP)';

  @override
  String get customExpenseAddedToast => 'Expense field added & calculated';

  @override
  String get customExpenseRemovedToast =>
      'Expense field removed & recalculated';

  @override
  String get addBtn => 'Add';

  @override
  String get deleteOwnReceiptBtn => 'Delete Receipt & Re-upload';

  @override
  String get confirmDeleteOwnReceiptBody =>
      'Delete this receipt image and reset payment status so you can upload a new one?';

  @override
  String get paymentReceiptDeletedToast =>
      'Receipt deleted — you can now upload a new one';
}
