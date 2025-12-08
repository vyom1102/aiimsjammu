import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:iwaymaps/APIMODELS/buildingAll.dart';
import 'package:vibration/vibration.dart';

import '../API/buildingAllApi.dart';
import '../BluetoothManager/BLEManager.dart';
import '../BluetoothScanAndroidClass.dart';
import '../BluetoothScanIOSClass.dart';
import '../Cell.dart';
import '../ELEMENTS/HelperClass.dart';
import '../ELEMENTS/UserCredential.dart';
import '../KeyCounter.dart';
import 'package:iwaymaps/navigationTools.dart';
import '../UserState.dart';
import '../beaconCleanUp.dart';
import '../bluetooth_scanning.dart';
import '../buildingState.dart';
import '../directionClass.dart' as dc;
import '../directionClass.dart';
import '../localization/locales.dart';
import '../peakValley.dart';
import '../singletonClass.dart';

class DirectionHeader extends StatefulWidget {
  String direction;
  int distance;
  bool isRelocalize;
  UserState user;
  String getSemanticValue;
  BuildContext context;
  final Function(String? nearestBeacon,   String? polyID, {   bool speakTTS ,   bool render,   bool providePinSelection, }) paint;
  final Function(String nearestBeacon) repaint;
  final Function() reroute;
  final Function() moveUser;
  final Function({bool force}) closeNavigation;
  final Function(dc.direction turn) focusOnTurn;
  final Function() clearFocusTurnArrow;

  DirectionHeader({
    this.distance = 0,
    required this.user,
    this.direction = "",
    required this.paint,
    required this.repaint,
    required this.reroute,
    required this.moveUser,
    required this.closeNavigation,
    required this.isRelocalize,
    this.getSemanticValue = '',
    required this.focusOnTurn,
    required this.clearFocusTurnArrow,
    required this.context,
  }) {
    try {
      double angle = tools.calculateAngleBWUserandCellPath(
          user.cellPath[0],
          user.cellPath[1],
          user.pathobj.numCols![user.bid]![user.floor]!,
          user.theta);
      direction = tools.angleToClocks(angle, context);
      if (direction == "Straight") {
        direction = "Go Straight";
      } else {
        direction = "Turn ${direction}, and Go Straight";
      }
    } catch (e) {}
  }

  @override
  State<DirectionHeader> createState() => _DirectionHeaderState();
}

class _DirectionHeaderState extends State<DirectionHeader> {
  List<Cell> turnPoints = [];
  BLueToothClass btadapter = new BLueToothClass();
  late Timer _timer;
  String turnDirection = "";
  List<Widget> DirectionWidgetList = [];
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale = '';
  bool disposed = false;
  BluetoothScanAndroidClass bluetoothScanAndroidClass =
  BluetoothScanAndroidClass();


  Map<String, double> ShowsumMap = Map();
  int DirectionIndex = 1;
  int nextTurnIndex = 0;
  bool isSpeaking = false;
  Timer? Device_timer;
  bool isSemanticEnabled = false;
  Queue<String> beaconTracker = Queue();

  void initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  void setTTSParams(String lngcode) async {
    try {
      // print("get ios voices ${await flutterTts.getVoices}");
      if (lngcode == "hi") {
        if (Platform.isAndroid) {
          await flutterTts
              .setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
        } else {
          await flutterTts.setVoice({"name": "Lekha", "locale": "hi-IN"});
        }
      } else {
        await flutterTts
            .setVoice({"name": "en-US-language", "locale": "en-US"});
      }

      await flutterTts.stop();
      if (Platform.isAndroid) {
        await flutterTts.setSpeechRate(0.7);
      } else {
        await flutterTts.setSpeechRate(0.55);
      }

      await flutterTts.setPitch(1.0);
    } catch (e) {}
  }

  late StreamSubscription<Map<String, dynamic>> _bufferSubscription;
  void _announceDirection(String instruction) {
    final announcement = "${instruction}";
    SemanticsService.announce(announcement, TextDirection.ltr);
  }

