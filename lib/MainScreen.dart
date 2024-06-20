import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/MapScreen.dart';
import '/RGCI/Screens/FavouriteRGCIScreen.dart';
import '/RGCI/Screens/QrScanner.dart';
import '/VenueSelectionScreen.dart';
import '/Navigation.dart';

import './RGCI/Screens/HomePage.dart';
import 'RGCI/Screens/ProfilePage.dart';
import 'FavouriteScreen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex=0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late int index;
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation()));
            } else {
              // Switch to the selected screen for other cases
              // if (index == 1) {
              //   // Open MapScreen in full screen
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
              // } else {
              //   // Switch to the selected screen for other cases
              //   this.index = index;
              // }
              this.index = index;
            }
          }),
          destinations: [
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff24B9B0),), label: 'Home',),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff24B9B0),), label: "Map",),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),width: 34,height: 34,), label: 'Scan',),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),), label: "Favourite",),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),), label: "Profile"),
          ],
        ),
      ),
    );
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

//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
// import '/MapScreen.dart';
// import '/RGCI/Screens/FavouriteRGCIScreen.dart';
// import '/RGCI/Screens/QrScanner.dart';
// import '/Navigation.dart';
//
// import './RGCI/Screens/HomePage.dart';
// import 'RGCI/Screens/ProfilePage.dart';
// import 'FavouriteScreen.dart';
//
// class MainScreen extends StatefulWidget {
//   final int initialIndex;
//
//   const MainScreen({super.key, this.initialIndex = 0});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   late PersistentTabController _controller;
//   ValueNotifier<bool> _showNavBar = ValueNotifier<bool>(true);
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = PersistentTabController(initialIndex: widget.initialIndex);
//   }
//
//   List<Widget> _buildScreens() {
//     return [
//       HomePage(),
//       Navigation(),
//       QRScannerScreen(),
//       FavouriteRGCIScreen(),
//       ProfilePage(),
//     ];
//   }
//
//   List<PersistentBottomNavBarItem> _navBarsItems() {
//     return [
//       PersistentBottomNavBarItem(
//         iconSize: 24,
//
//         icon: Icon(Icons.home_outlined),
//         inactiveIcon: Icon(Icons.home_outlined),
//
//         title: ("Home"),
//         activeColorPrimary: Color(0xff24B9B0),
//         inactiveColorPrimary: Color(0xff1C1B1F),
//       ),
//       PersistentBottomNavBarItem(
//         iconSize: 24,
//         icon: Icon(Icons.map_outlined),
//         inactiveIcon: Icon(Icons.map_outlined),
//
//         title: ("Map"),
//         activeColorPrimary: Color(0xff24B9B0),
//         inactiveColorPrimary: Color(0xff1C1B1F),
//       ),
//       PersistentBottomNavBarItem(
//         iconSize: 24,
//         icon: Icon(Icons.qr_code_scanner),
//         inactiveIcon: Icon(Icons.qr_code_scanner),
//
//         title: ("Scan"),
//         activeColorPrimary: Color(0xff24B9B0),
//         inactiveColorPrimary: Color(0xff1C1B1F),
//       ),
//       PersistentBottomNavBarItem(
//         iconSize: 24,
//         icon: Icon(Icons.bookmark_border),
//         inactiveIcon: Icon(Icons.bookmark_border),
//
//         title: ("Favourite"),
//         activeColorPrimary: Color(0xff24B9B0),
//         inactiveColorPrimary: Color(0xff1C1B1F),
//       ),
//       PersistentBottomNavBarItem(
//         iconSize: 24,
//         icon: Icon(Icons.person_2_outlined),
//         inactiveIcon: Icon(Icons.person_2_outlined),
//
//         title: ("Profile"),
//         activeColorPrimary: Color(0xff24B9B0),
//         inactiveColorPrimary: Color(0xff1C1B1F),
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//       valueListenable: _showNavBar,
//       builder: (context, showNavBar, child) {
//         return PersistentTabView(
//           context,
//           controller: _controller,
//           screens: _buildScreens(),
//           items: _navBarsItems(),
//           confineInSafeArea: true,
//           backgroundColor: Colors.white,
//           handleAndroidBackButtonPress: true,
//           resizeToAvoidBottomInset: true,
//           stateManagement: false,
//           hideNavigationBarWhenKeyboardShows: true,
//           decoration: NavBarDecoration(
//             borderRadius: BorderRadius.circular(10.0),
//             colorBehindNavBar: Colors.white,
//           ),
//           popAllScreensOnTapOfSelectedTab: true,
//           popActionScreens: PopActionScreensType.all,
//           itemAnimationProperties: ItemAnimationProperties(
//             duration: Duration(milliseconds: 200),
//             curve: Curves.ease,
//           ),
//           screenTransitionAnimation: ScreenTransitionAnimation(
//             animateTabTransition: true,
//             curve: Curves.ease,
//             duration: Duration(milliseconds: 200),
//           ),
//           navBarStyle: NavBarStyle.style3,
//           hideNavigationBar: !showNavBar,
//           onItemSelected: (index) {
//             setState(() {
//               if (index == 1) {
//                 _showNavBar.value = false;
//                 _controller.jumpToTab(index);
//               } else {
//                 _showNavBar.value = true;
//                 _controller.jumpToTab(index);
//               }
//             });
//           },
//         );
//       },
//     );
//   }
//
//   void showToast(String mssg) {
//     Fluttertoast.showToast(
//       msg: mssg,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.grey,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
// }
