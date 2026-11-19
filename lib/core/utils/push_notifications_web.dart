import 'dart:js_interop';
import 'dart:js_interop_unsafe';

String getPushPermissionStatus() {
  try {
    final res = globalContext.callMethod<JSString?>('mabnaGetPushPermission'.toJS);
    return res?.toDart ?? 'unsupported';
  } catch (_) {
    return 'unsupported';
  }
}

Future<String?> requestPushToken({bool silentOnly = false}) async {
  try {
    final promise = globalContext.callMethod<JSPromise<JSString?>?>(
      'mabnaRequestPushToken'.toJS,
      silentOnly.toJS,
    );
    if (promise == null) return null;
    final jsStr = await promise.toDart.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
    final token = jsStr?.toDart.trim() ?? '';
    return token.isNotEmpty ? token : null;
  } catch (_) {
    return null;
  }
}
