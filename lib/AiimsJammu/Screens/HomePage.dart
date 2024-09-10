import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/SignIn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:iwaymaps/API/DataVersionApi.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/AiimsJammu/Screens/NoInternetConnection.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/OpeningClosingStatus.dart';
import '../../API/RefreshTokenAPI.dart';
import '../../API/UsergetAPI.dart';
import '../../APIMODELS/DataVersion.dart';
import '../../VersioInfo.dart';
import '../Widgets/Translator.dart';
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
import '../../API/guestloginapi.dart';
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
  int _currentPage = 0;
  String token = "";
  late int index;
  late ScrollController _scrollController;
  late Timer _timer;
  int _currentIndex = 0;
  String? userId;
  String? accessToken;
  String? refreshToken;
  String? userName;
  String? emailAddress;
  bool nameLoading= false;
  bool isOnline = true;
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    versionApiCheck();
    checkForReload();
    versionApiCall();

    isUserValid();


    index = 0;
    _scrollController = ScrollController(initialScrollOffset: 140.0);

  }
  Future<void> isUserValid() async{
    try{
      print("aaya");
     String refreshToken1= await RefreshTokenAPI.refresh();
     print(refreshToken1);
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
        Uri.parse("https://dev.iwayplus.in/secured/data-version1"),
        body: json.encode({
          "id": "6673e7a3b92e69bc7f4b40ae",
        }),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": accessTokenN ?? "",
        },
      );

      print("code");
      print(response.statusCode);

      if (response.statusCode == 200) {
        print("Version API call success");
        print(response.body);

        final responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          int newDoctorVersion = responseData['versionData']['doctorDataVersion'] ?? 0;
          int newServiceVersion = responseData['versionData']['serviceDataVersion'] ?? 0;
          int newCorousalVersion = responseData['versionData']['corousalDataVersion'] ?? 0;
          int newAnnouncementVersion = responseData['versionData']['announcementDataVersion'] ?? 0;

          // Update the state with the new version values
          setState(() {
            doctorVersion = newDoctorVersion;
            serviceVersion = newServiceVersion;
            corousalVersion = newCorousalVersion;
            announcementVersion = newAnnouncementVersion;
          });

          if (dashboarddataversion.get('doctorVersion') != doctorVersion) {
            print("Updating doctor data...");
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

  }
  var versionBox = Hive.box('VersionData');
  void versionApiCall() async{
    try {
      DataVersion dataVersion = await DataVersionApi()
          .fetchDataVersionApiData(buildingAllApi.selectedBuildingID);
      if (versionBox.containsKey("buildingID") &&
          versionBox.get("buildingID") == dataVersion.versionData!.buildingID) {
        print("Already present");
        if (dataVersion.versionData!.landmarksDataVersion ==
            versionBox.get("landmarksDataVersion")) {
          VersionInfo.landmarksDataVersionUpdate = false;
          print("LandmarkVersion change: False");
        } else {
          versionBox.put("landmarksDataVersion",
              dataVersion.versionData!.landmarksDataVersion);

          VersionInfo.landmarksDataVersionUpdate = true;
          print("LandmarkVersion change: True");
        }

        if (dataVersion.versionData!.polylineDataVersion ==
            versionBox.get("polylineDataVersion")) {
          VersionInfo.polylineDataVersionUpdate = false;

          print("PolylineVersion change: False");
          print(
              "${dataVersion.versionData!.polylineDataVersion} ${versionBox.get(
                  "polylineDataVersion")}");
        } else {
          VersionInfo.polylineDataVersionUpdate = true;
          print("PolylineVersion change: True");
          versionBox.put("polylineDataVersion",
              dataVersion.versionData!.polylineDataVersion);
          print(
              "${dataVersion.versionData!.polylineDataVersion} ${versionBox.get(
                  "polylineDataVersion")}");
        }

        if (dataVersion.versionData!.buildingDataVersion ==
            versionBox.get("buildingDataVersion")) {
          VersionInfo.buildingDataVersionUpdate = false;
          print("BuildingDataVersion change: False");
        } else {
          VersionInfo.buildingDataVersionUpdate = true;
          versionBox.put("buildingDataVersion",
              dataVersion.versionData!.buildingDataVersion);
          print("BuildingDataVersion change: True");
        }

        if (dataVersion.versionData!.patchDataVersion ==
            versionBox.get("patchDataVersion")) {
          VersionInfo.patchDataVersionUpdate = false;
          print("PatchDataVersion change: False");
        } else {
          VersionInfo.patchDataVersionUpdate = true;
          versionBox.put(
              "patchDataVersion", dataVersion.versionData!.patchDataVersion);

          print("PatchDataVersion change: True");
        }
      } else {
        print("Not present");
        versionBox.put("landmarksDataVersion",
            dataVersion.versionData!.landmarksDataVersion);
        versionBox.put("polylineDataVersion",
            dataVersion.versionData!.polylineDataVersion);
        versionBox.put("buildingDataVersion",
            dataVersion.versionData!.buildingDataVersion);
        versionBox.put(
            "patchDataVersion", dataVersion.versionData!.patchDataVersion);
        versionBox.put("sId", dataVersion.versionData!.sId);
        versionBox.put("iV", dataVersion.versionData!.iV);
        versionBox.put("createdAt", dataVersion.versionData!.createdAt);
        versionBox.put("updatedAt", dataVersion.versionData!.updatedAt);
        versionBox.put("buildingID", dataVersion.versionData!.buildingID);
      }
      loadInfoToFile();
    }catch(e){

    }
  }
  var DashboardListBox = Hive.box('DashboardList');
  var userListBox = Hive.box('user');

  void checkForReload(){
    if(userListBox.containsKey('name')){
      userName = userListBox.get('name');
      print('name from database');
    }else{
      // getUserDetails();
      getUserDataFromHive();
      print("name from api");
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
      await guestApi().guestlogin().then((value){
        if(value.accessToken != null){
          token = value.accessToken!;
        }
      });
      print('trying');
      final response = await http.get(

        Uri.parse("https://dev.iwayplus.in/secured/hospital/all-doctors/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": token,
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
      } else {
        print("nope");
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }
  void _loadOtherServicesFromAPI() async {

    try {
      await guestApi().guestlogin().then((value){
        if(value.accessToken != null){
          token = value.accessToken!;
        }
      });
      print('trying');
      final response = await http.get(

        Uri.parse("https://dev.iwayplus.in/secured/hospital/all-services/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": token,
        },);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData.containsKey('data') && responseData['data'] is List) {

          setState(() {
            _otherservices = responseData['data'];
            _otherfilteredServices = _otherservices.where((service) =>
            service['type'] != 'Pharmacy' &&
                service['type'] != 'Ambulance' &&
                service['type'] != 'BloodBank' &&
                service['type'] != 'Counters' &&
                service['type'] != 'Cafeteria'
            ).toList();

          });

        } else {
          throw Exception('Response data does not contain the expected list of doctors under the "ServiceData" key');
        }
      } else {
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
    bool isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected) {
      _hideNoInternetSnackbar();
    } else {
      _showNoInternetSnackbar();
    }
  }
  Future<void> _loadImageCorousalFromAPI() async {
    try {
      await guestApi().guestlogin().then((value) {
        if (value.accessToken != null) {
          token = value.accessToken!;
        }
      });
      print('trying');
      final response = await http.get(
        Uri.parse("https://dev.iwayplus.in/secured/hospital/all-corousal/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": token,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
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

  Future<void> refreshTokenAndRetryForGetUserDetails(String baseUrl) async {
    final String refreshTokenUrl = "https://dev.iwayplus.in/api/refreshToken";

    try {
      final response = await http.post(
        Uri.parse(refreshTokenUrl),
        body: json.encode({
          "refreshToken": refreshToken,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final newAccessToken = json.decode(response.body)["accessToken"];
        setState(() {
          accessToken = newAccessToken;
        });

        // Save the new access token to Hive
        final signInBox = await Hive.openBox('SignInDatabase');
        signInBox.put('accessToken', accessToken);

        // Retry the getUserDetails call with the new access token
        await getUserDetails();
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> _loadAnnouncementsFromAPI() async {
    try {
      await guestApi().guestlogin().then((value) {
        if (value.accessToken != null) {
          token = value.accessToken!;
        }
      });
      final response = await http.get(
        Uri.parse('https://dev.iwayplus.in/secured/hospital/all-announcement/6673e7a3b92e69bc7f4b40ae'),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": token,
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
          print(announcements);
        } else {
          throw Exception('Response data does not contain the expected list of announcements');
        }
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
      await guestApi().guestlogin().then((value) {
        if (value.accessToken != null) {
          token = value.accessToken!;
        }
      });
      print('trying');
      final response = await http.get(
        Uri.parse("https://dev.iwayplus.in/secured/hospital/all-services/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": token,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
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
  Future<void> getUserDataFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get("accessToken");
      refreshToken = signInBox.get("refreshToken");
    });

    if (userId != null && accessToken != null && refreshToken != null) {
      // If user ID, access token, and refresh token are available, call API
      getUserDetails();
    } else {
      // Handle case where user ID, access token, or refresh token is missing
    }
  }
  Future<void> getUserDetails() async {

    setState(() {
      nameLoading = true;
    });
    final String baseUrl = "https://dev.iwayplus.in/secured/user/get";

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({"userId": userId}),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        setState(() {
          userName = responseBody["name"];
          emailAddress = responseBody["email"];
          userListBox.put('name', userName);
          userListBox.put('username',responseBody['username']);
        });
      } else if (response.statusCode == 403) {
        await refreshTokenAndRetryForGetUserDetails(baseUrl);

      }else {
        // Handle other status codes
      }
    } catch (e) {
      // Handle errors
    }finally {
      setState(() {
        nameLoading = false;
      });
    }

  }

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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                            children: [
                              TranslatorWidget("Hello, "),
                              nameLoading
                                  ? CircularProgressIndicator()
                                  : TranslatorWidget(
                                                    "$userName",
                                                    style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff18181b),
                              height: 26 / 20,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                            ],
                          ),
                      TranslatorWidget(
                        "How can we help you today?",
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff5e5e5f),
                          height: 20 / 14,
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                  Spacer(),
                  // IconButton(
                  //   icon: Icon(Icons.notifications_none_outlined),
                  //   color: Color(0xff18181b),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => NotificationScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DestinationSearchPage(voiceInputEnabled: false),
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
                                "Categories",
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DoctorListScreen()),
                                  );
                                },
                                child: _buildCard(
                                    'assets/images/Doctor.svg', 'Doctor')),
                            if(_pharmacyfilteredServices.isNotEmpty)
                            SizedBox(width: 12),

                            if(_pharmacyfilteredServices.isNotEmpty)
                            GestureDetector(
                                onTap: () {
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16),
                        child: Row(
                          children: [
                            Semantics(
                              header: true,
                              child: TranslatorWidget(
                                "Nearby Services",
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
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ServiceListScreen()),
                                );
                              },
                              child: TranslatorWidget(
                                "View all",
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff000000),
                                  height: 20 / 14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            )
                          ],
                        ),
                      ),



                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 270,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _services.map<Widget>((service) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServiceInfo(
                                        imagePath:  '${service['image']}',
                                        name: '${service['name']}',
                                        location: '${service['locationName']}',
                                        accessibility: '${service['accessibility']}',
                                        locationId: '${service['locationId']}',
                                        type: '${service['type']}',
                                        startTime: '${service['startTime']}',
                                        endTime: '${service['endTime']}',
                                        contact: '${service['contact']}',
                                        about: '${service['about']}',
                                        id: '${service['_id']}',
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  child: NearbyServiceWidget(
                                    id: '${service['_id']}',
                                    imagePath:
                                    '${service['image']}',
                                    name:
                                    '${service['name']}',
                                    location:
                                    '${service['locationName']}',
                                    locationId:
                                    '${service['locationId']}',
                                    type:
                                    '${service['type']}',
                                    startTime:
                                    '${service['startTime']}',
                                    endTime:
                                    '${service['endTime']}',
                                    accessibility:
                                    '${service['accessibility']}',
                                    contact: '${service['contact']}',
                                    about: '${service['about']}',
                                    weekDays:
                                    List<String>.from(service['weekDays']),
                                    // '${service['locationId']}',
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 8),
                        child: Row(
                          children: [
                            Semantics(
                              header:true,
                              child: TranslatorWidget(
                                "Announcements",
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff18181b),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AllAnnouncementScreen()),
                                );
                              },
                              child: TranslatorWidget(
                                "View all",
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff000000),

                                ),
                                textAlign: TextAlign.left,
                              ),
                            )
                          ],
                        ),
                      ),

                      Container(
                        height: 140,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: announcements.length,
                          itemBuilder: (BuildContext context, int index) {
                             final announcement = announcements[index];
                            return AnnouncementCard(
                              image: announcement['image']??"",
                              title: announcement['title']??"",
                              department: announcement['department']?? "",
                              dateTime: announcement['dateTime']??"",
                              article: announcement['article']??"",

                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        child: Row(
                          children: [
                            TranslatorWidget(
                              'Connect with us',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),

                            ),

                          ],
                        ),
                      ),

                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          InkWell(
                            onTap: () {
                              _launchInWebView(Uri.parse(twitter));
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  child: SvgPicture.asset(
                                      "assets/images/twitter.svg"),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              _launchInWebView(Uri.parse(youtube));
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Container(
                                    height: 24,
                                    width: 24,
                                    child: SvgPicture.asset(
                                        "assets/images/youtube.svg")),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              _launchInWebView(Uri.parse(facebook));
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  child: SvgPicture.asset(
                                      "assets/images/facebook.svg"),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              _launchInWebView(Uri.parse(instagram));
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Container(
                                    height: 24,
                                    width: 24,
                                    child: SvgPicture.asset(
                                        "assets/images/instagram.svg")),
                              ),
                            ),
                          ),
                        ],
                      ),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      ),
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
          Container(
            height: 1,
            color: Color(0xFFE0E0E0),
          ),
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

