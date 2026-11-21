String? getInitialBuildingCodeFromUrl() => null;

void updateBrowserBuildingUrl(String? code, {required bool isDefaultBuilding}) {}

String buildBuildingShareUrl(String code, {bool isDefaultBuilding = false}) {
  final clean = code.trim().toUpperCase();
  if (isDefaultBuilding || clean.isEmpty) {
    return 'https://mabna-care.web.app/';
  }
  return 'https://mabna-care.web.app/?b=$clean';
}
