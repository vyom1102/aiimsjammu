import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:navigation_sdk/src/DATABASE/BOXES/PatchAPIModelBox.dart';
import '../config.dart';

class RefreshTokenAPI {

  static String baseUrl = "${AppConfig.baseUrl}/api/refreshToken";

  static Future<String> refresh() async {
    var signInBox = Hive.box('SignInDatabase');
    String refreshToken = signInBox.get("refreshToken");

    final Map<String, dynamic> data = {
      "refreshToken": refreshToken,
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
      final newRefreshToken = responseBody["refreshToken"];
      signInBox.delete("accessToken");
      signInBox.put("accessToken", newAccessToken);

      signInBox.delete("refreshToken");
      signInBox.put("refreshToken", newRefreshToken);

      return newAccessToken;
    } else if (response.statusCode == 400) {
      print("logout condition");
      return "400";
    } else {
      print("Error refreshing tokens: ${response.statusCode}");
      throw Exception('Failed to refresh tokens');
    }
  }
}
