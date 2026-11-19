import 'dart:js_interop';
import 'dart:js_interop_unsafe';

bool isPwaStandalone() {
  try {
    final res = globalContext.callMethod<JSBoolean?>('mabnaIsStandalone'.toJS);
    return res?.toDart ?? false;
  } catch (_) {
    return false;
  }
}

bool canPromptPwaInstall() {
  try {
    final res = globalContext.callMethod<JSBoolean?>('mabnaCanInstallPrompt'.toJS);
    return res?.toDart ?? false;
  } catch (_) {
    return false;
  }
}

Future<bool> triggerPwaInstallPrompt() async {
  try {
    final promise = globalContext.callMethod<JSPromise<JSBoolean?>?>(
      'mabnaTriggerInstallPrompt'.toJS,
    );
    if (promise == null) return false;
    final res = await promise.toDart;
    return res?.toDart ?? false;
  } catch (_) {
    return false;
  }
}
