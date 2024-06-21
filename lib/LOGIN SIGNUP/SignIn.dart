
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:iwaymaps/ContactUs.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';
import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart' as lot;
import '../Elements/HelperClass.dart';
import '../MainScreen.dart';
import 'ForgetPassword.dart';
import 'LOGIN SIGNUP APIS/APIS/SignInAPI.dart';
import 'SignUp.dart';

class SignIn extends StatefulWidget {
  final String? emailOrPhoneNumber;
  final String? password;

  const SignIn({super.key, this.emailOrPhoneNumber, this.password});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  FocusNode smallTextMailFocus = new  FocusNode();
  FocusNode smallTextPassFocus = new  FocusNode();
  String prefixMailText = "";
  bool hidden = true;
  bool obsecure = true;
  TextEditingController passEditingController = TextEditingController();
  TextEditingController mailEditingController = TextEditingController();
  bool passincorrect = false;
  Color colorOfText = new Color(0xff49454f);
  Color outlineheaderColor = new Color(0xff49454f);
  Color outlineTextColor = new Color(0xff49454f);
  Color outlineheaderColorForPass = new Color(0xff49454f);
  Color outlineTextColorForPass = new Color(0xff49454f);
  bool loginclickable = false;
  Color buttonBGColor =  Color(0xff0B6B94);
bool isLoading = false;
  @override
  void initState() {
    super.initState();



    // Initialize the fields with provided parameters if available
    if (widget.emailOrPhoneNumber != null) {
      mailEditingController.text = widget.emailOrPhoneNumber!;
      emailFieldListner();
    }
    if (widget.password != null) {
      passEditingController.text = widget.password!;
      passwordFieldListner();
    }

    // Automatically sign in if both fields are populated
    if (widget.emailOrPhoneNumber != null && widget.password != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _signIn();
      });
    }
  }

  void emailFieldListner() {
    if (mailEditingController.text.length > 0) {
      if (passEditingController.text.length > 0) {
        setState(() {
          buttonBGColor = Color(0xff0B6B94);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColor = Color(0xff0B6B94); // Change the button color to green
        outlineTextColor = Color(0xff0B6B94); // Change the button color to green
      });
    } else {
      setState(() {
        outlineheaderColor = Color(0xff49454f);
        outlineTextColor = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void passwordFieldListner() {
    if (passEditingController.text.length > 0) {
      if (mailEditingController.text.length > 0) {
        setState(() {
          buttonBGColor = Color(0xff0B6B94);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColorForPass = Color(0xff0B6B94); // Change the button color to green
        outlineTextColorForPass = Color(0xff0B6B94); // Change the button color to green
      });
    } else {
      setState(() {
        outlineheaderColorForPass = Color(0xff49454f);
        outlineTextColorForPass = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void signINButtonControler() {
    setState(() {
      buttonBGColor = Color(0xff0B6B94);
    });
  }



  Future<void> _signIn() async {
    if (mailEditingController.text.isEmpty && passEditingController.text.isEmpty) {
      return HelperClass.showToast("Enter details");
    }
    String phoneNumberOEmail = '';
    if (containsOnlyNumeric(mailEditingController.text)) {
      phoneNumberOEmail += CountryCodeSelector().selectedCountryCode + mailEditingController.text;
    } else {
      phoneNumberOEmail += mailEditingController.text;
    }
    print("Signin api info send");
    print(phoneNumberOEmail);
    print(passEditingController.text);
    setState(() {
      isLoading = true;
    });
    SignInApiModel? signInResponse = await SignInAPI().signIN(phoneNumberOEmail, passEditingController.text);
    print("signInResponse.accessToken");
    print(signInResponse?.refreshToken);
    print(signInResponse?.accessToken);
    if (signInResponse == null) {
      setState(() {
        passincorrect = true;
        isLoading = false;
      });
      HelperClass.showToast("Invalid Username or Password");
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(initialIndex: 0),
        ),
            (route) => false,
      );
      HelperClass.showToast("Sign in successful");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    return UpgradeAlert(
      upgrader: Upgrader(
        minAppVersion: '',
      ),
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Container(
                height: (orientation == Orientation.portrait) ? screenHeight - 37 : screenWidth,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                ),
                child: AutofillGroup(
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(16, 60, 0, 0),
                                    child: Text(
                                      "Sign in",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff000000),
                                        height: 30 / 24,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                                          height: 58,
                                          child: Container(
                                            child: Row(
                                              children: [
                                                // containsOnlyNumeric(mailEditingController.text)
                                                //     ? CountryCodeSelector()
                                                //     : Text(""),
                                                Expanded(
                                                  child: Semantics(
                                                    label: "Enter email or phone number",
                                                    child: ExcludeSemantics(
                                                      child: TextFormField(

                                                        cursorColor: Color(0xff0B6B94),
                                                        cursorErrorColor: Color(0xff0B6B94),
                                                        autofillHints: [AutofillHints.username],
                                                        focusNode: smallTextMailFocus,
                                                        controller: mailEditingController,

                                                        decoration: InputDecoration(
                                                          labelText: "Email or mobile number",
                                                          labelStyle: TextStyle(
                                                            fontFamily: "Roboto",
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            // color: Color(0xff0B6B94),
                                                           color: Color(0xff49454f),
                                                            height: 16/12,
                                                          ),
                                                          floatingLabelStyle: TextStyle(
                                                            fontFamily: "Roboto",
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            color: Color(0xff0B6B94),
                                                            //  color: Color(0xff49454f),
                                                            height: 16/12,
                                                          ),

                                                          hintStyle: TextStyle(
                                                            fontFamily: "Roboto",
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w400,
                                                            color: Color(0xff49454f),
                                                            height: 24/16,
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(6),
                                                              borderSide: BorderSide(
                                                                color: Color(0xff0B6B94),
                                                                width: 2,
                                                              )
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(6),
                                                            borderSide: BorderSide(
                                                              color: Colors.black,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          prefix: Text(prefixMailText),
                                                          // prefixIcon: containsOnlyNumeric(emailMobileText.text) ? CountryCodeSelector() : Container()
                                                        ),
                                                        onChanged: (text){
                                                          emailFieldListner();
                                                          if(containsOnlyNumeric(text)){
                                                            setState(() {
                                                              prefixMailText = "+91  ";
                                                            });
                                                          }else{
                                                            setState(() {
                                                              prefixMailText = "";
                                                            });
                                                          }
                                                        },

                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                                          height: 58,
                                          child: Container(
                                            width: double.infinity,
                                            height: 48,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Semantics(
                                                    label: "Enter password",
                                                    child: ExcludeSemantics(
                                                      child: TextFormField(
                                                        cursorColor: Color(0xff0B6B94),
                                                        autofillHints: [AutofillHints.password],
                                                        focusNode: smallTextPassFocus,
                                                        controller: passEditingController,
                                                        obscureText: obsecure,
                                                        decoration: InputDecoration(
                                                          labelText: "Password",
                                                          suffixIcon:  IconButton(
                                                              onPressed: (){
                                                                setState(() {
                                                                  hidden = !hidden;
                                                                  obsecure = !obsecure;
                                                                });

                                                              },
                                                              icon: hidden?Icon(Icons.visibility_off_outlined) : Icon(Icons.visibility_outlined)
                                                          ),
                                                          labelStyle: TextStyle(
                                                            fontFamily: "Roboto",
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            color: Color(0xff49454f),

                                                          ),
                                                          floatingLabelStyle: TextStyle(
                                                            fontFamily: "Roboto",
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            color: Color(0xff0B6B94),

                                                          ),
                                                          hintStyle: TextStyle(
                                                            fontFamily: "Roboto",
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w400,
                                                            color: Color(0xff49454f),

                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(6),
                                                              borderSide: BorderSide(
                                                                color: Color(0xff0B6B94),
                                                                width: 2,
                                                              )
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(6),
                                                            borderSide: BorderSide(
                                                              color: Colors.black,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          // prefixIcon: containsOnlyNumeric(emailMobileText.text) ? CountryCodeSelector() : Container()
                                                        ),
                                                        onChanged: (value) {
                                                          passwordFieldListner();
                                                          setState(() {
                                                            passincorrect = false;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Semantics(
                                                //   label: 'View Password',
                                                //   child: InkWell(
                                                //     onTap: () {
                                                //       showpassword();
                                                //     },
                                                //     child: Container(
                                                //       margin: EdgeInsets.only(right: 12),
                                                //       child: SvgPicture.asset(passvis),
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      passincorrect
                                          ? Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.fromLTRB(26, 0, 0, 0),
                                        child: Text(
                                          "Incorrect Details",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.red,
                                            height: 20 / 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                          : Container(),
                                      Spacer(),
                                      Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.fromLTRB(0, 8, 8, 0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ForgetPassword(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Forgot Password?",
                                            style:  TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff0B6B94),

                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 20, right: 16, left: 16),
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Color(0xff888686),
                                          backgroundColor: buttonBGColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: loginclickable ? _signIn : null,
                                        child: Center(
                                          child: !isLoading ? Text(
                                            'Sign in',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffffffff),
                                            ),
                                          ):Container(
                                              height: 20,
                                              width: 20,

                                              child: CircularProgressIndicator(
                                                backgroundColor: Colors.grey,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ExcludeSemantics(
                        child: Container(
                          margin: EdgeInsets.only(top: 20,),
                          child: Text(
                            "or",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff8d8c8c),
                              height: 25/16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: (){
                      //     signInWithGoogle();
                      //   },
                      //   child: Container(
                      //       margin: EdgeInsets.only(top: 20,left: 16,right: 16),
                      //       padding: EdgeInsets.only(left: 12),
                      //       width: double.infinity,
                      //       height: 48,
                      //       decoration: BoxDecoration(
                      //         border: Border.all(
                      //             color: Color(0xFFB3B3B3),width: 1),
                      //         color: Color(0xfffffff),
                      //         borderRadius: BorderRadius.circular(4),
                      //       ),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Container(
                      //             child: Image.asset("assets/image 6.png",height: 24,), // Replace "your_image.png" with your PNG image path
                      //           ),
                      //           Container(
                      //             margin: EdgeInsets.only(left: 20),
                      //             child: const Text(
                      //               "Sign in with google",
                      //               style: TextStyle(
                      //                 fontFamily: "Roboto",
                      //                 fontSize: 16,
                      //                 fontWeight: FontWeight.w400,
                      //                 color: Color(0xff000000),
                      //                 height: 25/16,
                      //               ),
                      //               textAlign: TextAlign.center,
                      //             ),
                      //           ),
                      //         ],
                      //       )),
                      // ),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUp(),
                            ),
                          );
                        },
                        child: Container(
                          // margin: EdgeInsets.only(top:20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  child: Text(
                                    "Don't have an account?",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 20/14,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                              ),
                              Container(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignUp(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Sign up",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 20/14,
                                        color: Color(0xff0B6B94),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
      ),
    );
  }
}
bool containsOnlyNumeric(String input) {
  // Regular expression to match the pattern of numeric characters
  RegExp regExp = RegExp(r'^[0-9]+$');
  return regExp.hasMatch(input);
}

String extractPhoneNumber(String countryCode, String fullPhoneNumber) {
  // Check if the fullPhoneNumber starts with the countryCode
  if (fullPhoneNumber.startsWith(countryCode)) {
    // Extract the phone number part without the countryCode
    return fullPhoneNumber.substring(countryCode.length).trim();
  } else {
    // If the fullPhoneNumber doesn't start with the countryCode, return the original fullPhoneNumber
    return fullPhoneNumber;
  }
}
class CountryCodeSelector extends StatefulWidget {
  @override
  _CountryCodeSelectorState createState() => _CountryCodeSelectorState();
  String get selectedCountryCode => _CountryCodeSelectorState()._selectedCountryCode;
//for update -> context.read(countryCodeProvider).state = '+1';

}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  String _selectedCountryCode = '+91';

  String get selectedCountryCode =>
      _selectedCountryCode; // Default country code



  void _showCountryCodePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Select Country Code'),
          content: Container(
            width: double.maxFinite,
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountryCode = newValue!;
                  });
                  Navigator.of(context).pop();
                },
                items: <String>['+91']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      width: 18,
      child: GestureDetector(
        onTap: () {
          //_showCountryCodePicker(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              _selectedCountryCode,
              style: TextStyle(fontSize: 17),
            ),
            //Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}