  @override
  void initState() {
    super.initState();

    _bufferSubscription =
        BLEManager().bufferedDeviceStream.listen((bufferedData) {
          print("Received buffer: $bufferedData");
        });
    // initTts();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
    setTTSParams(_currentLocale);

    for (int i = 0; i < widget.user.pathobj.directions.length; i++) {
      direction element = widget.user.pathobj.directions[i];
      //DirectionWidgetList.add(scrollableDirection("${element.turnDirection == "Straight"?"Go Straight":"Turn ${element.turnDirection??""}, and Go Straight"}", '${((element.distanceToNextTurn??1)/UserState.stepSize).ceil()} steps', getCustomIcon(element.turnDirection!)));
    }
    // btadapter.emptyBin();
    // for (int i = 0; i < btadapter.BIN.length; i++) {
    //   if (btadapter.BIN[i]!.isNotEmpty) {
    //     btadapter.BIN[i]!.forEach((key, value) {
    //       key = "";
    //       value = 0.0;
    //     });
    //   }
    // }
    if (Platform.isAndroid) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        bluetoothScanAndroidClass.startbin();
        bluetoothScanAndroidClass.emptyBin();
        setState(() {
          bluetoothScanAndroidClass.listenToScanUpdates(SingletonFunctionController.apibeaconmap);
        });
      });
    } else if (Platform.isIOS) {
      final scannedDevices = BluetoothScanIOSClass.startScan();
    }
    setState(() {});
    //btadapter.startScanning(SingletonFunctionController.apibeaconmap);
    if (Platform.isAndroid) {
      _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
        // print("widget.user.pathobj.index");
        // print(widget.user.pathobj.index);
        if (widget.user.pathobj.index > 3 || widget.user.onConnection) {
          listenToBin();
        }
      });
    } else if (Platform.isIOS) {
      Device_timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
        try {
          listenToBin();
        } catch (e) {
          print("Error getting best device: $e");
        }
      });
    }

    btadapter.numberOfSample.clear();
    btadapter.rs.clear();
    Building.thresh = "";

    widget.getSemanticValue = "";

    if (widget.user.floor != widget.user.pathobj.destinationFloor &&
        widget.user.pathobj.connections[widget.user.bid]?[widget.user.floor] ==
            (widget.user.showcoordY * UserState.cols +
                widget.user.showcoordX)) {
      DirectionIndex = widget.user.pathobj.directions.indexWhere(
            (element) => element.turnDirection!.toLowerCase().contains("take"),
      );
      print(
          "nextturnIndexinitstate:${DirectionIndex} ${nextTurnIndex} ${widget.user.pathobj.directions.length}");
      // if (turnPoints.contains(widget.user.cellPath[widget.user.pathobj.index])) {
      //   if (DirectionIndex + 1 < widget.user.pathobj.directions.length){
      //     DirectionIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == widget.user.cellPath[widget.user.pathobj.index].node) + 1;
      //   }
      //   if (DirectionIndex >= widget.user.pathobj.directions.length) {
      //     DirectionIndex = widget.user.pathobj.directions.length - 1;
      //   }
      // }
      speak(
          convertTolng(
              "Use this ${widget.user.pathobj.accessiblePath} and go to ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} floor",
              _currentLocale,
              "",
              "",
              0,
              ""),
          _currentLocale,
          prevpause: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announceDirection(
            "Use this lift and go to ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} floor");
      });
    } else if (widget
        .user.pathobj.numCols![widget.user.bid]![widget.user.floor] !=
        null) {
      turnPoints = tools.getTurnpoints_inCell(widget.user.cellPath);
      turnPoints.add(widget.user.cellPath.last);
      turnPoints.add(widget.user.cellPath.first);

      (widget.user.cellPath.length % 2 == 0)
          ? turnPoints
          .add(widget.user.cellPath[widget.user.cellPath.length - 2])
          : turnPoints
          .add(widget.user.cellPath[widget.user.cellPath.length - 1]);
      double angle = 0.0;
      try {
        List<Cell> remainingPath =
        widget.user.cellPath.sublist(widget.user.pathobj.index + 1);
        Cell nextTurn = findNextTurn(turnPoints, remainingPath);
        widget.distance = tools.distancebetweennodes_inCell(
            nextTurn, widget.user.cellPath[widget.user.pathobj.index]);

        if (widget.user.pathobj.index < widget.user.path.length - 1) {
          angle = tools.calculateAngleBWUserandCellPath(
              widget.user.cellPath[widget.user.pathobj.index],
              widget.user.cellPath[widget.user.pathobj.index + 1],
              widget.user.pathobj.numCols![widget.user.bid]![widget.user
                  .floor]!,
              widget.user.theta);
          //
        }
      }catch(e){
        print("catch in findNextTurn ${e}");
      }
// if(widget.distance>1000){
//   widget.distance=7;
// }
      //print("angleeeeee $angle")  ;
      setState(() {
        widget.direction = tools.angleToClocks(angle, widget.context) == "None"
            ?"Straight":tools.angleToClocks(angle, widget.context);
        if (widget.direction == "Straight") {
          widget.direction = "Go Straight";
          if (!UserState.ttsOnlyTurns){
            speak(
                "${LocaleData.getProperty6('Go Straight', widget.context)} ${tools.convertFeet(widget.distance, widget.context)}}",
                _currentLocale,
                prevpause: true);
          }
        }else{
          widget.direction = convertTolng("Turn ${LocaleData.getProperty5(widget.direction, widget.context)}",
              _currentLocale,
              widget.direction,
              "",
              0,
              "");
          if (!UserState.ttsOnlyTurns){
            speak("${widget.direction}", _currentLocale, prevpause: true);
          }
          widget.getSemanticValue =
          "Turn ${widget.direction}, and Go Straight ${tools.convertFeet(widget.distance, widget.context)}";
        }
      });
    }
    try {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white // Set the icon color to dark
      ));
    } catch (e) {}
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      BluetoothScanIOSClass.stopScan();
    } else {
      bluetoothScanAndroidClass.stopScan();
    }
    Device_timer?.cancel();
    disposed = true;
    flutterTts.stop();
    _timer.cancel();
    super.dispose();
  }

  String getgetSemanticValue() {
    return widget.getSemanticValue;
  }

  double highestweight = 85.0;

  String? parseString(String input) {
    final regex = RegExp(r'Optional\("(.+?)"\)\s+(\d+\.\d+)');
    final match = regex.firstMatch(input);

    if (match != null) {
      final device = match.group(1); // Extracts "IW622"
      return device;
    } else {
      print("No match found!");
      return null;
    }
  }

  String? parseStringT(String input) {
    final regex = RegExp(r'Optional\("(.+?)"\)\s+(\d+\.\d+)');
    final match = regex.firstMatch(input);

    if (match != null) {
      final value = double.tryParse(match.group(2) ?? '0'); // Extracts 6.0 as a double
      return value.toString();
    } else {
      print("No match found!");
      return null;
    }
  }

  KeyCounter selectedBeaconCounter = KeyCounter();
  PeakValley peakValley = PeakValley(realtimeThreshold: Building.realtimeLocalisationThreshold);


  Future<bool> listenToBin({bool hardSwitch = false}) async {
    print("listenToBin called");
    String nearestBeacon = "";
    double beaconWeight = 0.0;
    if (Platform.isAndroid) {
      nearestBeacon = bluetoothScanAndroidClass.closestBeaconName;
      beaconWeight = bluetoothScanAndroidClass.closestBeaconAverage.abs();

    } else if (Platform.isIOS) {
      String receivedStringFromIOS = await BluetoothScanIOSClass.getBestDevice();
      nearestBeacon = parseString(receivedStringFromIOS) ?? "";
      beaconWeight = double.parse(parseStringT(receivedStringFromIOS)??"0.0").abs();
      beaconWeight = double.parse(parseStringT(receivedStringFromIOS)??"0.0").abs();
    }
    Map<String, List<int>> beaconData;

    if(Platform.isAndroid){
      beaconData = bluetoothScanAndroidClass.returnCurrentBeaconValue();
      print("beaconData $beaconData");
    }else{
      beaconData = await BluetoothScanIOSClass.returnCurrentBeaconValue();
      print("beaconDataIOS $beaconData");
    }

    List<int> liftCoordinates = [
      (widget.user.pathobj.connections[widget.user.bid]?[widget.user.floor] ??
          1) %
          UserState.cols,
      (widget.user.pathobj.connections[widget.user.bid]?[widget.user.floor] ??
          1) ~/
          UserState.cols
    ];

    // print("beacon from listen to bin $nearestBeacon <> $beaconWeight");

    if(hardSwitch){
      double minDistance = double.infinity;
      print("liftCoordinates $liftCoordinates\n"
          "widget.user.pathobj.destinationBid ${widget.user.pathobj.destinationBid}\n"
          "widget.user.pathobj.destinationFloor ${widget.user.pathobj.destinationFloor}");
      SingletonFunctionController.apibeaconmap.forEach((id, beacon){
        if(beacon.buildingID == widget.user.pathobj.destinationBid &&
            beacon.floor == widget.user.pathobj.destinationFloor
        ){
          double distance = tools.calculateDistance([beacon.coordinateX!, beacon.coordinateY!], liftCoordinates);
          print("Beacon ${id} is at distance $distance  --> $minDistance");
          if(distance < minDistance){
            nearestBeacon = id;
          }
        }
      });
    }

    if(beaconWeight.isNegative){
      beaconWeight = beaconWeight * -1;
    }

    if (nearestBeacon != "" && widget.user.key != SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId && widget.user.bid != buildingAllApi.outdoorID) {
      if (widget.user.floor != widget.user.pathobj.destinationFloor &&
          widget.user.pathobj.destinationFloor != widget.user.pathobj.sourceFloor &&
          widget.user.pathobj.destinationFloor == SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor) {

        List<int> beaconcoord = [
          SingletonFunctionController.apibeaconmap[nearestBeacon]!.coordinateX!,
          SingletonFunctionController.apibeaconmap[nearestBeacon]!.coordinateY!
        ];
        double distanceFromPath = 15.0;
        int? indexOnPath;

        for (var node in widget.user.cellPath) {
          if(node.floor == SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor && node.bid == SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID){
            List<int> pathcoord = [node.x, node.y];
            double distanceBetweenBeaconAndPath = tools.calculateDistance(beaconcoord, pathcoord);
            if (distanceBetweenBeaconAndPath < distanceFromPath) {
              distanceFromPath = distanceBetweenBeaconAndPath;
              indexOnPath = widget.user.cellPath.indexOf(node);
            }
          }
        }
        if (indexOnPath == null) {
          if(highestweight >= beaconWeight){
            selectedBeaconCounter.update(nearestBeacon);
            MapEntry? countEntry = selectedBeaconCounter.current();

            if(countEntry != null && countEntry.value >= 10){
              _lastAnnouncedTurnIndex=null;
              return reroute(nearestBeacon);
            }
          }
        }else {
          await speak("You have reached ${tools.numericalToAlphabetical(SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!)} floor", _currentLocale);
          await Future.delayed(Duration(seconds: 1));
          widget.user.onConnection = false;
          widget.user.key = SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId!;
          DirectionIndex = nextTurnIndex;
          widget.paint(nearestBeacon, null, render: false);
          return true;
        }

      } else if (tools.calculateDistance(liftCoordinates, [widget.user.showcoordX, widget.user.showcoordY]) < 10) {
        return false;
      } else if (!widget.user.onConnection &&
          widget.user.floor == SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor) {
        print("nearestBeaon $nearestBeacon highestweight $beaconWeight");
        List<double> beaconcoord = [double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!), double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!)];
        double distanceFromPath = 5;
        int? indexOnPath;

        // var cell = widget.user.snapper.snapToPathKalman(null, double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!), double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!), widget.user.pathobj.index, widget.user.cellPath);

        for (var node in widget.user.cellPath) {
          if(node.floor == SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor && node.bid == SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID){
            List<double> pathcoord = [node.lat, node.lng];
            double distanceBetweenBeaconAndPath = tools.calculateAerialDist(beaconcoord[0], beaconcoord[1], pathcoord[0], pathcoord[1]);
            if (distanceBetweenBeaconAndPath < distanceFromPath) {
              distanceFromPath = distanceBetweenBeaconAndPath;
              print("point for on path for $nearestBeacon is ${node.x}, ${node.y}");
              indexOnPath = widget.user.cellPath.indexOf(node);
            }
          }
        }

        print("indexOnPath for $nearestBeacon is $indexOnPath");

        if (indexOnPath == null) {
          if(highestweight >= beaconWeight){
            selectedBeaconCounter.update(nearestBeacon);
            MapEntry? countEntry = selectedBeaconCounter.current();

            if(countEntry != null && countEntry.value >= 10){
              _lastAnnouncedTurnIndex=null;
              return reroute(nearestBeacon);
            }
          }
        } else {
          selectedBeaconCounter.update(nearestBeacon);
          MapEntry<String, int>? result = peakValley.processBeaconPerSecond(beaconData);
          if(result != null){
            relocalize(indexOnPath, result.value, result.key);
          }
        }
      }
    }

    return false;
  }

  bool reroute(String nearestBeacon){
    print("listentoBin debug reroute on $nearestBeacon \n"
        "${StackTrace.current}");
    widget.repaint(nearestBeacon);
    widget.reroute;
    DirectionIndex = 1;
    nextTurnIndex = 1;
    return false;
  }

  bool relocalize(int index, int stepsToBeMoved, String nearestBeacon){
    print("listentoBin debug relocalize on $nearestBeacon $index $stepsToBeMoved\n"
        "${StackTrace.current}");
    widget.user.key = SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId!;
    widget.user.moveToPointOnPath(index, context);
    if(SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID != buildingAllApi.outdoorID){
      widget.user.moveToPointOnPathOnPath(context, stepsToBeMoved);
    }
    widget.moveUser();
    DirectionIndex = nextTurnIndex;
    return true;
  }


  void analyzeThresholdDrop(
      Map<DateTime, Map<String, String>> data, String beaconId) {
    print("analyzeThresholdDrop ${data}");
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // Sort by time

    DateTime? maxTime;
    double maxThreshold = double.negativeInfinity;

    // Step 1: Find max threshold and when it occurred
    for (var entry in sortedEntries) {
      final thresholdStr = entry.value[beaconId];
      if (thresholdStr == null) continue;

      final threshold = double.tryParse(thresholdStr);
      if (threshold == null) continue;

      if (threshold > maxThreshold) {
        maxThreshold = threshold;
        maxTime = entry.key;
      }
    }

    if (maxTime == null) {
      print("No valid threshold found for $beaconId");
      return;
    }

    // Step 2: Find first drop after max time
    DateTime? dropTime;
    for (var entry in sortedEntries) {
      if (entry.key.isAfter(maxTime)) {
        final thresholdStr = entry.value[beaconId];
        if (thresholdStr == null) continue;

        final threshold = double.tryParse(thresholdStr);
        if (threshold == null) continue;

        if (threshold < maxThreshold) {
          dropTime = entry.key;
          break;
        }
      }
    }

    // Step 3: Compute time difference
    if (dropTime != null) {
      final duration = dropTime.difference(maxTime);
      HelperClass.showToast(
          "Beacon $beaconId had max threshold $maxThreshold at $maxTime and dropped at $dropTime");
      print(
          "Beacon $beaconId had max threshold $maxThreshold at $maxTime and dropped at $dropTime");
      print("Time difference: ${duration.inMinutes} minutes");
    } else {
      HelperClass.showToast(
          "Beacon $beaconId had no drop after reaching max threshold at $maxTime");

      print(
          "Beacon $beaconId had no drop after reaching max threshold at $maxTime");
    }
  }

  void setEssentialsForReroute(String nearestBeacon) {
    _timer.cancel();
    widget.repaint(nearestBeacon);
    widget.reroute;
    DirectionIndex = 1;
    nextTurnIndex = 1;
  }

  void reacedDestinationEssentials(String nearestBeacon) {
    widget.user.onConnection = false;
    widget.user.key = SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId!;
    UserState.createCircle(widget.user.lat, widget.user.lng);
    speak(
        "You have reached ${tools.numericalToAlphabetical(SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!)} floor",
        _currentLocale);
    DirectionIndex = nextTurnIndex;
    //need to render on beacon for aiims jammu
    widget.paint(nearestBeacon, null, render: false);
  }

  void moveOnPathEssentials(String nearestBeacon, int? indexOnPath) {
    widget.user.key = SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId!;
    if (!UserState.ttsOnlyTurns) {
      speak(
          "${widget.direction} ${tools.convertFeet(widget.distance, widget.context)}",
          _currentLocale);
    }
    widget.user.moveToPointOnPath(indexOnPath!, context);
    widget.moveUser();
    DirectionIndex = nextTurnIndex;
  }

  int insertProjectedPointInIntList(
      List<int> path, int projectedPoint, int numCols) {
    // Helper function to compute x, y for a given element
    List<int> getXY(int element) {
      int x = element % numCols;
      int y = element ~/ numCols;
      return [x, y];
    }

    // Calculate x, y for the projected point
    List<int> projectedXY = getXY(projectedPoint);

    // Find the index to insert the projected point
    int indexToInsert = path.indexWhere((element) {
      List<int> elementXY = getXY(element);

      // Compare first by x, then by y if x is the same
      return (elementXY[0] > projectedXY[0]) ||
          (elementXY[0] == projectedXY[0] && elementXY[1] > projectedXY[1]);
    });

    return indexToInsert;
  }

  int insertProjectedPoint(List<Cell> path, Cell projectedPoint) {
    // Find the index of the next greater point
    int indexToInsert = path.indexWhere((cell) {
      // Compare by some criterion; here we're using the `x` coordinate
      return (cell.x > projectedPoint.x) ||
          (cell.x == projectedPoint.x && cell.y > projectedPoint.y);
    });

    return indexToInsert;
  }

  List<Cell> findTwoNearestPoints(
      List<double> beaconcoord, List<Cell> turnPoints, String userbid) {
    // Sort the list of turn points by distance to the beacon
    print("turnPoints[0].x ${turnPoints.length} ${turnPoints[0].x}");
    List<Cell> filteredPoints = turnPoints
        .where((point) => (point.bid == userbid && point.imaginedCell == false))
        .toList();
    print(
        "filteredPoints[0].x ${filteredPoints.length} ${filteredPoints[0].x}");

    filteredPoints.sort((a, b) => tools
        .calculateAerialDist(beaconcoord[0], beaconcoord[1], a.lat, a.lng)
        .compareTo(tools.calculateAerialDist(
        beaconcoord[0], beaconcoord[1], b.lat, b.lng)));
    print(
        "filteredPoints[0].x ${filteredPoints.length} ${filteredPoints[0].x}");
    // Return the first two points in the sorted list
    return [filteredPoints[0], filteredPoints[1]];
  }

  List<double> projectCellOntoSegment(
      List<double> beaconLatLng, Cell a, Cell b, int numCols) {
    // Vector AB (lat/lng)
    double abLat = b.lat - a.lat;
    double abLng = b.lng - a.lng;
    // Vector AP (lat/lng)
    double apLat = beaconLatLng[0] - a.lat;
    double apLng = beaconLatLng[1] - a.lng;
    // Dot products
    double abDotAb = abLat * abLat + abLng * abLng;
    double apDotAb = apLat * abLat + apLng * abLng;

    // Projection scalar t
    double t = apDotAb / abDotAb;

    // Clamp t to stay within the segment [0, 1]
    t = t.clamp(0.0, 1.0);

    // Projected point P' on the line segment
    double projLat = a.lat + t * abLat;
    double projLng = a.lng + t * abLng;

    // Convert projected lat/lng back to x/y for the Cell object

    return [projLat, projLng];
  }

  FlutterTts flutterTts = FlutterTts();
  List<String> _ttsQueue = [];
  bool _isSpeaking = false;

  Future<void> speak(String msg, String lngcode, {bool prevpause = false}) async {
    final stackTrace = StackTrace.current;
    print("speak Stack: \n$stackTrace");
    print("checkspeak");
    if (!UserState.ttsAllStop) {
      if (disposed) return;
      if (false) {
        await flutterTts.pause();
      }
      try {
        // Check if Semantic Mode is enabled
        if (isSemanticEnabled) {
          // PushNotifications.showSimpleNotification(body: "", payload: "", title: msg);
        } else {
          await flutterTts.speak(msg);
        }
      } catch (e) {
        print("Error during TTS: $e");
      }
    }
  }

  Cell findNextTurn(List<Cell> turns, List<Cell> path) {
    // Iterate through the sorted list
    for (int i = 0; i < path.length; i++) {
      for (int j = 0; j < turns.length; j++) {
        if (path[i] == turns[j]) {
          return path[i];
        }
      }
    }

    // If no number is greater than the target, return null
    if (path.length >= widget.user.pathobj.index) {
      return path[widget.user.pathobj.index];
    } else {
      return Cell(
          0,
          0,
          0,
              (double angle, {int? currPointer, int? totalCells}) {},
          0.0,
          0.0,
          "",
          0,
          0);
    }
  }

  Cell findPrevTurn(List<Cell> turns, List<Cell> path, int index) {
    int? prevTurn;
    // Iterate through the sorted list
    for (int i = index; i >= 0; i--) {
      for (int j = 0; j < turns.length; j++) {
        if (path[i].x == turns[j].x && path[i].y == turns[j].y) {
          prevTurn = i;
          if (prevTurn > 0) {
            return path[prevTurn - 1];
          } else {
            return path[prevTurn];
          }
        }
      }
    }

    // If no number is greater than the target, return null
    if (path.length >= widget.user.pathobj.index) {
      return path[widget.user.pathobj.index];
    } else {
      return Cell(
          0,
          0,
          0,
              (double angle, {int? currPointer, int? totalCells}) {},
          0.0,
          0.0,
          "",
          0,
          0);
    }
  }

  String convertTolng(String msg, String lngcode, String direction,
      String direc, int nextTurn, String nearestBeacon) {
    if (msg == "Turn ${direction}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(direction, widget.context)} मुड़ें";
      }
    } else if (msg ==
        "Use this lift and go to ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} floor") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "इस लिफ़्ट का उपयोग करें और ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} मंज़िल पर जाएँ";
      }
    } else if ((widget.user.pathobj.associateTurnWithLandmark[nextTurn] !=
        null &&
        widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name !=
            null) &&
        msg ==
            "Take next ${direc} from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!} से ${LocaleData.getProperty5(direc, widget.context)} मोड़ के करीब पहुंच रहे हैं।";
      }
    } else if (msg == "Take next ${direc}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${LocaleData.getProperty5(direc, widget.context)} मोड़ के करीब पहुंच रहे हैं";
      }
    } else if (msg ==
        "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}, and ${LocaleData.getProperty6('Go Straight', widget.context)} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(widget.direction, widget.context)} मुड़ें और सीधे ${(widget.distance / UserState.stepSize).ceil()} कदम चलें";
      }
    } else if (SingletonFunctionController.apibeaconmap[nearestBeacon] != null &&
        msg ==
            "You have reached ${tools.numericalToAlphabetical(SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!)} floor") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!)} मंजिल पर पहुंच गए हैं";
      }
    } else if (msg ==
        "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(widget.direction, widget.context)} मुड़ें";
      }
    } else if (msg == "Turn ${direction}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(direction, widget.context)} मुड़ें";
      }
    } else if (msg ==
        "You have reached ${widget.user.pathobj.destinationName}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${widget.user.pathobj.destinationName} पर पहुँच गए हैं।";
      }
    }
    return msg;
  }

  // Timer? _speakTimer;
  // bool _turnSpoken = true;
  Map<Cell, String> takeNextInstruction = {};
  Map<int, bool> turnInstruction = {};
  bool isTalkBackOn() {
    return SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;
  }

  int? _lastAnnouncedTurnIndex;
  @override
  void didUpdateWidget(DirectionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user.floor == widget.user.pathobj.sourceFloor &&
        widget.user.pathobj.connections.isNotEmpty &&
        widget.user.showcoordY * UserState.cols + widget.user.showcoordX ==
            widget.user.pathobj.connections[widget.user.bid]
            ?[widget.user.pathobj.sourceFloor]) {
    } else if (widget.user.path.isNotEmpty &&
        widget.user.cellPath.length - 1 > widget.user.pathobj.index) {
      // print("nextturnIndex:${DirectionIndex} ${nextTurnIndex} ${widget.user.pathobj.directions[DirectionIndex].turnDirection} ${widget.user.pathobj.directions[nextTurnIndex].turnDirection} ${widget.user.pathobj.directions.length}");
      widget.user.pathobj.connections.forEach((key, value) {
        value.forEach((inkey, invalue) {
          if (widget.user.path[widget.user.pathobj.index] == invalue) {
            widget.direction = "You have reached ";
          }
        });
      });
      List<Cell> remainingPath =
      widget.user.cellPath.sublist(widget.user.pathobj.index + 1);
      Cell nextTurn = findNextTurn(turnPoints, remainingPath);
      Cell prevTurn = findPrevTurn(
          turnPoints, widget.user.cellPath, widget.user.pathobj.index);
      nextTurnIndex = widget.user.pathobj.directions
          .indexWhere((element) => element.node == nextTurn.node);

      if (turnPoints
          .contains(widget.user.cellPath[widget.user.pathobj.index])) {
        if (DirectionIndex + 1 < widget.user.pathobj.directions.length) {
          DirectionIndex = widget.user.pathobj.directions.indexWhere(
                  (element) =>
              element.node ==
                  widget.user.cellPath[widget.user.pathobj.index].node) +
              1;
        }
        if (DirectionIndex >= widget.user.pathobj.directions.length) {
          DirectionIndex = widget.user.pathobj.directions.length - 1;
        }
      }
      // print("DirectionIndex:${DirectionIndex} ${nextTurnIndex} ${widget.user.pathobj.directions[nextTurnIndex].turnDirection}");
      widget.distance = tools.distancebetweennodes_inCell(
          nextTurn, widget.user.cellPath[widget.user.pathobj.index]);
      double angle = 0.0;
      try {
        angle = tools.calculateAnglefifth(
            widget.user.cellPath[widget.user.pathobj.index].node,
            widget.user.cellPath[widget.user.pathobj.index + 1].node,
            widget.user.cellPath[widget.user.pathobj.index + 2].node,
            widget.user.pathobj.numCols![widget.user.bid]![widget.user.floor]!);
      } catch (e) {
        print("error to be solved later $e");
      }
      if (widget.user.pathobj.index != 0) {
        try {
          angle = tools.calculateAnglefifth(
              widget.user.cellPath[widget.user.pathobj.index - 1].node,
              widget.user.cellPath[widget.user.pathobj.index].node,
              widget.user.cellPath[widget.user.pathobj.index + 1].node,
              widget
                  .user.pathobj.numCols![widget.user.bid]![widget.user.floor]!);
        } catch (e) {
          print("problem to be solved later $e");
        }
      }
      double userangle = tools.calculateAngleBWUserandCellPath(
          widget.user.cellPath[widget.user.pathobj.index],
          widget.user.cellPath[widget.user.pathobj.index + 1],
          widget.user.pathobj.numCols![widget.user.bid]![widget.user.floor]!,
          widget.user.theta);

      widget.direction = (tools.angleToClocks(angle, widget.context) == "None")
          ? oldWidget.direction
          : tools.angleToClocks(userangle, widget.context);
      String userdirection =
      (tools.angleToClocks(userangle, widget.context) == "None")
          ? oldWidget.direction
          : tools.angleToClocks(userangle, widget.context);

      if (userdirection == "Straight") {
        widget.direction = "Straight";
      }

      if (widget.user.pathobj.index < 3) {
        widget.direction = userdirection;
      }

      if (UserCredentials().getUserPersonWithDisability() == 1 ||
          UserCredentials().getUserPersonWithDisability() == 2) {
        widget.direction = userdirection;
      }
      int turnIndex = widget.user.cellPath.indexOf(nextTurn);
      double a = 0;
      try {
        if (turnIndex + 1 >= widget.user.path.length) {
          if (widget.user.cellPath[turnIndex - 2].bid ==
              widget.user.cellPath[turnIndex - 1].bid &&
              widget.user.cellPath[turnIndex - 1].bid ==
                  widget.user.cellPath[turnIndex].bid) {
            a = tools.calculateAnglefifth(
                widget.user.path[turnIndex - 2],
                widget.user.path[turnIndex - 1],
                widget.user.path[turnIndex],
                widget
                    .user.pathobj.numCols![widget.user.bid]![widget.user
                    .floor]!);
          }
        }
        else {
          if (turnIndex > 1 &&
              widget.user.cellPath[turnIndex - 1].bid ==
                  widget.user.cellPath[turnIndex].bid &&
              widget.user.cellPath[turnIndex].bid ==
                  widget.user.cellPath[turnIndex + 1].bid) {
            a = tools.calculateAnglefifth(
                widget.user.path[turnIndex - 1],
                widget.user.path[turnIndex],
                widget.user.path[turnIndex + 1],
                widget
                    .user.pathobj.numCols![widget.user.bid]![widget.user
                    .floor]!);
          }
        }
      }catch(e){
        print("direction header turnIndex ${e}");
      }

      String direc = tools.angleToClocks(a,
          widget.context); //giving error when turning left it says U turn = XXX
      // String direc = userdirection;
      turnDirection = direc;

      if(widget.direction=='None' || widget.direction=='on your None')
      {
        widget.direction=oldWidget.direction;
      }

      if (takeNextInstruction[nextTurn] != null) {
        direc = takeNextInstruction[nextTurn]!;
        widget.direction = takeNextInstruction[nextTurn]!;
      }
      // if(widget.distance>1000){
      //   widget.distance=7;
      // }

      // int prevD = tools.calculateDistance([prevTurn.x, prevTurn.y], [widget.user.cellPath[widget.user.pathobj.index].x, widget.user.cellPath[widget.user.pathobj.index].y]).toInt();
      // if(prevD>=6 && prevD<=7 && !isTalkBackOn()){
      //   Vibration.vibrate();
      //   widget.user.move(widget.context);
      //     speak(
      //       "${LocaleData.getProperty6('Go Straight', context)} ${tools.convertFeet(widget.distance, context)}",
      //       _currentLocale,
      //       prevpause: true,
      //     );
      // }
      try {
        Cell prevCell = widget.user.cellPath[widget.user.pathobj.index - 1];
        Cell nextCell = widget.user.cellPath[widget.user.pathobj.index + 1];
        if (prevCell.x == widget.user.cellPath[widget.user.pathobj.index].x &&
            prevCell.y == widget.user.cellPath[widget.user.pathobj.index].y) {
          prevCell = widget.user.cellPath[widget.user.pathobj.index - 2];
        }
        if (nextCell.x == widget.user.cellPath[widget.user.pathobj.index].x &&
            nextCell.y == widget.user.cellPath[widget.user.pathobj.index].y) {
          nextCell = widget.user.cellPath[widget.user.pathobj.index + 2];
        }
        // Check if turn is detected AND we haven't announced for this index yet
        if (widget.user.isTurnCheck(prevCell, nextCell) &&
            _lastAnnouncedTurnIndex != widget.user.pathobj.index){
          _lastAnnouncedTurnIndex = widget.user.pathobj.index;
          // print("_lastAnnouncedTurnIndex:${!widget.direction.contains('Take next')} ${widget.distance != 0}");// Mark as announced
          if (widget.distance != 0 && !widget.direction.contains('Take next') && !widget.direction.toLowerCase().contains('take')) {
            // print("turn check bro:${widget.user.isTurnCheck(prevCell, nextCell)} ${widget.direction} ${widget.distance}");
            WidgetsBinding.instance.addPostFrameCallback((_){
              _announceDirection('Turn ${LocaleData.getProperty5(widget.direction, context)} and Go Straight ${tools.convertFeet(widget.distance, context)}');
            });
          }else if(widget.direction.toLowerCase()=='Straight'.toLowerCase() || widget.direction.toLowerCase()=='Go Straight'.toLowerCase()){
            WidgetsBinding.instance.addPostFrameCallback((_){
              _announceDirection('Go Straight ${tools.convertFeet(widget.distance, context)}');
            });
          }
          return;
        }
      } catch (e) {
        // print("Error in turn announcement: $e"); // At least log the error
      }
      // print("widget.direction ${widget.direction}");
      // print("entereddd ${oldWidget.direction} ${widget.direction} ${turnInstruction[prevTurn]} ${prevTurn.node}");
      if((turnInstruction[prevTurn.node] == null || turnInstruction[prevTurn.node] == false) && !widget.direction.toLowerCase().contains("next")){
        print("inside force");
        turnInstruction[prevTurn.node] = true;
        Vibration.vibrate();
        if(widget.direction == "Straight"){
          speak(
            "${LocaleData.getProperty6('Go Straight', context)} ${tools.convertFeet(widget.distance, context)}",
            _currentLocale,
            prevpause: true,
          );
        }else{
          speak(
              convertTolng(
                  "Turn ${LocaleData.getProperty5(widget.direction, context)}",
                  _currentLocale,
                  widget.direction,
                  "",
                  0,
                  ""),
              _currentLocale,
              prevpause: true);
        }
      }

      if (oldWidget.direction != widget.direction && !widget.direction.toLowerCase().contains("next")) {
        if(!widget.direction.toLowerCase().contains("next")){
          print("entered in first ${oldWidget.direction} ${widget.direction}");
          if (oldWidget.direction == "Straight") {
            // _speakTimer?.cancel(); // Cancel any previous timer
            // _turnSpoken = false; // Reset flag
            if (turnPoints
                .contains(widget.user.cellPath[widget.user.pathobj.index])) {
              print("widget.direction ${widget.direction}");
              Vibration.vibrate();
              speak(
                  convertTolng(
                      "Turn ${LocaleData.getProperty5(widget.direction, context)}",
                      _currentLocale,
                      widget.direction,
                      "",
                      0,
                      ""),
                  _currentLocale,
                  prevpause: true);
            } else {
              if (widget.direction.toLowerCase().contains("slight") && !isTalkBackOn()) {
                widget.direction = "Straight";
                return;
              }
              // _speakTimer = Timer(Duration(seconds: 2), () {
              //   if (mounted && oldWidget.direction == widget.direction) {
              //     return; // Direction changed back, do not proceed
              //   }
              //   _turnSpoken = true; // Mark that turn instruction was spoken

              Vibration.vibrate();
              speak(
                  convertTolng(
                      "Turn ${LocaleData.getProperty5(widget.direction, context)}",
                      _currentLocale,
                      widget.direction,
                      "",
                      0,
                      ""),
                  _currentLocale,
                  prevpause: true);
              // });
            }
          } else if (widget.direction == "Straight") {
            print(
                "!turnPoints.contains(widget.user.cellPath[widget.user.pathobj.index])  ${!turnPoints.contains(widget.user.cellPath[widget.user.pathobj.index])} _turnSpoken");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _announceDirection(
                  '${LocaleData.getProperty6('Go Straight', context)}');
            });
            if (!turnPoints
                .contains(widget.user.cellPath[widget.user.pathobj.index])){
              print("returning due to turn");
              return; // Skip "Straight" if "Turn" was never spoken
            }
            Vibration.vibrate();
            UserState.isTurn = false;
            // if (!UserState.ttsOnlyTurns) {
            speak(
              "${LocaleData.getProperty6('Go Straight', context)} ${tools.convertFeet(widget.distance, context)}",
              _currentLocale,
              prevpause: true,
            );
            // }
          } else if (oldWidget.direction.toLowerCase().contains("next")) {
            Vibration.vibrate();
            speak(
                convertTolng(
                    "Turn ${LocaleData.getProperty5(widget.direction, context)}",
                    _currentLocale,
                    widget.direction,
                    "",
                    0,
                    ""),
                _currentLocale,
                prevpause: true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _announceDirection(
                  '${LocaleData.getProperty6('Go Straight', context)}');
            });
          }
        }else{
          if(widget.direction == "Straight"){
            Vibration.vibrate();
            speak(
              "${LocaleData.getProperty6('Go Straight', context)} ${tools.convertFeet(widget.distance, context)}",
              _currentLocale,
              prevpause: true,
            );
          }
        }
      }
      try {
        double takeNextInstructionDistance = 15;
        if(widget.user.bid != buildingAllApi.outdoorID){
          takeNextInstructionDistance = 10;
        }
        if (!direc.toLowerCase().contains("next")) {
          if (turnPoints.isNotEmpty &&
              nextTurn == turnPoints.last &&
              widget.distance == 7) {
            double angle = 0.0;
            try {
              angle = tools.calculateAngleThird(
                  [
                    widget.user.pathobj.destinationX,
                    widget.user.pathobj.destinationY
                  ],
                  widget.user.path[widget.user.pathobj.index + 1],
                  widget.user.path[widget.user.pathobj.index + 2],
                  widget.user.pathobj
                      .numCols![widget.user.bid]![widget.user.floor]!);
            } catch (e) {
              print("problem to be solved later $e");
            }
            if (!UserState.ttsOnlyTurns) {
              speak(
                  "${widget.direction} ${widget.distance} steps. ${widget.user.pathobj.destinationName} will be ${tools.angleToClocks2(angle, widget.context)}",
                  _currentLocale);
            }
            widget.user.move(context);
          } else if (turnPoints.isNotEmpty &&
              nextTurn != turnPoints.last &&
              widget.user.pathobj.connections[widget.user.bid]
              ?[widget.user.floor] !=
                  nextTurn.node &&

              ((widget.distance / UserState.stepSize).ceil() == takeNextInstructionDistance)) {
            // print("!direc.toLowerCase().contains ${!direc.toLowerCase().contains("slight")} ,${!direc.toLowerCase().contains("straight")} widget.user.pathobj.index ${widget.user.pathobj.index}  ${widget.user.pathobj.associateTurnWithLandmark[nextTurn.node]} ${[nextTurn]}");
            if ((!direc.toLowerCase().contains("slight") &&
                !direc.toLowerCase().contains("straight")) &&
                widget.user.pathobj.index > 4) {

              if (widget.user.pathobj.associateTurnWithLandmark[nextTurn.node] != null) {
                takeNextInstruction[nextTurn] = convertTolng(
                    "Take next ${direc} from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn.node]!.name!}",
                    _currentLocale,
                    '',
                    direc,
                    nextTurn!.node,
                    "");
                speak(
                    convertTolng(
                        "Take next ${direc} from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn.node]!.name!}",
                        _currentLocale,
                        '',
                        direc,
                        nextTurn!.node,
                        ""),
                    _currentLocale);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _announceDirection(
                      "Take next ${direc} from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn.node]!.name!}");
                });

                return;
                //widget.user.pathobj.associateTurnWithLandmark.remove(nextTurn);
              } else {
                takeNextInstruction[nextTurn] = convertTolng(
                    "Take next ${direc}",
                    _currentLocale,
                    '',
                    direc,
                    nextTurn!.node,
                    "");
                speak(
                    convertTolng("Take next ${direc}", _currentLocale, '',
                        direc, nextTurn!.node, ""),
                    _currentLocale);
                widget.user.move(widget.context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _announceDirection("Take next ${direc}");
                });
                return;
              }
            }
          }
        }
      } catch (e) {
        print("catch in turnpoints:${e}");
      }
    }
  }

  bool _isAtSourceConnection(UserState user) {
    final pathObj = user.pathobj;
    return user.floor == pathObj.sourceFloor &&
        pathObj.connections.isNotEmpty &&
        user.showcoordY * UserState.cols + user.showcoordX ==
            pathObj.connections[user.bid]?[pathObj.sourceFloor];
  }

  void _updateDirectionOnPath(DirectionHeader oldWidget, UserState user) {
    user.pathobj.connections.forEach((key, value) {
      value.forEach((inkey, invalue) {
        if (user.path[user.pathobj.index] == invalue) {
          widget.direction = "You have reached ";
        }
      });
    });
  }

  void _updateDirectionIndexOnTurn(UserState user) {
    if (turnPoints.contains(user.cellPath[user.pathobj.index])) {
      final currentIndex = user.pathobj.directions.indexWhere(
              (element) => element.node == user.cellPath[user.pathobj.index].node);
      if (currentIndex + 1 < user.pathobj.directions.length) {
        DirectionIndex = currentIndex + 1;
      }
      if (DirectionIndex >= user.pathobj.directions.length) {
        DirectionIndex = user.pathobj.directions.length - 1;
      }
    }
  }

  double _calculateAngle(UserState user) {
    final pathObj = user.pathobj;
    final cellPath = user.cellPath;
    final currentbid = user.bid;
    final currentFloor = user.floor;
    double angle = 0.0;
    try {
      angle = tools.calculateAnglefifth(
          cellPath[pathObj.index].node,
          cellPath[pathObj.index + 1].node,
          cellPath[pathObj.index + 2].node,
          pathObj.numCols![currentbid]![currentFloor]!);
    } catch (e) {
      print("error to be solved later $e");
    }
    if (pathObj.index != 0) {
      try {
        angle = tools.calculateAnglefifth(
            cellPath[pathObj.index - 1].node,
            cellPath[pathObj.index].node,
            cellPath[pathObj.index + 1].node,
            pathObj.numCols![currentbid]![currentFloor]!);
      } catch (e) {
        print("problem to be solved later $e");
      }
    }
    return angle;
  }

  String _calculateTurnDirection(
      UserState user, int turnIndex, String userDirection) {
    final pathObj = user.pathobj;
    final cellPath = user.cellPath;
    final currentbid = user.bid;
    final currentFloor = user.floor;
    double a = 0;
    if (turnIndex + 1 == user.path.length) {
      if (cellPath[turnIndex - 2].bid == cellPath[turnIndex - 1].bid &&
          cellPath[turnIndex - 1].bid == cellPath[turnIndex].bid) {
        a = tools.calculateAnglefifth(
            user.path[turnIndex - 2],
            user.path[turnIndex - 1],
            user.path[turnIndex],
            pathObj.numCols![currentbid]![currentFloor]!);
      }
    } else {
      try {
        if (cellPath[turnIndex - 1].bid == cellPath[turnIndex].bid &&
            cellPath[turnIndex].bid == cellPath[turnIndex + 1].bid) {
          a = tools.calculateAnglefifth(
              user.path[turnIndex - 1],
              user.path[turnIndex],
              user.path[turnIndex + 1],
              pathObj.numCols![currentbid]![currentFloor]!);
        }
      } catch (e) {
        print("error in direction header:${e}");
      }
    }
    return userDirection; // Directly using userDirection as it's already calculated
  }

  void _handleDirectionChange(DirectionHeader oldWidget) {
    if (oldWidget.direction != widget.direction) {
      if (oldWidget.direction == "Straight") {
        Vibration.vibrate();
        speak(
            convertTolng(
                "Turn ${LocaleData.getProperty5(widget.direction, context)}",
                _currentLocale,
                widget.direction,
                "",
                0,
                ""),
            _currentLocale,
            prevpause: true);
      } else if (widget.direction == "Straight") {
        Vibration.vibrate();
        UserState.isTurn = false;
        if (!UserState.ttsOnlyTurns) {
          speak(
              "${LocaleData.getProperty6('Go Straight', context)} ${tools.convertFeet(widget.distance, context)}}",
              _currentLocale,
              prevpause: true);
        }
      }
    }
  }

  void _handleApproachingDestinationOrTurn(Cell nextTurn, UserState user) {
    final pathObj = user.pathobj;
    final currentbid = user.bid;
    final currentFloor = user.floor;
    try {
      if (nextTurn == turnPoints.last && widget.distance == 7) {
        double angle = 0.0;
        try {
          angle = tools.calculateAngleThird(
              [pathObj.destinationX, pathObj.destinationY],
              user.path[pathObj.index + 1],
              user.path[pathObj.index + 2],
              pathObj.numCols![currentbid]![currentFloor]!);
        } catch (e) {
          print("problem to be solved later $e");
        }
        if (!UserState.ttsOnlyTurns) {
          speak(
              "${widget.direction} ${widget.distance} steps. ${pathObj.destinationName} will be ${tools.angleToClocks2(angle, widget.context)}",
              _currentLocale);
        }
        user.move(context);
      } else if (nextTurn != turnPoints.last &&
          pathObj.connections[currentbid]?[currentFloor] != nextTurn &&
          (widget.distance / UserState.stepSize).ceil() == 7) {
        final turnDirectionLower = turnDirection.toLowerCase();
        if (!turnDirectionLower.contains("slight") &&
            !turnDirectionLower.contains("straight") &&
            pathObj.index > 4) {
          final landmark = pathObj.associateTurnWithLandmark[nextTurn];
          if (landmark != null) {
            if (!UserState.ttsOnlyTurns) {
              speak(
                  convertTolng(
                      "You are approaching ${turnDirection} turn from ${landmark.name!}",
                      _currentLocale,
                      '',
                      turnDirection,
                      nextTurn!.node,
                      ""),
                  _currentLocale);
            }
            return;
          } else {
            if (!UserState.ttsOnlyTurns) {
              speak(
                  convertTolng("You are approaching ${turnDirection} turn",
                      _currentLocale, '', turnDirection, nextTurn!.node, ""),
                  _currentLocale);
            }
            user.move(widget.context);
            return;
          }
        }
      }
    } catch (e) {}
  }

  static Icon? getCustomIcon(String direction) {
    if (direction.toLowerCase().contains("lift")) {
      return Icon(
        Icons.elevator,
        color: Color(0xff01544f),
        size: 32,
      );
    } else if (direction.toLowerCase().contains("stair")) {
      return Icon(
        Icons.stairs,
        color: Color(0xff01544f),
        size: 23,
      );
    } else if (direction == "Straight") {
      return Icon(
        Icons.straight,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Slight Right") {
      return Icon(
        Icons.turn_slight_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Right") {
      return Icon(
        Icons.turn_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Sharp Right") {
      return Icon(
        Icons.turn_sharp_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "U Turn") {
      return Icon(
        Icons.u_turn_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Sharp Left") {
      return Icon(
        Icons.turn_sharp_left,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Left") {
      return Icon(
        Icons.turn_left,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Slight Left") {
      return Icon(
        Icons.turn_slight_left,
        color: Color(0xff01544f),
        size: 40,
      );
    } else {
      return null;
    }
  }

  Icon getNextCustomIcon(String direction) {
    if (direction.toLowerCase().contains("lift")) {
      return Icon(
        Icons.elevator,
        color: Colors.white,
        size: 23,
      );
    } else if (direction.toLowerCase().contains("stair")) {
      return Icon(
        Icons.stairs_rounded,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Straight") {
      return Icon(
        Icons.straight,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Slight Right") {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Right") {
      return Icon(
        Icons.turn_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Sharp Right") {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "U Turn") {
      return Icon(
        Icons.u_turn_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Sharp Left") {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Left") {
      return Icon(
        Icons.turn_left,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Slight Left") {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.white,
        size: 23,
      );
    } else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.white,
        size: 23,
      );
    }
  }

  Color getColor() {
    try {
      if (widget.user.pathobj.directions.isNotEmpty) {
        if (DirectionIndex < widget.user.pathobj.directions.length &&
            widget.user.pathobj.directions[DirectionIndex].isDestination) {
          return Colors.blue;
        } else {
          if (DirectionIndex == nextTurnIndex) {
            return Color(0xff01544f);
          } else {
            return Color(0xff01544f);
          }
        }
      } else {
        return Color(0xff01544f);
      }
    } catch (e) {
      return Color(0xff01544f);
    }
  }

  final Map<int, Map<String, double>> bin = {
    1: {'key1': 1.1, 'key2': 2.2},
    2: {'keyA': 3.3, 'keyB': 4.4},
  };

  @override
  Widget build(BuildContext context) {
    isSemanticEnabled = MediaQuery.of(context).accessibleNavigation;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    // String binString = btadapter.BIN.entries.map((entry) {
    //   int key = entry.key;
    //   Map<String, double> valueMap = entry.value;widget
    //   String valueString = valueMap.entries.map((e) {
    //     return '${e.key}: ${e.value}';
    //   }).join(', ');
    //   return 'BIN[$key]: {$valueString}';
    // }).join('\n');
    setState(() {});
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight),
      child: Semantics(
        excludeSemantics: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              margin: EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff01544f).withOpacity(0.4),
                      spreadRadius: 5, // How wide the shadow should be
                      blurRadius: 7, // How soft the shadow should be
                      offset: Offset(0, 3),
                    )
                  ],
                  color: getColor()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 44,
                      height: 44,
                      child: IconButton(
                          onPressed: () {
                            // setState(() {
                            //   if (DirectionIndex - 1 >= 1) {
                            //     DirectionIndex--;
                            //     widget.focusOnTurn(widget
                            //         .user.pathobj.directions[DirectionIndex]);
                            //     if (DirectionIndex == nextTurnIndex) {
                            //       widget.clearFocusTurnArrow();
                            //     }
                            //   }
                            // });
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.grey,
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  scrollableDirection(
                      "${widget.direction}",
                      '${tools.convertFeet(widget.distance, widget.context)}',
                      getCustomIcon(widget.direction),
                      DirectionIndex,
                      DirectionIndex,
                      widget.user.pathobj.directions,
                      widget.user,
                      widget.context),
                  const SizedBox(
                    width: 8,
                  ),
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 44,
                      height: 44,
                      child: IconButton(
                          onPressed: () {
                            // setState(() {
                            //   if (DirectionIndex + 1 <
                            //       widget.user.pathobj.directions.length) {
                            //     DirectionIndex++;
                            //     widget.focusOnTurn(widget
                            //         .user.pathobj.directions[DirectionIndex]);
                            //     if (widget.user.pathobj.directions.length -
                            //                 DirectionIndex ==
                            //             2 &&
                            //         widget
                            //                 .user
                            //                 .pathobj
                            //                 .directions[DirectionIndex]
                            //                 .distanceToNextTurnInFeet !=
                            //             null &&
                            //         widget
                            //                 .user
                            //                 .pathobj
                            //                 .directions[DirectionIndex]
                            //                 .distanceToNextTurnInFeet! <=
                            //             5 &&
                            //         DirectionIndex + 1 <
                            //             widget.user.pathobj.directions.length) {
                            //       DirectionIndex++;
                            //     }
                            //     if (DirectionIndex == nextTurnIndex) {
                            //       widget.clearFocusTurnArrow();
                            //     }
                            //   }
                            // });
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.grey,
                            size: 24,
                          )),
                    ),
                  )
                ],
              ),
            ),
            DirectionIndex == nextTurnIndex
                ? Semantics(
              excludeSemantics: true,
              child: Container(
                width: 98,
                height: 39,
                margin: EdgeInsets.only(left: 9, top: 5),
                padding: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Color(0xff013633),
                ),
                child: Row(
                  children: [
                    Text(
                      "${LocaleData.then.getString(context)}",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffFFFFFF),
                        height: 25 / 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    // Text(DirectionIndex.toString()),
                    // Text(nextTurnIndex.toString())
                    getNextCustomIcon(turnDirection)
                  ],
                ),
              ),
            )
                : Container(),
            kDebugMode?IconButton(onPressed: (){
              listenToBin(hardSwitch: true);
            }, icon: Icon(Icons.escalator_warning)):Container(),
            // kDebugMode?Text(tools.AngleBetweenBuildingandGlobalNorth.toString()):Container(),
            // Text(bluetoothScanAndroidClass.logging.keys.toString())
          ],
        ),
      ),
    );
  }
}

