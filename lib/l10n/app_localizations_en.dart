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
      '🧪 Local Demo Mode — Add Supabase keys in lib/config.dart for live deployment';

  @override
  String monthOption(int monthNum, int yearNum) {
    return 'Month $monthNum ($yearNum)';
  }

  @override
  String emergencyBadge(int amount) {
    return '🛡️ Emergency: $amount EGP';
  }

  @override
  String get editBtn => '⚙️ Edit';

  @override
  String get closeBtn => '✓ Close';

  @override
  String billTitle(int monthNum) {
    return 'Building Expenses — Month $monthNum:';
  }

  @override
  String get copyWhatsAppBtn => 'Copy for WhatsApp';

  @override
  String get waterLabel => '💧 Water';

  @override
  String get elecLabel => '⚡ Elec';

  @override
  String get elevLabel => '🛗 Elevator';

  @override
  String get cleanLabel => '🧹 Cleaning';

  @override
  String get forEmergLabel => '🛡️ Reserve';

  @override
  String totalExpensesLine(int total, int apts) {
    return '• Total Expenses: $total EGP (÷ $apts apts)';
  }

  @override
  String emergencySummaryLine(int total, int base, int added) {
    return '• Emergency Fund: $total EGP ($base avail + $added this month)';
  }

  @override
  String get sharePerAptLabel => 'Per Apt';

  @override
  String currency(int amount) {
    return '$amount EGP';
  }

  @override
  String get copiedTitle => '✅ Copied for WhatsApp:';

  @override
  String get copiedToast => '✅ Updated monthly report copied for WhatsApp';

  @override
  String get aptsCountField => '🏠 Apts:';

  @override
  String get baseEmergField => '💰 Previous Emergency Balance:';

  @override
  String get saveChangesBtn => '💾 Save Changes';

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
  String get paidBadge => '✅ Paid';

  @override
  String get adminLoginTitle => '🔐 Admin Login';

  @override
  String get adminPassHint => 'Enter admin password...';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get login => 'Login';

  @override
  String get manageAptsTitle => '🔑 Manage Apartment Names & Passwords';

  @override
  String get optionalName => 'Name (optional)';

  @override
  String nameHint(int num) {
    return 'e.g. Apt $num - John';
  }

  @override
  String get passcodeLabel => 'Passcode';

  @override
  String get saveAll => '💾 Save All';

  @override
  String get saving => 'Saving...';

  @override
  String fileLabel(String name) {
    return 'File: $name';
  }

  @override
  String get receiptAttachedPreviously => 'Receipt attached previously';

  @override
  String get cancelPaymentAdmin => '❌ Cancel Payment (Admin)';

  @override
  String dueDialogTitle(String aptLabel, int share) {
    return '$aptLabel — Due $share EGP';
  }

  @override
  String step1Passcode(String demoHint) {
    return '1. Apartment Passcode$demoHint';
  }

  @override
  String get enterPassHint => 'Enter passcode...';

  @override
  String get step2Image => '2. Transfer Screenshot (Optional)';

  @override
  String get confirmPaidCheckbox => 'I confirm I have paid this month\'s share';

  @override
  String get errConfirmCheckbox =>
      '❌ Please check the payment confirmation box first!';

  @override
  String get noReceiptAttached => 'Confirmed without receipt image';

  @override
  String get pickImagePrompt => '📸 Tap here to select receipt image';

  @override
  String chosenFile(String name) {
    return '✅ Selected: $name';
  }

  @override
  String get errMissingImage =>
      '❌ Please attach the transfer screenshot first!';

  @override
  String get confirmPaymentBtn => '✅ Confirm Payment';

  @override
  String get uploadingBtn => 'Uploading...';

  @override
  String whatsappHeader(int monthNum, int yearNum) {
    return '🏢 *Building Expenses — Month $monthNum ($yearNum)*';
  }

  @override
  String whatsappTotal(int total) {
    return '💰 *Total:* $total EGP';
  }

  @override
  String whatsappShare(int apts, int share) {
    return '📌 *Share per apartment ($apts apts):* $share EGP';
  }

  @override
  String whatsappEmergency(int total, int base, int added) {
    return '🛡️ *Emergency fund:* $total EGP ($base avail + $added this month)';
  }

  @override
  String get whatsappLinkPrompt =>
      '🔗 *Open the link to mark your payment and attach the receipt:*';

  @override
  String whatsappPaidStatus(int paid, int total) {
    return '✅ *Paid ($paid/$total):*';
  }

  @override
  String get whatsappNonePaid => '• None yet';

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
  String get complaintsTitle => '📢 Resident Complaints';

  @override
  String get improvementsTitle => '💡 Suggestions';

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
  String get anonymousAuthor => '🕵️ Anonymous';

  @override
  String get noPostsYet => 'No entries yet';

  @override
  String get postAddedToast => '✅ Submitted successfully';

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
    return '❌ Failed to load data: $err';
  }

  @override
  String get monthSavedToast => '✅ Month changes saved successfully';

  @override
  String get paymentCancelledToast => '✅ Payment cancelled';

  @override
  String get aptsSavedToast => '✅ Apartment names & passwords saved';

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
  String get monthAddedToast => '✅ Next month added';

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
  String get unpaidReminderBtn => 'Unpaid Reminder';

  @override
  String get emergencyLogBtn => 'Emergency Log';

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
  String get statusPending => '⏳ Under Review';

  @override
  String get statusInProgress => '🔧 In Progress';

  @override
  String get statusResolved => '✅ Resolved';

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
  String get monthDeletedToast => '🗑️ Month removed successfully';

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
}
