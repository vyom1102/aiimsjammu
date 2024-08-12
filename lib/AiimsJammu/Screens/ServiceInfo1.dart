import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../MainScreen.dart';
import '../Widgets/CalculateDistance.dart';
import '../Widgets/LocationIdFunction.dart';
import '../Widgets/OpeningClosingStatus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../Widgets/Translator.dart';
class ServiceInfo1 extends StatefulWidget {
  final String id;

  const ServiceInfo1({
    required this.id,

  });

  @override
  State<ServiceInfo1> createState() => _ServiceInfo1State();
}

class _ServiceInfo1State extends State<ServiceInfo1> {
  // final String phoneNumber = contact;
  final String shareText = 'https://play.google.com/store/apps/details?id=com.iwayplus.rgcinavigation';
  bool isFavorite=false;
  String? userId;
  String? accessToken;
  String? refreshToken;
  List<String>? favoriteServiceIds;
  Map<dynamic, dynamic> service={};
  bool isLoading = true;
  bool _isConnected = false;
  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      setState(() {
        _isConnected = true;
      });
    }
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
  Future<void> getServiceDetails(String serviceId) async {
    final String serviceUrl =
        "https://dev.iwayplus.in/secured/hospital/get-service/${serviceId}";

    try {
      isLoading =true;
      final response = await http.get(
        Uri.parse(serviceUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("getting single doctor detail");
        Map<dynamic, dynamic> serviceDetails = json.decode(response.body);
        print(serviceDetails);
        setState(() {
          service =serviceDetails;
          isLoading =false;

        });
      } else if (response.statusCode == 403) {
        await refreshTokenAndRetryForService(serviceId);
      }else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }
  Future<void> refreshTokenAndRetryForService(String serviceId) async {
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

        await getServiceDetails(serviceId);
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
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
  Future<bool> willPopScope() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: 0),
      ),
          (Route<dynamic> route) => false, // Remove all routes
    );
    return false;
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
  @override
  void initState() {
    _checkConnectivity();
    getServiceDetails(widget.id);

    getUserIDFromHive();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return isLoading?Center(
      child: Container(
          height: 40,
          width: 40,
          child: CircularProgressIndicator()),
    ):WillPopScope(
      onWillPop:willPopScope ,
      child: Scaffold(
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

                    // Image.network(
                    //   'https://dev.iwayplus.in/uploads/${widget.imagePath}',
                    //   // width: 250,
                    //   width: MediaQuery.of(context).size.width,
                    //   height: 200,
                    //   fit: BoxFit.cover,
                    // ),
                    CachedNetworkImage(
                      imageUrl: 'https://dev.iwayplus.in/uploads/${service["data"]["image"]}',
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 250,
                        height: 140,
                        color: Colors.grey[200],
                        child:Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      ),
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
                              service["data"]["type"],
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
                      service["data"]["name"],
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff18181b),

                      ),
                      textAlign: TextAlign.left,
                    ),

                    if(service["data"]["accessibility"]!='NO')
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
                      service["data"]["locationName"]??"",
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
                      future: calculateDistance(service["data"]["locationId"]),
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
                        child: OpeningClosingStatus(startTime: service["data"]["startTime"], endTime: service["data"]["endTime"],)),
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
                // Padding(
                //   padding: EdgeInsets.only(top: 12.0,right: 16,left: 16,bottom: 16),
                //   child: TranslatorWidget('Designing the operation hours section for a mobile app involves displaying the opening and closing hours of a business ',
                //     style: TextStyle(
                //       color: Color(0xFF595967),
                //       fontSize: 14,
                //       fontFamily: 'Roboto',
                //       fontWeight: FontWeight.w400,
                //
                //     ),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(top: 12.0,right: 16,left: 16,bottom: 16),
                  child: TranslatorWidget(
                    service["data"]["about"],
                    style:TextStyle(color: Color(0xFF595967),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    )

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
                if(service["data"]["contact"]!="null" && service["data"]["contact"].isNotEmpty)

                  SizedBox(height: 16,),

                if(service["data"]["contact"]!= "null" && service["data"]["contact"].isNotEmpty)
                  InkWell(
                    onTap: (){
                      _makePhoneCall(service["data"]["contact"]);

                    },

                    child: Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          Icon(Icons.phone),
                          SizedBox(width: 8,),
                          TranslatorWidget(
                            service["data"]["contact"],
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
                                '     ${service["data"]["startTime"]} Am - ${service["data"]["endTime"]} Pm',
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
                    PassLocationId(context,service["data"]["locationId"]);
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
                    _shareContent("https://dev.iwayplus.in/#/iway-apps/aiimsj.com/service?serviceId=${widget.id}&appStore=com.iwayplus.aiimsjammu&playStore=com.iwayplus.aiimsjammu");

                    // _shareContent("iwayplus://aiimsj.com/service?serviceId=${widget.id}");
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
              if(service["data"]["contact"]!="null" && service["data"]["contact"].isNotEmpty)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _makePhoneCall(service["data"]["contact"]);
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
      ),
    );
  }
}