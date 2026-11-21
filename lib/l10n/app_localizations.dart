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
  /// **'Statistics'**
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

  /// No description provided for @viewsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live overview of resident visits and app activity'**
  String get viewsHeroSubtitle;

  /// No description provided for @viewsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Opens'**
  String get viewsTotalLabel;

  /// No description provided for @viewsTotalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total app launches since release'**
  String get viewsTotalSubtitle;

  /// No description provided for @viewsUniqueLabel.
  ///
  /// In en, this message translates to:
  /// **'Unique Visitors'**
  String get viewsUniqueLabel;

  /// No description provided for @viewsUniqueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Distinct devices that opened the app'**
  String get viewsUniqueSubtitle;

  /// No description provided for @viewsTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Visits'**
  String get viewsTodayLabel;

  /// No description provided for @viewsTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Launches recorded today'**
  String get viewsTodaySubtitle;

  /// No description provided for @viewsAvgPerVisitorLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Opens per Visitor'**
  String get viewsAvgPerVisitorLabel;

  /// No description provided for @navFeedback.
  ///
  /// In en, this message translates to:
  /// **'Opinions'**
  String get navFeedback;

  /// No description provided for @navFeedbackFull.
  ///
  /// In en, this message translates to:
  /// **'Complaints & Suggestions'**
  String get navFeedbackFull;

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

  /// No description provided for @viewBillReceiptBtn.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewBillReceiptBtn;

  /// No description provided for @attachBillAfterPayBtn.
  ///
  /// In en, this message translates to:
  /// **'Attach Receipt'**
  String get attachBillAfterPayBtn;

  /// No description provided for @utilityPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get utilityPendingBadge;

  /// No description provided for @utilityReceiptDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{utility} Receipt'**
  String utilityReceiptDialogTitle(String utility);

  /// No description provided for @removeUtilityReceiptBtn.
  ///
  /// In en, this message translates to:
  /// **'Remove Receipt'**
  String get removeUtilityReceiptBtn;

  /// No description provided for @utilityReceiptSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Utility receipt saved'**
  String get utilityReceiptSavedToast;

  /// No description provided for @utilityReceiptRemovedToast.
  ///
  /// In en, this message translates to:
  /// **'Utility receipt removed'**
  String get utilityReceiptRemovedToast;

  /// No description provided for @navContactsFull.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Contacts'**
  String get navContactsFull;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Building Maintenance Numbers'**
  String get contactsTitle;

  /// No description provided for @contactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Any resident can add a trusted technician or maintenance number.'**
  String get contactsSubtitle;

  /// No description provided for @addContactBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Number'**
  String get addContactBtn;

  /// No description provided for @addContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Maintenance Number'**
  String get addContactTitle;

  /// No description provided for @contactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name / Service'**
  String get contactNameLabel;

  /// No description provided for @contactNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Eng. Khaled — Electrician'**
  String get contactNameHint;

  /// No description provided for @contactRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role / Description'**
  String get contactRoleLabel;

  /// No description provided for @contactRoleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Staircase & motor repair'**
  String get contactRoleHint;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get contactPhoneLabel;

  /// No description provided for @contactPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'01012345678'**
  String get contactPhoneHint;

  /// No description provided for @callBtn.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callBtn;

  /// No description provided for @whatsappBtn.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappBtn;

  /// No description provided for @errContactFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter name and phone number.'**
  String get errContactFields;

  /// No description provided for @contactAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Contact added'**
  String get contactAddedToast;

  /// No description provided for @confirmDeleteContactBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{name}\" from contacts?'**
  String confirmDeleteContactBody(String name);

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No contacts added yet.'**
  String get noContactsYet;

  /// No description provided for @deleteAllExtraChargesBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAllExtraChargesBtn;

  /// No description provided for @confirmDeleteAllExtraBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete all extra charges for this month from all apartments?'**
  String get confirmDeleteAllExtraBody;

  /// No description provided for @selectAllBtn.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAllBtn;

  /// No description provided for @deselectAllBtn.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAllBtn;

  /// No description provided for @errSelectAtLeastOneApt.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one apartment to add the charge.'**
  String get errSelectAtLeastOneApt;

  /// No description provided for @setupAptPassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your apartment passcode for the first time'**
  String get setupAptPassSubtitle;

  /// No description provided for @setupAptPassHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a passcode for your apartment (at least 4 characters). It will be saved on your device; contact the admin if forgotten.'**
  String get setupAptPassHint;

  /// No description provided for @newPasscodeLabel.
  ///
  /// In en, this message translates to:
  /// **'New Passcode'**
  String get newPasscodeLabel;

  /// No description provided for @confirmPasscodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Passcode'**
  String get confirmPasscodeLabel;

  /// No description provided for @saveAndUnlockBtn.
  ///
  /// In en, this message translates to:
  /// **'Save & Unlock'**
  String get saveAndUnlockBtn;

  /// No description provided for @errPassTooShort.
  ///
  /// In en, this message translates to:
  /// **'Passcode must be at least 4 characters.'**
  String get errPassTooShort;

  /// No description provided for @errPassMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passcodes do not match.'**
  String get errPassMismatch;

  /// No description provided for @errPassAlreadySet.
  ///
  /// In en, this message translates to:
  /// **'A passcode is already set for this apartment.'**
  String get errPassAlreadySet;

  /// No description provided for @forgotPassHint.
  ///
  /// In en, this message translates to:
  /// **'Forgot passcode? Contact the building admin to reset it.'**
  String get forgotPassHint;

  /// No description provided for @resetPassBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetPassBtn;

  /// No description provided for @passNotSetYet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get passNotSetYet;

  /// No description provided for @resetAllPasswordsBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset All Passwords'**
  String get resetAllPasswordsBtn;

  /// No description provided for @confirmResetAllPasswordsBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset passwords for all apartments? Each resident will be asked to set a new passcode.'**
  String get confirmResetAllPasswordsBody;

  /// No description provided for @allPasswordsResetToast.
  ///
  /// In en, this message translates to:
  /// **'All apartment passwords have been reset'**
  String get allPasswordsResetToast;

  /// No description provided for @drawerExtraSections.
  ///
  /// In en, this message translates to:
  /// **'More Sections'**
  String get drawerExtraSections;

  /// No description provided for @drawerPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get drawerPreferences;

  /// No description provided for @drawerThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get drawerThemeLabel;

  /// No description provided for @drawerThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get drawerThemeDark;

  /// No description provided for @drawerThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get drawerThemeLight;

  /// No description provided for @drawerLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get drawerLanguageLabel;

  /// No description provided for @drawerAdminSection.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get drawerAdminSection;

  /// No description provided for @drawerAdminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get drawerAdminLogin;

  /// No description provided for @contactManagerBtn.
  ///
  /// In en, this message translates to:
  /// **'Contact Manager'**
  String get contactManagerBtn;

  /// No description provided for @drawerMyAptLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Apt: {apt}'**
  String drawerMyAptLabel(String apt);

  /// No description provided for @digitalReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Payment Receipt'**
  String get digitalReceiptTitle;

  /// No description provided for @digitalReceiptBrand.
  ///
  /// In en, this message translates to:
  /// **'MABNA CARE • Verified Receipt'**
  String get digitalReceiptBrand;

  /// No description provided for @digitalReceiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed'**
  String get digitalReceiptStatus;

  /// No description provided for @receiptAptLabel.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get receiptAptLabel;

  /// No description provided for @receiptMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing Month'**
  String get receiptMonthLabel;

  /// No description provided for @receiptPaidAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid At'**
  String get receiptPaidAtLabel;

  /// No description provided for @receiptTotalPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get receiptTotalPaidLabel;

  /// No description provided for @receiptStampTitle.
  ///
  /// In en, this message translates to:
  /// **'Electronically Verified'**
  String get receiptStampTitle;

  /// No description provided for @receiptSaveImageBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get receiptSaveImageBtn;

  /// No description provided for @receiptSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Receipt image saved successfully'**
  String get receiptSavedToast;

  /// No description provided for @receiptSaveNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Take a screenshot to save this receipt'**
  String get receiptSaveNotSupported;

  /// No description provided for @viewDigitalReceiptBtn.
  ///
  /// In en, this message translates to:
  /// **'View MABNA CARE Digital Receipt'**
  String get viewDigitalReceiptBtn;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsAvgShare.
  ///
  /// In en, this message translates to:
  /// **'Avg / Apt'**
  String get analyticsAvgShare;

  /// No description provided for @analyticsCollectionRate.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get analyticsCollectionRate;

  /// No description provided for @analyticsEmergencyBalance.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get analyticsEmergencyBalance;

  /// No description provided for @analyticsChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses Comparison'**
  String get analyticsChartTitle;

  /// No description provided for @analyticsChartHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any month to inspect its breakdown'**
  String get analyticsChartHint;

  /// No description provided for @analyticsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses Breakdown — {month}'**
  String analyticsBreakdownTitle(String month);

  /// No description provided for @analyticsCollectionCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection Status — {month}'**
  String analyticsCollectionCardTitle(String month);

  /// No description provided for @analyticsCollectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get analyticsCollectedLabel;

  /// No description provided for @analyticsRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get analyticsRemainingLabel;

  /// No description provided for @analyticsInsightLower.
  ///
  /// In en, this message translates to:
  /// **'{month} expenses are {pct}% lower than the previous month (saved {diff} EGP)'**
  String analyticsInsightLower(String month, String pct, String diff);

  /// No description provided for @analyticsInsightHigher.
  ///
  /// In en, this message translates to:
  /// **'{month} expenses are {pct}% higher than the previous month (+{diff} EGP)'**
  String analyticsInsightHigher(String month, String pct, String diff);

  /// No description provided for @analyticsInsightSame.
  ///
  /// In en, this message translates to:
  /// **'{month} expenses match the previous month exactly'**
  String analyticsInsightSame(String month);

  /// No description provided for @analyticsInsightSingle.
  ///
  /// In en, this message translates to:
  /// **'{month} share: {share} EGP • {paid} of {total} paid'**
  String analyticsInsightSingle(
    String month,
    String share,
    int paid,
    int total,
  );

  /// No description provided for @analyticsNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough monthly data to analyze yet.'**
  String get analyticsNoData;

  /// No description provided for @pushCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Push Notification'**
  String get pushCardTitle;

  /// No description provided for @pushCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send an instant alert directly to all subscribed residents.'**
  String get pushCardSubtitle;

  /// No description provided for @pushTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Notification Title'**
  String get pushTitleLabel;

  /// No description provided for @pushTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Monthly dues reminder or elevator maintenance'**
  String get pushTitleHint;

  /// No description provided for @pushBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Notification Message'**
  String get pushBodyLabel;

  /// No description provided for @pushBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your notification details here...'**
  String get pushBodyHint;

  /// No description provided for @pushSendAllBtn.
  ///
  /// In en, this message translates to:
  /// **'Send to All Residents 🚀'**
  String get pushSendAllBtn;

  /// No description provided for @errPushFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter both a title and message first.'**
  String get errPushFieldsRequired;

  /// No description provided for @pushSentSuccessToast.
  ///
  /// In en, this message translates to:
  /// **'Notification sent successfully'**
  String get pushSentSuccessToast;

  /// No description provided for @pushNoDevicesToast.
  ///
  /// In en, this message translates to:
  /// **'No devices subscribed to notifications yet'**
  String get pushNoDevicesToast;

  /// No description provided for @pushNotConfiguredToast.
  ///
  /// In en, this message translates to:
  /// **'Push system ready — only the Firebase key in Supabase is pending'**
  String get pushNotConfiguredToast;

  /// No description provided for @pushSendFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Could not send notification right now'**
  String get pushSendFailedToast;

  /// No description provided for @pushAutoAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'📢 Important Building Announcement'**
  String get pushAutoAnnouncementTitle;

  /// No description provided for @pushAutoNewMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'🗓️ New Monthly Bill Available'**
  String get pushAutoNewMonthTitle;

  /// No description provided for @pushAutoNewMonthBody.
  ///
  /// In en, this message translates to:
  /// **'Expenses for {month} are now live on MABNA CARE.'**
  String pushAutoNewMonthBody(String month);

  /// No description provided for @pushAutoPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'🧾 New Payment Uploaded'**
  String get pushAutoPaymentTitle;

  /// No description provided for @pushAutoPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'{apt} uploaded a monthly payment receipt.'**
  String pushAutoPaymentBody(String apt);

  /// No description provided for @pushAutoFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'💬 New Resident Feedback'**
  String get pushAutoFeedbackTitle;

  /// No description provided for @drawerNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get drawerNotificationsLabel;

  /// No description provided for @pushEnabledBadge.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get pushEnabledBadge;

  /// No description provided for @pushEnableAction.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get pushEnableAction;

  /// No description provided for @pushEnabledToast.
  ///
  /// In en, this message translates to:
  /// **'🔔 Push notifications enabled on this device'**
  String get pushEnabledToast;

  /// No description provided for @pushBlockedToast.
  ///
  /// In en, this message translates to:
  /// **'Could not enable notifications (allow notifications in browser settings, or Add to Home Screen on iPhone)'**
  String get pushBlockedToast;

  /// No description provided for @pushAudienceAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Admin Only (Test)'**
  String get pushAudienceAdminOnly;

  /// No description provided for @pushAudienceAll.
  ///
  /// In en, this message translates to:
  /// **'All Residents'**
  String get pushAudienceAll;

  /// No description provided for @pushSendAdminTestBtn.
  ///
  /// In en, this message translates to:
  /// **'Send Test to Admin 🛡️'**
  String get pushSendAdminTestBtn;

  /// No description provided for @offlineBannerMsg.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offlineBannerMsg;

  /// No description provided for @onlineRestoredToast.
  ///
  /// In en, this message translates to:
  /// **'Back online — connection restored'**
  String get onlineRestoredToast;

  /// No description provided for @noNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noNetworkTitle;

  /// No description provided for @noNetworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and tap Retry to reload.'**
  String get noNetworkSubtitle;

  /// No description provided for @retryBtn.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryBtn;

  /// No description provided for @installAppNavLabel.
  ///
  /// In en, this message translates to:
  /// **'How to Install App'**
  String get installAppNavLabel;

  /// No description provided for @installAppTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Install MABNA CARE'**
  String get installAppTitle;

  /// No description provided for @installAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install the app on your home screen for 1-tap access without a browser bar and instant notifications.'**
  String get installAppSubtitle;

  /// No description provided for @installAppNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Install App Now'**
  String get installAppNowBtn;

  /// No description provided for @installAppAlreadyInstalled.
  ///
  /// In en, this message translates to:
  /// **'App is already installed on your device ✅'**
  String get installAppAlreadyInstalled;

  /// No description provided for @installAndroidTitle.
  ///
  /// In en, this message translates to:
  /// **'How to install on Android (Chrome)'**
  String get installAndroidTitle;

  /// No description provided for @installAndroidStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap the three dots menu (⋮) at the top corner of Chrome.'**
  String get installAndroidStep1;

  /// No description provided for @installAndroidStep2.
  ///
  /// In en, this message translates to:
  /// **'Select \"Install app\" or \"Install and create shortcut\" → \"Install\".'**
  String get installAndroidStep2;

  /// No description provided for @installAndroidStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Install\" on the confirmation popup — the app icon will appear on your home screen.'**
  String get installAndroidStep3;

  /// No description provided for @installIosTitle.
  ///
  /// In en, this message translates to:
  /// **'How to install on iPhone (Safari)'**
  String get installIosTitle;

  /// No description provided for @installIosStep1.
  ///
  /// In en, this message translates to:
  /// **'Make sure you open the link in Safari.'**
  String get installIosStep1;

  /// No description provided for @installIosStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap the Share icon at the bottom of the screen.'**
  String get installIosStep2;

  /// No description provided for @installIosStep3.
  ///
  /// In en, this message translates to:
  /// **'Select \"Add to Home Screen\" and then tap \"Add\".'**
  String get installIosStep3;

  /// No description provided for @notifHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifHistoryTitle;

  /// No description provided for @notifMarkAllReadBtn.
  ///
  /// In en, this message translates to:
  /// **'Mark all read ✓'**
  String get notifMarkAllReadBtn;

  /// No description provided for @notifFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String notifFilterAll(int count);

  /// No description provided for @notifFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread ({count})'**
  String notifFilterUnread(int count);

  /// No description provided for @notifEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No notifications sent yet.'**
  String get notifEmptyAll;

  /// No description provided for @notifEmptyUnread.
  ///
  /// In en, this message translates to:
  /// **'No unread notifications 🎉'**
  String get notifEmptyUnread;

  /// No description provided for @notifTypeAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get notifTypeAnnouncement;

  /// No description provided for @notifTypeNewMonth.
  ///
  /// In en, this message translates to:
  /// **'Monthly Bill'**
  String get notifTypeNewMonth;

  /// No description provided for @notifTypePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Alert'**
  String get notifTypePayment;

  /// No description provided for @notifTypeFeedback.
  ///
  /// In en, this message translates to:
  /// **'Resident Feedback'**
  String get notifTypeFeedback;

  /// No description provided for @notifTypeGeneral.
  ///
  /// In en, this message translates to:
  /// **'Admin Alert'**
  String get notifTypeGeneral;

  /// No description provided for @confirmDeleteNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this notification from history?'**
  String get confirmDeleteNotifBody;

  /// No description provided for @addCustomExpenseBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Expense Field'**
  String get addCustomExpenseBtn;

  /// No description provided for @addCustomExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Expense Field'**
  String get addCustomExpenseTitle;

  /// No description provided for @customExpenseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Field Name'**
  String get customExpenseNameLabel;

  /// No description provided for @customExpenseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Doorman, Motor Repair, Gas...'**
  String get customExpenseNameHint;

  /// No description provided for @customExpenseAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (EGP)'**
  String get customExpenseAmountLabel;

  /// No description provided for @customExpenseAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Expense field added & calculated'**
  String get customExpenseAddedToast;

  /// No description provided for @customExpenseRemovedToast.
  ///
  /// In en, this message translates to:
  /// **'Expense field removed & recalculated'**
  String get customExpenseRemovedToast;

  /// No description provided for @addBtn.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addBtn;

  /// No description provided for @deleteOwnReceiptBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete Receipt & Re-upload'**
  String get deleteOwnReceiptBtn;

  /// No description provided for @confirmDeleteOwnReceiptBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this receipt image and reset payment status so you can upload a new one?'**
  String get confirmDeleteOwnReceiptBody;

  /// No description provided for @paymentReceiptDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Receipt deleted — you can now upload a new one'**
  String get paymentReceiptDeletedToast;

  /// No description provided for @dueDateBanner.
  ///
  /// In en, this message translates to:
  /// **'Payment deadline for month {month} is day {day}'**
  String dueDateBanner(int month, int day);

  /// No description provided for @dueDatePassedBanner.
  ///
  /// In en, this message translates to:
  /// **'Payment deadline for month {month} (day {day}) has passed'**
  String dueDatePassedBanner(int month, int day);

  /// No description provided for @overdueBadge.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueBadge;

  /// No description provided for @overdueCountPill.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue'**
  String overdueCountPill(int count);

  /// No description provided for @dueDayField.
  ///
  /// In en, this message translates to:
  /// **'Due Day'**
  String get dueDayField;

  /// No description provided for @pushAudienceSpecificApt.
  ///
  /// In en, this message translates to:
  /// **'Specific Apt'**
  String get pushAudienceSpecificApt;

  /// No description provided for @pushAudienceUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Only'**
  String get pushAudienceUnpaid;

  /// No description provided for @pushSelectAptsHint.
  ///
  /// In en, this message translates to:
  /// **'Select apartment(s) (🔔 = notifications enabled):'**
  String get pushSelectAptsHint;

  /// No description provided for @pushUnpaidSummary.
  ///
  /// In en, this message translates to:
  /// **'Will send to {count} unpaid apartment(s) for month {month}'**
  String pushUnpaidSummary(int count, int month);

  /// No description provided for @pushAllPaidHint.
  ///
  /// In en, this message translates to:
  /// **'All apartments have paid for this month 🎉'**
  String get pushAllPaidHint;

  /// No description provided for @pushErrSelectApt.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one apartment'**
  String get pushErrSelectApt;

  /// No description provided for @pushSendSelectedBtn.
  ///
  /// In en, this message translates to:
  /// **'Send to Selected ({count})'**
  String pushSendSelectedBtn(int count);

  /// No description provided for @pushSendUnpaidBtn.
  ///
  /// In en, this message translates to:
  /// **'Remind Unpaid ({count})'**
  String pushSendUnpaidBtn(int count);

  /// No description provided for @pushDefaultUnpaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Reminder — Month {month}'**
  String pushDefaultUnpaidTitle(int month);

  /// No description provided for @pushDefaultUnpaidBody.
  ///
  /// In en, this message translates to:
  /// **'Kindly settle your building expenses for month {month} and upload the receipt in the app.'**
  String pushDefaultUnpaidBody(int month);

  /// No description provided for @adminPrankBioTitle.
  ///
  /// In en, this message translates to:
  /// **'🔐 Biometric Security Check'**
  String get adminPrankBioTitle;

  /// No description provided for @adminPrankBioSub.
  ///
  /// In en, this message translates to:
  /// **'Place your finger on the scanner to verify the Building Admin fingerprint'**
  String get adminPrankBioSub;

  /// No description provided for @adminPrankBioPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the fingerprint to verify...'**
  String get adminPrankBioPrompt;

  /// No description provided for @adminPrankBioScanning.
  ///
  /// In en, this message translates to:
  /// **'Matching fingerprint with building HQ... ⏳'**
  String get adminPrankBioScanning;

  /// No description provided for @adminPrankBioSkip.
  ///
  /// In en, this message translates to:
  /// **'Admin Password Login'**
  String get adminPrankBioSkip;

  /// No description provided for @adminPrankCaughtTitle.
  ///
  /// In en, this message translates to:
  /// **'Caught You, Neighbor!'**
  String get adminPrankCaughtTitle;

  /// No description provided for @adminPrankCaughtBody.
  ///
  /// In en, this message translates to:
  /// **'Coup attempt logged! Adding a 10 EGP curiosity fee to your apartment next month!'**
  String get adminPrankCaughtBody;

  /// No description provided for @adminPrankCaughtBackBtn.
  ///
  /// In en, this message translates to:
  /// **'Okay I surrender, Back Home'**
  String get adminPrankCaughtBackBtn;

  /// No description provided for @adminPrankCaughtRealBtn.
  ///
  /// In en, this message translates to:
  /// **'I really am the Admin (Enter Password)'**
  String get adminPrankCaughtRealBtn;

  /// No description provided for @adminPrankRoast1.
  ///
  /// In en, this message translates to:
  /// **'Nope! Just trying your luck today?'**
  String get adminPrankRoast1;

  /// No description provided for @adminPrankRoast2.
  ///
  /// In en, this message translates to:
  /// **'Wrong a second time! Looks like you memorized the Login button, not the password.'**
  String get adminPrankRoast2;

  /// No description provided for @adminPrankRoast3.
  ///
  /// In en, this message translates to:
  /// **'🚨 Caught again! Definitely not {attempt}'**
  String adminPrankRoast3(String attempt);

  /// No description provided for @adminPrankRoast4.
  ///
  /// In en, this message translates to:
  /// **'Give the keyboard a break, you are definitely not the admin!'**
  String get adminPrankRoast4;

  /// No description provided for @adminPrankCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cool down for {seconds}s before trying again'**
  String adminPrankCooldown(int seconds);

  /// No description provided for @changeAdminPassTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Admin Password'**
  String get changeAdminPassTitle;

  /// No description provided for @changeAdminPassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your admin passcode securely right from the app'**
  String get changeAdminPassSubtitle;

  /// No description provided for @currentAdminPassLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentAdminPassLabel;

  /// No description provided for @newAdminPassLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newAdminPassLabel;

  /// No description provided for @confirmNewAdminPassLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewAdminPassLabel;

  /// No description provided for @changeAdminPassSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Once saved, the password is updated in the database and any other logged-in admin devices will be signed out automatically.'**
  String get changeAdminPassSecurityNote;

  /// No description provided for @changeAdminPassBtn.
  ///
  /// In en, this message translates to:
  /// **'Save New Password'**
  String get changeAdminPassBtn;

  /// No description provided for @changeAdminPassFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the current, new, and confirmation passwords.'**
  String get changeAdminPassFieldsRequired;

  /// No description provided for @changeAdminPassSuccessToast.
  ///
  /// In en, this message translates to:
  /// **'✅ Admin password updated successfully'**
  String get changeAdminPassSuccessToast;

  /// No description provided for @passStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passStrengthWeak;

  /// No description provided for @passStrengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passStrengthMedium;

  /// No description provided for @passStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong ✓'**
  String get passStrengthStrong;

  /// No description provided for @monthlyReportBtn.
  ///
  /// In en, this message translates to:
  /// **'Statement (Image)'**
  String get monthlyReportBtn;

  /// No description provided for @monthlyReportScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Statement'**
  String get monthlyReportScreenTitle;

  /// No description provided for @reportDocSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Building Financial Statement'**
  String get reportDocSubtitle;

  /// No description provided for @reportIssuedLabel.
  ///
  /// In en, this message translates to:
  /// **'Issued: {date}'**
  String reportIssuedLabel(String date);

  /// No description provided for @reportSectionExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses Breakdown'**
  String get reportSectionExpenses;

  /// No description provided for @reportSectionApts.
  ///
  /// In en, this message translates to:
  /// **'Apartments Payment Status'**
  String get reportSectionApts;

  /// No description provided for @reportColApt.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get reportColApt;

  /// No description provided for @reportColDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get reportColDue;

  /// No description provided for @reportColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reportColStatus;

  /// No description provided for @reportTotalRow.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reportTotalRow;

  /// No description provided for @reportTotalExpensesKpi.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get reportTotalExpensesKpi;

  /// No description provided for @reportEmergencyBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Emergency Fund Balance'**
  String get reportEmergencyBalanceTitle;

  /// No description provided for @reportSavePngBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Statement Image for WhatsApp'**
  String get reportSavePngBtn;

  /// No description provided for @reportSavedToast.
  ///
  /// In en, this message translates to:
  /// **'✅ Statement image saved successfully'**
  String get reportSavedToast;

  /// No description provided for @reportChipExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportChipExpenses;

  /// No description provided for @reportChipApts.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get reportChipApts;

  /// No description provided for @reportChipEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get reportChipEmergency;

  /// No description provided for @reportAptsCountUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} apts'**
  String reportAptsCountUnit(int count);

  /// No description provided for @contactAddedByAptLabel.
  ///
  /// In en, this message translates to:
  /// **'Added by: {apt}'**
  String contactAddedByAptLabel(String apt);

  /// No description provided for @contactAddedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get contactAddedByAdmin;

  /// No description provided for @contactSelectYourAptLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Apartment'**
  String get contactSelectYourAptLabel;

  /// No description provided for @contactSelectYourAptHint.
  ///
  /// In en, this message translates to:
  /// **'Select your apartment'**
  String get contactSelectYourAptHint;

  /// No description provided for @errContactSelectApt.
  ///
  /// In en, this message translates to:
  /// **'Please select your apartment first'**
  String get errContactSelectApt;

  /// No description provided for @contactCardPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Business Card Photo (Optional)'**
  String get contactCardPhotoLabel;

  /// No description provided for @contactTakePhotoBtn.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get contactTakePhotoBtn;

  /// No description provided for @contactPickGalleryBtn.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get contactPickGalleryBtn;

  /// No description provided for @contactPhoneOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional if card photo is attached'**
  String get contactPhoneOptionalHint;

  /// No description provided for @errContactNameOrCardRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name and either a phone number or a card photo'**
  String get errContactNameOrCardRequired;

  /// No description provided for @contactTapToZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to zoom card'**
  String get contactTapToZoomHint;

  /// No description provided for @contactViewCardBtn.
  ///
  /// In en, this message translates to:
  /// **'View Full Card'**
  String get contactViewCardBtn;

  /// No description provided for @renameExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Expense Field'**
  String get renameExpenseTitle;

  /// No description provided for @expenseRenamedToast.
  ///
  /// In en, this message translates to:
  /// **'✅ Expense name updated'**
  String get expenseRenamedToast;

  /// No description provided for @editContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Maintenance Contact'**
  String get editContactTitle;

  /// No description provided for @contactUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'✅ Maintenance contact updated'**
  String get contactUpdatedToast;

  /// No description provided for @contactDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Maintenance contact deleted'**
  String get contactDeletedToast;

  /// No description provided for @contactsTabNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get contactsTabNumbers;

  /// No description provided for @contactsTabCards.
  ///
  /// In en, this message translates to:
  /// **'Cards & Photos'**
  String get contactsTabCards;

  /// No description provided for @noContactCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No cards or photos added yet'**
  String get noContactCardsYet;
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
