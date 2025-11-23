import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart';

import 'APIMODELS/GlobalAnnotationModel.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'Cell.dart';
import 'ViewModel/DirectionInstructionViewModel.dart';
import 'dijkastra.dart';
import 'directionClass.dart';

class pathState {
  String sourcePolyID = "";
  String destinationPolyID = "";
  String sourceName = "";
  String destinationName = "";
  int sourceX = 0;
  int sourceY = 0;
  double sourceLat = 0.0;
  double sourceLng = 0.0;
  int destinationX = 0;
  int destinationY = 0;
  double destinationLat = 0.0;
  double destinationLng = 0.0;
  int sourceFloor = 0;
  int destinationFloor = 0;
  String accessiblePath = "Lifts";
  List<List<double>> realWorldCoordinates = [];
  Map<int, List<int>> path = {};
  bool noPathFound = false;
  Map<int, List<Cell>> Cellpath = {};
  List<int> singleListPath = [];
  List<Cell> singleCellListPath = [];
  List<List<Cell>> listofPaths = [];
  Map<String,patchDataModel> patchData = Map();
  List<direction> directions = [];
  DirectionInstructionViewModel? directionInstructionViewModel;
  Map<String,Map<int,int>>? numCols = Map();
  int _index = 0;
  String sourceBid = "";
  String destinationBid = "";
  Map<String,Map<int,int>> connections = {};
  List<int> beaconCords = [];
  static List<Landmarks> nearbyLandmarks = [];
  Map<int,Landmarks> associateTurnWithLandmark = Map();
  String? SourceExitPolyid;
  String? DestinationEntryPolyid;
  static String? scanPolyID;
  Map<int, Set<Marker>> innerMarker = {};
  bool didPathStart = false;
  PathOption floorConnector = PathOption.lift;


  int get index => _index;

  set index(int value) {
    // print("index changed to $value ${StackTrace.current}");
    _index = value;
  }

  final List<Map<String, dynamic>> allOptions = [
    {
      "label": "Lift",
      "icon": Icons.elevator,
      "accessibleBy": "Lifts",
      "floorConnector": PathOption.lift,
    },
    {
      "label": "Escalator",
      "icon": Icons.escalator_warning,
      "accessibleBy": "Escalators",
      "floorConnector": PathOption.escalator,
    },
    {
      "label": "Ramp",
      "icon": Icons.accessible,
      "accessibleBy": "Ramps",
      "floorConnector": PathOption.ramp,
    },
    {
      "label": "Stairs",
      "icon": Icons.escalator,
      "accessibleBy": "Stairs",
      "floorConnector": PathOption.stairs,
    },
  ];

  List<Map<String, dynamic>>? filteredOptions;

  List<String> getAvailableConnectionsUnion(GlobalModel model) {
    List<String> availableConnectionsUnion = [];

    if (model.liftNodes != null && model.liftNodes!.isNotEmpty) {
      availableConnectionsUnion.add("Lifts");
    }
    if (model.stairsNodes != null && model.stairsNodes!.isNotEmpty) {
      availableConnectionsUnion.add("Stairs");
    }
    if (model.escalatorNodes != null && model.escalatorNodes!.isNotEmpty) {
      availableConnectionsUnion.add("Escalators");
    }
    if (model.rampNodes != null && model.rampNodes!.isNotEmpty) {
      availableConnectionsUnion.add("Ramps");
    }
    return availableConnectionsUnion;
  }


  // Default constructor without arguments
  pathState();
  // Additional constructor with named parameters for creating instances with specific values
  pathState.withValues(
      this.sourceX, this.sourceY, this.sourceFloor, this.destinationX, this.destinationY, this.destinationFloor, this.numCols, this._index);

  String? getHighestPriorityConnection(List<Map<String, dynamic>> filteredOptions) {
    const priority = ["Lift", "Escalator", "Ramp", "Stair"];

    for (final mode in priority) {
      final match = filteredOptions.firstWhere(
            (option) => option["label"] == mode,
        orElse: () => {},
      );
      if (match.isNotEmpty) return match["accessibleBy"];
    }

    return null; // No matching option found
  }


  void clear(){
    path.clear();
    Cellpath.clear();
    singleListPath.clear();
    directions.clear();
    connections.clear();
    nearbyLandmarks.clear();
    associateTurnWithLandmark.clear();
    index = 0;
    beaconCords.clear();
    noPathFound = false;
    didPathStart = false;
  }
  void swap() {
    // Swap source and destination information
    print("pathstate swap $sourceX,$sourceY,$sourceBid <> $destinationX,$destinationY,$destinationBid     $sourcePolyID<>$destinationPolyID");
    String tempPolyID = sourcePolyID;
    sourcePolyID = destinationPolyID;
    destinationPolyID = tempPolyID;

    String tempsourceBid = sourceBid;
    sourceBid = destinationBid;
    destinationBid = tempsourceBid;

    String tempName = sourceName;
    sourceName = destinationName;
    destinationName = tempName;

    int tempX = sourceX;
    sourceX = destinationX;
    destinationX = tempX;

    int tempY = sourceY;
    sourceY = destinationY;
    destinationY = tempY;

    int tempFloor = sourceFloor;
    sourceFloor = destinationFloor;
    destinationFloor = tempFloor;

    double tempLat = sourceLat;
    sourceLat = destinationLat;
    destinationLat = tempLat;

    double tempLng = sourceLng;
    sourceLng = destinationLng;
    destinationLng = tempLng;

    path.forEach((key, value) {
      path[key] = value.reversed.toList();
    });
    print("pathstate swap $sourceX,$sourceY <> $destinationX,$destinationY     $sourcePolyID<>$destinationPolyID");
  }

  void clearforaccessiblepath(){
    didPathStart = true;
    realWorldCoordinates.clear();
    path.clear();
    Cellpath.clear();
    singleListPath.clear();
    singleCellListPath.clear();
    listofPaths.clear();
    directions.clear();
    connections.clear();
    noPathFound = false;
  }
}