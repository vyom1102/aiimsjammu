import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../API/buildingAllApi.dart';
import '../APIMODELS/SensorFingerprintReal.dart';
import '../Elements/HelperClass.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/polylinedata.dart' as poly;
import '../BluetoothManager/BLEManager.dart';
import '../BluetoothScanAndroidClass.dart';
import '../GPS.dart';
import '../APIMODELS/FingerPrintData.dart' as fp;

import '../NAVIGATIONTools.dart';
import '../navigation_api_controller.dart';
import '../singletonClass.dart';

class Fingerprinting{
  late BuildContext _context;
  Set<Marker> _dotMarkers = {};
  Set<Marker> _Markers = {};
  fp.FingerPrintData? fingerPrintData;
  late Function _updateMarkers;
  Map<String, beacon>? apibeaconmap;
  poly.Nodes? userPosition;
  int? floor;
  Data? data;
  double _x = 0.0, _y = 0.0, _z = 0.0;
  double theta = 0.0;
  final DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'");
  Timer? timer;
  BluetoothScanAndroidClass bluetoothScanAndroidClass = BluetoothScanAndroidClass();
  Fingerprinting() {}
  List<String> predictionHistory = [];
  String lastLocation="";
  set updateMarkers(Function value) {
    _updateMarkers = value;
  }
  set context(BuildContext value) {
    _context = value;
  }
  Map<String, dynamic> getPreAveragedData(){
    print("fingerPrintData!.fingerPrintData:${fingerPrintData!.data}");
    return computeBeaconStats(fingerPrintData!.data!);
  }

  Future<void> enableFingerprinting(Map<String, beacon> beaconController) async {
    print("inside enabling");
    apibeaconmap = beaconController;
    // fingerPrintData = await fingerPrintingGetApi().Finger_Printing_GET_API(buildingAllApi.selectedBuildingID,apibeaconmap![bleManager.finalName]!.floor.toString()??'0');
    print("fingerprint data:${fingerPrintData!.data}");
  }

  Set<Marker> getMarkers(){
    return _dotMarkers.union(_Markers);
  }

  Map<String, dynamic> computeBeaconStats(List<fp.Data> newDataModel) {
    final result = <String, dynamic>{};

    for (var locationEntry in newDataModel) {
      final locationKey = locationEntry.location;
      final innerDataList = locationEntry.data as List<dynamic>;

      final beaconMap = <String, List<int>>{};
      final weakOutlierMap = <String, List<Map<String, dynamic>>>{};
      final deviationOutlierMap = <String, List<Map<String, dynamic>>>{};

      // Step 1: Collect all valid RSSI readings
      for (var dataItem in innerDataList) {
        final beacons = dataItem.beacons ?? [];

        for (var beacon in beacons) {
          final macId = beacon.beaconMacId;
          final rssiList = beacon.beaconRssi ?? [];

          if (macId == null || rssiList.isEmpty) continue;

          for (var rssi in rssiList) {
            if (rssi >= -90) {
              beaconMap.putIfAbsent(macId, () => []).add(rssi);
            } else {
              weakOutlierMap.putIfAbsent(macId, () => []).add({
                'value': rssi,
                'outlierType': 'weak_signal',
              });
            }
          }
        }
      }

      // Step 2: Compute stats + deviation outliers
      final beaconStats = beaconMap.map((macId, rssiList) {
        final mean = rssiList.reduce((a, b) => a + b) / rssiList.length;
        final variance = rssiList.fold(0.0, (sum, val) => sum + pow(val - mean, 2)) / rssiList.length;
        final stdDev = sqrt(variance);

        final cleanedRssiList = <int>[];
        for (var rssi in rssiList) {
          if (stdDev == 0 || (rssi >= mean - 2 * stdDev && rssi <= mean + 2 * stdDev)) {
            cleanedRssiList.add(rssi);
          } else {
            deviationOutlierMap.putIfAbsent(macId, () => []).add({
              'value': rssi,
              'outlierType': 'deviation_outlier',
            });
          }
        }

        final finalMean = cleanedRssiList.isNotEmpty
            ? cleanedRssiList.reduce((a, b) => a + b) / cleanedRssiList.length
            : 0.0;

        final finalVariance = cleanedRssiList.isNotEmpty
            ? cleanedRssiList.fold(0.0, (sum, val) => sum + pow(val - finalMean, 2)) / cleanedRssiList.length
            : 0.0;

        final finalStdDev = sqrt(finalVariance);

        final allOutliers = [
          ...?weakOutlierMap[macId],
          ...?deviationOutlierMap[macId],
        ];

        return MapEntry(macId, {
          'mean': finalMean,
          'stdDev': finalStdDev,
          'outliers': allOutliers,
        });
      });

      result[locationKey!] = {
        'beacons': beaconStats,
      };
    }

    print("Processed and averaged beacon data: $result");
    return result;
  }


