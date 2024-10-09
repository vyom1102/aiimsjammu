import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/Elements/HelperClass.dart';

import '../../../config.dart';

class SendOTPAPI{

  final String baseUrl = "${AppConfig.baseUrl}/auth/otp/send";

  Future<bool> sendOTP(String username) async {
    print('sendOTP');
    final Map<String, dynamic> data = {
      "username": username,
      "digits":4,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      HelperClass.showToast("OTP sent successfully");
      print("in if");
      return true;

    } else {
      print("SendOTPAPI--response.statusCode${response.statusCode} ${response.body}");
      return false;
    }
  }
}