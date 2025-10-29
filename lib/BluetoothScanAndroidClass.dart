
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwaymaps/singletonClass.dart';

import 'APIMODELS/beaconData.dart';
import 'ELEMENTS/BlurtoothDevice.dart';
import 'ELEMENTS/HelperClass.dart';

class BluetoothScanAndroidClass{

  BluetoothScanAndroidClass._internal();

  static final BluetoothScanAndroidClass _instance = BluetoothScanAndroidClass._internal();

  factory BluetoothScanAndroidClass() => _instance;


  static const methodChannel = MethodChannel('com.example.bluetooth/scan');
  static const eventChannel = EventChannel('com.example.bluetooth/scanUpdates');
  List<BluetoothDevice> devices = [];
  bool isScanning = false;
  bool EM_isScanning = false;
  static StreamSubscription? _scanSubscription; // Variable to hold the subscription
  int count = 0;

  Map<String, String> deviceNames = {};
  Map<String, List<int>> rssiValues = {};
  Map<String, double> distances = {};
  String closestDeviceDetails = "";
  String closestrssiDevice = "";
  String closestRSSI = "";
  Map<String, double> sumMapCallBack = {};
  Map<String, double> rssiAverage = {};
  Map<String, List<double>> rssiWeight = {};

  Map<String, List<double>> newList = {};

  String EM_NEAREST_BEACON = "";
  beacon EM_NEAREST_BEACON_VALUE = beacon();
  static Map<String, List<int>> EM_RSSI_VALUES = {};


  Future<void> startScan() async {
    print("startScan stacktrace");
    print(StackTrace.current);
    if(isScanning) return;
    try{
      await methodChannel.invokeMethod('startScan');
      isScanning = true;
    } on PlatformException catch(e){
      print("Failed to start scan: ${e.message}");
    }
  }

  Future<void> stopScan() async {
    if(!isScanning) return;

    try {
      await methodChannel.invokeMethod('stopScan');
      _scanSubscription?.cancel();
      isScanning = false;
    } on PlatformException catch (e) {
      print("Failed to stop scan: ${e.message}");
    }
  }




  List<String> nearestBeaconList = [];
  static Map<String, String> EM_DEVICE_NAME = {};
  static Map<String, List<double>> EM_RSSI_WEIGHT = {};
  static Map<String, double> EM_RSSI_AVERAGE = {};

  Future<String> listenToScanInitialLocalization(HashMap<String, beacon> apibeaconmap) async {
    print("listenToScanInitialLocalization");
    Map<String, String> IL_DEVICE_NAME = {};
    Map<String, List<int>> IL_RSSI_VALUES = {};
    Map<String, List<double>> IL_RSSI_WEIGHT = {};
    Map<String, double> IL_RSSI_AVERAGE = {};


    String closestDeviceDetails = "";

    print("Starting scan...");
    startScan(); // Ensure this function is implemented and starts the Bluetooth scan

    StreamSubscription? subscription;
    try {
      // Listen to the stream continuously
      subscription = eventChannel.receiveBroadcastStream().listen((deviceDetail) {
        // print("Received device detail: $deviceDetail");

        BluetoothDevice deviceDetails = HelperClass().parseDeviceDetails(deviceDetail);
        if (apibeaconmap.containsKey(deviceDetails.DeviceName)) {
          // print("Device found in apibeaconmap: ${deviceDetails.DeviceName}");
          String deviceMacId = deviceDetails.DeviceAddress;
          IL_DEVICE_NAME[deviceDetails.DeviceAddress] = deviceDetails.DeviceName;

          IL_RSSI_VALUES.putIfAbsent(deviceDetails.DeviceAddress, () => []);
          IL_RSSI_WEIGHT.putIfAbsent(deviceDetails.DeviceAddress, () => []);

          IL_RSSI_VALUES[deviceDetails.DeviceAddress]!.add(int.parse(deviceDetails.DeviceRssi));
          IL_RSSI_WEIGHT[deviceDetails.DeviceAddress]!.add(
              getWeight(getBinNumber(int.parse(deviceDetails.DeviceRssi).abs())));
        }
      }, onError: (error) {
        print("Error receiving device updates: $error");
      });
    } catch (e) {
      print("Error starting scan or receiving updates: $e");
    }

    await Future.delayed(Duration(seconds: 6));

    print("Stopping scan...");
    await subscription?.cancel();
    // stopScan();

    print("Processing scan results...");
    print("Device Names: $IL_DEVICE_NAME");
    print("RSSI Values: $IL_RSSI_VALUES");
    print("RSSI Weights: $IL_RSSI_WEIGHT");

    IL_RSSI_AVERAGE = calculateAverageFromRssi(IL_RSSI_VALUES, IL_DEVICE_NAME, IL_RSSI_WEIGHT);
    closestDeviceDetails = findLowestRssiDevice(IL_RSSI_AVERAGE);

    if(IL_RSSI_AVERAGE.isNotEmpty){
      SingletonFunctionController.SC_IL_RSSI_AVERAGE = {};
      SingletonFunctionController.SC_IL_RSSI_AVERAGE = IL_RSSI_AVERAGE;
    }

    print("Closest Device Details: $closestDeviceDetails");
    // if(closestDeviceDetails != "No devices found"){
    //
    // }
    SingletonFunctionController.SC_LOCALIZED_BEACON = "";
    SingletonFunctionController.SC_LOCALIZED_BEACON = closestDeviceDetails;
    // stopScan();
    return closestDeviceDetails;

  }



