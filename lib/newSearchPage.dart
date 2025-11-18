import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/singletonClass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'API/RefreshTokenAPI.dart';
import 'API/buildingAllApi.dart';
import 'API/ladmarkApi.dart';
import 'APIMODELS/landmark.dart';
import 'ELEMENTS/HelperClass.dart';
import 'Elements/DestinationPageChipsWidget.dart';
import 'NAVIGATIONTools.dart';
import 'Repository/RepositoryManager.dart';
import 'StringStorage.dart';
import 'UserState.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class NewSearchPage extends StatefulWidget {
  String hintText;
  String previousFilter;
  bool voiceInputEnabled;
  UserState user;
  NewSearchPage({this.hintText = "",
    this.previousFilter = "",
    required this.voiceInputEnabled,required this.user});

  @override
  State<NewSearchPage> createState() => _NewsearchpageState();
}

class _NewsearchpageState extends State<NewSearchPage> {
  land landmarkData = land();
  Color containerBoxColor = Color(0xffA1A1AA);
  TextEditingController _controller = TextEditingController();
  Color micColor = Colors.black;
  String searchHintString = "";
  List<dynamic> searchResults = [];
  List<dynamic> topSearches=[];
  List<dynamic>_services = [];
  int vall = -1;
  Set<String> optionListItemBuildingName = {};
  List<Widget> searcCategoryhResults = [];
  int lastIndex = -1;
  String selectedButton = "";
  bool isTyping=true;
  int lastval =-1;
  bool category = false;
  final SpeechToText speetchText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = "";
  bool micselected = false;
  bool promptLoader = false;
  bool isUpdated=false;

  var DashboardListBox = Hive.box('DashboardList');
  List<dynamic> classroomcourses = [];
  List<dynamic> tenants=[];
  List<dynamic> _events=[];
  List<dynamic> artworks=[];
  Set<String> optionListForUI ={};
  Set<String> locations = Set();
  String? userId;
  String? accessToken;
  String? refreshToken;
  static String apiUrl = '${AppConfig.baseUrl}/secured/techpark/all-directory/66d15dff0a6aa59c399401dc';

