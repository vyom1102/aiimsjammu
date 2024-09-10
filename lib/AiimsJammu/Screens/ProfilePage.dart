import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../Widgets/Translator.dart';
import '/FavouriteScreen.dart';
import '/LOGIN%20SIGNUP/SignIn.dart';
import '/AiimsJammu/Screens/EditProfile.dart';
import '/AiimsJammu/Screens/FavouriteRGCIScreen.dart';
import '/AiimsJammu/Screens/Help&SupportScreen.dart';
import '/AiimsJammu/Screens/PrivacyPolicy.dart';
import '/AiimsJammu/Screens/SettingScreenRgci.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  String? accessToken;
  String? refreshToken;
  String? name;
  String? emailAddress;
  String? username;
  String? uploadedimage;


  @override
  void initState() {
    super.initState();
    checkForReload();
    getUserDataFromHive();
  }
  var userListBox = Hive.box('user');

  void checkForReload(){
    if(userListBox.containsKey('name')){
      name = userListBox.get('name');
      print('name from database');
    }else{
      // getUserDetails();
      getUserDataFromHive();
      print("name from api");
    }
    if(userListBox.containsKey('username')){
      username = userListBox.get('username');
      print('username from database');
    }else{
      // getUserDetails();
      getUserDataFromHive();
      print("username from api");
    }
    if(userListBox.containsKey('photo')){
      uploadedimage = userListBox.get('photo');
      print('photo from database');
    }else{
      // getUserDetails();
      getUserDataFromHive();
      print("photo from api");
    }
  }
  Future<void> logout() async {
    final String logoutUrl = "https://dev.iwayplus.in/api/refreshToken/delete";

    try {
      final response = await http.delete(
        Uri.parse(logoutUrl),
        body: json.encode({
          "refreshToken": refreshToken,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(refreshToken);
      if (response.statusCode == 200) {
        final signInBox = await Hive.openBox('SignInDatabase');
        await signInBox.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        print('error deleting');
        CircularProgressIndicator();
      }
    } catch (e) {
      // Handle errors
    }
  }
  Future<void> getUserDataFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    final userlistBox = await Hive.openBox('user');

    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get("accessToken");
      refreshToken = signInBox.get("refreshToken");
      name = userlistBox.get("name");
      username = userlistBox.get("username");
      print("tokenrr");
      print(refreshToken);
    });
    if (name == null) {
    if (userId != null && accessToken != null && refreshToken != null) {
      // If user ID, access token, and refresh token are available, call API
      getUserDetails();
    }
    } else {
      // Handle case where user ID, access token, or refresh token is missing
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
        setState(() {
          name = responseBody["name"];
          emailAddress = responseBody["email"];
          username = responseBody["username"];
          userListBox.put('name', name);
          userListBox.put('username',username);
          userListBox.put('photo', uploadedimage);
        });
      } else if (response.statusCode == 403) {
        await refreshTokenAndRetryForGetUserDetails(baseUrl);

      } else {
      }
    } catch (e) {
      // Handle errors
    }
  }
  void navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfile()),
    );

    if (result != null && result['shouldRefresh'] == true) {
      getUserDetails();

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

        // Retry the getUserDetails call with the new access token
        await getUserDetails();
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
    }
  }
  @override
  Widget build(BuildContext context) {

        return Scaffold(

      appBar: AppBar(
        title: TranslatorWidget(
          'Account',
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            height: 0.07,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                Semantics(
                  label: "Profile Photo",
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0,right: 8),
                    child:Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey, // Grey border
                          width: 2.0, // Border width
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: 'https://dev.iwayplus.in/uploads/$uploadedimage',
                          width: 54,
                          height: 54,
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
                    // Container(
                    //   width: 54,
                    //   height: 54,
                    //
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     image: DecorationImage(
                    //       image: AssetImage('assets/images/Group 4343.png'),
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    // ),

                  ),
                ),
                Semantics(
                  label: "Name",
                  child: Container(
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TranslatorWidget(
                           name??'user',
                            style: TextStyle(
                              color: Color(0xFF18181B),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0.09,
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),

                        Semantics(
                          label: "Email Address",
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TranslatorWidget(

                              username??"Not Available",
                              style: TextStyle(

                                color: Color(0xFF8D8C8C),
                                fontSize: 12,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0.12,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
                    ],
                  ),
                ),
          SizedBox(height: 24,),
          Semantics(
            label: "",
            child: InkWell(
              onTap: (){
                navigateToEditProfile();
              //   Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) =>EditProfile()),
              // );
                },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/profilePageAssets/account_circle.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Edit Profile',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      child: Container(
                        width: 12,
                        height: 12,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label: "",
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>FavouriteRGCIScreen()),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/profilePageAssets/favorite.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Favourite',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      child: Container(
                        width: 12,
                        height: 12,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label: "",
            child: InkWell(
              onTap: (){ Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>SettingScreen()),
              );},
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/profilePageAssets/profileSetting.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Semantics(
          //   label:"",
          //   child: InkWell(
          //     onTap: (){
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) =>PrivacyPolicy()),
          //       );
          //     },
          //     child: Container(
          //       width: MediaQuery.sizeOf(context).width,
          //       height: 50,
          //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Container(
          //             width: 30,
          //             height: 30,
          //             // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
          //             child: SvgPicture.asset('assets/profilePageAssets/article.svg'),
          //           ),
          //           const SizedBox(width: 12),
          //           Text(
          //             'Terms and Privacy Policy',
          //             style: TextStyle(
          //               color: Color(0xFF18181B),
          //               fontSize: 16,
          //               fontFamily: 'Roboto',
          //               fontWeight: FontWeight.w500,
          //               height: 0.10,
          //             ),
          //           ),
          //           Spacer(),
          //           Container(
          //             width: 12,
          //             height: 12,
          //             // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
          //             child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          Semantics(
            label: '',
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>HelpSupportScreen()),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/profilePageAssets/help_center.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Help and Support',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SizedBox(height: MediaQuery.sizeOf(context).height*0.36,),
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //
          //     Container(
          //       width: MediaQuery.sizeOf(context).width*0.9,
          //       child: OutlinedButton(
          //         onPressed: () {
          //           logout();
          //           // Navigator.pushReplacement(
          //           //   context,
          //           //   MaterialPageRoute(
          //           //       builder: (context) =>SignIn()),
          //           // );
          //
          //         },
          //         style: OutlinedButton.styleFrom(
          //           padding: EdgeInsets.symmetric(vertical: 12),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(4),
          //           ),
          //           side: BorderSide(color: Color(0xFF0B6B94)),
          //         ),
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment:
          //           CrossAxisAlignment.center,
          //           children: [
          //             TranslatorWidget(
          //               'Log out',
          //               style: TextStyle(
          //                 color: Color(0xFF0B6B94),
          //                 fontSize: 16,
          //                 fontFamily: 'Roboto',
          //                 fontWeight: FontWeight.w500,
          //                 height: 0.09,
          //               ),
          //             )
          //
          //           ],
          //         ),
          //       ),
          //     ),
          //
          //   ],
          // ),
          Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: MediaQuery.sizeOf(context).width*0.9,
                child: OutlinedButton(
                  onPressed: () {

                    logout();
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) =>SignIn()),
                    // );

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
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      TranslatorWidget(
                        'Log out',
                        style: TextStyle(
                          color: Color(0xFF0B6B94),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0.09,
                        ),
                      )

                    ],
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 40,),


        ],
      ),
    );
  }
}
