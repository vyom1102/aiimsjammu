import 'dart:math' as math;
import 'package:iwaymaps/EventModel/APIModel/CategoryModel.dart';
import 'package:iwaymaps/EventModel/APIModel/SessionModel.dart';
import 'package:iwaymaps/EventModel/APIModel/SubEventsModel.dart';
import 'package:iwaymaps/singletonClass.dart';
import 'API/PatchApi.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;
import 'API/PolyLineApi.dart';
import 'API/buildingAllApi.dart';
import 'API/ladmarkApi.dart';
import 'API/slackApi.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'EventModel/APIModel/ExhibitorModel.dart';
import 'NAVIGATIONTools.dart';
import 'Repository/RepositoryManager.dart';
import 'UserState.dart';
import 'buildingState.dart';

class NavigationAPIController {
  Function createPatch = (patchDataModel value) {};
  Function createotherPatch = (String key, patchDataModel value) {};
  Function findCentroid = (List<Coordinates> vertices, String bid) {};
  Function createRooms = (polylinedata value, int floor){};
  Function createARPatch = (Map<int, geo.LatLng> coordinates){};
  Function createotherARPatch = (Map<int, geo.LatLng> coordinates, String bid){};
  Function createMarkers = (land landData, int floor, {String? bid}){};

  NavigationAPIController(
      {required this.createPatch,
        required this.createotherPatch,
        required this.findCentroid,
        required this.createRooms,
        required this.createARPatch,
        required this.createotherARPatch,
        required this.createMarkers
      });

  Future<void> patchAPIController(String id, bool selected, {patchDataModel? patchData}) async {
    print("patch for $id");
    // try {
      patchData ??= await RepositoryManager().getPatchDataNew(id) as patchDataModel;

    Building.buildingData ??= Map();
    Building.buildingData![patchData.patchData!.buildingID!] =
        patchData.patchData!.buildingName;
    SingletonFunctionController
        .building.patchData[patchData.patchData!.buildingID!] = patchData;
    if (selected) {
      createPatch(patchData);
    } else {
      // createotherPatch(id, patchData);
    }
    findCentroid(patchData.patchData!.coordinates!, id);

    if (selected) {
      tools.globalData = patchData;
      tools.setBuildingAngle(patchData.patchData!.buildingAngle!);

      for (var i = 0; i < 4; i++) {
        tools.corners.add(math.Point(
            double.parse(patchData.patchData!.coordinates![i].globalRef!.lat!),
            double.parse(
                patchData.patchData!.coordinates![i].globalRef!.lng!)));
      }
    }

    var currentFloorDimensions = SingletonFunctionController
        .building.floorDimenssion[id] ??
        {};

    currentFloorDimensions[0] = [
      int.parse(patchData.patchData!.length!),
      int.parse(patchData.patchData!.breadth!)
    ];

    SingletonFunctionController.building.floorDimenssion[id] =
        currentFloorDimensions;
    // }catch(e){}
  }

  Future<land?> landmarkAPIController(String id, bool selected, {land? landmarkData, List<ExhibitorModel>? exhibitors, Categorymodel? categories, SessionModel? sessions, SubEventsModel? subEvents}) async {
    landmarkData ??= await RepositoryManager().getLandmarkDataNew(id) as land;
    if(exhibitors != null && exhibitors.isNotEmpty){
      landmarkData.populateRenderDetailsUsingExhibitor(exhibitors);
    }
    if(categories != null && categories.data != null && categories.data!.isNotEmpty &&
        sessions != null && sessions.data != null && sessions.data!.isNotEmpty &&
        subEvents != null && subEvents.data != null && subEvents.data!.isNotEmpty){
      landmarkData.populateRenderDetailsUsingEvent(categories.data!, sessions.data!, subEvents.data!);
    }
    var Data = await SingletonFunctionController.building.landmarkdata;
    if(selected || Data == null){
      SingletonFunctionController.building.landmarkdata = Future.value(landmarkData);
    }else{
      var otherLandmarkdata = await SingletonFunctionController.building.landmarkdata;
      otherLandmarkdata?.mergeLandmarks(landmarkData.landmarks);
      SingletonFunctionController.building.landmarkdata = Future.value(otherLandmarkdata);
    }


    print("data recieved for ${landmarkData.landmarks!.first.buildingName}");

    var coordinates = <int, geo.LatLng>{};

    for (var landmark in landmarkData.landmarks!) {
      if (landmark.element!.subType == "AR"&&
          landmark.properties!.arName ==
              "P${int.parse(landmark.properties!.arValue!)}") {
        coordinates[int.parse(landmark.properties!.arValue!)] = geo.LatLng(
            double.parse(landmark.properties!.latitude!),
            double.parse(landmark.properties!.longitude!));
      }

      if (landmark.element!.type == "Floor") {
        var nonWalkableGrids = landmark.properties!.nonWalkableGrids!.join(',');
        var regExp = RegExp(r'\d+');
        var matches = regExp.allMatches(nonWalkableGrids);
        var allIntegers =
        matches.map((match) => int.parse(match.group(0)!)).toList();

        var currentNonWalkable = SingletonFunctionController
            .building.nonWalkable[landmark.buildingID!] ??
            {};
        currentNonWalkable[landmark.floor!] = allIntegers;

        SingletonFunctionController.building.nonWalkable[landmark.buildingID!] =
            currentNonWalkable;

        if(selected){
          UserState.nonWalkable = SingletonFunctionController.building.nonWalkable;
        }


        var currentFloorDimensions = SingletonFunctionController.building.floorDimenssion[id] ?? {};
        currentFloorDimensions[landmark.floor!] = [landmark.properties!.floorLength!, landmark.properties!.floorBreadth!];
        print("adding dimensions ${[landmark.properties!.floorLength!, landmark.properties!.floorBreadth!]} for ${landmark.floor} in ${landmark.buildingName} ${landmark.buildingID}");

        SingletonFunctionController
            .building.floorDimenssion[id] =
            currentFloorDimensions;
      }
      var currentFloorDimensions = SingletonFunctionController.building.floorDimenssion[id] ?? {};
      if(currentFloorDimensions[landmark.floor!] == null && currentFloorDimensions[0] != null){
        currentFloorDimensions[landmark.floor!] = currentFloorDimensions[0]!;
        SingletonFunctionController
            .building.floorDimenssion[id] =
            currentFloorDimensions;
      }
    }
    if (SingletonFunctionController
        .building.floorDimenssion[id] ==
        null) {
      sendErrorToSlack(
          "Floor data is null for ${id}", null);
    }
    if(SingletonFunctionController.building.nonWalkable[landmarkData.landmarks!.first.buildingID!] == null){
      Map<int, List<int>> imaginedNonWalkable = {0:[]};
      SingletonFunctionController.building.nonWalkable[landmarkData.landmarks!.first.buildingID!] = imaginedNonWalkable;
    }
    createMarkers(landmarkData, 0, id);
    ARPatch(id, selected, coordinates: coordinates);
    return await SingletonFunctionController.building.landmarkdata;
  }

