import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '/API/RefreshTokenAPI.dart';
import '/APIMODELS/outdoormodel.dart';
import '/config.dart';
import '/APIMODELS/beaconData.dart';
import '/APIMODELS/buildingAll.dart';
import '/APIMODELS/polylinedata.dart';
import '/APIMODELS/landmark.dart';
import '../DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import '../DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';


class buildingAllApi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/building/all";
  static var signInBox = Hive.box('SignInDatabase');
  var versionBox = Hive.box('VersionData');
  String accessToken = signInBox.get("accessToken");
  static outdoormodel? outBuildingData = null;
  static String selectedID="";
  static String selectedBuildingID="";
  static String selectedVenue="AIIMSJAMMU";
  static Map<String,g.LatLng> allBuildingID = {"66794105b80a6778c53c4856": g.LatLng(32.56361449037205,
      75.03635674681276),
    "6798c6df96af63c3e82659ec": g.LatLng(32.56407494260096,
        75.03513729442497),
    "6798c81c96af63c3e826add3": g.LatLng(32.56457352216475,
        75.035511009239),
    "6798c8fa96af63c3e8277db2": g.LatLng(32.56387091813491,
        75.03579721455554),
    "6798c99e96af63c3e828203d": g.LatLng(32.56413312709048,
        75.03661931346608),
    "6798ce3596af63c3e8294dbc": g.LatLng(32.565109981338004,
        75.03320147595436),
    "679ca3fde7e7001d98497002": g.LatLng(32.56599416559548,
        75.03392001626828),
    "67e190f9494c674815c10628": g.LatLng(32.56383615415665,
        75.039034761183),
    "6798ca0396af63c3e828c472": g.LatLng(32.56292907666193,
        75.03840723939935),
  };
  static Map<String,g.LatLng> globalBuildingIDS = {};
  static String outdoorID = "67986e4114ef508e9429a5ad";
  static Map<String,g.LatLng> onlyRenderBuildingID = {};


  void checkForUpdate() async {
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();
    accessToken = signInBox.get("accessToken");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      final buildingData = BuildingAllAPIModel(responseBody: responseBody);
      String APITime = responseBody[0]['updatedAt']!;

      if(BuildingAllBox.length==0){
        print("BUILDINGALL UPDATE BOX EMPTY AND SAVED IN THE DATABASE");
        BuildingAllBox.add(buildingData);
        buildingData.save();
      }else{
        List<dynamic> databaseresponseBody = BuildingAllBox.getAt(0)!.responseBody;
        String LastUpdatedTime = databaseresponseBody[0]['updatedAt']!;
        if(APITime != LastUpdatedTime){
          print("BUILDINGALL UPDATE API DATA FROM DATABASE AND UPDATED");
          print("Current Time: ${APITime} Last updated Time: ${LastUpdatedTime}");
          BuildingAllBox.add(buildingData);
          buildingData.save();
        }
      }
    }else if(response.statusCode == 403) {
      print('DATA VERSION API in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      return checkForUpdate();
    }else{
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }

  Future<List<buildingAll>> fetchBuildingAllData() async {
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();

    if(BuildingAllBox.length!=0){
      print("BUILDINGALL API DATA FROM DATABASE");
      print(BuildingAllBox.length);
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAll> buildingList = responseBody
          .where((data) => data['initialBuildingName'] != null)
          .map((data) => buildingAll.fromJson(data))
          .toList();
      return buildingList;
    }

    accessToken = signInBox.get("accessToken");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      final buildingData = BuildingAllAPIModel(responseBody: responseBody);
      print("BUILDING API DATA FROM API");
      BuildingAllBox.add(buildingData);
      buildingData.save();
      List<buildingAll> buildingList = responseBody
          .where((data) => data['initialBuildingName'] != null)
          .map((data) => buildingAll.fromJson(data))
          .toList();
      return buildingList;

    }else if(response.statusCode == 403){
      print('DATA VERSION API in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      return fetchBuildingAllData();
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }

  static void findBuildings(List<buildingAll> allBuildings){
    List<buildingAll> buildings = [];
    for (var building in allBuildings) {
      if(building.venueName == selectedVenue){
        buildings.add(building);
      }
    }
    for (var element in buildings) {
      g.LatLng kk = g.LatLng(element.coordinates![0], element.coordinates![1]);
      allBuildingID[element.sId!] = kk;
    }
    selectedID = allBuildingID.keys.first;
    selectedBuildingID = allBuildingID.keys.first;
  }

  // Method to set the stored string
  static Future<void> setStoredString(String value) async {
    selectedID = value;
    return;
  }

  // Method to get the stored string
  static String getStoredString() {
    return selectedID;
  }

  static void setStoredAllBuildingID(HashMap<String,g.LatLng> value){
    allBuildingID = value;
  }

  static Map<String,g.LatLng> getStoredAllBuildingID(){
    return allBuildingID;
  }


  // Method to set the stored string
  static void setStoredVenue(String value) {
    selectedVenue = value;
    //print("Set${selectedID}");
  }

  static void setSelectedBuildingID(String value)async{
    print("inside inside set id $value");
    selectedBuildingID = value;
    return;
  }

  static String getSelectedBuildingID() {
    return selectedBuildingID;
  }

  // Method to get the stored string
  static String getStoredVenue() {
    //print(selectedID);
    return selectedVenue;
  }

}