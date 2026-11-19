import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

Future<bool> savePngImage(Uint8List bytes, String fileName) async {
  try {
    final doc = globalContext['document'] as JSObject?;
    if (doc == null) return false;

    final anchor = doc.callMethod<JSObject>('createElement'.toJS, 'a'.toJS);
    final b64 = base64Encode(bytes);
    anchor['href'] = 'data:image/png;base64,$b64'.toJS;
    anchor['download'] = fileName.toJS;

    final body = doc['body'] as JSObject?;
    body?.callMethod('appendChild'.toJS, anchor);
    anchor.callMethod('click'.toJS);
    body?.callMethod('removeChild'.toJS, anchor);
    return true;
  } catch (_) {
    return false;
  }
}
