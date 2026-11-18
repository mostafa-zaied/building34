import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MABNA CARE'**
  String get appTitle;

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'Local Demo Mode — Add Supabase keys in lib/config.dart for live deployment'**
  String get demoBanner;

  /// No description provided for @monthOption.
  ///
  /// In en, this message translates to:
  /// **'Month {monthNum} ({yearNum})'**
  String monthOption(int monthNum, int yearNum);

  /// No description provided for @editBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editBtn;

  /// No description provided for @closeBtn.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeBtn;

  /// No description provided for @billTitle.
  ///
  /// In en, this message translates to:
  /// **'Building Expenses — Month {monthNum}:'**
  String billTitle(int monthNum);

  /// No description provided for @copyWhatsAppBtn.
  ///
  /// In en, this message translates to:
  /// **'Copy for WhatsApp'**
  String get copyWhatsAppBtn;

  /// No description provided for @waterLabel.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterLabel;

  /// No description provided for @elecLabel.
  ///
  /// In en, this message translates to:
  /// **'Elec'**
  String get elecLabel;

  /// No description provided for @elevLabel.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get elevLabel;

  /// No description provided for @cleanLabel.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleanLabel;

  /// No description provided for @totalExpensesLine.
  ///
  /// In en, this message translates to:
  /// **'• Total Expenses: {total} EGP (÷ {apts} apts)'**
  String totalExpensesLine(int total, int apts);

  /// No description provided for @sharePerAptLabel.
  ///
  /// In en, this message translates to:
  /// **'Per Apt'**
  String get sharePerAptLabel;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'{amount} EGP'**
  String currency(int amount);

  /// No description provided for @copiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Copied for WhatsApp:'**
  String get copiedTitle;

  /// No description provided for @copiedToast.
  ///
  /// In en, this message translates to:
  /// **'Updated monthly report copied for WhatsApp'**
  String get copiedToast;

  /// No description provided for @aptsCountField.
  ///
  /// In en, this message translates to:
  /// **'Apts:'**
  String get aptsCountField;

  /// No description provided for @saveChangesBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesBtn;

  /// No description provided for @manageAptsBtn.
  ///
  /// In en, this message translates to:
  /// **'Apts & Passwords'**
  String get manageAptsBtn;

  /// No description provided for @tapAptTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap your apartment to record payment'**
  String get tapAptTitle;

  /// No description provided for @paidCounter.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} of {total}'**
  String paidCounter(int paid, int total);

  /// No description provided for @defaultAptName.
  ///
  /// In en, this message translates to:
  /// **'Apt {num}'**
  String defaultAptName(int num);

  /// No description provided for @paidBadge.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidBadge;

  /// No description provided for @pendingPaymentBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingPaymentBadge;

  /// No description provided for @adminLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLoginTitle;

  /// No description provided for @adminPassHint.
  ///
  /// In en, this message translates to:
  /// **'Enter admin password...'**
  String get adminPassHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @manageAptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Apartment Names & Passwords'**
  String get manageAptsTitle;

  /// No description provided for @optionalName.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get optionalName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Apt {num} - John'**
  String nameHint(int num);

  /// No description provided for @passcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get passcodeLabel;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveAll;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @fileLabel.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String fileLabel(String name);

  /// No description provided for @cancelPaymentAdmin.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payment (Admin)'**
  String get cancelPaymentAdmin;

  /// No description provided for @step1Passcode.
  ///
  /// In en, this message translates to:
  /// **'1. Apartment Passcode{demoHint}'**
  String step1Passcode(String demoHint);

  /// No description provided for @enterPassHint.
  ///
  /// In en, this message translates to:
  /// **'Enter passcode...'**
  String get enterPassHint;

  /// No description provided for @step2Image.
  ///
  /// In en, this message translates to:
  /// **'Transfer Screenshot (Required)'**
  String get step2Image;

  /// No description provided for @unlockAptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter apartment passcode to open details (saved after first time)'**
  String get unlockAptSubtitle;

  /// No description provided for @unlockAptBtn.
  ///
  /// In en, this message translates to:
  /// **'Unlock Apartment'**
  String get unlockAptBtn;

  /// No description provided for @receiptRequiredNote.
  ///
  /// In en, this message translates to:
  /// **'Please attach the receipt screenshot to verify the paid amount (whether exact, higher, or lower).'**
  String get receiptRequiredNote;

  /// No description provided for @errReceiptRequired.
  ///
  /// In en, this message translates to:
  /// **'Please attach the receipt screenshot before confirming payment.'**
  String get errReceiptRequired;

  /// No description provided for @noReceiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Confirmed without receipt image'**
  String get noReceiptAttached;

  /// No description provided for @pickImagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap here to select receipt image'**
  String get pickImagePrompt;

  /// No description provided for @chosenFile.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String chosenFile(String name);

  /// No description provided for @confirmPaymentBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPaymentBtn;

  /// No description provided for @uploadingBtn.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingBtn;

  /// No description provided for @addApartmentBtn.
  ///
  /// In en, this message translates to:
  /// **'+ Add Apartment'**
  String get addApartmentBtn;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get navEmergency;

  /// No description provided for @navComplaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get navComplaints;

  /// No description provided for @navImprovements.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get navImprovements;

  /// No description provided for @complaintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Resident Complaints'**
  String get complaintsTitle;

  /// No description provided for @improvementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get improvementsTitle;

  /// No description provided for @writeComplaintHint.
  ///
  /// In en, this message translates to:
  /// **'Write your complaint clearly...'**
  String get writeComplaintHint;

  /// No description provided for @writeImprovementHint.
  ///
  /// In en, this message translates to:
  /// **'Share your suggestion to improve the building...'**
  String get writeImprovementHint;

  /// No description provided for @postAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Post anonymously (hide apartment name)'**
  String get postAnonymously;

  /// No description provided for @selectApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get selectApartment;

  /// No description provided for @submitPostBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitPostBtn;

  /// No description provided for @anonymousAuthor.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymousAuthor;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noPostsYet;

  /// No description provided for @postAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Submitted successfully'**
  String get postAddedToast;

  /// No description provided for @tabViewComplaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints ({count})'**
  String tabViewComplaints(int count);

  /// No description provided for @tabAddComplaint.
  ///
  /// In en, this message translates to:
  /// **'New Complaint'**
  String get tabAddComplaint;

  /// No description provided for @tabViewImprovements.
  ///
  /// In en, this message translates to:
  /// **'Suggestions ({count})'**
  String tabViewImprovements(int count);

  /// No description provided for @tabAddImprovement.
  ///
  /// In en, this message translates to:
  /// **'New Suggestion'**
  String get tabAddImprovement;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @errLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {err}'**
  String errLoadData(String err);

  /// No description provided for @monthSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Month changes saved successfully'**
  String get monthSavedToast;

  /// No description provided for @paymentCancelledToast.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelledToast;

  /// No description provided for @aptsSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Apartment names & passwords saved'**
  String get aptsSavedToast;

  /// No description provided for @errNoMonth.
  ///
  /// In en, this message translates to:
  /// **'No month selected'**
  String get errNoMonth;

  /// No description provided for @errWrongAdminPass.
  ///
  /// In en, this message translates to:
  /// **'Incorrect admin password'**
  String get errWrongAdminPass;

  /// No description provided for @errWrongAptPass.
  ///
  /// In en, this message translates to:
  /// **'Incorrect apartment passcode'**
  String get errWrongAptPass;

  /// No description provided for @errWrongAptPassHint.
  ///
  /// In en, this message translates to:
  /// **'Incorrect apartment passcode (try {hint})'**
  String errWrongAptPassHint(String hint);

  /// No description provided for @errPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not record payment'**
  String get errPaymentFailed;

  /// No description provided for @errCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel payment'**
  String get errCancelFailed;

  /// No description provided for @errAptLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load apartments'**
  String get errAptLoadFailed;

  /// No description provided for @errAptSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save apartment'**
  String get errAptSaveFailed;

  /// No description provided for @errEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty'**
  String get errEmptyMessage;

  /// No description provided for @errSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit post'**
  String get errSubmitFailed;

  /// No description provided for @errDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete post'**
  String get errDeleteFailed;

  /// No description provided for @addNextMonthBtn.
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get addNextMonthBtn;

  /// No description provided for @monthAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Next month added'**
  String get monthAddedToast;

  /// No description provided for @pinAptPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pin your apartment for quick payment'**
  String get pinAptPrompt;

  /// No description provided for @selectAptBtn.
  ///
  /// In en, this message translates to:
  /// **'Select Apt'**
  String get selectAptBtn;

  /// No description provided for @myAptPrefix.
  ///
  /// In en, this message translates to:
  /// **'My Apt'**
  String get myAptPrefix;

  /// No description provided for @payNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNowBtn;

  /// No description provided for @changeAptTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change apartment'**
  String get changeAptTooltip;

  /// No description provided for @emergencyLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund Log'**
  String get emergencyLogTitle;

  /// No description provided for @emergencyLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No withdrawals recorded yet.'**
  String get emergencyLogEmpty;

  /// No description provided for @emergencyAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get emergencyAmountHint;

  /// No description provided for @emergencyReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (e.g. water pump repair)'**
  String get emergencyReasonHint;

  /// No description provided for @recordExpenseBtn.
  ///
  /// In en, this message translates to:
  /// **'Record Expense'**
  String get recordExpenseBtn;

  /// No description provided for @errEmergencyInput.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount and reason.'**
  String get errEmergencyInput;

  /// No description provided for @errEmergencySave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save transaction.'**
  String get errEmergencySave;

  /// No description provided for @pinNoticeBtn.
  ///
  /// In en, this message translates to:
  /// **'Pin Notice'**
  String get pinNoticeBtn;

  /// No description provided for @noticeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Building Notice'**
  String get noticeDialogTitle;

  /// No description provided for @noticeDialogHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Elevator maintenance on Thursday 10–12'**
  String get noticeDialogHint;

  /// No description provided for @hideNoticeBtn.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideNoticeBtn;

  /// No description provided for @adminReplyLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Reply:'**
  String get adminReplyLabel;

  /// No description provided for @updateStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Status & Reply'**
  String get updateStatusTitle;

  /// No description provided for @statusFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusFieldLabel;

  /// No description provided for @adminReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Short admin reply (optional)...'**
  String get adminReplyHint;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @adminLogoutBtn.
  ///
  /// In en, this message translates to:
  /// **'Admin Logout'**
  String get adminLogoutBtn;

  /// No description provided for @emergencyTabWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get emergencyTabWithdraw;

  /// No description provided for @emergencyTabDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get emergencyTabDeposit;

  /// No description provided for @emergencyDepositReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (e.g. extra contribution or surplus)'**
  String get emergencyDepositReasonHint;

  /// No description provided for @recordDepositBtn.
  ///
  /// In en, this message translates to:
  /// **'Record Deposit'**
  String get recordDepositBtn;

  /// No description provided for @removeMonthBtn.
  ///
  /// In en, this message translates to:
  /// **'Remove Month'**
  String get removeMonthBtn;

  /// No description provided for @monthDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Month removed successfully'**
  String get monthDeletedToast;

  /// No description provided for @errCannotDeleteLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove the last remaining month'**
  String get errCannotDeleteLastMonth;

  /// No description provided for @deleteMonthConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Current Month?'**
  String get deleteMonthConfirmTitle;

  /// No description provided for @deleteMonthConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Month {month} ({year}) and all its payments will be permanently deleted.'**
  String deleteMonthConfirmBody(int month, int year);

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Building, Our Care.'**
  String get splashTagline;

  /// No description provided for @savedPassBadge.
  ///
  /// In en, this message translates to:
  /// **'Your apartment passcode is saved'**
  String get savedPassBadge;

  /// No description provided for @changePassBtn.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changePassBtn;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDeleteBtn;

  /// No description provided for @confirmDeleteAptBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{apt}\"?'**
  String confirmDeleteAptBody(String apt);

  /// No description provided for @confirmDeleteTxBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this transaction ({amount})?'**
  String confirmDeleteTxBody(String amount);

  /// No description provided for @confirmDeletePostBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to permanently delete this post?'**
  String get confirmDeletePostBody;

  /// No description provided for @confirmCancelPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel the payment for \"{apt}\"?'**
  String confirmCancelPaymentBody(String apt);

  /// No description provided for @instapayTitle.
  ///
  /// In en, this message translates to:
  /// **'InstaPay Transfer'**
  String get instapayTitle;

  /// No description provided for @instapaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer to this number, then upload receipt'**
  String get instapaySubtitle;

  /// No description provided for @openInstapayBtn.
  ///
  /// In en, this message translates to:
  /// **'Open InstaPay'**
  String get openInstapayBtn;

  /// No description provided for @extraChargesBtn.
  ///
  /// In en, this message translates to:
  /// **'Extra Apt Charges'**
  String get extraChargesBtn;

  /// No description provided for @extraChargesTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra Apartment Charges'**
  String get extraChargesTitle;

  /// No description provided for @selectAptsLabel.
  ///
  /// In en, this message translates to:
  /// **'Select apartment(s):'**
  String get selectAptsLabel;

  /// No description provided for @extraAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Extra amount per apartment'**
  String get extraAmountHint;

  /// No description provided for @extraReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (e.g. lock or valve repair)'**
  String get extraReasonHint;

  /// No description provided for @addExtraChargeBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Charge'**
  String get addExtraChargeBtn;

  /// No description provided for @extraChargesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded extra charges this month:'**
  String get extraChargesListTitle;

  /// No description provided for @noExtraChargesYet.
  ///
  /// In en, this message translates to:
  /// **'No extra charges recorded for this month.'**
  String get noExtraChargesYet;

  /// No description provided for @monthShareLine.
  ///
  /// In en, this message translates to:
  /// **'Monthly Share'**
  String get monthShareLine;

  /// No description provided for @totalDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDueLabel;

  /// No description provided for @confirmDeleteExtraBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this extra charge ({amount})?'**
  String confirmDeleteExtraBody(String amount);

  /// No description provided for @extraChargeAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Extra charge added'**
  String get extraChargeAddedToast;

  /// No description provided for @extraBadge.
  ///
  /// In en, this message translates to:
  /// **'+{amount} extra'**
  String extraBadge(int amount);

  /// No description provided for @upcomingBadge.
  ///
  /// In en, this message translates to:
  /// **'🚀 Coming Soon — Upcoming'**
  String get upcomingBadge;

  /// No description provided for @upcomingDirTitle.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood Services Directory'**
  String get upcomingDirTitle;

  /// No description provided for @upcomingDirSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soon you will be able to add and browse trusted local restaurants, pharmacies, and technicians around the building in one tap.'**
  String get upcomingDirSubtitle;

  /// No description provided for @upcomingInterestedBtn.
  ///
  /// In en, this message translates to:
  /// **'I am interested 👍'**
  String get upcomingInterestedBtn;

  /// No description provided for @upcomingVotedBtn.
  ///
  /// In en, this message translates to:
  /// **'Interest recorded'**
  String get upcomingVotedBtn;

  /// No description provided for @upcomingHintBefore.
  ///
  /// In en, this message translates to:
  /// **'Let us know if this service would be helpful to you.'**
  String get upcomingHintBefore;

  /// No description provided for @upcomingHintAfter.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing! Your feedback means a lot to us.'**
  String get upcomingHintAfter;

  /// No description provided for @catRestaurants.
  ///
  /// In en, this message translates to:
  /// **'🍽️ Restaurants & Cafes'**
  String get catRestaurants;

  /// No description provided for @catPharmacies.
  ///
  /// In en, this message translates to:
  /// **'💊 Pharmacies'**
  String get catPharmacies;

  /// No description provided for @catSupermarket.
  ///
  /// In en, this message translates to:
  /// **'🛒 Supermarkets'**
  String get catSupermarket;

  /// No description provided for @catProduce.
  ///
  /// In en, this message translates to:
  /// **'🥬 Fruits & Vegetables'**
  String get catProduce;

  /// No description provided for @catBakery.
  ///
  /// In en, this message translates to:
  /// **'🥖 Bakery & Sweets'**
  String get catBakery;

  /// No description provided for @catMaintenance.
  ///
  /// In en, this message translates to:
  /// **'🔧 Maintenance & Techs'**
  String get catMaintenance;

  /// No description provided for @catLaundry.
  ///
  /// In en, this message translates to:
  /// **'🧺 Laundry'**
  String get catLaundry;

  /// No description provided for @catCars.
  ///
  /// In en, this message translates to:
  /// **'🚗 Car Services'**
  String get catCars;

  /// No description provided for @catStationery.
  ///
  /// In en, this message translates to:
  /// **'📚 Stationery & Print'**
  String get catStationery;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'📌 Other Services'**
  String get catOther;

  /// No description provided for @settingsBtn.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsBtn;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get settingsTitle;

  /// No description provided for @settingsShortTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsShortTitle;

  /// No description provided for @adminOnlyPageMsg.
  ///
  /// In en, this message translates to:
  /// **'Admin access only.'**
  String get adminOnlyPageMsg;

  /// No description provided for @requirePassOnOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Require Apartment Passcode Before Opening'**
  String get requirePassOnOpenTitle;

  /// No description provided for @statusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Currently Enabled'**
  String get statusEnabled;

  /// No description provided for @statusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Currently Disabled'**
  String get statusDisabled;

  /// No description provided for @requirePassOnOpenDescOn.
  ///
  /// In en, this message translates to:
  /// **'When enabled: Residents must enter their apartment passcode from outside before viewing details or paying.'**
  String get requirePassOnOpenDescOn;

  /// No description provided for @requirePassOnOpenDescOff.
  ///
  /// In en, this message translates to:
  /// **'When disabled: Apartment details open directly, and the passcode is entered inside the payment dialog.'**
  String get requirePassOnOpenDescOff;

  /// No description provided for @buildingMonthMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Building & Month Management'**
  String get buildingMonthMgmtTitle;

  /// No description provided for @selectedMonthBadge.
  ///
  /// In en, this message translates to:
  /// **'Selected: {monthName} ({monthNum}/{yearNum})'**
  String selectedMonthBadge(String monthName, int monthNum, int yearNum);

  /// No description provided for @addNextMonthConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Next Month?'**
  String get addNextMonthConfirmTitle;

  /// No description provided for @addNextMonthConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Month {monthName} ({monthNum}/{yearNum}) will be added. Do you want to continue?'**
  String addNextMonthConfirmBody(String monthName, int monthNum, int yearNum);

  /// No description provided for @addNextMonthConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Add {monthName} ({monthNum}/{yearNum})'**
  String addNextMonthConfirmBtn(String monthName, int monthNum, int yearNum);

  /// No description provided for @monthAddedNamedToast.
  ///
  /// In en, this message translates to:
  /// **'✅ Added {monthName} ({monthNum}/{yearNum})'**
  String monthAddedNamedToast(String monthName, int monthNum, int yearNum);

  /// No description provided for @adminViewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Views (Admin Only)'**
  String get adminViewsTitle;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @viewsStatsLoadingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh to load stats (ensure Supabase SQL is applied)'**
  String get viewsStatsLoadingHint;

  /// No description provided for @viewsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get viewsTotalLabel;

  /// No description provided for @viewsUniqueLabel.
  ///
  /// In en, this message translates to:
  /// **'Unique'**
  String get viewsUniqueLabel;

  /// No description provided for @viewsTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get viewsTodayLabel;

  /// No description provided for @viewsWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get viewsWeekLabel;

  /// No description provided for @viewsUpcomingOpensLabel.
  ///
  /// In en, this message translates to:
  /// **'Opened Soon'**
  String get viewsUpcomingOpensLabel;

  /// No description provided for @viewsUpcomingVotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Interested 👍'**
  String get viewsUpcomingVotesLabel;

  /// No description provided for @navFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get navFeedback;

  /// No description provided for @navFeedbackFull.
  ///
  /// In en, this message translates to:
  /// **'Complaints & Suggestions'**
  String get navFeedbackFull;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navServicesFull.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServicesFull;

  /// No description provided for @soonBadge.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soonBadge;

  /// No description provided for @tabViewAllPosts.
  ///
  /// In en, this message translates to:
  /// **'View Posts ({count})'**
  String tabViewAllPosts(int count);

  /// No description provided for @tabAddPost.
  ///
  /// In en, this message translates to:
  /// **'Add Post'**
  String get tabAddPost;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterComplaints.
  ///
  /// In en, this message translates to:
  /// **'📢 Complaints'**
  String get filterComplaints;

  /// No description provided for @filterSuggestions.
  ///
  /// In en, this message translates to:
  /// **'💡 Suggestions'**
  String get filterSuggestions;

  /// No description provided for @postTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get postTypeLabel;

  /// No description provided for @typeComplaint.
  ///
  /// In en, this message translates to:
  /// **'📢 Complaint'**
  String get typeComplaint;

  /// No description provided for @typeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'💡 Suggestion'**
  String get typeSuggestion;

  /// No description provided for @errEmptyFeedbackMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter your complaint or suggestion first'**
  String get errEmptyFeedbackMsg;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
