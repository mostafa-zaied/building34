import 'dart:ui';

import '../l10n/app_localizations.dart';
import '../models/building_models.dart';

class BuildingState {
  final bool loading;
  final bool busy;
  final BuildingInfo building;
  final String supportWhatsapp;
  final List<SavedBuildingRef> savedBuildings;
  final bool buildingNotFound;
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
  final bool requireAptPassOnOpen;
  final List<BuildingContact> buildingContacts;
  final Map<int, bool> apartmentHasPasscode;
  final List<AppNotificationItem> notifications;
  final Set<String> readNotificationIds;

  const BuildingState({
    this.loading = true,
    this.busy = false,
    this.building = BuildingInfo.defaultDemo,
    this.supportWhatsapp = '201021950445',
    this.savedBuildings = const [],
    this.buildingNotFound = false,
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
    this.requireAptPassOnOpen = true,
    this.buildingContacts = const [],
    this.apartmentHasPasscode = const {},
    this.notifications = const [],
    this.readNotificationIds = const {},
  });

  AppLocalizations get s => lookupAppLocalizations(Locale(localeCode));

  String get displayBuildingName {
    final trimmed = building.name.trim();
    if (building.isDefaultBuilding &&
        (trimmed.isEmpty || trimmed.toUpperCase() == 'MABNA CARE')) {
      return s.appTitle;
    }
    return trimmed.isEmpty ? s.appTitle : trimmed;
  }

  int get unreadNotificationsCount =>
      notifications.where((n) => !readNotificationIds.contains(n.id)).length;

  MonthBill? get currentMonth =>
      months.isEmpty || selectedMonthIndex >= months.length
          ? null
          : months[selectedMonthIndex];

  String aptLabel(int aptNum) => apartmentNames[aptNum] ?? s.defaultAptName(aptNum);

  BuildingState copyWith({
    bool? loading,
    bool? busy,
    BuildingInfo? building,
    String? supportWhatsapp,
    List<SavedBuildingRef>? savedBuildings,
    bool? buildingNotFound,
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
    bool? requireAptPassOnOpen,
    List<BuildingContact>? buildingContacts,
    Map<int, bool>? apartmentHasPasscode,
    List<AppNotificationItem>? notifications,
    Set<String>? readNotificationIds,
  }) {
    return BuildingState(
      loading: loading ?? this.loading,
      busy: busy ?? this.busy,
      building: building ?? this.building,
      supportWhatsapp: supportWhatsapp ?? this.supportWhatsapp,
      savedBuildings: savedBuildings ?? this.savedBuildings,
      buildingNotFound: buildingNotFound ?? this.buildingNotFound,
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
      requireAptPassOnOpen: requireAptPassOnOpen ?? this.requireAptPassOnOpen,
      buildingContacts: buildingContacts ?? this.buildingContacts,
      apartmentHasPasscode: apartmentHasPasscode ?? this.apartmentHasPasscode,
      notifications: notifications ?? this.notifications,
      readNotificationIds: readNotificationIds ?? this.readNotificationIds,
    );
  }
}
