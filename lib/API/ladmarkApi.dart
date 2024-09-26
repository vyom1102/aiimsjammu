import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';

import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'RefreshTokenAPI.dart';
import 'buildingAllApi.dart';
import 'guestloginapi.dart';
import 'package:hive/hive.dart';


class landmarkApi {
<<<<<<< Updated upstream
  final String baseUrl = "https://dev.iwayplus.in/secured/landmarks";
  var signInBox = Hive.box('SignInDatabase');
  String token = "";
=======
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/landmarks" : "https://maps.iwayplus.in/secured/landmarks";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");
>>>>>>> Stashed changes



  Future<land> fetchLandmarkData({String? id = null}) async {
    print("landmark");
    token = signInBox.get("accessToken");
    final LandMarkBox = LandMarkApiModelBox.getData();
    if(LandMarkBox.containsKey(id??buildingAllApi.getStoredString())){
      print("LANDMARK DATA FORM DATABASE ");
      print(id??buildingAllApi.getStoredString());
      Map<String, dynamic> responseBody = LandMarkBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      print("Himanshuch ${land.fromJson(responseBody).landmarks![0].buildingName}");
      return land.fromJson(responseBody);
    }


    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString(),
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      print("checkid $id");
      String APITime = responseBody['landmarks'][0]['updatedAt']!;
      final landmarkData = LandMarkApiModel(responseBody: responseBody);

      print('LANDMARK DATA FROM API');
      print(responseBody.containsValue("polylineExist"));
      // print(LandMarkBox.length);
      //LandMarkApiModel? demoresponseBody = LandMarkBox.getAt(0);
      //print(demoresponseBody?.responseBody);
      LandMarkBox.put(land.fromJson(responseBody).landmarks![0].buildingID,landmarkData);

      // print(LandMarkBox.length);
      // print('TESTING LANDMARK API DATABASE OVER');
      landmarkData.save();


      //print("object ${responseBody['landmarks'][0].runtimeType}");
      return land.fromJson(responseBody);
      // if(!LandMarkBox.containsKey(buildingAllApi.getStoredString())){
      //   print('LANDMARK DATA FROM API');
      //   LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);
      //   landmarkData.save();
      //   return land.fromJson(responseBody);
      // }else{
      //   Map<String, dynamic> databaseresponseBody = LandMarkBox.get(buildingAllApi.getStoredString())!.responseBody;
      //   String LastUpdatedTime = databaseresponseBody['landmarks'][0]['updatedAt']!;
      //   print("APITime");
      //   if(APITime==LastUpdatedTime){
      //     print("LANDMARK DATA FROM DATABASE");
      //     print("Current Time: ${APITime} Last updated Time: ${LastUpdatedTime}");
      //     return land.fromJson(databaseresponseBody);
      //   }else{
      //     print("LANDMARK DATA FROM DATABASE AND UPDATED");
      //     print("Current Time: ${APITime} Last updated Time: ${LastUpdatedTime}");
      //     LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);
      //     landmarkData.save();
      //     return land.fromJson(responseBody);
      //   }
      // }
    } else {
      if (response.statusCode == 403) {
        RefreshTokenAPI.fetchPatchData();
        return landmarkApi().fetchLandmarkData();
      }
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}