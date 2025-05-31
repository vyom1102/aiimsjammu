import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/GlobalSearch.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:iwaymaps/websocket/UserLog.dart';
import 'package:iwaymaps/websocket/interactionManager.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/MapScreen.dart';
import '/AiimsJammu/Screens/FavouriteRGCIScreen.dart';
import '/AiimsJammu/Screens/QrScanner.dart';
import '/VenueSelectionScreen.dart';
import '/Navigation.dart';

import './AiimsJammu/Screens/HomePage.dart';
import 'API/buildingAllApi.dart';
import 'AiimsJammu/Screens/ProfilePage.dart';
import 'DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'DATABASE/BOXES/OutDoorModelBOX.dart';
import 'DATABASE/BOXES/PatchAPIModelBox.dart';
import 'DATABASE/BOXES/PolyLineAPIModelBOX.dart';
import 'DATABASE/BOXES/WayPointModelBOX.dart';
import 'FavouriteScreen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex=0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int index;
  final ws = wsocket("com.iwayplus.aiimsjammu");


  final screens = [
    HomePage(),
    GlobalSearchPage(voiceInputEnabled: false,frombottombar: true,),
    QRScannerScreen(),
    FavouriteRGCIScreen(),
    ProfilePage(),
  ];
  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
    setIDforWebSocket();
    print(index);
  }



  void setIDforWebSocket()async{
    final signInBox = await Hive.openBox('SignInDatabase');
    print("user id ${signInBox.get("userId")}");
    wsocket.message["userId"] = signInBox.get("userId");
  }

  Future<void> checkForUpdate() async {
    final newVersion = NewVersionPlus(
      androidId: 'com.iwayplus.aiimsjammu',
      iOSId: 'com.iwayplus.aiimsjammu',
    );
    try {
      final status = await newVersion.getVersionStatus();

      handleAppUpdate(status!.storeVersion,status!.localVersion);
    } catch (e) {
      print('Error checking for updates: $e');

    }
  }
  Future<void> handleAppUpdate(String currVersion, String localVersion) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Get current app version
    String currentVersion = currVersion;

    // Fetch stored version from preferences
    String? storedVersion = prefs.getString('appVersion')??localVersion;

    // Check if the app was updated (if stored version is different from the current version)
    print(storedVersion);
    bool hasHandledUpdate = prefs.getBool('hasHandledUpdate') ?? false;

    if (!hasHandledUpdate) {
      print("entereddd");
      // App has been updated - run your reset logic
      final BeaconBox = BeaconAPIModelBOX.getData();
      final BuildingAllBox = BuildingAllAPIModelBOX.getData();
      final LandMarkBox = LandMarkApiModelBox.getData();
      final PatchBox = PatchAPIModelBox.getData();
      final PolyLineBox = PolylineAPIModelBOX.getData();
      final WayPointBox = WayPointModeBOX.getData();
      final OutBuildingBox = OutDoorModeBOX.getData();
      BeaconBox.clear();
      BuildingAllBox.clear();
      LandMarkBox.clear();
      PatchBox.clear();
      PolyLineBox.clear();
      WayPointBox.clear();
      OutBuildingBox.clear();
      print("clearedafterupdate");
      //showToast("Database Cleared ${BeaconBox.length},${BuildingAllBox.length},${LandMarkBox.length},${PatchBox.length},${PolyLineBox.length},${WayPointBox.length},${OutBuildingBox.length}");

      await resetBluetooth();  // Reset Bluetooth adapter or any other necessary reset logic

      // Mark that the update has been handled to avoid running the reset again
      await prefs.setBool('hasHandledUpdate', true);
      // Update the stored version to the current version
      await prefs.setString('appVersion', currentVersion);


    }
  }
  Future<void> resetBluetooth() async {
    // Turn Bluetooth off
    try {
      await FlutterBluePlus.turnOff().timeout(Duration(seconds: 20)); // Increased timeout to 20s
    } catch (e) {
      print('Failed to turn off Bluetooth: $e');
    }
    // Turn Bluetooth on after a short delay
    await Future.delayed(Duration(seconds: 2));
    await FlutterBluePlus.turnOn();
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

          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: Offset(0, -2), // Negative y-offset for shadow above
                ),
              ],
            ),
            child: NavigationBar(
              surfaceTintColor: Colors.white,
              backgroundColor: Color(0xffFFFFFF),
              selectedIndex: index,
              onDestinationSelected: (index)=>setState(() {

                if(index==0){
                  InteractionManager().logInteraction("Home Button");
                }else if(index==1){
                  InteractionManager().logInteraction("Global Search");
                }else if(index==2){
                  InteractionManager().logInteraction("Scan Button");
                }else if(index==3){
                  InteractionManager().logInteraction("Favourite Button");
                }else if(index==4){
                  InteractionManager().logInteraction("Profile Button");
                }
                // if (index==1){
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => GlobalSearchPage(voiceInputEnabled: false)));
                //
                // } else {
                  this.index = index;
                  print(index);
                // }
              }),
              destinations: [
                NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xFF0B6B94),), label: 'Home',),
                NavigationDestination(icon: SvgPicture.asset("assets/images/searchicon.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/images/searchicon.svg",color: Color(0xFF0B6B94),), label: "Search",),
                NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xFF0B6B94),width: 34,height: 34,), label: 'Scan',),
                NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xFF0B6B94),), label: "Favourite",),
                NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xFF0B6B94),), label: "Profile"),
              ],
            ),
          ),
        ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'mainscreen',

            onPressed: (){
              if(true){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Navigation(),
                  ),
                );
              }else{
                HelperClass.showToast("Not at the current venue");
              }

            },
            backgroundColor: Color(0xFFFEAB01),
            shape: CircleBorder(),
            child: Semantics(
                label: "Map",
                child: Lottie.asset('assets/images/floatingmap.json')),
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

