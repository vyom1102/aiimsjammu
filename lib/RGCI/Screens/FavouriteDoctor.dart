import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/LocationIdFunction.dart';

class FavouriteDoctor extends StatefulWidget {
  const FavouriteDoctor({Key? key}) : super(key: key);

  @override
  State<FavouriteDoctor> createState() => _FavouriteDoctorState();
}

class _FavouriteDoctorState extends State<FavouriteDoctor> {
  String? userId;
  String? accessToken;
  String? refreshToken;
  List<String>? favoriteDoctorIds;
  List<String> doctorNames = [];
  List<String> doctorLocations = [];
  List<String> doctorSpeciality = [];
  List<String> FdoctorId = [];
  List<bool> favoriteStates = [];

  List<String> doctorLocationId = [];
  bool isFavorite = true;


  final String shareText = 'https://play.google.com/store/apps/details?id=com.iwayplus.rgcinavigation';
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
        favoriteDoctorIds = favorites
            .where((fav) => fav["favouriteType"] == "doctors")
            .map<String>((fav) =>
            (fav["favouriteIds"] as List).cast<String>().join(", "))
            .toList();
        print("idsss $favoriteDoctorIds");

        if (favoriteDoctorIds != null) {
          for (String doctorId in favoriteDoctorIds!) {
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
          "https://dev.iwayplus.in/secured/hospital/get-doctor/$doctorId";

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
            doctorNames.add(doctorDetails["data"]["name"]);
            doctorLocations.add(doctorDetails["data"]["locationName"]);
            doctorSpeciality.add(doctorDetails["data"]["speciality"]);
            FdoctorId.add(doctorDetails["data"]["_id"]);

            doctorLocationId.add(doctorDetails["data"]["locationId"]);
            favoriteStates.add(false);
            print(favoriteDoctorIds);

          });
        } else {
          // Handle error
        }
      } catch (e) {
        // Handle error
      }
    }

  Future<void> updateUserFavorites(String id) async {
    // print(widget.docId);
    String baseUrl = "https://dev.iwayplus.in/secured/user/toggle-favourites";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-access-token': '$accessToken',
    };
    Map<String, dynamic> body = {
      'userId': userId,
      'favouriteType': 'doctors',
      'favouriteId': id,
    };
    // if (widget.doctor['_id'] != null) {
    //   // Ensure doctor ID is added as a string
    //   String doctorId = widget.doctor['_id'].toString();
    //   print(doctorId);
    //   body['favouriteId'].add(doctorId);
    // }


    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(body),
    );


    if (response.statusCode == 200) {
      print('Doctor added to favorites!');

        Fluttertoast.showToast(
          msg: "Removed from favorites!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );

    } else if (response.statusCode == 403) {
      // Access token expired, refresh token and retry the call
      await refreshTokenAndRetryForGetUserDetails(baseUrl);
    } else {
      print('Failed to add doctor to favorites: ${response.statusCode}');
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

      }
    } catch (e) {

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
        title: Text(
          'Favourite Doctors',
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

              if (doctorNames.isEmpty)
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
                      Text(
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
                      Text(
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
        
              if (doctorNames.isNotEmpty && doctorLocations.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    doctorNames.length,
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
        
                                  Text(
                                    doctorNames[index],
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
                                      await updateUserFavorites(FdoctorId[index]);
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
                                  Text(
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
                              // Row(
                              //   children: [
                              //
                              //     Icon(
                              //       Icons.location_on_outlined,
                              //       color: Color(0xFF8D8C8C),
                              //       size: 16,
                              //     ),
                              //
                              //     Text(
                              //       doctorLocations[index],
                              //       style: TextStyle(
                              //         color: Color(0xFFA1A1AA),
                              //         fontSize: 14,
                              //         fontFamily: 'Roboto',
                              //         fontWeight: FontWeight.w400,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF8D8C8C),
                                    size: 16,
                                  ),
                                  SizedBox(width: 4), // Add some spacing between icon and text
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        doctorLocations[index],
                                        style: TextStyle(
                                          color: Color(0xFFA1A1AA),
                                          fontSize: 14,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
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
                                          Text(
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
                                          Text(
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