class scrollableDirection extends StatelessWidget {
  String Direction;
  String steps;
  Icon? i;
  int DirectionIndex;
  int nextTurnIndex;
  List<direction> listOfDirections;
  UserState user;
  BuildContext context;
  scrollableDirection(this.Direction, this.steps, this.i, this.DirectionIndex,
      this.nextTurnIndex, this.listOfDirections, this.user, this.context);
  String chooseDirection() {
    try {
      if(user.onConnection && listOfDirections.isNotEmpty){
        // print("user.onConnection ${listOfDirections
        //     .where((direction) {
        //   final turn = direction.turnDirection?.toLowerCase() ?? "";
        //   return turn.contains("lift") || turn.contains("stairs");
        // }).first.turnDirection!}");
        return listOfDirections
            .where((direction) {
          final turn = direction.turnDirection?.toLowerCase() ?? "";
          return turn.contains("lift") || turn.contains("stairs");
        }).first.turnDirection!;

      }
      if (listOfDirections.isNotEmpty &&
          listOfDirections.length > DirectionIndex) {
        if (DirectionIndex < listOfDirections.length &&
            listOfDirections[DirectionIndex].isDestination) {
          double? angle;
          if (user.pathobj.singleCellListPath.isNotEmpty) {
            int l = user.pathobj.singleCellListPath.length;
            angle = tools.calculateAngle([
              user.pathobj.singleCellListPath[l - 2].x,
              user.pathobj.singleCellListPath[l - 2].y
            ], [
              user.pathobj.singleCellListPath[l - 1].x,
              user.pathobj.singleCellListPath[l - 1].y
            ], [
              user.pathobj.destinationX,
              user.pathobj.destinationY
            ]);
          }
          return angle != null
              ? "${listOfDirections[DirectionIndex].turnDirection} ${LocaleData.willbe.getString(context)} ${LocaleData.getProperty(tools.angleToClocks3(angle, context), context)}"
              : "${listOfDirections[DirectionIndex].turnDirection} ${LocaleData.willbeonyourfront.getString(context)}";
        } else if (DirectionIndex == nextTurnIndex) {
          return listOfDirections[DirectionIndex].liftDestinationFloor != null
              ? LocaleData.getProperty(
              listOfDirections[DirectionIndex].turnDirection!, context)
              : "${Direction == "Straight" ? "${LocaleData.gostraight.getString(context)}" : LocaleData.getProperty(Direction, context)}";
        } else {
          if (DirectionIndex < listOfDirections.length) {
            return "${listOfDirections[DirectionIndex].turnDirection == "Straight" ? "${LocaleData.gostraight.getString(context)}" : "${LocaleData.getProperty(listOfDirections[DirectionIndex].turnDirection!, context)}"}";
          } else {
            return "${listOfDirections[DirectionIndex - 1].turnDirection == "Straight" ? "${LocaleData.gostraight.getString(context)}" : "${LocaleData.getProperty(listOfDirections[DirectionIndex - 1].turnDirection!, context)},"}";
          }
        }
      } else {
        return "${LocaleData.gostraight.getString(context)}";
      }
    } catch (e) {
      print("error in choose direction:${e}");
      return "${LocaleData.gostraight.getString(context)}";
    }
  }

