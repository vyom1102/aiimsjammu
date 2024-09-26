import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../Widgets/LocationIdFunction.dart';
import '../Widgets/Translator.dart';
import 'DoctorProfile1.dart';

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
  bool _isConnected = false;

  List<String> doctorLocationId = [];
  bool isFavorite = true;


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

  // Future<void> _shareContent(String text) async {
  //   await Share.share(text);
  // }

  Future<void> _shareContent(String text) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: text,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw Exception('QR code generation failed');
      }
      final qrCode = qrValidationResult.qrCode;

      final ByteData imageData = await rootBundle.load('assets/images/qrlogo.png');
      final ui.Codec codec = await ui.instantiateImageCodec(imageData.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image image = fi.image;

      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF0B6B94),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
        embeddedImage: image,
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(300, 300),
        ),
      );

      final int qrSize = 2048;
      final int padding = 100;
      final int totalSize = qrSize + (2 * padding);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawColor(Colors.white, BlendMode.src);

      canvas.translate(padding.toDouble(), padding.toDouble());
      painter.paint(canvas, Size(qrSize.toDouble(), qrSize.toDouble()));

      final picture = recorder.endRecording();
      final img = await picture.toImage(totalSize, totalSize);
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      final buffer = pngBytes!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/doctor_share.png';
      final file = await File(tempPath).writeAsBytes(buffer);

      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (e) {
      print('Error sharing content: $e');
    }
  }
  Future<void> getUserDetails() async {
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
          "${AppConfig.baseUrl}/secured/hospital/get-doctor/$doctorId";

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
    String baseUrl = "${AppConfig.baseUrl}/secured/user/toggle-favourites";

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
    final String refreshTokenUrl = "${AppConfig.baseUrl}/api/refreshToken";

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
    _checkConnectivity();

    getUserDataFromHive();
    super.initState();
  }
  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      setState(() {
        _isConnected = true;
      });
    }
  }
  Widget _buildNoNetworkState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no-connection 1.png',
              width: 100,
              height: 100,
            ),
            TranslatorWidget(
              'No Internet Connection',
              style: TextStyle(
                color: Color(0xFF18181B),
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
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
              if (!_isConnected)
                _buildNoNetworkState()
              else if (doctorNames.isEmpty)
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
        
              if (doctorNames.isNotEmpty && doctorLocations.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    doctorNames.length,
                        (index) => InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorProfile1(
                                  docId: FdoctorId[index],
                                ),
                              ),
                            );
                          },
                          child: Column(
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
                                        child: TranslatorWidget(
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
                                          _shareContent("${AppConfig.baseUrl}/#/iway-apps/aiimsj.com/doctor?docId=${FdoctorId[index]}&appStore=com.iwayplus.aiimsjammu&playStore=com.iwayplus.aiimsjammu");

                                          // _shareContent(shareText);
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
                ),
        
        

            ],
          ),
        ),
      ),
    );
  }
}