  // Add this variable to store the current search keyword
  String currentSearchKeyword = "";

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
          print("available subtypes:${subType} ${optionListForUI} ${widget.user.bid}");
          if (widget.user.bid == buildingAllApi.outdoorID) return;
          // Conditional based on selected building ID
          if (buildingID == widget.user.bid) {
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

  final Map<String, String> SubTypeToActualMap = {
    "washroom": "restRoom",
    "atm": "ATM",
    "drinking water": "Drinking Water",
    "cafeteria": "Cafeteria",
    "exit": "main entry",
    "entry": "main entry",
    "lift": "lift",
    "reception": "Help Desk | Reception",
  };


  @override
  void initState() {
    // TODO: implement initState
    fetchandBuild();
    if(widget.hintText!=""){
      searchHintString=widget.hintText;
    }
    if(widget.voiceInputEnabled){
      initSpeech();
      if(speetchText.isListening){
        stopListening().then((_){
          startListening();
        });
      }else{
        startListening();
      }
      // setState(() {
      //   speetchText.isListening
      //       ? stopListening()
      //       : startListening();
      // });
    }
    //pushToFloorSelection();
    requestMicPermission();

    super.initState();
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
  Future<void> _loadServicesFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/secured/techpark/all-services/66d15dff0a6aa59c399401dc"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
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
          setState((){
            tenants = responseData['data'];
            DashboardListBox.put('tenants', responseData['data']);
            print("tenants");
            print(tenants);
          });
        }else{
          throw Exception('Response data does not contain the expected list of doctors under the "DoctorData" key');
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
  void fetchandBuild()async{
    await fetchlist();

    await loadLandmarkData();
    if (widget.previousFilter != "") {
      setState((){
        _controller.text = widget.previousFilter;
        currentSearchKeyword = widget.previousFilter; // Set the search keyword
        isTyping=false;
        if(_controller.text.toLowerCase()=='exit'){
          print("got inside this");
          search('Entry');
        }else{
          search(_controller.text.toLowerCase());
        }
      });
    }
    setState(() {
      if (_controller.text.isNotEmpty) {
        search(_controller.text);
      } else {
        // print("Filter cleared");
        topSearchesFunc();
        searchResults = [];
      }
    });
  }

  Set<String> floors = {};
  Future<void> fetchFloors(String building,String name)async{
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      await RepositoryManager().getLandmarkDataNew(key).then((value){
        value.landmarksMap?.forEach((key, landmark){
          if (landmark.floor != null &&
              landmark.buildingName == building &&
              landmark.name != null &&
              landmark.name!.toUpperCase().contains(name.toUpperCase())) {
            print("Matched floor: ${landmark.name} ${landmark.floor}");
            floors.add(landmark.floor!.toString());
          }
        });
        landmarkData.mergeLandmarks(value.landmarks);
      });
    });
  }
  Future<void> topSearchesFunc() async {
    List<String> strings = await StringStorage.getStrings();
    setState(() {
      try{
        if(landmarkData.landmarksMap!=null){
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && strings.contains(value.properties?.polyId)) {
              topSearches.add(HighlightedSearchResult(
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
                accessible:  value.properties!.wheelChairAccessibility??"",
                distance: 10000,
                icon: Icon(
                  Icons.access_time,
                  color: Color(0xff000000),
                  size: 25,
                ),
                searchKeyword: currentSearchKeyword,
              ));
            }
          });
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && value.element!.subType != "beacon" && !strings.contains(value.properties?.polyId)) {
              if(value.priority!=null && value.priority! > 1){
                topSearches.add(HighlightedSearchResult(
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
                  accessible:  value.properties!.wheelChairAccessibility??"",
                  distance: 10000,
                  icon: Icon(
                    Icons.star,
                    color: Color(0xff000000),
                    size: 25,
                  ),
                  searchKeyword: currentSearchKeyword,
                ));
              }
            }
          });
          List<HighlightedSearchResult> uniqueResults = topSearches.fold<List<HighlightedSearchResult>>([], (list, element) {
            if (!list.any((e) => e.ID == element.ID && e.bid == element.bid)) {
              list.add(element);
            }
            return list;
          });
          topSearches = uniqueResults;
        }

      }catch(e){

      }

    });
  }

  Future<void> fetchlist() async {
    land? singletonData = await SingletonFunctionController.building.landmarkdata;
    if(singletonData != null){
      landmarkData = singletonData;
      print("landmarkData length ${landmarkData.landmarks?.length}");
      landmarkData.landmarksMap?.removeWhere(
            (key, landmark) => buildingAllApi.onlyRenderBuildingID.keys.contains(landmark.buildingID),
      );
      landmarkData.landmarks?.removeWhere(
            (landmark) => buildingAllApi.onlyRenderBuildingID.keys.contains(landmark.buildingID),
      );

      print("landmarkData length after removing ${landmarkData.landmarks?.length}");
      List<String?> buildingIDs = landmarkData.landmarksMap?.values
          .map((landmark) => landmark.buildingID)
          .toList()
          ?? [];

      print("buildingIDs printing $buildingIDs");

      await loadLandmarkData();
      return;
    }
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      if(!buildingAllApi.onlyRenderBuildingID.keys.contains(key)){
        await RepositoryManager().getLandmarkDataNew(key).then((value) async {
          landmarkData.mergeLandmarks(value.landmarks);
          await loadLandmarkData();
        });
      }
    });
  }
  List<String> fetchCategories(land value){
    List<String> list = [];
    for (var landmark in value.landmarks!) {
      if(landmark.element!.subType != "room door"){
        list.add(landmark.element!.subType!);
      }
    }
    return list;
  }

  bool containsSearchText(List<String> optionListForUI, String searchText) {
    return optionListForUI
        .map((option) => option.toLowerCase()) // Convert each list item to lowercase
        .contains(searchText.toLowerCase());  // Convert search text to lowercase
  }

  int indexOfCaseInsensitive(List<String> optionListForUI, String searchText) {
    return optionListForUI.indexWhere(
            (option) => option.toLowerCase() == searchText.toLowerCase());
  }


  String normalizeText(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }
  Future<void> onVenueClicked(String name, String location, String ID, String bid) async {
    print("IDDDDD $ID");
    await StringStorage.addString(ID);
    Navigator.pop(context, ID);
  }

  void initSpeech() async {
    speechEnabled = await speetchText.initialize();
    setState(() {});
  }
  Future<bool> requestMicPermission() async {
    var status = await Permission.microphone.status;

    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }

  void startListening() async {
    if (await speetchText.hasPermission == false) {
      await requestMicPermission();
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

  void onSpeechResult(result) {
    setState(() {
      print("Listening from mic");

      setState(() {
        _controller.text = result.recognizedWords;
        currentSearchKeyword = result.recognizedWords; // Update search keyword
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

  Future<void> stopListening() async {
    await speetchText.stop();
    micColor = Colors.black;
    setState(() {});
    if (speetchText.isNotListening) {
      setState(() {
        searchHintString = widget.hintText;
      });
    }
  }




  void search(String searchText, {String wantToFilter = ''}) {
    setState((){
      // Update the current search keyword
      currentSearchKeyword = searchText;

      if (searchText.isEmpty){
        searchResults = [];
        searcCategoryhResults = [];
        currentSearchKeyword = ""; // Clear keyword when search is empty
        return;
      }
      searchText = searchText.toLowerCase();
      String normalizedSearchText = normalizeText(searchText);
      searchResults.clear();
      searcCategoryhResults.clear();
      optionListItemBuildingName.clear();
      final isCategorySearch = optionListForUI.map((e) => e.toLowerCase()).contains(searchText.toLowerCase());
      if(isCategorySearch && widget.user.bid.isNotEmpty){
        var  result = landmarkData.landmarks!.where((landmark) => (landmark.element?.subType != null && landmark.element?.subType!.toLowerCase() == SubTypeToActualMap[searchText]?.toLowerCase() &&
            widget.user.bid == landmark.buildingID)).toList();
        print('iscatergorysearch:${searchText} ${SubTypeToActualMap[searchText]?.toLowerCase()}');
        if(searchText=='washroom'){
          result = landmarkData.landmarks!
              .where((landmark) {
            final subType = landmark.element?.subType;
            final mappedValue = SubTypeToActualMap[searchText];
            print("SubTypeToActualMap[searchText]?.toLowerCase() ${widget.user.bid} == ${landmark.buildingID} ${subType?.toLowerCase().contains(mappedValue.toString().toLowerCase())} $subType ${SubTypeToActualMap[searchText]} $result");
            return subType != null && mappedValue != null && subType.toLowerCase().contains(mappedValue.toLowerCase()) && widget.user.bid == landmark.buildingID;}).toList();
        }
        if(widget.user.bid==buildingAllApi.outdoorID){
          result = landmarkData.landmarks!.where((landmark) => (landmark.element?.subType != null && landmark.element?.subType!.toLowerCase() == SubTypeToActualMap[searchText]?.toLowerCase())).toList();
        }
        if(result.isEmpty){
          result = landmarkData.landmarks!.where((landmark) => (landmark.element?.subType != null && landmark.element?.subType!.toLowerCase() == SubTypeToActualMap[searchText]?.toLowerCase())).toList();
        }
        searchResults = sortAndSeparateByUserLocation(
          widget.user.coordX,
          widget.user.coordY,
          widget.user.lat,
          widget.user.lng,
          widget.user.floor,
          widget.user.bid,
          result,
        );
        searchResults = searchResults.take(25).toList();
      }else{
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
        result.sort((a, b) {
          var aName = a.item.renderDetail?.name??a.item.name ?? a.item.element?.subType ?? a.item.element!.type!;
          var bName =  b.item.renderDetail?.name?? b.item.name ??  b.item.element?.subType ??  b.item.element!.type!;
          if(aName == bName){
            if(a.item.floor!.toInt() < b.item.floor!.toInt()){
              return -1;
            }else{
              return 1;
            }
          }
          final aHasExact = aName.toLowerCase().split(' ').contains(searchText);
          final bHasExact = bName.toLowerCase().split(' ').contains(searchText);
          if (aHasExact && !bHasExact) return -1;
          if (!aHasExact && bHasExact) return 1;
          return a.score!.compareTo(b.score!);
        });
        print("landmark in search ${result}");
        for (var fuseResult in result) {
          final landmark = fuseResult.item;
          if (fuseResult.score < 0.5 && searchResults.length < 10) {
            searchResults.add(createHighlightedSearchResult(landmark));
          }
        }
      }
    });
    List<HighlightedSearchResult> uniqueResults = searchResults.fold<List<HighlightedSearchResult>>([], (list, element) {
      if (!list.any((e) => e.ID == element.ID && e.bid == element.bid)) {
        list.add(element);
      }
      return list;
    });
    searchResults = uniqueResults;
  }

  // Updated method to create highlighted search results
  HighlightedSearchResult createHighlightedSearchResult(Landmarks landmark) {
    return HighlightedSearchResult(
      name: landmark.renderDetail?.name??landmark.name ?? landmark.element?.subType ?? landmark.element!.type!,
      location: landmark.buildingID == buildingAllApi.outdoorID
          ? "${landmark.venueName}"
          : "Floor ${landmark.floor}, ${landmark.buildingName}, ${landmark.venueName}",
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
      searchKeyword: currentSearchKeyword,
    );
  }

  // void searchGeneral(String searchText) {
  //   int maxResults = 10;
  //
  //   // SERVICES
  //   int serviceCount = 0;
  //   for (var service in _services) {
  //     if (serviceCount >= 2 || searchResults.length >= maxResults) break;
  //     String name = service['name']?.toLowerCase() ?? '';
  //     String loc = service['locationName']?.toLowerCase() ?? '';
  //     if (name.contains(searchText) || loc.contains(searchText)) {
  //       searchResults.add(ServiceResult(
  //         serviceName: service['name'],
  //         serviceLocation: service['locationName'],
  //         serviceLocationId: service['locationId'],
  //         onClicked: onVenueClicked,
  //       ));
  //       serviceCount++;
  //     }
  //   }
  //
  //   // TENANTS
  //   int tenantCount = 0;
  //   for (var tenant in tenants) {
  //     if (tenantCount >= 2 || searchResults.length >= maxResults) break;
  //     String name = tenant['name']?.toLowerCase() ?? '';
  //     if (name.contains(searchText)) {
  //       // Use your existing tenant parsing logic here
  //       searchResults.add(...); // build TenantResult
  //       tenantCount++;
  //     }
  //   }
  //
  //   // EVENTS
  //   int eventCount = 0;
  //   for (var event in _events) {
  //     if (eventCount >= 2 || searchResults.length >= maxResults) break;
  //     String title = event['title']?.toLowerCase() ?? '';
  //     String loc = event['location']?.toLowerCase() ?? '';
  //     if (title.contains(searchText) || loc.contains(searchText)) {
  //       // build and add EventResult
  //       eventCount++;
  //     }
  //   }
  //
  //   // ARTWORKS
  //   int artworkCount = 0;
  //   for (var art in artworks) {
  //     if (artworkCount >= 2 || searchResults.length >= maxResults) break;
  //     String name = art['name']?.toLowerCase() ?? '';
  //     String artist = art['artist']?.toLowerCase() ?? '';
  //     if (name.contains(searchText) || artist.contains(searchText)) {
  //       // build and add ArtworkResult
  //       artworkCount++;
  //     }
  //   }
  //
  //   // FACULTY DIRECTORY
  //   futureFaculty.then((facultyList) {
  //     int dirCount = 0;
  //     for (var f in facultyList) {
  //       if (dirCount >= 2 || searchResults.length >= maxResults) break;
  //       String name = f.name?.toLowerCase() ?? '';
  //       String phone = f.contactNo?.toLowerCase() ?? '';
  //       if (name.contains(searchText) || phone.contains(searchText)) {
  //         // build and add DirectoryResult
  //         dirCount++;
  //       }
  //     }
  //   });
  // }


  List<HighlightedSearchResult> sortAndSeparateByUserLocation(
      int userX,
      int userY,
      double lat,
      double lng,
      int userFloor,
      String bid,
      List<Landmarks> value) {
    List<HighlightedSearchResult> searchList = [];
    // Check if already added based on unique ID (polyId)
    for (var landmark in value) {
      print("landmark ${landmark.name}  ${landmark.buildingID == bid} ${[userX, userY]} ${[
        double.tryParse(landmark.properties?.latitude ?? '0')?.toInt() ?? 0,
        double.tryParse(landmark.properties?.longitude ?? '0')?.toInt() ?? 0
      ]}");
      searchList.add(HighlightedSearchResult(
        name: landmark.name!,
        location: landmark.buildingID == buildingAllApi.outdoorID
            ? "${landmark.venueName}"
            : "Floor ${landmark.floor}, ${landmark.buildingName}, ${landmark.venueName}",
        onClicked: onVenueClicked,
        ID: landmark.properties!.polyId!,
        bid: landmark.buildingID!,
        floor: landmark.floor!,
        coordX:  landmark.doorX ?? landmark.coordinateX!,
        coordY: landmark.doorY ?? landmark.coordinateY!,
        accessible: landmark.element!.subType == "restRoom" &&
            landmark.properties!.washroomType == "Handicapped"
            ? "true"
            : "false",
        distance: (bid == buildingAllApi.outdoorID && landmark.floor == userFloor)
            ? (tools.calculateAerialDist(
          lat, lng,
          double.parse(landmark.properties!.latitude! ) ?? 0,
          double.parse(landmark.properties!.longitude! ) ?? 0
          ,
        ) * 0.3048).toInt()
            : (landmark.buildingID == bid && landmark.floor == userFloor)
            ? (tools.calculateDistance(
          [userX, userY],
          [
            landmark.doorX ?? landmark.coordinateX!,
            landmark.doorY ?? landmark.coordinateY!
          ],
        ) * 0.3048).toInt()
            : 10000,
        searchKeyword: currentSearchKeyword,

      ));
    }
    searchList.sort((a, b) {
      return a.distance.compareTo(b.distance);
    });

    print("searchList $searchList");

    return searchList;
  }

  bool sortAndSeparateByUserLocationGPS(
      double userLat,
      double userLng,
      int userFloor,
      String userBuildingID,
      Landmarks value,
      String searchedtext) {

    bool added = false;

    // Check if the value should be included

    if (value.name!.toLowerCase().contains(searchedtext.toLowerCase()) &&
        value.floor == userFloor) {
      // Check if already added based on unique ID (polyId)
      final alreadyExists = searchResults.any((result) =>
      result.ID == value.properties!.polyId);

      if (!alreadyExists) {
        searchResults.add(HighlightedSearchResult(
          name: value.name!,
          location: value.buildingID == buildingAllApi.outdoorID
              ? "${value.venueName}"
              : "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
          onClicked: onVenueClicked,
          ID: value.properties!.polyId!,
          bid: value.buildingID!,
          floor: value.floor!,
          coordX:  value.doorX ?? value.coordinateX!,
          coordY: value.doorY ?? value.coordinateY!,
          accessible: value.element!.subType == "restRoom" &&
              value.properties!.washroomType == "Handicapped"
              ? "true"
              : "false",
          distance: 0,
          searchKeyword: currentSearchKeyword,
        ));
        added = true;

      }
    }

    searchResults.sort((a, b) {
      double distanceA=0.0;
      double distanceB=0.0;
      print("entered here for: ${a.coordGlobalX!}");
      if(a.coordGlobalX!=null  && a.coordGlobalY!=null){
        distanceA = tools.calculateAerialDist(userLat, userLng,a.coordGlobalX, a.coordGlobalY);
        distanceB = tools.calculateAerialDist(userLat, userLng, b.coordGlobalX, b.coordGlobalY);

        a.distance = (distanceA).toInt();
        b.distance = (distanceB).toInt();
      }
      return distanceB.compareTo(distanceA);
    });

    if (searchResults.length > 2) {
      print("searchResults after in desti: ${searchResults[1].name}  ${searchResults[1].coordX} ${searchResults[1].coordY}");
    }


    print("searcresult: ${added}");
    return added;
  }


  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());

  }
  // void sortAndSeparateByUserLocation(
  //     int userLat,
  //     int userLng,
  //     int userFloor,
  //     String userBuildingID,
  //     Landmarks value,
  //     String searchedtext) {
  //
  //   // Check if the value should be included
  //   if (value.name!.toLowerCase().contains(searchedtext.toLowerCase()) &&
  //       value.buildingID == userBuildingID &&
  //       value.floor == userFloor) {
  //
  //     // Check if already added based on unique ID (polyId)
  //     final alreadyExists = searchResults.any((result) =>
  //     result.ID == value.properties!.polyId);
  //
  //     if (!alreadyExists) {
  //       searchResults.add(SearchpageResults(
  //         name: value.name!,
  //         location: value.buildingID == buildingAllApi.outdoorID
  //             ? "${value.venueName}"
  //             : "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
  //         onClicked: onVenueClicked,
  //         ID: value.properties!.polyId!,
  //         bid: value.buildingID!,
  //         floor: value.floor!,
  //         coordX: value.doorX ?? value.coordinateX!,
  //         coordY: value.doorY ?? value.coordinateY!,
  //         accessible: value.element!.subType == "restRoom" &&
  //             value.properties!.washroomType == "Handicapped"
  //             ? "true"
  //             : "false",
  //         distance: 0,
  //       ));
  //     }
  //   }
  //
  //   // Step 1: Sort the main list as per previous logic
  //   searchResults.sort((a, b) {
  //     double distanceA = tools.calculateDistance([userLat, userLng], [a.coordX!, a.coordY!]);
  //     double distanceB = tools.calculateDistance([userLat, userLng], [b.coordX!, b.coordY!]);
  //
  //     a.distance = (distanceA * 0.306).toInt();
  //     b.distance = (distanceB * 0.306).toInt();
  //
  //     return distanceA.compareTo(distanceB);
  //   });
  //
  //   if (searchResults.length > 2) {
  //     print("searchResults after in desti: ${searchResults[1].name}  ${searchResults[1].coordX} ${searchResults[1].coordY}");
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: statusBarHeight),
        color: Colors.white,
        child: !promptLoader?
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                width: screenWidth - 32,
                height: 48,
                margin: EdgeInsets.only(top: 16, left: 16, right: 17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                    containerBoxColor, // You can customize the border color
                    width: 1.0, // You can customize the border width
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 6,),
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
                        autofocus: widget.previousFilter.isEmpty?true:false,
                        child: Focus(
                          child: Semantics(
                            textField: true,
                            child: Container(
                                child: TextField(
                                  autofocus: widget.previousFilter.isEmpty?true:false,
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
                                      isTyping=true;
                                      topSearches.clear();
                                      topSearchesFunc();
                                      searchResults=[];
                                      searcCategoryhResults=[];
                                      vall=-1;
                                    }else{
                                      setState(() {
                                        category=false;
                                        isTyping=false;
                                      });
                                    }


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
                              setState(() {
                                vall = -1;
                                topSearches.clear();
                                topSearchesFunc();
                                searchResults=[];
                                searcCategoryhResults=[];
                                isTyping=true;
                                category=false;
                              });
                            },
                            icon: Semantics(
                                container: true,
                                label: "Clear",hint: "button. Double tap to activate",
                                child: Icon(Icons.close)))
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
                )),
            searchHintString.toLowerCase().contains("source")?const Divider(thickness: 6,color: Color(0xfff2f3f5),):Container(),
            Visibility(
              visible: _controller.text.isEmpty && optionListForUI.isNotEmpty,
              child: Container(
                  margin: EdgeInsets.only(left: 7, top: 10),
                  width: screenWidth,
                  height: 56,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: optionListForUI.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Semantics(
                          excludeSemantics: true,
                          label: 'Search for ${optionListForUI.toList()[index]}, button ${index + 1} of ${optionListForUI.length}',
                          hint: 'Double tap to activate',// Accessibility text
                          child: InkWell(
                              onTap: () {
                                // Handle button press
                                _controller.text = optionListForUI.toList()[index];
                                search(optionListForUI.toList()[index].toLowerCase());
                                print('Pressed: ${optionListForUI.toList()[index]}');
                              },
                              child: button(
                                svgPath: '',
                                text: optionListForUI.toList()[index],
                                icon: getIcon(optionListForUI.toList()[index].toLowerCase()),
                              )
                          ),
                        ),
                      );
                    },
                  )
              ),

            ),
            Flexible(
                flex: 1,
                child: SingleChildScrollView(
                  child: Focus(
                    autofocus: true,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:(searcCategoryhResults.isNotEmpty)?searcCategoryhResults:(searchResults.isNotEmpty)?searchResults.cast<Widget>():(topSearches.isNotEmpty)?topSearches.cast<Widget>():[]
                    ),
                  ),
                )),

            // if((searchResults.isEmpty && _controller.text.isNotEmpty) || searcCategoryhResults.isEmpty)
            //   Column(
            //       children: [
            //         SizedBox(height: 16,),
            //         Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: Image.asset('assets/noResults.png'),
            //         ),
            //         Text(
            //           'Sorry, No Results Found',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 16,
            //             fontFamily: 'Roboto',
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //         Text(
            //           ' Try something new  with different keywords',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //             color: Color(0xFFA1A1AA),
            //             fontSize: 14,
            //             fontFamily: 'Roboto',
            //             fontWeight: FontWeight.w400,
            //           ),
            //         )
            //       ]
            //   )
          ],
        ):Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      ),
    );

  }
}

