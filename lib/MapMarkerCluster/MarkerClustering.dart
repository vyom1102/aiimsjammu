

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../APIMODELS/landmark.dart';
import '../ELEMENTS/HelperClass.dart';
import '../NAVIGATIONTools.dart';
import '../config.dart';
import '../singletonClass.dart';
import 'MarkerLandmarkInformation.dart';
import 'PointForCenter.dart';
import 'PolygonCalculations.dart';
import 'UnifiedMarkerCreator.dart';

class MapClustering {
  final void Function(String sId) onMarkerTapCallback;

  MapClustering({required this.onMarkerTapCallback});

  late MarkerIconWithAnchor liftMarker;
  late MarkerIconWithAnchor maleWashroomMarker;
  late MarkerIconWithAnchor femaleWashroomMarker;
  late MarkerIconWithAnchor landmarkMarker;
  late MarkerIconWithAnchor cafeteriaMarker;
  late MarkerIconWithAnchor entryMarker;
  late MarkerIconWithAnchor stairsMarker;
  late MarkerIconWithAnchor stageMarker;
  late MarkerIconWithAnchor sittingAreaMarker;
  late MarkerIconWithAnchor counter;
  late MarkerIconWithAnchor yellowgreenDotMarker;
  late MarkerIconWithAnchor greengreenDotMarker;
  late MarkerIconWithAnchor insideEntryMarker;

  Map<String,MarkerIconWithAnchor> bitMapMarkers = {};
  PolygonCalculations polygonCalculations = PolygonCalculations();

  Future<void> initMarkers() async {
    final creator = UnifiedMarkerCreator();

    liftMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/MapLift.png',
      layout: MarkerLayout.imageOnly,
      customAnchor: const Offset(0.5, 0.5),
    );

    cafeteriaMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/cutlery.png',
      layout: MarkerLayout.imageOnly,
    );

    femaleWashroomMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/MapFemaleWashroom.png',
      layout: MarkerLayout.imageOnly,
      customAnchor: const Offset(0.5, 1.0)
    );

    maleWashroomMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/MapMaleWashroom.png',
      layout: MarkerLayout.imageOnly,
      customAnchor: const Offset(0.5, 1.0)
    );

    entryMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/MapEntry.png',
      layout: MarkerLayout.imageOnly,
      imageSize: const Size(30, 30),
      customAnchor: const Offset(0.5, 0.5),
    );

    landmarkMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/Generic Marker.png',
      layout: MarkerLayout.imageOnly,
    );

    stairsMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/MapStairs.png',
      layout: MarkerLayout.imageOnly,
      imageSize: const Size(25, 25),
      customAnchor: const Offset(0.5, 0.5),
    );

    stageMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/MapStage.png',
      layout: MarkerLayout.imageOnly,
    );

    sittingAreaMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/Depth 3, Frame 1-3.png',
      layout: MarkerLayout.imageOnly,
    );

    counter = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/Counter.png',
      layout: MarkerLayout.imageOnly,
      customAnchor: const Offset(0.5, 0.5),
    );

    insideEntryMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/insideEntry.png',
      layout: MarkerLayout.imageOnly,
      customAnchor: const Offset(0.5, 0.5),
    );

    greengreenDotMarker = await creator.createUnifiedMarker(
      text: "",
      imageSource: 'assets/greendot.png',
      layout: MarkerLayout.imageOnly,
      customAnchor: const Offset(0.5, 0.5),
    );
  }

  Future<void> createBitmapMarker() async {
    print("createBitmapMarker ${StackTrace.current}");

    final creator = UnifiedMarkerCreator();

    try {
      final landmarkData = await SingletonFunctionController.building.landmarkdata!;
      final landmarks = landmarkData.landmarks ?? [];

      for (final landmark in landmarks) {
        final polyId = landmark.properties?.polyId;
        if (polyId == null) continue;

        final elementType = landmark.element?.type;
        final elementSubType = landmark.element?.subType;
        final hasCoordinate = landmark.coordinateX != null;
        final hasValidPoly = !(landmark.wasPolyIdNull ?? true);

        // Global Landmarks
        if (elementType == "Global") {
          bitMapMarkers[polyId] = await _handleGlobalLandmark(
            landmark,
            creator,
            
          );
          continue;
        }

        // Rooms
        if (elementType == "Rooms" && hasCoordinate) {
          bitMapMarkers[polyId] = await _handleRoomLandmark(
            landmark,
            creator,
            
            hasValidPoly,
          );
          continue;
        }

        // Floor Connections
        if (elementType == "FloorConnection") {
          bitMapMarkers[polyId] = _handleFloorConnection(
            elementSubType,
            
          );
          continue;
        }

        // Washrooms
        if (landmark.properties?.washroomType != null) {
          bitMapMarkers[polyId] = _handleWashroom(
            landmark.properties!.washroomType!,
            
          );
          continue;
        }

        // Services
        if (elementType == "Services" && elementSubType == "kiosk" && hasCoordinate) {
          bitMapMarkers[polyId] = await creator.createUnifiedMarker(
            text: landmark.name ?? "",
            imageSource: 'assets/check-in.png',
            layout: MarkerLayout.horizontal,
            textFormat: TextFormat.smartWrap,
            textColor: const Color(0xfffb8c00),
          );
          continue;
        }

        // Room doors
        if (elementSubType == "room door" && landmark.doorX != null) {
          bitMapMarkers[polyId] = await creator.createUnifiedMarker(
            text: landmark.name ?? "",
            imageSource: 'assets/MapEntry.png',
            layout: MarkerLayout.horizontal,
            textFormat: TextFormat.smartWrap,
            imageSize: const Size(65, 65),
            textColor: Colors.black,
          );
          continue;
        }
      }
    } catch (e) {
      print("Error in createBitmapMarker: $e");
    }
  }

  Future<MarkerIconWithAnchor> _handleGlobalLandmark(
      Landmarks landmark,
      UnifiedMarkerCreator creator,
      ) async {
    final subType = landmark.element?.subType;

    switch (subType) {
      case "Male Washroom":
        return maleWashroomMarker;

      case "Female Washroom":
        return femaleWashroomMarker;

      case "Lift":
        return liftMarker;

      case "Stairs":
        return stairsMarker;

      case "Stage":
        return await creator.createUnifiedMarker(
          text: landmark.renderDetail?.name ?? "",
          imageSource: "assets/MapStage.png",
          layout: MarkerLayout.horizontal,
          textFormat: TextFormat.smartWrap,
          imageSize: const Size(105, 105),
        );

      case "stage":
        return stageMarker;

      case "Registration":
        return counter;

      default:
        if (subType?.toLowerCase() == "main entry") {
          return entryMarker;
        }

        // Handle rooms/booths
        if (subType == "room" || subType?.toLowerCase() == "booth") {
          return await _handleBoothLandmark(landmark, creator);
        }

        return landmarkMarker;
    }
  }

  Future<MarkerIconWithAnchor> _handleBoothLandmark(
      Landmarks landmark,
      UnifiedMarkerCreator creator,
      ) async {
    final detail = landmark.renderDetail;
    if (detail == null) {
      return SingletonFunctionController().mapCLustring.landmarkMarker;
    }

    // Extract name
    final name = detail.booth.isNotEmpty
        ? detail.booth.split('-').first.trim()
        : detail.name.split('-').first.trim();

    // No logo
    if (detail.logo.isEmpty) {
      return await creator.createUnifiedMarker(
        text: name,
        layout: MarkerLayout.textOnly,
        textFormat: TextFormat.lhFormat,
      );
    }

    // Logo with no booth type
    if (detail.boothType == null) {
      return await creator.createUnifiedMarker(
        text: name,
        imageSource: detail.logo,
        layout: MarkerLayout.horizontal,
        textFormat: TextFormat.smartWrap,
      );
    }

    // Logo with booth type
    final logoUrl = "${AppConfig.baseUrl}/uploads/${detail.logo}";

    switch (detail.boothType) {
      case "Platinum Booth":
        return await creator.createUnifiedMarker(
          text: "",
          imageSource: logoUrl,
          layout: MarkerLayout.imageOnly,
          imageSize: const Size(150, 75),
        );

      case "General":
        return await creator.createUnifiedMarker(
          text: "",
          imageSource: logoUrl,
          layout: MarkerLayout.imageOnly,
          imageSize: const Size(110, 110),
        );

      case "Gold Booth":
        return await creator.createUnifiedMarker(
          text: "",
          imageSource: logoUrl,
          layout: MarkerLayout.imageOnly,
          imageSize: const Size(112, 75),
        );

      default:
        return await creator.createUnifiedMarker(
          text: "",
          imageSource: logoUrl,
          layout: MarkerLayout.horizontal,
          textFormat: TextFormat.smartWrap,
        );
    }
  }

  Future<MarkerIconWithAnchor> _handleRoomLandmark(
      Landmarks landmark,
      UnifiedMarkerCreator creator,
      
      bool hasValidPoly,
      ) async {
    final subType = landmark.element?.subType;
    final name = landmark.name ?? "";

    // Classroom
    if (subType == "Classroom" && hasValidPoly) {
      return await creator.createUnifiedMarker(
        text: name,
        imageSource: 'assets/Classroom.png',
        layout: MarkerLayout.horizontal,
        textFormat: TextFormat.smartWrap,
        textColor: const Color(0xfffb8c00),
      );
    }

    // Cafeteria
    if (subType == "Cafeteria" && hasValidPoly) {
      return await creator.createUnifiedMarker(
        text: name,
        imageSource: 'assets/cutlery.png',
        layout: MarkerLayout.horizontal,
        textFormat: TextFormat.smartWrap,
        textColor: const Color(0xfffb8c00),
      );
    }

    // Counter
    if (subType == "Counter") {
      return await creator.createUnifiedMarker(
        text: name,
        imageSource: 'assets/Counter.png',
        layout: MarkerLayout.horizontal,
        textFormat: TextFormat.smartWrap,
        textColor: const Color(0xfffb8c00),
      );
    }

    // Counter types with no text
    if (subType == "Sample Collection Room" ||
        subType == "Reception" ||
        subType == "Cash Counter") {
      return await creator.createUnifiedMarker(
        text: "",
        imageSource: 'assets/Counter.png',
        layout: MarkerLayout.imageOnly,
        customAnchor: const Offset(0.5, 0.5),
      );
    }

    // Sitting Area
    if (subType == "Sitting Area") {
      return sittingAreaMarker;
    }

    // ATM
    if (subType == "ATM" && hasValidPoly) {
      return await creator.createUnifiedMarker(
        text: name,
        imageSource: 'assets/ATM.png',
        layout: MarkerLayout.horizontal,
        textFormat: TextFormat.smartWrap,
        textColor: const Color(0xfffb8c00),
      );
    }

    // Consultation Room
    if (subType == "Consultation Room" && hasValidPoly) {
      return await creator.createUnifiedMarker(
        text: name,
        imageSource: 'assets/Consultation Room.png',
        layout: MarkerLayout.horizontal,
        textFormat: TextFormat.smartWrap,
        textColor: const Color(0xfffb8c00),
      );
    }

    // Office
    if (subType == "Office" && hasValidPoly) {
      return await creator.createUnifiedMarker(
        text: name,
        imageSource: 'assets/Office.png',
        layout: MarkerLayout.horizontal,
        textFormat: TextFormat.smartWrap,
        textColor: const Color(0xfffb8c00),
      );
    }

    // Entrance Only
    if (subType == "Entrance Only") {
      return greengreenDotMarker;
    }

    // Main entry
    if (subType == "main entry") {
      return entryMarker;
    }

    // Gate
    if (name.toLowerCase().contains("gate")) {
      return greengreenDotMarker;
    }

    // Door Only
    if (subType == "Door Only") {
      return insideEntryMarker;
    }

    // Point of Interest (no marker)
    if (subType == "Point of Interest") {
      return greengreenDotMarker;
    }

    // Default room with door number/code
    if (hasValidPoly) {
      String code;
      if (landmark.properties?.doorNumber != null) {
        code = landmark.properties!.doorNumber!;
      } else if (name.contains(" - ") || name.contains("-")) {
        code = name.split("-")[0].trim();
      } else {
        code = name;
      }

      return await creator.createUnifiedMarker(
        text: code,
        layout: MarkerLayout.textOnly,
        textFormat: TextFormat.smartWrap,
      );
    }

    // Fallback for invalid poly
    return greengreenDotMarker;
  }

  MarkerIconWithAnchor _handleFloorConnection(
      String? subType,
      
      ) {
    if (subType == "lift") {
      return liftMarker;
    } else if (subType == "stairs") {
      return stairsMarker;
    }
    return greengreenDotMarker;
  }

  MarkerIconWithAnchor _handleWashroom(
      String washroomType,
      
      ) {
    if (washroomType == "Male") {
      return maleWashroomMarker;
    } else if (washroomType == "Female") {
      return femaleWashroomMarker;
    }
    return greengreenDotMarker;
  }


  Set<Marker> Markers = {};
  List<Landmarks> _landmarks = [];


  List<Landmarks> get landmarks => _landmarks;

  set landmarks(List<Landmarks> value) {
    _landmarks = value;
    print("Noew clustring on length${_landmarks.length}");
  }

  Set<Marker> recalculateClusters(double zoomLevel,double theta) {
    initMarkers();
    final newMarkers = _generateClusters(_landmarks, zoomLevel, theta);
    Markers = newMarkers;
    return Markers;
  }

  Landmarks getPriorityLandmark(List<Landmarks> landmarks) {
    // Define your priority order
    final priority = [
      "main entry",
      "lift",
      "Lift",
      "ramp",
      "Ramp",
      "stairs",
      "Stairs",
      "restRoom",
      "room door",
    ];

    for (final p in priority) {
      final landmark = landmarks.firstWhere(
            (l) => l.element?.subType == p,
        orElse: () => Landmarks(),
      );
      if (landmark.element != null) {
        return landmark;
      }
    }
    return landmarks.first; // nothing matched
  }

  Set<Marker> _generateClusters(List<Landmarks> landmarks, double zoomLevel, double theta) {
    double threshold = getClusteringDistance(zoomLevel);
    double thresholdDifferentTypes = getClusteringDistanceDifferentTypes(zoomLevel);
    Set<Marker> markers = {};
    Set<int> clustered = {};
    List<Landmarks> clusterdLandmarks = [];

    for (int i = 0; i < landmarks.length; i++) {
      if (clustered.contains(i)) continue;

      final cluster = <Landmarks>[landmarks[i]];
      clustered.add(i);
      try {
        for (int j = i + 1; j < landmarks.length; j++) {
          // if(landmarks[i].sId == "68d114b6c669c14ab0352d7f" && landmarks[j].sId == "68d114b6c669c14ab0352d7d"){
          //   final distance = calculateDistanceCluster(
          //     LatLng(double.parse(landmarks[i].properties!.latitude!), double.parse(landmarks[i].properties!.longitude!)),
          //     LatLng(double.parse(landmarks[j].properties!.latitude!), double.parse(landmarks[j].properties!.longitude!)),
          //   );
          //   print("distance between lift and stairs is $distance $thresholdDifferentTypes $zoomLevel  $threshold");
          // }
          // if(landmarks[i].sId == "68d114b6c669c14ab0352d7d" && landmarks[j].sId == "68d114b6c669c14ab0352d7f"){
          //   final distance = calculateDistanceCluster(
          //     LatLng(double.parse(landmarks[i].properties!.latitude!), double.parse(landmarks[i].properties!.longitude!)),
          //     LatLng(double.parse(landmarks[j].properties!.latitude!), double.parse(landmarks[j].properties!.longitude!)),
          //   );
          //   print("distance between lift and stairs is $distance $thresholdDifferentTypes $zoomLevel  $threshold");
          // }
          // if(landmarks[j].element?.subType != landmarks[i].element?.subType) continue;
          // if (clustered.contains(j)) continue;

          final distance = calculateDistanceCluster(
            LatLng(double.parse(landmarks[i].properties!.latitude!),
                double.parse(landmarks[i].properties!.longitude!)),
            LatLng(double.parse(landmarks[j].properties!.latitude!),
                double.parse(landmarks[j].properties!.longitude!)),
          );

          if (landmarks[j].element?.subType == landmarks[i].element?.subType &&
              distance.floor() < threshold) {
            cluster.add(landmarks[j]);
            clustered.add(j);
          } else
          if (landmarks[j].element?.subType != landmarks[i].element?.subType &&
              distance.floor() < thresholdDifferentTypes) {
            cluster.add(landmarks[j]);
            clustered.add(j);
          }
        }
      }catch(e){

      }

      // if (cluster.length == 1) {
      //   markers.add(_createMarker(cluster.first,zoomLevel));
      // } else {
      var landmarkSelected = getPriorityLandmark(cluster);
      clustered.remove(landmarks.indexOf(landmarkSelected));
      markers.add(_createMarker(getPriorityLandmark(cluster),zoomLevel, theta));
      // final (floor,center,polyID,buildingID,name,allLandmarks) = _calculateClusterCenter(cluster);
      // markers.add(_createClusterMarker(center, cluster.length,zoomLevel,floor,polyID,buildingID,name,allLandmarks));
      // }
    }
    return markers;
  }

  double getClusteringDistance(double zoom) {
    if (zoom >= 21) return 0;        // Show all markers, no clustering
    if (zoom >= 20) return 1;        // Light clustering
    if (zoom >= 19) return 5;
    if (zoom >= 18) return 10;
    if (zoom >= 17) return 20;
    return 4000 / pow(2, zoom - 10); // Aggressive clustering below 18
  }

  double getClusteringDistanceDifferentTypes(double zoom) {
    if (zoom <= 19.5 && zoom > 18.8) return 12;
    if (zoom <= 18.8 && zoom > 17) return 14;
    if (zoom < 17) return 20;
    return double.negativeInfinity; // Aggressive clustering below 18
  }

  void calculateClusterDistance(List<LatLng> coords, double zoom){

    for(int i=0 ; i<coords.length-1 ; i++){
      double currentDistance = calculateDistanceCluster(coords[i], coords[i+1]);

    }
  }

  double calculateDistanceCluster(LatLng a, LatLng b) {
    const earthRadius = 6371000;
    final dLat = _toRadiansCluster(b.latitude - a.latitude);
    final dLng = _toRadiansCluster(b.longitude - a.longitude);
    final rLat1 = _toRadiansCluster(a.latitude);
    final rLat2 = _toRadiansCluster(b.latitude);

    final aCalc = sin(dLat / 2) * sin(dLat / 2) +
        cos(rLat1) * cos(rLat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(aCalc), sqrt(1 - aCalc));

    return earthRadius * c;
  }


  (int?,LatLng,String?,String?,String?,List<Landmarks>?) _calculateClusterCenter(List<Landmarks> cluster) {
    double lat = 0;
    double lng = 0;
    int? floor;
    String? polyID;
    int? coordinateX;
    int? coordinateY;
    String? buildingId;
    String? name;
    for (var landmark in cluster) {
      if(polygonCalculations.landmarkWithPolygonPoints.containsKey(landmark.properties!.polyId!)){
        LatLng positionPoint = landmark.renderDetail!.calculateRoomCenter(polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId!]!);
        lat = positionPoint.latitude;
        lng = positionPoint.longitude;
      }else{
        lat = LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)).latitude;
        lng = LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)).longitude;
      }

      coordinateX = landmark.coordinateX;
      coordinateY = landmark.coordinateY;
      floor = landmark.floor;
      polyID = landmark.properties!.polyId;
      buildingId = landmark.buildingID;
      name = landmark.name;
    }
    return (floor,LatLng(lat,lng),polyID,buildingId,name,cluster);
  }


  double _toRadiansCluster(double degree) => degree * pi / 180;


  Marker _createMarker(Landmarks landmark, double zoomLevel, double theta) {
    if (bitMapMarkers.containsKey(landmark.properties!.polyId) &&
        landmark.element != null &&
        landmark.element!.subType != null) {
      return _createBitmapMarker(landmark, zoomLevel, theta);
    } else {
      return _createDefaultMarker(landmark);
    }
  }

