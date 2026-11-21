import 'dart:js_interop';
import 'dart:js_interop_unsafe';

String? getInitialBuildingCodeFromUrl() {
  final code = Uri.base.queryParameters['b']?.trim().toUpperCase();
  if (code == null || code.isEmpty) return null;
  return code;
}

void updateBrowserBuildingUrl(String? code, {required bool isDefaultBuilding}) {
  try {
    final param = (isDefaultBuilding || code == null) ? '' : code.trim().toUpperCase();
    globalContext.callMethod<JSAny?>('mabnaSetBuildingUrl'.toJS, param.toJS);
  } catch (_) {}
}

String buildBuildingShareUrl(String code, {bool isDefaultBuilding = false}) {
  final clean = code.trim().toUpperCase();
  if (isDefaultBuilding || clean.isEmpty) {
    return 'https://mabna-care.web.app/';
  }
  return 'https://mabna-care.web.app/?b=$clean';
}
