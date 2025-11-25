import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

Future<Uint8List> convertToPng(File file) async {
  final bytes = await file.readAsBytes();

  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return pngBytes!.buffer.asUint8List();
}
