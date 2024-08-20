import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '/MapScreen.dart';
import '/AiimsJammu/Screens/FavouriteRGCIScreen.dart';
import '/AiimsJammu/Screens/QrScanner.dart';
import '/VenueSelectionScreen.dart';
import '/Navigation.dart';

import './AiimsJammu/Screens/HomePage.dart';
import 'AiimsJammu/Screens/ProfilePage.dart';
import 'FavouriteScreen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex=0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late int index;
  bool isLocating=false;
  final screens = [
    HomePage(),
    Navigation(),
    QRScannerScreen(),
    FavouriteRGCIScreen(),
    ProfilePage(),
  ];
  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
    getLocs();
    print(index);
  }

  Position? userLoc;
  void getLocs()async{
    setState(() {
      isLocating=true;
    });
    userLoc= await getUsersCurrentLatLng();
    if(mounted){
      setState(() {
        isLocating=false;
      });
    }

print("userLoc");
    print(userLoc);
    UserState.geoFenced=await HelperClass.getGeoFenced("AIIMSJAMMU", userLoc!);

  }

  Future<Position?> getUsersCurrentLatLng()async{

    if (await Permission.location.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return position;

    }
    else{
      Position pos=Position(longitude: 77.1852061, latitude:  28.5436197, timestamp: DateTime.now(), accuracy: 100, altitude: 1, altitudeAccuracy: 100, heading: 10, headingAccuracy: 100, speed: 100, speedAccuracy: 100);
      return pos;
    }

  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (index == 0) {
          final shouldPop = await showExitAlert(context);
          if (shouldPop) {
            SystemNavigator.pop();
          }
        } else {
          setState(() {
            index = 0;
          });
        }
      },
      child: Scaffold(
        body: screens[index],
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.transparent,
            labelTextStyle: MaterialStateProperty.all(TextStyle(
              fontFamily: "Roboto",
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xff4B4B4B),
              height: 20/14,
            )),
          ),

          child: NavigationBar(
            backgroundColor: Color(0xffFFFFFF),
            selectedIndex: index,
            onDestinationSelected: (index)=>setState(() {
              if (index==1 ){
                if(UserState.geoFenced!=3){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation()));
                }else{
                  HelperClass.showToast("This map preview is not available at your location");
                }

              } else {

                this.index = index;
                print(index);
              }
            }),
            destinations: [
              NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff24B9B0),), label: 'Home',),
              NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff24B9B0),), label: "Map",),
              NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff24B9B0),width: 34,height: 34,), label: 'Scan',),
              NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff24B9B0),), label: "Favourite",),
              NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff24B9B0),), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showExitAlert(BuildContext context) async {
    bool? exit = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Exit App',
      text: 'Do you really want to exit?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        Navigator.of(context).pop(true);
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop(false);
      },
    );
    return exit ?? false;
  }
  void showToast(String mssg) {
    Fluttertoast.showToast(
      msg: mssg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

