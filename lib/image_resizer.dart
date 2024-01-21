import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageResizer {
  static void _resizeImage(List<dynamic> args) {
    final sendPort = args[0] as SendPort;
    try {
      Uint8List bytes = File(args[1]).readAsBytesSync();

      final resizedImage = img.copyResize(
        img.decodeImage(bytes)!,
        width: (args[2] as num).toInt(),
        maintainAspect: true,
        backgroundColor: img.ColorRgb8(255, 255, 255),
        interpolation: img.Interpolation.average,
      );

      Isolate.exit(sendPort, img.encodePng(resizedImage));
    } catch (e) {
      Isolate.exit(sendPort, Uint8List.fromList([]));
    }
  }

  Future<img.Image?> resizeImage({
    required String imagePath,
    required double width,
  }) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_resizeImage, [
      receivePort.sendPort,
      imagePath,
      width,
    ]);
    final bytes = await receivePort.first as Uint8List;
    receivePort.close();

    return img.decodePng(bytes);
  }
}