// New highlighted search result widget
class HighlightedSearchResult extends StatelessWidget {
  final String name;
  final String location;
  final Function(String name, String location, String ID, String bid) onClicked;
  final String ID;
  final String bid;
  final int floor;
  final int coordX;
  final int coordY;
  final String accessible;
  final int distance;
  final String searchKeyword;
  final Icon? icon;
  final double? coordGlobalX;
  final double? coordGlobalY;

  HighlightedSearchResult({
    required this.name,
    required this.location,
    required this.onClicked,
    required this.ID,
    required this.bid,
    required this.floor,
    required this.coordX,
    required this.coordY,
    required this.accessible,
    required this.distance,
    required this.searchKeyword,
    this.icon,
    this.coordGlobalX,
    this.coordGlobalY,
  });

  // Function to create highlighted text widget
  Widget _buildHighlightedText(String text, String keyword, TextStyle baseStyle) {
    if (keyword.isEmpty) {
      return Text(text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerKeyword = keyword.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerKeyword);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: baseStyle.copyWith(
          backgroundColor: Colors.yellow,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClicked(name, location, ID, bid);
      },
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: icon ?? Icon(
                    Icons.place,
                    color: Color(0xff000000),
                    size: 25,
                  ),
                ),
                if (distance < 10000)
                  Container(
                    margin: EdgeInsets.only(top: 4, left: 11),
                    child: Text(
                      "${distance}m",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8d8c8c),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(name, 36),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(location, 36),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8d8c8c),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (accessible == "true")
              Container(
                margin: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.accessible,
                  color: Colors.blue,
                  size: 20,
                ),
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
  final String serviceLocationId;
  final Function(String name, String location, String ID, String bid) onClicked;
  final String searchKeyword;

  ServiceResult({
    required this.serviceName,
    required this.serviceLocation,
    required this.onClicked,
    required this.serviceLocationId,
    this.searchKeyword = "",
  });

  // Function to create highlighted text widget
  Widget _buildHighlightedText(String text, String keyword, TextStyle baseStyle) {
    if (keyword.isEmpty) {
      return Text(text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerKeyword = keyword.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerKeyword);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: baseStyle.copyWith(
          backgroundColor: Colors.orange,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onClicked("", "",serviceLocationId, "");
      },
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(serviceName, 35),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Click to know more',
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
            ),

          ],
        ),
      ),
    );

  }
}

