import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '/Elements/HelperClass.dart';

class SendOTPAPI{

  final String baseUrl = "${AppConfig.baseUrl}/auth/otp/send";
  final String xaccesstoken = AppConfig.Authorization;
  Future<bool> sendOTP(String username) async {
    final Map<String, dynamic> data = {
      "username": username,
      "digits":4,
      "appName":"Aiims Jammu Navigation"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: EncryptedbodyForApi(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token':xaccesstoken
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("SendOTPAPI--response.statusCode${response.statusCode} ${response.body}");
      return false;
    }
  }
}