import 'dart:typed_data';

/// On native platforms, ImagePicker handles maxWidth/maxHeight/imageQuality directly.
Future<Uint8List> compressReceiptImage(
  Uint8List bytes, {
  int maxDimension = 1280,
  double quality = 0.72,
}) async {
  return bytes;
}
