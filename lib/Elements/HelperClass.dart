import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:url_launcher/url_launcher.dart';
import '../API/BuildingAPI.dart';
import '../API/buildingAllApi.dart';
import '../APIMODELS/buildingAll.dart';
import '../APIMODELS/landmark.dart';
import '../ELEMENTS/BlurtoothDevice.dart';
import '../MODELS/MarkerIconWithAnchor.dart';
import '../MODELS/VenueModel.dart';
import 'package:http/http.dart' as http;

class HelperClass{
  static bool SemanticEnabled = false;

  BluetoothDevice parseDeviceDetails(String response) {
    final deviceRegex = RegExp(
      r'Device Name: (.+?)\n.*?Address: (.+?)\n.*?RSSI: (-?\d+)(?:.*?Raw Data: ([0-9A-Fa-f\-]+))?',
      dotAll: true,
    );

    final match = deviceRegex.firstMatch(response);

    if (match != null) {
      final deviceName = match.group(1) ?? 'Unknown';
      final deviceAddress = match.group(2) ?? 'Unknown';
      final deviceRssi = match.group(3) ?? '0';
      final rawData = match.group(4) ?? '';

      return BluetoothDevice(
        DeviceName: deviceName,
        DeviceAddress: deviceAddress,
        DeviceRssi: deviceRssi,
        rawData: rawData,
      );
    } else {
      throw Exception('Invalid device details string');
    }
  }

  String getCategoryAsset(String? boothType,String path) {
    switch (boothType) {
      case "Purple Convention":
        return "assets/PurpleConvention.png";
      case "Purple Exhibition":
        return "assets/PurpleExhibition.png";
      case "Purple Experience Zone":
        return "assets/PurpleExperienceZone.png";
      case "Purple Fun":
        return "assets/PurpleFun.png";
      case "Purple Kaleidoscope":
        return "assets/PurpleKaleidoscope.png";
      case "Purple Rain":
        return "assets/PurpleRain.png";
      case "Purple Spectrum":
        return "assets/PurpleSpectrum.png";
      case "Purple Sports":
        return "assets/PurpleSport.png";
      case "Purple Street":
        return "assets/PurpleStreet.png";
      case "Purple Think Tank":
        return "assets/PurpleThinkTank.png";
      default:
        return path; // fallback
    }
  }