  String chooseSteps() {
    try {
      // print("DirectionIndex $DirectionIndex and $nextTurnIndex");
      if (listOfDirections.isNotEmpty &&
          DirectionIndex < listOfDirections.length) {
        if (listOfDirections[DirectionIndex].isDestination) {
          return "";
        } else if (nextTurnIndex == -1 ||
            DirectionIndex == nextTurnIndex &&
                listOfDirections[DirectionIndex].liftDestinationFloor == null) {
          return '$steps';
        } else {
          return '${tools.convertFeet((listOfDirections[DirectionIndex].distanceToNextTurnInFeet ?? 1).toInt(), context)}';
        }
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Icon? chooseIcon() {
    try {
      if(user.onConnection && listOfDirections.isNotEmpty){
        var instruction = listOfDirections.where((direction)=>direction.turnDirection != null && direction.turnDirection!.toLowerCase().contains("lift")).first.turnDirection!;
        _DirectionHeaderState.getCustomIcon(instruction);
      }
      if (listOfDirections.isNotEmpty &&
          DirectionIndex < listOfDirections.length) {
        if (listOfDirections[DirectionIndex].isDestination) {
          return const Icon(
            Icons.place_rounded,
            color: Colors.blueAccent,
            size: 40,
          );
        } else if (nextTurnIndex == -1 ||
            DirectionIndex == nextTurnIndex &&
                listOfDirections[DirectionIndex].liftDestinationFloor == null) {
          return i;
        } else {
          return _DirectionHeaderState.getCustomIcon(
              listOfDirections[DirectionIndex].turnDirection!);
        }
      } else {
        return const Icon(Icons.straight);
      }
    } catch (e) {
      return const Icon(Icons.straight);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: "${chooseDirection()} ${chooseSteps()}",
              excludeSemantics: true,
              child: Center(
                child: Text(
                  chooseDirection(),
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 30 / 24,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Semantics(
            excludeSemantics: true,
            child: Container(
              width: 85,
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ((chooseDirection().toLowerCase().contains("lift") ||
                      chooseDirection()
                          .toLowerCase()
                          .contains("stair")) ||
                      listOfDirections.isEmpty ||
                      (DirectionIndex > 0 &&
                          listOfDirections.length > DirectionIndex &&
                          listOfDirections[DirectionIndex].isDestination))
                      ? Container()
                      : Text(
                    chooseSteps().replaceAll("meter", "m"),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 26 / 16,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  chooseIcon() == null
                      ? Container()
                      : Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color:
                      Colors.white, // Set background color to white
                      shape:
                      BoxShape.circle, // Make the container a circle
                    ),
                    child:
                    chooseIcon(), // Your icon or widget inside the circle
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}