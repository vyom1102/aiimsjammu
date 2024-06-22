import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/SignIn.dart';
import 'dart:math';

import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart' as lot;
import '../Elements/HelperClass.dart';
import '../MainScreen.dart';
import 'CreateNewPassword.dart';
import 'LOGIN SIGNUP APIS/APIS/SignUpAPI.dart';

class VerifyYourAccount extends StatefulWidget {
  final String previousScreen;
  final String userEmailOrPhone;
  final String userName;
  final String userPasword;

  const VerifyYourAccount({required this.previousScreen,this.userEmailOrPhone='',this.userName='',this.userPasword=''});

  @override
  State<VerifyYourAccount> createState() => _VerifyYourAccountState();
}

class _VerifyYourAccountState extends State<VerifyYourAccount> {
  String finalSendingEmailORPhone = "";


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

  TextEditingController OTPEditingController = TextEditingController();


  Color button1 = new Color(0xff777777);
  Color text1 = new Color(0xff777777);

  Color outlineheaderColor = new Color(0xff49454f);
  Color outlineTextColor = new Color(0xff49454f);

  Color outlineheaderColorForPass = new Color(0xff49454f);
  Color outlineTextColorForPass = new Color(0xff49454f);



  bool loginclickable = false;
  Color buttonBGColor = new Color(0xff24b9b0);

  Color outlineheaderColorForName = new Color(0xff49454f);
  Color outlineTextColorForName = new Color(0xff49454f);




  void OTPFieldListner(){
    if(OTPEditingController.text.length>0){
      if(OTPEditingController.text.length>0){
        setState(() {
          buttonBGColor = Color(0xff24b9b0);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColor = Color(0xff24b9b0);// Change the button color to green
        outlineTextColor = Color(0xff24b9b0);// Change the button color to green
      });
    }else{
      setState(() {
        outlineheaderColor = Color(0xff49454f);
        outlineTextColor = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }
  int timeLeft = 59;



  @override
  void initState() {
    super.initState();
    startCountDown(); // Call startCountDown() when the widget is initialized
  }
  void startCountDown(){
    Timer.periodic(Duration(seconds: 1), (timer) {
      if(timeLeft>0) {
        setState(() {
          timeLeft--;
        });
      }else{
        timer.cancel();
      }
    });
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    try {
      // Try parsing the string into a double
      double.parse(str);
      // If parsing succeeds, return true
      return true;
    } catch (e) {
      // If parsing fails, return false
      return false;
    }
  }



  void _onFocusChange() {
    if (_focusNode1.hasFocus) {
      setState(() {
        phoneEditingController.clear();
      });
    } else if (_focusNode2.hasFocus || _focusNode1_1.hasFocus) {
      setState(() {
        OTPEditingController.clear();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;

    if(isNumeric(widget.userEmailOrPhone)){
      finalSendingEmailORPhone = "+91${widget.userEmailOrPhone}";
    }else{
      finalSendingEmailORPhone = widget.userEmailOrPhone;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Semantics(
              label: "Back",
              child: Icon(Icons.arrow_back)),
        ),
      ),
      body: Stack(
          children: [SafeArea(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Container(
                height: (orientation == Orientation.portrait)
                    ? screenHeight-37
                    : screenWidth,
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
                                Semantics(
                                  label: "Verify your account, 60 seconds left",
                                  child: ExcludeSemantics(
                                    child: GestureDetector(
                                      onTap: (){
                                        startCountDown();
                                      },
                                      child: Container(
                                          margin: EdgeInsets.fromLTRB(16, 11, 0, 0),
                                          width: double.infinity,
                                          child: Text(
                                            "Verify Your Account",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xff000000),
                                              height: 30/24,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                      ),
                                    ),
                                  ),
                                ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0,left: 16,right: 16),
                              child: Text(
                                            "Please enter the verification code we’ve sent you on ${finalSendingEmailORPhone}",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff242323),
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                            ),

                                // Container(
                                //   margin: EdgeInsets.only(left: 16,top: 8,right: 16),
                                //   width: screenWidth,
                                //   child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Flexible(
                                //         child: Container(
                                //           child: Text(
                                //             "Please enter the verification code we’ve sent you on ${finalSendingEmailORPhone}",
                                //             style: const TextStyle(
                                //               fontFamily: "Roboto",
                                //               fontSize: 16,
                                //               fontWeight: FontWeight.w400,
                                //               color: Color(0xff242323),
                                //             ),
                                //             textAlign: TextAlign.left,
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                Container(
                                    margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                                    height: 58,
                                    width: double.infinity,

                                    child: Semantics(
                                      label: "Enter 4 digit OTP",
                                      child: ExcludeSemantics(
                                        child: TextFormField(


                                          focusNode: _focusNode1,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly,

                                          ],
                                          controller: OTPEditingController,
                                          decoration: InputDecoration(
                                              labelText: 'OTP',
                                              labelStyle: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
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
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                  borderSide: BorderSide(
                                                    color: Color(0xff24b9b0),
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
                                              border: InputBorder.none
                                          ),
                                          onChanged: (value) {
                                            OTPFieldListner();

                                            outlineheaderColorForPass = new Color(0xff49454f);
                                            outlineheaderColorForName = new Color(0xff49454f);
                                          },
                                        ),
                                      ),
                                    )
                                ),
                                ExcludeSemantics(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 32,top: 4),
                                    child: Text(
                                      "Enter your 4-digit otp here",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff49454f),
                                        height: 16/12,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: 4,right: 26),
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Text(
                                        timeLeft==0? 'Try Again': '00:${timeLeft.toString()}',
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff000000),
                                          height: 23/16,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  )
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 20,right: 16,left: 16),
                                    child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Color(0xff777777), backgroundColor: buttonBGColor,                                          // Text color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  4.0), // Button border radius
                                            ),
                                            elevation: 0,
                                          ),
                                          // onPressed: loginclickable ? login : null,
                                          onPressed: () async {
                                              if(widget.previousScreen=='ForgetPassword' && OTPEditingController.text.length==4){
                                                print("sending");
                                                print(finalSendingEmailORPhone);
                                                print(widget.userEmailOrPhone);
                                                print(widget.userName);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CreateNewPassword(otp: (OTPEditingController.text.isNotEmpty)?OTPEditingController.text:'', user: finalSendingEmailORPhone)
                                                  ),
                                                );
                                              }else if(OTPEditingController.text.isEmpty || OTPEditingController.text.length<4){
                                                HelperClass.showToast("Enter 4 Digit OTP");
                                              }
                                              else{

                                                  if(await SignUpAPI().signUP(finalSendingEmailORPhone, widget.userName, widget.userPasword, OTPEditingController.text)){
                                                    Navigator.pushAndRemoveUntil(context,
                                                      MaterialPageRoute(
                                                        builder: (context) => SignIn(emailOrPhoneNumber: widget.userEmailOrPhone,password: widget.userPasword,)
                                                      ),(route) => false,
                                                    );
                                                  }else{

                                                  }
                                              }
                                            },
                                          child: Center(
                                            child:
                                            Text(
                                              'Verify OTP',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xffffffff),
                                              ),
                                            ),
                                          ),
                                        ))
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )]
      ),
    );
  }
}
