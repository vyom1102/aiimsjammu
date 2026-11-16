import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../API/RefreshTokenAPI.dart';
import '../../Userbox.dart';
import '../../config.dart';
import '../APIModel/CategoryModel.dart';

class Categoryapi{

  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  String baseUrl = "${AppConfig.baseUrl}/secured/event/all-category/684952e2e5c3aa55dd6c636b";

  Future<Categorymodel> fetchCategory({bool apiCall = false}) async {
    accessToken = signInBox.get("accessToken");

    // final CategorApiBox = CategoryAPIModelBOX.getData();

    // if(CategorApiBox.containsKey("684952e2e5c3aa55dd6c636b") && !apiCall){
    //   Map<String, dynamic> responseBody = CategorApiBox.get("684952e2e5c3aa55dd6c636b")!.responseBody;
    //   print("CATEGORY API DATA FROM DATABASE");
    //   fetchCategory(apiCall: true);
    //   return Categorymodel.fromJson(responseBody);
    // }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken!
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      // final categoryData = CategoryAPIModel(responseBody: responseBody);
      // print('CATEGORY DATA FROM API');
      // CategorApiBox.put("684952e2e5c3aa55dd6c636b",categoryData);
      // categoryData.save();
      return Categorymodel.fromJson(responseBody);
    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return await fetchCategory();
    } else {
      print("Categoryapi response.statusCode ${response.statusCode} ${response.body}");
      throw Exception('Failed to load data');
    }
  }
}