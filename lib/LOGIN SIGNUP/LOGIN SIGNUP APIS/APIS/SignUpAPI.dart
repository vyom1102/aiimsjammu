import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '/Elements/HelperClass.dart';
class SignUpAPI{

  final String xaccesstoken = AppConfig.Authorization;

  Future<bool> signUP(String username,String name, String password,String OTP) async {
    final String baseUrl = "${AppConfig.baseUrl}/auth/signup";
    final Map<String, dynamic> data = {
      "username": username,
      "name": name,
      "password": password,
      "otp": OTP,
      "appId":"com.iwayplus.aiimsjammu"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: EncryptedbodyForApi(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': xaccesstoken,
      },
    );
    print('---response--- ${response.statusCode}');
    print(response.body);
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status']) {
       return true;
      } else {
        print("SignUpAPI--response.statusCode ${responseData['status']} ");
        HelperClass.showToast(responseData["message"]);
      }
    } else {
      var responseData = json.decode(response.body);
      print("SignUpAPI--response.statusCode response.body ${response.statusCode} ${response.body}");
      HelperClass.showToast(responseData["message"]);
    }
    return false;
  }

  Future<bool> checkUserExists(String username) async {
    return false;
    final Map<String, dynamic> data = {"username": username, "appId":"com.iwayplus.aiimsjammu"};

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/username'),
      body: EncryptedbodyForApi(data),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': '1D7A90DA-69EE-4D86-BF6D-90A24DFF1193',
      },
    );
    print('---response---');
    print(response.body);
    if (response.statusCode == 200) {
      var responseBody = response.body;
      var jsonResponse = json.decode(responseBody);
      return jsonResponse['userExist'];

    } else {
      throw Exception(
          'Failed to check user existence: ${response.reasonPhrase}');
    }
  }

}