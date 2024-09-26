
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
// import 'package:iwayplusashoka/ashoka/Screens/CourseDetailScreen.dart';
import '../../API/RefreshTokenAPI.dart';
import '../../APIMODELS/landmark.dart';
import '../../Elements/SearchpageCategoryResult.dart';
import '../../Elements/SearchpageResults.dart';
import '../../config.dart';
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

  GlobalSearchPage(
      {this.hintText = "",
      this.previousFilter = "",
      required this.voiceInputEnabled,
      this.userLocalized = ""});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  land landmarkData = land();
  List<String> landmarkFuzzyNameList = [];
  List<Widget> searchResults = [];
  List<Widget> recentResults = [];
  List<dynamic>_services = [];
  String token = "";
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
  String? userId;
  String? accessToken;
  String? refreshToken;
  // bool isLoading = true;
  Set<String> locations = Set();
  var DashboardListBox = Hive.box('DashboardList');
  List<dynamic> classroomcourses = [];

  FlutterTts flutterTts = FlutterTts();
  bool category = false;
  List<String> optionList = [
    'washroom',
    'cafeteria',
    'drinking water',
    'atm',
    'entry',

  ];
  List<String> optionListForUI = [
    'Washroom',
    'Cafeteria',
    'Drinking water',
    'ATM',
    'Entry',

  ];
  Set<String> optionListItemBuildingName = {};
  List<Widget> searcCategoryhResults = [];
  Color containerBoxColor = Color(0xffA1A1AA);
  Color micColor = Colors.black;
  bool micselected = false;
  int vall = -1;
  int lastval = -1;
  List<Widget> topSearches=[];
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];
  @override
  void initState() {
    super.initState();
    getUserDataFromHive();
    checkForReload();
    fetchandBuild();
    _controller.addListener(_onSearchChanged);

    for (int i = 0; i < optionListForUI.length; i++) {
      if (optionListForUI[i].toLowerCase() ==
          widget.previousFilter.toLowerCase()) {
        vall = i;
      }
    }
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
  Future<void> getUserDataFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get("accessToken");
      refreshToken = signInBox.get("refreshToken");
    });
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
  void topSearchesFunc(){
    setState(() {
      topSearches.add(Container(margin:EdgeInsets.only(left: 26,top: 12,bottom: 12),child: Row(
        children: [
          Icon(Icons.search_sharp),
          SizedBox(width: 26,),
          Text(
            "Top Searches",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff000000),
              height: 24/18,
            ),
            textAlign: TextAlign.left,
          )
        ],
      ),));
      landmarkData.landmarksMap!.forEach((key, value) {
        if (value.name != null && value.element!.subType != "beacon") {
          if(value.priority!=null && value.priority!>1){
            topCategory = true;
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
            ));
          }

        }
      });
    });
  }
  Future<void> fetchlist() async {

      buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
        await landmarkApi().fetchLandmarkData(id: key).then((value) {
          landmarkData.mergeLandmarks(value.landmarks);
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

  void checkForReload() {
    if (DashboardListBox.containsKey('_doctors')) {
      _doctors = DashboardListBox.get('_doctors');
      print(_doctors);
      locations = _doctors
          .map((doctor) => doctor['locationName'] as String)
          .toSet();
      setState(() {});
    } else {
      _loadDoctorsFromAPI();
    }

    if(DashboardListBox.containsKey('_services')){
      _services = DashboardListBox.get('_services');
      print('_loadServicesFromAPI FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_loadServicesFromAPI API CALL');
    }

  }
  Future<void> _loadDoctorsFromAPI() async {
    try {
      final response = await http.get(

        Uri.parse("${AppConfig.baseUrl}/secured/hospital/all-doctors/66210fd6360138500a3f1f62"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": '$accessToken',
        },);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("doctor fetched from api");

        if (responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            _doctors = responseData['data'];
            _filteredDoctors = _doctors;

            DashboardListBox.put('_doctors', responseData['data']);
          });
        } else {
          throw Exception('Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
      }else if (response.statusCode == 403) {
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
  Future<void> _loadServicesFromAPI() async {
    try {

      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/secured/hospital/all-services/66210fd6360138500a3f1f62"),
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
        }else if (response.statusCode == 403) {
          String newAccessToken = await RefreshTokenAPI.refresh();
          accessToken = newAccessToken;
          _loadServicesFromAPI();

        } else {
          throw Exception(
              'Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
        _services.sort((a, b) => a['endTime'].compareTo(b['endTime']));
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
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

        String? matchedCategory;
        for (var category in optionList) {
          if (searchText.toLowerCase().contains(category) ||
              relatedTerms[category]!.any((term) => searchText.toLowerCase().startsWith(term))) {
            matchedCategory = category;
            break;
          }
        }

        if (matchedCategory != null) {
          category = true;
          topCategory = false;

          vall = optionList.indexOf(matchedCategory);

          searcCategoryhResults.clear();
          optionListItemBuildingName.clear();

          if (landmarkData.landmarksMap != null) {
            landmarkData.landmarksMap!.forEach((key, value) {
              if (searcCategoryhResults.length < 10) {
                if (value.name != null && value.element!.subType != "beacons") {
                  final lowerCaseName = value.name!.toLowerCase();
                  if (lowerCaseName.contains(matchedCategory!) ||
                      relatedTerms[matchedCategory]!.any((term) => lowerCaseName.startsWith(term))) {
                    optionListItemBuildingName.add(value.buildingName!);
                  }
                }
              }
            });

            optionListItemBuildingName.forEach((element) {
              searcCategoryhResults.add(SearchpageCategoryResults(
                name: matchedCategory!,
                buildingName: element,
                onClicked: onVenueClicked,
              ));
            });
          }
          print("Category search results: ${searcCategoryhResults.length}");
        } else {
          category = false;
          topCategory = false;

          vall = -1;
          searchResults.clear();

          int locationCount = 0, courseCount = 0, serviceCount = 0;

          print("Searching landmarks...");
          if (landmarkData.landmarksMap != null) {
            landmarkData.landmarksMap!.forEach((key, value) {
              if (locationCount < 5 && searchResults.length < 10) {
                if (value.name != null && value.element!.subType != "beacon") {
                  String normalizedSearchText = normalizeText(searchText);
                  String normalizedValueName = normalizeText(value.name!);

                  if (normalizedValueName.contains(normalizedSearchText)) {
                    print("Landmark match found: ${value.name}");
                    searchResults.add(SearchpageResults(
                      name: "${value.name}",
                      location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
                      onClicked: onVenueClicked,
                      ID: value.properties!.polyId!,
                      bid: value.buildingID!,
                      floor: value.floor!,
                      coordX: value.coordinateX!,
                      coordY: value.coordinateY!,
                    ));
                    locationCount++;
                  }
                }
              }
            });
          }

          print("Searching doctors...");
          for (var doctor in _doctors) {
            if (courseCount < 3 && searchResults.length < 10) {
              String courseName = doctor['name'] ?? '';
              String locationName = doctor['locationName'] ?? '';
              if (courseName.toLowerCase().contains(searchText.toLowerCase()) ||
                  locationName.toLowerCase().contains(searchText.toLowerCase())) {
                searchResults.add(ClassroomCourseResult(
                  courseName: courseName,
                  locationName: locationName,
                  onClicked: (name, location) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DoctorProfile(doctor: doctor,docId: doctor["_id"],)),
                    );
                  },
                ));
                courseCount++;
              }
            } else {
              break;
            }
          }

          print("Searching services...");
          print("Total services: ${_services.length}");
          for (var service in _services) {
            if (serviceCount < 2 && searchResults.length < 10) {
              String serviceName = service['name'] ?? '';
              String serviceLocation = service['locationName'] ?? '';
              if (serviceName.toLowerCase().contains(searchText.toLowerCase()) ||
                  serviceLocation.toLowerCase().contains(searchText.toLowerCase())) {
                print("Service match found: $serviceName at $serviceLocation");
                searchResults.add(ServiceResult(
                  serviceName: serviceName,
                  serviceLocation: serviceLocation,
                  onClicked: (name, location) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceInfo(
                          imagePath: '${service['image']}',
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
                          // distance: '${service['distance'] ?? "50"}',
                          latitude: '${service['latitude']}',
                          longitude: '${service['longitude']}',
                        ),
                      ),
                    );
                  },
                ));
                serviceCount++;
              }
            } else {
              break;
            }
          }

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
                        name: "${value.name}",
                        location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
                        onClicked: onVenueClicked,
                        ID: value.properties!.polyId!,
                        bid: value.buildingID!,
                        floor: value.floor!,
                        coordX: value.coordinateX!,
                        coordY: value.coordinateY!,
                      ));
                      locationCount++;
                    }
                  }
                }
              });
            }

            print("Searching classroom courses with similarity...");
            // for (var course in classroomcourses) {
            //   if (courseCount < 3 && searchResults.length < 10) {
            //     String courseName = course['title'] ?? '';
            //     String locationName = course['locationName'] ?? '';
            //     if (StringSimilarity.compareTwoStrings(courseName.toLowerCase(), searchText.toLowerCase()) > similarityThreshold ||
            //         StringSimilarity.compareTwoStrings(locationName.toLowerCase(), searchText.toLowerCase()) > similarityThreshold) {
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

            print("Searching services with similarity...");
            for (var service in _services) {
              if (serviceCount < 2 && searchResults.length < 10) {
                String serviceName = service['name'] ?? '';
                String serviceLocation = service['locationName'] ?? '';
                if (StringSimilarity.compareTwoStrings(serviceName.toLowerCase(), searchText.toLowerCase()) > similarityThreshold ||
                    StringSimilarity.compareTwoStrings(serviceLocation.toLowerCase(), searchText.toLowerCase()) > similarityThreshold) {
                  print("Service similar match found: $serviceName at $serviceLocation");
                  searchResults.add(ServiceResult(
                    serviceName: serviceName,
                    serviceLocation: serviceLocation,
                    onClicked: (name, location) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceInfo(
                            imagePath: '${service['image']}',
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
                            // distance: '${service['distance'] ?? "50"}',
                            latitude: '${service['latitude']}',
                            longitude: '${service['longitude']}',
                          ),
                        ),
                      );
                    },
                  ));
                  serviceCount++;
                }
              } else {
                break;
              }
            }

            print("Total search results after similarity: ${searchResults.length}");
          } else {
            print("Total search results: ${searchResults.length}");
          }
        }
      } else {
        print("Search text is empty");
        searchResults = [];
        searcCategoryhResults = [];
      }
    });
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
    Navigator.pop(context, ID);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body:Container(
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
                                        category=false;
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

                    Semantics(
                      header: true,
                      label: 'Filters',
                      child: Container(
                        margin: EdgeInsets.only(left: 7, top: 4),
                        width: screenWidth,
                        child: ChipsChoice<int>.single(
                          value: vall,
                          onChanged: (val) {
                            if (HelperClass.SemanticEnabled) {
                              speak("${optionListForUI[val]} selected");
                            }
                            selectedButton = optionListForUI[val];
                            setState(() => vall = val);
                            lastval = val;
                            _controller.text = optionListForUI[val];
                            search(optionListForUI[val]);
                          },
                          choiceItems: C2Choice.listFrom<int, String>(
                            source: optionListForUI,
                            value: (i, v) => i,
                            label: (i, v) => v,
                          ),
                          choiceBuilder: (item, i) {
                            if (!item.selected) {
                              vall = -1;
                            }
                            return DestinationPageChipsWidget(
                              svgPath: '',
                              text: optionListForUI[i],
                              onSelect: item.select!,
                              selected: item.selected,
                              onTap: (String text) {
                                if (text.isNotEmpty) {
                                  search(text);
                                } else {

                                  setState(() {
                                    search(text);
                                    _controller.text="";
                                    searchResults = [];
                                    searcCategoryhResults = [];
                                    vall = -1;
                                  });
                                }
                              },
                            );
                          },
                          direction: Axis.horizontal,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Divider(thickness: 6, color: Color(0xfff2f3f5)),
                    // Search results
                    Flexible(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Semantics(
                            header: true,
                            label: 'Related Search',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (!category && topCategory)? topSearches:(category)?searcCategoryhResults:searchResults,

                            ),
                          ),
                        )),
                    if (_controller.text.isNotEmpty && searchResults.isEmpty && (category ? searcCategoryhResults : (!category && topCategory ? topSearches : [])).isEmpty)

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
              height: 40,
              width: 40,
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5), // Specify the background color here
              ),
              child: SvgPicture.asset('assets/images/Doctor.svg')
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
              height: 40,
              width: 40,
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5),
              ),
              child: SvgPicture.asset('assets/images/counter.svg')
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