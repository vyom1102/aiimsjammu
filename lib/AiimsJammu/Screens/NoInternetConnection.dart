import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../Widgets/Translator.dart';

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection> {
  bool isConnectedToInternet =true;
  StreamSubscription? _internetConnection;
  bool _isLoading = false;

  void _showProgressIndicator() {
    setState(() {
      _isLoading = true;
    });

    Timer(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  @override
  void initState() {
    _internetConnection = InternetConnection().onStatusChange.listen((event) {
      switch(event){
        case InternetStatus.connected:
          Navigator.pop(context);
        default:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
      }
    });
    super.initState();
  }
  @override
  void dispose() {
  _internetConnection?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/no-connection 1.png',
                width:70,
                height: 70,
              ),
              SizedBox(height: 20,),
              TranslatorWidget(
                'No Internet connection',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 60),
                child: TranslatorWidget(
                  'Please check your internet connection and try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 24,),
              ElevatedButton(
                  style: ElevatedButton
                      .styleFrom(
                    minimumSize: Size(120.0, 25.0),
                    backgroundColor:
                    Color(0xFF0B6B94),
                    padding: EdgeInsets
                        .symmetric(
                        vertical: 8),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(4),
                    ),
                  ),
                  onPressed:_showProgressIndicator
                  , child: TranslatorWidget(
                'Try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,

                ),
              )),
              if (_isLoading)
                CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
