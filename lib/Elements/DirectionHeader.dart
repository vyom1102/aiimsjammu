import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';

import 'package:iwaymaps/navigationTools.dart';
import 'package:vibration/vibration.dart';

import '../UserState.dart';
import '../bluetooth_scanning.dart';
import '../buildingState.dart';
import '../directionClass.dart';
import '../directionClass.dart' as dc;
import '../directionClass.dart';
import '../Navigation.dart';


class DirectionHeader extends StatefulWidget {
  String direction;
  int distance;
  bool isRelocalize;
  UserState user;
  String getSemanticValue;
  final Function(String nearestBeacon, {bool render}) paint;
  final Function(String nearestBeacon) repaint;
  final Function() reroute;
  final Function() moveUser;
  final Function() closeNavigation;
  final Function(dc.direction turn) focusOnTurn;
  final Function()clearFocusTurnArrow;



  DirectionHeader({this.distance = 0, required this.user , this.direction = "", required this.paint, required this.repaint, required this.reroute, required this.moveUser, required this.closeNavigation,required this.isRelocalize,this.getSemanticValue='', required this.focusOnTurn,required this.clearFocusTurnArrow}){
    try{
      double angle = tools.calculateAngleBWUserandCellPath(
          user.Cellpath[0], user.Cellpath[1], user.pathobj.numCols![user.Bid]![user.floor]!,user.theta);
      direction = tools.angleToClocks(angle);
      if(direction == "Straight"){
        direction = "Go Straight";
      }else{
        direction = "Turn ${direction}, and Go Straight";
      }
    }catch(e){

    }
  }

  @override
  State<DirectionHeader> createState() => _DirectionHeaderState();
}

class _DirectionHeaderState extends State<DirectionHeader> {
  List<int> turnPoints = [];
  BLueToothClass btadapter = new BLueToothClass();
  late Timer _timer;
  String turnDirection = "";
  List<Widget> DirectionWidgetList = [];


  Map<String, double> ShowsumMap = Map();
  int DirectionIndex = 1;
  int nextTurnIndex = 0;
<<<<<<< Updated upstream
  
=======
  bool isSpeaking=false;
  String? threshold;

  void initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }






>>>>>>> Stashed changes
  @override
  void initState() {
    super.initState();

    for(int i = 0; i<widget.user.pathobj.directions.length ; i++){
      direction element = widget.user.pathobj.directions[i];
      //DirectionWidgetList.add(scrollableDirection("${element.turnDirection == "Straight"?"Go Straight":"Turn ${element.turnDirection??""}, and Go Straight"}", '${((element.distanceToNextTurn??1)/UserState.stepSize).ceil()} steps', getCustomIcon(element.turnDirection!)));

    }


    btadapter.emptyBin();
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if(btadapter.BIN[i]!.isNotEmpty){
        btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }
<<<<<<< Updated upstream
    // btadapter.startScanning(Building.apibeaconmap);
    // _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
    //   //print("Pathposition");
    //   //print(widget.user.path);
    //
    //
    //   // //print("listen to bin :${listenToBin()}");
    //
    //   // HelperClass.showToast("Bin cleared");
    //   if(widget.user.pathobj.index>3) {
    //     listenToBin();
    //   }
    //
    //
    //
    // });
=======
    btadapter.startScanning(Building.apibeaconmap);
    _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      //
      //
      // //
      // HelperClass.showToast("Bin cleared");
      if(widget.user.pathobj.index>1) {
        listenToBin();
      }



    });