  void disableFingerprinting(){
    _dotMarkers.clear();
    _Markers.clear();
    userPosition = null;

    floor = null; // Reinitialize GPS object if required
    data = null;
    _x = 0.0;
    _y = 0.0;
    _z = 0.0;
    theta = 0.0;
    // Cancel any active subscriptions and reset
    // Cancel the timer if active
    timer?.cancel();
    timer = null;
  }
  void clearMarkers(){
    _Markers.clear();
    _dotMarkers.clear();
  }
  Map<String, dynamic> computeRealtimeBeaconStats(List<SensorFingerprintReal> realtimeSensorData) {
    final result = <String, dynamic>{};
    final beaconMap = <String, List<int>>{};
    final weakOutlierMap = <String, List<Map<String, dynamic>>>{};
    final deviationOutlierMap = <String, List<Map<String, dynamic>>>{};

    // Step 1: Collect RSSI values and weak signal outliers
    for (var data in realtimeSensorData) {
      for (var beacon in data.beacons ?? []) {
        final macId = beacon.beaconMacId;
        final rssi = beacon.beaconRssi;

        if (macId == null || rssi == null) continue;

        // print("macid: $macId, rssi: $rssi");

        // ✅ Only add if this macId hasn't been added yet
        beaconMap.putIfAbsent(macId, () => rssi);
      }
    }

    // Step 2: Compute stats and flag deviation outliers
    final Map<String, Map<String, dynamic>> beaconStats = {};

    beaconMap.forEach((macId, rssiList) {
      print("rssilist: $rssiList, $macId");

      final mean = rssiList.reduce((a, b) => a + b) / rssiList.length;
      final variance = rssiList.fold(0.0, (sum, val) => sum + pow(val - mean, 2)) / rssiList.length;
      final stdDev = sqrt(variance);

      final cleanedRssiList = <int>[];
      for (var rssi in rssiList) {
        if (stdDev == 0 || (rssi >= mean - 2 * stdDev && rssi <= mean + 2 * stdDev)) {
          cleanedRssiList.add(rssi);
        } else {
          deviationOutlierMap.putIfAbsent(macId, () => []).add({
            'value': rssi,
            'outlierType': 'deviation_outlier',
          });
        }
      }
      final finalMean = cleanedRssiList.isNotEmpty
          ? cleanedRssiList.reduce((a, b) => a + b) / cleanedRssiList.length
          : 0.0;
      final finalVariance = cleanedRssiList.isNotEmpty
          ? cleanedRssiList.fold(0.0, (sum, val) => sum + pow(val - finalMean, 2)) / cleanedRssiList.length
          : 0.0;
      final finalStdDev = sqrt(finalVariance);
      // ✅ Skip weak beacons
      if (finalMean < -95) {
        print("Skipping weak beacon $macId with mean RSSI: $finalMean");
        return;
      }

      final allOutliers = [
        ...?weakOutlierMap[macId],
        ...?deviationOutlierMap[macId],
      ];

      beaconStats[macId] = {
        'mean': finalMean,
        'stdDev': finalStdDev,
        'outliers': allOutliers,
      };
    });

    result['realtime'] = {
      'beacons': beaconStats,
    };

    print("realtime data: $result");
    return result;
  }


