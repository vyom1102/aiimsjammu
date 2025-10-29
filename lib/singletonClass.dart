import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/APIMODELS/buildingAll.dart';

import 'API/beaconapi.dart';
import 'APIMODELS/beaconData.dart';
import 'BluetoothManager/BLEManager.dart';
import 'BluetoothScanAndroidClass.dart';
import 'BluetoothScanIOSClass.dart';
import 'MapMarkerCluster/MarkerClustering.dart';
import 'Repository/RepositoryManager.dart';
import 'bluetooth_scanning.dart';
import 'buildingState.dart';
import '../main.dart';

class SingletonFunctionController {

  static final SingletonFunctionController _instance = SingletonFunctionController._internal();
  factory SingletonFunctionController() => _instance;
  SingletonFunctionController._internal();
  bool _isRunning = false;
  Completer<void>? _completer;
  static BLueToothClass btadapter = new BLueToothClass();
  static HashMap<String, beacon> apibeaconmap = HashMap();
  static Building building = Building(floor: Map(), numberOfFloors: Map());
  static Future<void>? timer;
  static String currentBeacon = "";
  static double currentRssi = double.infinity;
  static String SC_LOCALIZED_BEACON = "";
  static String fingerprintingPoint="";
  static String localizedBeacon="";
  MapClustering mapCLustring = MapClustering(onMarkerTapCallback: (String sId) {  });
  BluetoothScanAndroidClass bluetoothScanAndroidClass = BluetoothScanAndroidClass();
  static Map<String, double> SC_IL_RSSI_AVERAGE = {};
  BluetoothScanIOSClass bluetoothScanIOSClass = BluetoothScanIOSClass();
  // Private controller
  final StreamController<beacon> _controller = StreamController<beacon>.broadcast();
  // Public stream
  Stream<beacon> get stream => _controller.stream;
  final _seen = <String>{};
  // Update the stream
  void updatePoint(beacon point){
      try {
          print("points added");
          _controller.add(point);
      }catch(e){}
  }
  // Optional dispose
  void dispose() {
    currentBeacon="";
    _controller.close();
  }

  bool isBinEmpty() {
    for (int i = 0; i < SingletonFunctionController.btadapter.BIN.length; i++) {
      if (SingletonFunctionController.btadapter.BIN[i] != null &&
          SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty) {
        // If any bin is not empty, return false
        return false;
      }
    }
    // If all bins are empty, return true
    return true;
  }

  Future<void> executeFunction(Map<String,LatLng> allBuildingID) async {
    if (_isRunning){
      // Wait for the currently running instance to finish
      return _completer?.future;
    }
    // Mark the function as running and create a new Completer
    _isRunning = true;
    _completer = Completer<void>();
    if(buildingAllApi.outdoorID.isNotEmpty){
      allBuildingID[buildingAllApi.outdoorID] = LatLng(0.0, 0.0);
    }
    try {
      // Perform your task here
      building.qrOpened=false;
      building.destinationQr=false;
      await Future.wait(allBuildingID.entries.map((entry) async {
        var key = entry.key;
        List<beacon> beaconList = await RepositoryManager().getBeaconDataNew(key);
        if (building.beacondata == null) {
          building.beacondata = beaconList;
        } else {
          building.beacondata = List.from(building.beacondata!)..addAll(beaconList);
        }
        for (var beacon in beaconList) {
          if (beacon.name != null) {
            apibeaconmap[beacon.name!] = beacon!;
          }
        }
        Building.apibeaconmap = apibeaconmap;
      })).then((value)async{
        print("again got called inside singleton");
        if(!kIsWeb){
          if(Platform.isAndroid){
            BLEManager().startScanning(bufferSize: 5, streamFrequency: 5,duration: 10);
          }else{
            BluetoothScanIOSClass.startScan();
          }
        }
        timer= Future.delayed((await FlutterBluePlus.isOn==true)?Duration(seconds:4):Duration(seconds:0));
        //timer= Future.delayed((await FlutterBluePlus.isOn==true)?Duration(seconds:9):Duration(seconds:0));
      });

      // Simulate a long-running task
    } finally {
      // Mark the function as complete
      _isRunning = false;
      _completer?.complete();

    }
  }

  Future<Map<String, double>?> getLatLng() async {
    Position? position = await getCurrentLocation();

    if (position != null) {
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    }
    return null;
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return null;
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  beacon? getlocalizedBeacon(){
    double highestweight = 0;
    String nearestBeacon = "";
    // if(isBinEmpty() == false){
    // }
    return (SingletonFunctionController.currentBeacon!="")?Building.apibeaconmap[SingletonFunctionController.currentBeacon]:null;
  }
}

void showToast(String mssg) {
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

class FingerPrintPoint{
  final int fingerX;
  final int fingerY;
  final int fingerFloor;
  final String fingerBid;

  FingerPrintPoint({
    required this.fingerX,
    required this.fingerY,
    required this.fingerFloor,
    required this.fingerBid,
  });
}