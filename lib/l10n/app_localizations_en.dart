// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Building Expenses';

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
  String get adminSectionHint =>
      '⚙️ Edit Month Items (hover/focus a field to highlight its card):';

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
  String get step2Image => '2. Transfer Screenshot (Required)';

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
  String get navComplaints => 'Complaints';

  @override
  String get navImprovements => 'Improvements';

  @override
  String get complaintsTitle => '📢 Resident Complaints';

  @override
  String get improvementsTitle => '💡 Building Improvements';

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
}
