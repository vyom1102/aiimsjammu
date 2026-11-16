import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../API/buildingAllApi.dart';
import '../DATABASE/BOXES/BuildingByVenueMapAPIBOX.dart';
import '../ELEMENTS/HelperClass.dart';
import '../APIMODELS/Buildingbyvenue.dart';
import '../Userbox.dart';
import '../api/RefreshTokenAPI.dart';
import '../config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;


class Buildingbyvenueapi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/building/get/venue";

  static var signInBox = Hive.box('SignInDatabase');
  var versionBox = Hive.box('VersionData');
  String accessToken = signInBox.get("accessToken");

  Future<BuildingData> fetchBuildingIDS(String id) async {
    accessToken = signInBox.get("accessToken");
    //final BuildingByVenueBox = BuildingByVenueAPIBOX.getData();

    bool isInternetConnected = await HelperClass.checkInternetConnectivity();


    // if(!isInternetConnected && BuildingByVenueBox.length != 0){
    //   List<dynamic> responseBody = BuildingByVenueBox.get(0)!.responseBody;
    //   print("INTERNET IS NOT CONNECTED!! BUILDINGBYVENUE API DATA COMMING FROM DATABASE $responseBody");
    //   List<Buildingbyvenue> buildingList = responseBody.map((data) => Buildingbyvenue.fromJson(data)).toList();
    //   return buildingList;
    // }

    final Map<String, dynamic> data = {
      "venueName": id, //venue Name
      "campusIncludes":true
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken!,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      // final buildingByVenueData = BuildingByVenueAPIModel(responseBody: responseBody);
      print("BUILDINGBYVENUE API DATA FROM API $responseBody");
      //BuildingByVenueBox.add(buildingByVenueData);
      // buildingByVenueData.save();
      BuildingData buildingList = BuildingData.fromJson(responseBody);
      return buildingList;

    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return fetchBuildingIDS(id);
    } else {
      print("else ${response.body}");
      print(response.body);
      throw Exception('Failed to load landmark data');
    }
  }

  static Future<void> findBuildings({String? venue}) async {
    BuildingData allBuildings = await Buildingbyvenueapi().fetchBuildingIDS(venue??buildingAllApi.selectedVenue).timeout(const Duration(seconds: 5), onTimeout: () {
      print("Timeout: Failed to fetch building IDS within 5 seconds");
      return BuildingData(buildings: [], campus: null); // Return an empty list on timeout
    });
    if (allBuildings.buildings == null || allBuildings.buildings!.isEmpty) return; // Exit if no buildings fetched
    Map<String, g.LatLng> allBuildingID = {};
    Map<String, g.LatLng> globalBuildingIDS = {};

      for (var element in allBuildings.buildings!){
        g.LatLng kk = g.LatLng(element.coordinates![0], element.coordinates![1]);
        allBuildingID[element.id] = kk;
        if(element.globalAnnotation??false){
          globalBuildingIDS[element.id] = kk;
        }
      }
      print("allBuildingID.keys ${allBuildingID.keys.toList()}");

    if (allBuildingID.isNotEmpty) {
      String selectedID = allBuildingID.keys.first;
      if(globalBuildingIDS.isNotEmpty){
        selectedID = globalBuildingIDS.keys.first;
      }
      buildingAllApi.selectedID = selectedID;
      buildingAllApi.selectedBuildingID = selectedID;
      buildingAllApi.allBuildingID = allBuildingID;
      buildingAllApi.globalBuildingIDS = globalBuildingIDS;
      buildingAllApi.onlyRenderBuildingID = Map.from(allBuildingID)..removeWhere((key, value) => globalBuildingIDS.containsKey(key));
      print("Success to fetch building IDS: ${buildingAllApi.allBuildingID}");
      return;
    }else{
      print("Failed to fetch building IDS: allBuildingID ${allBuildingID.length}");
    }
  }
}