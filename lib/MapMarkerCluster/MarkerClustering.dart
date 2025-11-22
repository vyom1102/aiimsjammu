

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../APIMODELS/landmark.dart';
import '../ELEMENTS/HelperClass.dart';
import '../MODELS/MarkerIconWithAnchor.dart';
import '../NAVIGATIONTools.dart';
import '../config.dart';
import '../singletonClass.dart';
import 'MarkerLandmarkInformation.dart';
import 'PointForCenter.dart';
import 'PolygonCalculations.dart';

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
  late MarkerIconWithAnchor counter;
  late MarkerIconWithAnchor dotMarker;
  late MarkerIconWithAnchor yellowDotMarker;
  late MarkerIconWithAnchor greenDotMarker;
  late MarkerIconWithAnchor blueDotMarker;
  late MarkerIconWithAnchor insideEntryMarker;

  Map<String,MarkerIconWithAnchor> bitMapMarkers = {};
  PolygonCalculations polygonCalculations = PolygonCalculations();

  Future<void> initMarkers() async {

    liftMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/MapLift.png',imageSize: const Size(85, 85),color: Color(0xff544551), offset: Offset(0.5, 0.5));
    cafeteriaMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/cutlery.png',imageSize: const Size(85, 85),color: Color(0xff544551));
    femaleWashroomMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/MapFemaleWashroom.png',imageSize: const Size(85, 85),color: Color(0xff544551));
    maleWashroomMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/MapMaleWashroom.png',imageSize: const Size(85, 85),color: Color(0xff544551));
    entryMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/MapEntry.png',imageSize: const Size(75, 75),color: Color(0xff544551), offset: Offset(0.5, 0.5));
    landmarkMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/Generic Marker.png',imageSize: const Size(70, 70),color: Color(0xff544551));
    stairsMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/MapStairs.png',imageSize: const Size(60, 60),color: Color(0xff544551), offset: Offset(0.5, 0.5));
    stageMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/MapStage.png',imageSize: const Size(85, 85),color: Color(0xff544551));
    counter = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/Counter.png',imageSize: const Size(60, 60),color: Color(0xff544551), offset: Offset(0.5, 0.5));
    dotMarker = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/dot.png',imageSize: const Size(25, 25),color: Color(0xff544551));
    blueDotMarker = await bitmapDescriptorFromImageWithCenterAnchor('assets/greendot.png',imageSize: Size(95,95));
    insideEntryMarker = await bitmapDescriptorFromImageWithCenterAnchor('assets/insideEntry.png',imageSize: Size(45,45));
    greenDotMarker = await bitmapDescriptorFromImageWithCenterAnchor('assets/greendot.png',imageSize: Size(95,95));

  }

  void createBitmapMarker() {
    print("createBitmapMarker ${StackTrace.current}");
    try {
      SingletonFunctionController.building.landmarkdata!.then((value) async {
        List<Landmarks> landmarks = value.landmarks!;
        for (int i = 0; i < landmarks.length; i++) {
          if(landmarks[i].element?.type =="Global"){
            //FOR GLOBAL LANDMARKS (IIT DELHI - LHC,CAMPUS)
            if(landmarks[i].element?.subType == "Male Washroom"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.maleWashroomMarker;
            }else if(landmarks[i].element?.subType == "Female Washroom"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.femaleWashroomMarker;
            }else if(landmarks[i].element?.subType == "room" || landmarks[i].element?.subType?.toLowerCase() == "booth"){
              // print("landmarks[i].renderDetail ${landmarks[i].name} ${landmarks[i].renderDetail!.boothType} ${landmarks[i].element?.type} ${landmarks[i].element?.subType}");
              // print("landmarks[i].name ${landmarks[i].name}");
              if (landmarks[i].renderDetail != null) {
                final detail = landmarks[i].renderDetail!;

                if (detail.logo.isNotEmpty && detail.boothType == null) {
                  String name = detail.booth.isNotEmpty
                      ? detail.booth.split('-').first.trim()
                      : detail.name.split('-').first.trim();

                  print("detail.logo ${detail.logo}");
                  bitMapMarkers[landmarks[i].properties?.polyId ?? ""] =
                  await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternet(
                    name,
                    detail.logo,
                  );
                } else if (detail.logo.isNotEmpty) {
                  if (detail.boothType == "Platinum Booth") {

                    bitMapMarkers[landmarks[i].properties?.polyId ?? ""] =
                    await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternet(
                      "",
                      "${AppConfig.baseUrl}/uploads/${detail.logo}",
                      imageSize: const Size(150, 75),
                    );
                  }else if (detail.boothType == "General") {
                    bitMapMarkers[landmarks[i].properties?.polyId ?? ""] =
                    await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternet(
                      "",
                      "${AppConfig.baseUrl}/uploads/${detail.logo}",
                      imageSize: const Size(110, 110),
                    );
                  } else if (detail.boothType == "Gold Booth") {
                    bitMapMarkers[landmarks[i].properties?.polyId ?? ""] =
                    await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternet(
                      "",
                      "${AppConfig.baseUrl}/uploads/${detail.logo}",
                      imageSize: const Size(112, 75),
                    );
                  } else {
                    bitMapMarkers[landmarks[i].properties?.polyId ?? ""] =
                    await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternet(
                      "",
                      "${AppConfig.baseUrl}/uploads/${detail.logo}",
                    );
                  }
                } else {
                  // no logo
                  String name = detail.booth.isNotEmpty
                      ? detail.booth.split('-').first.trim()
                      : detail.name.split('-').first.trim();

                  bitMapMarkers[landmarks[i].properties?.polyId ?? ""] = await HelperClass().bitmapDescriptorFromCenteredTextFormatName(name);
                }
              }

            }else if(landmarks[i].element?.subType == "Lift"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.liftMarker;
            }else if(landmarks[i].element?.subType == "Stairs"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.stairsMarker;
            }else if(landmarks[i].element?.subType == "Stage"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchorInternet(
                landmarks[i].renderDetail.name,
                "assets/MapStage.png",
                  imageSize : const Size(105, 105)
              );
            }else if(landmarks[i].element?.subType == "stage"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.stageMarker;
            }else if(landmarks[i].element?.subType == "Registration"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.counter;
            }else if(landmarks[i].element!.subType?.toLowerCase() == "main entry"){
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.entryMarker;
            }
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Classroom" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            if (landmarks[i].priority! > 1) {
              bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                  landmarks[i].name!, 'assets/Classroom.png',
                  imageSize: const Size(85, 85), color: Color(0xfffb8c00));
            } else {
              bitMapMarkers[landmarks[i].properties!.polyId!] =
              await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                  landmarks[i].name!, 'assets/Classroom.png',
                  imageSize: const Size(85, 85), color: Color(0xfffb8c00));
            }
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Cafeteria" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            
            bitMapMarkers[landmarks[i].properties!.polyId!] =
            await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/cutlery.png',
                imageSize: const Size(65,65), color: Color(0xfffb8c00));
          }
          else if (landmarks[i].name != null &&
              landmarks[i].name!.toLowerCase().contains("pharmacy")) {
            // bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromTextAndImage(landmarks[i].name!, 'assets/P.png', imageSize: const Size(95, 95), color: Color(0xfffb8c00));
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Point of Interest" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {}
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Counter" &&
              landmarks[i].coordinateX != null) {
            bitMapMarkers[landmarks[i].properties!.polyId!] =
            await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/Counter.png',
                imageSize: const Size(85, 85), color: Color(0xfffb8c00));
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "ATM" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            bitMapMarkers[landmarks[i].properties!.polyId!] =
            await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/ATM.png',
                imageSize: const Size(65, 65), color: Color(0xfffb8c00));
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Consultation Room" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            bitMapMarkers[landmarks[i].properties!.polyId!] =
            await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/Consultation Room.png',
                imageSize: const Size(65, 65), color: Color(0xfffb8c00));
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Office" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/Office.png',
                imageSize: const Size(65, 65), color: Color(0xfffb8c00));
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Entrance Only" &&
              landmarks[i].coordinateX != null) {
            bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.blueDotMarker;
          }else if(landmarks[i].element!.type == "Rooms" && landmarks[i].element!.subType == "main entry"){
            // final result = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(landmarks[i].name!, 'assets/MapEntry.png', imageSize: const Size(100, 100),);
            // print("main entry ${landmarks[i].name}");
            // bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(landmarks[i].name!, 'assets/MapEntry.png', imageSize: const Size(75, 75),fontSizee: 32);;
            bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.entryMarker;
          }
          else if(landmarks[i].name != null && landmarks[i].name!.toLowerCase().contains("gate")){
            bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.blueDotMarker;
          }else if(landmarks[i].element!.type == "Rooms" && landmarks[i].element!.subType == "Door Only"){
            bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.insideEntryMarker;
          }
          else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType != "main entry" &&
              landmarks[i].element!.subType != "Entrance Only" &&
              landmarks[i].coordinateX != null) {

            // try {
              if(landmarks[i].wasPolyIdNull == false){
                String? code;
                if(landmarks[i].properties?.doorNumber == null){
                  if(landmarks[i].name!.contains(" - ") || landmarks[i].name!.contains("-")){
                    code = landmarks[i].name!.split("-")[0];
                  }else{
                    code = landmarks[i].name??"";
                  }
                }else{
                  code = landmarks[i].properties?.doorNumber;
                }
                // print("landmarks[i].properties.doorNumber $code -- ${landmarks[i].properties?.doorNumber} ${landmarks[i].name} ${landmarks[i].buildingName}");

                // bitMapMarkers[landmarks[i].properties!.polyId!] = MarkerIconWithAnchor(icon, Offset(0,0));
                bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromCenteredTextFormatEDName(code??"");
              }else{
                bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.blueDotMarker;
              }

            // }catch(e){
            //   print()
            // }
          }
          else if (landmarks[i].element != null &&
              landmarks[i].element!.subType != null &&
              landmarks[i].element!.subType == "room door" &&
              landmarks[i].doorX != null) {
            //for cubical marker changed form entryMarker to landmarkMarker
            bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/MapEntry.png',
                imageSize: const Size(65, 65), color: Colors.black);
          }
          else if (landmarks[i].name != null &&
              landmarks[i].element!.type == ("FloorConnection") &&
              landmarks[i].element!.subType == "lift") {
            try {
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.liftMarker;
            }catch(e){}
          }
          else if (landmarks[i].name != null &&
              landmarks[i].element!.type == "FloorConnection" &&
              landmarks[i].element!.subType == "stairs") {
            try {
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.stairsMarker;
            }catch(e){}
          }
          else if (landmarks[i].properties!.washroomType != null &&
              landmarks[i].properties!.washroomType == "Male") {
            try {
              bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.maleWashroomMarker;
            }catch(e){}
          }
          else if (landmarks[i].properties!.washroomType != null &&
              landmarks[i].properties!.washroomType == "Female") {
            bitMapMarkers[landmarks[i].properties!.polyId!] = SingletonFunctionController().mapCLustring.femaleWashroomMarker;
          }
          else if (landmarks[i].element!.subType != null &&
              landmarks[i].element!.subType == "main entry") {
            bitMapMarkers[landmarks[i].properties!.polyId!] = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/MapEntry.png',
                imageSize: const Size(65, 65), color: Colors.black);
          }
          else if (landmarks[i].element!.type == "Services" &&
              landmarks[i].element!.subType == "kiosk" &&
              landmarks[i].coordinateX != null) {
            bitMapMarkers[landmarks[i].properties!.polyId!] =
            await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
                landmarks[i].name!, 'assets/check-in.png',
                imageSize: const Size(65, 65), color: Color(0xfffb8c00));
          } else {
            // 
          }
        }
      });
    }catch(e){

    }
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
    if (zoom <= 19.5 && zoom > 18.8) return 4;
    if (zoom <= 18.8 && zoom > 17) return 8;
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
    if(coordinateX != null && coordinateY != null && buildingId != null) {
      List<double> value = tools.localtoglobal(
          coordinateX,
          coordinateY,
          SingletonFunctionController.building
              .patchData[buildingId]);
      return (floor,LatLng(lat,lng),polyID,buildingId,name,cluster);
    }
    return (floor,LatLng(lat,lng),polyID,buildingId,name,cluster);
  }


  double _toRadiansCluster(double degree) => degree * pi / 180;


  Marker _createMarker(Landmarks landmark, double zoomLevel, double theta){
    // if(landmark.element!.subType?.toLowerCase() == "booth"){
      print("_createMarker ${landmark.name} ${bitMapMarkers.containsKey(landmark.properties!.polyId)} ${landmark.element!.subType}");
    // }
    if(bitMapMarkers.containsKey(landmark.properties!.polyId) && landmark.element != null && landmark.element!.subType != null){

      MarkerIconWithAnchor dotIcon;
      if(landmark.renderDetail != null){
        // print("landmark.renderDetail!.color! ${landmark.renderDetail!.name!} ${landmark.renderDetail!.booth!} ${landmark.renderDetail!.color!}");
        if(landmark.renderDetail!.color == "#3AADE8"){
          dotIcon = SingletonFunctionController().mapCLustring.blueDotMarker;
        }else if(landmark.renderDetail!.color == "#34CD2"){
          // print("in#34CD2");
          dotIcon = SingletonFunctionController().mapCLustring.greenDotMarker;
        }else{
          dotIcon = SingletonFunctionController().mapCLustring.blueDotMarker;
        }
      }else{
        dotIcon = SingletonFunctionController().mapCLustring.blueDotMarker;
      }
      if(landmark.element!.subType == "room door" || landmark.element!.subType == "Reception"){
        if(zoomLevel < 20.8) {
          List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[landmark.properties!.polyId];
          // print("calculatedPoints check ${calculatedPoints} ${polygonCalculations.landmarkWithLatLng.containsKey(landmark.properties!.polyId)}");
          if(calculatedPoints != null) {
            LatLng positionPoint = polygonCalculations.midpoint(calculatedPoints[0], calculatedPoints[1]);
            return Marker(
                icon: dotIcon.icon,
                markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId-${landmark.sId}"),
                position: positionPoint,
                anchor: dotIcon.anchor,
                onTap: () {
                  onMarkerTapCallback(landmark.properties!.polyId!!);
                }
            );
          }else{
            return Marker(
              markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId-${landmark.sId}"),
              icon: dotIcon.icon,
              anchor: dotIcon.anchor,
              position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!!);
              }
            );
          }
        } else {
            List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[landmark.properties!.polyId];
            // print("print${landmark.name} ${landmark.properties!.polyId} ${calculatedPoints?.length}");
            if(calculatedPoints != null){
              int leftMost = LeftMost().leftMostPoint(PointForCenter(calculatedPoints![0].latitude, calculatedPoints[0].longitude, "name"), PointForCenter(calculatedPoints[1].latitude, calculatedPoints[1].longitude, "name"), zoomLevel);
              double rotation;
              if(leftMost == -1){
                rotation = polygonCalculations.calculateBearing(calculatedPoints[0],calculatedPoints[1]);
              }else{
                rotation = polygonCalculations.calculateBearing(calculatedPoints[1],calculatedPoints[0]);
              }
              LatLng positionPoint = polygonCalculations.midpoint(calculatedPoints[0], calculatedPoints[1]);

              return Marker(
                  icon: bitMapMarkers[landmark.properties!.polyId!]!.icon,
                  markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId-${landmark.sId}"),
                  position: positionPoint,
                  anchor: bitMapMarkers[landmark.properties!.polyId!]!.anchor,
                  flat: true,
                  rotation: rotation,
                  onTap: () {
                    onMarkerTapCallback(landmark.properties!.polyId!!);
                    //
                  }
              );
            }else if(polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId] != null){
              List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId];
              LatLng positionPoint = tools.calculateRoomCenter(calculatedPoints!);

              return Marker(
                  icon: bitMapMarkers[landmark.properties!.polyId!]!.icon,
                  markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId-${landmark.sId}"),
                  position: positionPoint,
                  anchor: bitMapMarkers[landmark.properties!.polyId!]!.anchor,
                  onTap: () {
                    onMarkerTapCallback(landmark.properties!.polyId!!);
                    //
                  }
              );
            }else{
              return Marker(
                  icon: bitMapMarkers[landmark.properties!.polyId!]!.icon,
                  markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId-${landmark.sId}"),
                  position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
                  anchor: bitMapMarkers[landmark.properties!.polyId!]!.anchor,
                  onTap: () {
                    onMarkerTapCallback(landmark.properties!.polyId!!);
                    //
                  }
              );
            }
        }
      }
      else if(landmark.element!.subType!.toLowerCase().contains("door only")){
        if(zoomLevel > 20.8){
          if(landmark.name!.toLowerCase().contains("main entry")){
            return Marker(
                icon: SingletonFunctionController().mapCLustring.entryMarker.icon,
                markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId- ${landmark.sId}"),
                position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
                anchor: SingletonFunctionController().mapCLustring.entryMarker.anchor,
                infoWindow: InfoWindow(title: landmark.name),
                onTap: () {
                  onMarkerTapCallback(landmark.properties!.polyId!!);
                }
            );
          }else {
            return Marker(
                icon: bitMapMarkers[landmark.properties!.polyId!]!.icon,
                markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId- ${landmark.sId}"),
                position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
                anchor: bitMapMarkers[landmark.properties!.polyId!]!.anchor,
                infoWindow: InfoWindow(title: landmark.name),
                onTap: () {
                  onMarkerTapCallback(landmark.properties!.polyId!!);
                }
            );
          }
        }else{
          return Marker(
              icon: dotIcon.icon,
              markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name} sId- ${landmark.sId}"),
              position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
              anchor: dotIcon.anchor,
              infoWindow: InfoWindow(title: landmark.name),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!!);
              }
          );
        }
      }
      // FOR GLOBAL ANNOTATION
      else if(landmark.element!.subType == "Female Washroom"){
        if(polygonCalculations.landmarkWithPolygonPoints.containsKey(landmark.properties!.polyId!)){
          print("For Female Washroom");
          LatLng positionPoint = landmark.renderDetail!.calculateRoomCenter(polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId!]!);
          return Marker(
              icon: SingletonFunctionController().mapCLustring
                  .femaleWashroomMarker.icon,
              markerId: MarkerId(
                  "polyId-${landmark.properties!.polyId} ${LatLng(
                      double.parse(landmark.properties!.latitude!),
                      double.parse(landmark.properties!
                          .longitude!))}landmarkType-${landmark.element!
                      .subType}buildingID-${landmark.buildingID}name-${landmark
                      .name} sId- ${landmark.sId}"),
              position: positionPoint,
              anchor: SingletonFunctionController().mapCLustring
                  .femaleWashroomMarker.anchor,
              infoWindow: InfoWindow(title: landmark.name),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!);
              }
          );
        }else {
          print("For else Female Washroom");
          return Marker(
              icon: SingletonFunctionController().mapCLustring
                  .femaleWashroomMarker.icon,
              markerId: MarkerId(
                  "polyId-${landmark.properties!.polyId} ${LatLng(
                      double.parse(landmark.properties!.latitude!),
                      double.parse(landmark.properties!
                          .longitude!))}landmarkType-${landmark.element!
                      .subType}buildingID-${landmark.buildingID}name-${landmark
                      .name} sId- ${landmark.sId}"),
              position: LatLng(double.parse(landmark.properties!.latitude!),
                  double.parse(landmark.properties!.longitude!)),
              anchor: SingletonFunctionController().mapCLustring
                  .femaleWashroomMarker.anchor,
              infoWindow: InfoWindow(title: landmark.name),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!);
              }
          );
        }
      }
      else if(landmark.element!.subType == "Male Washroom"){
        if(polygonCalculations.landmarkWithPolygonPoints.containsKey(landmark.properties!.polyId!)){
          LatLng positionPoint = landmark.renderDetail!.calculateRoomCenter(polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId!]!);
          return Marker(
              icon: SingletonFunctionController().mapCLustring
                  .maleWashroomMarker.icon,
              markerId: MarkerId(
                  "polyId-${landmark.properties!.polyId} ${LatLng(
                      double.parse(landmark.properties!.latitude!),
                      double.parse(landmark.properties!
                          .longitude!))}landmarkType-${landmark.element!
                      .subType}buildingID-${landmark.buildingID}name-${landmark
                      .name} sId- ${landmark.sId}"),
              position: positionPoint,
              anchor: SingletonFunctionController().mapCLustring
                  .maleWashroomMarker.anchor,
              infoWindow: InfoWindow(title: landmark.name),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!);
              }
          );
        }else {
          return Marker(
              icon: SingletonFunctionController().mapCLustring
                  .maleWashroomMarker.icon,
              markerId: MarkerId(
                  "polyId-${landmark.properties!.polyId} ${LatLng(
                      double.parse(landmark.properties!.latitude!),
                      double.parse(landmark.properties!
                          .longitude!))}landmarkType-${landmark.element!
                      .subType}buildingID-${landmark.buildingID}name-${landmark
                      .name} sId- ${landmark.sId}"),
              position: LatLng(double.parse(landmark.properties!.latitude!),
                  double.parse(landmark.properties!.longitude!)),
              anchor: SingletonFunctionController().mapCLustring
                  .maleWashroomMarker.anchor,
              infoWindow: InfoWindow(title: landmark.name),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!);
              }
          );
        }
      }

      else if(landmark.element!.subType == "room" || landmark.element!.subType?.toLowerCase() == "booth"){
        // print("inroom ${landmark.name} $zoomLevel");
        List<LatLng>? polygonPoints = polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId];
        double? area;
        if (polygonPoints != null && polygonPoints.isNotEmpty) {
          area = tools.calculatePolygonArea(polygonPoints);
        }
        print("area calc $area for ${landmark.name} zoomLevel $zoomLevel");

        if(polygonCalculations.landmarkWithLatLng.containsKey(landmark.properties!.polyId!)){
          LatLng positionPoint = LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!));
          if(area != null &&
              !(area > 60 && zoomLevel > 19.9) && // <-- skip marker if both true
              (!(area > 200 && zoomLevel < 19) &&
                  (area <= 200 && zoomLevel < 20.8))){
            // print("dot rendered for ${landmark.name} first else");
            return Marker(
                icon: dotIcon.icon,
                markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
                position: positionPoint,
                // flat: true,
                anchor: dotIcon.anchor,
                onTap: () {
                  onMarkerTapCallback(landmark.properties!.polyId!);
                }
            );
          }else{
            List<LatLng>? points = polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId];
            List<LatLng>? calculatedPoints = polygonCalculations.landmarkWithLatLng[landmark.properties!.polyId];
            int leftMost = LeftMost().leftMostPoint(PointForCenter(calculatedPoints![0].latitude, calculatedPoints[0].longitude, "name"), PointForCenter(calculatedPoints[1].latitude, calculatedPoints[1].longitude, "name"), theta);
            double rotation;
            if(leftMost == -1) {
              rotation = polygonCalculations.calculateBearing(calculatedPoints[0],calculatedPoints[1]);
            }else{
              rotation = polygonCalculations.calculateBearing(calculatedPoints[1],calculatedPoints[0]);
            }

            // LatLng positionPoint = tools.calculateRoomCenter(calculatedPoints);

            if(landmark.element?.subType?.toLowerCase() == "booth"){
              // print("landmark name center ${landmark.name} $rotation");
              // LatLng positionPoint = polygonCalculations.midpoint(calculatedPoints[0], calculatedPoints[1]);
              return Marker(
                  markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
                  icon: bitMapMarkers[landmark.properties!.polyId!]!.icon,
                  anchor: Offset(0.5, 0.38),
                  flat: true,
                  position: positionPoint,
                  rotation: rotation,
                  onTap: () {
                    onMarkerTapCallback(landmark.properties!.polyId!);
                  }
              );
            }else{
              return Marker(
                  markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
                  icon: bitMapMarkers[landmark.properties!.polyId!]!.icon,
                  anchor: dotIcon.anchor,
                  // flat: true,
                  position: positionPoint,
                  // rotation: rotation,
                  onTap: () {
                    onMarkerTapCallback(landmark.properties!.polyId!);
                  }
              );
            }

          }
        }else{
          // print("dot rendered for ${landmark.name} last else");
          return Marker(
              markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
              icon: dotIcon.icon,
              anchor: dotIcon.anchor,
              position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!);
              }
          );
        }

      }
      else if(landmark.element!.subType == "Lift"){
        if(polygonCalculations.landmarkWithPolygonPoints.containsKey(landmark.properties!.polyId!)){
          LatLng positionPoint = landmark.renderDetail!.calculateRoomCenter(polygonCalculations.landmarkWithPolygonPoints[landmark.properties!.polyId!]!);
          return Marker(
              icon: SingletonFunctionController().mapCLustring.liftMarker.icon,
              markerId: MarkerId(
                  "polyId-${landmark.properties!.polyId} ${LatLng(
                      double.parse(landmark.properties!.latitude!),
                      double.parse(landmark.properties!
                          .longitude!))}landmarkType-${landmark.element!
                      .subType}buildingID-${landmark.buildingID}name-${landmark
                      .name}sId-${landmark.sId}"),
              position: positionPoint,
              anchor: SingletonFunctionController().mapCLustring.liftMarker
                  .anchor,
              infoWindow: InfoWindow(title: landmark.name),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!);
              }
          );
        }else {
          return Marker(
              icon: SingletonFunctionController().mapCLustring.liftMarker.icon,
              markerId: MarkerId(
                  "polyId-${landmark.properties!.polyId} ${LatLng(
                      double.parse(landmark.properties!.latitude!),
                      double.parse(landmark.properties!
                          .longitude!))}landmarkType-${landmark.element!
                      .subType}buildingID-${landmark.buildingID}name-${landmark
                      .name}sId-${landmark.sId}"),
              position: LatLng(double.parse(landmark.properties!.latitude!),
                  double.parse(landmark.properties!.longitude!)),
              anchor: SingletonFunctionController().mapCLustring.liftMarker
                  .anchor,
              infoWindow: InfoWindow(title: landmark.name),
              onTap: () {
                onMarkerTapCallback(landmark.properties!.polyId!);
              }
          );
        }
      }
      else if(landmark.element!.subType == "Stairs"){
        return Marker(
            icon: SingletonFunctionController().mapCLustring.stairsMarker.icon,
            markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
            position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
            anchor: SingletonFunctionController().mapCLustring.stairsMarker.anchor,
            infoWindow: InfoWindow(title: landmark.name),
            onTap: () {
              onMarkerTapCallback(landmark.properties!.polyId!);
            }
        );
      }
      else{
        return Marker(
            icon: bitMapMarkers[landmark.properties!.polyId!]!.icon,
            markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
            position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
            anchor: bitMapMarkers[landmark.properties!.polyId!]!.anchor,
            infoWindow: InfoWindow(title: landmark.name),
            onTap: () {
              onMarkerTapCallback(landmark.properties!.polyId!);
            }
        );
      }
    }
    else {
      // ELSE FOR NON-GLOBAL MAIN ENTRY, CAFETERIA, LIFT, RESTROOM
      MarkerIconWithAnchor assignMarker;
      if(landmark.element!.subType =="main entry"){
        assignMarker = SingletonFunctionController().mapCLustring.entryMarker;
      }else if(landmark.element!.subType =="Cafeteria"){
        assignMarker = SingletonFunctionController().mapCLustring.cafeteriaMarker;
      }else if(landmark.element!.subType =="lift"){
        assignMarker = SingletonFunctionController().mapCLustring.liftMarker;
      }else if(landmark.element!.subType == "restRoom"){
        if(landmark.name!.toLowerCase().contains('female')) {
          assignMarker = SingletonFunctionController().mapCLustring.femaleWashroomMarker;
        }else if(landmark.name!.toLowerCase().contains('male')){
          assignMarker = SingletonFunctionController().mapCLustring.maleWashroomMarker;
        }else{
          assignMarker = SingletonFunctionController().mapCLustring.femaleWashroomMarker;
        }
      }else if(landmark.element!.subType =="room door"){
        assignMarker = SingletonFunctionController().mapCLustring.blueDotMarker;
      }else if(landmark.element!.subType =="stairs"){
        assignMarker = SingletonFunctionController().mapCLustring.stairsMarker;
      }else{
        assignMarker = SingletonFunctionController().mapCLustring.blueDotMarker;
      }
      try {
        return Marker(
            icon: assignMarker.icon,
            markerId: MarkerId("polyId-${landmark.properties!.polyId} ${LatLng(
                double.parse(landmark.properties!.latitude!), double.parse(
                landmark.properties!.longitude!))}landmarkType-${landmark
                .element!.subType}buildingID-${landmark
                .buildingID}name-${landmark.name}sId-${landmark.sId}"),
            position: LatLng(double.parse(landmark.properties!.latitude!),
                double.parse(landmark.properties!.longitude!)),
            anchor: assignMarker.anchor,
            infoWindow: InfoWindow(title: landmark.name),
            onTap: () {
              onMarkerTapCallback(landmark.properties!.polyId!);
            }
        );
      }catch(e){
        // print("landmark error ${landmark.sId} ${landmark.coordinateX} ${landmark.coordinateY} ${landmark.name} ${landmark.properties!.latitude} ${landmark.properties!.longitude}");
        return Marker(
            icon: assignMarker.icon,
            markerId: MarkerId("polyId-${landmark.properties!.polyId})}landmarkType-${landmark.element!.subType}buildingID-${landmark.buildingID}name-${landmark.name}sId-${landmark.sId}"),
            anchor: assignMarker.anchor,
            infoWindow: InfoWindow(title: landmark.name),
            onTap: () {
              onMarkerTapCallback(landmark.properties!.polyId!);
            }
        );
      }
    }
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
        icon: SingletonFunctionController().mapCLustring.blueDotMarker.icon,
        anchor: SingletonFunctionController().mapCLustring.blueDotMarker.anchor,
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
        icon: SingletonFunctionController().mapCLustring.blueDotMarker.icon,
        anchor: SingletonFunctionController().mapCLustring.blueDotMarker.anchor,
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
        icon: SingletonFunctionController().mapCLustring.blueDotMarker.icon,
        anchor: SingletonFunctionController().mapCLustring.blueDotMarker.anchor,
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
