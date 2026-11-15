// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Hausverwaltung';

  @override
  String get demoBanner =>
      '🧪 Lokaler Demo-Modus — Supabase-Daten in lib/config.dart für Live-Betrieb eintragen';

  @override
  String monthOption(int monthNum, int yearNum) {
    return 'Monat $monthNum ($yearNum)';
  }

  @override
  String emergencyBadge(int amount) {
    return '🛡️ Rücklage: $amount EGP';
  }

  @override
  String get editBtn => '⚙️ Bearbeiten';

  @override
  String get closeBtn => '✓ Schließen';

  @override
  String billTitle(int monthNum) {
    return 'Hauskosten — Monat $monthNum:';
  }

  @override
  String get copyWhatsAppBtn => 'Für WhatsApp kopieren';

  @override
  String get waterLabel => '💧 Wasser';

  @override
  String get elecLabel => '⚡ Strom';

  @override
  String get elevLabel => '🛗 Aufzug';

  @override
  String get cleanLabel => '🧹 Reinigung';

  @override
  String get forEmergLabel => '🛡️ Rücklage';

  @override
  String totalExpensesLine(int total, int apts) {
    return '• Gesamtkosten: $total EGP (÷ $apts Whg.)';
  }

  @override
  String emergencySummaryLine(int total, int base, int added) {
    return '• Notfallfonds: $total EGP ($base vorhanden + $added diesen Monat)';
  }

  @override
  String get sharePerAptLabel => 'Pro Whg.';

  @override
  String currency(int amount) {
    return '$amount EGP';
  }

  @override
  String get copiedTitle => '✅ Für WhatsApp kopiert:';

  @override
  String get copiedToast => '✅ Aktueller Monatsbericht für WhatsApp kopiert';

  @override
  String get adminSectionHint =>
      '⚙️ Monatsposten bearbeiten (Fokus hebt die Karte oben hervor):';

  @override
  String get aptsCountField => '🏠 Whg.:';

  @override
  String get baseEmergField => '💰 Vorheriger Notfallfonds:';

  @override
  String get saveChangesBtn => '💾 Speichern';

  @override
  String get manageAptsBtn => 'Whg. & Passwörter';

  @override
  String get tapAptTitle => 'Wohnung antippen, um Zahlung zu melden';

  @override
  String paidCounter(int paid, int total) {
    return 'Bezahlt $paid von $total';
  }

  @override
  String defaultAptName(int num) {
    return 'Whg. $num';
  }

  @override
  String get paidBadge => '✅ Bezahlt';

  @override
  String get adminLoginTitle => '🔐 Admin-Anmeldung';

  @override
  String get adminPassHint => 'Admin-Passwort eingeben...';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get login => 'Anmelden';

  @override
  String get manageAptsTitle => '🔑 Wohnungsnamen & Passwörter verwalten';

  @override
  String get optionalName => 'Name (optional)';

  @override
  String nameHint(int num) {
    return 'z.B. Whg. $num - Max';
  }

  @override
  String get passcodeLabel => 'Passwort';

  @override
  String get saveAll => '💾 Alle speichern';

  @override
  String get saving => 'Speichern...';

  @override
  String fileLabel(String name) {
    return 'Datei: $name';
  }

  @override
  String get receiptAttachedPreviously => 'Beleg wurde bereits hochgeladen';

  @override
  String get cancelPaymentAdmin => '❌ Zahlung stornieren (Admin)';

  @override
  String dueDialogTitle(String aptLabel, int share) {
    return '$aptLabel — Fällig $share EGP';
  }

  @override
  String step1Passcode(String demoHint) {
    return '1. Wohnungspasswort$demoHint';
  }

  @override
  String get enterPassHint => 'Passwort eingeben...';

  @override
  String get step2Image => '2. Überweisungsbeleg (Pflicht)';

  @override
  String get pickImagePrompt => '📸 Tippen, um Belegbild auszuwählen';

  @override
  String chosenFile(String name) {
    return '✅ Ausgewählt: $name';
  }

  @override
  String get errMissingImage =>
      '❌ Bitte zuerst den Überweisungsbeleg anhängen!';

  @override
  String get confirmPaymentBtn => '✅ Zahlung bestätigen';

  @override
  String get uploadingBtn => 'Wird hochgeladen...';

  @override
  String whatsappHeader(int monthNum, int yearNum) {
    return '🏢 *Hauskosten — Monat $monthNum ($yearNum)*';
  }

  @override
  String whatsappTotal(int total) {
    return '💰 *Gesamt:* $total EGP';
  }

  @override
  String whatsappShare(int apts, int share) {
    return '📌 *Anteil pro Wohnung ($apts Whg.):* $share EGP';
  }

  @override
  String whatsappEmergency(int total, int base, int added) {
    return '🛡️ *Notfallfonds:* $total EGP ($base vorhanden + $added diesen Monat)';
  }

  @override
  String get whatsappLinkPrompt =>
      '🔗 *Link öffnen, um Zahlung zu melden und Beleg anzuhängen:*';

  @override
  String whatsappPaidStatus(int paid, int total) {
    return '✅ *Bezahlt ($paid/$total):*';
  }

  @override
  String get whatsappNonePaid => '• Noch keine';

  @override
  String get addApartmentBtn => '+ Wohnung hinzufügen';

  @override
  String get navExpenses => 'Kosten';

  @override
  String get navComplaints => 'Beschwerden';

  @override
  String get navImprovements => 'Ideen';

  @override
  String get complaintsTitle => '📢 Beschwerden';

  @override
  String get improvementsTitle => '💡 Verbesserungsvorschläge';

  @override
  String get writeComplaintHint => 'Beschwerde hier eingeben...';

  @override
  String get writeImprovementHint => 'Verbesserungsvorschlag teilen...';

  @override
  String get postAnonymously => 'Anonym senden (Wohnung verbergen)';

  @override
  String get selectApartment => 'Wohnung';

  @override
  String get submitPostBtn => 'Senden';

  @override
  String get anonymousAuthor => '🕵️ Anonym';

  @override
  String get noPostsYet => 'Noch keine Einträge';

  @override
  String get postAddedToast => '✅ Erfolgreich gesendet';

  @override
  String tabViewComplaints(int count) {
    return 'Beschwerden ($count)';
  }

  @override
  String get tabAddComplaint => 'Neue Beschwerde';

  @override
  String tabViewImprovements(int count) {
    return 'Ideen ($count)';
  }

  @override
  String get tabAddImprovement => 'Neue Idee';
}