>>>>>>> Stashed changes

    btadapter.numberOfSample.clear();
    btadapter.rs.clear();
    Building.thresh = "";

    widget.getSemanticValue="";
    if(widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor] != null){
      turnPoints = tools.getTurnpoints(widget.user.path, widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);

<<<<<<< Updated upstream
      (widget.user.path.length%2==0)? turnPoints.add(widget.user.path[widget.user.path.length-2]):turnPoints.add(widget.user.path[widget.user.path.length-1]);
      //  btadapter.startScanning(Building.apibeaconmap);
      // _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      //
      //   listenToBin();
      //
      // });
      List<int> remainingPath = widget.user.path.sublist(widget.user.pathobj.index+1);
      int nextTurn = findNextTurn(turnPoints, remainingPath);
      widget.distance = tools.distancebetweennodes(nextTurn, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
=======
    if(widget.user.floor!=widget.user.pathobj.destinationFloor &&  widget.user.pathobj.connections[widget.user.Bid]?[widget.user.floor] == (widget.user.showcoordY*UserState.cols + widget.user.showcoordX)){
      speak(convertTolng(
          "Use this lift and go to ${tools.numericalToAlphabetical(
              widget.user.pathobj.destinationFloor)} floor",_currentLocale, "", "", 0, "")
          , _currentLocale, prevpause:true);
    }else if(widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor] != null){

      turnPoints = tools.getTurnpoints_inCell(widget.user.Cellpath);
      turnPoints.add(widget.user.Cellpath.last);

      

      (widget.user.Cellpath.length%2==0)? turnPoints.add(widget.user.Cellpath[widget.user.Cellpath.length-2]):turnPoints.add(widget.user.Cellpath[widget.user.Cellpath.length-1]);

      List<Cell> remainingPath = widget.user.Cellpath.sublist(widget.user.pathobj.index+1);
      Cell nextTurn = findNextTurn(turnPoints, remainingPath);
        widget.distance = tools.distancebetweennodes_inCell(nextTurn, widget.user.Cellpath[widget.user.pathobj.index]);
>>>>>>> Stashed changes
      double angle = 0.0;
      if(widget.user.pathobj.index<widget.user.path.length-1){
        //
        angle = tools.calculateAngleBWUserandCellPath(widget.user.Cellpath[widget.user.pathobj.index], widget.user.Cellpath[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!,widget.user.theta);
        //
      }

      //print("angleeeeee $angle")  ;
      setState(() {
        widget.direction = tools.angleToClocks(angle);
        if(widget.direction == "Straight"){
          widget.direction = "Go Straight";
          
          speak("Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");
        }else{
<<<<<<< Updated upstream
          widget.direction = "Turn ${widget.direction}, and Go Straight";
         
          speak("${widget.direction} ${(widget.distance/UserState.stepSize).ceil()} steps");
          widget.getSemanticValue="${widget.direction} ${(widget.distance/UserState.stepSize).ceil()} steps";
=======
          
          widget.direction = convertTolng("Turn ${LocaleData.getProperty5(widget.direction, widget.context)}", _currentLocale, widget.direction,"",0, "");
         if(!UserState.ttsOnlyTurns) {
            speak(
                "${widget.direction}",
                _currentLocale, prevpause: true);
          }
        widget.getSemanticValue =
        "Turn ${widget.direction}, and Go Straight ${tools.convertFeet(widget.distance,widget.context)}";
>>>>>>> Stashed changes

        }
      });

    }


  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  String getgetSemanticValue(){
    return widget.getSemanticValue;
  }


  String debuglastNearestbeacon="";
  String debuglNearestbeacon="";
  Map<String, double> sortedsumMap={};
  Map<String, double> sumMap = {};
  Map<String, double> sumMapAvg = {};

  var newMap = <String, double>{};

  bool listenToBin(){
    double highestweight = 0;
    String nearestBeacon = "";
    sumMap.clear();
    sumMap = btadapter.calculateAverage();
<<<<<<< Updated upstream
=======
    print("threshold");
    threshold=(widget.user.building!.patchData[widget.user.Bid]!.patchData!.realtimeLocalisationThreshold!=null)?widget.user.building!.patchData[widget.user.Bid]!.patchData!.realtimeLocalisationThreshold!:'5';
    print(threshold);
    //
>>>>>>> Stashed changes
    sortedsumMap.clear();
    //


    sumMap.forEach((key, value) {
      if(highestweight<value){
        nearestBeacon = key;
        highestweight = value;
      }
    });


    setState(() {
      ShowsumMap = HelperClass().sortMapByValue(sumMap);
    });

    btadapter.stopScanning();
    btadapter.startScanning(Building.apibeaconmap);

    // sortedsumMap.entries.forEach((element) {
    //   if(Building.apibeaconmap[element.key]!.floor == widget.user.pathobj.destinationFloor && element.value >= 0.05){
    //     nearestBeacon = element.key;
    //     highestweight = element.value;
    //   }
    // });
    // //
    // //


    // for (int i = 0; i < btadapter.BIN.length; i++) {
    //   if (btadapter.BIN[i]!.isNotEmpty) {
    //
    //     btadapter.BIN[i]!.forEach((key, value) {
    //       //
    //       //
    //       //
    //
    //       setState(() {
    //             widget.direction = "${widget.direction}$key   $value\n";
    //           });
    //
    //       //
    //
    //       if (value > highestweight) {
    //         highestweight = value;
    //         //nearestBeacon = key;
    //       }
    //     });
    //     break;
    //   }
    // }

    // btadapter.emptyBin();
    //

    // sortedsumMap.forEach((key, value) {
    //
    //   setState(() {
    //     widget.direction = "${widget.direction}$key   $value\n";
    //   });
    //
    //   //
    //
    //   if(value>highestweight){
    //     highestweight =  value;
    //     nearestBeacon = key;
    //   }
    // });
    setState(() {
      debuglNearestbeacon = nearestBeacon;
      if(debuglastNearestbeacon != nearestBeacon){
        debuglastNearestbeacon = nearestBeacon;
      }

    });

    ////

<<<<<<< Updated upstream
  //print("nearest${nearestBeacon}");
    if(nearestBeacon !=""){

      if(widget.user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null) {
        if (widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId) {
          if (widget.user.floor != Building.apibeaconmap[nearestBeacon]!.floor) {

            //print("workingg 5");
=======
  // 
    if(nearestBeacon !=""){
      

      if(widget.user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null) {
        
        
        
        if (widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId) {
          

          //widget.user.pathobj.destinationFloor
          if (widget.user.floor != widget.user.pathobj.destinationFloor && widget.user.pathobj.destinationFloor!=widget.user.pathobj.sourceFloor && widget.user.pathobj.destinationFloor == Building.apibeaconmap[nearestBeacon]!.floor) {
            widget.user.onConnection = false;
            
>>>>>>> Stashed changes
            widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
            speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor");
            widget.paint(nearestBeacon,render: false);
            return true;

          } else if (widget.user.floor ==
              Building.apibeaconmap[nearestBeacon]!.floor &&
              highestweight >= 1.2) {

<<<<<<< Updated upstream
            //print("workingg user floor ${widget.user.floor}");
=======
              highestweight >=int.parse(threshold!)) {

            widget.user.onConnection = false;
            //
>>>>>>> Stashed changes
            List<int> beaconcoord = [
              Building.apibeaconmap[nearestBeacon]!.coordinateX!,
              Building.apibeaconmap[nearestBeacon]!.coordinateY!
            ];
            List<int> usercoord = [
              widget.user.showcoordX,
              widget.user.showcoordY
            ];
            double d = tools.calculateDistance(beaconcoord, usercoord);
<<<<<<< Updated upstream
            if (d < 5) {
              //print("workingg 1");
              //near to user so nothing to do
              return true;
            } else {
              //print("workingg 2");
              int distanceFromPath = 100000000;
              int? indexOnPath = null;
              int numCols = widget.user.pathobj.numCols![widget.user
                  .Bid]![widget.user.floor]!;
              widget.user.path.forEach((node) {
                List<int> pathcoord = [node % numCols, node ~/ numCols];
                double d1 = tools.calculateDistance(beaconcoord, pathcoord);
                if (d1 < distanceFromPath) {
                  distanceFromPath = d1.toInt();
                  //print("node on path $node");
                  //print("distanceFromPath $distanceFromPath");
                  indexOnPath = widget.user.path.indexOf(node);
                  //print(indexOnPath);
                }
              });
=======
            int distanceFromPath = 100000000;
            int? indexOnPath = null;
            int numCols = widget.user.pathobj.numCols![widget.user
                .Bid]![widget.user.floor]!;
            widget.user.path.forEach((node) {
              List<int> pathcoord = [node % numCols, node ~/ numCols];
              double d1 = tools.calculateDistance(beaconcoord, pathcoord);
              if (d1 < distanceFromPath) {
                distanceFromPath = d1.toInt();
                //
                //
                indexOnPath = widget.user.path.indexOf(node);
                //
              }
            });

            if (distanceFromPath > 10) {
              
              _timer.cancel();
              widget.repaint(nearestBeacon);
              widget.reroute;
              DirectionIndex = 1;
              return false; //away from path
            } else {
              double dis = tools.calculateDistance([widget.user.showcoordX,widget.user.showcoordY], beaconcoord);
              
              widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
              if(!UserState.ttsOnlyTurns) {
                speak(
                    "${widget.direction} ${tools.convertFeet(
                        widget.distance, widget.context)}",
                    _currentLocale
                );
              }
              widget.user.moveToPointOnPath(indexOnPath!);
>>>>>>> Stashed changes

              if (distanceFromPath > 10) {
                //print("workingg 3");
                _timer.cancel();
                widget.repaint(nearestBeacon);
                widget.reroute;
                return false; //away from path
              } else {
                //print("workingg 4");
                widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
                speak("${widget.direction} ${(widget.distance /
                    UserState.stepSize).ceil()} steps");
                widget.user.moveToPointOnPath(indexOnPath!);
                widget.moveUser();
                return true; //moved on path
              }
            }
<<<<<<< Updated upstream
=======
            // if (d < 5) {
            //   
            //   //near to user so nothing to do
            //   return true;
            // } else {
            //   //
            //   int distanceFromPath = 100000000;
            //   int? indexOnPath = null;
            //   int numCols = widget.user.pathobj.numCols![widget.user
            //       .Bid]![widget.user.floor]!;
            //   widget.user.path.forEach((node) {
            //     List<int> pathcoord = [node % numCols, node ~/ numCols];
            //     double d1 = tools.calculateDistance(beaconcoord, pathcoord);
            //     if (d1 < distanceFromPath) {
            //       distanceFromPath = d1.toInt();
            //       //
            //       //
            //       indexOnPath = widget.user.path.indexOf(node);
            //       //
            //     }
            //   });
            //
            //   if (distanceFromPath > 10) {
            //     
            //     _timer.cancel();
            //     widget.repaint(nearestBeacon);
            //     widget.reroute;
            //     DirectionIndex = 1;
            //     return false; //away from path
            //   } else {
            //     
            //     widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
            //     speak(
            //         "${widget.direction} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}",
            //         _currentLocale
            //     );
            //     widget.user.moveToPointOnPath(indexOnPath!);
            //     widget.moveUser();
            //     DirectionIndex = nextTurnIndex;
            //     return true; //moved on path
            //   }
            // }
>>>>>>> Stashed changes


            //
            //
            //
            //
            //
          }
        }


      }else{
<<<<<<< Updated upstream
        //print("workingg 6");
        //print("listening");
        //print("inelese");

        //print(nearestBeacon);
        _timer.cancel();
        widget.repaint(nearestBeacon);
        widget.reroute;
=======
        

        
        //
        //

        //
        if(highestweight>1.2){
          _timer.cancel();
          widget.repaint(nearestBeacon);
          widget.reroute;
        }
>>>>>>> Stashed changes
        return false;
      }
    }

    // btadapter.emptyBin();


    return false;
  }


  FlutterTts flutterTts = FlutterTts() ;
  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  int findNextTurn(List<int> turns, List<int> path) {
    // Iterate through the sorted list
    for (int i = 0; i < path.length; i++) {
      for(int j = 0; j< turns.length; j++){
        if(path[i] == turns[j]){
          return path[i];
        }
      }
    }

    // If no number is greater than the target, return null
    if(path.length >= widget.user.pathobj.index){
      return path[widget.user.pathobj.index];
    }else{
<<<<<<< Updated upstream
      return 0;
=======
      return Cell(0, 0, 0, (double angle, {int? currPointer,int? totalCells}){}, 0.0, 0.0, "", 0,0);
>>>>>>> Stashed changes
    }
  }

  @override
  void didUpdateWidget(DirectionHeader oldWidget){
    super.didUpdateWidget(oldWidget);

    if(widget.user.floor == widget.user.pathobj.sourceFloor && widget.user.pathobj.connections.isNotEmpty && widget.user.showcoordY*UserState.cols + widget.user.showcoordX  == widget.user.pathobj.connections[widget.user.Bid]![widget.user.pathobj.sourceFloor]){

<<<<<<< Updated upstream
    }else{

      if(widget.user.path[widget.user.pathobj.index] == turnPoints.last){

        speak("You have reached ${widget.user.pathobj.destinationName}");
        widget.closeNavigation();
      }else{
=======
    }else if (widget.user.path.isNotEmpty && widget.user.Cellpath.length-1>widget.user.pathobj.index){
      
>>>>>>> Stashed changes
        widget.user.pathobj.connections.forEach((key, value) {
          value.forEach((inkey, invalue) {
            if(widget.user.path[widget.user.pathobj.index] == invalue){
              widget.direction = "You have reached ";
            }
          });
        });
<<<<<<< Updated upstream

=======
        List<Cell> remainingPath = widget.user.Cellpath.sublist(widget.user.pathobj.index+1);
        // 
        // 
        Cell nextTurn = findNextTurn(turnPoints, remainingPath);
        // 
        // 

        nextTurnIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == nextTurn.node);
        // 
>>>>>>> Stashed changes



        List<int> remainingPath = widget.user.path.sublist(widget.user.pathobj.index+1);
        int nextTurn = findNextTurn(turnPoints, remainingPath);
        print(nextTurn);
        print(remainingPath);
        nextTurnIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == nextTurn);

        if(turnPoints.contains(widget.user.path[widget.user.pathobj.index])){
          if(DirectionIndex + 1 < widget.user.pathobj.directions.length)
          DirectionIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == widget.user.path[widget.user.pathobj.index])+1;
        }
<<<<<<< Updated upstream
        widget.distance = tools.distancebetweennodes(nextTurn, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);

        double angle = tools.calculateAngleBWUserandCellPath(widget.user.Cellpath[widget.user.pathobj.index], widget.user.Cellpath[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!,widget.user.theta);
        widget.direction = tools.angleToClocks(angle) == "None"?oldWidget.direction:tools.angleToClocks(angle);
        int index = widget.user.path.indexOf(nextTurn);
        //print("index $index");
=======
          widget.distance = tools.distancebetweennodes_inCell(nextTurn, widget.user.Cellpath[widget.user.pathobj.index]);
        double angle = 0.0;
        try{
          angle = tools.calculateAnglefifth(widget.user.Cellpath[widget.user.pathobj.index].node, widget.user.Cellpath[widget.user.pathobj.index+1].node, widget.user.Cellpath[widget.user.pathobj.index+2].node,widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
        }catch(e){
          print("error to be solved later $e");
        }
        if(widget.user.pathobj.index != 0){
          try {
            angle = tools.calculateAnglefifth(
                widget.user.Cellpath[widget.user.pathobj.index - 1].node,
                widget.user.Cellpath[widget.user.pathobj.index].node,
                widget.user.Cellpath[widget.user.pathobj.index + 1].node,
                widget.user.pathobj.numCols![widget.user.Bid]![widget.user
                    .floor]!);
          }catch(e){
            print("problem to be solved later $e");
          }
        }
        double userangle = tools.calculateAngleBWUserandCellPath(widget.user.Cellpath[widget.user.pathobj.index], widget.user.Cellpath[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!,widget.user.theta);

        widget.direction = tools.angleToClocks(angle,widget.context) == "None"?oldWidget.direction:tools.angleToClocks(angle,widget.context);
        String userdirection = tools.angleToClocks(userangle,widget.context) == "None"?oldWidget.direction:tools.angleToClocks(userangle,widget.context);
        if(userdirection == "Straight"){
          widget.direction = "Straight";
        }
      if(widget.user.pathobj.index<3){
        widget.direction = userdirection;
      }

      if(UserCredentials().getUserPersonWithDisability()==1 || UserCredentials().getUserPersonWithDisability()==2){
        widget.direction = userdirection;
      }



      int index = widget.user.Cellpath.indexOf(nextTurn);
        //
>>>>>>> Stashed changes
        double a =0;
        if(index+1 == widget.user.path.length){
          a = tools.calculateAnglefifth(widget.user.path[index-2], widget.user.path[index-1], widget.user.path[index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
        }else{
          a = tools.calculateAnglefifth(widget.user.path[index-1], widget.user.path[index], widget.user.path[index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
        }

        String direc = tools.angleToClocks(a);
        turnDirection = direc;
        if(nextTurn == turnPoints.last && widget.distance == 7){
          double angle = tools.calculateAngleThird([widget.user.pathobj.destinationX,widget.user.pathobj.destinationY], widget.user.path[widget.user.pathobj.index+1], widget.user.path[widget.user.pathobj.index+2], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
          speak("${widget.direction} ${widget.distance} steps. ${widget.user.pathobj.destinationName} will be ${tools.angleToClocks2(angle)}");
        }else if(nextTurn != turnPoints.last && (widget.distance/UserState.stepSize).ceil() == 7){
          if(!direc.contains("slight")){

            if(widget.user.pathobj.associateTurnWithLandmark[nextTurn] != null){
              speak("Approaching ${direc} turn from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}");
              //widget.user.pathobj.associateTurnWithLandmark.remove(nextTurn);
            }else{
              speak("Approaching ${direc} turn");
              widget.user.move();
            }
          }
        }
<<<<<<< Updated upstream


        if(oldWidget.direction != widget.direction){

          if(oldWidget.direction == "Straight"){

            Vibration.vibrate();
=======
      
      
        String direc = tools.angleToClocks(a,widget.context);
        turnDirection = direc;

      if(oldWidget.direction != widget.direction){

        if(oldWidget.direction == "Straight"){
          

          Vibration.vibrate();


          // if(nextTurn == turnPoints.last){
          //   speak("${widget.direction} ${widget.distance} meter then you will reach ${widget.user.pathobj.destinationName}");
          // }else{
          //   speak("${widget.direction} ${widget.distance} meter");
          // }
          
>>>>>>> Stashed changes


            // if(nextTurn == turnPoints.last){
            //   speak("${widget.direction} ${widget.distance} meter then you will reach ${widget.user.pathobj.destinationName}");
            // }else{
            //   speak("${widget.direction} ${widget.distance} meter");
            // }

            speak("Turn ${widget.direction}");
            //speak("Turn ${widget.direction}, and Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");


<<<<<<< Updated upstream
          }else if(widget.direction == "Straight"){



            Vibration.vibrate();

            speak("Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");
          }
        }
      }
=======
        }else if(widget.direction == "Straight"){
          Vibration.vibrate();
          UserState.isTurn=false;
          if(!UserState.ttsOnlyTurns) {
            speak(
                "${LocaleData.getProperty6('Go Straight', context)} ${tools
                    .convertFeet(widget.distance, context)}}",
                _currentLocale, prevpause: true);
          }
        }
      }

        if(nextTurn == turnPoints.last && widget.distance == 7){
          double angle = 0.0;
          try{
            angle = tools.calculateAngleThird([widget.user.pathobj.destinationX,widget.user.pathobj.destinationY], widget.user.path[widget.user.pathobj.index+1], widget.user.path[widget.user.pathobj.index+2], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
          }catch(e){
            print("problem to be solved later $e");
          }
          if(!UserState.ttsOnlyTurns) {
            speak("${widget.direction} ${widget.distance} steps. ${widget.user
                .pathobj.destinationName} will be ${tools.angleToClocks2(
                angle, widget.context)}", _currentLocale);
          }
            widget.user.move(context);
        }else if(nextTurn != turnPoints.last && widget.user.pathobj.connections[widget.user.Bid]?[widget.user.floor] != nextTurn && (widget.distance/UserState.stepSize).ceil() == 7){

          if((!direc.toLowerCase().contains("slight") && !direc.toLowerCase().contains("straight")) && widget.user.pathobj.index > 4){

            if(widget.user.pathobj.associateTurnWithLandmark[nextTurn] != null){
              if(!UserState.ttsOnlyTurns){
                speak(
                    convertTolng(
                        "You are approaching ${direc} turn from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}",
                        _currentLocale,
                        '',
                        direc,
                        nextTurn!.node,""),
                    _currentLocale);
              }

              return;
              //widget.user.pathobj.associateTurnWithLandmark.remove(nextTurn);
            }else{
              if(!UserState.ttsOnlyTurns) {
                speak(
                    convertTolng("You are approaching ${direc} turn",
                        _currentLocale, '', direc, nextTurn!.node, ""),
                    _currentLocale);
              }
              widget.user.move(widget.context);
              return;
            }


          }
        }

>>>>>>> Stashed changes
    }
  }

  static Icon getCustomIcon(String direction) {
    if(direction == "Straight"){
      return Icon(
        Icons.straight,
        color: Colors.white,
        size: 40,
      );
    }else if(direction == "Slight Right"){
      return Icon(
        Icons.turn_slight_right,
        color: Colors.white,
        size: 40,
      );
    }else if(direction == "Right"){
      return Icon(
        Icons.turn_right,
        color: Colors.white,
        size: 40,
      );
    }else if(direction == "Sharp Right"){
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.white,
        size: 40,
      );
    }else if(direction == "U Turn"){
      return Icon(
        Icons.u_turn_right,
        color: Colors.white,
        size: 40,
      );
    }else if(direction == "Sharp Left"){
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.white,
        size: 40,
      );
    }else if(direction == "Left"){
      return Icon(
        Icons.turn_left,
        color: Colors.white,
        size: 40,
      );
    }else if(direction == "Slight Left"){
      return Icon(
        Icons.turn_slight_left,
        color: Colors.white,
        size: 40,
      );
    }else{
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.white,
        size: 40,
      );
    }
  }

  Icon getNextCustomIcon(String direction) {
    if(direction == "Straight"){
      return Icon(
        Icons.straight,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Slight Right"){
      return Icon(
        Icons.turn_slight_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Right"){
      return Icon(
        Icons.turn_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Sharp Right"){
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "U Turn"){
      return Icon(
        Icons.u_turn_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Sharp Left"){
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Left"){
      return Icon(
        Icons.turn_left,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Slight Left"){
      return Icon(
        Icons.turn_slight_left,
        color: Colors.white,
        size: 23,
      );
    }else{
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.white,
        size: 23,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Semantics(
      excludeSemantics: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 8,bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight: Radius.circular(16)),
              color: widget.user.pathobj.directions[DirectionIndex].isDestination?Colors.blue:DirectionIndex == nextTurnIndex ?Color(0xff01544F):Colors.grey,

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semantics(

                  excludeSemantics: true,
                  child: Container(
                    width: 44,
                    height: 44,
                    child: IconButton(onPressed: (){setState(() {
                      if(DirectionIndex - 1 >=1){
                        DirectionIndex--;
                        widget.focusOnTurn(widget.user.pathobj.directions[DirectionIndex]);
                        if(DirectionIndex == nextTurnIndex){
                          widget.clearFocusTurnArrow();
                        }
                      }
                    });}, icon: Icon(Icons.arrow_back_ios_new,color: DirectionIndex - 1 >=1?Colors.white:Colors.grey,)),
                  ),
                ),
                const SizedBox(width: 8,),
                scrollableDirection("${widget.direction}", '${(widget.distance/UserState.stepSize).ceil()}', getCustomIcon(widget.direction),DirectionIndex,nextTurnIndex,widget.user.pathobj.directions,widget.user),
                const SizedBox(width: 8,),
                Semantics(
                  excludeSemantics: true,
                  child: Container(
                    width: 44,
                    height: 44,
                    child: IconButton(onPressed: (){setState(() {
                      if(DirectionIndex + 1 < widget.user.pathobj.directions.length){
                        DirectionIndex++;
                        widget.focusOnTurn(widget.user.pathobj.directions[DirectionIndex]);
                        if(widget.user.pathobj.directions.length-DirectionIndex == 2 && widget.user.pathobj.directions[DirectionIndex].distanceToNextTurn != null && widget.user.pathobj.directions[DirectionIndex].distanceToNextTurn!<=5 && DirectionIndex + 1 < widget.user.pathobj.directions.length){
                          DirectionIndex++;
                        }
                        if(DirectionIndex == nextTurnIndex){
                          widget.clearFocusTurnArrow();
                        }
                      }
                    });}, icon: Icon(Icons.arrow_forward_ios_outlined,color: DirectionIndex + 1 < widget.user.pathobj.directions.length?Colors.white:Colors.grey,size: 24,)),
                  ),
                )
              ],
            ),
          ),
<<<<<<< Updated upstream
          DirectionIndex == nextTurnIndex?Container(
            width: 98,
            height: 39,
            margin: EdgeInsets.only(left: 9,top: 5),
            padding: EdgeInsets.only(left: 16,right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: Color(0xff013633),
            ),
            child: Row(
              children: [
                Text(
                  "Then",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffFFFFFF),
                    height: 25/16,
=======
          DirectionIndex == nextTurnIndex?Semantics(
            excludeSemantics: true,
            child: Container(
              width: 98,
              height: 39,
              margin: EdgeInsets.only(left: 9,top: 5),
              padding: EdgeInsets.only(left: 16,right: 16),
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
                      height: 25/16,
                    ),
                    textAlign: TextAlign.left,
>>>>>>> Stashed changes
                  ),
                  SizedBox(width: 6,),
                  // Text(DirectionIndex.toString()),
                  // Text(nextTurnIndex.toString())
                  getNextCustomIcon(turnDirection)
                ],
              ),
            ),
          ):Container()
        ],
      ),
    );
  }
}

class scrollableDirection extends StatelessWidget {
  String Direction;
  String steps;
  Icon i;
  int DirectionIndex;
  int nextTurnIndex;
  List<direction> listOfDirections;
  UserState user;

  scrollableDirection(this.Direction,this.steps,this.i,this.DirectionIndex,this.nextTurnIndex,this.listOfDirections,this.user);

  String chooseDirection(){
<<<<<<< Updated upstream
    if(listOfDirections[DirectionIndex].isDestination){
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
      return angle!=null?"${listOfDirections[DirectionIndex].turnDirection} will be ${tools.angleToClocks3(angle)}":
      "${listOfDirections[DirectionIndex].turnDirection} will be on your front";
    }else if(DirectionIndex == nextTurnIndex){
      return "${Direction == "Straight"?"Go Straight":"Turn ${Direction}, and Go Straight"}";
    }else{
      if(DirectionIndex<listOfDirections.length){
        return "${listOfDirections[DirectionIndex].turnDirection == "Straight"?"Go Straight":"Turn ${listOfDirections[DirectionIndex].turnDirection}, and Go Straight"}";
      }else{
        return "${listOfDirections[DirectionIndex-1].turnDirection == "Straight"?"Go Straight":"Turn ${listOfDirections[DirectionIndex-1].turnDirection}, and Go Straight"}";
=======
    
    try {
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
          return angle != null ? "${listOfDirections[DirectionIndex]
              .turnDirection} ${LocaleData.willbe.getString(
              context)} ${LocaleData
              .getProperty(tools.angleToClocks3(angle, context), context) }" :
          "${listOfDirections[DirectionIndex].turnDirection} ${LocaleData
              .willbeonyourfront.getString(context)}";
        } else if (DirectionIndex == nextTurnIndex) {
          return "${Direction == "Straight" ? "${LocaleData.gostraight
              .getString(
              context)}" : LocaleData.getProperty(Direction, context)}";
        } else {
          if (DirectionIndex < listOfDirections.length) {
            return "${listOfDirections[DirectionIndex].turnDirection ==
                "Straight"
                ? "${LocaleData.gostraight.getString(context)}"
                : "${LocaleData.getProperty(
                listOfDirections[DirectionIndex].turnDirection!, context)}"}";
          } else {
            return "${listOfDirections[DirectionIndex - 1].turnDirection ==
                "Straight"
                ? "${LocaleData.gostraight.getString(context)}"
                : "${LocaleData.getProperty(
                listOfDirections[DirectionIndex - 1].turnDirection!,
                context)},"}";
          }
        }
      } else {
        return "${LocaleData.gostraight.getString(context)}";
>>>>>>> Stashed changes
      }
    }
  }

  String chooseSteps(){
    if(listOfDirections[DirectionIndex].isDestination){
     return "";
    }else if(DirectionIndex == nextTurnIndex){
      return '$steps Steps';
    }else{
      return '${((listOfDirections[DirectionIndex].distanceToNextTurn??1)/UserState.stepSize).ceil()} Steps';
    }
  }

  Icon chooseIcon(){
    if(listOfDirections[DirectionIndex].isDestination){
     return Icon(Icons.place_rounded,color: Colors.white,size: 40,);
    }else if(DirectionIndex == nextTurnIndex){
      return i;
    }else{
      return _DirectionHeaderState.getCustomIcon(listOfDirections[DirectionIndex].turnDirection!);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return  Expanded(

      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: "${chooseDirection() } ${chooseSteps()}",
              excludeSemantics: true,
              child: Center(
                child: Text(
                  chooseDirection(),
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 30/24,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
<<<<<<< Updated upstream
          Container(
            width: 75,
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                listOfDirections[DirectionIndex].isDestination?Container():Text(
                  chooseSteps(),
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 26/16,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  height: 40,
                  width: 40,
                  child: chooseIcon(),
                ),
              ],
=======
          Semantics(
            excludeSemantics: true,
            child: Container(
              width: 85,
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ((chooseDirection().toLowerCase().contains("lift") || chooseDirection().toLowerCase().contains("stair")) || listOfDirections.isEmpty || (DirectionIndex>0 && listOfDirections.length>DirectionIndex && listOfDirections[DirectionIndex].isDestination))?Container():Text(
                    chooseSteps().replaceAll("meter", "m"),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 26/16,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white, // Set background color to white
                      shape: BoxShape.circle, // Make the container a circle
                    ),
                    child: chooseIcon(), // Your icon or widget inside the circle
                  )

                ],
              ),
>>>>>>> Stashed changes
            ),
          )],
      ),
    );
  }
}