  String? previousSmoothedLocation; // Declare this outside the function, as a class-level variable
  Future<String> findBestMatchingLocationHybrid({
    Map<String, dynamic>? realTimeData,
    Map<String, dynamic>? preProcessData,
    int historyLimit = 7,
    double cosineWeight = 0.6,
    double distanceWeight = 0.6,
    double confidenceThreshold = 0.4,
  }) async {
    // Step 0: Get 5 nearest points to strongest beacon
    clearMarkers();
    final realtimeBeacons = realTimeData!['realtime']?['beacons'] as Map<String, dynamic>;
    final nearestBeacon = bleManager.finalName;
    final nearestPoints = await _getNearestBalancedPoints(limit: 7, preProcessData: preProcessData!, weightAvg:BLEManager().weightAvg);
    print("nearest pointss:${nearestPoints}");
    // Step 1: Filter preProcessData to only nearest points
    final filteredData = Map<String, dynamic>.fromEntries(
        preProcessData!.entries.where((entry) => nearestPoints.contains(entry.key))
    );
    // Step 2: Calculate max overlap (only on filtered points)
    int maxOverlap = 0;
    int minOverlap = double.maxFinite.toInt();
    final locationOverlapMap = <String, int>{};
    filteredData.forEach((locationKey, data){
      final overlapCount = (data['beacons'] as Map<String, dynamic>)
          .keys.where((macId) => realtimeBeacons.containsKey(macId))
          .length;
      locationOverlapMap[locationKey] = overlapCount;
      if (overlapCount > maxOverlap)
        {
          maxOverlap = overlapCount;
        }
      if (overlapCount < minOverlap) {
        minOverlap = overlapCount;
      }
      print("maxoverlapcount:${maxOverlap} ${minOverlap}for ${locationKey} ${overlapCount} ${locationOverlapMap.entries.first.value}");
      print("prebeacons:${filteredData[locationKey]}");
    });
    // Step 3: Score only locations with max overlap
    final scoredLocations = locationOverlapMap.entries
        .where((e) => e.value >= minOverlap && e.value <= maxOverlap)
        .map((e) {
      final locationKey = e.key;
      final preBeacons = filteredData[locationKey]['beacons'] as Map<String, dynamic>;
      double distance = 0;
      final realtimeVector = <double>[];
      final preprocessedVector = <double>[];
      realtimeBeacons.forEach((macId, beaconData) {
        if (preBeacons.containsKey(macId)) {
          final realMean = beaconData['mean'] as double;
          final preMean = preBeacons[macId]['mean'] as double;
          realtimeVector.add(realMean);
          preprocessedVector.add(preMean);
          distance += pow(preMean - realMean, 2);
        }
      });
      distance = sqrt(distance);
      final cosineSimilarity = computeCosineSimilarity(realtimeVector, preprocessedVector);
      final score = (cosineWeight * cosineSimilarity) + (distanceWeight * (1 / (1 + distance)));
      return MapEntry(locationKey, score);
    }).toList();
    // Step 4: Get top 3 and apply proximity boost
    print("scoredLocations:${scoredLocations}");
    scoredLocations.sort((a, b) => b.value.compareTo(a.value));
    final top3 = scoredLocations.take(3).toList();
    // final rescoredTop3 = top3.map((entry){
    //   print('Before Rank: ${entry.key}, Score: ${entry.value.toStringAsFixed(4)}');
    //   final proximityBoost = 1 / (1 + getDistanceToNearestBeacon(entry.key));
    //   return MapEntry(entry.key, entry.value + (proximityBoost * 0.5)); // Adjust 0.5 as needed
    // }).toList()..sort((a, b) => b.value.compareTo(a.value));

    // Step 5: Visualize and return result
    final waypoints = await NavigationAPIController.extractWaypoints();
    try {
      await Future.wait(
          top3.take(3).map((entry) async {
            print(
                'Final Rank: ${entry.key}, Score: ${entry.value.toStringAsFixed(
                    4)}');
            // await Future.wait(
            //     waypoints.where((p) => p.coordx ==int.parse(entry.key.split(',')[0]) && p.coordy ==int.parse(entry.key.split(',')[1]) ).map((p) => addDotMarker(p, entry))
            // );
          })
      );
      return top3.first.key ?? 'unknown';
    }catch(e){
      return 'unknown';
    }
  }
