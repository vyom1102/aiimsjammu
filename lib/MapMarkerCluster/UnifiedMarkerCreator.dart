import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class MarkerIconWithAnchor {
  final BitmapDescriptor icon;
  final Offset anchor; // normalized [0..1] offset

  MarkerIconWithAnchor(this.icon, this.anchor);
}

enum MarkerLayout {
  vertical, // Image top, text bottom
  horizontal, // Image left, text right
  textOnly, // No image, just text
  imageOnly, // Only image, no text
}

enum TextFormat {
  simple,
  smartWrap,
  lhFormat,
  centered,
}

class UnifiedMarkerCreator {
  /// Creates a crisp marker that keeps the same *physical* size across devices.
  /// imageSize is in logical dp (same units you'd expect for Flutter widgets).
  Future<MarkerIconWithAnchor> createUnifiedMarker({
    required String text,
    String? imageSource,
    MarkerLayout layout = MarkerLayout.vertical,
    TextFormat textFormat = TextFormat.smartWrap,
    Size imageSize = const Size(35, 35), // logical dp
    double fontSize = 12.0, // logical sp
    Color textColor = Colors.black,
    Color strokeColor = const Color(0xfff8f9fa),
    double strokeWidth = 2.0, // logical
    double spacing = 0.0, // logical
    Offset? customAnchor, // normalized if provided
    bool maintainAspectRatio = true,
  }) async {
    final double ratio = ui.window.devicePixelRatio; // device pixel ratio

    // Convert logical sizes to pixel sizes (so final PNG has pixel-perfect content)
    final double imageWidthPx = imageSize.width * ratio;
    final double imageHeightPx = imageSize.height * ratio;
    final double fontSizePx = fontSize * ratio;
    final double strokeWidthPx = strokeWidth * ratio;
    final double spacingPx = spacing * ratio;

    // Format text
    final String formattedText = _formatText(text, textFormat);

    // Load & decode image at exact pixel size (if provided)
    ui.Image? markerImage;
    Size actualImageSizePx = Size(imageWidthPx, imageHeightPx);

    if (imageSource != null && imageSource.isNotEmpty) {
      try {
        Uint8List? bytes;
        if (imageSource.startsWith('http')) {
          final response = await http.get(Uri.parse(imageSource));
          if (response.statusCode == 200) bytes = response.bodyBytes;
        } else {
          final bd = await rootBundle.load(imageSource);
          bytes = bd.buffer.asUint8List();
        }

        if (bytes != null) {
          // Decode original to get aspect ratio
          final Completer<ui.Image> originalCompleter = Completer();
          ui.decodeImageFromList(
              bytes, (ui.Image img) => originalCompleter.complete(img));
          final ui.Image originalImage = await originalCompleter.future;
          if (maintainAspectRatio) {
            final double origAR = originalImage.width / originalImage.height;
            final double targetAR = imageWidthPx / imageHeightPx;
            if (origAR > targetAR) {
              // image is wider -> fit width
              actualImageSizePx = Size(imageWidthPx, imageWidthPx / origAR);
            } else {
              // image is taller or equal -> fit height
              actualImageSizePx = Size(imageHeightPx * origAR, imageHeightPx);
            }
          } else {
            actualImageSizePx = Size(imageWidthPx, imageHeightPx);
          }

          // instantiate codec at final pixel size (prevents later upscaling)
          final codec = await ui.instantiateImageCodec(
            bytes,
            targetWidth: actualImageSizePx.width.toInt().clamp(1, 10000),
            targetHeight: actualImageSizePx.height.toInt().clamp(1, 10000),
          );
          final frame = await codec.getNextFrame();
          markerImage = frame.image;
        }
      } catch (e) {
        // keep markerImage null and fallback to text-only layout
        print('⚠️ image load failed: $e');
        markerImage = null;
      }
    }

    // If attempted image but failed -> fallback to textOnly (unless imageOnly requested)
    if (markerImage == null &&
        imageSource != null &&
        layout != MarkerLayout.imageOnly) {
      layout = MarkerLayout.textOnly;
    }
    if (layout == MarkerLayout.imageOnly && markerImage == null) {
      throw Exception('imageOnly requires a valid image source');
    }

    // Prepare text painters (measured in pixels)
    TextPainter? fillPainter;
    TextPainter? strokePainter;
    double textWidthPx = 0;
    double textHeightPx = 0;

    if (layout != MarkerLayout.imageOnly && formattedText.isNotEmpty) {
      final fillStyle = TextStyle(
        fontFamily: 'PT_Sans',
        fontSize: fontSizePx,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.0,
      );
      final strokeStyle = TextStyle(
        fontFamily: 'PT_Sans',
        fontSize: fontSizePx,
        fontWeight: FontWeight.w500,
        color: strokeColor,
        height: 1.0,
      );

      fillPainter = TextPainter(
        text: TextSpan(text: formattedText, style: fillStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      strokePainter = TextPainter(
        text: TextSpan(text: formattedText, style: strokeStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      // We must give a sufficiently large max width in pixels.
      // This ensures multi-line wrapping behaves like you'd expect.
      // Choose a generous maximum width in pixels (e.g., 300 dp * ratio)
      final double maxTextWidthPx = (300.0 * ratio);
      fillPainter.layout(minWidth: 0, maxWidth: maxTextWidthPx);
      strokePainter.layout(minWidth: 0, maxWidth: maxTextWidthPx);

      textWidthPx = fillPainter.width;
      textHeightPx = fillPainter.height;
    }

    // Compute canvas size in pixels depending on layout
    double canvasWidthPx;
    double canvasHeightPx;
    double imageX = 0, imageY = 0, textX = 0, textY = 0;

    switch (layout) {
      case MarkerLayout.horizontal:
        if (markerImage != null) {
          canvasWidthPx = actualImageSizePx.width +
              spacingPx +
              textWidthPx +
              strokeWidthPx * 2;
          canvasHeightPx =
              max(actualImageSizePx.height, textHeightPx) + strokeWidthPx * 2;
          imageX = strokeWidthPx;
          imageY = (canvasHeightPx - actualImageSizePx.height) / 2;
          textX = imageX + actualImageSizePx.width + spacingPx;
          textY = (canvasHeightPx - textHeightPx) / 2;
        } else {
          canvasWidthPx = textWidthPx + strokeWidthPx * 2;
          canvasHeightPx = textHeightPx + strokeWidthPx * 2;
          textX = strokeWidthPx;
          textY = strokeWidthPx;
        }
        break;

      case MarkerLayout.vertical:
        if (markerImage != null) {
          canvasWidthPx =
              max(actualImageSizePx.width, textWidthPx) + strokeWidthPx * 2;
          canvasHeightPx = actualImageSizePx.height +
              spacingPx +
              textHeightPx +
              strokeWidthPx * 2;
          imageX = (canvasWidthPx - actualImageSizePx.width) / 2;
          imageY = strokeWidthPx;
          textX = (canvasWidthPx - textWidthPx) / 2;
          textY = imageY + actualImageSizePx.height + spacingPx;
        } else {
          canvasWidthPx = textWidthPx + strokeWidthPx * 2;
          canvasHeightPx = textHeightPx + strokeWidthPx * 2;
          textX = strokeWidthPx;
          textY = strokeWidthPx;
        }
        break;

      case MarkerLayout.textOnly:
        canvasWidthPx = textWidthPx + strokeWidthPx * 2;
        canvasHeightPx = textHeightPx + strokeWidthPx * 2;
        textX = strokeWidthPx;
        textY = strokeWidthPx;
        break;

      case MarkerLayout.imageOnly:
        canvasWidthPx = actualImageSizePx.width;
        canvasHeightPx = actualImageSizePx.height;
        imageX = 0;
        imageY = 0;
        break;
    }

    // Ensure integer pixel dimensions at least 1
    final int canvasW = max(1, canvasWidthPx.ceil());
    final int canvasH = max(1, canvasHeightPx.ceil());

    // Draw into picture recorder (working in pixel units)
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Draw image (if exists) with high quality
    if (markerImage != null) {
      final paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;
      canvas.drawImage(markerImage, Offset(imageX, imageY), paint);
    }

    // Draw text stroke then fill with improved quality
    if (fillPainter != null &&
        strokePainter != null &&
        layout != MarkerLayout.imageOnly) {
      final textOffset = Offset(textX, textY);

      // Draw stroke in 8 directions only for better quality (instead of full grid)
      if (strokeWidthPx > 0) {
        final double offset = strokeWidthPx;

        // Draw in 8 cardinal and diagonal directions
        final directions = [
          Offset(-offset, 0),
          Offset(offset, 0),
          Offset(0, -offset),
          Offset(0, offset),
          Offset(-offset, -offset),
          Offset(offset, -offset),
          Offset(-offset, offset),
          Offset(offset, offset),
        ];

        for (final dir in directions) {
          strokePainter.paint(
              canvas, Offset(textOffset.dx + dir.dx, textOffset.dy + dir.dy));
        }
      }

      // Draw main fill on top
      fillPainter.paint(canvas, textOffset);
    }

    // Finish and convert to image at final pixel dimensions
    final ui.Image finalImage =
        await recorder.endRecording().toImage(canvasW, canvasH);
    final ByteData? pngBytesData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    if (pngBytesData == null)
      throw Exception('Failed to encode marker image to PNG.');
    final Uint8List pngBytes = pngBytesData.buffer.asUint8List();

    // Calculate normalized anchor (0..1)
    Offset anchor;
    if (customAnchor != null) {
      anchor = customAnchor;
    } else {
      // Default anchors depending on layout:
      if (markerImage == null) {
        // Center for text-only
        anchor = Offset(0.5, 0.5);
      } else {
        switch (layout) {
          case MarkerLayout.horizontal:
            // center of image horizontally, bottom of canvas vertically
            final double ax = (imageX + actualImageSizePx.width / 2) / canvasW;
            final double ay = (imageY + actualImageSizePx.height) / canvasH;
            anchor = Offset(ax.clamp(0.0, 1.0), ay.clamp(0.0, 1.0));
            break;
          case MarkerLayout.vertical:
            // center horizontally, bottom of image vertically (so marker tip aligns)
            final double ax2 = (imageX + actualImageSizePx.width / 2) / canvasW;
            final double ay2 = (imageY + actualImageSizePx.height) / canvasH;
            anchor = Offset(ax2.clamp(0.0, 1.0), ay2.clamp(0.0, 1.0));
            break;
          case MarkerLayout.imageOnly:
            anchor = Offset(0.5, 0.5);
            break;
          case MarkerLayout.textOnly:
            anchor = Offset(0.5, 0.5);
            break;
        }
      }
    }

    final descriptor = BitmapDescriptor.fromBytes(pngBytes);
    return MarkerIconWithAnchor(descriptor, anchor);
  }

  String _formatText(String text, TextFormat format) {
    switch (format) {
      case TextFormat.simple:
        return text;
      case TextFormat.centered:
        return text;
      case TextFormat.lhFormat:
        final lhRegex = RegExp(r'^(LH\s*\d+)\s*-\s*(.+)$');
        if (lhRegex.hasMatch(text)) {
          final match = lhRegex.firstMatch(text)!;
          return "${match.group(1)!}\n${match.group(2)!}";
        } else {
          final words = text.split(RegExp(r'\s+'));
          if (words.length >= 2) {
            return "${words[0]} ${words[1]}";
          }
          return words[0];
        }
      case TextFormat.smartWrap:
        final words = text.trim().split(RegExp(r'\s+'));
        List<String> lines = [];
        int index = 0;
        bool isFirstWordNumber = words.isNotEmpty && RegExp(r'^\d+(/\d+)?$').hasMatch(words[0]);
        if (isFirstWordNumber) {
          lines.add(words[0]);
          index = 1;
        }
        int remainingCount = words.length - index;
        if (remainingCount == 2) {
          lines.add(words[index]);
          lines.add(words[index + 1]);
          index += 2;
        } else if (remainingCount % 2 == 1 && index < words.length) {
          lines.add(words[index]);
          index++;
        }
        while (index < words.length) {
          if (index + 1 < words.length) {
            String firstWord = words[index];
            String secondWord = words[index + 1];
            String pair = "$firstWord $secondWord";
            if (pair.length > 20) {
              lines.add(firstWord);
              index++;
            } else {
              lines.add(pair);
              index += 2;
            }
          } else {
            lines.add(words[index]);
            index++;
          }
        }
        List<String> finalLines = [];
        for (int i = 0; i < lines.length; i++) {
          String line = lines[i];
          List<String> lineWords = line.split(' ');
          if (lineWords.last.length <= 2 && i + 1 < lines.length) {
            String shortWord = lineWords.last;
            String restOfLine = lineWords.sublist(0, lineWords.length - 1).join(' ');
            String nextLineWithShort = "$shortWord ${lines[i + 1]}";
            if (nextLineWithShort.length <= 20) {
              if (restOfLine.isNotEmpty) {
                finalLines.add(restOfLine);
              }
              lines[i + 1] = nextLineWithShort;
            } else {
              finalLines.add(line);
            }
          } else {
            finalLines.add(line);
          }
        }
        return finalLines.join("\n");
    }
  }
}
