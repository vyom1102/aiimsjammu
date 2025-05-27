import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:iwaymaps/AiimsJammu/Screens/BuildingLandmarks.dart';
import 'package:iwaymaps/AiimsJammu/Screens/DirectoryScreen.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/GlobalSearch.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/SignIn.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:iwaymaps/API/DataVersionApi.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/AiimsJammu/Screens/NoInternetConnection.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/OpeningClosingStatus.dart';
import '../../API/GlobalAnnotationapi.dart';
import '../../API/PatchApi.dart';
import '../../API/PolyLineApi.dart';
import '../../API/RefreshTokenAPI.dart';
import '../../API/UsergetAPI.dart';
import '../../API/ladmarkApi.dart';
import '../../API/outBuilding.dart';
import '../../API/waypoint.dart';
import '../../APIMODELS/DataVersion.dart';
import '../../APIMODELS/landmark.dart';
import '../../DATABASE/BOXES/BeaconAPIModelBOX.dart';
import '../../DATABASE/BOXES/BuildingAPIModelBox.dart';
import '../../DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import '../../DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import '../../DATABASE/BOXES/LandMarkApiModelBox.dart';
import '../../DATABASE/BOXES/OutDoorModelBOX.dart';
import '../../DATABASE/BOXES/PatchAPIModelBox.dart';
import '../../DATABASE/BOXES/PolyLineAPIModelBOX.dart';
import '../../DATABASE/BOXES/WayPointModelBOX.dart';
import '../../Elements/HelperClass.dart';
import '../../Navigation.dart';
import '../../UserState.dart';
import '../../VersioInfo.dart';
import '../../buildingState.dart';
import '../../config.dart';
import '../../singletonClass.dart';
import '../../websocket/NotifIcationSocket.dart';
import '../../websocket/UserLog.dart';
import '../../websocket/interactionManager.dart';
import '../Widgets/MapPreview.dart';
import '../Widgets/Translator.dart';
import '../Widgets/WebSocketDriver.dart';
import '../Widgets/defaultMap.dart';
import '/DestinationSearchPage.dart';
import '/AiimsJammu/Screens/ATMScreen.dart';
import '/AiimsJammu/Screens/AllAnnouncementScreen.dart';
import '/AiimsJammu/Screens/CafeteriaScreen.dart';
import '/AiimsJammu/Screens/CountersScreen.dart';
import '/AiimsJammu/Screens/DoctorScreen.dart';
import '/AiimsJammu/Screens/EmergencyScreen.dart';
import '/AiimsJammu/Screens/NotificationScreen.dart';
import '/AiimsJammu/Screens/OtherServices.dart';
import '/AiimsJammu/Screens/ServiceInfo.dart';
import '/AiimsJammu/Screens/ServicesScreen.dart';
import 'package:http/http.dart' as http;
import '/AiimsJammu/Widgets/LocationIdFunction.dart';
import '/AiimsJammu/Widgets/NearbyServiceCard.dart';
import '../Widgets/AnouncementCard.dart';
import '../Widgets/CalculateDistance.dart';
import '../Widgets/ImageCarouse.dart';
import '../Data/ServicesDemoData.dart';
import 'PharmacyScreen.dart';

