import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import '../API/buildingAllApi.dart';
import '../APIMODELS/polylinedata.dart';
import '../Cell.dart';
import '../UserState.dart';
import '../cutommarker.dart';
import '../navigationTools.dart';
import '../singletonClass.dart';
// assuming your utils are here

class PlayPreviewManager {
  final ValueNotifier<Set<gmap.Marker>> previewMarkersNotifier = ValueNotifier({});
  Map<String, Map<int, Set<gmap.Polyline>>> _pathCovered = {};
  Map<String, Map<int, Set<gmap.Marker>>> _previewMarker = {};
  bool _isPlaying = false;
  bool _isCancelled = false;
  bool _stopAnimation = false;
  CameraPosition? _cameraPosition;
  static Function alignMapToPath = (List<double> A, List<double> B,{bool isTurn=false}) {};
  static Function findLift = (String floor, List<Floors> floorData) {};
  static Function findCommonLift = (List<PolyArray> list1, List<PolyArray> list2) {};
  static Function createRooms=(int floor, String bid){};
  Map<String, Map<int, Set<gmap.Polyline>>> get pathCovered => _pathCovered;
  Map<String, Map<int, Set<gmap.Marker>>> get previewMarker => _previewMarker;


  bool get isPlaying => _isPlaying;

  set cameraPosition(CameraPosition value) {
    _cameraPosition = value;
  }

  void clear(){
    _pathCovered.clear();
    _pathCovered = {};
  }

  void clearPreview() {
    cancel();
    stop();
    _stopAnimation = true;
    _isCancelled = true;

    _pathCovered = {};

    _previewMarker.forEach((key, floorMap) {
      floorMap.forEach((floor, markerSet) => markerSet.clear());
    });
    _previewMarker.clear();

    print("✅ Cleared preview data successfully.");
    _pathCovered = {};
  }


  void cancel() {
    _isCancelled = true;
  }

  void stop() {
    _stopAnimation = true;
  }

