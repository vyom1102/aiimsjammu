import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../API/RefreshTokenAPI.dart';
import '../../Userbox.dart';
import '../../config.dart';
import '../APIModel/SubEventsModel.dart';

class Subeventsapi{

  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  String baseUrl = "${AppConfig.baseUrl}/secured/event/all-subEvent/684952e2e5c3aa55dd6c636b?populate=true";

  Future<SubEventsModel> fetchSubEvents({bool apiCall = false}) async {
    accessToken = signInBox.get("accessToken");

    // final SubEventAPIBox = SubEventAPIModelBOX.getData();
    //
    // if(SubEventAPIBox.containsKey("684952e2e5c3aa55dd6c636b") && !apiCall){
    //   Map<String, dynamic> responseBody = SubEventAPIBox.get("684952e2e5c3aa55dd6c636b")!.responseBody;
    //   print("SUB-EVENT API DATA FROM DATABASE");
    //   fetchSubEvents(apiCall: true);
    //   return SubEventsModel.fromJson(responseBody);
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
      // final subEventData = SubEventAPIModel(responseBody: responseBody);
      // print('SUB-EVENT DATA FROM API');
      // SubEventAPIBox.put("684952e2e5c3aa55dd6c636b",subEventData);
      // subEventData.save();
      return SubEventsModel.fromJson(responseBody);
    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return await fetchSubEvents();
    } else {
      print("Sessionsapi response.statusCode ${response.statusCode} ${response.body}");
      throw Exception('Failed to load data');
    }
  }
}