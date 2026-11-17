import 'dart:ui';

import '../l10n/app_localizations.dart';
import '../models/building_models.dart';

class BuildingState {
  final bool loading;
  final bool isAdminAuthenticated;
  final bool isAdminOpen;
  final String adminPass;
  final double baseEmergency;
  final List<MonthBill> months;
  final Map<int, String> apartmentNames;
  final int selectedMonthIndex;
  final String? highlightedKey;
  final String? copiedPreview;
  final String? feedbackMessage;
  final bool feedbackIsError;
  final String localeCode;
  final bool isDarkMode;
  final int selectedNavIndex;
  final List<FeedbackPost> feedbackPosts;
  final int? myAptNum;
  final String? savedAptPass;
  final String announcement;
  final List<EmergencyTransaction> emergencyTransactions;
  final PageViewStats? pageViewStats;

  const BuildingState({
    this.loading = true,
    this.isAdminAuthenticated = false,
    this.isAdminOpen = false,
    this.adminPass = 'admin123',
    this.baseEmergency = 2550,
    this.months = const [],
    this.apartmentNames = const {},
    this.selectedMonthIndex = 0,
    this.highlightedKey,
    this.copiedPreview,
    this.feedbackMessage,
    this.feedbackIsError = false,
    this.localeCode = 'ar',
    this.isDarkMode = true,
    this.selectedNavIndex = 0,
    this.feedbackPosts = const [],
    this.myAptNum,
    this.savedAptPass,
    this.announcement = '',
    this.emergencyTransactions = const [],
    this.pageViewStats,
  });

  AppLocalizations get s => lookupAppLocalizations(Locale(localeCode));

  MonthBill? get currentMonth =>
      months.isEmpty || selectedMonthIndex >= months.length
          ? null
          : months[selectedMonthIndex];

  String aptLabel(int aptNum) => apartmentNames[aptNum] ?? s.defaultAptName(aptNum);

  BuildingState copyWith({
    bool? loading,
    bool? isAdminAuthenticated,
    bool? isAdminOpen,
    String? adminPass,
    double? baseEmergency,
    List<MonthBill>? months,
    Map<int, String>? apartmentNames,
    int? selectedMonthIndex,
    String? Function()? highlightedKey,
    String? Function()? copiedPreview,
    String? Function()? feedbackMessage,
    bool? feedbackIsError,
    String? localeCode,
    bool? isDarkMode,
    int? selectedNavIndex,
    List<FeedbackPost>? feedbackPosts,
    int? Function()? myAptNum,
    String? Function()? savedAptPass,
    String? announcement,
    List<EmergencyTransaction>? emergencyTransactions,
    PageViewStats? Function()? pageViewStats,
  }) {
    return BuildingState(
      loading: loading ?? this.loading,
      isAdminAuthenticated: isAdminAuthenticated ?? this.isAdminAuthenticated,
      isAdminOpen: isAdminOpen ?? this.isAdminOpen,
      adminPass: adminPass ?? this.adminPass,
      baseEmergency: baseEmergency ?? this.baseEmergency,
      months: months ?? this.months,
      apartmentNames: apartmentNames ?? this.apartmentNames,
      selectedMonthIndex: selectedMonthIndex ?? this.selectedMonthIndex,
      highlightedKey: highlightedKey != null ? highlightedKey() : this.highlightedKey,
      copiedPreview: copiedPreview != null ? copiedPreview() : this.copiedPreview,
      feedbackMessage: feedbackMessage != null ? feedbackMessage() : this.feedbackMessage,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      localeCode: localeCode ?? this.localeCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      feedbackPosts: feedbackPosts ?? this.feedbackPosts,
      myAptNum: myAptNum != null ? myAptNum() : this.myAptNum,
      savedAptPass: savedAptPass != null ? savedAptPass() : this.savedAptPass,
      announcement: announcement ?? this.announcement,
      emergencyTransactions: emergencyTransactions ?? this.emergencyTransactions,
      pageViewStats: pageViewStats != null ? pageViewStats() : this.pageViewStats,
    );
  }
}
