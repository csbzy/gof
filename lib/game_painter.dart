import 'dart:ui';

import 'package:flutter/material.dart';

class GameBoyScreen {
  static int gameBoyAdvancedWidth = 240;
  static int gameBoyWidth = 160;
}

/// LCD painter is used to copy the LCD data from the gameboy PPU to the screen.
class LCDPainter extends CustomPainter {
  LCDPainter(this.img, this.scale, this.width, this.height);

  /// Indicates if the LCD is drawing new content
  bool drawing = false;
  List<int> img;

  double scale;
  int width;
  int height;

  @override
  void paint(Canvas canvas, Size size) {
    drawing = true;
    if (img.isEmpty) {
      drawing = false;
      return;
    }

    final isGameBoyAdvance = width == GameBoyScreen.gameBoyAdvancedWidth;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        Paint color = Paint();
        color.style = PaintingStyle.stroke;
        color.strokeWidth = 1.0;
        final i = x + y * width;
        int r, g, b = 0;
        if (isGameBoyAdvance) {
          r = img[i * 4];
          g = img[i * 4 + 1];
          b = img[i * 4 + 2];
        } else {
          r = img[i * 3];
          g = img[i * 3 + 1];
          b = img[i * 3 + 2];
        }

        color.color =
            Color(0xFF000000 | ((r & 0xFF) << 16 | (g & 0xFF) << 8 | b & 0xFF));

        List<Offset> points = [];
        var xStart = (x * scale).toInt();
        var yStart = (y * scale).toInt();
        final xEnd = (x + 1) * scale;
        final yEnd = (y + 1) * scale;
        if (scale > 1) {
          for (int actualY = yStart; actualY < yEnd; actualY++) {
            for (int actualX = xStart; actualX < xEnd; actualX++) {
              points.add(Offset(actualX.toDouble(), (actualY).toDouble()));
            }
          }
        } else {
          points.add(Offset(xStart.toDouble(), yStart.toDouble()));
        }
        canvas.drawPoints(PointMode.points, points, color);
      }
    }

    drawing = false;
  }

  @override
  bool shouldRepaint(LCDPainter oldDelegate) {
    return !drawing;
  }
}
