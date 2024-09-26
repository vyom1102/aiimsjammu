


import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'dart:math';
import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart' as lot;
import '../Elements/HelperClass.dart';
import '../MainScreen.dart';
import 'LOGIN SIGNUP APIS/APIS/SendOTPAPI.dart';
import 'SignIn.dart';
import 'VerifyYourAccount.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FocusNode emailFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode cnfPasswordFocus = FocusNode();




  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode2_1 = FocusNode();
  FocusNode _focusNode1_1 = FocusNode();
  bool otpenalbed = false;
  bool loginapifetching = false;
  bool loginapifetching2 = false;

  bool subotpclickable = false;
  bool passincorrect = false;
  bool otpincorrect = false;
  Random random = Random();
  // userdata uobj = new userdata();
  bool ispassempty = true;

  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController OTPEditingController = TextEditingController();
  String passvis = 'assets/LoginScreen_PasswordEye.svg';
  bool obsecure = true;
  //CountryCode _defaultCountry = CountryCode.fromCountryCode('US');

  Color buttonColor2 = Color(0xffbdbdbd);
  Color textColor = Color(0xff777777);
  Color textColor2 = Color(0xff777777);
  String phoneNumber = '';
  String code = '';

  String initialCountry = 'IN';
  // PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String initialCountry2 = 'IN';
  // PhoneNumber number2 = PhoneNumber(isoCode: 'IN');

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  String prefixMailText = "";



  TextEditingController passEditingController = TextEditingController();
  TextEditingController mailEditingController = TextEditingController();
  TextEditingController nameEditingController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();

  bool _obscureText = true;

  Color button1 = new Color(0xff777777);
  Color text1 = new Color(0xff777777);

  Color outlineheaderColor = new Color(0xff49454f);
  Color outlineTextColor = new Color(0xff49454f);

  Color outlineheaderColorForPass = new Color(0xff49454f);
  Color outlineTextColorForPass = new Color(0xff49454f);

  bool loginclickable = false;
  Color buttonBGColor = new Color(0xff49454f);

  Color outlineheaderColorForName = new Color(0xff49454f);
  Color outlineTextColorForName = new Color(0xff49454f);



  final TextEditingController confirmPassEditingController = TextEditingController();


  final FocusNode _focusNode1_2 = FocusNode();

  bool _obscureTextConfirm = true;

  void nameFiledListner() {
    if (nameEditingController.text.length > 0) {
      if (mailEditingController.text.length > 0 &&
          passEditingController.text.length > 0) {
        setState(() {
          buttonBGColor = Color(0xff0B6B94);
        });
      }
      setState(() {
        outlineheaderColorForName =
            Color(0xff0B6B94); // Change the button color to green
        outlineTextColorForName =
            Color(0xff0B6B94); // Change the button color to green
      });
    } else {
      setState(() {
        outlineheaderColorForName = Color(0xff49454f);
        outlineTextColorForName = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void emailFieldListner() {
    if (mailEditingController.text.length > 0) {
      if (passEditingController.text.length > 0 &&
          nameEditingController.text.length > 0) {
        setState(() {
          buttonBGColor = Color(0xff0B6B94);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColor =
            Color(0xff0B6B94); // Change the button color to green
        outlineTextColor =
            Color(0xff0B6B94); // Change the button color to green
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
      if (mailEditingController.text.length > 0 &&
          nameEditingController.text.length > 0) {
        setState(() {
          buttonBGColor = Color(0xff0B6B94);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColorForPass =
            Color(0xff0B6B94); // Change the button color to green
        outlineTextColorForPass =
            Color(0xff0B6B94); // Change the button color to green
      });
    } else {
      setState(() {
        outlineheaderColorForPass = Color(0xff49454f);
        outlineTextColorForPass = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void showpassword() {
    setState(() {
      obsecure = !obsecure;
      obsecure
          ? passvis = "assets/passnotvis.svg"
          : passvis = "assets/passvis.svg";
    });
  }

  @override
  void initstate() {
    super.initState();


    // _focusNode1.addListener(_onFocusChange);
    // emailFocus.addListener(() {
    //   setState(() {
    //
    //   });
    // });
    // _focusNode2.addListener(_onFocusChange);
    // _focusNode1_1.addListener(_onFocusChange);
    // _focusNode2_1.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode1.hasFocus) {
      setState(() {
        phoneEditingController.clear();
      });
    } else if (_focusNode2.hasFocus || _focusNode1_1.hasFocus) {
      setState(() {
        mailEditingController.clear();
        passEditingController.clear();
      });
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<bool> checkUserExists(String username) async {
    var headers = {
      'X-Api-Key': '1D7A90DA-69EE-4D86-BF6D-90A24DFF1193',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST', Uri.parse('https://dev.iwayplus.in/auth/username'));
    request.body = json.encode({"username": username});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      print('---response---');
      print(jsonResponse);
      return jsonResponse[
      'userExist'];

    } else {
      throw Exception(
          'Failed to check user existence: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Semantics(label: "Back", child: Icon(Icons.arrow_back)),
        ),
      ),
      body: Stack(children: [
        SafeArea(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Container(
                height: (orientation == Orientation.portrait) ? screenHeight - 37 : screenWidth,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                ),
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
                                  margin: EdgeInsets.fromLTRB(16, 11, 0, 0),
                                  width: double.infinity,
                                  child: Text(
                                    "Sign Up",
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
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                                      height: 58,
                                      child: Container(
                                        // padding: EdgeInsets.only(left: 12),
                                        width: double.infinity,
                                        // decoration: BoxDecoration(
                                        //   border: Border.all(color: outlineheaderColor, width: 2),
                                        //   color: Color(0xfffffff),
                                        //   borderRadius: BorderRadius.circular(4),
                                        // ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Semantics(
                                                label: "Enter Email or mobile number",
                                                child: ExcludeSemantics(
                                                  child: TextFormField(
                                                    focusNode: emailFocus,
                                                    controller: mailEditingController,

                                                    decoration: InputDecoration(
                                                      labelText: "Email or mobile number",
                                                      labelStyle: TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xff49454f),
                                                        height: 16/12,
                                                      ),
                                                      floatingLabelStyle: TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xff0B6B94),
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

                                  ]


                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                                  height: 58,
                                  child: Container(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Semantics(
                                            label: "Enter your name",
                                            child: ExcludeSemantics(
                                              child: TextFormField(
                                                focusNode: nameFocus,
                                                controller: nameEditingController,
                                                decoration: InputDecoration(
                                                  labelText: "Name",
                                                  labelStyle: TextStyle(
                                                  fontFamily: "Roboto",
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                    color: Color(0xff49454f),
                                                  height: 16/12,
                                                ),
                                                  hintStyle: TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff49454f),
                                                    height: 24/16,
                                                  ),
                                                  floatingLabelStyle: TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff0B6B94),
                                                    height: 16/12,
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
                                                  nameFiledListner();
                                                  setState(() {
                                                    outlineheaderColorForPass = new Color(0xff49454f);
                                                    outlineheaderColor = new Color(0xff49454f);
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                                  height: 58,
                                  child: Container(
                                    width: double.infinity,
                                    height: 48,

                                    child: Container(
                                      child: Semantics(
                                        label: "Enter your password",
                                        child: ExcludeSemantics(
                                          child: TextField(
                                            focusNode: passwordFocus,
                                            controller: passEditingController,
                                            obscureText: _obscureText,
                                            decoration: InputDecoration(
                                              labelText: "Password",
                                              labelStyle: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff49454f),
                                                height: 16/12,
                                              ),
                                              floatingLabelStyle: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff0B6B94),
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
                                              border: InputBorder.none,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureText = !_obscureText; // Toggle show/hide password
                                                  });
                                                },
                                              ),
                                            ),
                                            onChanged: (value) {
                                              passwordFieldListner();
                                              setState(() {
                                                outlineheaderColorForName = new Color(0xff49454f);
                                                outlineheaderColor = new Color(0xff49454f);
                                                passincorrect = false;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                passEditingController.text.length < 8
                                    ? ExcludeSemantics(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 30, top: 4),
                                    child: Text(
                                      "8 characters password required.",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xffB3261E),
                                        height: 16 / 12,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                )
                                    : Container(),
                                Container(
                                  margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                                  height: 58,
                                  child: Container(
                                    width: double.infinity,
                                    height: 48,

                                    child: Container(
                                      child: Semantics(
                                        label: "Confirm your password",
                                        child: ExcludeSemantics(
                                          child: TextField(
                                            focusNode: cnfPasswordFocus,
                                            controller: confirmPassEditingController,
                                            obscureText: _obscureTextConfirm,
                                            decoration: InputDecoration(
                                              labelText: "Confirm Password",
                                              labelStyle: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff49454f),
                                                height: 16/12,
                                              ),
                                              floatingLabelStyle: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff0B6B94),
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
                                              border: InputBorder.none,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureTextConfirm ? Icons.visibility_off : Icons.visibility,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureTextConfirm = !_obscureTextConfirm; // Toggle show/hide password
                                                  });
                                                },
                                              ),
                                            ),
                                            onChanged: (value) {
                                              confirmPasswordFieldListener();
                                              setState(() {
                                                outlineheaderColorForName = new Color(0xff49454f);
                                                outlineheaderColor = new Color(0xff49454f);
                                                passincorrect = false;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                confirmPassEditingController.text != passEditingController.text
                                    ? ExcludeSemantics(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 32, top: 4),
                                    child: Text(
                                      "Passwords do not match.",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xffB3261E),
                                        height: 16 / 12,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                )
                                    : Container(),
                                Container(
                                  margin: EdgeInsets.only(top: 20, right: 16, left: 16),
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Color(0xff777777),
                                        backgroundColor: buttonBGColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        elevation: 0,
                                      ),

                                      onPressed: () async {
                                        if (mailEditingController.text.isNotEmpty &&
                                            nameEditingController.text.isNotEmpty &&
                                            passEditingController.text.isNotEmpty &&
                                            confirmPassEditingController.text.isNotEmpty) {
                                          if (passEditingController.text.length >= 8) {
                                            if (passEditingController.text == confirmPassEditingController.text) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return Center(child: CircularProgressIndicator());
                                                },
                                              );

                                              String finalMailEditingController = '';
                                              if (containsOnlyNumeric(mailEditingController.text)) {
                                                finalMailEditingController = "+91${mailEditingController.text}";
                                              } else {
                                                finalMailEditingController = mailEditingController.text;
                                              }

                                              try {
                                                print("checking phone number");
                                                print(finalMailEditingController);


                                                bool userExists = await checkUserExists(finalMailEditingController);
                                                if(!userExists){
                                                  bool otpSent = await SendOTPAPI().sendOTP(finalMailEditingController);
                                                  if (!otpSent) {
                                                    HelperClass.showToast("Invalid email");
                                                    Navigator.of(context).pop(); // Dismiss the loading dialog
                                                    return; // Exit the function
                                                  }
                                                }

                                                Navigator.of(context).pop(); // Dismiss the loading dialog

                                                if (containsOnlyNumeric(mailEditingController.text)) {
                                                  if (mailEditingController.text.length != 10) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      type: QuickAlertType.error,
                                                      title: 'Error',
                                                      text: 'Incorrect phone number entered',
                                                      confirmBtnText: 'OK',
                                                    );
                                                  } else if (userExists) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      type: QuickAlertType.error,
                                                      title: 'Error',
                                                      text: 'User already exists. Please use a different phone number.',
                                                      confirmBtnText: 'OK',
                                                      onConfirmBtnTap: () {
                                                        Navigator.pop(context);
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => SignIn(
                                                              emailOrPhoneNumber: mailEditingController.text,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                  else{
                                                    bool otpSent = await SendOTPAPI().sendOTP(finalMailEditingController);

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => VerifyYourAccount(
                                                          previousScreen: 'SignUp',
                                                          userEmailOrPhone: mailEditingController.text,
                                                          userName: nameEditingController.text,
                                                          userPasword: passEditingController.text,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } else if (userExists) {
                                                  QuickAlert.show(
                                                    context: context,
                                                    type: QuickAlertType.error,
                                                    title: 'Error',
                                                    text: 'User already exists. Please use a different email address.',
                                                    confirmBtnText: 'OK',
                                                    onConfirmBtnTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => SignIn(
                                                            emailOrPhoneNumber: mailEditingController.text,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  bool otpSent = await SendOTPAPI().sendOTP(finalMailEditingController);

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => VerifyYourAccount(
                                                        previousScreen: 'SignUp',
                                                        userEmailOrPhone: mailEditingController.text,
                                                        userName: nameEditingController.text,
                                                        userPasword: passEditingController.text,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (error) {
                                                Navigator.of(context).pop(); // Dismiss the loading dialog
                                                print(error);
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Error"),
                                                      content: Text('An error occurred while checking user existence. Please try again.'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text('OK'),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            } else {
                                              HelperClass.showToast("Passwords do not match.");
                                            }
                                          } else {
                                            HelperClass.showToast("Password should be of 8 characters");
                                          }
                                        } else {
                                          HelperClass.showToast("Please provide all required fields");
                                        }
                                      },

                                      child: Center(
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xffffffff),
                                          ),
                                        ),
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
                  ],
                ),
              ),
            )

        )
      ]),
    );
  }

  void confirmPasswordFieldListener() {
    if(passEditingController.text == confirmPassEditingController.text){

    }
  }
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

