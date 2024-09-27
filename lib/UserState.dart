import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:geodesy/geodesy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/MotionModel.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:iwaymaps/websocket/UserLog.dart';
import 'buildingState.dart' as b;

import 'APIMODELS/beaconData.dart';
import 'Cell.dart';
import 'localization/locales.dart';
import 'navigationTools.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:iwaymaps/websocket/UserLog.dart';

class UserState {
  int floor;
  int coordX;
  double coordXf;
  int coordY;
  double coordYf;
  double lat;
  double lng;
  String key;
  double theta;
  String? locationName;
  bool isnavigating;
  int showcoordX;
  int showcoordY;
  static int geoFenced=0;

  static bool isTurn=false;
  pathState pathobj = pathState();
  List<int> path = [];
  List<Cell> Cellpath = [];
  bool initialallyLocalised = false;
  String Bid;
  List<int> offPathDistance = [];
  bool onConnection = false;
  bool temporaryExit = false;
  static double geoLat=0.0;
  static double geoLng=0.0;
  static bool ttsAllStop=false;
  static bool ttsOnlyTurns=false;
  b.Building? building;
  static int xdiff = 0;
  static int ydiff = 0;
  static bool isRelocalizeAroundLift = false;
  static bool reachedLift = false;
  static int UserHeight = 195;
  static double stepSize = 2;
  static String lngCode = 'en';
  static int cols = 0;
  static int rows = 0;
  static Map<String, Map<int, List<int>>> nonWalkable = Map();
  static Function reroute = () {};
  static Function closeNavigation = () {};
  static Function speak = (String lngcode) {};
  static Function AlignMapToPath = () {};
  static Function changeBuilding = (){};
  static Function startOnPath = () {};
  static Function paintMarker = (geo.LatLng Location) {};
  static Function createCircle = (double lat, double lng) {};

  UserState(
      {required this.floor,
      required this.coordX,
      required this.coordY,
      required this.lat,
      required this.lng,
      required this.theta,
      this.key = "",
      this.Bid = "",
      this.showcoordX = 0,
      this.showcoordY = 0,
      this.isnavigating = false,
      this.coordXf = 0.0,
      this.coordYf = 0.0});

  // Future<void> move()async {
  //   
  //   
  //   
  //   pathobj.index = pathobj.index + 1;
  //   
  //
  //   List<int> transitionvalue = tools.eightcelltransition(this.theta);
  //   coordX = coordX + transitionvalue[0];
  //   coordY = coordY + transitionvalue[1];
  //   List<double> values = tools.localtoglobal(coordX, coordY);
  //   lat = values[0];
  //   lng = values[1];
  //
  //
  //   if(this.isnavigating && pathobj.path.isNotEmpty && pathobj.numCols != 0){
  //     showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
  //     showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
  //   }else{
  //     showcoordX = coordX;
  //     showcoordY = coordY;
  //   }
  //
  //   
  //   
  //   
  //
  // }

  Future<void> move(context) async {

    moveOneStep(context);

    for (int i = 1; i < stepSize.toInt(); i++) {
      bool movementAllowed = true;

      if (!MotionModel.isValidStep(
          this, cols, rows, nonWalkable[Bid]![floor]!, reroute)) {
        
        movementAllowed = false;
      }

      if (isnavigating) {
        int prevX = Cellpath[pathobj.index - 1].x;
        int prevY = Cellpath[pathobj.index - 1].y;
        int nextX = Cellpath[pathobj.index + 1].x;
        int nextY = Cellpath[pathobj.index + 1].y;
        //non Walkable Check

        //destination check
        if (Cellpath.length - pathobj.index < 6) {
          
          movementAllowed = false;
        }

        //turn check
        if (tools
            .isTurn([prevX, prevY], [showcoordX, showcoordY], [nextX, nextY])) {
          
          movementAllowed = false;
        }

        //lift check

        if (pathobj.connections[Bid]?[floor] ==
            showcoordY * cols + showcoordX) {
          
          movementAllowed = false;
        }
      }

      if (movementAllowed) {
        moveOneStep(context);
      } else if (!movementAllowed) {
        return;
      }
    }

    if (stepSize.toInt() != stepSize) {}
  }

