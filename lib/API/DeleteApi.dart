import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../Elements/HelperClass.dart';

class DeleteApi {
<<<<<<< Updated upstream

  static String refreshToken = "";
  static String baseUrl = "https://dev.iwayplus.in/secured/user/delete";
=======
  static String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/user/delete" : "https://maps.iwayplus.in/secured/user/delete";
  static var signInBox = Hive.box('SignInDatabase');
  static String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  static Future<bool> deleteData() async {
>>>>>>> Stashed changes

  static Future<bool> fetchPatchData() async {
    var signInBox = Hive.box('SignInDatabase');
    String userid = signInBox.get("userId");
    String token = signInBox.get("accessToken");


    final Map<String, dynamic> data = {
      "userId": userid
    };

    final response = await http.delete(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );


    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      HelperClass.showToast(responseBody['message']);
      return true;
    } else {
      HelperClass.showToast(response.statusCode.toString());
      return false;
      
    }
  }
}
