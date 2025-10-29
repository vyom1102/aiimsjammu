import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../API/RefreshTokenAPI.dart';
import '../../Userbox.dart';
import '../../config.dart';
import '../APIModel/CategoryModel.dart';
import '../APIModel/ExhibitorModel.dart';

class Exhibitorsapi{


  String baseUrl = "${AppConfig.baseUrl}/api/purplefest/purple-exhibitors-all?populate=true";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");
  Future<List<ExhibitorModel>> fetchExhibitor({bool apiCall = false}) async {
    accessToken = signInBox.get("accessToken");

    // final ExhibitorApiBox = ExhibitorAPIModelBOXNEW.getData();
    //
    // if(ExhibitorApiBox.containsKey("PURPLE_FEST_EXHIBITOR_KEY") && !apiCall){
    //   print('EXHIBITOR DATA FROM DATABASE');
    //   List<dynamic> responseBody = ExhibitorApiBox.get("PURPLE_FEST_EXHIBITOR_KEY")!.responseBody;
    //   List<ExhibitorModel> exhibitorList = responseBody.map((data) => ExhibitorModel.fromJson(data)).toList();
    //   fetchExhibitor(apiCall: true);
    //   return exhibitorList;
    // }


    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken!
      },
    );
    print("response ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      // final exhibitorData = ExhibitorAPIModelNEW(responseBody: responseBody);
      // ExhibitorApiBox.put("PURPLE_FEST_EXHIBITOR_KEY", exhibitorData);
      // exhibitorData.save();
      print('EXHIBITOR DATA FROM API');
      List<ExhibitorModel> exhibitorList = responseBody.map((data) => ExhibitorModel.fromJson(data)).toList();
      return exhibitorList;
    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return await fetchExhibitor();
    } else {
      print("fetchExhibitor response.statusCode ${response.statusCode} ${response.body}");
      throw Exception('Failed to load data');
    }
  }
}