  Future<void> moveOneStep(context) async {
    wsocket.message["userPosition"]["X"] = coordX;
    wsocket.message["userPosition"]["Y"] = coordY;
    wsocket.message["userPosition"]["floor"] = floor;

    if (isnavigating) {
      checkForMerge();
      moveinCampus(context);
      pathobj.index = pathobj.index + 1;
      if((Bid == buildingAllApi.outdoorID && Cellpath[pathobj.index].bid == buildingAllApi.outdoorID) && tools.calculateDistance([showcoordX, showcoordY], [Cellpath[pathobj.index].x,Cellpath[pathobj.index].y])>=3){

        //destination check
        List<Cell> turnPoints =
        tools.getCellTurnpoints(Cellpath);
        print("angleeeeeeeee ${(tools.calculateDistance([showcoordX, showcoordY],
            [pathobj.destinationX, pathobj.destinationY]) <
            6)}");
        bool isSameFloorAndBuilding = floor == pathobj.destinationFloor &&
            Bid == pathobj.destinationBid;

        bool isNearLastTurnPoint = tools.calculateDistance(
            [turnPoints.last.x, turnPoints.last.y],
            [pathobj.destinationX, pathobj.destinationY]) < 10;

        bool isAtLastTurnPoint = showcoordX == turnPoints.last.x &&
            showcoordY == turnPoints.last.y;

        bool isNearDestination = tools.calculateDistance(
            [showcoordX, showcoordY],
            [pathobj.destinationX, pathobj.destinationY]) < 6;

        if (isSameFloorAndBuilding &&
            ((isNearLastTurnPoint && isAtLastTurnPoint) || isNearDestination)) {
          createCircle(lat, lng);
          closeNavigation();
        }


        Cell point = tools.findingprevpoint(Cellpath,pathobj.index);
        double angle = tools.calculateBearing([lat,lng], [Cellpath[pathobj.index].lat, Cellpath[pathobj.index].lng]);
        Map<String, double> data = tools.findslopeandintercept(point.x, point.y, Cellpath[pathobj.index].x, Cellpath[pathobj.index].y);
        List<int> transitionvalue = tools.findpoint(coordX,coordY, Cellpath[pathobj.index].x, Cellpath[pathobj.index].y, data);
        showcoordX = transitionvalue[0];
        showcoordY = transitionvalue[1];
        coordX = transitionvalue[0];
        coordY = transitionvalue[1];
        List<double> values = tools.moveLatLng([lat,lng], angle, 1);
        lat = values[0];
        lng = values[1];
        path.insert(pathobj.index, (showcoordY*cols)+showcoordX);
        Cellpath.insert(pathobj.index, Cell((showcoordY*cols)+showcoordX, showcoordX, showcoordY, tools.eightcelltransition, lat, lng, buildingAllApi.outdoorID, floor, cols,imaginedCell: true));
        return;
      }
      if(Cellpath[pathobj.index].bid != null && Bid != Cellpath[pathobj.index].bid) {
        Bid = Cellpath[pathobj.index].bid!;
        cols = building!.floorDimenssion[Bid]![floor]![0];
        rows = building!.floorDimenssion[Bid]![floor]![1];
      }
      List<int> p = tools.analyzeCell(Cellpath, Cellpath[pathobj.index]);
      List<int> transitionvalue = Cellpath[pathobj.index]
          .move(this.theta, currPointer: p[1], totalCells: p[0]);
      coordX = coordX+transitionvalue[0];
      coordY = coordY+transitionvalue[1];
      List<double> values =
          tools.localtoglobal(showcoordX, showcoordY, building!.patchData[Cellpath[pathobj.index].bid]);
      lat = values[0];
      lng = values[1];

