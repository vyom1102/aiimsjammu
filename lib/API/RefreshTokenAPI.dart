import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import 'guestloginapi.dart';

class RefreshTokenAPI {

<<<<<<< Updated upstream
  static String refreshToken = "";
  static String baseUrl = "https://dev.iwayplus.in/api/refreshToken?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edff";
=======
  static String baseUrl = kDebugMode? "https://dev.iwayplus.in/api/refreshToken?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edff" : "https://maps.iwayplus.in/api/refreshToken?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edff";
>>>>>>> Stashed changes

  static void fetchPatchData() async {
    var signInBox = Hive.box('SignInDatabase');
    refreshToken = signInBox.get("refreshToken");
    // print("refreshToken");
    // print(refreshToken);

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
<<<<<<< Updated upstream
=======
      final newAccessToken = responseBody["accessToken"];
      signInBox.delete("accessToken");
      print(signInBox.get("accessToken"));
      signInBox.put("accessToken", newAccessToken);
      print(signInBox.get("accessToken"));
>>>>>>> Stashed changes

      String updatedAccessToken = responseBody["accessToken"];
      signInBox.put('accessToken', updatedAccessToken);

<<<<<<< Updated upstream
      print(responseBody);
      return;
=======
      return newAccessToken;
>>>>>>> Stashed changes
    } else {
      print(Exception);
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}