class TenantResult extends StatelessWidget {
  final String tenantName;
  final Function() onClicked;
  final String searchKeyword;

  TenantResult({
    required this.tenantName,
    required this.onClicked,
    this.searchKeyword = "",
  });

  // Function to create highlighted text widget
  Widget _buildHighlightedText(String text, String keyword, TextStyle baseStyle) {
    if (keyword.isEmpty) {
      return Text(text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerKeyword = keyword.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerKeyword);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: baseStyle.copyWith(
          backgroundColor: Colors.green,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(tenantName, 35),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Click to know more',
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
  final String searchKeyword;

  EventResult({
    required this.onClicked,
    required this.eventName,
    this.searchKeyword = "",
  });

  // Function to create highlighted text widget
  Widget _buildHighlightedText(String text, String keyword, TextStyle baseStyle) {
    if (keyword.isEmpty) {
      return Text(text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerKeyword = keyword.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerKeyword);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: baseStyle.copyWith(
          backgroundColor: Colors.purple,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(eventName, 35),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Click to know more',
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
            ),

          ],
        ),
      ),
    );

  }
}

class ArtworkResult extends StatelessWidget {
  final String artworkName;
  final Function() onClicked;
  final String searchKeyword;

  ArtworkResult({
    required this.onClicked,
    required this.artworkName,
    this.searchKeyword = "",
  });

  // Function to create highlighted text widget
  Widget _buildHighlightedText(String text, String keyword, TextStyle baseStyle) {
    if (keyword.isEmpty) {
      return Text(text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerKeyword = keyword.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerKeyword);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: baseStyle.copyWith(
          backgroundColor: Colors.pink,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(artworkName, 35),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Click to know more',
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
  final String searchKeyword;

  DirectoryResult({
    required this.DirectoryName,
    required this.DirectoryContact,
    required this.onClicked,
    this.searchKeyword = "",
  });

  // Function to create highlighted text widget
  Widget _buildHighlightedText(String text, String keyword, TextStyle baseStyle) {
    if (keyword.isEmpty) {
      return Text(text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerKeyword = keyword.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerKeyword);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: baseStyle.copyWith(
          backgroundColor: Colors.teal,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(DirectoryName, 35),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                    alignment: Alignment.topLeft,
                    child: _buildHighlightedText(
                      HelperClass.truncateString(DirectoryContact, 35),
                      searchKeyword,
                      const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8d8c8c),
                      ),
                    ),
                  ),
                ],
              ),
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