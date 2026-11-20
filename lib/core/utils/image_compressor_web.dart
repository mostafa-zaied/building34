import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

/// Compresses large receipt images on Flutter Web via HTML5 Canvas (`image/jpeg`)
/// before uploading to Supabase Storage, dramatically speeding up mobile uploads.
Future<Uint8List> compressReceiptImage(
  Uint8List bytes, {
  int maxDimension = 1280,
  double quality = 0.72,
}) async {
  // Skip tiny images (< 140 KB) that don't need compression
  if (bytes.lengthInBytes < 140 * 1024) return bytes;
  try {
    final fn = globalContext['mabnaCompressImage'];
    if (fn == null || fn.isUndefinedOrNull) return bytes;
    final b64In = base64Encode(bytes);
    final promise = globalContext.callMethod<JSPromise<JSString>>(
      'mabnaCompressImage'.toJS,
      b64In.toJS,
      maxDimension.toJS,
      quality.toJS,
    );
    final resultJs = await promise.toDart;
    final b64Out = resultJs.toDart;
    if (b64Out.isEmpty) return bytes;
    final compressed = base64Decode(b64Out);
    return compressed.lengthInBytes < bytes.lengthInBytes ? compressed : bytes;
  } catch (_) {
    return bytes;
  }
}
