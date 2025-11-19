import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'APIMODELS/Buildingbyvenue.dart';

class ApiDataFetcher {
  final String accessToken;
  final String baseUrl;

  ApiDataFetcher({
    required this.accessToken,
    required this.baseUrl,
  });

  // Generic method to make API calls
  Future<dynamic> makeApiCall({
    required String endpoint,
    required String method,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse(endpoint);
      http.Response response;

      if (method == 'POST') {
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      } else {
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during API call: $e');
      return null;
    }
  }

  // Save data to file
  Future<void> saveToFile(String filename, dynamic data) async {
    try {
      final file = File('api_data/$filename');
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(data));
      print('✓ Saved: $filename');
    } catch (e) {
      print('Error saving $filename: $e');
    }
  }

  Future<BuildingData> fetchBuildingIDS(String venueName) async {
    print('\nFetching Patch data...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/building/get/venue',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,

      },
      body: {
        "venueName": venueName,
        "campusIncludes":true //venue Name
      },
    );
    var buildingData = BuildingData.fromJson(data);
    return buildingData;
  }

  // 1. Landmark API
  Future<void> fetchLandmark(String buildingId) async {
    print('\nFetching Landmark data...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/landmarks?format=v2',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        
      },
      body: {'id': buildingId},
    );

    if (data != null) {
      await saveToFile('Landmark$buildingId.json', data);
    }
  }

  // 2. Building Beacons API
  Future<void> fetchBuildingBeacons(String buildingId) async {
    print('\nFetching Building Beacons...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/building/beacons',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        
      },
      body: {'buildingId': buildingId},
    );

    if (data != null) {
      await saveToFile('Beacon$buildingId.json', data);
    }else{
      print("Beacons null for $buildingId");
    }
  }

  // 5. Data Version API
  Future<void> fetchDataVersion(String buildingId) async {
    print('\nFetching Data Version...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/data-version',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
      },
      body: {'building_ID': buildingId},
    );

    if (data != null) {
      await saveToFile('DataVersion$buildingId.json', data);
    }
  }

  // 6. Global Annotation API
  Future<void> fetchGlobalAnnotation(String id) async {
    print('\nFetching Global Annotation...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/get-global-annotation/$id',
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
      },
    );

    if (data != null) {
      await saveToFile('GlobalAnnotation$id.json', data);
    }
  }

  // 8. Patch API
  Future<void> fetchPatch(String buildingId, {String manufacturer = 'Generic', String deviceModel = 'Generic'}) async {
    print('\nFetching Patch data...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/patch/get?format=v2',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        
      },
      body: {
        'id': buildingId,
        'manufacturer': manufacturer,
        'devicemodel': deviceModel,
      },
    );

    if (data != null) {
      await saveToFile('Patch$buildingId.json', data);
    }
  }

  // 9. Polyline API
  Future<void> fetchPolyline(String buildingId) async {
    print('\nFetching Polyline data...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/polyline?format=v2',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        
      },
      body: {'id': buildingId},
    );

    if (data != null) {
      await saveToFile('Polyline$buildingId.json', data);
    }
  }

  // 10. Waypoint API
  Future<void> fetchWaypoint(String buildingId, {bool outdoor = false}) async {
    print('\nFetching Waypoint data...');
    final data = await makeApiCall(
      endpoint: '$baseUrl/secured/indoor-path-network',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        
      },
      body: {
        'building_ID': buildingId,
        'outdoor': outdoor,
      },
    );

    if (data != null) {
      await saveToFile('Waypoint$buildingId.json', data);
    }
  }

  // Fetch all data for a building/venue
  Future<void> fetchAllData({required String buildingId}) async {
    print('========================================');
    print('Starting API Data Fetch');
    print('========================================');

    await fetchLandmark(buildingId);
    await fetchBuildingBeacons(buildingId);
    await fetchDataVersion(buildingId);
    await fetchGlobalAnnotation(buildingId);
    await fetchPatch(buildingId);
    await fetchPolyline(buildingId);
    await fetchWaypoint(buildingId);

    print('\n========================================');
    print('All API calls completed!');
    print('Data saved in ./api_data/ directory');
    print('========================================');
  }
}

void main() async {
  // Configuration - REPLACE WITH YOUR ACTUAL VALUES
  final fetcher = ApiDataFetcher(
    accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmI1ZWY2NGI2ZDc1MDIzZDg5YWY3NjYiLCJyb2xlcyI6WyJ1c2VyIiwiYWRtaW4iXSwiaWF0IjoxNzYzNDY4Mzc3LCJleHAiOjE3NjM0NzAxNzd9.eG6-ODtFOcMVJLTrDMWH6tFStbsnB5uZVd7k4JcqPd8',
    baseUrl: 'https://maps.iwayplus.in',  // e.g., 'https://api.example.com'
  );
  var buildingData = await fetcher.fetchBuildingIDS("AIIMSJAMMU");
  buildingData.buildings?.forEach((building) async {
    await fetcher.fetchAllData(
      buildingId: building.id,
    );
  });
}