
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:iwaymaps/AiimsJammu/Screens/FavouriteDoctor.dart';
import 'package:iwaymaps/AiimsJammu/Screens/FavouriteService.dart';
class FavouriteRGCIScreen extends StatefulWidget {
  const FavouriteRGCIScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteRGCIScreen> createState() => _FavouriteRGCIScreenState();
}

class _FavouriteRGCIScreenState extends State<FavouriteRGCIScreen> {
  String? userId;
  String? accessToken;
  String? refreshToken;
  String? originalName;
  bool isLoading = false;
  String? NoOfDoc;
  String? NoOfService;

  @override
  void initState() {
    super.initState();
    // Retrieve user ID from Hive
    getUserIDFromHive();
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

        await getUserDetailsWithNewToken(baseUrl);
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
    }
  }
  Future<void> getUserDetailsWithNewToken(String baseUrl) async {
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
        print(responseBody);
        // _emailController.text = responseBody["email"];
        // originalName = responseBody["name"];
        // _nameController.text = originalName!;
      } else {
        // Handle other status codes after token refresh
      }
    } catch (e) {
      // Handle errors after token refresh
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
    }
  }
  Future<void> getUserDetails() async {
    setState(() {
      isLoading = true;
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
        print(responseBody);

        var doctorsFavourites = responseBody['favourites']
            .firstWhere((item) => item['favouriteType'] == 'doctors', orElse: () => null);

        if (doctorsFavourites != null) {
          // Get the length of the favouriteIds array for doctors
          List<dynamic>? favouriteDoctorIds = doctorsFavourites['favouriteIds'];

          if (favouriteDoctorIds != null) {
            setState(() {
              NoOfDoc = favouriteDoctorIds.length.toString();
            });
          }
        }
        var servicesFavourites = responseBody['favourites']
            .firstWhere((item) => item['favouriteType'] == 'services', orElse: () => null);

        if (servicesFavourites != null) {
          // Get the length of the favouriteIds array for services
          List<dynamic>? favouriteServiceIds = servicesFavourites['favouriteIds'];
          if (favouriteServiceIds != null) {
            setState(() {
              NoOfService = favouriteServiceIds.length.toString();
            });
          }
        }

        print("value12344$NoOfDoc");
        print(responseBody['favourites'][0]['favouriteIds'].length);
        // _emailController.text = responseBody["email"];
        // originalName = responseBody["name"];
        // _nameController.text = originalName!;
      } else if (response.statusCode == 403) {
        // Access token expired, refresh token and retry the call
        await refreshTokenAndRetryForGetUserDetails(baseUrl);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      // Handle errors
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Favourite',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                'My saved items',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              SvgPicture.asset('assets/images/favorite.svg'),
              SizedBox(width: 16),
            ],
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FavouriteDoctor()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),

              child: Row(
                children: [
                  SvgPicture.asset('assets/images/Doctor.svg',width: 30,),
                  SizedBox(width: 16,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctors',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF18181B),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [


                          Text(
                            NoOfDoc!=null?"${NoOfDoc} items":"No items",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                            ),
                          )
                        ],
                      ),


                    ],
                  ),
                  Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    child: Container(
                      width: 20,
                      height: 20,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ),

                ],

              ),
            ),
          ),
          SizedBox(height: 8,),

          InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FavouriteService()),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 4),

              child: Row(
                children: [
                  SvgPicture.asset('assets/images/Cafetaria.svg',width: 30,),
                  SizedBox(width: 16,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF18181B),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [


                          Text(
                            NoOfService!=null?"$NoOfService items":"No items",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                            ),
                          )
                        ],
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    child: Container(
                      width: 20,
                      height: 20,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ),

                ],

              ),
            ),
          ),

        ],
      ),
    );
  }
}
