
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:iwaymaps/websocket/UserLog.dart';
import 'package:iwaymaps/websocket/interactionManager.dart';
import 'package:iwaymaps/websocket/navigationLogManager.dart';
import 'package:iwaymaps/websocket/sessionManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '/localization/locales.dart';
import 'API/buildingAllApi.dart';
import 'AiimsJammu/Screens/DoctorProfile1.dart';
import 'AiimsJammu/Screens/ServiceInfo1.dart';
import 'AiimsJammu/Screens/SplashScreen.dart';
import 'AiimsJammu/Widgets/WebSocketDriver.dart';
import 'DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import 'DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import 'DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import 'DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import 'DATABASE/DATABASEMODEL/GlobalAnnotationAPIModel.dart';
import 'DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import 'DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';
import 'DATABASE/DATABASEMODEL/OutDoorModel.dart';
import 'DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import 'DATABASE/DATABASEMODEL/WayPointModel.dart';
import 'Elements/deeplinks.dart';
import 'LOGIN SIGNUP/SignIn.dart';
import 'MainScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'config.dart';

final interactionManager = InteractionManager();
final sessionManager = SessionManager();
final navigationManager=NavigationLogManager();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(LandMarkApiModelAdapter());
  await Hive.openBox<LandMarkApiModel>('LandMarkApiModelFile'); //LandMarkApiModelFile name ke ek file bn rhi hy and usme LandMarkApiModelFile type ke object store ho rhe hy
  Hive.registerAdapter(PatchAPIModelAdapter());
  await Hive.openBox<PatchAPIModel>('PatchAPIModelFile');
  Hive.registerAdapter(PolyLineAPIModelAdapter());
  await Hive.openBox<PolyLineAPIModel>("PolyLineAPIModelFile");
  Hive.registerAdapter(BuildingAllAPIModelAdapter());
  await Hive.openBox<BuildingAllAPIModel>("BuildingAllAPIModelFile");
  Hive.registerAdapter(FavouriteDataBaseModelAdapter());
  await Hive.openBox<FavouriteDataBaseModel>("FavouriteDataBaseModelFile");
  Hive.registerAdapter(BeaconAPIModelAdapter());
  await Hive.openBox<BeaconAPIModel>('BeaconAPIModelFile');
  Hive.registerAdapter(BuildingAPIModelAdapter());
  await Hive.openBox<BuildingAPIModel>('BuildingAPIModelFile');
  Hive.registerAdapter(OutDoorModelAdapter());
  await Hive.openBox<OutDoorModel>('OutDoorModelFile');
  Hive.registerAdapter(WayPointModelAdapter());
  await Hive.openBox<WayPointModel>('WayPointModelFile');
  Hive.registerAdapter(DataVersionLocalModelAdapter());
  await Hive.openBox<DataVersionLocalModel>('DataVersionLocalModelFile');
  Hive.registerAdapter(LocalNotificationAPIDatabaseModelAdapter());
  await Hive.openBox<LocalNotificationAPIDatabaseModel>('LocalNotificationAPIDatabaseModel');
  Hive.registerAdapter(GlobalAnnotationAPIModelAdapter());
  await Hive.openBox<GlobalAnnotationAPIModel>('GlobalAnnotationAPIModelFile');

  await interactionManager.initialize();
  await sessionManager.initialize();
  await navigationManager.initialize();

  await Hive.openBox('Favourites');
  await Hive.openBox('UserInformation');

  // await Firebase.initializeApp();

  // await Hive.openBox('Favourites');
  await Hive.openBox('DashboardList');

  await Hive.openBox('Filters');
  await Hive.openBox('SignInDatabase');
  await Hive.openBox('LocationPermission');
  await Hive.openBox('VersionData');
  await Hive.openBox('user');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  var signInDatabaseBox = Hive.box('SignInDatabase');
  if (signInDatabaseBox.containsKey("accessToken")) {
    await buildingAllApi().fetchBuildingAllData().then((value){
      buildingAllApi.findBuildings(value);
    });
  }


  WakelockPlus.enable();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  late String googleSignInUserName='';
  final FlutterLocalization localization = FlutterLocalization.instance;
  late AppLinks _appLinks;
  String? _accessToken;
  String? initialDocId;
  String? initialServiceId;
  bool isLocating=false;
  late io.Socket _socket;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    SessionManager().startSession();
    configureLocalization();
    // _initializeSocket();
    //  LocationTrackingService().initialize();
    // LocationTrackingService().startTracking();

    // _initDeepLinkListener();

    super.initState();
  }


  void _initDeepLinkListener(BuildContext c) async {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri? uri) {
        Deeplink.deeplinkConditions(uri, c).then((v){
          setState(() {
            initialDocId = Deeplink.initialDocId;
            initialServiceId=Deeplink.initialServiceId;
            _accessToken=Deeplink.accessToken;
          });
        });
    });
  }
  void configureLocalization(){
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');
    localization.onTranslatedLanguage = ontranslatedLanguage;
  }


  void _initializeSocket() {
    _socket = io.io(AppConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true, // Automatically connects on app start
      'reconnection': true, // Enables auto-reconnect
      'reconnectionAttempts': 5, // Tries reconnecting 5 times
      'reconnectionDelay': 2000, // 2s delay between retries
    });

    _socket.onConnect((_) async {
      print('✅ Connected to WebSocket Server in main.dart');
      // sendMessage();
      await LocationTrackingService().initialize();

      LocationTrackingService().startTracking();
    });

    _socket.onDisconnect((_) => print('⚠️ Disconnected from WebSocket Server main.dart'));
    _socket.onError((data) => print('❌ WebSocket Error main.dart : $data'));
    _socket.onReconnect((_) => print('🔄 Reconnecting...'));

     }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App went to background
      print("App is in the background");
      InteractionManager().syncLogsToServer("");
      SessionManager().endSession();
      NavigationLogManager().syncLogsToServer();
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground
      print("App is in the foreground");
    }
  }

  void ontranslatedLanguage(Locale? locale){
    setState(() {

    });
  }
  var locBox=Hive.box('LocationPermission');
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    print(status);

    await locBox.put('location', (status.isGranted)?true:false);
    if (status.isGranted){

      print('location permission granted');



    } else if(status.isPermanentlyDenied) {
      print('location permission is permanently granted');
    }else{
      print("location permission is granted");
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isIOS = Platform.isIOS;
    bool isAndroid = Platform.isAndroid;
    if(isIOS){
      print("IOS");
    }else if(isAndroid){
      print("Android");
    }
    requestLocationPermission();
    return MaterialApp(
      title: "IWAYPLUS",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xff0B6B94), // Change cursor color
          selectionColor: Colors.greenAccent.withOpacity(0.5), // Change selection color
          selectionHandleColor: Color(0xff0B6B94), // Change selection handle color
        ),
      ),
      home: FutureBuilder<bool>(
        future: null,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final bool isUserAuthenticated = snapshot.data ?? false;

          if (!isUserAuthenticated) {
            var signInDatabaseBox = Hive.box('SignInDatabase');
            if (!signInDatabaseBox.containsKey("accessToken")) {
              return SplashScreen();
            } else {
              _initDeepLinkListener(context);
              if (initialDocId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamed(context, '/doctor/$initialDocId');
                });
                return MainScreen(initialIndex: 0);
              } else if (initialServiceId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamed(context, '/service/$initialServiceId');
                });
                return MainScreen(initialIndex: 0);
              } else {
                return MainScreen(initialIndex: 0);
              }
            }
          } else {
            _initDeepLinkListener(context);

            if (initialDocId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamed(context, '/doctor/$initialDocId');
              });
              return MainScreen(initialIndex: 0);
            } else if (initialServiceId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamed(context, '/service/$initialServiceId');
              });
              return MainScreen(initialIndex: 0);
            } else {
              return MainScreen(initialIndex: 0);
            }
          }
        },
      ),
      supportedLocales: [
        Locale('en'), // English
        Locale('hi'), // Hindi
        // Locale('es'), // Spanish
        // Locale('fr'), // French
        // Locale('de'), // German
        Locale('ta'), // Tamil
        Locale('te'), // Telugu
        Locale('pa'), // Punjabi
      ],
      localizationsDelegates: localization.localizationsDelegates,
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/doctor/')) {
          final docId = settings.name!.substring('/doctor/'.length);
          return MaterialPageRoute(
            builder: (context) => DoctorProfile1(docId: docId),
          );
        } else if (settings.name!.startsWith('/service/')) {
          final serviceId = settings.name!.substring('/service/'.length);
          return MaterialPageRoute(
            builder: (context) => ServiceInfo1(id: serviceId),
          );
        }
        return null;
      },
      //LoginScreen(),
      // MainScreen(initialIndex: 0,),

    );
  }
}
