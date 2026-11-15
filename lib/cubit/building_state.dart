import 'dart:ui';

import '../l10n/app_localizations.dart';
import '../models/building_models.dart';

class BuildingState {
  final bool loading;
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

  const BuildingState({
    this.loading = true,
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
  });

  AppLocalizations get s => lookupAppLocalizations(Locale(localeCode));

  MonthBill? get currentMonth =>
      months.isEmpty || selectedMonthIndex >= months.length
          ? null
          : months[selectedMonthIndex];

  String aptLabel(int aptNum) => apartmentNames[aptNum] ?? s.defaultAptName(aptNum);

  BuildingState copyWith({
    bool? loading,
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
  }) {
    return BuildingState(
      loading: loading ?? this.loading,
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
    );
  }
}