  Future<void> ARPatch(String id, bool selected, {Map<int, geo.LatLng>? coordinates}) async {
    if(coordinates == null){
      var landmarkData = await RepositoryManager().getLandmarkDataNew(id) as land;
      coordinates = <int, geo.LatLng>{};
      for (var landmark in landmarkData.landmarks!) {
        if (landmark.element!.subType == "AR" &&
            landmark.properties!.arName ==
                "P${int.parse(landmark.properties!.arValue!)}") {
          coordinates[int.parse(landmark.properties!.arValue!)] = geo.LatLng(
              double.parse(landmark.properties!.latitude!),
              double.parse(landmark.properties!.longitude!));
        }
      }
    }

    if(selected){
      print("createARPatch call");
      createARPatch(coordinates);
      if (SingletonFunctionController.building.ARCoordinates.containsKey(id) && coordinates.isNotEmpty) {
        SingletonFunctionController.building.ARCoordinates[id] = coordinates;
        print("patchmade for${SingletonFunctionController.building.ARCoordinates.keys} ${StackTrace.current}");
      }
    }else{
      print("createARPatch other call");
      createotherARPatch(coordinates, id);
    }
  }
  Future<polylinedata> polylineAPIController(String id, bool selected, {polylinedata? polylineData}) async {
    polylineData ??= await RepositoryManager().getPolylineDataNew(id) as polylinedata;
    SingletonFunctionController.building
        .polylinedatamap[id] = polylineData;
    SingletonFunctionController
        .building.numberOfFloors[id] =
        polylineData.polyline!.floors!.length;
    Building.numberOfFloorsDelhi[id] =
        polylineData.polyline!.floors!.map((element) {
          return tools.alphabeticalToNumerical(element.floor!);
        }).toList();
    print("createroomscalledfor${id} ${polylineData.polylineExist}");
    createRooms(polylineData, 0);
    SingletonFunctionController.building.floor[id] = 0;
    return polylineData;
  }
 static polylinedata? data;
 static Future<List<Nodes>> extractWaypoints() async {
    print("called");
    // data ??= await PolyLineApi().fetchPolyData(id:buildingAllApi.selectedBuildingID);
    data ??= await RepositoryManager().getPolylineDataNew(buildingAllApi.selectedBuildingID);
    List<Nodes> waypoints = [];
    for (var floors in data!.polyline!.floors!) {
      for (var polys in floors.polyArray!) {
        if (polys.polygonType == "Waypoints" && 3 == tools.alphabeticalToNumerical(polys.floor!)) {
          for (var node in polys.nodes!) {
            // Check if node is at least 2 meters away from all nodes in waypoints
            bool isFarEnough = waypoints.every((existingNode) =>
            tools.calculateAerialDist(
                existingNode.lat!, existingNode.lon!, node.lat!, node.lon!) >= 2);

            if (isFarEnough) {
              waypoints.add(node);
            }
          }
        }
      }
    }
    print("waypoints ${waypoints.length}");
    return waypoints;
  }
}
