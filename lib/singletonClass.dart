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
import 'buildingState.dart';
import '../main.dart';

class SingletonFunctionController {

  static final SingletonFunctionController _instance = SingletonFunctionController._internal();
  factory SingletonFunctionController() => _instance;
  SingletonFunctionController._internal();
  bool _isRunning = false;
  Completer<void>? _completer;
  static HashMap<String, beacon> apibeaconmap = HashMap();
  static Building building = Building(floor: Map(), numberOfFloors: Map());
  static Future<void>? timer;
  static String? currentBeacon = "";
  static double currentRssi = double.infinity;
  static String SC_LOCALIZED_BEACON = "";
  static String fingerprintingPoint="";
  static String localizedBeacon="";
  static Map<String, double> SC_IL_RSSI_AVERAGE = {};
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