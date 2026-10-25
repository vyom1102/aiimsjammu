import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
enum SignUpResult {
  success,
  userAlreadyExists,
  failure;

  static SignUpResult fromResponse(int statusCode, Map<String, dynamic> data) {
    if (data['status'] == false && data['message'] == 'User already exist!') {
      return SignUpResult.userAlreadyExists;
    }
    return statusCode == 200 && data['status'] == true
        ? SignUpResult.success
        : SignUpResult.failure;
  }
}

class SignUpAPI{

  final String xaccesstoken = AppConfig.Authorization;

  Future<SignUpResult> signUP(String username,String name, String password,String OTP) async {
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
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    final result = SignUpResult.fromResponse(response.statusCode, responseData);
    if (result != SignUpResult.success) {
      Fluttertoast.showToast(
        msg: responseData["message"],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    return result;
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
