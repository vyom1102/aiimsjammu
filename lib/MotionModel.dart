import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;
import 'API/buildingAllApi.dart';
import 'Cell.dart';
import 'UserState.dart';
import 'navigationTools.dart';

class MotionModel{
  static int stuckCount = 0;
  static bool isValidStep(UserState user, int cols, int rows, List<int>? nonWalkable, Function reroute, BuildContext context){
    if(user.pathobj.index+1 > user.cellPath.length-1){
      UserState.closeNavigation();
    }
    if(user.onConnection || user.temporaryExit){
      print("isValid false due to lift");
      return false;
    }
    print("user.pathobj.index:${user.pathobj.index}");
    try{
      Cell prevCell = user.cellPath[user.pathobj.index - 1];
      Cell nextCell = user.cellPath[user.pathobj.index + 1];
      if(prevCell.x==user.cellPath[user.pathobj.index].x && prevCell.y==user.cellPath[user.pathobj.index].y){
        prevCell=user.cellPath[user.pathobj.index - 2];
      }
      if((nextCell.x==user.cellPath[user.pathobj.index].x && nextCell.y==user.cellPath[user.pathobj.index].y)){
        nextCell=user.cellPath[user.pathobj.index + 2];
      }
      if(user.isTurnCheck(prevCell,nextCell) && stopOnTurn(user)){
        print("isTurnCheck:condition is true");
        UserState.recenterMap;
        return false;
      }
    }catch(e){
      print("motionmdoel turn stopping error $e");
    }
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    if(user.isnavigating){
      transitionValue = user.cellPath[user.pathobj.index+1].move(user.theta);
    }
    int newX = user.coordX + transitionValue[0];
    int newY = user.coordY + transitionValue[1];
    print("newxnewy $newX,$newY");
    if(newX<0 || newX >=cols || newY < 0 || newY >= rows){
      print("isValid false due to building boundary ${user.bid} ${StackTrace.current}");
      // return false;
    }
    if(nonWalkable != null && nonWalkable.contains((newY*cols)+newX)){
      print("motionmodel $newY $newX $cols ${(newY*cols)+newX}");
      stuckCount++;
      if(stuckCount==5){
        //if the pointer gets stuck in the non walkable during navigation.
        if(user.bid == buildingAllApi.outdoorID || user.cellPath[user.pathobj.index].masterGraph){
          user.moveToPointOnPathOnPath(context, ((stuckCount*UserState.stepSize)-1).toInt());
        }else{
          user.moveToPointOnPath((user.pathobj.index+(stuckCount*UserState.stepSize)-1).toInt(), context);
        }

        stuckCount = 0;
      }
      print("isValid false due to stuck in nonWalkable $stuckCount");
      return false;
    }
    try{
      print("motion model ${[user.coordX,user.coordY]} <> ${[user.showcoordX,user.showcoordY]}");
      if(user.cellPath[user.pathobj.index+1].move == tools.twocelltransitionhorizontal || user.cellPath[user.pathobj.index+1].move == tools.twocelltransitionvertical){
        if(tools.calculateDistance([user.coordX,user.coordY], [user.showcoordX,user.showcoordY])>(user.bid==buildingAllApi.outdoorID?40:20)){
          // reroute();
        }
      }else{
        if(tools.calculateDistance([user.coordX,user.coordY], [user.showcoordX,user.showcoordY])>(user.bid==buildingAllApi.outdoorID?40:20)){
          // reroute();
        }
      }
    }catch(e){}
    return true;
  }

  static bool isTurnCheck(UserState user) {
    bool isTurn = false;
    int prevX = user.cellPath[user.pathobj.index - 1].x;
    int prevY = user.cellPath[user.pathobj.index - 1].y;
    int nextX = user.cellPath[user.pathobj.index + 1].x;
    int nextY = user.cellPath[user.pathobj.index + 1].y;
    print("{[prevX, prevY]} ${[prevX, prevY]}, ${[user.showcoordX, user.showcoordY]}, ${[nextX, nextY]}");
    if (user.bid == buildingAllApi.outdoorID) {
      print("MotionModel isTurnCheck outdoor");
      if(user.cellPath[user.pathobj.index - 1].bid == user.cellPath[user.pathobj.index].bid &&
          user.cellPath[user.pathobj.index].bid == user.cellPath[user.pathobj.index + 1].bid &&
          user.cellPath[user.pathobj.index + 1].bid == user.bid){
        if(user.pathobj.index > 0 && user.pathobj.index < user.cellPath.length - 1){
          double angle = tools.angle(user.cellPath[user.pathobj.index - 1], user.cellPath[user.pathobj.index], user.cellPath[user.pathobj.index + 1]);
          print("MotionModel isTurnCheck angle $angle");
          if(angle > 34.5){
            print("MotionModel isTurnCheck outdoor true");
            isTurn = true;
          }
        }
      }else{
        print("MotionModel isTurnCheck outdoor false");
        isTurn = false;
      }
    } else if (tools.isTurn([prevX, prevY], [user.showcoordX, user.showcoordY], [nextX, nextY])) {
      print('Motion Model Indoor turn check true.');
      isTurn = true;
    }
    // if(isTurn){
    //   _pocketModeController.updateLastHeading();
    // }else{
    //   _pocketModeController.clearLastHeading();
    // }
    return isTurn;
  }
  static bool stopOnTurn(UserState user) {
    if (user.isnavigating && user.pathobj.numCols![user.bid] != null) {
        int col = user.pathobj.numCols![user.bid]![user.floor]!;
        if (reached(user, col) == false && user.bid == user.cellPath[user.pathobj.index + 1].bid) {
          List<int> a = [user.showcoordX, user.showcoordY];
          List<int> tval = tools.eightcelltransition(user.theta);

          List<int> b = [user.showcoordX + tval[0], user.showcoordY + tval[1]];

          int node = user.path[user.pathobj.index + 1];

          List<int> c = [node % col, node ~/ col];
          int val = tools.calculateAngleSecond(a, b, c).toInt();
          if (user.bid == buildingAllApi.outdoorID || (user.cellPath[user.pathobj.index].masterGraph)) {
            print("val we got:${val}");
            double a = user.theta<0?user.theta+360:user.theta;
            val = (tools.calculateBearing_fromLatLng(
                geo.LatLng(user.cellPath[user.pathobj.index].lat, user.cellPath[user.pathobj.index].lng),
                geo.LatLng(user.cellPath[user.pathobj.index + 1].lat, user.cellPath[user.pathobj.index + 1].lng)) - a).toInt().abs();
            if(val<60 && val>-60){
              val = 0;
            }
            print("val we got:${val}");
          }
          if (val<22.5 && val>-22.5) {
            return false;
          }else{
            return true;
          }
        }

    }
    return false;
  }
  static bool reached(UserState state,int col){
    int x=0;
    int y=0;
    if(state.path.length>0){
      x=state.path[state.path.length-1]%col ;
      y=state.path[state.path.length-1]~/col;
    }
    if(state.showcoordX==x && state.showcoordY==y){
      return true;
    }

    return false;
  }


}