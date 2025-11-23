import 'dart:core';

import 'package:iwaymaps/singletonClass.dart';

import 'API/buildingAllApi.dart';
import 'APIMODELS/Building.dart';
import 'BluetoothManager/BeaconValueInjector.dart';

class PeakValley {
  String realtimeThreshold;
  PeakValley({required this.realtimeThreshold}){
    if(realtimeThreshold.isEmpty){
      realtimeThreshold = "-85";
    }
  }
  // Internal beacon history: only tracks one beacon at a time
  Map<String, List<BeaconReading>> _beaconHistory = {};

  Map<String, List<double>> get beaconHistoryValues {
    return _beaconHistory.map(
          (key, value) => MapEntry(
        key,
        value.map((entry) => entry.value).toList(),
      ),
    );
  }

  Map<String, double> _beaconPeakMap = {};

  BeaconInjector injector = BeaconInjector();

  /// Processes a beacon reading and detects:
  /// 1. Peak → Valley → Valley
  /// 2. Peak → Valley → BeaconChange
  ///
  /// Returns a MapEntry:
  /// - key: beacon ID
  /// - value: steps to be moved
  /// Returns null if no pattern detected.

  MapEntry<String, int>? processBeaconPerSecond(
      Map<String, List<int>> originalBeacons) {
    if (originalBeacons.isEmpty) {
      print("exiting because of empty list for ${originalBeacons.keys}");
      return null;
    }

    Map<String, List<int>> beacons = injector.process({...originalBeacons});

    DateTime flagTime = DateTime.now();

    // Process ALL beacons, not just the strongest
    MapEntry<String, int>? result;

    // print("injectedvalues ${sortMapByKey(beacons)}");

    for (String beaconId in beacons.keys) {
      List<int> rssiList = beacons[beaconId]!;
      if (rssiList.isEmpty){
        print("rssiList is empty ${beaconId}");
        continue;
      }

      int maxRssi = rssiList.reduce((a, b) => a > b ? a : b);
      double beaconWeight = maxRssi.toDouble();

      // Initialize history for new beacons
      if (!_beaconHistory.containsKey(beaconId)) {
        _beaconHistory[beaconId] = [];
      }

      // Add current reading to this beacon's history
      bool isInjected = !(originalBeacons.containsKey(beaconId));

      _beaconHistory[beaconId]!.add(
        BeaconReading(flagTime, beaconWeight, isInjected),
      );

      // Keep last 3 entries per beacon
      if (_beaconHistory[beaconId]!.length > 4) {
        _beaconHistory[beaconId]!.removeAt(0);
      }

      // Check for patterns on this beacon
      MapEntry<String, int>? beaconResult =
      _checkBeaconPattern(beaconId, flagTime);

      if (beaconResult != null) {
        if (result == null ||
            _beaconPeakMap[beaconId]! > _beaconPeakMap[result.key]!) {
          result = beaconResult;
        }
      }
    }

    // // Handle beacon change detection (strongest beacon switched)
    // if (lastProcessedBeacon != strongestBeacon && lastProcessedBeacon != null) {
    //   MapEntry<String, int>? changeResult = _handleBeaconChange(lastProcessedBeacon!, strongestBeacon!, flagTime);
    //   if (changeResult != null) {
    //     result = changeResult;
    //   }
    // }

    // lastProcessedBeacon = strongestBeacon;
    return result;
  }

  double peakThresh=-85;
  double getPeakValleyThreshold(){
    if(SingletonFunctionController.building.patchData[buildingAllApi.selectedBuildingID]!=null && SingletonFunctionController.building.patchData[buildingAllApi.selectedBuildingID]!.patchData!.realtimeLocalisationThreshold != null && SingletonFunctionController.building.patchData[buildingAllApi.selectedBuildingID]!.patchData!.realtimeLocalisationThreshold!.isNotEmpty){
      peakThresh = double.parse(SingletonFunctionController.building.patchData[buildingAllApi.selectedBuildingID]!.patchData!.realtimeLocalisationThreshold!);
    }
    print("peakThresh:${peakThresh}");
    return peakThresh;
  }

  MapEntry<String, int>? _checkBeaconPattern(
      String beaconId, DateTime flagTime) {
    List<BeaconReading> history = _beaconHistory[beaconId]!;

    history.forEach((h){
      print("history $beaconId ${h.toString()}");
    });

    // Check Peak → Valley → Valley pattern
    if (history.length >= 3) {

      // if (history[1].injected && history[2].injected) {
      //   return null;
      // }

      var a = history[0]; // oldest
      var b = history[1]; // middle
      var c = history[2]; // newest (current)
      var d;
      if(history.length>3){
        d = history[3];
      }

      if (history[0].time.difference(history[1].time).inSeconds.abs() > 2 ||
          history[1].time.difference(history[2].time).inSeconds.abs() > 2) {
        return null;
      }

      bool peakGreaterThanPrevious =
          _beaconPeakMap[beaconId] == null || b.value > _beaconPeakMap[beaconId]!;

      // Pattern: Peak → Valley → Valley (a > b, a > c, b >= c)
      print("int.parse(realtimeThreshold) ${int.parse(realtimeThreshold)}");
      if (b.value > getPeakValleyThreshold() && a.value < b.value && b.value > c.value && peakGreaterThanPrevious && !matchesPattern(a, b, c, d)) {
        Duration duration = history[0].time.difference(flagTime).abs();
        int roundedSeconds = (duration.inMilliseconds / 1000).round();
        int stepsToBeMoved = (roundedSeconds / 2).round();
        // Update peak map
        _beaconPeakMap[beaconId] = b.value;
        // print(
        //     "${history[0]}     ${history[1]}     ${history[2]}      ${history[3]}      ${_beaconPeakMap[beaconId]}    $beaconId   second condition");
        return MapEntry(beaconId, stepsToBeMoved);
      }
    }

    return null;
  }

  bool matchesPattern(BeaconReading A, BeaconReading B, BeaconReading C, BeaconReading? D) {
    final a = A.injected;
    final b = B.injected;
    final c = C.injected;
    final d = D?.injected;

    final cond1 = (a && b && c);

    bool cond3 = false;
    bool cond4 = false;
    bool cond5 = false;
    bool cond6 = false;
    bool cond7 = false;
    bool cond8 = false;

    if (D != null) {
      cond3 = (!a && b && c && d!);
      cond4 = (!a && b && c && !d! && D.value > C.value);
      cond5 = (a && b && !c && d! && D.value > C.value);
      cond6 = (a && b && !c && !d! && D.value > C.value);
      cond7 = (!a && b && !c && d! && D.value > C.value);
      cond8 = (!a && b && !c && !d! && D.value > C.value);
    }

    return cond1 || cond3 || cond4 || cond5 || cond6 || cond7 || cond8;
  }

  Map<String, List<int>> sortMapByKey(Map<String, List<int>> input) {
    final sortedKeys = input.keys.toList()..sort();
    return {for (var k in sortedKeys) k: input[k]!};
  }

}

class BeaconReading {
  final DateTime time;
  final double value;
  final bool injected;

  BeaconReading(this.time, this.value, this.injected);

  @override
  String toString() {
    return '(value: $value, injected: $injected, time: $time)';
  }
}

