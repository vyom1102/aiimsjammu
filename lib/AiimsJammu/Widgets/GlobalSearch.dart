
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/LocationIdFunction.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:string_similarity/string_similarity.dart';


import 'package:chips_choice/chips_choice.dart';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../API/RefreshTokenAPI.dart';
import '../../APIMODELS/landmark.dart';
import '../../Elements/SearchpageCategoryResult.dart';
import '../../Elements/SearchpageResults.dart';
import '../../StringStorage.dart';
import '../../Userbox.dart';
import '../../config.dart';
import '../../navigationTools.dart';
import '../../selectOnMapScreen.dart';
import '../../singletonClass.dart';
import '../Screens/DoctorProfile.dart';
import '../Screens/ServiceInfo.dart';
import '/API/buildingAllApi.dart';
import '/API/ladmarkApi.dart';
import '/APIMODELS/buildingAll.dart';
import '/Elements/DestinationPageChipsWidget.dart';
import '/Elements/HelperClass.dart';
import '/Elements/SearchNearby.dart';
import '/Elements/SearchpageRecents.dart';
import '/UserState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

class GlobalSearchPage extends StatefulWidget {
  String hintText;
  String previousFilter;
  bool voiceInputEnabled;
  String userLocalized;
  UserState? user;
  bool frombottombar;


