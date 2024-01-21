import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cellular_automata_image_effects/pixel_info.dart';
import 'package:image/image.dart' as img;
import 'package:rxdart/subjects.dart';

class PixelAutomataManager {
  static const _terminatingSignal = "END";
  ReceivePort? _receivePort;
  StreamSubscription<dynamic>? _streamSubscription;
  final _streamController = BehaviorSubject<List<List<PixelInfo>>>();
  Stream<List<List<PixelInfo>>> get stream => _streamController.stream;
  List<List<PixelInfo>> _pixelInfosCollection = [];

  Timer? _timer;
  List<VoidCallback> _operationQueue = [];

  ///165, 60, 78, 153, 90
  Future<void> applyEffect({
    required img.Image image,
    int rule = 165,
  }) async {
    try {
      _pixelInfosCollection = [];
      _operationQueue = [];
      _streamController.add(_pixelInfosCollection);
      _releaseResources();
      _receivePort = ReceivePort();

      _timer ??= Timer.periodic(
        const Duration(milliseconds: 5),
        (timer) {
          if (_operationQueue.isEmpty) {
            if (_receivePort == null) {
              timer.cancel();
              _timer = null;
            }
            return;
          }
          _operationQueue.removeAt(0).call();
        },
      );

      await Isolate.spawn(_applyEffect, [
        _receivePort!.sendPort,
        img.encodePng(image),
        rule.toRadixString(2).padLeft(8, '0'),
      ]);

      _streamSubscription = _receivePort!.listen(
        (message) async {
          if (message == _terminatingSignal) {
            _releaseResources();
            return;
          }

          if (message is List<Map>) {
            final pixelInfos = List<PixelInfo>.from(
              message.map(
                (e) => PixelInfo.fromMap(e),
              ),
            );
            _operationQueue.add(() {
              _pixelInfosCollection.add(pixelInfos);
              _streamController.add([..._pixelInfosCollection]);
            });
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Color _colorFrom(img.Pixel pixel, bool clear) {
    final red = pixel.r.toInt();
    final green = pixel.g.toInt();
    final blue = pixel.b.toInt();

    return Color.fromARGB(
      255,
      clear ? 255 : red,
      clear ? 255 : green,
      clear ? 255 : blue,
    );
  }

  static void _applyEffect(List<dynamic> args) {
    final sendPort = args[0] as SendPort;
    try {
      final image = img.decodePng(args[1] as Uint8List)!;
      final width = image.width;

      List<int> cells = List.generate(
        width,
        (index) => index == width ~/ 2 ? 0 : 1,
      );

      final ruleSet = (args[2] as String).split('').map(int.parse).toList();

      int computeNewState(int left, int current, int right) {
        return ruleSet[7 - int.parse('$left$current$right', radix: 2)];
      }

      List<int> nextCells = List.generate(width, (index) => 0);

      final pixelSize = width / image.height;

      for (int j = 0; j < image.height; j++) {
        final pixelInfos = <PixelInfo>[];

        for (int i = 0; i < image.width; i++) {
          final pixel = image.getPixel(i, j);
          pixelInfos.add(
            PixelInfo(
              x: i,
              y: j,
              size: pixelSize,
              color: _colorFrom(pixel, cells[i] == 0),
            ),
          );
        }

        sendPort.send(pixelInfos.map((e) => e.toMap()).toList());
        nextCells[0] = computeNewState(cells.last, cells.first, cells[1]);
        nextCells[width - 1] = computeNewState(
          cells[width - 2],
          cells.last,
          cells.first,
        );

        for (int i = 1; i < width - 1; i++) {
          final left = cells[i - 1];
          final current = cells[i];
          final right = cells[i + 1];
          final newState = computeNewState(left, current, right);
          nextCells[i] = newState;
        }
        cells = nextCells;
      }
      Isolate.exit(sendPort, _terminatingSignal);
    } catch (e, trace) {
      print(e);
      print(trace);
      Isolate.exit(sendPort, _terminatingSignal);
    }
  }

  void _releaseResources() {
    _receivePort?.close();
    _streamSubscription?.cancel();
    _receivePort = null;
    _streamSubscription = null;
  }

  void dispose() {
    _releaseResources();
    _timer?.cancel();
    _pixelInfosCollection = [];
    _operationQueue = [];
    _streamController.close();
  }
}
