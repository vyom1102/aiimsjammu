
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/LocationIdFunction.dart';

class DoctorProfile extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String docId;

  DoctorProfile({required this.doctor, required this.docId});

  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  bool isFavorite = false;
  String? userId;
  String? accessToken;
  String? refreshToken;
  bool isLoading = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String? originalName;

  @override
  void initState() {
    getUserIDFromHive();
    super.initState();
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

  // Future<void> getUserDetails() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   final String baseUrl = "https://dev.iwayplus.in/secured/user/get";
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
  //       _emailController.text = responseBody["email"];
  //       originalName = responseBody["name"];
  //       _nameController.text = originalName!;
  //       // Check if docId is in favorites
  //       if (responseBody["favourites"] != null &&
  //           responseBody["favourites"]["doctors"] != null) {
  //         List<dynamic> doctorIds = responseBody["favourites"]["doctors"];
  //         print(" Alll fav doc $doctorIds");
  //         print(widget.docId);
  //         setState(() {
  //           isFavorite = doctorIds.contains(widget.docId);
  //         });
  //       }
  //     } else if (response.statusCode == 403) {
  //       // Access token expired, refresh token and retry the call
  //       await refreshTokenAndRetryForGetUserDetails(baseUrl);
  //     } else {
  //       print(response.statusCode);
  //     }
  //   } catch (e) {
  //     // Handle errors
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
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
        _emailController.text = responseBody["email"];
        originalName = responseBody["name"];
        _nameController.text = originalName!;

        // Check if docId is in favorites
        if (responseBody["favourites"] != null) {
          List<dynamic> favorites = responseBody["favourites"];
          for (var favorite in favorites) {
            if (favorite["favouriteType"] == "doctors") {
              List<dynamic> doctorIds = favorite["favouriteIds"];
              setState(() {
                isFavorite = doctorIds.contains(widget.docId);
              });
              break;
            }
          }
        }
      } else if (response.statusCode == 403) {
        // Access token expired, refresh token and retry the call
        await refreshTokenAndRetryForGetUserDetails(baseUrl);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      // Handle errors
    } finally {
      setState(() {
        isLoading = false;
      });
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
        _emailController.text = responseBody["email"];
        originalName = responseBody["name"];
        _nameController.text = originalName!;
        // Check if docId is in favorites
        if (responseBody["favourites"] != null &&
            responseBody["favourites"]["doctors"] != null) {
          List<dynamic> doctorIds = responseBody["favourites"]["doctors"];
          print(doctorIds);

          setState(() {
            isFavorite = doctorIds.contains(widget.docId);
          });
        }
      } else {
        // Handle other status codes after token refresh
      }
    } catch (e) {
      // Handle errors after token refresh
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
      'favouriteType': 'doctors',
      'favouriteId': widget.docId,
    };

    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Doctor added to favorites!');
      if (!isFavorite) {
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

      setState(() {
        isFavorite = !isFavorite;
      });
    } else if (response.statusCode == 403) {
      // Access token expired, refresh token and retry the call
      await refreshTokenAndRetryForGetUserDetails(baseUrl);
    } else {
      print('Failed to add doctor to favorites: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Doctor Details',
          style: TextStyle(
            color: Color(0xFF3F3F46),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 0.09,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await updateUserFavorites();
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                        NetworkImage('https://dev.iwayplus.in/uploads/${widget.doctor['imageUrl']}'),
                        // AssetImage(widget.doctor[
                        //     'imageUrl']),
                        radius: 73,
                      ),
                      SizedBox(height: 20),
                      Text(
                        widget.doctor['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF18181B),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0.09,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        widget.doctor['speciality'],
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
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Color(0xffF3F4F6),
            ),
        
            Container(
              height: 120,
              // color:Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffF3F4F6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                                'assets/DoctorProfileAssets/medal.png'),
                          ),
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.doctor['experience'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Experience',
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
                  ),
                  Container(
                    // width: 150,
                    height: 200,
        
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffF3F4F6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                                'assets/DoctorProfileAssets/publication.png'),
                          ),
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.doctor['publications'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Publication',
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
                  ),
                  Container(
                    // width: 150,
                    height: 200,
        
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffF3F4F6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                                'assets/DoctorProfileAssets/Award.png'),
                          ),
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.doctor['awards'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Award',
                          style: TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                'About',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 0.07,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 16, left: 16),
                  child: Text(
                    widget.doctor['about'],
                    style: TextStyle(
                      color: Color(0xFF3F3F46),
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      // height: 0.10,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        _launchInWebView(Uri.parse(widget.doctor['profile']));
                      },
                      child: Text(
                        'View profile',
                        style: TextStyle(
                          color: Color(0xFF0B6B94),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          // height: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
              child: Text(
                'Working Time',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 0.07,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.doctor['workingDays'].map<Widget>((day) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                  child: Text(
                    '${day['day']} - ${day['openingTime']} AM - ${day['closingTime']} PM',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: OutlinedButton(
          onPressed: () {
            PassLocationId(context,widget.doctor['locationId']);
          },
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Color(0xFF0B6B94)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Direction',
                style: TextStyle(
                  color: Color(0xFF0B6B94),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  // height: 0.10,
                ),
              ),
              SizedBox(width: 8),
              Transform.rotate(
                angle: 180 * 3.1415926535 / 180,
                child: Icon(
                  Icons.subdirectory_arrow_left_outlined,
                  color: Color(0xFF0B6B94),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchInWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }
}