      // if(coordXf == 0.0){
      //   coordXf = transitionvalue[0]*(stepSize-stepSize.toInt());
      // }else{
      //   coordX = coordX + transitionvalue[0];
      //   coordXf = 0.0;
      // }
      //
      //
      // if(coordYf == 0.0){
      //   coordYf = transitionvalue[1]*(stepSize-stepSize.toInt());
      // }else{
      //   coordY = coordY + transitionvalue[1];
      //   coordYf = 0.0;
      // }
      if (this.isnavigating &&
          pathobj.Cellpath.isNotEmpty &&
          pathobj.numCols != 0) {
        showcoordX = Cellpath[pathobj.index].x;
        showcoordY = Cellpath[pathobj.index].y;
        List<double> values =
        tools.localtoglobal(showcoordX, showcoordY, building!.patchData[Cellpath[pathobj.index].bid]);
        lat = values[0];
        lng = values[1];
        if(Cellpath[pathobj.index-1].bid != Cellpath[pathobj.index].bid){
          
          coordX = showcoordX;
          coordY = showcoordY;
          values =
              tools.localtoglobal(coordX, coordY, building!.patchData[Cellpath[pathobj.index].bid]);
          lat = values[0];
          lng = values[1];
          String? previousBuildingName = b.Building.buildingData?[Cellpath[pathobj.index - 1].bid];
          String? nextBuildingName = b.Building.buildingData?[pathobj.destinationBid];

          if (previousBuildingName != null && nextBuildingName != null) {
            if(Cellpath[pathobj.index - 1].bid == pathobj.sourceBid){
              speak(convertTolng("Exiting $previousBuildingName. Continue along the path towards $nextBuildingName.", "", 0.0, context, 0.0,nextBuildingName,previousBuildingName),lngCode);
            }else if(Cellpath[pathobj.index].bid == pathobj.destinationBid){

              if(pathobj.destinationBid == buildingAllApi.outdoorID){
                speak(convertTolng("Continue ahead towards ${pathobj.destinationName}.", "", 0.0, context, 0.0, "", "",destname:pathobj.destinationName ) ,lngCode);
              }else{
                speak(convertTolng("Entering ${nextBuildingName}. Continue ahead.", "", 0.0, context, 0.0,nextBuildingName,""),lngCode);
              }
            }

          } changeBuilding(Cellpath[pathobj.index-1].bid, Cellpath[pathobj.index].bid);
        }
      } else {
        showcoordX = coordX;
        showcoordY = coordY;
        values =
            tools.localtoglobal(coordX, coordY, building!.patchData[Cellpath[pathobj.index].bid]);
        lat = values[0];
        lng = values[1];
      }


      int prevX = Cellpath[pathobj.index - 1].x;
      int prevY = Cellpath[pathobj.index - 1].y;
      int nextX = Cellpath[pathobj.index + 1].x;
      int nextY = Cellpath[pathobj.index + 1].y;
      //non Walkable Check