  Future<void> playPreviewAnimation({required List<Cell> pathList}) async {
    if (_isPlaying || pathList.isEmpty) return;
    _pathCovered.clear();
    Uint8List iconMarker = await getImagesFromMarker('assets/previewarrow.png', 80);
    _isPlaying = true;
    _isCancelled = false;
    _stopAnimation = false;
    try {
      List<gmap.LatLng> currentCoordinates = [];

      int lastFloorItterated = pathList.first.floor;
      String lastBidIterated = pathList.first.bid!;
      createRooms(lastFloorItterated, lastBidIterated);
      for (int i = 0; i < pathList.length; i++) {
        if (_isCancelled || _stopAnimation) {
          print("🔴 Animation stopped manually.");

          return;
        }
        Cell current = pathList[i];
        Cell next = pathList[i];
        if(i<pathList.length-1){
          next = pathList[i+1];
        }
        double row = current.lat;
        double col = current.lng;
        double row1 = next.lat;
        double col1 = next.lng;
        List<double> value = [row, col];
        List<double> value1 = [row1, col1];
        final buildingId = next.bid!;
        final floorId = next.floor;
        gmap.Marker marker = gmap.Marker(
          markerId: gmap.MarkerId("preview_marker"),
          position: gmap.LatLng(pathList.first.lat, pathList.first.lng),
          icon: gmap.BitmapDescriptor.fromBytes(iconMarker),
          anchor: Offset(0.5, 0.5),
        );
        if (floorId != lastFloorItterated || buildingId != lastBidIterated){
          lastFloorItterated = floorId;
          lastBidIterated = buildingId;
          createRooms(lastFloorItterated, lastBidIterated);
          currentCoordinates.clear();
          value1 = [row1, col1];
          // 🛠️ Reinitialize marker at indoor entry
          marker = gmap.Marker(
            markerId: gmap.MarkerId("preview_marker"),
            position: gmap.LatLng(value1[0], value1[1]),
            icon: gmap.BitmapDescriptor.fromBytes(iconMarker),
            anchor: Offset(0.5, 0.5),
          );
          _previewMarker.clear();
          _previewMarker.putIfAbsent(lastBidIterated, () => {});
          _previewMarker[lastBidIterated]!.putIfAbsent(lastFloorItterated, () => <gmap.Marker>{});
          _previewMarker[lastBidIterated]![lastFloorItterated]!.clear();
          _previewMarker[lastBidIterated]![lastFloorItterated]!.add(marker);
        }
        final gStart = gmap.LatLng(value[0], value[1]);
        final gEnd = gmap.LatLng(value1[0], value1[1]);
        List<gmap.LatLng> interpolatedPoints;
        if (buildingId == buildingAllApi.outdoorID || current.masterGraph){
          print("in outdoor:${gStart} ${gEnd}");
          interpolatedPoints = interpolatePoints(gStart, gEnd, 0.4); // fine-grained steps
        }else{
          interpolatedPoints = [gStart, gEnd]; // single jump
        }
        for(int j = 0; j<interpolatedPoints.length; j++){
          if (_isCancelled || _stopAnimation){
            clearPreview();
            print("🔴 Animation stopped manually.");
            return;
          }
          final latLng = gmap.LatLng(value[0], value[1]);
          currentCoordinates.add(interpolatedPoints[j]);
          final polyline = gmap.Polyline(
            polylineId: gmap.PolylineId("preview_${floorId}_$i"),
            points: List.from(currentCoordinates),
            color: Colors.green,
            width: 8,
          );
          marker = customMarker.move(interpolatedPoints[j], marker);
          if(interpolatedPoints[j].latitude != value1[0] && interpolatedPoints[j].longitude != value1[1]){
            double angle = tools.calculateBearing([interpolatedPoints[j].latitude, interpolatedPoints[j].longitude], [value1[0], value1[1]]);
            marker = customMarker.rotate(angle-(_cameraPosition != null?_cameraPosition!.bearing:0.0), marker);
          }
          // if (turnPoints.contains(current.node)) {
          //   await alignMapToPath([value[0], value[1]], [value1[0], value1[1]], isTurn: true);
          // } else {
          //   if(interpolatedPoints[j].latitude != value1[0] && interpolatedPoints[j].longitude != value1[1]){
          //     await alignMapToPath([interpolatedPoints[j].latitude, interpolatedPoints[j].longitude], [value1[0], value1[1]]);
          //   }
          // }
          // ✅ Accumulate instead of overwrite
          _pathCovered.putIfAbsent(buildingId,() => {});
          _pathCovered[buildingId]!.putIfAbsent(floorId, () => <gmap.Polyline>{});
          _pathCovered[buildingId]![floorId]!.clear();
          _pathCovered[buildingId]![floorId]!.add(polyline);
          print("playPreview ${[row1, col1]} ${next.floor} added to floor $floorId");
          _previewMarker.putIfAbsent(lastBidIterated,() => {});
          _previewMarker[lastBidIterated]!.putIfAbsent(lastFloorItterated, () => <gmap.Marker>{});
          _previewMarker[lastBidIterated]![lastFloorItterated]?.clear();
          _previewMarker[lastBidIterated]![lastFloorItterated]!.add(marker);
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
      print("✅ Animation complete for ${pathList.first.bid} | Floor ${pathList.first.floor}");
      // _pathCovered.clear();
    } catch (e) {
      print("❌ Error in preview animation: $e");
      clearPreview();
    } finally {
      _previewMarker.clear();
      _isPlaying = false;
    }
    clearPreview();
    return;
  }


  List<gmap.LatLng> interpolatePoints(
      gmap.LatLng start, gmap.LatLng end, double intervalMeters) {
    const earthRadius = 6371000.0; // in meters
    final lat1 = start.latitude * pi / 180;
    final lng1 = start.longitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final lng2 = end.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLng = lng2 - lng1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final totalDistance = earthRadius * c;

    final steps = (totalDistance / intervalMeters).floor();

    List<gmap.LatLng> points = [];

    for (int i = 1; i <= steps; i++) {
      final fraction = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final lng = start.longitude + (end.longitude - start.longitude) * fraction;
      points.add(gmap.LatLng(lat, lng));
    }

    return points;
  }

  Future<Uint8List> getImagesFromMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

}