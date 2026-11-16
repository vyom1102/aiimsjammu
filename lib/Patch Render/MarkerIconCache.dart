import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIconCache {
  static final Map<String, BitmapDescriptor> _iconCache = {};

  static Future<void> preloadIcons(List<String> buildingNames) async {
    for (String name in buildingNames) {
      if (!_iconCache.containsKey(name)) {
        _iconCache[name] = await bitmapDescriptorFromTextAndImageUpdated(
          name, 'assets/buildingMarker.png',
          imageSize: const Size(100, 100),
        );
      }
    }
    print("_iconCache ${_iconCache.length}");
  }

  static BitmapDescriptor? getIcon(String name) {
    return _iconCache[name];
  }

  static Future<BitmapDescriptor> bitmapDescriptorFromTextAndImageUpdated(
      String text,
      String? imagePath, {
        Size imageSize = const Size(50, 50),
        Color? color,
      }) async {
    if (kIsWeb) {
      imageSize = const Size(45, 45);
    }

    final double fontSize = kIsWeb ? 12.0 : 35.0;
    final double strokeOffset = 3.0;
    final double spacing = 10.0;

    final textStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? const Color(0xff000000),
    );

    final strokeStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    );

    // Create text painters
    final fillPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: text, style: strokeStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    ui.Image? markerImage;
    if (imagePath != null) {
      final ByteData baseImageBytes = await rootBundle.load(imagePath);
      final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
        baseImageBytes.buffer.asUint8List(),
        targetWidth: imageSize.width.toInt(),
        targetHeight: imageSize.height.toInt(),
      );
      final ui.FrameInfo markerImageFrame = await markerImageCodec.getNextFrame();
      markerImage = markerImageFrame.image;
    }

    final double canvasWidth = (markerImage != null)
        ? imageSize.width + spacing + textWidth
        : textWidth;
    final double canvasHeight = (markerImage != null)
        ? (imageSize.height > textHeight ? imageSize.height : textHeight)
        : textHeight;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double imageX = 0;
    final double imageY = (canvasHeight - imageSize.height) / 2;

    final double textX = (markerImage != null) ? (imageSize.width) : 0;
    final double textY = (canvasHeight - textHeight) / 2;

    // Draw stroke around text
    for (double dx in [-strokeOffset, 0, strokeOffset]) {
      for (double dy in [-strokeOffset, 0, strokeOffset]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }

    // Draw main fill text
    fillPainter.paint(canvas, Offset(textX, textY));

    // Draw image if available
    if (markerImage != null) {
      canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());
    }

    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(canvasWidth.toInt(), canvasHeight.toInt());

    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }
}