//hospital id = 6673e7a3b92e69bc7f4b40ae
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bool isConnectedToInternet =true;
  // StreamSubscription? _internetConnection;
  List<dynamic> carouselImages = [];
  // List<AnnouncementAData> AnnounceData = [];
  List<dynamic> announcements = [];
  List<dynamic> directory=[];
  Map<String, dynamic> allLandmarkData = {};
  List<String> globalBuildingIds = [];
  List<String> AiimsJammuBuildingIds = ["67986e4114ef508e9429a5ad", "66794105b80a6778c53c4856", "6798c6df96af63c3e82659ec", "6798c81c96af63c3e826add3", "6798c8fa96af63c3e8277db2", "6798c99e96af63c3e828203d", "6798ca0396af63c3e828c472", "6798ce3596af63c3e8294dbc", "679ca3fde7e7001d98497002"];
  bool _isLoading = false;
  List<dynamic> filteredLandmarks = [];
  String? selectedlandmarkpolyId;
  double? buildingstartX = 32.5637551;
  double? buildingstartY = 75.0341691;
  PageController _pageController = PageController();
  List<dynamic> _services = [];
  List<dynamic> _filteredServices = [];
  List<dynamic> _atmfilteredServices = [];
  List<dynamic> _pharmacyfilteredServices = [];
  List<dynamic> _countersfilteredServices = [];
  List<dynamic> _cafeteriafilteredServices = [];
  String? accessTokenN;
  String? refreshTokenN;
  List<dynamic> _emergencyfilteredService =[];
  List<dynamic> _otherservices = [];
  List<dynamic>   _otherfilteredServices = [];
  String twitter = "https://x.com/AiimsJammu";
  String facebook = "https://www.facebook.com/aiimsvijaypur";
  String youtube = "https://www.youtube.com/channel/UC0V4753jPLDzPmlypa1xDiQ/playlists";
  String instagram = "https://www.instagram.com/aiims_vijaypurjmu/";
  int doctorVersion = 0;
  int serviceVersion = 0;
  int corousalVersion = 0;
  int announcementVersion = 0;
  int directoryVersion = 0;
  int _currentPage = 0;
  late int index;
  late ScrollController _scrollController;
  late Timer _timer;
  int _currentIndex = 0;
  String? userId;
  String? accessToken;
  String? refreshToken;
  String? userName = "User";
  bool isDriver = false;
  String? emailAddress;
  bool nameLoading= false;
  bool isOnline = true;
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];
  Widget? mapPreview;
  Map<dynamic, dynamic> combinedLandmarkData = {};
  final ws = wsocket("com.iwayplus.aiimsjammu");


  @override
  void initState() {
    super.initState();
    getUserDataFromHive();
    fetchAndStoreBuildingIds();
    getDriverDetail();
    NotificationSocket.receiveMessage();
    checkForUpdate();
    _pageController = PageController(initialPage: _currentPage);
    getLocs();
    wsocket.message["AppInitialization"]["BID"]=buildingAllApi.selectedBuildingID;
    wsocket.message["AppInitialization"]["buildingName"]=buildingAllApi.selectedVenue;
    // SingletonFunctionController().executeFunction(buildingAllApi.allBuildingID);
    versionApiCheck();
    checkForReload();
    versionApiCall();
    // fetchAllLandmarkData();
    isUserValid();
    callbackFunc();
    requestNotificationPermission();
    // dataDownload();
    SingletonFunctionController().executeFunction(buildingAllApi.allBuildingID);
    index = 0;
    _scrollController = ScrollController(initialScrollOffset: 140.0);

  }
  Future<void> fetchAllLandmarkData() async {
    if (globalBuildingIds.isEmpty) {
      await fetchAndStoreBuildingIds();
    }
    for (var buildingId in globalBuildingIds) {
      await fetchLandmarkData(buildingId);
    }
  }
  Future<void> fetchAndStoreBuildingIds() async {
    // Open the Hive box
    var buildingIdsBox = await Hive.openBox('BuildingIds');
    // Retrieve building IDs from the box
    if (buildingIdsBox.containsKey("buildingId")) {
      globalBuildingIds = List<String>.from(
          buildingIdsBox.get('buildingId')
      );
    }else{
      print("Aiims jammu ids");
      setState(() {
        globalBuildingIds = AiimsJammuBuildingIds;

      });
    }


    setState(() {
      _isLoading = true;
    });
    await setInitialLandmarkData();
    await DataVersionCheckForLandmarks();
    setState(() {
      _isLoading = false;
    });
    print("Global Building IDs: $globalBuildingIds");
  }
  // Future<void> setInitialLandmarkData() async{
  //   for(String buildingId in globalBuildingIds) {
  //     var landmarkDataBox = await Hive.openBox('LandmarkDataBox');
  //     var data = await landmarkDataBox.get('landmarkData_$buildingId');
  //     setState(() {
  //       allLandmarkData[buildingId] = data;
  //     });
  //
  //     print("no data changed in landmark $buildingId");
  //   }
  // }
  Future<void> setInitialLandmarkData() async {
    bool shouldFetch = false;
    var landmarkDataBox = await Hive.openBox('LandmarkDataBox');

    for (String buildingId in globalBuildingIds) {
      var data = await landmarkDataBox.get('landmarkData_$buildingId');

      if (data != null) {
        setState(() {
          allLandmarkData[buildingId] = data;
        });
        print("Landmark data loaded from cache for $buildingId");
      } else {
        print("No data found for $buildingId, will fetch from API.");
        shouldFetch = true;
      }
    }

    if (shouldFetch) {
      await fetchLandmarkDataAccToVenue("AIIMSJAMMU");
    }
  }

  Future<void>DataVersionCheckForLandmarks() async {
    print("in data version");
    for(String buildingId in globalBuildingIds){
      print("building data version for $buildingId");
      await fetchDataVersion(buildingId: buildingId);
    }
  }
  Future<Map<String, dynamic>> fetchDataVersion({
    required String buildingId,
  }) async {
    try {
      final Uri url = Uri.parse('${AppConfig.baseUrl}/secured/data-version');
      final headers = {
        'Content-Type': 'application/json',
        'x-access-token': '$accessToken',
      };
      final body = json.encode({
        "building_ID": buildingId,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      print("status code for data version ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData["status"] == true) {
          final versionData = responseData["versionData"];
          final int polylineVersion = versionData["polylineDataVersion"];
          final int landmarksVersion = versionData["landmarksDataVersion"];

          var box = await Hive.openBox('DataVersion');
          final storedPolylineVersion = box.get('${buildingId}_polylineVersion', defaultValue: -1);
          final storedLandmarksVersion = box.get('${buildingId}_landmarksVersion', defaultValue: -1);
          print("storedLandmarksVersion for $buildingId is $storedLandmarksVersion");
          print("storedPolylineVersion for $buildingId is $storedPolylineVersion");

          if ( landmarksVersion != storedLandmarksVersion) {
            print("data changed for $buildingId");
            await box.put('${buildingId}_landmarksVersion', landmarksVersion);
            await fetchLandmarkData(buildingId);
          }else{

            var landmarkDataBox = await Hive.openBox('LandmarkDataBox');
            var data = await landmarkDataBox.get('landmarkData_$buildingId');
            setState(() {
              allLandmarkData[buildingId] = data;
            });
            print("no data changed in landmark $buildingId");
          }
        }
        return responseData;
      }else if(response.statusCode == 403){
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        return fetchDataVersion(buildingId: buildingId);
      } else {
        var landmarkDataBox = await Hive.openBox('LandmarkDataBox');
        var data = await landmarkDataBox.get('landmarkData_$buildingId');
        setState(() {
          allLandmarkData[buildingId] = data;
        });
        print("no data changed in landmark else $buildingId");
        throw HttpException('Failed to fetch data version: ${response.reasonPhrase}');
      }
    } catch (e) {
      var landmarkDataBox = await Hive.openBox('LandmarkDataBox');
      var data = await landmarkDataBox.get('landmarkData_$buildingId');
      setState(() {
        allLandmarkData[buildingId] = data;
      });
      print("no data changed in landmark $buildingId");
      throw Exception('Error fetching data version: $e');
    }
  }
  Future<void> fetchLandmarkData(String buildingId) async {

    var headers = {
      'Content-Type': 'application/json',
      'x-access-token': '$accessToken'
    };

    var request = http.Request(
      'POST',
      Uri.parse('${AppConfig.baseUrl}/secured/landmarks'),
    );
    request.body = json.encode({"id": buildingId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);

      // Save data in Hive for caching
      var landmarkDataBox = await Hive.openBox('LandmarkDataBox');
      await landmarkDataBox.put('landmarkData_$buildingId', data);
      print("Landmark data stored for building a $buildingId");

      // Update state and store landmark data
      setState(() {
        allLandmarkData[buildingId] = data;
        // landmarkData = data;
      });


    } else if (response.statusCode == 403) {
      // Refresh the access token and retry the request
      accessToken = await RefreshTokenAPI.refresh();
      await fetchLandmarkData(buildingId);
    } else {
      print("Error: ${response.reasonPhrase}");
    }

    // Add landmarks for the specified floor
    // await addLandmarksForFloor(buildingId, currentFloor);
  }
  Future<void> fetchLandmarkDataAccToVenue(String venueName) async {
    var headers = {
      'Content-Type': 'application/json',
      'x-access-token': '$accessToken'
    };

    var request = http.Request(
      'POST',
      Uri.parse('${AppConfig.baseUrl}/secured/landmarks-venue'),
    );
    request.body = json.encode({"venueName": venueName});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print("fetchLandmarkDataAccToVenue");
    print(response.statusCode);
    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);
      print(data);
      // Save each building's landmark data in Hive
      var landmarkDataBox = await Hive.openBox('LandmarkDataBox');

      data.forEach((buildingId, buildingData) async {
        await landmarkDataBox.put('landmarkData_$buildingId', buildingData);
        print("Landmarkvenue data stored for building $buildingId");
        print(landmarkDataBox.get('landmarkData_$buildingId'));
        // Update state with each building's data
        setState(() {
          allLandmarkData[buildingId] = buildingData;
        });
      });

    } else if (response.statusCode == 403) {
      // Refresh the access token and retry the request
      accessToken = await RefreshTokenAPI.refresh();
      await fetchLandmarkDataAccToVenue(venueName);
    } else {
      print("Error: ${response.reasonPhrase}");
    }
  }


  Future<void> filterLandmarks(String? type, int floorInt,{String? washroomType}) async {
    print("in filter landmark $type , $floorInt");
    if (allLandmarkData.isEmpty) return;

    print("in all landmarkdata");
    List<dynamic> landmarks = [];

    // final landmarks = allLandmarkData[globalBuildingIds[1]]?['landmarks'] as List;
    for (var buildingId in globalBuildingIds) {
      if (allLandmarkData[buildingId]?['landmarks'] != null) {
        landmarks.addAll(allLandmarkData[buildingId]['landmarks'] as List);
      }
    }
    String? selectedWashroomType =washroomType??"male";

    // // If the user selected washroom, ask for male or female
    // if (type?.toLowerCase() == 'washroom') {
    //   selectedWashroomType = await showDialog<String>(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('Select Washroom Type'),
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             ListTile(
    //               title: const Text('Male'),
    //               onTap: () {
    //                 Navigator.pop(context, 'male');
    //               },
    //             ),
    //             ListTile(
    //               title: const Text('Female'),
    //               onTap: () {
    //                 Navigator.pop(context, 'female');
    //               },
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   );
    //
    //   // If the user cancels the selection, exit the function
    //   if (selectedWashroomType == null) return;
    // }

    filteredLandmarks = landmarks.where((landmark) {
      bool floorMatch = landmark['floor'] == floorInt;
      String landmarkType = landmark['element']['subType']?.toString().toLowerCase() ?? '';

      // Check washroom type if washroom is selected
      if (type?.toLowerCase() == 'washroom') {
        String washroomType = landmark['properties']['washroomType']?.toString().toLowerCase() ?? '';
        return floorMatch && landmarkType == 'restroom' && washroomType == selectedWashroomType;
      }

      switch (type?.toLowerCase()) {
        case 'lift':
          return floorMatch && landmarkType == 'lift';
        case 'entry':
          return floorMatch && landmarkType == 'main entry';
        case 'pharmacy':
          return floorMatch && landmarkType == 'pharmacy';
        case 'drinkingwater':
          return floorMatch && landmarkType == 'drinkingwater';
        case 'food and drinks':
          return floorMatch && landmarkType == 'food and drinks';
        case 'atm':
          return floorMatch && landmarkType == "atm";
        case 'transport':
          return floorMatch && (landmarkType == "transportation service till building" || landmarkType == "Pick-up / Drop-off Point");
        default:
          return floorMatch;
      }
    }).toList();

    if (filteredLandmarks.isNotEmpty) {
      // Find nearest landmark based on current position
      Map<dynamic, dynamic> nearestLandmark = filteredLandmarks[0];
      double minDistance = double.infinity;
      buildingstartY = userLoc!.longitude;
      buildingstartX = userLoc!.latitude;
      print("user loccc");
      print(buildingstartX);
      print(buildingstartY);
      print(nearestLandmark);
      for (var landmark in filteredLandmarks) {

        double landmarkX = double.parse(landmark['properties']['latitude']);
        double landmarkY = double.parse(landmark['properties']['longitude']);

        double distance = sqrt(
            pow(buildingstartX! - landmarkX, 2) +
                pow(buildingstartY! - landmarkY, 2)
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestLandmark = landmark;
        }
      }

      print('Nearest ${type ?? 'all'} landmark on floor $floorInt in building :');
      print(nearestLandmark);
      print(nearestLandmark['_id']);
      setState(() {
        selectedlandmarkpolyId = nearestLandmark['properties']['polyId']??nearestLandmark['_id'];

      });
      print('selectedlandmarkpolyId from nearby amenities');
      print(selectedlandmarkpolyId);
      if(selectedlandmarkpolyId!=null)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Navigation(directLandID: selectedlandmarkpolyId!,),
          ),
        );

    } else {
      print('No landmarks found of type: ${type ?? 'all'} on floor $floorInt in building');
      Fluttertoast.showToast(msg: "Error finding nearby $type ");
    }
  }

  Future<void> getUserDataFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    setState(() {

      accessToken = signInBox.get("accessToken");
      refreshToken = signInBox.get("refreshToken");
    });
  }

  void callbackFunc(){
    SingletonFunctionController().executeFunction(buildingAllApi.allBuildingID).then((_){
      SingletonFunctionController.timer?.whenComplete((){
        localizeUser();
      });
    });
  }
  Future<void> localizeUser({bool speakTTS = true}) async {
    double highestweight = 0;
    String nearestBeacon = "";
    print("binresult ${SingletonFunctionController.btadapter.BIN}");
    for (int i = 0;
    i < SingletonFunctionController.btadapter.BIN.length;
    i++) {
      if (SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty) {
        SingletonFunctionController.btadapter.BIN[i]!.forEach((key, value) {
          if (value < 0) {
            value = value * -1;
          }
          if (value > highestweight) {
            highestweight = value;
            nearestBeacon = key;
          }
        });
        break;
      }
    }
    if (nearestBeacon != "" && Building.apibeaconmap[nearestBeacon] != null) {
      SingletonFunctionController.currentBeacon = nearestBeacon;
    }
  }

  bool _updateAvailable = false;
  bool _checkingForUpdate = true;
  String? currentVersion = "";

  Future<void> checkForUpdate() async {
    final newVersion = NewVersionPlus(
      androidId: 'com.iwayplus.aiimsjammu',
      iOSId: 'com.iwayplus.aiimsjammu',
    );

    try {
      final status = await newVersion.getVersionStatus();
      print("status");
      print(status!.canUpdate);
      setState(() {
        currentVersion = status?.localVersion;
        _updateAvailable = status != null && status.canUpdate;
        _checkingForUpdate = false;
      });

      // Show dialog if update is available
      if (_updateAvailable) {
        _showUpdateDialog();
      }

    } catch (e) {
      print('Error checking for updates: $e');
      setState(() {
        _checkingForUpdate = false;
      });
    }
  }

  // Function to show update dialog
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Available"),
          content: Text("A new version of the app is available. Please update to the latest version."),
          actions: <Widget>[
            TextButton(
              child: Text("Update Now"),
              onPressed: () async {
                // Add your app update logic here
                final url = Theme.of(context).platform == TargetPlatform.iOS
                    ? 'https://apps.apple.com/in/app/aiims-jammu-navigation/id6677034083'
                    : 'https://play.google.com/store/apps/details?id=com.iwayplus.aiimsjammu';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Position? userLoc;
  bool isLocating=false;
  void getLocs()async{
    setState((){
      isLocating=true;
    });
    userLoc= await getUsersCurrentLatLng();
    if(mounted){
      setState(() {
        isLocating=false;
      });
    }
    print("userLoc");
    print(userLoc);
    UserState.geoFenced=await HelperClass.getGeoFenced(userLoc!);
  }

  Future<Position?> getUsersCurrentLatLng()async{
    if (await Permission.location.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return position;

    }
    else{
      Position pos=Position(longitude: 77.1852061, latitude:  28.5436197, timestamp: DateTime.now(), accuracy: 100, altitude: 1, altitudeAccuracy: 100, heading: 10, headingAccuracy: 100, speed: 100, speedAccuracy: 100);
      return pos;
    }

  }
  Future<List<dynamic>> dataDownload() async {
    List<dynamic> polylines = [];
    List<dynamic> landmarks = [];
    List<dynamic> patches = [];
    land? mergedLandmarkData;

    // Helper function to fetch and process data for a building ID
    Future<void> fetchDataForBuilding(String id) async {
      try {
        var patchData = await patchAPI().fetchPatchData(id: id);
        var polylineData = await PolyLineApi().fetchPolyData(id: id);
        var landmarkData = await landmarkApi().fetchLandmarkData(id: id);
        var waypointData = await waypointapi().fetchwaypoint(id);

        polylines.add(polylineData);
        patches.add(patchData);
        landmarks.add(landmarkData);

        if (mergedLandmarkData == null) {
          mergedLandmarkData = landmarkData;
        } else {
          mergedLandmarkData!.mergeLandmarks(landmarkData.landmarks);
        }
      } catch (e) {
        print("Error fetching data for building ID $id: $e");
      }
    }

    // Fetch data for all building IDs in parallel
    await Future.wait(buildingAllApi.allBuildingID.keys.map(fetchDataForBuilding));

    // try {
    //   var globalData = await GlobalAnnotation().fetchGlobalAnnotationData(buildingAllApi.outdoorID);
    //   Building.GlobalAnnotation = globalData;
    // }catch(_){}

    // Fetch outdoor data
    await fetchDataForBuilding(buildingAllApi.outdoorID);

    // Update state and return polylines
    setState(() {
      mapPreview = MapPreview(polylines, landmarks, patches, Building.GlobalAnnotation);
    });

    return polylines;
  }

  Future<bool> requestNotificationPermission() async {
    // Check current platform
    if (await Permission.notification.isGranted) {
      print('Notification permission already granted');
      return true;
    }

    // Request permission
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      print('Notification permission granted');
      return true;
    } else if (status.isDenied) {
      print('Notification permission denied');
    } else if (status.isPermanentlyDenied) {
      print('Notification permission permanently denied');
      // Optionally, open app settings
      //openAppSettings();
    }

    return false;
  }


  Future<void> isUserValid() async{
    try{
      String refreshToken1= await RefreshTokenAPI.refresh();
      if(refreshToken1=="400"){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false,
        );
      }
    }
    catch(e){

    }
  }

  Future<void> versionApiCheck() async {
    try {
      final dashboarddataversion = await Hive.openBox("dashboardDataVersion");
      final signInBox = await Hive.openBox('SignInDatabase');
      accessTokenN = signInBox.get("accessToken");
      refreshTokenN = signInBox.get("refreshToken");

      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/secured/data-version1"),
        body: json.encode({
          "id": "6673e7a3b92e69bc7f4b40ae",
        }),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": accessTokenN ?? "",
        },
      );


      if (response.statusCode == 200) {
        print("Version API call success");
        print(response.body);

        final responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          int newDoctorVersion = responseData['versionData']['doctorDataVersion'] ?? 0;
          int newServiceVersion = responseData['versionData']['serviceDataVersion'] ?? 0;
          int newCorousalVersion = responseData['versionData']['corousalDataVersion'] ?? 0;
          int newAnnouncementVersion = responseData['versionData']['announcementDataVersion'] ?? 0;
          int newDirectoryVersion = responseData['versionData']['directoryDataVersion']??0;

          // Update the state with the new version values
          setState(() {
            doctorVersion = newDoctorVersion;
            serviceVersion = newServiceVersion;
            corousalVersion = newCorousalVersion;
            announcementVersion = newAnnouncementVersion;
            directoryVersion = newDirectoryVersion;
          });

          if (dashboarddataversion.get('doctorVersion') != doctorVersion) {
            _doctors.clear();
            await _loadDoctorsFromAPI();
            print("Doctor data updated");
            dashboarddataversion.put('doctorVersion', doctorVersion);
          } else {
            print("No updates for doctor data");
          }

          // Handle service data updates
          if (dashboarddataversion.get('serviceVersion') != serviceVersion) {
            print("Updating service data...");
            _services.clear();
            await _loadServicesFromAPI();
            print("Service data updated");
            dashboarddataversion.put('serviceVersion', serviceVersion);
          } else {
            print("No updates for service data");
          }

          // Handle corousal data updates
          if (dashboarddataversion.get('corousalVersion') != corousalVersion) {
            print("Updating corousal data...");
            carouselImages.clear();
            await _loadImageCorousalFromAPI();
            print("Corousal data updated");
            dashboarddataversion.put('corousalVersion', corousalVersion);
          } else {
            print("No updates for corousal data");
          }

          // Handle announcement data updates
          if (dashboarddataversion.get('announcementVersion') != announcementVersion) {
            print("Updating announcement data...");
            announcements.clear();
            await _loadAnnouncementsFromAPI();
            print("Announcement data updated");
            dashboarddataversion.put('announcementVersion', announcementVersion);
          } else {
            print("No updates for announcement data");
          }
          if (dashboarddataversion.get('directoryVersion') != directoryVersion) {
            print("Updating directory data...");
            await fetchDirectories();
            print("directory data updated");
            dashboarddataversion.put('directoryVersion', directoryVersion);
          } else {
            print("No updates for announcement data");
          }
        }
      } else if (response.statusCode == 403) {
        String newAccessToken = await RefreshTokenAPI.refresh();
        print('Refresh done');
        accessTokenN = newAccessToken;
        versionApiCheck(); // Retry with the new token
      }
    } catch (e) {
      print("Error during version API call: $e");
    }
  }
  Future<void> fetchDirectories() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/secured/hospital/all-directory/6673e7a3b92e69bc7f4b40ae'),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          List<dynamic> data = responseData['data'];
          directory = data;
          DashboardListBox.put('directories', json.encode(data));
        }
      } else if (response.statusCode == 403) {
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        fetchDirectories();
      } else {

        print('Failed to load directories: ${response.statusCode}');
      }
    } catch (e) {

      print('Error fetching directories: $e');
    }
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    print(status);


    if (status.isGranted) {
      print('location permission granted');
      return true;


    } else if(status.isPermanentlyDenied) {
      print('location permission is permanently granted');
      return false;

    }else{
      print("location permission is granted");
      return false;
    }
  }


  Future<void> _launchInWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }
  void loadInfoToFile(){
    var infoBox=Hive.box('SignInDatabase');
    String accessToken = infoBox.get('accessToken');
    print('loadInfoToFile');
    print(infoBox.get('userId'));

    UsergetAPI().getUserDetailsApi(infoBox.get('userId'));

    if(!userInfoBox.containsKey("userTrackingOn")){
      promptLocationAccess();
    }
  }

  var userInfoBox=Hive.box('UserInformation');

  void promptLocationAccess() {
    if(userInfoBox.containsKey("userTracking") && userInfoBox.get("userTracking")){
      print("userTracking on");
      showLocationTrackingDialog(context);
    }else{
      print("userTracking off");
    }
  }

  void showLocationTrackingDialog(BuildContext context) {
    userInfoBox.put("userTrackingOn", "yes");
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Google-style rounded corners
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue,size: 40,), // Google Maps-like icon
              SizedBox(width: 8),
              Text("Location Tracking"),
              SizedBox(width: 8),
            ],
          ),
          content: Text(
            "To enhance your experience, this app continuously tracks your location, even when closed or not in use.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text("OK", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  var versionBox = Hive.box('VersionData');
  void versionApiCall() async{
    try {
      await DataVersionApi()
          .fetchDataVersionApiData(buildingAllApi.selectedBuildingID);

      loadInfoToFile();
    }catch(e){

    }
  }
  var DashboardListBox = Hive.box('DashboardList');
  var userListBox = Hive.box('user');

  Future<void> checkForReload() async {
    if(userListBox.containsKey('name')){
      userName = userListBox.get('name');
      print('name from database');
    }else{
      getUserDataFromHive();
      print("name from api");
    }
    print("driver check");
    print(userListBox.containsKey('isDriver'));
    print(userListBox.get('isDriver'));
    if(userListBox.containsKey('isDriver')) {

      if (userListBox.get('isDriver')) {
        print("Driver");
        await LocationTrackingService().initialize();
        LocationTrackingService().startTracking();
      }
    }
    if(userListBox.containsKey('username')){
      emailAddress = userListBox.get('username');
      print('username from database');
    }else{
      // getUserDetails();
      getUserDataFromHive();
      print("username from api");
    }
    if(DashboardListBox.containsKey('carouselImages')){
      carouselImages = DashboardListBox.get('carouselImages');
      print('_loadImageCorousalFromAPI FROM DATABASE');

    }else{
      _loadImageCorousalFromAPI();
      print('_loadImageCorousalFromAPI API CALL');
    }

    if(DashboardListBox.containsKey('_services')){
      _services = DashboardListBox.get('_services');
      // _pharmacyfilteredServices = DashboardListBox.get('_pharmacyfilteredServices');
      print('_loadServicesFromAPI FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_loadServicesFromAPI API CALL');
    }
    if(DashboardListBox.containsKey('_pharmacyfilteredServices')){
      // _services = DashboardListBox.get('_services');
      _pharmacyfilteredServices = DashboardListBox.get('_pharmacyfilteredServices');
      print(_pharmacyfilteredServices);
      print('_pharmacyfilteredServices FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_pharmacyfilteredServices API CALL');
    }
    if(DashboardListBox.containsKey('_emergencyfilteredService')){
      // _services = DashboardListBox.get('_services');
      _emergencyfilteredService = DashboardListBox.get('_emergencyfilteredService');
      print('_emergencyfilteredService FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_emergencyfilteredService API CALL');
    }
    ////
    if(DashboardListBox.containsKey('_atmfilteredServices')){
      // _services = DashboardListBox.get('_services');
      _atmfilteredServices = DashboardListBox.get('_atmfilteredServices');
      print('_atmfilteredServices FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_atmfilteredServices API CALL');
    }
    if(DashboardListBox.containsKey('_countersfilteredServices')){
      // _services = DashboardListBox.get('_services');
      _countersfilteredServices = DashboardListBox.get('_countersfilteredServices');
      print('_countersfilteredServices FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_countersfilteredServices API CALL');
    }
    if(DashboardListBox.containsKey('_cafeteriafilteredServices')){
      // _services = DashboardListBox.get('_services');
      _cafeteriafilteredServices = DashboardListBox.get('_cafeteriafilteredServices');
      print('_cafeteriafilteredServices FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_cafeteriafilteredServices API CALL');
    }
    /////
    if(DashboardListBox.containsKey('announcements')){
      announcements = DashboardListBox.get('announcements');
      print('_loadAnnouncementsFromAPI FROM DATABASE');
    }else{
      _loadAnnouncementsFromAPI();
      print('_loadAnnouncementsFromAPI API CALL');

    }
    if(DashboardListBox.containsKey('directories')){
      print(DashboardListBox.get('directories'));
      print('directories FROM DATABASE');
    }else{
      fetchDirectories();
      print('directories API CALL');

    }
    if(DashboardListBox.containsKey('_doctors')){
      _doctors = DashboardListBox.get('_doctors');
      setState(() {
        _filteredDoctors = _doctors;
      });
      print('_doctors FROM DATABASE');

    }else{
      _loadDoctorsFromAPI();
      print('_doctors from api');
    }

  }
  Future<void> getDriverDetail() async {
    final String baseUrl = "${AppConfig.baseUrl}/secured/user/get";

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({"userId": userId}),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );
      print("driver get");
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        setState(() async {

          isDriver = responseBody["userTracking"]??false;
          if(isDriver) {
            await LocationTrackingService().initialize();
            LocationTrackingService().startTracking();
          }
          userListBox.put('isDriver', isDriver);
          print("userTracking11");
          print(isDriver);
          print(responseBody['userTracking']);
          print(userListBox.get('isDriver'));
        });
      } else if (response.statusCode == 403) {
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        await getDriverDetail();

      } else {
      }
    } catch (e) {
      // Handle errors
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    // _internetConnection?.cancel();
    super.dispose();
  }
  // Future<void> checkConnectivity() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   setState(() {
  //     isOnline = connectivityResult != ConnectivityResult.none;
  //   });
  // }
  Future<void> _loadDoctorsFromAPI() async {
    try {

      print('trying');
      final response = await http.get(

        Uri.parse("${AppConfig.baseUrl}/secured/hospital/all-doctors/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
        },);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            _doctors = responseData['data'];
            _filteredDoctors = _doctors;
            DashboardListBox.put('_doctors', responseData['data']);

          });
        } else {
          throw Exception('Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
      }else if(response.statusCode==403){
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        _loadDoctorsFromAPI();

      } else {
        print("nope");
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }
  void _showNoInternetSnackbar() {
    setState(() {
      // isConnectedToInternet = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(

        margin: EdgeInsets.only(bottom: 90,right: 10,left:10),
        content: Text('No Internet Connection'),

        behavior: SnackBarBehavior.floating,
        duration: Duration(days: 1), // Long duration to keep the snackbar visible
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            // Attempt to check the connection again
            _checkInternetConnection();
          },
        ),
      ),
    );
  }

  void _hideNoInternetSnackbar() {
    setState(() {
      // isConnectedToInternet = true;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _checkInternetConnection() async {
    bool isConnected = true;
    if (isConnected) {
      _hideNoInternetSnackbar();
    } else {
      _showNoInternetSnackbar();
    }
  }
  Future<void> _loadImageCorousalFromAPI() async {
    try {

      print('trying');
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/secured/hospital/all-corousal/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
        if (responseData.containsKey('data') &&
            responseData['data'] is List) {
          setState(() {

            carouselImages = responseData['data'];
            DashboardListBox.put("carouselImages",responseData['data']);

          });


        } else {
          throw Exception(
              'Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
        ////
        // To be later changed according to distance
        ////
        _services.sort((a, b) => a['endTime'].compareTo(b['endTime']));
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  Future<void> _loadAnnouncementsFromAPI() async {
    try {

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/secured/hospital/all-announcement/6673e7a3b92e69bc7f4b40ae'),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData['status'] == true && responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            announcements = responseData['data'];
            DashboardListBox.put('announcements', responseData['data']);
          });
          // print(announcements);
        } else {
          throw Exception('Response data does not contain the expected list of announcements');
        }
      }else if(response.statusCode==403){
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        _loadAnnouncementsFromAPI();

      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }


  Future<void> _loadServicesFromAPI() async {
    try {

      print('trying');
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/secured/hospital/all-services/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
        if (responseData.containsKey('data') &&
            responseData['data'] is List) {
          setState(() {
            _services = responseData['data'];
            _filteredServices = _services;
            _pharmacyfilteredServices = _services.where((service) => service['type'] == 'Pharmacy').toList();
            _atmfilteredServices = _services.where((service) => service['type'] == 'ATM').toList();
            _countersfilteredServices = _services.where((service) => service['type'] == 'Counters').toList();
            _cafeteriafilteredServices = _services.where((service) => service['type'] == 'Cafeteria').toList();
            _emergencyfilteredService = _services.where((service) => service['type'] == 'Ambulance' || service['type'] == 'BloodBank').toList();
            DashboardListBox.put('_services', responseData['data']);
            DashboardListBox.put('_pharmacyfilteredServices', _services.where((service) => service['type'] == 'Pharmacy').toList());
            DashboardListBox.put('_atmfilteredServices', _services.where((service) => service['type'] == 'ATM').toList());
            DashboardListBox.put('_countersfilteredServices', _services.where((service) => service['type'] == 'Counters').toList());
            DashboardListBox.put('_cafeteriafilteredServices', _services.where((service) => service['type'] == 'Cafeteria').toList());
            DashboardListBox.put('_emergencyfilteredService', _services.where((service) => service['type'] == 'Ambulance' || service['type'] == 'BloodBank').toList());


          });
        } else {
          throw Exception(
              'Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
        ////
        // To be later changed according to distance
        ////
        _services.sort((a, b) => a['endTime'].compareTo(b['endTime']));
      }else if(response.statusCode==403){
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        _loadServicesFromAPI();

      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }


  Future<void> _refresh() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print("Connectivity Result: $connectivityResult");

    // Check if the result contains wifi or mobile connectivity
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      setState(() {
        carouselImages.clear();
        _services.clear();
        _filteredServices.clear();
        announcements.clear();
        // news.clear();
        DashboardListBox.clear();
      });

      final BeaconBox = BeaconAPIModelBOX.getData();
      final DataBox = DataVersionLocalModelBOX.getData();
      final BuildingAllBox = BuildingAllAPIModelBOX.getData();
      final buildingData = BuildingAPIModelBox.getData();
      final LandMarkBox = LandMarkApiModelBox.getData();
      final PatchBox = PatchAPIModelBox.getData();
      final PolyLineBox = PolylineAPIModelBOX.getData();
      final WayPointBox = WayPointModeBOX.getData();
      final OutBuildingBox = OutDoorModeBOX.getData();

      BeaconBox.clear();
      BuildingAllBox.clear();
      buildingData.clear();
      LandMarkBox.clear();
      PatchBox.clear();
      PolyLineBox.clear();
      WayPointBox.clear();
      OutBuildingBox.clear();
      DataBox.clear();

      print("Refreshed");

      await _loadImageCorousalFromAPI();
      await _loadServicesFromAPI();
      await _loadAnnouncementsFromAPI();
      // await _loadNewsFromAPI();
      versionApiCall();
      checkForReload();
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'No Internet Connection',
        text: 'Please check your internet connection and try again.',
      );
    }
  }



  void animateToNextPage() {
    if (_currentPage < 4) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  // // Function to start automatic animation
  // void startAutoAnimation() {
  //   Timer.periodic(Duration(seconds: 40), (Timer timer) {
  //     animateToNextPage();
  //   });
  // }
  void _scrollToNext() {
    if (_currentIndex < announcements.length - 2) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _scrollController.animateTo(
      _currentIndex * 80.0,
      duration: Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
    );
  }

  // Future<void> getUserDetails() async {
  //
  //   setState(() {
  //     nameLoading = true;
  //   });
  //   final String baseUrl = "${AppConfig.baseUrl}/secured/user/get";
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(baseUrl),
  //       body: json.encode({"userId": userId}),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'x-access-token': '$accessToken',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> responseBody = json.decode(response.body);
  //       setState(() {
  //         userName = responseBody["name"];
  //         emailAddress = responseBody["email"];
  //         userListBox.put('name', userName);
  //         userListBox.put('username',responseBody['username']);
  //       });
  //     } else if (response.statusCode == 403) {
  //       String newAccessToken = await RefreshTokenAPI.refresh();
  //       accessToken = newAccessToken;
  //       getUserDetails();
  //     }else {
  //       // Handle other status codes
  //     }
  //   } catch (e) {
  //     // Handle errors
  //   }finally {
  //     setState(() {
  //       nameLoading = false;
  //     });
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      onRefresh: _refresh,

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 120,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //           children: [
                  //             TranslatorWidget("Hello, "),
                  //             nameLoading
                  //                 ? CircularProgressIndicator()
                  //                 : TranslatorWidget(
                  //                                   "$userName",
                  //                                   style: const TextStyle(
                  //             fontFamily: "Roboto",
                  //             fontSize: 20,
                  //             fontWeight: FontWeight.w700,
                  //             color: Color(0xff18181b),
                  //             height: 26 / 20,
                  //                                   ),
                  //                                   textAlign: TextAlign.left,
                  //                                 ),
                  //           ],
                  //         ),
                  //     TranslatorWidget(
                  //       "How can we help you today?",
                  //       style: TextStyle(
                  //         fontFamily: "Roboto",
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w400,
                  //         color: Color(0xff5e5e5f),
                  //         height: 20 / 14,
                  //       ),
                  //       textAlign: TextAlign.left,
                  //     )
                  //   ],
                  // ),
                  // SvgPicture.asset('assets/images/dashboardlogo.svg',height: 40,width: 40,),
                  Image.asset('assets/images/dashboardlogo.png',height: 50,width: 50,),
                  Column(
                    children: [
                      Text(
                        'AIIMS JAMMU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF003666),
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 1.20,
                          letterSpacing: 0.24,
                        ),
                      ),
                      Text(
                        'Navigation for All',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                          letterSpacing: 0.01,
                        ),
                      )
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_none_outlined),
                    color: Color(0xff18181b),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.only(left: 16, right: 8),
                decoration: BoxDecoration(
                  // color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: Color(0xFFE0E0E0), width: 1),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      child: SvgPicture.asset(
                          'assets/images/searchicon.svg'),
                    ),
                    // Icon(Icons.search),
                    SizedBox(width: 16),
                    // Semantics(
                    //   header: true,
                    //   // label: "Search Bar",
                    //   child: GestureDetector(
                    //     onTap: (){
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => DestinationSearchPage(voiceInputEnabled: false)),
                    //       );
                    //     },
                    //     child: Container(
                    //       width: MediaQuery.sizeOf(context).width * 0.67,
                    //       child: TextField(
                    //         decoration: InputDecoration(
                    //           hintText: 'Doctor, services..',
                    //           border: InputBorder.none,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Semantics(
                      header: true,
                      // label: "Search Bar",
                      child: GestureDetector(
                        onTap: () {
                          InteractionManager().logInteraction('Search Bar');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GlobalSearchPage(voiceInputEnabled: false),
                            ),
                          ).then((value) => PassLocationId(context, value));
                        },
                        child: Container(
                            padding: EdgeInsets.only(top: 8),
                            width: MediaQuery.of(context).size.width * 0.67,
                            height: 40,
                            child: TranslatorWidget(
                              "Where do you want to go?",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff535353),

                              ),
                              textAlign: TextAlign.left,
                            )
                        ),
                      ),
                    ),

                    // SizedBox(width: 26,),
                    // Spacer(),
                    // Semantics(
                    //   label: "Microphone",
                    //   child: Icon(
                    //     Icons.mic_none_outlined,
                    //     color: Color(0xff8E8C8C),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 10,),

            ],
          ),
        ),
        body: isOnline?Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [

                  Column(
                    children: [

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 8.0, horizontal: 16),
                      //   child:ImageCarouselWidget(
                      //     imagesWithText: carouselImages.map((item) => ImageTextPair(
                      //       webUrl: item['webUrl'],
                      //       image: item['image'],
                      //       text: item['text'],
                      //       subText: item['subText'],
                      //     )).toList(),
                      //   ),
                      //       // ImageCarouselWidget(imagesWithText: carouselImages),
                      //
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                        child: _buildMainServices(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 12),
                        child: Row(
                          children: [
                            Semantics(
                              header: true,
                              child: TranslatorWidget(
                                "Nearby Amenities",
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff18181b),
                                  height: 23 / 16,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,right: 16),
                        child: _buildAmenities(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            Semantics(
                              header: true,
                              child: TranslatorWidget(
                                "Hospital Services",
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff18181b),
                                  height: 23 / 16,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            GestureDetector(
                                onTap: () {
                                  InteractionManager().logInteraction('Doctor Category');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DoctorListScreen()),
                                  );
                                },
                                child: _buildCard(
                                    'assets/images/Doctor.svg', 'Doctor')),
                            GestureDetector(
                                onTap: () {
                                  InteractionManager().logInteraction('Directrory Category');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HospitalDirectory()),
                                  );
                                },
                                child: _buildCard(
                                    'assets/images/Directory.svg', 'Directory')),
                            if(_pharmacyfilteredServices.isNotEmpty)
                              SizedBox(width: 12),

                            if(_pharmacyfilteredServices.isNotEmpty)
                              GestureDetector(
                                  onTap: () {
                                    InteractionManager().logInteraction('Pharmacy Category');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PharmacyScreen()),
                                    );
                                  },child: _buildCard('assets/images/Pharmacy.svg', 'Pharmacy')),

                            if(_emergencyfilteredService.isNotEmpty)
                              SizedBox(width: 12),
                            if(_emergencyfilteredService.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  InteractionManager().logInteraction('Emergency Category');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EmergencyScreen()),
                                  );
                                },
                                child: _buildCard(
                                    'assets/images/Doctor (1).svg', 'Emergency'),
                              ),
                            if(_atmfilteredServices.isNotEmpty)
                              SizedBox(width: 12),
                            if(_atmfilteredServices.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  InteractionManager().logInteraction('ATM Category');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ATMScreen()),
                                  );
                                },
                                child: _buildCard(
                                    'assets/images/Atm.svg', 'ATM'),
                              ),
                            if(_cafeteriafilteredServices.isNotEmpty)
                              SizedBox(width: 12),
                            if(_cafeteriafilteredServices.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  InteractionManager().logInteraction('Cafeteria Category');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CafeteriaScreen()),
                                  );
                                },
                                child: _buildCard(
                                    'assets/images/Cafetaria.svg', 'Cafeteria'),
                              ),
                            if(_countersfilteredServices.isNotEmpty)
                              SizedBox(width: 12),
                            if(_countersfilteredServices.isNotEmpty)
                              GestureDetector(
                                  onTap: () {
                                    InteractionManager().logInteraction('Counters Category');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CountersScreen()),
                                    );
                                  },

                                  child: _buildCard('assets/images/counter.svg', 'Counters')),
                            if(_otherfilteredServices.isNotEmpty)
                              SizedBox(width: 12),
                            if(_otherfilteredServices.isNotEmpty)
                              GestureDetector(
                                  onTap: () {
                                    InteractionManager().logInteraction('Others Category');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OtherServiceScreen()),
                                    );
                                  },

                                  child: _buildCard('assets/images/cat.svg', 'Others')),
                            SizedBox(
                              width: 12,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 16.0, bottom: 12),
                      //   child: Row(
                      //     children: [
                      //       Semantics(
                      //         header: true,
                      //         child: TranslatorWidget(
                      //           "Hospital Navigation",
                      //           style: TextStyle(
                      //             fontFamily: "Roboto",
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w500,
                      //             color: Color(0xff18181b),
                      //             height: 23 / 16,
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Semantics(
                      //   onTap: (){
                      //     InteractionManager().logInteraction('Map');
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => Navigation(),
                      //       ),
                      //     );
                      //   },
                      //   header: true,
                      //   label: "Map",
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(16.0),
                      //     child: GestureDetector(
                      //       onPanStart: (details) {
                      //         showDialog(
                      //           context: context,
                      //           barrierColor: Colors.black.withOpacity(0.5),
                      //           builder: (BuildContext context) {
                      //             return GestureDetector(
                      //               onTap: () {
                      //                 Navigator.pop(context);
                      //               },
                      //               child: Stack(
                      //                 children: [
                      //                   BackdropFilter(
                      //                     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      //                     child: Container(
                      //                       color: Colors.black.withOpacity(0),
                      //                     ),
                      //                   ),
                      //                   Center(
                      //                     child: GestureDetector(
                      //                       onTap: () {
                      //
                      //                       },
                      //                       child: Dialog(
                      //                         insetPadding: EdgeInsets.zero,
                      //                         backgroundColor: Colors.transparent,
                      //                         child: Container(
                      //                           width: MediaQuery.sizeOf(context).width * 0.7,
                      //                           height: MediaQuery.sizeOf(context).height * 0.45,
                      //                           child: mapPreview ?? defaultMap(),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             );
                      //           },
                      //         );
                      //       },
                      //       onLongPress: () {
                      //         showDialog(
                      //           context: context,
                      //           barrierColor: Colors.black.withOpacity(0.5),
                      //           builder: (BuildContext context) {
                      //             return GestureDetector(
                      //               onTap: () {
                      //                 Navigator.pop(context);
                      //               },
                      //               child: Stack(
                      //                 children: [
                      //                   BackdropFilter(
                      //                     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      //                     child: Container(
                      //                       color: Colors.black.withOpacity(0),
                      //                     ),
                      //                   ),
                      //                   Center(
                      //                     child: GestureDetector(
                      //                       onTap: () {
                      //                       },
                      //                       child: Dialog(
                      //                         insetPadding: EdgeInsets.zero,
                      //                         backgroundColor: Colors.transparent,
                      //                         child: Container(
                      //                           width: MediaQuery.sizeOf(context).width * 0.7,
                      //                           height: MediaQuery.sizeOf(context).height * 0.5,
                      //                           child: mapPreview ?? defaultMap(),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             );
                      //           },
                      //         );
                      //       },
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //         height: 160,
                      //         child: mapPreview ?? defaultMap(),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child:ImageCarouselWidget(
                          imagesWithText: carouselImages.map((item) => ImageTextPair(
                            webUrl: item['webUrl'],
                            image: item['image'],
                            text: item['text'],
                            subText: item['subText'],
                          )).toList(),
                        ),
                        // ImageCarouselWidget(imagesWithText: carouselImages),

                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 16.0, vertical: 16),
                      //   child: Row(
                      //     children: [
                      //       Semantics(
                      //         header: true,
                      //         child: TranslatorWidget(
                      //           "Nearby Services",
                      //           style: TextStyle(
                      //             fontFamily: "Roboto",
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w500,
                      //             color: Color(0xff18181b),
                      //             height: 23 / 16,
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //       ),
                      //       Spacer(),
                      //       GestureDetector(
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) => ServiceListScreen()),
                      //           );
                      //         },
                      //         child: TranslatorWidget(
                      //           "View all",
                      //           style: TextStyle(
                      //             fontFamily: "Roboto",
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //             color: Color(0xff000000),
                      //             height: 20 / 14,
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      //
                      // Container(
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   height: 270,
                      //   child: ListView(
                      //     scrollDirection: Axis.horizontal,
                      //     children: _services.map<Widget>((service) {
                      //       return Padding(
                      //         padding: const EdgeInsets.only(left: 12.0),
                      //         child: GestureDetector(
                      //           onTap: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => ServiceInfo(
                      //                   imagePath:  '${service['image']}',
                      //                   name: '${service['name']}',
                      //                   location: '${service['locationName']}',
                      //                   accessibility: '${service['accessibility']}',
                      //                   locationId: '${service['locationId']}',
                      //                   type: '${service['type']}',
                      //                   startTime: '${service['startTime']}',
                      //                   endTime: '${service['endTime']}',
                      //                   contact: '${service['contact']}',
                      //                   about: '${service['about']}',
                      //                   id: '${service['_id']}',
                      //                   longitude: '${service['longitude']}',
                      //                   latitude: '${service['latitude']}',
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //           child: SizedBox(
                      //             child: NearbyServiceWidget(
                      //               id: '${service['_id']}',
                      //               imagePath:
                      //               '${service['image']}',
                      //               name:
                      //               '${service['name']}',
                      //               location:
                      //               '${service['locationName']}',
                      //               locationId:
                      //               '${service['locationId']}',
                      //               type:
                      //               '${service['type']}',
                      //               startTime:
                      //               '${service['startTime']}',
                      //               endTime:
                      //               '${service['endTime']}',
                      //               accessibility:
                      //               '${service['accessibility']}',
                      //               contact: '${service['contact']}',
                      //               about: '${service['about']}',
                      //               weekDays:
                      //               List<String>.from(service['weekDays']),
                      //               longitude: '${service['longitude']}',
                      //               latitude: '${service['latitude']}',
                      //               // '${service['locationId']}',
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),
                      //
                      //
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 8),
                      //   child: Row(
                      //     children: [
                      //       Semantics(
                      //         header:true,
                      //         child: TranslatorWidget(
                      //           "Announcements",
                      //           style: TextStyle(
                      //             fontFamily: "Roboto",
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w500,
                      //             color: Color(0xff18181b),
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //       ),
                      //       Spacer(),
                      //       GestureDetector(
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) => AllAnnouncementScreen()),
                      //           );
                      //         },
                      //         child: TranslatorWidget(
                      //           "View all",
                      //           style: TextStyle(
                      //             fontFamily: "Roboto",
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //             color: Color(0xff000000),
                      //
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      //
                      // Container(
                      //   height: 140,
                      //   child: ListView.builder(
                      //     controller: _scrollController,
                      //     scrollDirection: Axis.vertical,
                      //     itemCount: announcements.length,
                      //     itemBuilder: (BuildContext context, int index) {
                      //        final announcement = announcements[index];
                      //       return AnnouncementCard(
                      //         image: announcement['image']??"",
                      //         title: announcement['title']??"",
                      //         department: announcement['department']?? "",
                      //         dateTime: announcement['dateTime']??"",
                      //         article: announcement['article']??"",
                      //
                      //       );
                      //     },
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 16,
                      // ),
                      // Padding(
                      //   padding:
                      //   const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      //   child: Row(
                      //     children: [
                      //       TranslatorWidget(
                      //         'Connect with us',
                      //         style: TextStyle(
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //
                      //       ),
                      //
                      //     ],
                      //   ),
                      // ),
                      //
                      // Row(
                      //   children: [
                      //     SizedBox(
                      //       width: 16,
                      //     ),
                      //     InkWell(
                      //       onTap: () {
                      //         _launchInWebView(Uri.parse(twitter));
                      //       },
                      //       child: Container(
                      //         height: 40,
                      //         width: 40,
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(6.0),
                      //           child: Container(
                      //             height: 24,
                      //             width: 24,
                      //             child: SvgPicture.asset(
                      //                 "assets/images/twitter.svg"),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 8,
                      //     ),
                      //     InkWell(
                      //       onTap: () {
                      //         _launchInWebView(Uri.parse(youtube));
                      //       },
                      //       child: Container(
                      //         height: 40,
                      //         width: 40,
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(6.0),
                      //           child: Container(
                      //               height: 24,
                      //               width: 24,
                      //               child: SvgPicture.asset(
                      //                   "assets/images/youtube.svg")),
                      //         ),
                      //       ),
                      //     ),
                      //
                      //     SizedBox(
                      //       width: 8,
                      //     ),
                      //     InkWell(
                      //       onTap: () {
                      //         _launchInWebView(Uri.parse(facebook));
                      //       },
                      //       child: Container(
                      //         height: 40,
                      //         width: 40,
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(6.0),
                      //           child: Container(
                      //             height: 24,
                      //             width: 24,
                      //             child: SvgPicture.asset(
                      //                 "assets/images/facebook.svg"),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //
                      //     SizedBox(
                      //       width: 8,
                      //     ),
                      //     InkWell(
                      //       onTap: () {
                      //         _launchInWebView(Uri.parse(instagram));
                      //       },
                      //       child: Container(
                      //         height: 40,
                      //         width: 40,
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(6.0),
                      //           child: Container(
                      //               height: 24,
                      //               width: 24,
                      //               child: SvgPicture.asset(
                      //                   "assets/images/instagram.svg")),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ):TranslatorWidget("Offline"),
        floatingActionButton: FloatingActionButton(
          heroTag: 'homepage',
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Navigation(),
              ),
            );
          },
          backgroundColor: Color(0xFFFEAB01),
          shape: CircleBorder(),
          child: Semantics(
              label: "Map",
              child: Lottie.asset('assets/images/floatingmap.json')),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: (){
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => Navigation(),
        //       ),
        //     );
        //   },
        //   backgroundColor: Color(0xFFFEAB01),
        //   shape: CircleBorder(),
        //   child: Lottie.asset('assets/images/floatingmap.json'),
        // )
        // FloatingActionButton(onPressed: (){},
        // child: Lottie.asset('assets/images/floatingmap.json'),
        // ),
      ),
    );
  }
  Widget _buildAmenities() {
    final List<Map<String, dynamic>> amenities = [
      {'icon': Icons.local_atm, 'bg': Colors.blue[50], 'title': 'ATM','type':'ATM','image':'assets/images/Homepage-Category.svg'},
      {'icon': Icons.local_drink, 'bg': Colors.blue[50], 'title': 'Water','type':'drinkingwater','image':'assets/images/water.svg'},
      {'icon': Icons.directions_bus, 'bg': Colors.blue[50], 'title': 'Transport','type':'transport','image':'assets/images/Transport.svg'},
      {'icon': Icons.wc, 'bg': Colors.blue[50], 'title': 'Restroom','type':'washroom','image':'assets/images/Washroom.svg'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: amenities.map((amenity) {
          return GestureDetector(
            onTap:(){
              print("amenity['type']");
              print("${amenity['type']}");
              filterLandmarks(amenity['type'],0);
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: amenity['bg'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(amenity['image']),
                    // Icon(
                    //   amenity['icon'],
                    //   color: Color(0xff003666),
                    //   size: 30,
                    // ),
                  ),
                ),
                const SizedBox(height: 8),
                TranslatorWidget(
                  amenity['title'],
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  // Widget _buildMainServices() {
  //   final List<Map<String, dynamic>> services = [
  //     {
  //       'image': 'assets/images/opd.svg',
  //       'color': Color(0xFFEAF2FF),
  //       'iconColor': Color(0xFF003366),
  //       'title': 'OPD & Ayush',
  //       'buildingId':['66794105b80a6778c53c4856','679ca3fde7e7001d98497002'],
  //     },
  //     {
  //       'image':  'assets/images/emergency.svg',
  //       'color': Color(0xFFFAE9E9),
  //       'iconColor': Colors.red,
  //       'title': 'Emergency',
  //       'buildingId':['6798c6df96af63c3e82659ec'],
  //     },
  //     {
  //       'image':  'assets/images/ward.svg',
  //       'color': Color(0xFFFAF8E9),
  //       'iconColor': Color(0xFF6B8E23),
  //       'title': 'Ward',
  //       'buildingId':['6798c99e96af63c3e828203d','6798c81c96af63c3e826add3'],
  //     },
  //     {
  //       'image':  'assets/images/diagnostic.svg',
  //       'color': Color(0xFFE4F8EB),
  //       'iconColor': Color(0xFF00796B),
  //       'title': 'Diagnostic',
  //       'buildingId':['6798c8fa96af63c3e8277db2'],
  //     },
  //   ];
  //
  //   return GridView.count(
  //     shrinkWrap: true,
  //     physics: NeverScrollableScrollPhysics(),
  //     crossAxisCount: 2,
  //     crossAxisSpacing: 16,
  //     mainAxisSpacing: 16,
  //     childAspectRatio: 1.2,
  //     children: services.map((service) {
  //       return InkWell(
  //         onTap: (){
  //
  //           bool anyLandmarkExists = false;
  //           List<dynamic> allLandmarks = [];
  //           List<String> buildingIds = List<String>.from(service['buildingId']);
  //
  //           print("Selected service: ${service['title']}");
  //           print("Building IDs: $buildingIds");
  //
  //           // First, collect all landmarks from all buildings
  //           for (String id in buildingIds) {
  //             print("Processing building ID: $id");
  //             if (allLandmarkData.containsKey(id)) {
  //               print("Found landmarks for building: $id");
  //
  //               // Check if landmarks exist
  //               if (allLandmarkData[id]['landmarkExist'] == true) {
  //                 anyLandmarkExists = true;
  //               }
  //
  //               // Get landmarks list from this building and add to our collection
  //               if (allLandmarkData[id]['landmarks'] != null &&
  //                   allLandmarkData[id]['landmarks'] is List) {
  //                 List<dynamic> buildingLandmarks = List<dynamic>.from(allLandmarkData[id]['landmarks']);
  //                 print("Adding ${buildingLandmarks.length} landmarks from building $id");
  //                 allLandmarks.addAll(buildingLandmarks);
  //               }
  //             } else {
  //               print("No landmarks found for building: $id");
  //             }
  //           }
  //
  //           // Create the combined data with merged content
  //           Map<String, dynamic> combinedData = {
  //             'landmarkExist': anyLandmarkExists,
  //             'landmarks': allLandmarks
  //           };
  //
  //           print("Final combined landmarks count: ${allLandmarks.length}");
  //
  //           // Navigate to Buildinglandmarks with the combined data
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => Buildinglandmarks(
  //                 buildingName: service['title'],
  //                 buildingId: buildingIds.join(','),
  //                 landmarkData: combinedData,
  //               ),
  //             ),
  //           );
  //         },
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: service['color'],
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               SvgPicture.asset(service['image']),
  //               TranslatorWidget(
  //                 service['title'],
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }
  Widget _buildMainServices() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchServiceData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildShimmerGrid();
        }

        List<Map<String, dynamic>> services = snapshot.data!;

        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: services.map((service) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Buildinglandmarks(
                      buildingName: service['title'],
                      buildingId: service['buildingId'].join(','),
                      landmarkData: service['landmarkData'],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: service['color'],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(service['image']),
                    TranslatorWidget(
                      service['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Future<List<Map<String, dynamic>>> _fetchServiceData() async {
  //   final List<Map<String, dynamic>> services = [
  //     {
  //       'image': 'assets/images/opd.svg',
  //       'color': Color(0xFFEAF2FF),
  //       'iconColor': Color(0xFF003366),
  //       'title': 'OPD & Ayush',
  //       'buildingId':['66794105b80a6778c53c4856','679ca3fde7e7001d98497002'],
  //     },
  //     {
  //       'image': 'assets/images/emergency.svg',
  //       'color': Color(0xFFFAE9E9),
  //       'iconColor': Colors.red,
  //       'title': 'Emergency',
  //       'buildingId':['6798c6df96af63c3e82659ec'],
  //     },
  //     {
  //       'image': 'assets/images/ward.svg',
  //       'color': Color(0xFFFAF8E9),
  //       'iconColor': Color(0xFF6B8E23),
  //       'title': 'Ward',
  //       'buildingId':['6798c99e96af63c3e828203d','6798c81c96af63c3e826add3'],
  //     },
  //     {
  //       'image': 'assets/images/diagnostic.svg',
  //       'color': Color(0xFFE4F8EB),
  //       'iconColor': Color(0xFF00796B),
  //       'title': 'Diagnostic',
  //       'buildingId':['6798c8fa96af63c3e8277db2'],
  //     },
  //   ];
  //
  //   for (var service in services) {
  //     List<String> buildingIds = List<String>.from(service['buildingId']);
  //     bool anyLandmarkExists = false;
  //     List<dynamic> allLandmarks = [];
  //
  //     for (String id in buildingIds) {
  //       if (allLandmarkData.containsKey(id)) {
  //         if (allLandmarkData[id]['landmarkExist'] == true) {
  //           anyLandmarkExists = true;
  //         }
  //         if (allLandmarkData[id]['landmarks'] is List) {
  //           allLandmarks.addAll(List<dynamic>.from(allLandmarkData[id]['landmarks']));
  //         }
  //       }
  //     }
  //
  //     service['landmarkData'] = {
  //       'landmarkExist': anyLandmarkExists,
  //       'landmarks': allLandmarks,
  //     };
  //   }
  //
  //   return Future.delayed(Duration(seconds: 2), () => services); // Simulated API delay
  // }
  Future<List<Map<String, dynamic>>> _fetchServiceData() async {
    final List<Map<String, dynamic>> services = [
      {
        'image': 'assets/images/opd.svg',
        'color': Color(0xFFEAF2FF),
        'iconColor': Color(0xFF003366),
        'title': 'OPD & Ayush',
        'buildingId':['66794105b80a6778c53c4856','679ca3fde7e7001d98497002'],
      },
      {
        'image': 'assets/images/emergency.svg',
        'color': Color(0xFFFAE9E9),
        'iconColor': Colors.red,
        'title': 'Emergency',
        'buildingId':['6798c6df96af63c3e82659ec'],
      },
      {
        'image': 'assets/images/ward.svg',
        'color': Color(0xFFFAF8E9),
        'iconColor': Color(0xFF6B8E23),
        'title': 'Ward',
        'buildingId':['6798c99e96af63c3e828203d','6798c81c96af63c3e826add3'],
      },
      {
        'image': 'assets/images/diagnostic.svg',
        'color': Color(0xFFE4F8EB),
        'iconColor': Color(0xFF00796B),
        'title': 'Diagnostic',
        'buildingId':['6798c8fa96af63c3e8277db2'],
      },
    ];

    final completer = Completer<List<Map<String, dynamic>>>();

    const maxWaitTime = Duration(seconds: 20);
    Timer? timeoutTimer;

    // Function to check if data is ready
    bool isDataReady(List<Map<String, dynamic>> services) {
      // Check if any service has landmark data available
      return services.any((service) =>
      service.containsKey('landmarkData') &&
          service['landmarkData']['landmarkExist'] == true
      );
    }

    // Setup polling to check for data readiness
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      // Process landmark data for each service
      try {
        for (var service in services) {
          List<String> buildingIds = List<String>.from(service['buildingId']);
          bool anyLandmarkExists = false;
          List<dynamic> allLandmarks = [];

          for (String id in buildingIds) {
            if (allLandmarkData.containsKey(id)) {
              if (allLandmarkData[id]['landmarkExist'] == true) {
                anyLandmarkExists = true;
              }
              if (allLandmarkData[id]['landmarks'] is List) {
                allLandmarks.addAll(
                    List<dynamic>.from(allLandmarkData[id]['landmarks']));
              }
            }
          }

          service['landmarkData'] = {
            'landmarkExist': anyLandmarkExists,
            'landmarks': allLandmarks,
          };
        }
      }catch(e){

      }

      // Check if data is ready to be returned
      if (isDataReady(services)) {
        timer.cancel();
        if (timeoutTimer != null) timeoutTimer!.cancel();
        completer.complete(services);
      }
    });

    // Set a timeout just in case
    timeoutTimer = Timer(maxWaitTime, () {
      if (!completer.isCompleted) {
        completer.complete(services);
      }
    });

    return completer.future;
  }
  Widget _buildShimmerGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) => _buildShimmerCard()),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

}
Widget _buildCard(String imagePath, String text) {
  return Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      // ),
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            imagePath,
            width: 40,
            height: 43,
          ),
          SizedBox(height: 5),
          // Container(
          //   height: 1,
          //   color: Color(0xFFE0E0E0),
          // ),
          SizedBox(
            height: 5,
          ),
          TranslatorWidget(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildImpNote(
    String imagePath,
    ) {
  return Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          imagePath,
          width: 300,
          height: 130,
        ),
      ],
      // ),
    ),
  );
}

class CarouselImageData {
  final String image;
  final String text;
  final String subText;
  final String altText;

  CarouselImageData({
    required this.image,
    required this.text,
    required this.subText,
    required this.altText,
  });

  factory CarouselImageData.fromJson(Map<String, dynamic> json) {
    return CarouselImageData(
      image: json['image'],
      text: json['text'],
      subText: json['subText'],
      altText: json['altText'],
    );
  }
}

class AnnouncementAData {
  final String department;
  final String dateTime;
  final String article;



  AnnouncementAData({required this.department, required this.dateTime, required this.article});

  factory AnnouncementAData.fromJson(Map<String, dynamic> json) {
    return AnnouncementAData(
      department: json['department'],
      dateTime: json['dateTime'],
      article: json['article'],

    );
  }

}