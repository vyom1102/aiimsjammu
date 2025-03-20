import '../APIMODELS/GlobalAnnotationModel.dart';
import '../APIMODELS/landmark.dart';
import '../APIMODELS/polylinedata.dart';
import '../navigationTools.dart';
import '../navigation_api_controller.dart';
import '../waypoint.dart' as way;
import 'global_rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;


class GlobalAnnotationController {
  GlobalModel data;
  Function polygonTap = (List<geo.LatLng> coordinates, String id) {};
  NavigationAPIController apiController;
  GlobalAnnotationController({required this.data, required this.polygonTap, required this.apiController});

  List<way.PathModel>? wrapWayPoint() {
    print("wrapWayPoint");
    PathNetwork? pathNetwork = data.pathNetwork;
    if(pathNetwork == null){
      return null;
    }
    Map<dynamic, dynamic> JSONPathNetwork = pathNetwork.toJson();
    JSONPathNetwork["pathNetworkGlobal"] = swapLatLng(JSONPathNetwork["pathNetworkGlobal"]);
    JSONPathNetwork["floor"] = 0;
    JSONPathNetwork["building_ID"] = data.mappingElements?.first.buildingID;
    way.PathModel wayPointList = way.PathModel.fromJson(JSONPathNetwork as Map<dynamic, dynamic>);
    print("wayPointList returned is $wayPointList");
    return [wayPointList];
  }

  Map<String, dynamic> swapLatLng(dynamic pathNetwork) {
    Map<String, List<dynamic>> modifiedMap = {};

    pathNetwork.forEach((key, value) {
      String newKey = key.split(',').reversed.join(',');
      List<dynamic> newValues = value.map((v) => v.split(',').reversed.join(',')).toList();

      modifiedMap[newKey] = newValues;
    });

    return modifiedMap;
  }

  Future<void> wrapPatch() async {
    await apiController.patchAPIController(data.mappingElements!.first.buildingID!, false);
    await apiController.landmarkAPIController(data.mappingElements!.first.buildingID!, false);
  }

  Future<List<Landmarks>?> wrapLandmarks() async {
    List<Landmarks>? landmarks = null;
    data.mappingElements?.forEach((element){
      if(element.geometry?.type == "Point"){
        print("associatedPolygons are ${element.associatedPolygons}");
        print("Found point ${element.properties!.name}");
        Map<dynamic, dynamic> JSON = {
          "element": {
            "type": "Rooms",
            "subType": "room door"
          },
          "properties": {
            "nonWalkableGrids": [],
            "flr_dist_matrix": [],
            "frConn": [],
            "clickedPoints": [],
            "polygonId": [],
            "polygonExist": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty),
            "polyId": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty)?element.associatedPolygons![0]:element.id,
            "latitude": "${element.geometry?.coordinates?[1]}",
            "node": null,
            "longitude": "${element.geometry?.coordinates?[0]}"
          },
          "_id": element.id,
          "building_ID": element.buildingID,
          "coordinateX": element.geometry?.coordinatesLocal?[0],
          "coordinateY": element.geometry?.coordinatesLocal?[1],
          "doorX": element.geometry?.coordinatesLocal?[0],
          "doorY": element.geometry?.coordinatesLocal?[1],
          "type": element.type,
          "floor": 0,
          "name": element.properties?.name,
          "buildingName": data.buildingName,
          "venueName": data.venueName
        };
        Landmarks landmark = Landmarks.fromJson(JSON);
        print(landmark.properties!.polyId);
        landmarks ??= [];
        landmarks?.add(landmark);
      }
    });

    return landmarks;
  }


  static Future<List<Landmarks>?> OptionalWrapLandmarks(GlobalModel localData) async {
    List<Landmarks>? landmarks = null;
    localData.mappingElements?.forEach((element){
      if(element.geometry?.type == "Point"){
        print("associatedPolygons are ${element.associatedPolygons}");
        print("Found point ${element.properties!.name}");
        Map<dynamic, dynamic> JSON = {
          "element": {
            "type": "Rooms",
            "subType": "room door"
          },
          "properties": {
            "nonWalkableGrids": [],
            "flr_dist_matrix": [],
            "frConn": [],
            "clickedPoints": [],
            "polygonId": [],
            "polygonExist": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty),
            "polyId": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty)?element.associatedPolygons![0]:element.id,
            "latitude": "${element.geometry?.coordinates?[1]}",
            "node": null,
            "longitude": "${element.geometry?.coordinates?[0]}"
          },
          "_id": element.id,
          "building_ID": element.buildingID,
          "coordinateX": element.geometry?.coordinatesLocal?[0],
          "coordinateY": element.geometry?.coordinatesLocal?[1],
          "doorX": element.geometry?.coordinatesLocal?[0],
          "doorY": element.geometry?.coordinatesLocal?[1],
          "type": element.type,
          "floor": 0,
          "name": element.properties?.name,
          "buildingName": localData.buildingName,
          "venueName": localData.venueName
        };
        Landmarks landmark = Landmarks.fromJson(JSON);
        print(landmark.properties!.polyId);
        landmarks ??= [];
        landmarks?.add(landmark);
      }
    });

    return landmarks;
  }

  Future<Set<geo.Polygon>?> renderCampus() async {
    return await globalRendering(data,polygonTap);
  }

  polylinedata? wrapPolyline() {
    Map<int,List<PolyArray>> floor = {};
    data.mappingElements?.forEach((element){
      if(element.geometry?.type == "LineString"){
        floor.putIfAbsent(element.properties!.level!, ()=>[]);
        List<Nodes> nodes = [];
        for(int i = 0; i<element.geometry!.coordinates!.length; i++){
          var node = Nodes()
          ..coordx = element.geometry!.coordinatesLocal![i][0]
          ..coordy = element.geometry!.coordinatesLocal![i][1]
          ..lat = element.geometry!.coordinates![i][1]
          ..lon = element.geometry!.coordinates![i][0];
         nodes.add(node);
        }
        var poly = PolyArray()
        ..polygonType = "Waypoints"
          ..floor = tools.numericalToAlphabetical(element.properties!.level!)
        ..nodes = nodes;
        floor[element.properties!.level!]!.add(poly);
      }
    });
    if(floor.isEmpty){
      return null ;
    }
    List<Floors> floorObjects = [];
    floor.forEach((floor,polyArray){
      var Floor = Floors()
          ..polyArray = polyArray
          ..floor = tools.numericalToAlphabetical(floor);
      floorObjects.add(Floor);
    });
    if(floorObjects.isEmpty){
      return null ;
    }
    var polylineObject = Polyline()
    ..floors = floorObjects
    ..buildingID = data.mappingElements!.first.buildingID;

    var polylineData = polylinedata()
    ..polylineExist = true
    ..polyline = polylineObject;

    return polylineData;
  }

}