// Main bitmap marker creation with subtype routing
  Marker _createBitmapMarker(Landmarks landmark, double zoomLevel, double theta) {
    final subType = landmark.element!.subType!;

    if (subType == "room door" || subType == "Reception" ||
        subType == "Blood Bank" || subType == "Library") {
      return _createRoomDoorMarker(landmark, zoomLevel);
    } else if (subType.toLowerCase().contains("door only")) {
      return _createDoorOnlyMarker(landmark, zoomLevel);
    } else if (subType == "Female Washroom") {
      return _createWashroomMarker(landmark, isFemale: true);
    } else if (subType == "Male Washroom") {
      return _createWashroomMarker(landmark, isFemale: false);
    } else if (subType == "room" || subType.toLowerCase() == "booth") {
      return _createRoomOrBoothMarker(landmark, zoomLevel, theta);
    } else if (subType == "Lift") {
      return _createLiftMarker(landmark);
    } else if (subType == "Stairs") {
      return _createStairsMarker(landmark);
    } else {
      return _createGenericBitmapMarker(landmark);
    }
  }

// Room door marker (Reception, Blood Bank, Library, etc.)
  Marker _createRoomDoorMarker(Landmarks landmark, double zoomLevel) {
    final dotIcon = _getDotIcon(landmark);
    final markerId = _buildMarkerId(landmark);
    final polyId = landmark.properties!.polyId!;

    if (zoomLevel < 20.8) {
      return _createDotMarkerAtCalculatedOrDefaultPosition(
          landmark, dotIcon, markerId, polyId
      );
    } else {
      return _createRotatedMarkerAtCalculatedPosition(
          landmark, markerId, polyId, zoomLevel
      );
    }
  }