  GlobalSearchPage(
      {this.hintText = "",
        this.previousFilter = "",
        this.frombottombar = false,
        required this.voiceInputEnabled,
        this.userLocalized = "",this.user});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  land landmarkData = land();
  List<String> landmarkFuzzyNameList = [];
  List<dynamic> searchResults = [];
  List<Widget> recentResults = [];
  List<dynamic>_services = [];
  List<dynamic> recent = [];
  TextEditingController _controller = TextEditingController();
  Timer? _searchDebounce;
  final SpeechToText speetchText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = "";
  String searchHintString = "";
  bool topBarIsEmptyOrNot = false;
  int lastIndex = -1;
  String selectedButton = "";
  final coursesPerPage = 20;
  int currentPage = 1;
  List<String> buildingIds =["65d8835adb333f89456e687f","66b5adabb6d75023d8830957","66b5ae7cb6d75023d884233e"];
  String? userId;
  String? accessToken;
  String? refreshToken;
  Set<String> locations = Set();
  var DashboardListBox = Hive.box('DashboardList');
  List<dynamic> classroomcourses = [];
  List<dynamic> tenants=[];
  List<dynamic> _events=[];
  List<dynamic> artworks=[];
  FlutterTts flutterTts = FlutterTts();
  List<Widget> searcCategoryhResults = [];
  Color containerBoxColor = Color(0xffA1A1AA);
  Color micColor = Colors.black;
  bool micselected = false;
  int vall = -1;
  int lastval = -1;
  List<Widget> topSearches=[];
  static String apiUrl = '${AppConfig.baseUrl}/secured/techpark/all-directory/66d15dff0a6aa59c399401dc';
  Set<String> optionListForUI={};
  @override
  void initState() {
    super.initState();
    checkForReload();
    fetchandBuild();
    _controller.addListener(_onSearchChanged);
    if (widget.voiceInputEnabled) {
      initSpeech();
      setState(() {
        speetchText.isListening ? stopListening() : startListening();
      });
      if (!micselected) {
        micColor = Color(0xff24B9B0);
      }
    }
    if (widget.previousFilter != "") {
      setState(() {
        _controller.text = widget.previousFilter;
      });
    }
    setState(() {
      searchHintString = widget.hintText;
    });

    fetchRecents();
  }
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }
  Future<void> loadLandmarkData() async {
    try {
      Set<String> tempOptionSet = {}; // use Set to prevent duplicates
      await Future.forEach(
        landmarkData.landmarksMap!.entries,
            (MapEntry keyValue) async {
          var value = keyValue.value;
          final subType = value.element?.subType ?? '';
          final buildingID = value.buildingID;
          // Always include global types
          if (subType == "restRoom") {
            tempOptionSet.add("Washroom");
          } else if (subType == "ATM") {
            tempOptionSet.add("ATM");
          } else if (subType == "Drinking Water") {
            tempOptionSet.add("Drinking Water");
          }
          if (widget.user!.bid == buildingAllApi.outdoorID) return;
          // Conditional based on selected building ID
          if (buildingID == widget.user!.bid) {
            if (subType == "Cafeteria") {
              tempOptionSet.add("Cafeteria");
            } else if (subType == "main entry") {
              tempOptionSet.add("Exit");
            } else if (subType == "lift") {
              tempOptionSet.add("Lift");
            } else if (subType == "Help Desk | Reception") {
              tempOptionSet.add("Reception");
            }
          }
        },
      );

      setState(() {
        optionListForUI = tempOptionSet; // overwrite old list
        isUpdated = true;
      });
    } catch (e) {
      print("Error in updating list: $e");
      setState(() {
        isUpdated = false;
      });
    }
  }
  void fetchRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('recents');
    if (savedData != null) {
      recent = jsonDecode(savedData);
      setState(() {
        for (List<dynamic> value in recent) {
          if (buildingAllApi.getStoredAllBuildingID()[value[3]] != null) {
            recentResults.add(SearchpageRecents(
              name: value[0],
              location: value[1],
              onVenueClicked: onVenueClicked,
              ID: value[2],
              bid: value[3],
            ));
            searchResults = recentResults;
          }
        }
      });
    }
  }

  void fetchandBuild() async {
    await fetchlist();

    setState(() {
      if (_controller.text.isNotEmpty) {
        search(_controller.text);
      } else {
        // print("Filter cleared");
        topSearchesFunc();
        searchResults = [];
        searcCategoryhResults = [];
        vall = -1;
      }
    });

  }
  Future<void> topSearchesFunc() async {
    List<String> strings = await StringStorage.getStrings();
    setState(() {
      try{
        if(landmarkData.landmarksMap!=null){
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && strings.contains(value.properties?.polyId)) {
              topSearches.add(SearchpageResults(
                name: "${value.name}",
                location:
                "Floor ${value.floor}, ${value
                    .buildingName}, ${value.venueName}",
                onClicked: onVenueClicked,
                ID: value.properties!.polyId!,
                bid: value.buildingID!,
                floor: value.floor!,
                coordX: value.coordinateX!,
                coordY: value.coordinateY!,
                accessible:  value.properties!.wheelChairAccessibility??"", distance: 10000,
                icon: Icon(
                  Icons.access_time,
                  color: Color(0xff000000),
                  size: 25,
                ),
              ));
            }
          });
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && value.element!.subType != "beacon" && !strings.contains(value.properties?.polyId)) {
              if(value.priority!=null && value.priority!>1){
                topSearches.add(SearchpageResults(
                  name: "${value.name}",
                  location:
                  "Floor ${value.floor}, ${value
                      .buildingName}, ${value.venueName}",
                  onClicked: onVenueClicked,
                  ID: value.properties!.polyId!,
                  bid: value.buildingID!,
                  floor: value.floor!,
                  coordX: value.coordinateX!,
                  coordY: value.coordinateY!,
                  accessible:  value.properties!.wheelChairAccessibility??"", distance: 10000,
                  icon: Icon(
                    Icons.star,
                    color: Color(0xff000000),
                    size: 25,
                  ),
                ));
              }
            }
          });
        }

      }catch(e){

      }

    });
  }
  Future<void> fetchlist() async {
    land? singletonData = await SingletonFunctionController.building.landmarkdata;
    if(singletonData != null){
      landmarkData = singletonData;
      await loadLandmarkData();
      return;
    }
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      await landmarkApi().fetchLandmarkData(id: key).then((value) async {
        landmarkData.mergeLandmarks(value.landmarks);
        await loadLandmarkData();
      });
    });
  }

  void initSpeech() async {
    speechEnabled = await speetchText.initialize();
    setState(() {});
  }

  void onSpeechResult(result) {
    setState(() {
      print("Listening from mic");

      setState(() {
        _controller.text = result.recognizedWords;
        search(result.recognizedWords);
        // print(_controller.text);
      });
      wordsSpoken = "${result.recognizedWords}";

      // if (result.recognizedWords == null) {
      //   print("result.recognizedWords");
      //
      //
      //   setState(() {
      //     searchHintString = widget.hintText;
      //   });
      // }
    });
  }
  bool isUpdated=false;
  String getIcon(String option) {
    switch (option.toLowerCase()) {
      case 'washroom':
        return 'assets/washroomIcon.png';
      case 'cafeteria':
        return 'assets/cafeteria.png';
      case 'drinking water':
        return 'assets/waterPoint.png';
      case 'atm':
        return 'assets/atmIcon.png';
      case 'exit':
        return 'assets/entryExit.png';
      case 'lift':
        return 'assets/liftIcon.png';
      case 'reception':
        return 'assets/receptionIcon.png';
      default:
        return ''; // Return a default icon if no match is found
    }
  }

  void startListening() async {
    if (await speetchText.hasPermission == false) {
      HelperClass.showToast("Permission not allowed");
      return;
    }
    setState(() {
      searchHintString = "";
    });
    await speetchText.listen(onResult: onSpeechResult);
    if (speetchText.isNotListening) {
      setState(() {
        searchHintString = widget.hintText;
      });
    }
    HelperClass.showToast("Speak to search");
    await Future.delayed(Duration(seconds: 5));
    micColor = Colors.black;
    setState(() {});
  }
  void checkForReload(){
    if (DashboardListBox.containsKey('coursesss')) {
      classroomcourses = DashboardListBox.get('coursesss');
      print(classroomcourses);
      locations = classroomcourses
          .map((course) => course['locationName'] as String)
          .toSet();
      setState(() {});
    } else {
      getUserDataFromHive();
    }

    if(DashboardListBox.containsKey('_services')){
      _services = DashboardListBox.get('_services');
      print('_loadServicesFromAPI FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_loadServicesFromAPI API CALL');
    }
    if (DashboardListBox.containsKey('_events')) {
      _events = DashboardListBox.get('_events');
      print((_events));
      print('_loadeventsFromAPI FROM DATABASE');
    } else {
      _loadEventsFromAPI();
      print('_loadEventsFromAPI API CALL');
    }
    if(DashboardListBox.containsKey('tenants')){
      tenants = DashboardListBox.get('tenants');
      print('_loadTenant FROM DATABASE');

    }else{
      _loadTenantsFromAPI();
      print('tenants API CALL');
    }

    if (DashboardListBox.containsKey('artworks')) {
      // futureFaculty = DashboardListBox.get('directory');
      artworks = DashboardListBox.get('artworks');
      print('artworks FROM DATABASE');
    } else {
      fetchArtworks();
      print('artworks API CALL');
    }

  }
  Future<void> _loadServicesFromAPI() async {
    accessToken = await UserBox.getAccessToken();
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/secured/techpark/all-services/66d15dff0a6aa59c399401dc"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": accessToken??"",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('data') &&
            responseData['data'] is List) {
          setState(() {
            _services = responseData['data'];
            DashboardListBox.put('_services', responseData['data']);


          });
        } else {
          throw Exception(
              'Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
        ////
        // To be later changed according to distance
        ////
        _services.sort((a, b) => a['endTime'].compareTo(b['endTime']));
      } else if (response.statusCode == 403) {
        String newAccessToken = await RefreshTokenAPI.refresh();
        print('Refresh done');
        return _loadEventsFromAPI();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }
  Future<void> _loadEventsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse(
            "${AppConfig.baseUrl}/secured/techpark/all-workshop/66d15dff0a6aa59c399401dc"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            _events = responseData['data'];
            DashboardListBox.put('_events', responseData['data']);
            print(_events);
          });
        } else {
          throw Exception(
              'Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
      } else if (response.statusCode == 403) {
        String newAccessToken = await RefreshTokenAPI.refresh();
        print('Refresh done');
        accessToken = newAccessToken;
        _loadEventsFromAPI();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }
  Future<List<Map<String, dynamic>>> fetchArtworks() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/secured/techpark/all-artwork/66d15dff0a6aa59c399401dc'),
      headers: {
        'Content-Type': 'application/json',
        "x-access-token": '$accessToken',
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        print("artwork data stored");
        DashboardListBox.put('artworks',jsonResponse['data']);

        return List<Map<String, dynamic>>.from(jsonResponse['data']);
      } else {
        throw Exception('API returned false status');
      }
    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return fetchArtworks();
      // return artworks;
    } else {
      throw Exception('Failed to load artworks');
    }
  }

  Future<void> _loadTenantsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse(
            "${AppConfig.baseUrl}/secured/techpark/all-tenant/66d15dff0a6aa59c399401dc"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            tenants = responseData['data'];
            DashboardListBox.put('tenants', responseData['data']);
            print("tenants");
            print(tenants);
          });
        } else {
          throw Exception(
              'Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
      } else if (response.statusCode == 403) {
        String newAccessToken = await RefreshTokenAPI.refresh();
        print('Refresh done');
        accessToken = newAccessToken;
        _loadTenantsFromAPI();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  Future<void> getUserDataFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    userId = signInBox.get("userId");
    accessToken = signInBox.get("accessToken");
    refreshToken = signInBox.get("refreshToken");

    if (userId != null && accessToken != null && refreshToken != null) {
      // await fetchCourses();
    } else {
      // Handle case where user ID, access token, or refresh token is missing
    }
  }

  void stopListening() async {
    await speetchText.stop();
    micColor = Colors.black;
    setState(() {});
    if (speetchText.isNotListening) {
      setState(() {
        searchHintString = widget.hintText;
      });
    }
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(Duration(milliseconds: 500), () {
      search(_controller.text);
    });
  }


  bool topCategory=false;



  void search(String searchText) {

    setState(() {
      if (searchText.isNotEmpty) {
        print("Searching for: $searchText");
        Map<String, List<String>> relatedTerms = {
          'washroom': ['toilet', 'restroom', 'bathroom', 'lavatory'],
          'cafeteria': ['canteen', 'food court', 'dining hall','food'],
          'drinking water': ['water', 'water cooler','paani','pani'],
          'atm': ['cash ', 'bank ','money'],
          'entry': ['entrance', 'doorway', 'gateway','gate'],
        };

        topCategory = false;
        searchResults.clear();
        int locationCount = 0, courseCount = 0, serviceCount = 0,tenantCount =0 , eventCount =0,artworkCount=0;
        String normalizedSearchText = normalizeText(searchText);
        print("Searching landmarks...");
        if (landmarkData.landmarksMap != null) {
          final fuse = Fuzzy<Landmarks>(
            landmarkData.landmarks!,
            options: FuzzyOptions(
              findAllMatches: true,
              threshold: 0.4,
              tokenize: false,
              keys:[
                WeightedKey(
                  name: 'element.name',
                  getter: (landmark) => normalizeText(landmark.renderDetail?.name??landmark.name ?? landmark.element?.subType ?? landmark.element!.type!),
                  weight: 1.0,
                ),
              ],
            ),
          );
          final result = fuse.search(normalizedSearchText);
          print("result:${result} ${normalizedSearchText}  ${fuse}");
          result.sort((a, b) {
            print("${normalizedSearchText.toLowerCase()} a.item.toLowerCase().split(' ') ${a.item.name!.toLowerCase().split(' ')}");
            final aHasExact = a.item.name!.toLowerCase().split(' ').contains(normalizedSearchText.toLowerCase());
            final bHasExact = b.item.name!.toLowerCase().split(' ').contains(normalizedSearchText.toLowerCase());
            if (aHasExact && !bHasExact) return -1;
            if (!aHasExact && bHasExact) return 1;
            return a.score!.compareTo(b.score!);
          });
          for (var fuseResult in result) {
            if (fuseResult.score < 0.5 && searchResults.length < 10) {
              final Landmarks landmark = fuseResult.item;
              searchResults.add(SearchpageResults(
                name: landmark.renderDetail.name,
                location: landmark.buildingID == buildingAllApi.outdoorID
                    ? "${landmark.venueName}"
                    : "Floor ${landmark.floor}, ${landmark.venueName}",
                onClicked: onVenueClicked,
                ID: landmark.properties!.polyId!,
                bid: landmark.buildingID!,
                floor: landmark.floor!,
                coordX: landmark.coordinateX!,
                coordY: landmark.coordinateY!,
                accessible: landmark.element!.subType == "restRoom" &&
                    landmark.properties!.washroomType == "Handicapped"
                    ? "true"
                    : "false",
                distance: 10000,
              ));

              // Optional: if you want to keep reversing and limiting like before
              List<dynamic> reversed = searchResults.reversed.toList();
              setState(() {
                searchResults = reversed.take(25).toList();
              });
            }
          }

          // print("Searching classroom courses...");
          // print("Total classroom courses: ${classroomcourses.length}");
          // for (var course in classroomcourses) {
          //   if (courseCount < 3 && searchResults.length < 10) {
          //     String courseName = course['title'] ?? '';
          //     String locationName = course['locationName'] ?? '';
          //     if (courseName.toLowerCase().contains(searchText.toLowerCase()) ||
          //         locationName.toLowerCase().contains(searchText.toLowerCase())) {
          //       searchResults.add(ClassroomCourseResult(
          //         courseName: courseName,
          //         locationName: locationName,
          //         onClicked: (name, location) {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => CourseDetailScreen(course: course)),
          //           );
          //         },
          //       ));
          //       courseCount++;
          //     }
          //   } else {
          //     break;
          //   }
          // }

          print("Searching services...");
          print("Total services: ${_services.length}");
          print("Searching tenant...");
          print("Total tenant: ${tenants.length}");
          for (var company in tenants) {
            Map<String, Set<String>> towerFloors = {};

            for (var location in company['locationsShown']) {
              String tower = location['tower'].toString();
              String floor = location['floor'].toString();
              towerFloors.putIfAbsent(tower, () => Set<String>()).add(floor);
            }

            List<String> locationParts = towerFloors.entries.map((entry) {
              String tower = entry.key;
              List<String> floors = entry.value.toList()
                ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
              return floors.length == 1
                  ? "Tower $tower, Floor ${floors.join(', ')}"
                  : "Tower $tower, Floors ${floors.join(', ')}";
            }).toList();

            String locationText;
            bool showInfoIcon = towerFloors.length > 1;
            if (towerFloors.length == 1) {
              locationText = locationParts.join('');
            } else {
              locationText = "Towers - Floors";
            }

          }


          print("Searching events...");
          print("Total events: ${_events.length}");

          print("Searching artworks...");
          print("Total artworks: ${artworks.length}");
          print(artworks);

          if (searchResults.isEmpty) {
            print("No exact matches found, performing similarity search...");

            double similarityThreshold = 0.8;

            print("Searching landmarks with similarity...");
            if (landmarkData.landmarksMap != null) {
              landmarkData.landmarksMap!.forEach((key, value) {
                if (locationCount < 5 && searchResults.length < 10) {
                  if (value.name != null && value.element!.subType != "beacon") {
                    String lowerCaseName = value.name!.toLowerCase();
                    if (StringSimilarity.compareTwoStrings(lowerCaseName, searchText.toLowerCase()) > similarityThreshold) {
                      print("Landmark similar match found: ${value.name}");
                      searchResults.add(SearchpageResults(
                        name: value.renderDetail?.name??value.name ?? value.element?.subType ?? value.element!.type!,
                        location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
                        onClicked: onVenueClicked,
                        ID: value.properties!.polyId!,
                        bid: value.buildingID!,
                        floor: value.floor!,
                        coordX: value.coordinateX!,
                        coordY: value.coordinateY!,
                        accessible: '', distance: 10000,
                      ));
                      locationCount++;
                    }
                  }
                }
              });
            }


            print("Searching services with similarity...");
            print("Total search results after similarity: ${searchResults.length}");
          } else {
            print("Total search results: ${searchResults.length}");
          }

        }
        else {
          print("Search text is empty");
          searchResults = [];
          searcCategoryhResults = [];
        }
      }});
  }


  bool sortAndSeparateByUserLocation(
      int userLat,
      int userLng,
      int userFloor,
      String userBuildingID,
      Landmarks value,
      String searchedtext) {

    bool added = false;

    // Check if the value should be included
    if (value.name!.toLowerCase().contains(searchedtext.toLowerCase()) &&
        value.buildingID == userBuildingID &&
        value.floor == userFloor) {
      print("entered here for: ${value}");

      // Check if already added based on unique ID (polyId)
      final alreadyExists = searchResults.any((result) =>
      result.ID == value.properties!.polyId);

      if (!alreadyExists) {
        searchResults.add(SearchpageResults(
          name: value.name!,
          location: value.buildingID == buildingAllApi.outdoorID
              ? "${value.venueName}"
              : "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
          onClicked: onVenueClicked,
          ID: value.properties!.polyId!,
          bid: value.buildingID!,
          floor: value.floor!,
          coordX: value.doorX ?? value.coordinateX!,
          coordY: value.doorY ?? value.coordinateY!,
          accessible: value.element!.subType == "restRoom" &&
              value.properties!.washroomType == "Handicapped"
              ? "true"
              : "false",
          distance: 10000,
        ));
        added = true;
      }
    }

    // Sort the main list
    searchResults.sort((a, b) {
      double distanceA = tools.calculateDistance([userLat, userLng], [a.coordX!, a.coordY!]);
      double distanceB = tools.calculateDistance([userLat, userLng], [b.coordX!, b.coordY!]);

      a.distance = (distanceA * 0.306).toInt();
      b.distance = (distanceB * 0.306).toInt();

      return distanceA.compareTo(distanceB);
    });

    print("searcresult:${searchResults.length}");

    if (searchResults.length > 2) {
      print("searchResults after in desti: ${searchResults[1].name}  ${searchResults[1].coordX} ${searchResults[1].coordY}");
    }

    return added;
  }

  // void search(String searchText) {
  //   setState(() {
  //     if (searchText.isNotEmpty) {
  //       print("Searching for: $searchText");
  //
  //       Map<String, List<String>> relatedTerms = {
  //         'washroom': ['toilet', 'restroom', 'bathroom', 'lavatory'],
  //         'cafeteria': ['canteen', 'food court', 'dining hall'],
  //         'drinking water': ['water', 'water cooler'],
  //         'atm': ['cash machine', 'bank '],
  //         'entry': ['entrance', 'doorway', 'gateway'],
  //         'lift': ['elevator', 'escalator'],
  //         'reception': ['front desk', 'information desk', 'lobby'],
  //       };
  //
  //       String? matchedCategory;
  //       for (var category in optionList) {
  //         if (searchText.toLowerCase().contains(category) ||
  //             relatedTerms[category]!.any((term) => searchText.toLowerCase().startsWith(term))) {
  //           matchedCategory = category;
  //           break;
  //         }
  //       }
  //
  //       if (matchedCategory != null) {
  //         category = true;
  //         topCategory = false;
  //
  //         vall = optionList.indexOf(matchedCategory);
  //
  //         searcCategoryhResults.clear();
  //         optionListItemBuildingName.clear();
  //
  //         if (landmarkData.landmarksMap != null) {
  //           landmarkData.landmarksMap!.forEach((key, value) {
  //             if (searcCategoryhResults.length < 10) {
  //               if (value.name != null && value.element!.subType != "beacons") {
  //                 final lowerCaseName = value.name!.toLowerCase();
  //                 if (lowerCaseName.contains(matchedCategory!) ||
  //                     relatedTerms[matchedCategory]!.any((term) => lowerCaseName.startsWith(term))) {
  //                   optionListItemBuildingName.add(value.buildingName!);
  //                 }
  //               }
  //             }
  //           });
  //
  //           optionListItemBuildingName.forEach((element) {
  //             searcCategoryhResults.add(SearchpageCategoryResults(
  //               name: matchedCategory!,
  //               buildingName: element,
  //               onClicked: onVenueClicked,
  //             ));
  //           });
  //         }
  //         print("Category search results: ${searcCategoryhResults.length}");
  //       } else {
  //         category = false;
  //         topCategory = false;
  //
  //         vall = -1;
  //         searchResults.clear();
  //
  //         // Search in landmarks
  //         int locationCount = 0, courseCount = 0, serviceCount = 0;
  //
  //         print("Searching landmarks...");
  //         if (landmarkData.landmarksMap != null) {
  //           landmarkData.landmarksMap!.forEach((key, value) {
  //             if (locationCount < 5 && searchResults.length < 10) {
  //               if (value.name != null && value.element!.subType != "beacon") {
  //                 String normalizedSearchText = normalizeText(searchText);
  //                 String normalizedValueName = normalizeText(value.name!);
  //
  //                 if (normalizedValueName.contains(normalizedSearchText)) {
  //                   print("Landmark match found: ${value.name}");
  //                   searchResults.add(SearchpageResults(
  //                     name: "${value.name}",
  //                     location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
  //                     onClicked: onVenueClicked,
  //                     ID: value.properties!.polyId!,
  //                     bid: value.buildingID!,
  //                     floor: value.floor!,
  //                     coordX: value.coordinateX!,
  //                     coordY: value.coordinateY!,
  //                   ));
  //                   locationCount++;
  //                 }
  //               }
  //             }
  //           });
  //         }
  //
  //         print("Searching classroom courses...");
  //         print("Total classroom courses: ${classroomcourses.length}");
  //         for (var course in classroomcourses) {
  //           if (courseCount < 3 && searchResults.length < 10) {
  //             String courseName = course['title'] ?? '';
  //             String locationName = course['locationName'] ?? '';
  //             if (courseName.toLowerCase().contains(searchText.toLowerCase()) ||
  //                 locationName.toLowerCase().contains(searchText.toLowerCase())) {
  //               searchResults.add(ClassroomCourseResult(
  //                 courseName: courseName,
  //                 locationName: locationName,
  //                 onClicked: (name, location) {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => CourseDetailScreen(course: course)),
  //                   );
  //                 },
  //               ));
  //               courseCount++;
  //             }
  //           } else {
  //             break;
  //           }
  //         }
  //
  //         print("Searching services...");
  //         print("Total services: ${_services.length}");
  //         for (var service in _services) {
  //           if (serviceCount < 2 && searchResults.length < 10) {
  //             String serviceName = service['name'] ?? '';
  //             String serviceLocation = service['locationName'] ?? '';
  //             if (serviceName.toLowerCase().contains(searchText.toLowerCase()) ||
  //                 serviceLocation.toLowerCase().contains(searchText.toLowerCase())) {
  //               print("Service match found: $serviceName at $serviceLocation");
  //               searchResults.add(ServiceResult(
  //                 serviceName: serviceName,
  //                 serviceLocation: serviceLocation,
  //                 onClicked: (name, location) {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => ServiceInfo(
  //                         imagePath: '${service['image']}',
  //                         name: '${service['name']}',
  //                         location: '${service['locationName']}',
  //                         accessibility: '${service['accessibility']}',
  //                         locationId: '${service['locationId']}',
  //                         type: '${service['type']}',
  //                         startTime: '${service['startTime']}',
  //                         endTime: '${service['endTime']}',
  //                         contact: '${service['contact']}',
  //                         about: '${service['about']}',
  //                         id: '${service['_id']}',
  //                         distance: '${service['distance'] ?? "50"}',
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ));
  //               serviceCount++;
  //             }
  //           } else {
  //             break;
  //           }
  //         }
  //         print("Total search results: ${searchResults.length}");
  //       }
  //     } else {
  //       print("Search text is empty");
  //       searchResults = [];
  //       searcCategoryhResults = [];
  //     }
  //   });
  // }
  String normalizeText(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }
  void clearAllRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recents');
  }


  void onVenueClicked(String name, String location, String ID, String bid) {
    if(widget.frombottombar){
      PassLocationId(context, ID);
    }else if(!widget.frombottombar) {
      Navigator.pop(context, ID);
    }
  }
  bool isTyping=true;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Search bar
              Semantics(
                header: true,
                child: Container(
                  width: screenWidth - 32,
                  height: 48,
                  margin: EdgeInsets.only(top: 16, left: 16, right: 17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: containerBoxColor,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 6),
                      if(!widget.frombottombar)
                        Container(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Semantics(
                            label: "Back",
                            child: SvgPicture.asset(
                                "assets/DestinationSearchPage_BackIcon.svg"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FocusScope(
                          autofocus: true,
                          child: Focus(
                            child: Semantics(
                              header: true,
                              child: Container(
                                  child: TextField(
                                    autofocus: true,
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText: "${searchHintString}",
                                      border: InputBorder.none, // Remove default border
                                    ),
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff18181b),
                                      height: 25 / 16,
                                    ),
                                    onTap: () {
                                      if (containerBoxColor == Color(0xffA1A1AA)) {
                                        containerBoxColor = Color(0xff24B9B0);
                                      } else {
                                        containerBoxColor = Color(0xffA1A1AA);
                                      }
                                    },
                                    onSubmitted: (value) {

                                      search(value);
                                    },
                                    onChanged: (value) {
                                      search(value);
                                      if(_controller.text.isEmpty){
                                        topSearches.clear();
                                        topSearchesFunc();
                                      }else{
                                        setState(() {
                                          isTyping=false;
                                        });
                                      }
                                      // print("Final Set");
                                      // print(cardSet);
                                    },
                                  )),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 6),
                        width: 40,
                        height: 48,
                        child: Center(
                          child: _controller.text.isNotEmpty
                              ? IconButton(
                              onPressed: (){
                                _controller.text = "";
                                setState((){
                                  vall = -1;
                                  search(_controller.text);
                                  recentResults = [];
                                  searcCategoryhResults = [];

                                  isTyping=true;
                                  topSearches.clear();
                                  topSearchesFunc();
                                });
                              },
                              icon: Semantics(
                                  label: "Close", child: Icon(Icons.close)))
                              : IconButton(
                            onPressed: () {
                              initSpeech();
                              setState(() {
                                speetchText.isListening
                                    ? stopListening()
                                    : startListening();
                              });
                              if (!micselected) {
                                micColor = Color(0xff24B9B0);
                              }

                              setState(() {});
                            },
                            icon: Semantics(
                              label: "Voice Search",
                              child: Icon(
                                Icons.mic,
                                color: micColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Current location (if applicable)
              searchHintString.toLowerCase().contains("source")
                  ? Divider(thickness: 6, color: Color(0xfff2f3f5))
                  : Container(),
              (widget.user!=null)?Visibility(
                visible: isTyping && optionListForUI.isNotEmpty,
                child: Semantics(
                  label: "Facilities Filter",
                  header: true,
                  child: Container(
                    margin: EdgeInsets.only(left: 7, top: 4),
                    width: screenWidth,
                    child: ChipsChoice<int>.single(
                      value: vall,
                      onChanged: (val) async {
                        print("this is working");
                        if (HelperClass.SemanticEnabled) {
                          // speak("${optionListForUI[val]} selected");
                        }
                        // Reset vall to -1 if input text is not empty and a valid option is selected
                        if (_controller.text.isNotEmpty && vall != -1) {
                          setState(() {
                            vall = -1;
                          });
                        }
                        // Set the selected option
                        selectedButton = optionListForUI.toList()[val];
                        setState(() {
                          vall = val;
                        });
                        lastval = val;
                        _controller.text = optionListForUI.toList()[val];
                        search(optionListForUI.toList()[val].toLowerCase());
                        setState(() {
                          isTyping=true;
                        });
                      },
                      choiceItems: optionListForUI.isNotEmpty == true
                          ? C2Choice.listFrom<int, String>(
                        source: optionListForUI.toList(),
                        value: (i, v) => i,
                        label: (i, v) => v,
                      ):[],
                      choiceBuilder: (item, i) {
                        return DestinationPageChipsWidget(
                          svgPath: '',
                          text: optionListForUI.toList()[i],
                          onSelect: item.select!,
                          selected: item.selected,
                          icon: getIcon(optionListForUI.toList()[i].toLowerCase()),
                        );
                      },
                      direction: Axis.horizontal,
                    ),
                  ),
                ),

              ):Container(),
              // Search results
              Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Semantics(
                      header: true,
                      label: 'Related Search',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (topCategory)? topSearches:searchResults.cast<Widget>(),
                      ),
                    ),
                  )),
              if (_controller.text.isNotEmpty && searchResults.isEmpty && ((topCategory ? topSearches : [])).isEmpty)

                Column(
                    children: [
                      SizedBox(height: 16,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/noResults.png'),
                      ),
                      Text(
                        'Sorry, No Results Found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' Try something new  with different keywords',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ]
                )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }
}

class ClassroomCourseResult extends StatelessWidget {
  final String courseName;
  final String locationName;
  final Function(String, String) onClicked;

  ClassroomCourseResult({
    required this.courseName,
    required this.locationName,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(courseName, locationName),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xffEBEBEB),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5), // Specify the background color here
              ),
              child: Icon(

                Icons.school,
                color: Color(0xff000000),
                size: 25,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(courseName, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Click to know more',
                    // HelperClass.truncateString(locationName, 30),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );

  }
}
class ServiceResult extends StatelessWidget {
  final String serviceName;
  final String serviceLocation;
  final Function(String, String) onClicked;

  ServiceResult({
    required this.serviceName,
    required this.serviceLocation,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(serviceName, serviceLocation),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xffEBEBEB),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5),
              ),
              child: Icon(

                Icons.miscellaneous_services,
                color: Color(0xff000000),
                size: 25,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(serviceName, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Click to know more',
                    // HelperClass.truncateString(serviceLocation, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );

  }
}
class TenantResult extends StatelessWidget {
  final String tenantName;
  final Function(String) onClicked;

  TenantResult({
    required this.tenantName,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(tenantName),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xffEBEBEB),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5),
              ),
              child: Icon(

                Icons.business_outlined,
                color: Color(0xff000000),
                size: 25,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(tenantName, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Click to know more',
                    // HelperClass.truncateString(serviceLocation, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );

  }
}
class EventResult extends StatelessWidget {
  final String eventName;
  final Function(String) onClicked;

  EventResult({
    required this.onClicked, required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(eventName),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xffEBEBEB),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5),
              ),
              child: Icon(

                Icons.event,
                color: Color(0xff000000),
                size: 25,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(eventName, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Click to know more',
                    // HelperClass.truncateString(serviceLocation, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );

  }
}
class ArtworkResult extends StatelessWidget {
  final String artworkName;
  final Function(String) onClicked;

  ArtworkResult({
    required this.onClicked, required this.artworkName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(artworkName),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xffEBEBEB),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5),
              ),
              child: Icon(

                Icons.palette,
                color: Color(0xff000000),
                size: 25,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(artworkName, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Click to know more',
                    // HelperClass.truncateString(serviceLocation, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );

  }
}
class DirectoryResult extends StatelessWidget {
  final String DirectoryName;
  final String DirectoryContact;
  final Function(String) onClicked;

  DirectoryResult({
    required this.DirectoryName,
    required this.DirectoryContact,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(DirectoryContact),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xffEBEBEB),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5),
              ),
              child: Icon(

                Icons.contact_phone_outlined,
                color: Color(0xff000000),
                size: 25,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(DirectoryName, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    // 'Click to know more',
                    HelperClass.truncateString(DirectoryContact, 35),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.call_outlined),
            SizedBox(width: 16,),

          ],
        ),
      ),
    );

  }
}
