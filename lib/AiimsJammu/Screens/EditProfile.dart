

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';

import '../../API/DeleteApi.dart';
import '../../LOGIN SIGNUP/SignIn.dart';
import '../../config.dart';
import '../Widgets/Translator.dart';
import 'ChangePassword.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String? userId;
  String? accessToken;
  String? refreshToken;
  String? originalName;
  String? photoUrl;
  File? _selectedImage;
  String? uploadedimage;
  bool isLoading = false;


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile
        != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);

      });
      await uploadImage();
    }
  }
  Future<void> uploadImage() async {
    final String uploadUrl = "${AppConfig.baseUrl}/secured/upload";

    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.headers['x-access-token'] = '$accessToken';
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      final response = await request.send();
      print("responsecode while uploading image");
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        print(responseData);
        if (responseData['status']) {
          setState(() {
            photoUrl = responseData['filename'];
          });

          userListBox.put('photo', photoUrl);

          await updateUser(context);
        } else {
          print("Failed to upload image: ${responseData['message']}");
        }
      } else if (response.statusCode == 403) {
        await refreshTokenAndRetryUpload();
      } else {
        print("Failed to upload image. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while uploading the file: $e");
    }
  }
  Future<void> refreshTokenAndRetryUpload() async {
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

        // Update the access token in the local database
        final signInBox = await Hive.openBox('SignInDatabase');
        signInBox.put('accessToken', accessToken);

        // Retry the image upload with the new token
        await uploadImage();
      } else {
        print("Failed to refresh token. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while refreshing the token: $e");
    }
  }
  @override
  void initState() {
    super.initState();
    // Retrieve user ID from Hive
    getUserIDFromHive();
  }
  var userListBox = Hive.box('user');

  Future<void> getUserIDFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    print("signInBox.values");
    print(signInBox.values);

    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get('accessToken');
      refreshToken = signInBox.get('refreshToken');
      _nameController.text = userListBox.get('name');
      _emailController.text = userListBox.get('username');
      uploadedimage = userListBox.get("photo");

    });

    if (userId != null) {
      if(_nameController.text.isEmpty || uploadedimage==null ) {
      getUserDetails();
      }else{
        print("name and email from database");
      }
    } else {
      print("User id is null");
    }
  }
  Future<void> getUserDetails() async {
    setState(() {
      isLoading = true;
    });
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
        _emailController.text = responseBody["username"];
        originalName = responseBody["name"];

        print("originalName");
        print(originalName);
        setState(() {
          // originalName = responseBody["name"];
          _emailController.text = responseBody["username"]??"Not Available";
          _nameController.text = responseBody["name"]??"User";
          uploadedimage = responseBody["photo"]??"not available";

        });
        _nameController.text = originalName!;
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
        uploadedimage = responseBody["photo"]??"not available";

      } else {
        // Handle other status codes after token refresh
      }
    } catch (e) {
      // Handle errors after token refresh
    }
  }



  // Future<void> updateUser() async {
  //   final String updateUrl = "${AppConfig.baseUrl}/secured/user/update/$userId";
  //
  //   try {
  //     final response = await http.put(
  //       Uri.parse(updateUrl),
  //       body: json.encode({
  //         "email": _emailController.text,
  //         "name": _nameController.text,
  //       }),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'x-access-token': '$accessToken',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Handle successful update
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Name updated successfully')),
  //       );
  //       Navigator.pop(context);
  //     } else if (response.statusCode == 403) {
  //       // Access token expired, refresh token and retry the call
  //       await refreshTokenAndRetry(updateUrl);
  //     } else {
  //       // Handle other status codes
  //     }
  //   } catch (e) {
  //     // Handle errors
  //   }
  // }
  Future<void> updateUser(BuildContext context) async {
    final String updateUrl = "${AppConfig.baseUrl}/secured/user/update/$userId";

    // Show a loading indicator
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Updating',
      text: 'Please wait...',
      barrierDismissible: false,
    );

    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        body: json.encode({
          "email": _emailController.text,
          "name": _nameController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      Navigator.of(context).pop(); // Close the loading indicator

      if (response.statusCode == 200) {
        // Show success alert
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Name updated successfully',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            userListBox.put('name', _nameController.text);

            Navigator.pop(context);
            Navigator.of(context).pop({
              'shouldRefresh': true
            });
          },
        );
      } else if (response.statusCode == 403) {
        // Access token expired, refresh token and retry the call
        await refreshTokenAndRetry(updateUrl);
      } else {
        // Handle other status codes
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Failed to update name. Please try again.',
          confirmBtnText: 'OK',
        );
      }
    } catch (e) {
      // Handle errors
      Navigator.of(context).pop(); // Close the loading indicator if an error occurs
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'An error occurred while updating. Please try again.',
        confirmBtnText: 'OK',
      );
    }
  }

  Future<void> refreshTokenAndRetry(String updateUrl) async {
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
        final signInBox = await Hive.openBox('SignInDatabase');
        signInBox.put('accessToken', accessToken);


        await updateUserWithNewToken(updateUrl);
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> updateUserWithNewToken(String updateUrl) async {
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        body: json.encode({
          "email": _emailController.text,
          "name": _nameController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        // Handle successful update after token refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslatorWidget('Name updated successfully')),
        );
      } else {
        // Handle other status codes after token refresh
      }
    } catch (e) {
      // Handle errors after token refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: isLoading
              ? CircularProgressIndicator()
              :Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Container(
                  //   width: 150,
                  //   height: 150,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     // color: Colors.lightBlue,
                  //     image: DecorationImage(
                  //       image: AssetImage('assets/images/Group 4343.png'),
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey, // Grey border
                        width: 2.0, // Border width
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: '${AppConfig.baseUrl}/uploads/$uploadedimage',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[200],
                          child: Image.asset(
                            'assets/images/Group 4343.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child:
                      IconButton(
                        icon: Icon(Icons.camera_alt,color: Colors.white,),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      enabled: false,
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Or Phone No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 20,),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen(email: _emailController.text,)),
                      );
                    },
                    child: TranslatorWidget(
                      'Change password',
                      style: TextStyle(
                        color: Color(0xFF0B6B94),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Spacer(),
                  // Container(
                  //   margin: EdgeInsets.only(right: 22,top: 2,),
                  //   alignment: Alignment.centerLeft,
                  //   child: TextButton(
                  //     onPressed: () async {
                  //       var signInBox = Hive.box('SignInDatabase');
                  //       String userid = signInBox.get("userId");
                  //       String token = signInBox.get("accessToken");
                  //       print("userid");
                  //       print(signInBox.get("userId"));
                  //       print(userid);
                  //       print(token);
                  //       print(signInBox.keys);
                  //       signInBox.clear();
                  //       print("Localdatabase cleared");
                  //       print(signInBox.keys);
                  //       Future<bool> response = DeleteApi..deleteDataa();
                  //       if(await response){
                  //         signInBox.clear();
                  //         print("Localdatabase cleared");
                  //         print(signInBox.keys);
                  //         Navigator.pushAndRemoveUntil(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => SignIn()),
                  //               (route) => false,
                  //         );
                  //       }else{
                  //
                  //       }
                  //     },
                  //     child: Text(
                  //       'Delete Profile',
                  //       style: TextStyle(
                  //         color: Colors.red,
                  //         fontSize: 16,
                  //         fontFamily: 'Roboto',
                  //         fontWeight: FontWeight.w500,
                  //         height: 0.10,
                  //       ),
                  //     ),
                  //   ),
                  // ),
        Container(
          margin: EdgeInsets.only(right: 22, top: 2),
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              // Show confirmation dialog
              QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                title: 'Delete Profile',
                text: 'Are you sure you want to delete your profile?',
                confirmBtnText: 'Yes',
                cancelBtnText: 'No',
                onConfirmBtnTap: () async {
                  Navigator.of(context).pop(); // Close the confirmation dialog

                  var signInBox = Hive.box('SignInDatabase');
                  String userid = signInBox.get("userId");
                  String token = signInBox.get("accessToken");
                  print("userid");
                  print(signInBox.get("userId"));
                  print(userid);
                  print(token);
                  print(signInBox.keys);
                  signInBox.clear();
                  print("Local database cleared");
                  print(signInBox.keys);

                  Future<bool> response = DeleteApi.deleteData();
                  if (await response) {
                    signInBox.clear();
                    print("Local database cleared");
                    print(signInBox.keys);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()),
                          (route) => false,
                    );
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Error',
                      text: 'Failed to delete profile. Please try again.',
                      confirmBtnText: 'OK',
                    );
                  }
                },
                onCancelBtnTap: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                },
              );
            },
            child: TranslatorWidget(
              'Delete Profile',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 0.10,
              ),
            ),
          ),
        )
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.26),

              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: OutlinedButton(
                      // onPressed: () {
                      //   if (_nameController.text != originalName) {
                      //
                      //     QuickAlert.show(
                      //       context: context,
                      //       type: QuickAlertType.success,
                      //       title: 'Success',
                      //       text: 'Name changed successfully',
                      //       confirmBtnText: 'OK',
                      //       onConfirmBtnTap: () {
                      //         updateUser();
                      //         Navigator.pop(context);
                      //
                      //       },
                      //     );
                      //   }else{
                      //     Fluttertoast.showToast(
                      //       msg: "No changes made",
                      //       toastLength: Toast.LENGTH_LONG,
                      //       gravity: ToastGravity.BOTTOM,
                      //       backgroundColor: Colors.black,
                      //       textColor: Colors.white,
                      //     );
                      //   }
                      // },
                      onPressed: () {
                        if (_nameController.text != originalName) {
                          updateUser(context);
                          // Navigator.pop(context);
                        } else {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Error',
                            text: 'No changes made',
                            confirmBtnText: 'OK',
                          );
                        }
                      },

                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(color: Color(0xFF0B6B94)),
                      ),
                      child: TranslatorWidget(
                        'Save changes',
                        style: TextStyle(
                          color: Color(0xFF0B6B94),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
