import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../APIMODELS/Building.dart';
import '../APIMODELS/beaconData.dart';
import '../ELEMENTS/BlurtoothDevice.dart';
import '../ELEMENTS/HelperClass.dart';
import '../path_snapper.dart';
import '../singletonClass.dart';
import 'BluetoothKalmanFilter.dart';


class BLEManager{
  static final BLEManager _instance = BLEManager._internal();
  String finalName = "";
  double finalweight = double.infinity;

  factory BLEManager() {
    return _instance;
  }
  BLEManager._internal();
  static const methodChannel = MethodChannel('com.example.bluetooth/scan');
  static const eventChannel = EventChannel('com.example.bluetooth/scanUpdates');
  final StreamController<Map<String, dynamic>> _bufferedDeviceStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get bufferedDeviceStream => _bufferedDeviceStreamController.stream;
  static StreamSubscription? scanSubscription;
  Timer? _bufferEmitTimer;
  Timer? _manualStopTimer;
  Timer? trimBufferTimer;
  Map<String,Map<DateTime,String>> buffer = Map();
  Map<String,double> weightAvg = {};
  void startScanning({
    required int bufferSize,
    required int streamFrequency,
    int? duration,
  }) {

    // stopScanning(); // cancel previous
    listenToScanUpdates(bufferSize);
    // Start emitting data to stream every [streamFrequency] seconds
    startBufferedEmission(bufferSizeInSeconds: streamFrequency);
    if (duration != null) {
      _manualStopTimer = Timer(Duration(seconds: duration), () {
        stopScanning();
      });
    }
  }


  void startBufferedEmission({required int bufferSizeInSeconds}) {
    if(kDebugMode)
      _bufferEmitTimer?.cancel(); // cancel previous if any
    _bufferEmitTimer = null;

    _bufferEmitTimer = Timer.periodic(Duration(seconds: bufferSizeInSeconds), (_) {
      final dataToSend = Map<String, Map<DateTime,String>>.from(buffer);
      _bufferedDeviceStreamController.add(dataToSend);
    });
  }
  void printFull(String text) {
    const int chunkSize = 800; // Console limit-safe size
    for (var i = 0; i < text.length; i += chunkSize) {

    }
  }
  Future<void> startScan() async {
    try{
      await methodChannel.invokeMethod('startScan');
      // isScanning = true;
    } on PlatformException catch(e){

    }
  }
  Future<void> stopScanning() async {
    try {
      await methodChannel.invokeMethod('stopScan');
      //cancel _scanSubscription of native scanning
      trimBufferTimer?.cancel();
      trimBufferTimer = null;
      scanSubscription?.cancel(
      );
      scanSubscription = null;
      //cancel buffer Emission
      _bufferEmitTimer?.cancel();
      // trimBuffer Timer
      //timer for manual scanning stop
      _manualStopTimer?.cancel();
      //dataStructure buffer clean
    } on PlatformException catch (e) {

    }
  }

  void listenToScanUpdates(int bufferSize) {
    startScan();
    buffer.clear();
    trimBuffer(bufferSize);
    // if (kDebugMode)
    print("listenToScanUpdates");
    scanSubscription = eventChannel.receiveBroadcastStream().listen((device) {
      // if (kDebugMode)
      // print("devices from scanning:${device}");
      BluetoothDevice deviceDetails = HelperClass().parseDeviceDetails(device);
      // 
      if(SingletonFunctionController.apibeaconmap.containsKey(deviceDetails.DeviceName)){
        // 
        buffer.putIfAbsent(deviceDetails.DeviceName, () => <DateTime, String>{});
        buffer[deviceDetails.DeviceName]![DateTime.now()] = deviceDetails.DeviceRssi;
      }
    }, onError: (error) {

    });
  }
  void trimBuffer(int bufferSize){
    trimBufferTimer = Timer.periodic(Duration(seconds: 1), (timer)  {
      // if (kDebugMode) 
      // 
      buffer.forEach((beaconName,beaconRespVal){
        final toRemove = <DateTime>[];
        beaconRespVal.forEach((beaconDateTime, beaconRSSI){
          // 
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
      // 
      doCalculationForNearestBeacon();
    });
  }
  void doCalculationForNearestBeacon(){
    //
    weightAvg.clear();
    Map<String, List<double>> beacons = {};
    buffer.forEach((beaconName, beaconResponseValues){
      double totalWeight = 0.0;
      int divideBySize = 0;

      beaconResponseValues.forEach((dateTime,rSSI){
        beacons.putIfAbsent(beaconName, ()=>[]);
        beacons[beaconName]!.add(double.parse(rSSI).abs());
      });
      //


      beaconResponseValues.forEach((dateTime,rSSI){
        totalWeight+= int.parse(rSSI).abs();
        divideBySize+=1;
      });
      weightAvg[beaconName] = totalWeight/divideBySize;
    });
    var result = BluetoothKalmanFilter().getNearestBeacon(beacons);

    // 
    String? nearest = result.key;
    String finalBeacon = "";
    var finalAverageVariable = 1000.0;
    var allBeacons = result.value;

    allBeacons.forEach((id, data) {
      var totalWeight = 0.0;
      var finalAverage = 0.0;

      List<double> smoothed = data['smoothed'];
      smoothed.forEach((rssi){
        totalWeight+=rssi.toInt();
      });
      finalAverage = totalWeight/smoothed.length;
      if(finalAverage<finalAverageVariable){
        finalAverageVariable = finalAverage;
        finalBeacon = id;
      }
      double avg = data['weightedAvg'];
      // 
      // 
      // 
      // 
      // 

    });
    double finalWeight = double.negativeInfinity;
    String localName = "";
    weightAvg.forEach((name,weight){
      if(weight>finalWeight){
        finalWeight = weight;
        localName = name;
      }
    });
    finalName = finalBeacon;
    finalweight = finalWeight;

    // if (!finalWeight.isNaN){
    //   finalWeight = finalWeight.toInt();
    // }
    print("finalWeight ${finalWeight}");

    if(finalName.isNotEmpty){
      SingletonFunctionController.currentBeacon=finalName;
      SingletonFunctionController.currentRssi = finalWeight;
    }
    // if (kDebugMode) 
    // if (kDebugMode) 
  }




}