// Helper: Create dot marker at calculated or default position
  Marker _createDotMarkerAtCalculatedOrDefaultPosition(
      Landmarks landmark,
      MarkerIconWithAnchor dotIcon,
      MarkerId markerId,
      String polyId
      ) {
    List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[polyId];
    List<LatLng>? polygonPoints = polygonCalculations.landmarkWithPolygonPoints[polyId];
    LatLng position;

    if(polygonPoints != null){
      position = tools.calculateRoomCenter(polygonPoints!);
    } else if (calculatedPoints != null) {
      position = polygonCalculations.midpoint(calculatedPoints[0], calculatedPoints[1]);
    } else {
      position = _getDefaultPosition(landmark);
    }

    return Marker(
      icon: dotIcon.icon,
      markerId: markerId,
      position: position,
      anchor: dotIcon.anchor,
      onTap: () => onMarkerTapCallback(polyId),
    );
  }

// Helper: Create rotated marker with bearing calculation
  Marker _createRotatedMarkerAtCalculatedPosition(
      Landmarks landmark,
      MarkerId markerId,
      String polyId,
      double zoomLevel
      ) {
    List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[polyId];

    if (calculatedPoints != null) {
      double rotation = _calculateRotation(calculatedPoints, polyId, zoomLevel);
      LatLng positionPoint = _getPositionForRotatedMarker(calculatedPoints, polyId);

      return Marker(
        icon: bitMapMarkers[polyId]!.icon,
        markerId: markerId,
        position: positionPoint,
        anchor: bitMapMarkers[polyId]!.anchor,
        flat: true,
        rotation: rotation,
        onTap: () => onMarkerTapCallback(polyId),
      );
    } else if (polygonCalculations.landmarkWithPolygonPoints[polyId] != null) {
      List<LatLng>? polygonPoints = polygonCalculations.landmarkWithPolygonPoints[polyId];
      LatLng positionPoint = tools.calculateRoomCenter(polygonPoints!);

      return Marker(
        icon: bitMapMarkers[polyId]!.icon,
        markerId: markerId,
        position: positionPoint,
        anchor: bitMapMarkers[polyId]!.anchor,
        onTap: () => onMarkerTapCallback(polyId),
      );
    } else {
      return Marker(
        icon: bitMapMarkers[polyId]!.icon,
        markerId: markerId,
        position: _getDefaultPosition(landmark),
        anchor: bitMapMarkers[polyId]!.anchor,
        onTap: () => onMarkerTapCallback(polyId),
      );
    }
  }