  Map<String,Map<DateTime,String>> buffer = Map();
  Timer? trimBufferTimer;
  String closestBeaconName = "";
  double closestBeaconAverage = 0.0;

  //For logging purpose (debug)
  Map<DateTime,Map<String,List<String>>> logging = Map();
  List<DateTime> loggingTaps = [];
  void listenToScanUpdates(HashMap<String, beacon> apibeaconmap) {
    startScan();
    loggingTaps.clear();
    // print("listenToScanUpdates");
    trimBuffer(5);
    Map<String, List<int>> rssiValues = {};
    String deviceMacId = "";
    // Start listening to the stream continuously
    _scanSubscription = eventChannel.receiveBroadcastStream().listen((deviceDetail) {

      BluetoothDevice deviceDetails = HelperClass().parseDeviceDetails(deviceDetail);

      if(apibeaconmap.containsKey(deviceDetails.DeviceName)) {
        buffer.putIfAbsent(deviceDetails.DeviceName, () => <DateTime, String>{});
        buffer[deviceDetails.DeviceName]![DateTime.now()] = deviceDetails.DeviceRssi;
        //logging
        final now = DateTime.now();
        logging.putIfAbsent(now, () => <String, List<String>>{});
        logging[now]!.putIfAbsent(deviceDetails.DeviceName, () => []);
        logging[now]![deviceDetails.DeviceName]!.add(deviceDetails.DeviceRssi);
        // print("logging keys ${logging.keys}");
      }
    }, onError: (error) {
      print('Error receiving device updates: $error');
    });
  }


  void trimBuffer(int bufferSize){
    trimBufferTimer = Timer.periodic(Duration(seconds: 1), (timer)  {
      buffer.forEach((beaconName,beaconRespVal){
        final toRemove = <DateTime>[];
        beaconRespVal.forEach((beaconDateTime, beaconRSSI){
          if(DateTime.now().difference(beaconDateTime) > Duration(seconds: bufferSize)){
            toRemove.add(beaconDateTime);
          }
        });
        for(final beaconDateTime in toRemove){
          beaconRespVal.remove(beaconDateTime);
        }
      });
      final keysToRemove = <String>[];
      buffer.forEach((key, value) {
        if (value.isEmpty) {
          keysToRemove.add(key);
        }
      });
      for (final key in keysToRemove) {
        buffer.remove(key);
      }
      doCalculationForNearestBeacon();
    });
  }

