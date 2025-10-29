import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/Elements/HelperClass.dart';

import '../API/buildingAllApi.dart';
import '../buildingState.dart';
import '../singletonClass.dart';
import '/Patch%20Render/MarkerIconCache.dart';

class MapOverlayBuilder {
  Set<Marker> _markers = {};
  Set<Polygon> _polygons = {};

  Set<Marker> get markers => _markers;
  Set<Polygon> get polygons => _polygons;

  bool _outDoorUpdated = false;
  bool _outDoorBuildingUpdates = false;

  void onCameraMoveForMapPatchController(CameraPosition cameraPosition) {
    if (cameraPosition.zoom > 19) {
      if (_markers.isNotEmpty || _polygons.isNotEmpty) {
        _markers.clear();
        _polygons.clear();
      }
      _outDoorBuildingUpdates = false;
    } else if (cameraPosition.zoom < 19 && cameraPosition.zoom > 16.2) {
      if (!_outDoorBuildingUpdates) {
        _outDoorUpdated = false;
        _renderCampusPatchTransition(
          buildingAllApi.allBuildingID.keys.toList(),
          outdoorID: buildingAllApi.outdoorID,
        );
        _outDoorBuildingUpdates = true;
      }
    } else if (cameraPosition.zoom <= 16.2) {
      _markers = _markers.where((marker) => marker.markerId.value.contains(buildingAllApi.outdoorID)).toSet();
      if (!_outDoorUpdated) {
        _outDoorBuildingUpdates = false;
        _renderCampusPatchTransition([buildingAllApi.outdoorID]);
        _outDoorUpdated = true;
      }
    }
  }

  Future<void> _renderCampusPatchTransition(List<String> IDS, {String? outdoorID}) async {
    _polygons.clear();
    _markers.clear();
    print("IDS.length $IDS");
    print(IDS.contains(outdoorID));
    if(IDS.length>1) {
      IDS.remove(outdoorID);
      print("inlength ${outdoorID}");
      _markers.removeWhere((markers)=>markers.markerId.toString().contains(outdoorID!));
      _polygons.removeWhere((polygon) => polygon.polygonId.toString().contains(outdoorID!));
    }

    for (String id in IDS) {
      if (id == outdoorID) continue;

      final coordinates = SingletonFunctionController.building.ARCoordinates[id];
      if (coordinates != null && coordinates.isNotEmpty) {
        final sortedPoints = LinkedHashMap.fromEntries(
          coordinates.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        );

        final polygonPoints = sortedPoints.values.toList();

        _polygons.add(
          Polygon(
            polygonId: PolygonId('patch$id'),
            points: polygonPoints,
            strokeWidth: 1,
            strokeColor: Colors.black.withOpacity(0.5),
            fillColor: Colors.blue.withOpacity(0.1),
            geodesic: false,
            consumeTapEvents: true,
            zIndex: 5,
          ),
        );
      }

      final buildingName = Building.buildingData?[id]?.trim() ?? "Tower";
      final position = Building.allBuildingID[id];

      if (position != null) {
        final result = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(buildingName, 'assets/buildingMarker.png', imageSize: const Size(100, 100),);
        final icon = result.icon;
        final anchor = result.anchor;


        _markers.add(
          Marker(
            markerId: MarkerId('$id$buildingName'),
            position: position,
            icon: icon,
            anchor: anchor,
          ),
        );
      }
    };
  }

  static Future<BitmapDescriptor> _bitmapDescriptorFromTextAndImageUpdated(
      String text,
      String? imagePath, {
        Size imageSize = const Size(50, 50),
        double fontSizee = 35.0,
        Color? color,
      }) async {
    if (kIsWeb) imageSize = const Size(45, 45);

    final double fontSize = kIsWeb ? 12.0 : fontSizee;
    const double strokeOffset = 3.0;
    const double spacing = 10.0;

    final fillPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'PT_Sans',
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: color ?? Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final strokePainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'PT_Sans',
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = fillPainter.width;
    final textHeight = fillPainter.height;

    ui.Image? markerImage;
    if (imagePath != null) {
      final data = await rootBundle.load(imagePath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: imageSize.width.toInt(),
        targetHeight: imageSize.height.toInt(),
      );
      markerImage = (await codec.getNextFrame()).image;
    }

    final canvasWidth = (markerImage != null)
        ? imageSize.width + spacing + textWidth
        : textWidth;
    final canvasHeight = (markerImage != null)
        ? (imageSize.height > textHeight ? imageSize.height : textHeight)
        : textHeight;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final imageOffset = Offset(0, (canvasHeight - imageSize.height) / 2);
    final textOffset = Offset(
      (markerImage != null ? imageSize.width + spacing : 0),
      (canvasHeight - textHeight) / 2,
    );

    for (final dx in [-strokeOffset, 0, strokeOffset]) {
      for (final dy in [-strokeOffset, 0, strokeOffset]) {
        if (dx != 0 || dy != 0) {
          strokePainter.paint(canvas, textOffset.translate(dx.toDouble(), dy.toDouble()));
        }
      }
    }

    fillPainter.paint(canvas, textOffset);
    if (markerImage != null) {
      canvas.drawImage(markerImage, imageOffset, Paint());
    }

    final image = await recorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
