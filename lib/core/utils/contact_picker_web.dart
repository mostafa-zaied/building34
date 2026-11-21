import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

bool isContactPickerSupported() {
  try {
    final res =
        globalContext.callMethod<JSBoolean?>('mabnaCanPickContact'.toJS);
    return res?.toDart ?? false;
  } catch (_) {
    return false;
  }
}

Future<({String name, String phone})?> pickDeviceContact() async {
  try {
    final promise = globalContext.callMethod<JSPromise<JSString?>?>(
      'mabnaPickContact'.toJS,
    );
    if (promise == null) return null;
    final jsStr = await promise.toDart;
    final raw = jsStr?.toDart ?? '';
    if (raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final name = (decoded['name'] ?? '').toString().trim();
    final phone = (decoded['phone'] ?? '').toString().trim();
    if (name.isEmpty && phone.isEmpty) return null;
    return (name: name, phone: phone);
  } catch (_) {
    return null;
  }
}