  void doCalculationForNearestBeacon() {
    Map<String, double> beaconWeightedAverages = {};

    buffer.forEach((beaconName, rssiMap) {
      if (rssiMap.isNotEmpty) {
        int rssiSum = 0;
        double totalSize = 0;

        for (var rssiStr in rssiMap.values) {
          if(rssiStr.isNotEmpty) {
            int? rssi = int.tryParse(rssiStr);
            rssi = rssi?.abs(); // Convert to positive for bin weight logic
            rssiSum += rssi!;
            totalSize++;
          }else{
            print("rssiStr.isEmpty");
          }
        }

        if (totalSize > 0) {
          double weightedAverage = rssiSum / totalSize;
          beaconWeightedAverages[beaconName] = weightedAverage;
        }

      }

    });
    // print("beaconWeightedAverages $beaconWeightedAverages");
      MapEntry<String, double>? minEntry = beaconWeightedAverages.isNotEmpty
          ? beaconWeightedAverages.entries.reduce((a, b) => a.value < b.value ? a : b)
          : null;
      // print("minEntry $minEntry");
      if(minEntry != null) {
        closestBeaconName = minEntry.key;
        closestBeaconAverage = minEntry.value;
      }

    return;
  }


  Map<String, List<int>> returnCurrentBeaconValue(){
    Map<String, List<int>> response = {};
    DateTime current = DateTime.now();
    buffer.forEach((beaconName,beaconTimeRssi){
      beaconTimeRssi.forEach((beaconDateTime, beaconRSSI){
        if(current.difference(beaconDateTime) <= const Duration(seconds: 1)){
          response.putIfAbsent(beaconName, ()=>[]);
          response[beaconName]!.add(int.parse(beaconRSSI));
        }
      });
    });
    // print("returnCurrentBeaconValue $response");
    return response;
  }



  Map<String, List<double>> giveSumMapCallBack(){
    // print("newList");

    // print(newList);
    return newList;
  }

  String giveClosestDeviceCallBAck(){
    return closestrssiDevice;
  }
  String giveRssiMapCallBAck(){
    return closestrssiDevice;
  }
  String giveRssiCallBAck(){
    return closestRSSI;
  }