// Helper functions
  String _findStrongestBeacon(Map<String, dynamic> beacons) {
    return beacons.entries.reduce((a, b) =>
    a.value['mean'] > b.value['mean'] ? a : b
    ).key;
  }

  Future<List<String>> _getNearestBalancedPoints({
    required Map<String, dynamic> preProcessData,
    required Map<String, double> weightAvg, // Sorted map of beaconMac -> weight
    int topBeaconsCount = 2,
    int limit = 5,
    double stdDevThreshold = 1.5,
    double meanDistanceThreshold=26
  })async{
    final sortedWeightAvgEntries = weightAvg.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
// Now take the top beacon MAC addresses
    final topBeaconMacs = sortedWeightAvgEntries
        .take(topBeaconsCount)
        .map((entry) => entry.key)
        .toList();
    print("weightAvg.keys:${topBeaconMacs}");
    final List<List<int>> topBeaconCoords = [];
    for (final mac in topBeaconMacs){
      final x = apibeaconmap?[mac]?.coordinateX;
      final y = apibeaconmap?[mac]?.coordinateY;
      if (x != null && y != null) {
        topBeaconCoords.add([x.toInt(), y.toInt()]);
      }
    }
    print("topbeacons it got:${topBeaconMacs} ${topBeaconCoords}");
    final List<MapEntry<String, double>> filteredPoints = [];
    if (topBeaconCoords.length >= 1) {
      final beaconA = topBeaconCoords[0];
      final beaconB = topBeaconCoords.length >= 2 ? topBeaconCoords[1] : null;
      double beaconDistance = beaconB != null
          ? tools.calculateDistance(beaconA, beaconB)
          : double.infinity;
      print("📏 Distance between top 2 beacons: $beaconDistance");
      for (final key in preProcessData.keys) {
        try {
          final parts = key.split(',');
          final pointX = int.parse(parts[0]);
          final pointY = int.parse(parts[1]);
          final pointCoord = [pointX, pointY];
          bool shouldCheck = false;
          if (beaconDistance <= 25 && beaconB != null) {
            // Case: Between two beacons — check if the point lies close to the line segment
            shouldCheck = tools.isPointNearLine(pointCoord, beaconA, beaconB, tolerance: 25.0);
            print("should_check :${shouldCheck} ${pointCoord}");
          } else {
            // Case: Near single beacon — check if point is within radius 25
            final distanceToA = tools.calculateDistance(pointCoord,beaconA);
            print("distance from beacon :${distanceToA}");
            shouldCheck = distanceToA <= 25.0;
          }
          if (!shouldCheck) continue;
          // Compute distances from point to top beacons
          final List<double> distances = topBeaconCoords
              .map((beaconCoord) => tools.calculateDistance(beaconCoord, pointCoord))
              .toList();
          // Compute mean and std deviation
          final mean = distances.reduce((a, b) => a + b) / distances.length;
          final variance = distances.fold(0.0, (sum, d) => sum + pow(d - mean, 2)) / distances.length;
          final stdDev = sqrt(variance);
          print("🧪 $key => StdDev: ${stdDev.toStringAsFixed(2)}, Mean: ${mean.toStringAsFixed(2)}");
          if (mean <= meanDistanceThreshold) {
            filteredPoints.add(MapEntry(key, mean));
            print("✅ Accepted: $key");
          } else {
            print("❌ Rejected: $key");
          }
        } catch (e) {
          print("⚠️ Skipped malformed key: $key");
        }
      }
    }
// Sort the valid points based on mean distance and select top 5
    filteredPoints.sort((a, b) => a.value.compareTo(b.value));
    final goodPoints = filteredPoints.take(5).toList();

    print("🎯 Final selected points:");
    for (var entry in goodPoints) {
      print("👉 ${entry.key} (Mean: ${entry.value.toStringAsFixed(2)})");
    }
    // Sort by average distance to top beacons (optional)
    goodPoints.sort((a, b) => a.value.compareTo(b.value));
    return goodPoints
        .take(limit)
        .map((entry) => "${entry.key.split(',')[0]},${entry.key.split(',')[1]},3")
        .toList();
  }



  double getDistanceToNearestBeacon(String locationKey) {
    List<String> point = locationKey.split(',');
      final nearestBeacon=apibeaconmap?[bleManager.finalName];
    double minDistance = double.infinity;
      final double bx = double.parse(point[0]);
      final double by = double.parse(point[1]);
      // Example: User's current estimated position or source beacon
      final double? ux = nearestBeacon?.coordinateX!.toDouble();
      final double? uy = nearestBeacon?.coordinateY!.toDouble();
      final double dist = sqrt(pow(bx - ux!, 2) + pow(by - uy!, 2));
      print("distances from each beacon:${dist}");
    return dist;
  }
  double euclideanDistance(String a, String b) {
    final aParts = a.split(',').map((e) => double.tryParse(e) ?? 0).toList();
    final bParts = b.split(',').map((e) => double.tryParse(e) ?? 0).toList();

    final x1 = aParts.length > 0 ? aParts[0] : 0;
    final y1 = aParts.length > 1 ? aParts[1] : 0;
    final x2 = bParts.length > 0 ? bParts[0] : 0;
    final y2 = bParts.length > 1 ? bParts[1] : 0;

    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }

  double computeCosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0;

    double dotProduct = 0, normA = 0, normB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return (normA == 0 || normB == 0) ? 0 : dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<void> addMarker(LatLng _markerPosition) async {
    print("latlng:${_markerPosition.latitude},${_markerPosition.longitude}");
    _Markers.add(
      Marker(
          markerId: MarkerId('${_markerPosition.latitude},${_markerPosition.longitude}'),
          position: _markerPosition,
          onTap: (){
            print("on dot marker");
          }
      ),
    );
    _updateMarkers();
  }
  BLEManager bleManager = BLEManager();
  static Map<String, int> beaconCountMap = {};
  Future<void> collectSensorDataEverySecond(HashMap<String, beacon> apibeaconmap)async{
    if(apibeaconmap != null){
      // bleManager.startScanning(bufferSize: 5, streamFrequency: 7,duration: null);
      // bluetoothScanAndroidClass.listenToScanUpdates(apibeaconmap!);
    }else{
      HelperClass.showToast("Getting beacon data!!");
    }
    data = Data(position: "${userPosition?.coordx},${userPosition?.coordy},$floor");
    accelerometerEvents.listen((AccelerometerEvent event) {
      _x = event.x;
      _y = event.y;
      _z = event.z;
    });
    FlutterCompass.events!.listen((event){
      theta = event.heading!;
    });
    List<BeaconReal> beacons = [];
    beacons.clear();
    bleManager.bufferedDeviceStream.listen((streamData) async {
      // print("datafrom scanning ${data}");
      Map<String, List<int>> beaconWithRssi = {};
      streamData.forEach((deviceName,deviceRssi){
        List<int> rssiList = [];
        deviceRssi.forEach((key,value){
          rssiList.add(int.parse(value));
        });
        beaconWithRssi[deviceName] = rssiList;
      });
      // print("beaconWithRssi:${beaconWithRssi}");
      beaconWithRssi.forEach((key,value){
        if(apibeaconmap != null && apibeaconmap![key] != null){
          Position position = Position(x:(apibeaconmap![key]!.coordinateX??apibeaconmap![key]!.doorX!).toDouble(),y:(apibeaconmap![key]!.coordinateY??apibeaconmap![key]!.doorY!).toDouble());
          beacons.add(setBeacon(key, key, value,position,apibeaconmap![key]!.floor!.toString(),apibeaconmap![key]!.buildingID));
        }
      });
      // print("📦 Parsed beaconWithRssi: $beaconWithRssi ${apibeaconmap}");
      // Map beacons to known positions
      beaconWithRssi.forEach((key, value) {
        if (apibeaconmap != null && apibeaconmap![key] != null) {
          // print("got inside this123");
          final beaconInfo = apibeaconmap![key]!;
          final position = Position(
            x: (beaconInfo.coordinateX ?? beaconInfo.doorX!).toDouble(),
            y: (beaconInfo.coordinateY ?? beaconInfo.doorY!).toDouble(),
          );
          beacons.add(setBeacon(
            key,
            key,
            value,
            position,
            beaconInfo.floor!.toString(),
            beaconInfo.buildingID,
          ));
        }
      });
      // print("beacon added:${beacons}");

      // Create fingerprint with this scan batch
      final fingerprint = SensorFingerprintReal(
        beacons: beacons,
        wifi: null,
        gpsData: null,
        magnetometerData: null,
        accelerometerData: null,
        lux: null,
        timeStamp: dateFormat.format(DateTime.now().toUtc()),
      );
      data??=Data();
      data?.sensorFingerprint ??= [];
      data?.sensorFingerprint?.add(fingerprint);
      // print("🧠 Collected Fingerprint: ${data?.toJson()} ${fingerprint}");
      // Optional: Handle scan termination
      print("${data!=null && data!.sensorFingerprint!=null && data!.sensorFingerprint!.isNotEmpty}");
       if(data!=null && data!.sensorFingerprint!=null && data!.sensorFingerprint!.isNotEmpty){
         if(SingletonFunctionController.currentBeacon!.isNotEmpty && bleManager.finalName.isNotEmpty){
          String prevBeacon=bleManager.finalName;
          // print("the distaces between the ${SingletonFunctionController.currentBeacon} ${prevBeacon} two:${ tools.calculateDistance(
          //     [
          //       SingletonFunctionController.apibeaconmap[SingletonFunctionController.currentBeacon]!.coordinateX!,
          //       SingletonFunctionController.apibeaconmap[SingletonFunctionController.currentBeacon]!.coordinateY!
          //     ],
          //     [
          //       SingletonFunctionController.apibeaconmap[prevBeacon]!.coordinateX!,
          //       SingletonFunctionController.apibeaconmap[prevBeacon]!.coordinateY!
          //     ]
          // )}");
          if (SingletonFunctionController.currentBeacon!=null &&
             SingletonFunctionController.currentBeacon!.isNotEmpty &&
              tools.calculateDistance(
                  [
                    SingletonFunctionController.apibeaconmap[SingletonFunctionController.currentBeacon]!.coordinateX!,
                    SingletonFunctionController.apibeaconmap[SingletonFunctionController.currentBeacon]!.coordinateY!
                  ],
                  [
                    SingletonFunctionController.apibeaconmap[prevBeacon]!.coordinateX!,
                    SingletonFunctionController.apibeaconmap[prevBeacon]!.coordinateY!
                  ]
              ) >= 25
          ) {

            beaconCountMap[prevBeacon] = (beaconCountMap[prevBeacon] ?? 0) + 1;
            // print("got inside this first time");
            print("beaconCountMap:${beaconCountMap[prevBeacon]!}");
            if (beaconCountMap[prevBeacon]! >3) {
              SingletonFunctionController.currentBeacon = prevBeacon;
              beaconCountMap.clear(); // Optional: reset counts after localization
            }
          }
         }
         else if(SingletonFunctionController.currentBeacon==null || SingletonFunctionController.currentBeacon!.isEmpty){
           // print("got inside this first time");
           SingletonFunctionController.currentBeacon=bleManager.finalName;
           // print("SingletonFunctionController.currentBeacon:${SingletonFunctionController.currentBeacon}");
         }
        // if(kDebugMode)showToast(SingletonFunctionController.currentBeacon);
        // Map<String,dynamic> realtimeData= computeRealtimeBeaconStats(data!.sensorFingerprint!);
        // String nearestPoint=await findBestMatchingLocationHybrid(realTimeData:realtimeData,preProcessData:getPreAveragedData());
        // SingletonFunctionController.fingerprintingPoint=nearestPoint;
        try {
          SingletonFunctionController().updatePoint(SingletonFunctionController.apibeaconmap[SingletonFunctionController.currentBeacon]!);
        }catch(e){}
        // HelperClass.showToast("${BLEManager.finalName}");
        // HelperClass.showToast("${nearestPoint}");
        // print("fingerprinting data: ${nearestPoint}");
       }
    });
  }

  // Future<bool> stopCollectingData()async{
  //   timer?.cancel();
  //   bluetoothScanAndroidClass.stopScan();
  //   //cancel beacon stream here
  //   return await fingerPrintingApi().Finger_Printing_API(buildingAllApi.selectedBuildingID, data!);
  // }
  Future<bool> stopCollectingRealData() async {
    timer?.cancel();
    timer=null;
    print("realtime scanning stopped");
    //cancel beacon stream here
    return true;
  }


  void disableRealValues(){
    data?.sensorFingerprint = [];

    return;
  }
  BeaconReal setBeacon(String? beaconMacId, String? beaconName, List<int> beaconRssi, Position? beaconPosition,   String? beaconFloor,   String? buildingId){
    return BeaconReal(
        beaconMacId: beaconMacId, beaconName: beaconName, beaconRssi: beaconRssi, beaconPosition: beaconPosition,beaconFloor:beaconFloor,buildingId:buildingId
    );
  }
  Future<MagnetometerData> fetchMagnetometerData() async {
    return MagnetometerData(value: theta);
  }

  Future<AccelerometerData> fetchAccelerometerData() async {
    return AccelerometerData(x: _x, y: _y, z: _z);
  }

  double average(List<int> numbers) {
    if (numbers.isEmpty) return 0.0;
    int sum = numbers.reduce((a, b) => a + b);
    return sum / numbers.length;
  }



}