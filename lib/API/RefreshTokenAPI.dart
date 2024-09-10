import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/APIMODELS/patchDataModel.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/PatchAPIModel.dart';


import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import 'guestloginapi.dart';

class RefreshTokenAPI {

  static String baseUrl = "https://dev.iwayplus.in/api/refreshToken?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edff";

  static Future<String> refresh() async {
    var signInBox = Hive.box('SignInDatabase');
    String refreshToken = signInBox.get("refreshToken");
    print("refreshToken");
    print(refreshToken);

    final Map<String, dynamic> data = {
      "refreshToken": refreshToken
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("in refreshTOken");
      Map<String, dynamic> responseBody = json.decode(response.body);
      final newAccessToken = responseBody["accessToken"];
      print(signInBox.get("accessToken"));
      signInBox.put("accessToken", newAccessToken);
      print(signInBox.get("accessToken"));


      return newAccessToken;
      // return "403";
    }else if (response.statusCode == 400) {
      print("Refresh token is invalid or expired.");
      return "400";
    } else {
      print(Exception);
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}