// Door only marker
  Marker _createDoorOnlyMarker(Landmarks landmark, double zoomLevel) {
    final polyId = landmark.properties!.polyId!;
    final markerId = _buildMarkerId(landmark);
    final position = _getDefaultPosition(landmark);
    final infoWindow = InfoWindow(title: landmark.name);

    if (zoomLevel > 20.8) {
      if (landmark.name!.toLowerCase().contains("main entry")) {
        return Marker(
          icon: SingletonFunctionController().mapCLustring.entryMarker.icon,
          markerId: markerId,
          position: position,
          anchor: SingletonFunctionController().mapCLustring.entryMarker.anchor,
          infoWindow: infoWindow,
          onTap: () => onMarkerTapCallback(polyId),
        );
      } else {
        return Marker(
          icon: bitMapMarkers[polyId]!.icon,
          markerId: markerId,
          position: position,
          anchor: bitMapMarkers[polyId]!.anchor,
          infoWindow: infoWindow,
          onTap: () => onMarkerTapCallback(polyId),
        );
      }
    } else {
      final dotIcon = _getDotIcon(landmark);
      return Marker(
        icon: dotIcon.icon,
        markerId: markerId,
        position: position,
        anchor: dotIcon.anchor,
        infoWindow: infoWindow,
        onTap: () => onMarkerTapCallback(polyId),
      );
    }
  }

// Washroom marker (Male/Female)
  Marker _createWashroomMarker(Landmarks landmark, {required bool isFemale}) {
    final polyId = landmark.properties!.polyId!;
    final markerId = _buildMarkerId(landmark);
    final washroomMarker = isFemale
        ? SingletonFunctionController().mapCLustring.femaleWashroomMarker
        : SingletonFunctionController().mapCLustring.maleWashroomMarker;

    LatLng position;
    if (polygonCalculations.landmarkWithPolygonPoints.containsKey(polyId)) {
      if (isFemale) print("For Female Washroom");
      position = landmark.renderDetail!.calculateRoomCenter(
          polygonCalculations.landmarkWithPolygonPoints[polyId]!
      );
    } else {
      if (isFemale) print("For else Female Washroom");
      position = _getDefaultPosition(landmark);
    }

    return Marker(
      icon: washroomMarker.icon,
      markerId: markerId,
      position: position,
      anchor: washroomMarker.anchor,
      infoWindow: InfoWindow(title: landmark.name),
      onTap: () => onMarkerTapCallback(polyId),
    );
  }

