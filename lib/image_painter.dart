import 'package:cellular_automata_image_effects/pixel_info.dart';
import 'package:flutter/material.dart';

class ImagePainter extends CustomPainter {
  final List<List<PixelInfo>> pixelInfosCollection;

  const ImagePainter({required this.pixelInfosCollection});

  @override
  void paint(Canvas canvas, Size size) {
    for (final pixelInfos in pixelInfosCollection) {
      for (final pixelInfo in pixelInfos) {
        pixelInfo.drawPixelOn(canvas);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ImagePainter oldDelegate) =>
      oldDelegate.pixelInfosCollection != pixelInfosCollection;
}