      //destination check
      List<Cell> turnPoints =
          tools.getCellTurnpoints(Cellpath);
      print("angleeeeeeeee ${(tools.calculateDistance([showcoordX, showcoordY],
          [pathobj.destinationX, pathobj.destinationY]) <
          6)}");
      bool isSameFloorAndBuilding = floor == pathobj.destinationFloor &&
          Bid == pathobj.destinationBid;

      bool isNearLastTurnPoint = tools.calculateDistance(
          [turnPoints.last.x, turnPoints.last.y],
          [pathobj.destinationX, pathobj.destinationY]) < 10;

      bool isAtLastTurnPoint = showcoordX == turnPoints.last.x &&
          showcoordY == turnPoints.last.y;

      bool isNearDestination = tools.calculateDistance(
          [showcoordX, showcoordY],
          [pathobj.destinationX, pathobj.destinationY]) < 6;

      if (isSameFloorAndBuilding &&
          ((isNearLastTurnPoint && isAtLastTurnPoint) || isNearDestination)) {
        createCircle(lat, lng);
        closeNavigation();
      }
      // if (floor == pathobj.destinationFloor &&
      //     Bid == pathobj.destinationBid &&
      //     showcoordX == turnPoints[turnPoints.length - 1].x &&
      //     showcoordY == turnPoints[turnPoints.length - 1].y &&
      //     tools.calculateDistance([showcoordX, showcoordY],
      //             [pathobj.destinationX, pathobj.destinationY]) <
      //         6) {
      //
      // }

      //turn check
      if (tools
          .isTurn([prevX, prevY], [showcoordX, showcoordY], [nextX, nextY])) {

        UserState.isTurn=true;
        print("qpalzm turn detected ${[prevX, prevY]}, ${[
          showcoordX,
          showcoordY
        ]}, ${[nextX, nextY]}");
        if(Cellpath[pathobj.index+1].bid == Cellpath[pathobj.index].bid){
          print("value at turnsss");
          print([lat, lng]);
          print(tools.localtoglobal(nextX, nextY, building!.patchData[Bid]));
          AlignMapToPath([lat, lng],
              tools.localtoglobal(nextX, nextY, building!.patchData[Bid]));
        }
      }

      //lift check
      
      

      if (floor != pathobj.destinationFloor &&
          pathobj.connections[Bid]?[floor] ==
              (showcoordY * cols + showcoordX)) {
        // UserState.reachedLift=true;
        onConnection = true;
        createCircle(lat, lng);
        speak(
            convertTolng(
                "Use this ${pathobj.accessiblePath} and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor",
                "",
                0.0,
                context,
                0.0,"",""),
            lngCode,
            prevpause: true);
      }

      if (0 < pathobj.index &&
          pathobj.index < Cellpath.length - 1 &&
          pathState.nearbyLandmarks.isNotEmpty &&
          !tools.isCellTurn(Cellpath[pathobj.index - 1],
              Cellpath[pathobj.index], Cellpath[pathobj.index + 1])) {
        pathState.nearbyLandmarks.retainWhere((element) {
          if (element.element!.subType == "room door" &&
              element.properties!.polygonExist != true) {
            if (tools.calculateDistance([
                  showcoordX,
                  showcoordY
                ], [
                  element.doorX ?? element.coordinateX!,
                  element.doorY ?? element.coordinateY!
                ]) <=
                3) {
              if(!UserState.ttsOnlyTurns){
                speak(
                    convertTolng("Passing by ${element.name}", element.name, 0.0,
                        context, 0.0,"",""),
                    lngCode);
              }

              return false; // Remove this element
            }
          } else {
            if (tools.calculateDistance([
                  showcoordX,
                  showcoordY
                ], [
                  element.doorX ?? element.coordinateX!,
                  element.doorY ?? element.coordinateY!
                ]) <=
                6) {
              double agl = tools.calculateAngle2([
                showcoordX,
                showcoordY
              ], [
                showcoordX + transitionvalue[0],
                showcoordY + transitionvalue[1]
              ], [
                element.coordinateX!,
                element.coordinateY!
              ]);
              if(!UserState.ttsOnlyTurns){
                speak(
                    convertTolng(
                        "${element.name} is on your ${LocaleData.getProperty5(tools.angleToClocks(agl, context), context)}",
                        element.name!,
                        0.0,
                        context,
                        0.0,"",""),
                    lngCode);
              }

              return false; // Remove this element
            }
          }
          return true; // Keep this element
        });
      }
    } else {
      pathobj.index = pathobj.index + 1;

      List<int> transitionvalue = tools.eightcelltransition(this.theta);
      coordX = coordX + transitionvalue[0];
      coordY = coordY + transitionvalue[1];
      List<double> values =
          tools.localtoglobal(coordX, coordY, building!.patchData[Bid]);
      lat = values[0];
      lng = values[1];
      if (this.isnavigating &&
          pathobj.path.isNotEmpty &&
          pathobj.numCols != 0) {
        showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
        showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
      } else {
        showcoordX = coordX;
        showcoordY = coordY;
      }
    }

    int d = tools
        .calculateDistance([coordX, coordY], [showcoordX, showcoordY]).toInt();
    if (d > 0) {
      offPathDistance.add(d);
    }
  }

  Future<void> moveinCampus(context) async {

  }

  String convertTolng(
      String msg, String? name, double agl, BuildContext context, double a,String nextBuildingName ,String currentBuildingName,
      {String destname = ""}) {
    
    print(
        "$msg");
    if (msg ==
        "You have reached ${destname}. It is ${tools.angleToClocks3(a, context)}") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "आप ${destname} पर पहुँच गए हैं। वह ${LocaleData.getProperty(tools.angleToClocks3(a, context), context)}";
      }
    } else if (msg ==
        "Use this Lifts and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor") {
      if (lngCode == 'en') {
        return "Use this Lift and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor";
      } else {
        return "इस लिफ़्ट का उपयोग करें और ${tools.numericalToAlphabetical(pathobj.destinationFloor)} मंज़िल पर जाएँ";
      }
    } else if (msg ==
        "Use this Stairs and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor") {
      if (lngCode == 'en') {
        return "Use this Stair and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor";
      } else {
        return "इन सीढ़ियों का उपयोग करें और ${tools.numericalToAlphabetical(pathobj.destinationFloor)} मंज़िल पर जाएँ";
      }
    } else if (name != null && msg == "Passing by ${name}") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "${name} से गुज़रते हुए";
      }
    } else if (name != null &&
        msg ==
            "${name} is on your ${(
              tools.angleToClocks(agl, context),
              context
            )}") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "${name} आपके ${LocaleData.getProperty5(tools.angleToClocks(agl, context), context)} पर है";
      }
    }else if (nextBuildingName != "" && currentBuildingName!="" &&
        msg ==
            "Exiting $currentBuildingName. Continue along the path towards $nextBuildingName.") {

      if (lngCode == 'en') {
        return msg;
      } else {
        print("entereddddd");
        print(msg);
        return "${currentBuildingName} से बाहर निकलते हुए। ${nextBuildingName} की ओर चलते रहें";
      }
    }else if (nextBuildingName != "" &&
        msg ==
            "Entering ${nextBuildingName}. Continue ahead.") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "${nextBuildingName} में प्रवेश कर रहे हैं। आगे बढ़ते रहें।";
      }
    }else if (destname != "" &&
        msg ==
            "Continue ahead towards $destname") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "$destname की ओर आगे बढ़ते रहें";
      }
    }
    return "";
  }

  Future<void> checkForMerge() async {
    if (offPathDistance.length == 3) {
      if (tools.allElementsAreSame(offPathDistance)) {
        offPathDistance.clear();
        coordX = showcoordX;
        coordY = showcoordY;
      } else {
        offPathDistance.removeAt(0);
      }
    }
  }

  Future<void> moveToFloor(int fl) async {
    floor = fl;
    if (pathobj.Cellpath[fl] != null) {
      // coordX=coordinateX!;
      // coordY=coordinateY!;
      coordX = pathobj.Cellpath[fl]![0].x;
      coordY = pathobj.Cellpath[fl]![0].y;
      List<double> values =
          tools.localtoglobal(coordX, coordY, building!.patchData[Bid]);
      lat = values[0];
      lng = values[1];
      showcoordX = coordX;
      showcoordY = coordY;
      pathobj.index = path.indexOf(pathobj.Cellpath[fl]![0].node);
      paintMarker(geo.LatLng(lat, lng));
    }
  }

  Future<void> moveToPointOnPath(int index, {bool onTurn = false}) async {
    if(onTurn){
      int? turnIndex = await findTurnPointAround();
      if (turnIndex != null) {
        index = turnIndex;
      }
    }
    if (index > path.length - 1) {
      index = path.length - 9;
    }
    showcoordX = path[index] % pathobj.numCols![Bid]![floor]!;
    showcoordY = path[index] ~/ pathobj.numCols![Bid]![floor]!;
    coordX = showcoordX;
    coordY = showcoordY;
    pathobj.index = index + 1;
    List<double> values =
        tools.localtoglobal(coordX, coordY, building!.patchData[Bid]);
    lat = values[0];
    lng = values[1];
    createCircle(values[0], values[1]);
    AlignMapToPath([values[0],values[1]],values);
  }

  Future<int> moveToNearestPoint() async {
    double d = 100000000;
    if (coordX == 0 && coordY == 0) {
      return pathobj.index;
    }
    for (var e in Cellpath) {
      if (e.floor == floor && e.bid == Bid) {
        double distance = tools.calculateDistance([coordX, coordY], [e.x, e.y]);
        if (distance < d) {
          d = distance;
          pathobj.index = Cellpath.indexOf(e);
        }
      }
    }
    return pathobj.index;
  }

  Future<void> moveToNearestTurn(int index) async {
    List<Cell> turnPoints =
        tools.getCellTurnpoints(Cellpath);
    for (int i = index; i < Cellpath.length; i++) {
      for (int j = 0; j < turnPoints.length; j++) {
        if (Cellpath[i] == turnPoints[j]) {
          if (tools.calculateDistance(
                  [Cellpath[pathobj.index].x, Cellpath[pathobj.index].y],
                  [turnPoints[j].x, turnPoints[j].y]) <=
              10) {
            pathobj.index = Cellpath.indexOf(turnPoints[j]);
          }
          return;
        }
      }
    }
  }

  Future<int?> findTurnPointAround() async {
    List<Cell> turnPoints =
    tools.getCellTurnpoints(Cellpath);
    double d = 11;
    int? ind;
    for (int j = 0; j < turnPoints.length; j++) {
      double distance = tools.calculateDistance(
          [showcoordX, showcoordY],
          [turnPoints[j].x, turnPoints[j].y]);
      if(distance<d){
        d = distance;
        ind = Cellpath.indexOf(turnPoints[j]);
      }
    }
    return ind;
  }

  Future<void> moveToStartofPath() async {
    double d = 100000000;
    int i = await moveToNearestPoint();
    
    await moveToNearestTurn(i);

    // if(Cellpath[0].x == turnPoints[0].x && Cellpath[0].y == turnPoints[0].y){
    //   if (tools.calculateDistance([Cellpath[0].x, Cellpath[0].y],
    //       [turnPoints[1].x, turnPoints[1].y]) <=
    //       10) {
    //     pathobj.index = Cellpath.indexOf(turnPoints[0]);
    //   }
    // }else{
    //   if (tools.calculateDistance([Cellpath[0].x, Cellpath[0].y],
    //       [turnPoints[0].x, turnPoints[0].y]) <=
    //       10) {
    //     pathobj.index = Cellpath.indexOf(turnPoints[0]);
    //   }
    // }

    floor = pathobj.sourceFloor;
    showcoordX = Cellpath[pathobj.index].x;
    showcoordY = Cellpath[pathobj.index].y;
    coordX = showcoordX;
    coordY = showcoordY;
    List<double> values =
        tools.localtoglobal(showcoordX, showcoordY, building!.patchData[Bid]);
    lat = values[0];
    lng = values[1];

    
  }

  Future<void> reset() async {
    showcoordX = coordX;
    showcoordY = coordY;
    isnavigating = false;
    pathobj = pathState();
    path = [];
  }
}