// Room or booth marker
  Marker _createRoomOrBoothMarker(Landmarks landmark, double zoomLevel, double theta) {
    final polyId = landmark.properties!.polyId!;
    final dotIcon = _getDotIcon(landmark);

    List<LatLng>? polygonPoints = polygonCalculations.landmarkWithPolygonPoints[polyId];
    double? area;
    if (polygonPoints != null && polygonPoints.isNotEmpty) {
      area = tools.calculatePolygonArea(polygonPoints);
    }
    print("area calc $area for ${landmark.name} zoomLevel $zoomLevel");

    if (polygonCalculations.landmarkWithLatLng.containsKey(polyId)) {
      LatLng positionPoint = _getDefaultPosition(landmark);

      // Check if we should render a dot marker
      if (area != null &&
          !(area > 60 && zoomLevel > 19.9) &&
          (!(area > 200 && zoomLevel < 19) && (area <= 200 && zoomLevel < 20.8))) {
        return Marker(
          icon: dotIcon.icon,
          markerId: _buildMarkerId(landmark),
          position: positionPoint,
          anchor: dotIcon.anchor,
          onTap: () => onMarkerTapCallback(polyId),
        );
      } else {
        // Render bitmap marker with rotation
        List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[polyId];
        double rotation = _calculateRotationForRoom(calculatedPoints!, theta);

        if (landmark.element?.subType?.toLowerCase() == "booth") {
          return Marker(
            markerId: _buildMarkerId(landmark),
            icon: bitMapMarkers[polyId]!.icon,
            anchor: Offset(0.5, 0.38),
            flat: true,
            position: positionPoint,
            rotation: rotation,
            onTap: () => onMarkerTapCallback(polyId),
          );
        } else {
          return Marker(
            markerId: _buildMarkerId(landmark),
            icon: bitMapMarkers[polyId]!.icon,
            anchor: dotIcon.anchor,
            position: positionPoint,
            onTap: () => onMarkerTapCallback(polyId),
          );
        }
      }
    } else {
      return Marker(
        markerId: _buildMarkerId(landmark),
        icon: dotIcon.icon,
        anchor: dotIcon.anchor,
        position: _getDefaultPosition(landmark),
        onTap: () => onMarkerTapCallback(polyId),
      );
    }
  }

// Lift marker
  Marker _createLiftMarker(Landmarks landmark) {
    final polyId = landmark.properties!.polyId!;
    final liftMarker = SingletonFunctionController().mapCLustring.liftMarker;

    LatLng position;
    if (polygonCalculations.landmarkWithPolygonPoints.containsKey(polyId)) {
      position = landmark.renderDetail!.calculateRoomCenter(
          polygonCalculations.landmarkWithPolygonPoints[polyId]!
      );
    } else {
      position = _getDefaultPosition(landmark);
    }

    return Marker(
      icon: liftMarker.icon,
      markerId: _buildMarkerId(landmark),
      position: position,
      anchor: liftMarker.anchor,
      infoWindow: InfoWindow(title: landmark.name),
      onTap: () => onMarkerTapCallback(polyId),
    );
  }

// Stairs marker
  Marker _createStairsMarker(Landmarks landmark) {
    final stairsMarker = SingletonFunctionController().mapCLustring.stairsMarker;

    return Marker(
      icon: stairsMarker.icon,
      markerId: _buildMarkerId(landmark),
      position: _getDefaultPosition(landmark),
      anchor: stairsMarker.anchor,
      infoWindow: InfoWindow(title: landmark.name),
      onTap: () => onMarkerTapCallback(landmark.properties!.polyId!),
    );
  }

// Generic bitmap marker (fallback)
  Marker _createGenericBitmapMarker(Landmarks landmark) {
    final polyId = landmark.properties!.polyId!;

    return Marker(
      icon: bitMapMarkers[polyId]!.icon,
      markerId: _buildMarkerId(landmark),
      position: _getDefaultPosition(landmark),
      anchor: bitMapMarkers[polyId]!.anchor,
      infoWindow: InfoWindow(title: landmark.name),
      onTap: () => onMarkerTapCallback(polyId),
    );
  }