  Map<String, double> calculateAverageFromRssi(
      Map<String, List<int>> rssiValues,
      Map<String, String> deviceList,
      Map<String, List<double>> rssiWeight) {
    Map<String, double> averagedRssiValues = {};

    rssiWeight.forEach((address, rssiList) {
      if (rssiList.isNotEmpty) {
        // Calculate average if the list is not empty
        double average = rssiList.reduce((a, b) => a + b) / rssiList.length;
        int beaconBinNumber = getBinNumber(average.toInt());

        // Update the newList for debugging or other purposes
        newList[deviceList[address]!] = rssiList;

        print("deviceList[address]");
        print(average);
        print(newList);

        // Add the average to the map
        averagedRssiValues[deviceList[address]!] = average;
      } else {
        print("Warning: RSSI list for $address is empty.");
      }
    });

    // Sort by the average RSSI values in descending order
    var sortedEntries = averagedRssiValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return the sorted map
    return Map.fromEntries(sortedEntries);
  }


  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort(
              (a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }

  Map<String, double> calculateAverage(){
    //HelperClass.showToast("Bin ${BIN} \n number $numberOfSample");
    Map<String, double> sumMap = {};
    // Iterate over each inner map and accumulate the values for each string key
    BIN.values.forEach((innerMap) {
      innerMap.forEach((key, value) {
        sumMap[key] = (sumMap[key] ?? 0.0) + value;
      });
    });
    // Divide the sum by the number of values for each string key
    sumMap.forEach((key, sum) {
      int count = numberOfSample[key]!;
      sumMap[key] = sum / count;
    });

    BIN = HashMap();
    numberOfSample.clear();
    startbin();

    return sumMap;
  }


  double calculateDistance(double rssi) {
    const int txPower = -64; // Adjust based on the reference RSSI at 1 meter
    const double environmentalFactor = 1; // Adjust based on your environment
    return pow(10, (txPower - rssi) / (10 * environmentalFactor))
        .toDouble(); // Cast to double
  }

  String findLowestRssiDevice(Map<String, double> rssiAverage) {
    String? lowestKey;
    double? lowestValue;

    rssiAverage.forEach((key, value) {
      if (lowestValue == null || value > lowestValue!) {
        lowestValue = value;
        lowestKey = key;
      }
    });
    closestRSSI = lowestValue.toString();
    print("findLowestRssiDevice");
    print(lowestValue);

    return lowestKey ?? "No devices found";
  }

  String EM_findLowestRssiDevice(Map<String, double> rssiAverage) {
    String? lowestKey;
    double? lowestValue = 3;
    print("rssiAverage");
    print(rssiAverage);
    rssiAverage.forEach((key, value) {

      if (lowestValue == null || value > lowestValue!) {
        lowestValue = value;
        lowestKey = key;
      }
    });
    closestRSSI = lowestValue.toString();
    print("findLowestRssiDevice");
    print(lowestValue);
    print(lowestKey);

    return lowestKey ?? "No devices found";
  }


  HashMap<int, HashMap<String, double>> BIN = HashMap();
  HashMap<String,int> numberOfSample = HashMap();
  HashMap<String,List<int>> rs = HashMap();
  HashMap<int, double> weight = HashMap();

  int getBinNumber(int Rssi){
    if (Rssi <= 65) {
      print("getBinNumber0");
      return 0;
    } else if (Rssi <= 75) {
      print("getBinNumber1");
      return 1;
    } else if (Rssi <= 80) {
      print("getBinNumber2");
      return 2;
    } else if (Rssi <= 85) {
      return 3;
    } else if (Rssi <= 90) {
      return 4;
    } else if (Rssi <= 95) {
      return 5;
    } else {
      return 6;
    }
  }


  double getWeight(int num){
    switch(num) {
      case 0:
        return 12.0;
      case 1:
        return 6.0;
      case 2:
        return 4.0;
      case 3:
        return 0.5;
      case 4:
        return 0.25;
      case 5:
        return 0.15;
      case 6:
        return 0.1;
      default:
        return 0.0;
    }
  }


  void addtoBin(String MacId, int rssi) {

    int binnumber = 0;
    int Rssi = rssi * -1;
    if(numberOfSample[MacId] == null){
      numberOfSample[MacId] = 0;
      rs[MacId] = [];
    }
    numberOfSample[MacId] = numberOfSample[MacId]! + 1;
    rs[MacId]!.add(rssi);



    //print("of beacon ${rs}");


    if (Rssi <= 65) {
      binnumber = 0;
    } else if (Rssi <= 75) {
      binnumber = 1;
    } else if (Rssi <= 80) {
      binnumber = 2;
    } else if (Rssi <= 85) {
      binnumber = 3;
    } else if (Rssi <= 90) {
      binnumber = 4;
    } else if (Rssi <= 95) {
      binnumber = 5;
    } else {
      binnumber = 6;
    }

    if(BIN[binnumber]==null){
      startbin();
    }

    if (BIN[binnumber]!.containsKey(MacId)) {
      BIN[binnumber]![MacId] = BIN[binnumber]![MacId]! + weight[binnumber]!;
    } else {
      BIN[binnumber]![MacId] = 1 * weight[binnumber]!;
    }
    //print("number of sample---${numberOfSample[MacId]}");
  }

  void startbin() {
    BIN[0] = HashMap<String, double>();
    BIN[1] = HashMap<String, double>();
    BIN[2] = HashMap<String, double>();
    BIN[3] = HashMap<String, double>();
    BIN[4] = HashMap<String, double>();
    BIN[5] = HashMap<String, double>();
    BIN[6] = HashMap<String, double>();

    weight[0] = 12.0;
    weight[1] = 6.0;
    weight[2] = 4.0;
    weight[3] = 0.5;
    weight[4] = 0.25;
    weight[5] = 0.15;
    weight[6] = 0.1;
  }

  void emptyBin() {
    for (int i = 0; i < BIN.length; i++) {
      BIN[i]!.clear();
    }
    numberOfSample.clear();
    rs.clear();
  }
}