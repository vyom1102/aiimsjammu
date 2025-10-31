import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../APIMODELS/DataVersion.dart';
import '../Userbox.dart';
import '../api/RefreshTokenAPI.dart';

class DataVersionapiNewForRepo{

  static var signInBox = Hive.box('SignInDatabase');
  var versionBox = Hive.box('VersionData');
  String accessToken = signInBox.get("accessToken");

  String baseUrl = "${AppConfig.baseUrl}/secured/data-versions-multiple";

  Future<List<DataVersionModel>?> fetchDataVersion(String venueName) async {
    accessToken = signInBox.get("accessToken");

    final Map<String, dynamic> data = {
      "venueName": venueName
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken!
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      List<DataVersionModel> DataVersion = responseBody.map((data) => DataVersionModel.fromJson(data)).toList();
      print('DataVersion DATA FROM API');
      return DataVersion;
    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return await fetchDataVersion(venueName);
    } else {
      print("DataVersion response.statusCode ${response.statusCode} ${response.body}");
      return null;
    }
  }
}