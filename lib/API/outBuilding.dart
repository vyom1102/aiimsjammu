import 'dart:convert';
<<<<<<< Updated upstream
=======
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
>>>>>>> Stashed changes
import 'package:http/http.dart' as http;
import '../APIMODELS/guestloginmodel.dart';
import '../APIMODELS/outdoormodel.dart';
import 'guestloginapi.dart';

class outBuilding {
<<<<<<< Updated upstream
=======
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/outdoor" : "https://maps.iwayplus.in/secured/outdoor";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
>>>>>>> Stashed changes

  Future<outdoormodel?> outbuilding(List<String> ids) async {

    final String baseUrl = "https://dev.iwayplus.in/secured/outdoor";

    String token = "";

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

<<<<<<< Updated upstream
=======
    for(var id in ids){
      if(OutBuildingBox.containsKey(id)){
        print("OUTBUILDING DATA FORM DATABASE");
        Map<String, dynamic> responseBody = OutBuildingBox.get(id)!.responseBody;
        return outdoormodel.fromJson(responseBody);
      }
    }
>>>>>>> Stashed changes

    final Map<String, dynamic> data = {
      "buildingIds": ids
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      return outdoormodel.fromJson(responseBody);

<<<<<<< Updated upstream
=======
    }else if(response.statusCode == 403){
      print("OUTBUILDING DATA API IN ERROR 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      final Map<String, dynamic> data = {
        "buildingIds": ids
      };

      final response = await http.post(
        Uri.parse(baseUrl), body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        final outBuildingData = OutDoorModel(responseBody: responseBody);
        print("OUTBUILDING DATA FORM API");


        OutBuildingBox.put(ids[0], outBuildingData);
        outBuildingData.save();

        return outdoormodel.fromJson(responseBody);

      }else{
        print('OUTBUILDING DATA EMPTY FROM API AFTER 403');
        outdoormodel outBuild = outdoormodel();
        return outBuild;
      }

>>>>>>> Stashed changes
    } else {
      print(ids);
      print(json.decode(response.body));
      print("outdoor api error");
    }
  }
}
