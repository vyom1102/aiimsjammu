
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/LocationIdFunction.dart';
import '../Widgets/Translator.dart';

class DoctorProfile1 extends StatefulWidget {
  // final Map<String, dynamic> doctor;
  final String docId;

  DoctorProfile1({ required this.docId});

  @override
  _DoctorProfile1State createState() => _DoctorProfile1State();
}

class _DoctorProfile1State extends State<DoctorProfile1> {
  bool isFavorite = false;
  String? userId;
  String? accessToken;
  String? refreshToken;
  bool isLoading = false;
  Map<dynamic, dynamic> doctor={};

  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String? originalName;

  @override
  void initState() {
    getUserIDFromHive();
    getDoctorDetails(widget.docId);
    super.initState();
  }
  Future<void> getDoctorDetails(String doctorId) async {
    final String doctorUrl =
        "https://dev.iwayplus.in/secured/hospital/get-doctor/$doctorId";

    try {
      isLoading =true;
      final response = await http.get(
        Uri.parse(doctorUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("getting single doctor detail");
        Map<dynamic, dynamic> doctorDetails = json.decode(response.body);
        print(doctorDetails);
        setState(() {
          doctor =doctorDetails["data"];
          isLoading =false;

        });
      } else if (response.statusCode == 403) {
        await refreshTokenAndRetryForDoctor(doctorId);
      }else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }
  Future<void> refreshTokenAndRetryForDoctor(String docId) async {
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

        await getDoctorDetails(docId);
      } else {
        // Handle token refresh failure
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
  Widget build(BuildContext context) {
    return isLoading?Center(
      child: Container(
          height: 40,
          width: 40,
          child: CircularProgressIndicator()),
    ):Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: TranslatorWidget(
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
          IconButton(onPressed: (){
            _shareContent("https://dev.iwayplus.in/#/iway-apps/aiimsj.com/doctor?docId=${widget.docId}&appStore=com.iwayplus.aiimsjammu&playStore=com.iwayplus.aiimsjammu");

            // _shareContent("iwayplus://aiimsj.com/doctor?docId=${widget.docId}");
          }, icon: Icon(Icons.share_outlined)),
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
                        NetworkImage('https://dev.iwayplus.in/uploads/${doctor['imageUrl']}'),
                        // AssetImage(widget.doctor[
                        //     'imageUrl']),
                        radius: 73,
                      ),
                      SizedBox(height: 20),
                      TranslatorWidget(
                        doctor['name']??"Loading",
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
                      TranslatorWidget(
                        doctor['speciality'],
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
                        TranslatorWidget(
                          doctor['experience'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TranslatorWidget(
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
                        TranslatorWidget(
                          doctor['publications'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TranslatorWidget(
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
                        TranslatorWidget(
                          doctor['awards'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TranslatorWidget(
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
              child: TranslatorWidget(
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
                  child: TranslatorWidget(
                    doctor['about'],
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
                        _launchInWebView(Uri.parse(doctor['profile']));
                      },
                      child: TranslatorWidget(
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
              child: TranslatorWidget(
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
              children:doctor['workingDays'].map<Widget>((day) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                  child: TranslatorWidget(
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
            PassLocationId(context,doctor['locationId']);
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
              TranslatorWidget(
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