// Default marker (for non-bitmap cases)
  Marker _createDefaultMarker(Landmarks landmark) {
    final MarkerIconWithAnchor assignMarker = _getDefaultMarkerIcon(landmark);
    final markerId = _buildMarkerId(landmark);

    try {
      return Marker(
        icon: assignMarker.icon,
        markerId: markerId,
        position: _getDefaultPosition(landmark),
        anchor: assignMarker.anchor,
        infoWindow: InfoWindow(title: landmark.name),
        onTap: () => onMarkerTapCallback(landmark.properties!.polyId!),
      );
    } catch (e) {
      return Marker(
        icon: assignMarker.icon,
        markerId: MarkerId("polyId-${landmark.properties!.polyId})}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
        anchor: assignMarker.anchor,
        infoWindow: InfoWindow(title: landmark.name),
        onTap: () => onMarkerTapCallback(landmark.properties!.polyId!),
      );
    }
  }

// === HELPER METHODS ===

  MarkerIconWithAnchor _getDotIcon(Landmarks landmark) {
    if (landmark.renderDetail != null) {
      if (landmark.renderDetail!.color == "#3AADE8" ||
          landmark.renderDetail!.color == "#34CD2") {
        return SingletonFunctionController().mapCLustring.greengreenDotMarker;
      } else {
        return SingletonFunctionController().mapCLustring.greengreenDotMarker;
      }
    }
    return SingletonFunctionController().mapCLustring.greengreenDotMarker;
  }

  MarkerIconWithAnchor _getDefaultMarkerIcon(Landmarks landmark) {
    final subType = landmark.element!.subType;

    if (subType == "main entry") {
      return SingletonFunctionController().mapCLustring.entryMarker;
    } else if (subType == "Cafeteria") {
      return SingletonFunctionController().mapCLustring.cafeteriaMarker;
    } else if (subType == "lift") {
      return SingletonFunctionController().mapCLustring.liftMarker;
    } else if (subType == "restRoom") {
      if (landmark.name!.toLowerCase().contains('female')) {
        return SingletonFunctionController().mapCLustring.femaleWashroomMarker;
      } else if (landmark.name!.toLowerCase().contains('male')) {
        return SingletonFunctionController().mapCLustring.maleWashroomMarker;
      } else {
        return SingletonFunctionController().mapCLustring.femaleWashroomMarker;
      }
    } else if (subType == "room door") {
      return SingletonFunctionController().mapCLustring.greengreenDotMarker;
    } else if (subType == "stairs") {
      return SingletonFunctionController().mapCLustring.stairsMarker;
    } else {
      return SingletonFunctionController().mapCLustring.greengreenDotMarker;
    }
  }

  MarkerId _buildMarkerId(Landmarks landmark) {
    try{
      return MarkerId(
          "polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"
      );
    }catch(e){
      return MarkerId(
          "polyId-${landmark.properties!.polyId} landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"
      );
    }
  }

  LatLng _getDefaultPosition(Landmarks landmark) {
    return LatLng(
        double.parse(landmark.properties!.latitude!),
        double.parse(landmark.properties!.longitude!)
    );
  }

  double _calculateRotation(List<LatLng> calculatedPoints, String polyId, double zoomLevel) {
    int leftMost = LeftMost().leftMostPoint(
        PointForCenter(calculatedPoints[0].latitude, calculatedPoints[0].longitude, "name"),
        PointForCenter(calculatedPoints[1].latitude, calculatedPoints[1].longitude, "name"),
        zoomLevel
    );

    double rotation;
    if (leftMost == -1) {
      rotation = polygonCalculations.calculateBearing(calculatedPoints[0], calculatedPoints[1]);
    } else {
      rotation = polygonCalculations.calculateBearing(calculatedPoints[1], calculatedPoints[0]);
    }

    if (polygonCalculations.landmarkWithPolygonPoints[polyId] != null) {
      final result = findBestFitRectangleBearing(
          polygonCalculations.landmarkWithPolygonPoints[polyId]!
      );
      rotation = result.bearing;
    }

    return rotation;
  }

  double _calculateRotationForRoom(List<LatLng> calculatedPoints, double theta) {
    int leftMost = LeftMost().leftMostPoint(
        PointForCenter(calculatedPoints[0].latitude, calculatedPoints[0].longitude, "name"),
        PointForCenter(calculatedPoints[1].latitude, calculatedPoints[1].longitude, "name"),
        theta
    );

    if (leftMost == -1) {
      return polygonCalculations.calculateBearing(calculatedPoints[0], calculatedPoints[1]);
    } else {
      return polygonCalculations.calculateBearing(calculatedPoints[1], calculatedPoints[0]);
    }
  }

  LatLng _getPositionForRotatedMarker(List<LatLng> calculatedPoints, String polyId) {
    LatLng positionPoint = polygonCalculations.midpoint(calculatedPoints[0], calculatedPoints[1]);

    if (polygonCalculations.landmarkWithPolygonPoints[polyId] != null) {
      positionPoint = tools.calculateRoomCenter(
          polygonCalculations.landmarkWithPolygonPoints[polyId]!
      );
    }

    return positionPoint;
  }

  Marker _createClusterMarker(LatLng center, int count,double zoom,int? floor,String? polyId,String? buildingId,String? name,List<Landmarks>? allLandmarks) {
    String? majorityType;
    Marker? majorityWinMarker;
    Map<String, int> typeCounts = {};
    if (allLandmarks != null && allLandmarks.isNotEmpty) {
      // Initialize counts
      typeCounts = {
        "else": 0,
        "main entry":0,
        "Door Only": 0,
        "room": 0,
        "stairs": 0,
        "Stairs": 0,
        "restRoomMALE": 0,
        "Male Washroom": 0,
        "Female Washroom": 0,
        "restRoomFEMALE": 0,
        "lift": 0,
        "Lift": 0,
      };


      // Count occurrences of each landmark type
      for (var landmark in allLandmarks) {
        if(landmark.element!.subType != null) {
          if (landmark.element!.subType == "Door Only" &&
              landmark.name!.toLowerCase().contains("main entry")) {
            typeCounts["main entry"] =
                (typeCounts[landmark.element!.subType] ?? 0) + 1;
          } else if (typeCounts.containsKey(landmark.element!.subType)) {
            typeCounts[landmark.element!.subType!] =
                (typeCounts[landmark.element!.subType] ?? 0) + 1;
          } else if (landmark.element!.subType!.contains("restRoom")) {
            if (landmark.name!.toLowerCase().contains("female")) {
              typeCounts["restRoomFEMALE"] =
                  (typeCounts[landmark.element!.subType] ?? 0) + 1;
            } else if (landmark.name!.toLowerCase().contains("male")) {
              typeCounts["restRoomMALE"] =
                  (typeCounts[landmark.element!.subType] ?? 0) + 1;
            }
          }
        }
      }

      // Find the majority type
      majorityType = typeCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    // Example: You can now use majorityType for marker customization
    if (majorityType == "lift") {
      majorityWinMarker = Marker(
          markerId: MarkerId('cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}'),
          position: center,
          icon: SingletonFunctionController().mapCLustring.liftMarker.icon,
          anchor: SingletonFunctionController().mapCLustring.liftMarker.anchor,
          infoWindow: InfoWindow(title: '$count locations'),
          onTap: (){
            onMarkerTapCallback(polyId!);
          }
      );
    }
    else if (majorityType == "restRoomMALE") {
      majorityWinMarker = Marker(
          markerId: MarkerId('cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}'),
          position: center,
          icon: SingletonFunctionController().mapCLustring.maleWashroomMarker.icon,
          anchor: SingletonFunctionController().mapCLustring.maleWashroomMarker.anchor,
          infoWindow: InfoWindow(title: '$count locations'),
          onTap: (){
            onMarkerTapCallback(polyId!);
          }
      );
    }
    else if (majorityType == "restRoomFEMALE") {
      majorityWinMarker = Marker(
          markerId: MarkerId('cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}'),
          position: center,
          icon: SingletonFunctionController().mapCLustring.femaleWashroomMarker.icon,
          anchor: SingletonFunctionController().mapCLustring.femaleWashroomMarker.anchor,
          infoWindow: InfoWindow(title: '$count locations'),
          onTap: (){
            onMarkerTapCallback(polyId!);
          }
      );
    }
    else if (majorityType == "main entry") {
        majorityWinMarker = Marker(
            markerId: MarkerId('cluster_${center.latitude}_${center.longitude}landmarkType-main entry buildingID-${buildingId} floor ${floor}'),
            position: center,
            icon: SingletonFunctionController().mapCLustring.entryMarker.icon,
            anchor: SingletonFunctionController().mapCLustring.entryMarker.anchor,
            infoWindow: InfoWindow(title: '$count locations'),
            onTap: () {
              onMarkerTapCallback(polyId!);
            }
        );
    }
    else if (majorityType == "roomdoor") {
      List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[polyId];

      LatLng positionPoint;
      if (calculatedPoints != null) {
        positionPoint = polygonCalculations.midpoint(
          calculatedPoints[0],
          calculatedPoints[1],
        );
      } else {
        positionPoint = center;
      }

      majorityWinMarker = Marker(
        markerId: MarkerId(
          'cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}',
        ),
        position: positionPoint,
        icon: SingletonFunctionController().mapCLustring.greengreenDotMarker.icon,
        anchor: SingletonFunctionController().mapCLustring.greengreenDotMarker.anchor,
        infoWindow: InfoWindow(title: '$count locations'),
        onTap: () {
          onMarkerTapCallback(polyId!);
        },
      );
    }
    else if (majorityType == "Door Only") {
      List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[polyId];

      LatLng positionPoint;
      if (calculatedPoints != null) {
        positionPoint = polygonCalculations.midpoint(
          calculatedPoints[0],
          calculatedPoints[1],
        );
      } else {
        positionPoint = center;
      }

      majorityWinMarker = Marker(
        markerId: MarkerId(
          'cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}',
        ),
        position: positionPoint,
        icon: SingletonFunctionController().mapCLustring.greengreenDotMarker.icon,
        anchor: SingletonFunctionController().mapCLustring.greengreenDotMarker.anchor,
        infoWindow: InfoWindow(title: '$count locations'),
        onTap: () {
          onMarkerTapCallback(polyId!);
        },
      );

    }

    //FOR GLOBAL
    else if (majorityType == "Male Washroom") {
      majorityWinMarker = Marker(
          markerId: MarkerId('cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}'),
          position: center,
          icon: SingletonFunctionController().mapCLustring.maleWashroomMarker.icon,
          anchor: SingletonFunctionController().mapCLustring.maleWashroomMarker.anchor,
          infoWindow: InfoWindow(title: '$count locations'),
          onTap: (){
            onMarkerTapCallback(polyId!);
          }
      );
    }
    else if (majorityType == "Lift") {
      majorityWinMarker = Marker(
          markerId: MarkerId('cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}'),
          position: center,
          icon: SingletonFunctionController().mapCLustring.liftMarker.icon,
          anchor: SingletonFunctionController().mapCLustring.liftMarker.anchor,
          infoWindow: InfoWindow(title: '$count locations'),
          onTap: (){
            onMarkerTapCallback(polyId!);
          }
      );
    }

    else{
      List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[polyId];
      LatLng positionPoint;
      if (calculatedPoints != null) {
        positionPoint = polygonCalculations.midpoint(
          calculatedPoints[0],
          calculatedPoints[1],
        );
      } else {
        positionPoint = center;
      }

      majorityWinMarker = Marker(
        markerId: MarkerId(
          'cluster_${center.latitude}_${center.longitude}buildingID-${buildingId} floor ${floor}',
        ),
        position: positionPoint,
        icon: SingletonFunctionController().mapCLustring.greengreenDotMarker.icon,
        anchor: SingletonFunctionController().mapCLustring.greengreenDotMarker.anchor,
        infoWindow: InfoWindow(title: '$count locations'),
        onTap: () {
          onMarkerTapCallback(polyId!);
        },
      );
    }
    
    return majorityWinMarker;
  }

  Future<MarkerIconWithAnchor> bitmapDescriptorFromImageWithCenterAnchor(
      String imagePath, {
        Size imageSize = const Size(50, 50),
      }) async {
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // Adjust image size based on device pixel ratio
    Size adjustedImageSize = Size(
      imageSize.width * (devicePixelRatio / 2.5),
      imageSize.height * (devicePixelRatio / 2.5),
    );

    if (kIsWeb) {
      adjustedImageSize = const Size(45, 45); // fallback for web
    }

    // Load image from assets
    final ByteData baseImageBytes = await rootBundle.load(imagePath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      baseImageBytes.buffer.asUint8List(),
      targetWidth: adjustedImageSize.width.toInt(),
      targetHeight: adjustedImageSize.height.toInt(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    // Create canvas same as image size
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw image at (0,0)
    canvas.drawImage(image, Offset.zero, Paint());

    // Final image
    final ui.Image finalImage = await recorder.endRecording().toImage(
      adjustedImageSize.width.toInt(),
      adjustedImageSize.height.toInt(),
    );

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return MarkerIconWithAnchor(
      BitmapDescriptor.fromBytes(pngBytes),
      const Offset(0.5, 0.5), // center anchor
    );
  }

}

