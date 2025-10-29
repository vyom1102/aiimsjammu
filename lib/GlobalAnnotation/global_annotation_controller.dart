import 'dart:math';
import '../APIMODELS/GlobalAnnotationModel.dart';
import '../APIMODELS/landmark.dart';
import '../APIMODELS/polylinedata.dart';
import '../NAVIGATIONTools.dart';
import '../navigation_api_controller.dart';
import '../singletonClass.dart';
import '../waypoint.dart' as way;
import 'global_rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;


class GlobalAnnotationController {
  GlobalModel data;
  Function? polygonTap = (List<geo.LatLng>? coordinates,   String id,   String path) {};
  NavigationAPIController? apiController;
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
    way.PathModel wayPointList = way.PathModel.fromJson(JSONPathNetwork);
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
    await apiController?.patchAPIController(data.mappingElements!.first.buildingID!, false);
    // await apiController.landmarkAPIController(data.mappingElements!.first.buildingID!, false);
  }

  Future<List<Landmarks>?> wrapLandmarks({polylinedata? polyline}) async {
    print("wrapLandmarks called for ${data.mappingElements!.first.buildingID!}");
    List<Landmarks>? landmarks = null;
    var coordinates = <int, geo.LatLng>{};
    data.mappingElements?.forEach((element){
      if(SingletonFunctionController.building.nonWalkable[element.buildingID]?[element.properties?.level??0] == null){
        SingletonFunctionController.building.nonWalkable.putIfAbsent(element.buildingID!, ()=>{});
        SingletonFunctionController.building.nonWalkable[element.buildingID]?.putIfAbsent(element.properties?.level??0, ()=>[]);
      }
      if(element.geometry?.type == "Point" && element.properties?.type != "Beacon"){
        if(element.properties?.type == "BP"){
          int number = int.parse(element.properties!.name!.replaceAll(RegExp(r'[^0-9]'), ''));
          coordinates[number] = geo.LatLng(element.geometry!.coordinates!.last!, element.geometry!.coordinates!.first!);
        }else{
          ///polygon finding
          PolyArray? polygon;
          geo.LatLng? globalCenter;
          Point<double>? localCenter;
          if(element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty){
            polyline?.polyline?.floors?.forEach((floor){
              floor.polyArray?.forEach((p){
                if(p.id == element.associatedPolygons![0]){
                  polygon = p;
                }
              });
            });
            if(polygon != null){
              List<geo.LatLng> globalPolygonPoints = [];
              List<List<int>> localPolygonPoints = [];
              polygon!.nodes?.forEach((node){
                globalPolygonPoints.add(geo.LatLng(node.lat!, node.lon!));
                localPolygonPoints.add([node.coordx!, node.coordy!]);
              });
              // print("element.properties?.name ${element.properties?.name}  ${tools.calculatePolygonArea(globalPolygonPoints)}");
              globalCenter = tools.calculateRoomCenter(globalPolygonPoints);
              localCenter = tools.calculateGridPolygonCenter(localPolygonPoints);
            }
          }
          // print("associatedPolygons for ${element.properties?.name} are ${element.associatedPolygons}");
          Map<dynamic, dynamic> JSON = {
            "element": {
              "type": "Global",
              "subType": element.properties?.type
            },
            "properties": {
              "nonWalkableGrids": [],
              "flr_dist_matrix": [],
              "frConn": [],
              "clickedPoints": [],
              "polygonId": [],
              "polygonExist": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty),
              "polyId": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty)?element.associatedPolygons![0]:null,
              "latitude": globalCenter != null ? "${globalCenter.latitude}":"${element.geometry?.coordinates?[1]}",
              "doorLat": "${element.geometry?.coordinates?[1]}",
              "node": null,
              "longitude": globalCenter != null ? "${globalCenter.longitude}":"${element.geometry?.coordinates?[0]}",
              "doorLng": "${element.geometry?.coordinates?[0]}"
            },
            "_id": element.sId,
            "building_ID": element.buildingID,
            "coordinateX": localCenter != null ? localCenter.x:element.geometry?.coordinatesLocal?[0],
            "coordinateY": localCenter != null ? localCenter.y:element.geometry?.coordinatesLocal?[1],
            "doorX": element.geometry?.coordinatesLocal?[0],
            "doorY": element.geometry?.coordinatesLocal?[1],
            "type": element.type,
            "floor": element.properties?.level??0,
            "name": element.properties?.name,
            "buildingName": data.buildingName,
            "venueName": data.venueName
          };
          Landmarks landmark = Landmarks.fromJson(JSON);
          landmarks ??= [];
          landmarks?.add(landmark);
        }
      }
    });
    print("for ${data.mappingElements!.first.buildingID!} coordinates are $coordinates");
    if(coordinates.isNotEmpty){
      apiController?.createotherARPatch(coordinates, data.mappingElements!.first.buildingID!);
    }

    return landmarks;
  }

  Future<Set<geo.Polygon>?> renderCampus() async {
    return await globalRendering(data,polygonTap!);
  }

  polylinedata? wrapPolyline() {
    Map<int,List<PolyArray>> floor = {};
    for(var element in data.mappingElements!){
      List<Nodes> nodes = [];
      floor.putIfAbsent(element.properties!.level!, ()=>[]);
      if(element.properties?.type?.toLowerCase() == "block layer"){
        continue;
      }
      if(element.geometry?.type == "LineString"){
        for(int i = 0; i<element.geometry!.coordinates!.length; i++){
          var node = Nodes()
            ..coordx = element.geometry!.coordinatesLocal![i][0]
            ..coordy = element.geometry!.coordinatesLocal![i][1]
            ..lat = element.geometry!.coordinates![i][1]
            ..lon = element.geometry!.coordinates![i][0];
          nodes.add(node);
        }
        var poly = PolyArray()
          ..id = element.id
          ..polygonType = "Waypoints"
          ..floor = tools.numericalToAlphabetical(element.properties!.level!)
          ..visibilityType = "visible"
          ..nodes = nodes;
        floor[element.properties!.level!]!.add(poly);
      }else if(element.geometry?.type == "Polygon"){
        if(element.properties?.type?.toLowerCase() == "outdoor block layer" || element.properties?.type?.toLowerCase() == "block layer") continue;
        for(int i = 0; i<element.geometry!.coordinates![0].length; i++){
          var node = Nodes()
            ..coordx = element.geometry!.coordinatesLocal![0][i][0]
            ..coordy = element.geometry!.coordinatesLocal![0][i][1]
            ..lat = element.geometry!.coordinates![0][i][1]
            ..lon = element.geometry!.coordinates![0][i][0];
          nodes.add(node);
        }
        var poly = PolyArray()
          ..sId = element.id
          ..id = element.id
          ..polygonType = (element.properties?.type??"room").toLowerCase() == "room"?'Room':'Cubicle'
          ..cubicleName = element.properties?.type??""
          ..name = element.properties?.name
          ..visibilityType = "visible"
          ..floor = tools.numericalToAlphabetical(element.properties!.level!)
          ..cubicleColor = element.properties?.fillColor
          ..nodes = nodes;
        floor[element.properties!.level!]!.add(poly);
      }
    }
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
