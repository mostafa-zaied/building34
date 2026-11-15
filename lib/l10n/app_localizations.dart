import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
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
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Building Expenses'**
  String get appTitle;

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'🧪 Local Demo Mode — Add Supabase keys in lib/config.dart for live deployment'**
  String get demoBanner;

  /// No description provided for @monthOption.
  ///
  /// In en, this message translates to:
  /// **'Month {monthNum} ({yearNum})'**
  String monthOption(int monthNum, int yearNum);

  /// No description provided for @emergencyBadge.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Emergency: {amount} EGP'**
  String emergencyBadge(int amount);

  /// No description provided for @editBtn.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Edit'**
  String get editBtn;

  /// No description provided for @closeBtn.
  ///
  /// In en, this message translates to:
  /// **'✓ Close'**
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
  /// **'💧 Water'**
  String get waterLabel;

  /// No description provided for @elecLabel.
  ///
  /// In en, this message translates to:
  /// **'⚡ Elec'**
  String get elecLabel;

  /// No description provided for @elevLabel.
  ///
  /// In en, this message translates to:
  /// **'🛗 Elevator'**
  String get elevLabel;

  /// No description provided for @cleanLabel.
  ///
  /// In en, this message translates to:
  /// **'🧹 Cleaning'**
  String get cleanLabel;

  /// No description provided for @forEmergLabel.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Reserve'**
  String get forEmergLabel;

  /// No description provided for @totalExpensesLine.
  ///
  /// In en, this message translates to:
  /// **'• Total Expenses: {total} EGP (÷ {apts} apts)'**
  String totalExpensesLine(int total, int apts);

  /// No description provided for @emergencySummaryLine.
  ///
  /// In en, this message translates to:
  /// **'• Emergency Fund: {total} EGP ({base} avail + {added} this month)'**
  String emergencySummaryLine(int total, int base, int added);

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
  /// **'✅ Copied for WhatsApp:'**
  String get copiedTitle;

  /// No description provided for @copiedToast.
  ///
  /// In en, this message translates to:
  /// **'✅ Updated monthly report copied for WhatsApp'**
  String get copiedToast;

  /// No description provided for @adminSectionHint.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Edit Month Items (hover/focus a field to highlight its card):'**
  String get adminSectionHint;

  /// No description provided for @aptsCountField.
  ///
  /// In en, this message translates to:
  /// **'🏠 Apts:'**
  String get aptsCountField;

  /// No description provided for @baseEmergField.
  ///
  /// In en, this message translates to:
  /// **'💰 Previous Emergency Balance:'**
  String get baseEmergField;

  /// No description provided for @saveChangesBtn.
  ///
  /// In en, this message translates to:
  /// **'💾 Save Changes'**
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
  /// **'✅ Paid'**
  String get paidBadge;

  /// No description provided for @adminLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'🔐 Admin Login'**
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
  /// **'🔑 Manage Apartment Names & Passwords'**
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
  /// **'💾 Save All'**
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

  /// No description provided for @receiptAttachedPreviously.
  ///
  /// In en, this message translates to:
  /// **'Receipt attached previously'**
  String get receiptAttachedPreviously;

  /// No description provided for @cancelPaymentAdmin.
  ///
  /// In en, this message translates to:
  /// **'❌ Cancel Payment (Admin)'**
  String get cancelPaymentAdmin;

  /// No description provided for @dueDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{aptLabel} — Due {share} EGP'**
  String dueDialogTitle(String aptLabel, int share);

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
  /// **'2. Transfer Screenshot (Required)'**
  String get step2Image;

  /// No description provided for @pickImagePrompt.
  ///
  /// In en, this message translates to:
  /// **'📸 Tap here to select receipt image'**
  String get pickImagePrompt;

  /// No description provided for @chosenFile.
  ///
  /// In en, this message translates to:
  /// **'✅ Selected: {name}'**
  String chosenFile(String name);

  /// No description provided for @errMissingImage.
  ///
  /// In en, this message translates to:
  /// **'❌ Please attach the transfer screenshot first!'**
  String get errMissingImage;

  /// No description provided for @confirmPaymentBtn.
  ///
  /// In en, this message translates to:
  /// **'✅ Confirm Payment'**
  String get confirmPaymentBtn;

  /// No description provided for @uploadingBtn.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingBtn;

  /// No description provided for @whatsappHeader.
  ///
  /// In en, this message translates to:
  /// **'🏢 *Building Expenses — Month {monthNum} ({yearNum})*'**
  String whatsappHeader(int monthNum, int yearNum);

  /// No description provided for @whatsappTotal.
  ///
  /// In en, this message translates to:
  /// **'💰 *Total:* {total} EGP'**
  String whatsappTotal(int total);

  /// No description provided for @whatsappShare.
  ///
  /// In en, this message translates to:
  /// **'📌 *Share per apartment ({apts} apts):* {share} EGP'**
  String whatsappShare(int apts, int share);

  /// No description provided for @whatsappEmergency.
  ///
  /// In en, this message translates to:
  /// **'🛡️ *Emergency fund:* {total} EGP ({base} avail + {added} this month)'**
  String whatsappEmergency(int total, int base, int added);

  /// No description provided for @whatsappLinkPrompt.
  ///
  /// In en, this message translates to:
  /// **'🔗 *Open the link to mark your payment and attach the receipt:*'**
  String get whatsappLinkPrompt;

  /// No description provided for @whatsappPaidStatus.
  ///
  /// In en, this message translates to:
  /// **'✅ *Paid ({paid}/{total}):*'**
  String whatsappPaidStatus(int paid, int total);

  /// No description provided for @whatsappNonePaid.
  ///
  /// In en, this message translates to:
  /// **'• None yet'**
  String get whatsappNonePaid;

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

  /// No description provided for @navComplaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get navComplaints;

  /// No description provided for @navImprovements.
  ///
  /// In en, this message translates to:
  /// **'Improvements'**
  String get navImprovements;

  /// No description provided for @complaintsTitle.
  ///
  /// In en, this message translates to:
  /// **'📢 Resident Complaints'**
  String get complaintsTitle;

  /// No description provided for @improvementsTitle.
  ///
  /// In en, this message translates to:
  /// **'💡 Building Improvements'**
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
  /// **'🕵️ Anonymous'**
  String get anonymousAuthor;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noPostsYet;

  /// No description provided for @postAddedToast.
  ///
  /// In en, this message translates to:
  /// **'✅ Submitted successfully'**
  String get postAddedToast;
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
      <String>['ar', 'de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
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