Widget _buildNearbyService(String imagePath, String name, String Location,
    String locationId, String type,String startTime, String endTime,String accessibility,List<String> weekDays) {

  return Container(
    color: Colors.white,
    child: GestureDetector(

      // onTap: () {
      //   // PassLocationId(locationId);
      //
      //
      // },
      child: Card(
        shadowColor: Color(0xff000000).withOpacity(0.25),
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFE0E0E0), width: 1),
          ),
          width: 250,
          child: Stack(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [

                    Image.network(
                      'https://dev.iwayplus.in/uploads/${imagePath}',
                      width: 250,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      // child: Container(
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     color: Colors.transparent.withOpacity(
                      //         0.2),
                      //   ),
                      //   child: IconButton(
                      //     disabledColor: Colors.grey,
                      //     onPressed: () {},
                      //     icon: Icon(
                      //       isFavorite ? Icons.favorite : Icons.favorite_border,
                      //       color: isFavorite ? Colors.red : null,
                      //     ),
                      //     color: Colors.white,
                      //   ),
                      // ),
                      child: Container(
                        // width: 73,
                        height: 26,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF05AF9A),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TranslatorWidget(
                              type,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0.12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                    ),
                    TranslatorWidget(
                      name,
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff18181b),

                      ),
                      textAlign: TextAlign.left,
                    ),

                    if(accessibility!='NO')
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/images/accessible.png',scale: 4,),
                      )
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF8D8C8C),
                      size: 16,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    TranslatorWidget(
                      Location,
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8D8C8C),

                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                      child: SvgPicture.asset('assets/images/routing.svg'),

                    ),
                    SizedBox(
                      width: 8,
                    ),

                    FutureBuilder<double>(
                      future: calculateDistance(locationId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            width: 25,
                            height: 25,// Adjust width as needed
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return TranslatorWidget(
                            'Error',
                            style: TextStyle(color: Colors.red),
                          );
                        } else {
                          return Text(
                            '${snapshot.data!.toStringAsFixed(2)} m',
                            style: TextStyle(
                              color: Color(0xFF8D8C8C),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                            ),
                          );
                        }
                      },
                    ),

                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  children: [
                    SizedBox(width: 12,),
                    Container(
                      // height: 20,
                        child: OpeningClosingStatus(startTime: startTime, endTime: endTime,)),
                  ],
                ),
                SizedBox(height: 5,)
              ],
            ),
          ]),
        ),
      ),
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
