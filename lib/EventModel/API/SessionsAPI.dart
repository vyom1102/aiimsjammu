import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../API/RefreshTokenAPI.dart';
import '../../Userbox.dart';
import '../../config.dart';
import '../APIModel/SessionModel.dart';

class Sessionsapi{

  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  String baseUrl = "${AppConfig.baseUrl}/secured/event/all-session/684952e2e5c3aa55dd6c636b?populate=true";

  Future<SessionModel> fetchSession({bool apiCall = false}) async {
    print("Session api stack ${StackTrace.current}");
    accessToken = signInBox.get("accessToken");

    // final SessionAPIBox = SessionAPIModelBOX.getData();
    //
    // if(SessionAPIBox.containsKey('684952e2e5c3aa55dd6c636b') && !apiCall){
    //   Map<String, dynamic> responseBody = SessionAPIBox.get('684952e2e5c3aa55dd6c636b')!.responseBody;
    //   print("SESSION API DATA FROM DATABASE");
    //   fetchSession(apiCall: true);
    //   return SessionModel.fromJson(responseBody);
    // }else{
    //   print("Key Not found");
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
      // final sessionData = SessionAPIModel(responseBody: responseBody);
      // print('SESSION DATA FROM API');
      // SessionAPIBox.put('684952e2e5c3aa55dd6c636b',sessionData);
      // sessionData.save();
      // print("Session data ${SessionAPIBox.keys} ${SessionAPIBox.values}");
      return SessionModel.fromJson(responseBody);
    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return await fetchSession();
    } else {
      print("Sessionsapi response.statusCode ${response.statusCode} ${response.body}");
      throw Exception('Failed to load data');
    }
  }
}