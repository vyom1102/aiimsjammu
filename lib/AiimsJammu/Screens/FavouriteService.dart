
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/LocationIdFunction.dart';
import '../Widgets/Translator.dart';

class FavouriteService extends StatefulWidget {
  const FavouriteService({Key? key}) : super(key: key);

  @override
  State<FavouriteService> createState() => _FavouriteServiceState();
}

class _FavouriteServiceState extends State<FavouriteService> {
  String? userId;
  String? accessToken;
  String? refreshToken;
  List<String>? favoriteServiceIds;
  List<String> ServiceNames = [];
  List<String> ServiceContact = [];
  List<String> doctorLocations = [];
  List<String> doctorSpeciality = [];
  List<String> FserviceId = [];

  List<String> doctorLocationId = [];
  List<bool> favoriteStates = [];

  final String shareText = 'https://play.google.com/store/apps/details?id=com.iwayplus.rgcinavigation';


  Future<void> updateUserFavorites(String id) async {
    String baseUrl = "https://dev.iwayplus.in/secured/user/toggle-favourites";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-access-token': '$accessToken',
    };
    Map<String, dynamic> body = {
      'userId': userId,
      'favouriteType': 'services',
      'favouriteId': id,
    };

    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Removed from favorites!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      print('Service added to favorites!');
    } else if (response.statusCode == 403) {
      await refreshTokenAndRetryForGetUserDetails(baseUrl);
    } else {
      print('Failed to add service to favorites: ${response.statusCode}');
    }
  }

  Future<void> getUserDataFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get("accessToken");
      refreshToken = signInBox.get("refreshToken");
    });

    if (userId != null && accessToken != null && refreshToken != null) {
      getUserDetails();
    } else {
      // Handle case where user ID, access token, or refresh token is missing
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  Future<void> _shareContent(String text) async {
    await Share.share(text);
  }

  Future<void> getUserDetails() async {
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
        final favorites = responseBody["favourites"];
        favoriteServiceIds = favorites
            .where((fav) => fav["favouriteType"] == "services")
            .map<String>((fav) =>
            (fav["favouriteIds"] as List).cast<String>().join(", "))
            .toList();
        print("idsss $favoriteServiceIds");

        if (favoriteServiceIds != null) {
          for (String doctorId in favoriteServiceIds!) {
            List<String> individualDoctorIds = doctorId.split(',').map((id) => id.trim()).toList();
            for (String id in individualDoctorIds) {
              getDoctorDetails(id);
              print("individual id: $id");
            }
          }
        }
      } else if (response.statusCode == 403) {
        await refreshTokenAndRetryForGetUserDetails(baseUrl);
      } else {
        // Handle other status codes
      }
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> getDoctorDetails(String doctorId) async {
    final String doctorUrl =
        "https://dev.iwayplus.in/secured/hospital/get-service/$doctorId";

    try {
      final response = await http.get(
        Uri.parse(doctorUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        print("getting single doctor detail");
        Map<String, dynamic> doctorDetails = json.decode(response.body);
        print(doctorDetails);
        setState(() {
          ServiceNames.add(doctorDetails["data"]["name"]);
          doctorLocations.add(doctorDetails["data"]["locationName"]);
          doctorSpeciality.add(doctorDetails["data"]["type"]);
          ServiceContact.add(doctorDetails["data"]["contact"]);
          doctorLocationId.add(doctorDetails["data"]["locationId"]);
          FserviceId.add(doctorDetails["data"]["_id"]);
          // Initialize favorite state for this service item
          favoriteStates.add(false);
        });
      } else {
        // Handle error
      }
    } catch (e) {
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

        await getUserDetails();
      } else {
        // Handle other status codes
      }
    } catch (e) {
      // Handle errors
    }
  }

  @override
  void initState() {
    getUserDataFromHive();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          'Favourite Services',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (ServiceNames.isEmpty)
                Container(
                  height: MediaQuery.sizeOf(context).height*0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/noFavourite.png',
                          width: 150,
                          height: 150,
                        ),
                        TranslatorWidget(
                          'No Favorites Yet',
                          style: TextStyle(
                            color: Color(0xFF18181B),
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TranslatorWidget(
                          'Explore our services, doctors, and medicines to add your favorites here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              if (ServiceNames.isNotEmpty && doctorLocations.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    ServiceNames.length,
                        (index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 12),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  TranslatorWidget(
                                    ServiceNames[index],
                                    style: TextStyle(
                                      color: Color(0xFF18181B),
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        favoriteStates[index] = !favoriteStates[index];
                                      });
                                      await updateUserFavorites(FserviceId[index]);
                                    },
                                    icon: Icon(
                                      favoriteStates[index] ? Icons.favorite_border:Icons.favorite ,
                                      color: favoriteStates[index] ? null:Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(height: 8,),
                              Row(
                                children: [
                                  TranslatorWidget(
                                    doctorSpeciality[index],
                                    style: TextStyle(
                                      color: Color(0xFFA1A1AA),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8,),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF8D8C8C),
                                    size: 16,
                                  ),
                                  TranslatorWidget(
                                    doctorLocations[index],
                                    style: TextStyle(
                                      color: Color(0xFFA1A1AA),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        print('called');
                                        print(" id od doc $doctorLocationId[index]");
                                        PassLocationId(context,doctorLocationId[index]);
                                      },
                                      style: ElevatedButton
                                          .styleFrom(
                                        backgroundColor:
                                        Color(0xFF0B6B94),
                                        padding: EdgeInsets
                                            .symmetric(
                                            vertical: 12),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(4),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
                                        children: [
                                          Transform.rotate(
                                            angle: 180 * 3.1415926535 / 180,
                                            child: Icon(
                                              Icons.subdirectory_arrow_left_outlined,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          TranslatorWidget(
                                            'Directions',
                                            style: TextStyle(
                                              color:
                                              Colors.white,
                                              fontSize: 14,
                                              fontFamily:
                                              'Roboto',
                                              fontWeight:
                                              FontWeight
                                                  .w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8,),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _shareContent(shareText);
                                      },
                                      style: OutlinedButton
                                          .styleFrom(
                                        padding: EdgeInsets
                                            .symmetric(
                                            vertical: 12),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(4),
                                        ),
                                        side: BorderSide(
                                            color: Color(
                                                0xFF0B6B94)),
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
                                        children: [

                                          Icon(
                                            Icons
                                                .share,
                                            color: Color(
                                                0xFF0B6B94),
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          TranslatorWidget(
                                            'Share',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily:
                                              'Roboto',
                                              fontWeight:
                                              FontWeight
                                                  .w500,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16,),
                      ],
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
