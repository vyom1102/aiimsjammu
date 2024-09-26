import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';

import '../APIMODELS/beaconData.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';


class beaconapi {
<<<<<<< Updated upstream
  final String baseUrl = "https://dev.iwayplus.in/secured/building/beacons";
  var signInBox = Hive.box('SignInDatabase');
  String token = "";

  Future<List<beacon>> fetchBeaconData({String? id}) async {
    print("beacon");
    token = signInBox.get("accessToken");
    final BeaconBox = BeaconAPIModelBOX.getData();
    if(BeaconBox.containsKey(id??buildingAllApi.getStoredString())){
=======
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/building/beacons" : "https://maps.iwayplus.in/secured/building/beacons";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<List<beacon>> fetchBeaconData(String id) async {

    print("beacon---");
    print(baseUrl);
    accessToken = signInBox.get("accessToken");
    final BeaconBox = BeaconAPIModelBOX.getData();

    print("beaconapi $id");
    print(BeaconBox.containsKey(id));
    print(VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(id));
    // print(VersionInfo.buildingLandmarkDataVersionUpdate[id]!);
    if(VersionInfo.buildingLandmarkDataVersionUpdate.isEmpty || (BeaconBox.containsKey(id) && VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(id) && VersionInfo.buildingLandmarkDataVersionUpdate[id]! == false)){
>>>>>>> Stashed changes
      print("BEACON DATA FROM DATABASE");
      print(BeaconBox.keys);
      print(BeaconBox.values);
      List<dynamic> responseBody = BeaconBox.get(buildingAllApi.getStoredString())!.responseBody;
      List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
      return beaconList;
    }

    print("Mishor");
    print(id);
    print(buildingAllApi.getStoredString());
    print(buildingAllApi.getStoredString().runtimeType);

    final Map<String, dynamic> data = {
      "buildingId": id??buildingAllApi.getStoredString(),
    };
    print("Mishordata");
    print(data);

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );

    if (response.statusCode == 200) {
      print("BEACON DATA FROM API");
      List<dynamic> responseBody = json.decode(response.body);
      List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
      print("response.statusCode");
      print("beaconList $beaconList");
      final beaconData = BeaconAPIModel(responseBody: responseBody);
      BeaconBox.put(beaconList[0].buildingID,beaconData);
      beaconData.save();

      return beaconList;
    } else {
      if (response.statusCode == 403) {
        RefreshTokenAPI.fetchPatchData();
        return beaconapi().fetchBeaconData();
      }
      HelperClass.showToast("MishorError in Beacon API");
      print(Exception);
      print("Mishorcheck");
      print(Exception);
      throw Exception('Failed to load beacon data');

    }
  }
}