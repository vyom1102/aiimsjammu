import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/CalculateDistance.dart';
import '../Widgets/LocationIdFunction.dart';
import '../Widgets/OpeningClosingStatus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../Widgets/Translator.dart';
class ServiceInfo extends StatefulWidget {
  final String id;
  final String imagePath;
  final String name;
  final String location;
  final String accessibility;
  final String locationId;
  final String type;
  final String contact;
  final String about;

  final String startTime;
  final String endTime;

  const ServiceInfo({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.accessibility,
    required this.locationId,
    required this.type,
    required this.contact,

    required this.about,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<ServiceInfo> createState() => _ServiceInfoState();
}

class _ServiceInfoState extends State<ServiceInfo> {
  // final String phoneNumber = contact;
  final String shareText = 'https://play.google.com/store/apps/details?id=com.iwayplus.rgcinavigation';
  bool isFavorite=false;
  String? userId;
  String? accessToken;
  String? refreshToken;
  List<String>? favoriteServiceIds;
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


        // Check if docId is in favorites
        if (responseBody["favourites"] != null) {
          List<dynamic> favorites = responseBody["favourites"];
          for (var favorite in favorites) {
            if (favorite["favouriteType"] == "services") {
              List<dynamic> doctorIds = favorite["favouriteIds"];
              setState(() {
                isFavorite = doctorIds.contains(widget.id);
              });
              break;
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

  Future<void> getUserIDFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');

    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get('accessToken');
      refreshToken = signInBox.get('refreshToken');
    });
    if (userId != null) {
      getUserDetails();
    } else {
      // Handle if userId is null
    }

  }
  Future<void> updateUserFavorites() async {

    String baseUrl = "https://dev.iwayplus.in/secured/user/toggle-favourites";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-access-token': '$accessToken',
    };
    Map<String, dynamic> body = {
      'userId': userId,
      'favouriteType': 'services',
      'favouriteId': widget.id,
    };



    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(body),
    );


    if (response.statusCode == 200) {
      print('Services added to favorites!');
      if (isFavorite) {
        Fluttertoast.showToast(
          msg: "Added to favorites!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Removed from favorites!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
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

        print('here');
        // updateUserFavorites();
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
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
  @override
  void initState() {
    getUserIDFromHive();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                isFavorite = !isFavorite;
              });
              await updateUserFavorites();
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //
          //   },
          //   icon: Icon(
          //       Icons.share
          //   ),
          // ),

        ],
      ),
      body: SingleChildScrollView(
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [

                  Image.network(
                    'https://dev.iwayplus.in/uploads/${widget.imagePath}',
                    // width: 250,
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,

                    child: Container(
                      // width: 73,
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF05AF9A),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(0),
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
                            widget.type,
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
              SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 12,
                  ),
                  TranslatorWidget(
                    widget.name,
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff18181b),

                    ),
                    textAlign: TextAlign.left,
                  ),

                  if(widget.accessibility!='NO')
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Image.asset('assets/images/accessible.png',scale: 4,),
                    )
                ],
              ),
              SizedBox(
                height: 8,
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
                    widget.location,
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
                height: 8,
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
                    future: calculateDistance(widget.locationId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 25,
                          height: 25,// Adjust width as needed
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
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
              SizedBox(height: 16,),
              Row(
                children: [
                  SizedBox(width: 12,),
                  Container(
                    // height: 20,
                      child: OpeningClosingStatus(startTime: widget.startTime, endTime: widget.endTime,)),
                ],
              ),
              SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 16,right: 16),
                child: Row(
                  children: [
                    TranslatorWidget(
                      'About',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,

                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0,right: 16,left: 16,bottom: 16),
                child: TranslatorWidget('Designing the operation hours section for a mobile app involves displaying the opening and closing hours of a business ',
                style: TextStyle(
                  color: Color(0xFF595967),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,

                ),
                ),
              ),
              SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.only(left: 16.0,bottom: 8),
                child: Row(
                  children: [
                    TranslatorWidget(
                      'Information',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.09,
                      ),
                    ),
                  ],
                ),
              ),
              if(widget.contact!="null" && widget.contact.isNotEmpty)

                SizedBox(height: 16,),

              if(widget.contact != "null" && widget.contact.isNotEmpty)
                InkWell(
                  onTap: (){
                    _makePhoneCall(widget.contact);

                  },

                  child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 8,),
                      TranslatorWidget(
                        widget.contact,
                        style: TextStyle(
                          color: Color(0xFF595967),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,

                        ),
                      )
                    ],
                  ),
                                ),
                ),
              SizedBox(height: 16,),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule),
                        SizedBox(width: 8,),
                        TranslatorWidget(
                          'Opening Hours:',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 0.10,
                          ),
                        ),
                        SizedBox(height: 8,),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 16,),
                        Column(
                          children: [
                            TranslatorWidget(
                              'Monday to Sunday',
                              style: TextStyle(
                                color: Color(0xFF595967),
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,

                              ),
                            ),
                            SizedBox(height: 4,),
                            TranslatorWidget(
                              '     ${widget.startTime} Am - ${widget.endTime} Pm',
                              style: TextStyle(
                                color: Color(0xFF595967),
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,

                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  print('called');
                  PassLocationId(context,widget.locationId);
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
            SizedBox(width: 8,),
            if(widget.contact!="null" && widget.contact.isNotEmpty)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _makePhoneCall(widget.contact);
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
                          .call,
                      color: Color(
                          0xFF0B6B94),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    TranslatorWidget(
                      'Call',
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
      ),
    );
  }
}