  Future<BitmapDescriptor> bitmapDescriptorFromTextAndImage(
      String text,
      String? imagePath, {
        Size imageSize = const Size(50, 50),
        Color? color,
      }) async {
    if (kIsWeb) {
      imageSize = const Size(45, 45);
    }

    final double fontSize = kIsWeb ? 12.0 : 35.0;
    final double strokeOffset = 3; // Offset for stroke emulation

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

    // Create painters
    final fillPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: text, style: strokeStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    // Dimensions
    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;
    final double canvasWidth = textWidth > imageSize.width ? textWidth : imageSize.width;
    final double canvasHeight = textHeight + (imagePath != null ? imageSize.height + 20.0 : 0.0);

    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final textX = (canvasWidth - textWidth) / 2;
    final textY = 0.0;

    // Draw stroke (offsets in all 8 directions)
    for (double dx in [-strokeOffset, 0, strokeOffset]) {
      for (double dy in [-strokeOffset, 0, strokeOffset]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }

    // Draw the actual fill text
    fillPainter.paint(canvas, Offset(textX, textY));

    // Draw image if provided
    if (imagePath != null) {
      final ByteData baseImageBytes = await rootBundle.load(imagePath);
      final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
        baseImageBytes.buffer.asUint8List(),
        targetWidth: imageSize.width.toInt(),
        targetHeight: imageSize.height.toInt(),
      );
      final ui.FrameInfo markerImageFrame = await markerImageCodec.getNextFrame();
      final ui.Image markerImage = markerImageFrame.image;

      final double imageX = (canvasWidth - imageSize.width) / 2;
      final double imageY = textHeight + 10.0;
      canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());
    }

    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(canvasWidth.toInt(), canvasHeight.toInt());

    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes!);
  }


  Future<MarkerIconWithAnchor> bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
      String text,
      String? imagePath, {
        Size imageSize = const Size(50, 50),
        double fontSizee = 35.0,
        Color? color,
        Color? strokeColor,
        Offset? offset,
      }) async {

    final double devicePixelRatio = ui.window.devicePixelRatio;

    // Adjust image size based on device pixel ratio
    Size adjustedImageSize = Size(
      imageSize.width * (devicePixelRatio/2.5),
      imageSize.height * (devicePixelRatio/2.5),
    );

    if (kIsWeb) {
      adjustedImageSize = const Size(45, 45); // Keep web handling same
    }

    final double fontSize = fontSizee * (devicePixelRatio/2.5); // Keep constant font size
    const double strokeOffset = 3.0;
    const double spacing = 0.0;

    // Format text for two-line balance
    // Format text for two-line balance
    final List<String> words = text
        .replaceAll('\n', ' ') // remove any accidental line breaks
        .trim()
        .split(RegExp(r'\s+'));

    final buffer = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      // 🔹 If the word itself is long (>8 chars), put it alone
      if (word.length > 8) {
        buffer.writeln(word);
        continue;
      }

      // 🔹 Otherwise, try to pair with the next word
      if (i + 1 < words.length) {
        final nextWord = words[i + 1];
        if (nextWord.length > 8) {
          buffer.writeln(word);
        } else {
          buffer.writeln("$word $nextWord");
          i++; // skip next word since it's already used
        }
      } else {
        buffer.writeln(word);
      }
    }

    final String formattedText = buffer.toString();


    // Text styles
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
      color: strokeColor ?? Colors.white,
    );

    // Painters
    final fillPainter = TextPainter(
      text: TextSpan(text: formattedText, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: formattedText, style: strokeStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    // Load image
    ui.Image? markerImage;
    if (imagePath != null) {
      final ByteData baseImageBytes = await rootBundle.load(imagePath);
      final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
        baseImageBytes.buffer.asUint8List(),
        targetWidth: adjustedImageSize.width.toInt(),
        targetHeight: adjustedImageSize.height.toInt(),
      );
      final ui.FrameInfo markerImageFrame =
      await markerImageCodec.getNextFrame();
      markerImage = markerImageFrame.image;
    }

    final double canvasWidth = (markerImage != null)
        ? adjustedImageSize.width + spacing + textWidth
        : textWidth;

    final double canvasHeight = (markerImage != null)
        ? (adjustedImageSize.height > textHeight
        ? adjustedImageSize.height
        : textHeight)
        : textHeight;

    // Anchor for LatLng positioning
    final double anchorX = markerImage != null
        ? (adjustedImageSize.width / 2) / canvasWidth
        : 0.5;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double imageX = 0;
    final double imageY = (canvasHeight - adjustedImageSize.height) / 2;
    final double textX =
    (markerImage != null) ? (adjustedImageSize.width + spacing) : 0;
    final double textY = (canvasHeight - textHeight) / 2;

    // Draw stroke around text
    for (double dx in [-strokeOffset, 0, strokeOffset]) {
      for (double dy in [-strokeOffset, 0, strokeOffset]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }

    // Draw main text
    fillPainter.paint(canvas, Offset(textX, textY));

    // Draw image
    if (markerImage != null) {
      canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());
    }

    // Final image
    final ui.Image finalImage =
    await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    double anchorY;

// If there's an image, anchor should align to bottom of image/text combo
    if (markerImage != null) {
      anchorY = (canvasHeight - imageY) / canvasHeight;
    } else {
      // For pure text, anchor at bottom of text block
      anchorY = 1.0;
    }

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      offset ?? Offset(anchorX, anchorY),
    );
  }

  Future<MarkerIconWithAnchor> bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternetNew(
      String text,
      String? imageUrl, {
        Size imageSize = const Size(100, 100),
        double fontSizee = 39.0,
        Color? color,
        Color? strokeColor,
        Offset? offset,
      }) async {
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // Adjust image size based on device pixel ratio
    Size adjustedImageSize = Size(
      imageSize.width * (devicePixelRatio / 2.5),
      imageSize.height * (devicePixelRatio / 2.5),
    );

    if (kIsWeb) {
      adjustedImageSize = const Size(45, 45);
    }

    final double fontSize = fontSizee * (devicePixelRatio / 2.5);
    const double strokeOffset = 3.0;
    const double spacing = 0.0;

    // 🟣 Format text with line breaks for long words
    final List<String> words = text
        .replaceAll('\n', ' ')
        .trim()
        .split(RegExp(r'\s+'));

    final buffer = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.length > 8) {
        buffer.writeln(word);
        continue;
      }
      if (i + 1 < words.length) {
        final nextWord = words[i + 1];
        if (nextWord.length > 8) {
          buffer.writeln(word);
        } else {
          buffer.writeln("$word $nextWord");
          i++;
        }
      } else {
        buffer.writeln(word);
      }
    }

    final String formattedText = buffer.toString();

    // 🟣 Text styles
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
      color: strokeColor ?? Colors.white,
    );

    // Painters
    final fillPainter = TextPainter(
      text: TextSpan(text: formattedText, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: formattedText, style: strokeStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    // 🟣 Load image from internet (if valid)
    ui.Image? markerImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;
          final ui.Codec codec = await ui.instantiateImageCodec(
            bytes,
            targetWidth: adjustedImageSize.width.toInt(),
            targetHeight: adjustedImageSize.height.toInt(),
          );
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          markerImage = frameInfo.image;
        } else {
          print("⚠️ Failed to load image: ${response.statusCode}");
        }
      } catch (e) {
        print("⚠️ Error loading image: $e");
      }
    }

    // 🟣 Canvas sizing
    final double canvasWidth =
    (markerImage != null) ? adjustedImageSize.width + spacing + textWidth : textWidth;

    final double canvasHeight = (markerImage != null)
        ? (adjustedImageSize.height > textHeight
        ? adjustedImageSize.height
        : textHeight)
        : textHeight;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double imageX = 0;
    final double imageY = (canvasHeight - adjustedImageSize.height) / 2;
    final double textX = (markerImage != null) ? (adjustedImageSize.width + spacing) : 0;
    final double textY = (canvasHeight - textHeight) / 2;

    // Stroke around text
    for (double dx in [-strokeOffset, 0, strokeOffset]) {
      for (double dy in [-strokeOffset, 0, strokeOffset]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }

    // Fill text
    fillPainter.paint(canvas, Offset(textX, textY));

    // Draw image (if available)
    if (markerImage != null) {
      canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());
    }

    // Final image
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // 🟣 Dynamic anchor calculation
    double anchorX;
    double anchorY;

    if (markerImage != null) {
      // 🔹 Image + text → same as before
      anchorX = (adjustedImageSize.width / 2) / canvasWidth;
      anchorY = (canvasHeight - imageY) / canvasHeight;
    } else {
      // 🔹 Only text → center anchor
      anchorX = 0.5;
      anchorY = 0.5;
    }

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      offset ?? Offset(anchorX, anchorY),
    );
  }


  Future<MarkerIconWithAnchor> bitmapDescriptorFromCenteredText(
      String text, {
        double fontSizee = 30.0,        // 🔹 Text size
        double strokeWidth = 1,       // 🔹 Stroke thickness
        Color textColor = Colors.black,
        Color strokeColor = const Color(0xfff8f9fa),
      }) async {
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // Scale text size for screen DPI
    final double fontSize = fontSizee * (devicePixelRatio / 2.5);

    // Text styles
    final textStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: textColor,
    );

    final strokeStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: strokeColor,
    );

    // Painters
    final fillPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: text, style: strokeStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    // Canvas
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double canvasWidth = textWidth + strokeWidth * 2;
    final double canvasHeight = textHeight + strokeWidth * 2;

    final double textX = strokeWidth;
    final double textY = strokeWidth;

    // Draw stroke with custom width
    for (double dx in [-strokeWidth, 0, strokeWidth]) {
      for (double dy in [-strokeWidth, 0, strokeWidth]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }

    // Draw main text
    fillPainter.paint(canvas, Offset(textX, textY));

    // Final image
    final ui.Image finalImage =
    await pictureRecorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt());

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      const Offset(0.5, 0.5), // Center anchor
    );
  }

  Future<MarkerIconWithAnchor> bitmapDescriptorFromCenteredTextFormatEDName(
      String text, {
        double fontSizee = 30.0, // 🔹 Text size
        double strokeWidth = 2, // 🔹 Stroke thickness
        Color textColor = Colors.black,
        Color strokeColor = const Color(0xfff8f9fa),
      }) async {
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // 🔹 Split words
    final words = text.trim().split(RegExp(r'\s+'));

    String line1 = "";
    String line2 = "";

    if (words.length == 1) {
      // Only one word
      line1 = words[0];
    } else {
      if (words[0].length < 4 && words.length > 1) {
        // First word short → put first two words together
        line1 = "${words[0]} ${words[1]}";
        if (words.length > 2) {
          line2 = words.sublist(2).join(" ");
        }
      } else {
        // Normal split → first word, rest
        line1 = words[0];
        line2 = words.sublist(1).join(" ");
      }
    }

    final processedText = line2.isNotEmpty ? "$line1\n$line2" : line1;

    // Scale text size for screen DPI
    final double fontSize = fontSizee * (devicePixelRatio / 2.5);

    // Text styles
    final textStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: textColor,
      height: 1.2, // line spacing
    );

    final strokeStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: strokeColor,
      height: 1.2,
    );

    // Painters
    final fillPainter = TextPainter(
      text: TextSpan(text: processedText, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: processedText, style: strokeStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    // Canvas
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double canvasWidth = textWidth + strokeWidth * 2;
    final double canvasHeight = textHeight + strokeWidth * 2;

    final double textX = strokeWidth;
    final double textY = strokeWidth;

    // Draw stroke with custom width
    for (double dx in [-strokeWidth, 0, strokeWidth]) {
      for (double dy in [-strokeWidth, 0, strokeWidth]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }

    // Draw main text
    fillPainter.paint(canvas, Offset(textX, textY));

    // Final image
    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(canvasWidth.toInt(), canvasHeight.toInt());

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      const Offset(0.5, 0.5), // Center anchor
    );
  }



  Future<MarkerIconWithAnchor> bitmapDescriptorFromCenteredTextFormatName(
      String text, {
        double fontSizee = 30.0,        // 🔹 Text size
        double strokeWidth = 2,         // 🔹 Stroke thickness
        Color textColor = Colors.black,
        Color strokeColor = const Color(0xfff8f9fa),
      }) async {
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // 🔹 Preprocess text into one or two lines
    String line1 = "";
    String line2 = "";

    final lhRegex = RegExp(r'^(LH\s*\d+)\s*-\s*(.+)$'); // e.g. "LH 114 - Gate 2"

    if (lhRegex.hasMatch(text)) {
      final match = lhRegex.firstMatch(text)!;
      line1 = match.group(1)!; // LH 114
      line2 = match.group(2)!; // Gate 2
    } else {
      final words = text.split(RegExp(r'\s+'));
      if (words.length >= 2) {
        line1 = "${words[0]} ${words[1]}";
      } else {
        line1 = words[0];
      }
    }

    final processedText = line2.isNotEmpty ? "$line1\n$line2" : line1;

    // Scale text size for screen DPI
    final double fontSize = fontSizee * (devicePixelRatio / 2.5);

    // Text styles
    final textStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: textColor,
      height: 1.2, // line spacing
    );

    final strokeStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: strokeColor,
      height: 1.2,
    );

    // Painters
    final fillPainter = TextPainter(
      text: TextSpan(text: processedText, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: processedText, style: strokeStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    // Canvas
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double canvasWidth = textWidth + strokeWidth * 2;
    final double canvasHeight = textHeight + strokeWidth * 2;

    final double textX = strokeWidth;
    final double textY = strokeWidth;

    // Draw stroke with custom width
    for (double dx in [-strokeWidth, 0, strokeWidth]) {
      for (double dy in [-strokeWidth, 0, strokeWidth]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }

    // Draw main text
    fillPainter.paint(canvas, Offset(textX, textY));

    // Final image
    final ui.Image finalImage =
    await pictureRecorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt());

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      const Offset(0.5, 0.5), // Center anchor
    );
  }


  Future<MarkerIconWithAnchor> bitmapDescriptorFromOutDoorRoads(
      String text,
      String? imagePath, {
        Size imageSize = const Size(50, 50),
        double fontSizee = 35.0,
        Color? color,
        Color? strokeColor
      }) async {
    if (kIsWeb) {
      imageSize = const Size(45, 45);
    }

    List<String> words = text.trim().split(RegExp(r'\s+'));
    int totalLetters = text.replaceAll(RegExp(r'\s+'), '').length;

    if (words.length > 5 && totalLetters > 27) {
      int splitIndex = (words.length / 2).floor();
      text = words.sublist(0, splitIndex).join(' ') +
          '\n' +
          words.sublist(splitIndex).join(' ');
    }

    double fontSize = 35;
    final double strokeOffset = 3.0;
    final double spacing = 0.0;

    // 👇 Format the text: first 2 words on one line, rest on second line

    // Text styles
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
      color: strokeColor??Colors.white,
    );

    // Text painters
    final fillPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: text, style: strokeStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    // Load marker image if provided
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

    // anchorX aligns LatLng to the center of the pin image
    final double anchorX = markerImage != null
        ? imageSize.width / canvasWidth
        : 0.5;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double imageX = 0;
    final double imageY = (canvasHeight - imageSize.height) / 2;

    final double textX = (markerImage != null) ? (imageSize.width + spacing) : 0;
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

    // Draw image
    if (markerImage != null) {
      canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());
    }

    // Final image
    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(canvasWidth.toInt(), canvasHeight.toInt());

    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      Offset(anchorX, 1.0),
    );
  }

  Future<MarkerIconWithAnchor> bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternet(
      String text,
      String? imageUrlOrAsset, {
        Size imageSize = const Size(95, 95),
        Color textColor = Colors.black,
        double fontSizee = 35.0,
        Offset? offset,
      }) async {
    final double devicePixelRatio = ui.window.devicePixelRatio;

    Uint8List? imageBytes;

    // ✅ Try loading image (if URL/asset is valid)
    if (imageUrlOrAsset != null && imageUrlOrAsset.isNotEmpty) {
      try {
        if (imageUrlOrAsset.startsWith("http")) {
          final response = await http.get(Uri.parse(imageUrlOrAsset));
          if (response.statusCode == 200) {
            imageBytes = response.bodyBytes;
          } else {
            print("⚠️ Failed to load network image: ${response.statusCode} ${imageUrlOrAsset}");
          }
        } else {
          final byteData = await rootBundle.load(imageUrlOrAsset);
          imageBytes = byteData.buffer.asUint8List();
        }
      } catch (e) {
        print("⚠️ Error loading image: $e");
        imageBytes = null; // fall back to text-only
      }
    }

    // 🔹 Format text based on your custom condition
    final List<String> words = text
        .replaceAll('\n', ' ')
        .trim()
        .split(RegExp(r'\s+'));

    final buffer = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      // If the word itself is long (>8 chars), put it alone
      if (word.length > 8) {
        buffer.writeln(word);
        continue;
      }

      // Otherwise, try to pair with the next word
      if (i + 1 < words.length) {
        final nextWord = words[i + 1];
        if (nextWord.length > 8) {
          buffer.writeln(word);
        } else {
          buffer.writeln("$word $nextWord");
          i++; // skip next word
        }
      } else {
        buffer.writeln(word);
      }
    }

    final String formattedText = buffer.toString();
    print("✅ formattedText: $formattedText");

    // 🔹 Setup text painter using formatted text
    final double fontSize = fontSizee * (devicePixelRatio / 2.5);
    final double strokeOffset = 2.0;

    final textStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: textColor,
    );

    final strokeStyle = TextStyle(
      fontFamily: 'PT_Sans',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    );

    final fillPainter = TextPainter(
      text: TextSpan(text: formattedText, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final strokePainter = TextPainter(
      text: TextSpan(text: formattedText, style: strokeStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = fillPainter.width;
    final double textHeight = fillPainter.height;

    // 🔹 If image fails or null → only text
    if (imageBytes == null) {
      final double canvasWidth = textWidth + 20;
      final double canvasHeight = textHeight + 20;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final double textX = (canvasWidth - textWidth) / 2;
      final double textY = (canvasHeight - textHeight) / 2;

      // Stroke + fill
      for (double dx in [-strokeOffset, 0, strokeOffset]) {
        for (double dy in [-strokeOffset, 0, strokeOffset]) {
          if (dx != 0 || dy != 0) {
            strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
          }
        }
      }
      fillPainter.paint(canvas, Offset(textX, textY));

      final ui.Image textOnlyImage =
      await recorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt());

      final ByteData? byteData =
      await textOnlyImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      return MarkerIconWithAnchor(
        BitmapDescriptor.fromBytes(pngBytes),
        offset ?? const Offset(0.5, 1.0),
      );
    }

    // 🔹 Otherwise, proceed with image + text
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      completer.complete(img);
    });
    final ui.Image originalImage = await completer.future;

    // Maintain aspect ratio
    final double originalAspectRatio = originalImage.width / originalImage.height;
    final double targetAspectRatio = imageSize.width / imageSize.height;

    Size actualImageSize;
    if (originalAspectRatio > targetAspectRatio) {
      actualImageSize = Size(
        imageSize.width,
        imageSize.width / originalAspectRatio,
      );
    } else {
      actualImageSize = Size(
        imageSize.height * originalAspectRatio,
        imageSize.height,
      );
    }

    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: actualImageSize.width.toInt(),
      targetHeight: actualImageSize.height.toInt(),
    );
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    // Canvas size
    final double canvasWidth = max(imageSize.width, textWidth);
    final double canvasHeight = imageSize.height + textHeight + 8;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final double imageX = (canvasWidth - actualImageSize.width) / 2;
    final double imageY = (imageSize.height - actualImageSize.height) / 2;
    final double textX = (canvasWidth - textWidth) / 2;
    final double textY = imageSize.height + 8;

    // Draw image + text
    canvas.drawImage(image, Offset(imageX, imageY), Paint());

    for (double dx in [-strokeOffset, 0, strokeOffset]) {
      for (double dy in [-strokeOffset, 0, strokeOffset]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, Offset(textX + dx, textY + dy));
        }
      }
    }
    fillPainter.paint(canvas, Offset(textX, textY));

    // Final image
    final ui.Image finalImage =
    await recorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      offset ?? const Offset(0.5, 0.5),
    );
  }



  Future<void> saveJsonToAndroidDownloads(String fileName, String jsonString) async {
    if(!kIsWeb){
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      }

      if (downloadsDir == null || !downloadsDir.existsSync()) {
        print("❌ Could not access Downloads folder.");
        return;
      }

      final filePath = '${downloadsDir.path}/$fileName.json';
      final file = File(filePath);

      try {
        await file.writeAsString(jsonString, flush: true);
        print("✅ JSON file saved at: $filePath");
      } catch (e) {
        print("❌ Error writing JSON file: $e");
      }
    }
  }

  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> sendMailto({
    String email = "mail@example.com",
  }) async {
    final String emailSubject = "Feedbacks";
    final Uri parsedMailto = Uri.parse(
        "mailto:<$email>?subject=$emailSubject");

    if (!await launchUrl(
      parsedMailto,
      mode: LaunchMode.externalApplication,
    )) {
      throw "error";
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }


  static String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + ' ..';
    }
  }
  static void showToast(String mssg) {
    if(!kDebugMode) return;
    Fluttertoast.showToast(
      msg: mssg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }


  static List<bool> getCommonConnectionsStatus(Landmarks landmark1, Landmarks landmark2) {
    return [
      landmark1.lifts!.any((lift1) =>
          landmark2.lifts!.any((lift2) => lift1.name == lift2.name)), // Lifts
      landmark1.stairs!.any((stair1) =>
          landmark2.stairs!.any((stair2) => stair1.name == stair2.name)), // Stairs
      landmark1.ramps!.any((ramp1) =>
          landmark2.ramps!.any((ramp2) => ramp1.name == ramp2.name)), // Ramps
      landmark1.escalators!.any((escalator1) =>
          landmark2.escalators!.any((escalator2) => escalator1.name == escalator2.name)) // Escalators
    ];
  }

  static Future<void> shareContent(String text, String name) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: text,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw Exception('QR code generation failed');
      }
      final qrCode = qrValidationResult.qrCode;

      final ByteData imageData = await rootBundle.load('assets/qrlogo.png');
      final ui.Codec codec = await ui.instantiateImageCodec(imageData.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image image = fi.image;

      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF0B6B94),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
        embeddedImage: image,
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(300, 300),
        ),
      );

      final int qrSize = 2048;
      final int padding = 100;
      final int totalSize = qrSize + (2 * padding);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.src);
      canvas.translate(padding.toDouble(), padding.toDouble());
      painter.paint(canvas, Size(qrSize.toDouble(), qrSize.toDouble()));
      final picture = recorder.endRecording();
      final img = await picture.toImage(totalSize, totalSize);
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = pngBytes!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$name.png';
      final file = await File(tempPath).writeAsBytes(buffer);
      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (e) {
      print('Error sharing content: $e');
    }
  }

  static Future<HashMap<String,List<buildingAll>>> groupBuildings(List<buildingAll> data)async{
    HashMap<String,List<buildingAll>> venueMap = HashMap();
    for(buildingAll building in data){
      venueMap.putIfAbsent(building.venueName!, ()=>[]);
      venueMap[building.venueName]!.add(building);
    }
    return venueMap;
  }

  static Future<Map<String,g.LatLng>> createAllbuildingMap (HashMap<String,List<buildingAll>> venueMap, String venue)async{
    Map<String,g.LatLng> AllBuildingMap = Map();
    for (var building in venueMap[venue]!) {
      AllBuildingMap[building.sId!] = g.LatLng(building.coordinates![0], building.coordinates![1]);
    }
    return AllBuildingMap;
  }

  static String extractLandmark(String url) {
    final RegExp regex = RegExp(r'source=([^&]*)&appStore');
    final Match? match = regex.firstMatch(url);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    } else {
      return '';
    }
  }

  static Map<String, List<buildingAll>> createVenueHashMap(List<buildingAll> buildingList) {
    Map<String, List<buildingAll>> dummyVenueHashMap = HashMap<String, List<buildingAll>>();

    for (buildingAll building in buildingList) {
      // Check if the venueName is already a key in the HashMap
      if (dummyVenueHashMap.containsKey(building.venueName)) {
        // If yes, add the building to the existing list
        dummyVenueHashMap[building.venueName]!.add(building);
      } else {
        // If no, create a new list with the building and add it to the HashMap
        dummyVenueHashMap[building.venueName??""] = [building];
      }
    }
    return dummyVenueHashMap;
  }
  static List<VenueModel> createVenueList(Map<String, List<buildingAll>> venueHashMap){
    List<VenueModel> newList = [];
    for (var entry in venueHashMap.entries) {
      String key = entry.key;
      List<buildingAll> value = entry.value;
      newList.add(VenueModel(venueName: key, distance: 190, buildingNumber: value.length, imageURL: value[0].venuePhoto??"", Tag: value[0].venueCategory??"", address: value[0].address,description: value[0].description,phoneNo: value[0].phone,website: value[0].website,coordinates: value[0].coordinates!, dist: 0));
      // print('Key: $key');
      // print('Value: $value');
    }
    return newList;
  }
  static Map<String, List<buildingAll>> venueHashMap=new HashMap();
  static List<VenueModel> venueList=[];
  static List<VenueModel> buildingsPos=[];
  static buildingApicall()async{
    await buildingAllApi().fetchBuildingAllData().then((value) {
     // print(value);
     venueHashMap=createVenueHashMap(value);
     venueList = createVenueList(venueHashMap);
     for(int i=0;i<venueList.length;i++)
     {
       buildingsPos.add(venueList[i]);
     }
    });

  }


  static Future<bool> getGeoFenced(Position userPos)async{
    bool res=false;
    await BuildingAPI().fetchBuildData().then((value){
      for(int i=0;i<value.data!.length;i++){
        // if(isPointInsidePolygon(value.data![i].boundary!,userPos) || UserCredentials().getRoles().contains('admin')){
        //   print("got inside geo fenced condition");
        //   res=true;
        //   return;
        // }
      }
    });
    return res;
    // await buildingApicall();
    // List<buildingAll>? buildingList=venueHashMap[venueName];
    // for(int i=0;i<buildingList!.length;i++){
    //   var currentData=buildingList[i];
    //   if(currentData.geofencing!=null && currentData.geofencing!){
    //     for(int j=0;j<venueList.length;j++){
    //       if(userPos.latitude.toStringAsFixed(2)==venueList[j].coordinates[0].toStringAsFixed(2) && userPos.longitude.toStringAsFixed(2)==venueList[j].coordinates[1].toStringAsFixed(2)){
    //         return 0;
    //       }
    //     }
    //   }else{
    //     return 1;
    //   }
    // }
    // return 2;

  }





  double getBinWeight(int rssi){
    if (rssi <= 55) {
      return 12.0;
    }else if (rssi <= 65) {
      return 9.0;
    } else if (rssi <= 75) {
      return 4.0;
    } else if (rssi <= 80) {
      return 3.0;
    } else if (rssi <= 85) {
      return 2.0;
    } else if (rssi <= 90) {
      return 0.5;
    } else if (rssi <= 95) {
      return 0.25;
    } else {
      return 0.1;
    }
  }



}