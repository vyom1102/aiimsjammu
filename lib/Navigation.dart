import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:intl/intl.dart' as intl;

import 'dart:ui';
import 'package:app_settings/app_settings.dart';
import 'package:device_meta/device_meta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwaymaps/APIMODELS/GlobalAnnotationModel.dart';
import 'package:iwaymaps/APIMODELS/landmark.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/GlobalSearch.dart';
import 'package:iwaymaps/MODELS/RoadInfo.dart';
import 'package:iwaymaps/pannels/PinSelectionLocationModel.dart';
import 'package:iwaymaps/websocket/PushNotifications.dart';
import 'package:iwaymaps/websocket/interactionManager.dart';
import 'package:iwaymaps/websocket/navigationLogManager.dart';
import 'package:iwaymaps/websocket/navigationLogModel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '/ELEMENTS/PickupLocationPin.dart';
import '/pannels/PinLandmarkPannel.dart';
import '/path.dart';
import '/pathState.dart';
import '/realWorldModel.dart';
import '/routeOption.dart';
import '/singletonClass.dart';
import '/waypoint.dart';
import 'package:vibration/vibration.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:collection/collection.dart';
import 'package:collection/collection.dart' as pac;
import 'package:fluster/fluster.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:http/http.dart';
import '../GPS.dart';
import '/API/buildingAllApi.dart';
import '/API/slackApi.dart';
import '/APIMODELS/buildingAll.dart';
import '/CLUSTERING/InitMarkerModel.dart';
import '/CLUSTERING/MapHelper.dart';
import '/CLUSTERING/MapMarkers.dart';
import '/CONSTANTS.dart';
import '/Elements/HelperClass.dart';
import '/Elements/QRLandmarkScreen.dart';
import '/Elements/UserCredential.dart';
import '/Elements/landmarkPannelShimmer.dart';
import '/MODELS/FilterInfoModel.dart';
import '/VenueSelectionScreen.dart';
import '/websocket/UserLog.dart';
import '../newSearchPage.dart';
import '../path_snapper.dart';
import 'API/DataVersionApi.dart';
import 'API/DataVersionApiNewForRepo.dart';
import 'API/GlobalAnnotationapi.dart';
import 'API/PolyLineApi.dart';
import 'API/RatingsaveAPI.dart';
import 'API/outBuilding.dart';
import 'API/waypoint.dart';
import 'APIMODELS/DataVersion.dart';
import 'APIMODELS/outdoormodel.dart';
import 'BluetoothScanAndroidClass.dart';
import 'BluetoothScanIOSClass.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import 'DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import 'DebugToggle.dart';
import 'ELEMENTS/DirectionHeader.dart';
import 'ELEMENTS/DirectionInstruction.dart';
import 'ELEMENTS/ExploreModeWidget.dart';
import 'Elements/AccessiblePathButton.dart';
import 'EventModel/EventStatus.dart';
import 'EventModel/EventsState.dart';
import 'EventModel/UI/card.dart';
import 'GPSBuffer.dart';
import 'GPSService.dart';
import 'GlobalAnnotation/global_annotation_controller.dart';
import 'GlobalAnnotation/global_rendering.dart';
import 'LogginhScreen.dart';
import 'MapMarkerCluster/MarkerClustering.dart';
import 'MapMarkerCluster/PointForCenter.dart';
import 'MapMarkerCluster/PolygonCalculations.dart';
import 'MapMarkerCluster/UnifiedMarkerCreator.dart';
import 'PlayPreview/PlayPreviewManager.dart';
import 'Repository/RepositoryManager.dart';
import 'Sensor/SensorManager.dart';
import 'UserState.dart';
import 'VersioInfo.dart';
import 'ViewModel/DirectionInstructionViewModel.dart';
import 'centeroid.dart';
import 'config.dart';
import 'dijkastra.dart';
import 'directionClass.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'API/PatchApi.dart';
import 'API/beaconapi.dart';
import 'API/ladmarkApi.dart';
import 'API/outbuildingapi.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/outbuildingmodel.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'Cell.dart';
import 'DestinationSearchPage.dart';
import 'Elements/HomepageSearch.dart';
import 'Elements/NavigationFilterCard.dart';
import 'Elements/SearchNearby.dart';
import 'MapState.dart';
import 'MotionModel.dart';
import 'SourceAndDestinationPage.dart';
import 'bluetooth_scanning.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'cutommarker.dart';
import 'dart:math' as math;
import 'package:turf/centroid.dart' as turf;
import 'package:image/image.dart' as img;
import 'package:device_meta/device_meta.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'APIMODELS/landmark.dart' as la;
import 'dart:ui' as ui;
import 'package:geodesy/geodesy.dart' as geo;
import 'package:lottie/lottie.dart' as lott;
import 'APIMODELS/landmark.dart' as landmark;
import 'fetchrouteParams.dart';
import 'localization/locales.dart';
import 'low_fedility/homepage.dart';
import 'low_fedility/lowFedility.dart';
import 'main.dart';
import 'navigationTools.dart';

import 'navigation_api_controller.dart';

import '/RippleButton.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigation(),
    );
  }
}


class Navigation extends StatefulWidget {
  String directLandID = "";
  String directsourceID = "";
  static bool bluetoothGranted = false;

  Navigation({this.directLandID = '', this.directsourceID = ''});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // NetworkManager networkManager = NetworkManager();

  ///update above this
  MapState mapState = new MapState();
  Timer? _exploreModeTimer;
  String maptheme = "";
  var _initialCameraPosition = CameraPosition(
    target: buildingAllApi.allBuildingID.values.first,
    zoom: 0,
  );
  late GoogleMapController _googleMapController;

  //BLOCK LAYER
  Set<Polygon> globalBlock = Set();
  Set<Polygon> outDoorGlobalBlock = Set();
  Set<Marker> blockMarker = Set();
  Set<Marker> outdoorBlockMarker = Set();
  Set<Polygon> allGlobalBlocks = Set();

  Set<Polygon> patch = Set();
  Set<Polygon> otherpatch = Set();
  // Set<Polygon> blurPatch = Set();
  Map<String, Set<gmap.Polyline>> polylines = Map();
  Map<String, Set<gmap.Polyline>> dottedPath = Map();
  Set<gmap.Polyline> otherpolylines = Set();
  Set<gmap.Polyline> focusturn = Set();
  Set<Marker> focusturnArrow = Set();
  Map<String, Set<Polygon>> closedpolygons = Map();
  Set<Polygon> globalCampus = Set();
  Set<Polygon> otherclosedpolygons = Set();
  Set<Marker> Markers = Set();
  Set<Marker> landmarkMarkers = Set();
  Set<Marker> builidngNameMarker = Set();
  int currentSelectedFloor = 0;

  Map<String, Set<Marker>> selectedroomMarker = Map();
  Map<String, Map<int, Set<Marker>>> pathMarkers = {};
  Map<String, List<Marker>> markers = Map();
  // Building SingletonFunctionController.building = Building(floor: Map(), numberOfFloors: Map());
  Map<String, Map<int, Set<gmap.Polyline>>> singleroute = {};
  Map<String, Map<int, Set<gmap.Polyline>>> pathCovered = {};
  Map<int, Set<Marker>> dottedSingleRoute = {};
  // List<RoadInfo> roadPointMarkerList = [];
  // BLueToothClass SingletonFunctionController.btadBLueToothClass();
  bool _isLandmarkPanelOpen = false;
  bool _isRoutePanelOpen = false;
  bool _isnavigationPannelOpen = false;
  bool _isreroutePannelOpen = false;
  bool _isBuildingPannelOpen = true;
  bool _isFilterPanelOpen = false;
  bool checkedForPolyineUpdated = false;
  bool checkedForPatchDataUpdated = false;
  bool checkedForLandmarkDataUpdated = false;
  pac.PriorityQueue<MapEntry<String, double>> debugPQ = new pac.PriorityQueue();
  final creator = UnifiedMarkerCreator();
  late Uint8List userloc;
  late Uint8List userlocdebug;
  PlayPreviewManager? playPreviewManager;
  // HashMap<String, beacon> SingletonFunctionController.apibeaconmap = HashMap();
  late FlutterTts flutterTts;
  double mapbearing = 0.0;
  //UserState user = UserState(floor: 0, coordX: 154, coordY: 94, lat: 28.543406741799892, lng: 77.18761156074972, key: "659001d7e6c204e1eec13e26");
  UserState user = UserState(
      floor: 0, coordX: 0, coordY: 0, lat: 0.0, lng: 0.0, key: "");
  pathState PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);

  late String manufacturer;
  double step_threshold = 0.6;

  static const Duration _ignoreDuration = Duration(milliseconds: 20);
  UserAccelerometerEvent? _userAccelerometerEvent;
  DateTime? _userAccelerometerUpdateTime;
  int? _userAccelerometerLastInterval;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  late StreamSubscription<AccelerometerEvent>? pdr;
  Duration sensorInterval = Duration(milliseconds: 100);
  final pinLandmarkPannel PinLandmarkPannel = pinLandmarkPannel();

  late StreamSubscription<CompassEvent> compassSubscription;
  bool detected = false;
  List<String> allBuildingList = [];
  List<double> accelerationMagnitudes = [];
  bool isCalibrating = false;
  bool excludeFloorSemanticWork = false;
  bool markerSldShown = true;
  Set<Marker> _markers = Set();
  Set<Marker> _exploreModeMarker = Set();
  Set<Marker> _exploreModeDebugBeaconMarker = Set();
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale = '';
  final GlobalKey rerouteButton = GlobalKey();

  BluetoothScanAndroidClass bluetoothScanAndroidClass =
  BluetoothScanAndroidClass();

  late AnimationController PB_controller;
  late Animation<double> PBanimation;
  bool PB_isProgressing = false;
  double _progressValue = 0.0;
  final double targetZoom = 22.0;

  late DateTime timerStartTime;
  SensorManager accData = SensorManager();
  SensorManager magnetoData = SensorManager();

  bool initialInAppLoading = false;
  late StreamSubscription<beacon> _subscription;
  beacon? _currentPoint;
  late AnimationController _moveController;
  late Animation<LatLng> _moveAnimation;
  LatLng? _oldPosition;
  LatLng? _newPosition;
  Marker? animatedMarker;
  late MapClustering mapClustering;
  final eventsState = EventsState();
  @override
  void initState() {
    super.initState();
    // initBluetooth();
    _initializeClustering();
    mapClustering = MapClustering(onMarkerTapCallback: (String sId) {
      print("sId $sId");
      onLandmarkVenueClicked(sId);
    });
    gpsSubscription = GPSService.locationStream.listen((Location location) {
      gpsBuffer.add(location.latitude, location.longitude);
    }, onError: (error){
      print("Error receiving GPS data: $error");
    });
    Homepage.relocalize = relocalizeUser;
    Homepage.onVenueClicked = onLandmarkVenueClicked;
    initializeMarkers();
    NavigationLogManager().initialize();
    magnetoData.startMagnetometer();
    accData.startAccelerometer();

    //add a timer of duration 5sec
    //PolylineTestClass.polylineSet.clear();
    // StartPDR();


    WidgetsBinding.instance.addObserver(this);
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = 'en';

    if (UserCredentials().getUserOrentationSetting() == 'Focus Mode') {
      UserState.ttsOnlyTurns = true;
      UserState.ttsAllStop = false;
    } else {
      UserState.ttsOnlyTurns = false;
      UserState.ttsAllStop = false;
    }

    if (!HelperClass.SemanticEnabled) {
      setState(() {
        _mainIcon = Icons.volume_down_outlined;
        _mainColor = Colors.blueAccent;
      });
      UserState.ttsOnlyTurns = true;
      UserState.ttsAllStop = false;
    }

    setState(() {
      _mainIcon = Icons.volume_up_outlined;
      _mainColor = Colors.green;
    });
    UserState.ttsAllStop = false;
    UserState.ttsOnlyTurns = false;

    _messageTimer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      wsocket.sendmessg();
    });

    if (!kIsWeb) {
      if (SingletonFunctionController.timer == null) {
        SingletonFunctionController.timer =
            Future.delayed(const Duration(seconds: 7));
        timerStartTime = DateTime.now();
      } else {
        print("timer already initialized");
      }
      //  callbackFunc();
    }
    listenToMagnetometer();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Smooth duration
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800), // Adjust for smoother animation
      vsync: this,
    );
    _animationController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Adjust as needed
    );
    _initialiMarkerAnimationController=AnimationController(vsync: this,
        duration: const Duration(milliseconds: 7000)
    );
    _zoomAnimation = CurvedAnimation(
      parent: _animationController1!,
      curve: Curves.easeInOut,
    ).drive(Tween<double>(begin: 0.0, end: targetZoom));
    // Create the animation
    _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
      ..addListener(() {
        _updateCircle(user.lat, user.lng);
      });
    SingletonFunctionController.building.floor.putIfAbsent("", () => 0);
    flutterTts = FlutterTts();
    setState(() {
      isLoading = true;
    });
    PB_controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
    );
    // Define a Tween to animate the progress from 0.0 to 1.0
    PBanimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: PB_controller,
        curve: Curves.easeInOut, // Smooth linear curve for even progress
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      speak("${LocaleData.loadingMaps.getString(context)}", _currentLocale);
      apiCalls(context);
    });
    !DebugToggle.Slider ? handleCompassEvents() : () {};
    DefaultAssetBundle.of(context)
        .loadString("assets/mapstyle.json")
        .then((value) {
      maptheme = value;
    });
    if (!kIsWeb) {
      checkPermissions();
      setPdrThreshold();
      getDeviceManufacturer();
    }
    // try {
    //   _streamSubscriptions.add(
    //     userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
    //             (UserAccelerometerEvent event) {
    //           final now = DateTime.now();
    //           // setState(() {
    //           //   _userAccelerometerEvent = event;
    //           //   if (_userAccelerometerUpdateTime != null) {
    //           //     final interval = now.difference(_userAccelerometerUpdateTime!);
    //           //     if (interval > _ignoreDuration) {
    //           //       _userAccelerometerLastInterval = interval.inMilliseconds;
    //           //     }
    //           //   }
    //           // });
    //           _userAccelerometerUpdateTime = now;
    //         }, onError: (e) {
    //       showDialog(
    //           context: context,
    //           builder: (context) {
    //             return const AlertDialog(
    //               title: Text("Sensor Not Found"),
    //               content: Text(
    //                   "It seems that your device doesn't support User Accelerometer Sensor"),
    //             );
    //           });
    //       cancelOnError:
    //       true;
    //     }),
    //   );
    // } catch (E) {}
    // fetchlist();
    // filterItems();
  }

  // AvailabilityState? _currentState;

  // Future<void> initBluetooth() async {
  //   // Check Bluetooth state
  //   _currentState=await UniversalBle.getBluetoothAvailabilityState();
  //   if(Platform.isAndroid){
  //     final state = await UniversalBle.getBluetoothAvailabilityState();
  //     if (state != AvailabilityState.poweredOn) {
  //       print('initBluetooth${AvailabilityState.poweredOn} ${state}');
  //       // try {
  //       //   UniversalBle.availabilityStream.listen((state) {
  //       //     if (state == AvailabilityState.poweredOn) {
  //       //       print("state is powered on");
  //       //       Navigator.push(context,MaterialPageRoute<void>(
  //       //         builder: (BuildContext context) => MainScreen(),
  //       //       ),);
  //       //     }
  //       //   });
  //       // }catch(e){
  //       //
  //       // }
  //       // This will show the system prompt on Android
  //       // On iOS, nothing happens (must enable manually in Settings)
  //       final success = await UniversalBle.enableBluetooth();
  //       print('initBluetooth${success}');
  //       if (success) {
  //         print("Bluetooth enabled ✅");
  //       } else {
  //         print("Bluetooth not enabled ❌");
  //       }
  //     } else {
  //       print("Bluetooth already ON ✅");
  //     }
  //   }
  // }

  void _initializeClustering() async {
    MapClustering(onMarkerTapCallback: (String sId) {
      print("sId $sId");
      onLandmarkVenueClicked(sId);
    }).initMarkers().then((_) {
      MapClustering(onMarkerTapCallback: (String sId) {
        print("sId $sId");
        onLandmarkVenueClicked(sId);
      }).createBitmapMarker();
    });
    // Optionally: trigger cluster recalculation
    setState(() {
      // trigger rebuild if needed
    });
  }

  // Start the animation loop
  void PB_startAnimation() {
    if (!PB_isProgressing) {
      setState(() {
        PB_isProgressing = true;
      });
      PB_controller.repeat(); // Make the animation repeat indefinitely
    }
  }

  // Stop the animation loop
  void PB_stopAnimation() {
    if (PB_isProgressing) {
      setState(() {
        PB_isProgressing = false;
      });
      PB_controller.stop(); // Stop the animation
    }
  }

  void updateMarkers() {
    print("updating");
    setState(() {});
  }

  void clearMarkers() {
    fingerprinting.clearMarkers();
  }
  bool isFromLocalize = true; // Initialize at class level
  Future<void> initializeMarkers() async {
    userloc = await getImagesFromMarker('assets/userloc0.png', 70);
    if (!kIsWeb && kDebugMode) {
      userlocdebug = await getImagesFromMarker('assets/tealtorch.png', 15);
    }
  }
  bool isAppinForeground = true;
  AppLifecycleState? _lastLifecycleState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.detached &&
        (_lastLifecycleState == AppLifecycleState.paused ||
            _lastLifecycleState == AppLifecycleState.inactive)){
      print("App is killed");
      if(currentNavigationLog!=null){
        markNavigationUnsuccessful("User abruptly ended Navigation");
        NavigationLogManager().syncLogsToServer().then((_){
          currentNavigationLog=null;
        });
      }
    }else if (state == AppLifecycleState.paused) {
      // App went to background
      print("App is in the background");
      if (user.isnavigating) {
        StopPDR();
        setState(() {
          isAppinForeground = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground
      print("App is in the foreground");
      setState(() {
        isAppinForeground=true;
      });
      // App came to foreground
      print("App is in the foreground");
      if(user.isnavigating){
        StartPDR();
      }
    }
    _lastLifecycleState = state;
  }

  void excludeFloorSemanticWorkchange() {
    setState(() {
      excludeFloorSemanticWork = true;
    });
  }

  double minHeight = 92.0;
  bool maxHeightBottomSheet = false;
  void close_isnavigationPannelOpen() {
    closeRoutePannel();
    _slidePanelDown();
    _resetScrollPosition();

    setState(() {
      //_isnavigationPannelOpen = false;
      minHeight = 90;
    });
  }

  void calibrate() async {
    setState(() {
      isCalibrating = true;
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      double magnitude =
      sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      setState(() {
        accelerationMagnitudes.add(magnitude);
      });
    });

    Timer(Duration(seconds: 10), () {
      //calculateThresholds();
      setState(() {
        isCalibrating = false;
      });
    });
    StartPDR();
  }

  void startOnPath() {
    setState(() {
      _isnavigationPannelOpen = true;
      _isreroutePannelOpen = false;
      user.isnavigating = true;
    });
  }

  void calculateThresholds() {
    if (accelerationMagnitudes.isNotEmpty) {
      double mean = accelerationMagnitudes.reduce((a, b) => a + b) /
          accelerationMagnitudes.length;
      double variance = accelerationMagnitudes
          .map((x) => (x - mean) * (x - mean))
          .reduce((a, b) => a + b) /
          accelerationMagnitudes.length;
      double standardDeviation = sqrt(variance);
      // Adjust multiplier as needed for sensitivity
      double multiplier = 5;
      setState(() {
        peakThreshold = mean + multiplier * standardDeviation;
        valleyThreshold = mean - multiplier * standardDeviation;
      });
    }
  }

  Future<void> getDeviceManufacturer() async {
    DeviceMeta deviceMeta = await DeviceMeta.init(storageKey: "exampleapp");
    try {
      manufacturer = deviceMeta.manufacturer!;
      wsocket.message["deviceInfo"]["deviceManufacturer"] =
          manufacturer.toString();
      // networkManager.ws.updateDeviceManufacturer(manufacturer.toString());
      if (manufacturer.toLowerCase().contains("samsung")) {
        step_threshold = 0.12;
      } else if (manufacturer.toLowerCase().contains("oneplus")) {
        step_threshold = 0.7;
      } else if (manufacturer.toLowerCase().contains("realme")) {
        step_threshold = 0.7;
      } else if (manufacturer.toLowerCase().contains("redmi")) {
        step_threshold = 0.12;
      } else if (manufacturer.toLowerCase().contains("google")) {
        step_threshold = 1.08;
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<void> setPdrThreshold() async {
    if (SingletonFunctionController
        .building.patchData[buildingAllApi.selectedBuildingID] !=
        null &&
        SingletonFunctionController
            .building
            .patchData[buildingAllApi.selectedBuildingID]!
            .patchData!
            .pdrThreshold !=
            null &&
        SingletonFunctionController
            .building
            .patchData[buildingAllApi.selectedBuildingID]!
            .patchData!
            .pdrThreshold!
            .isNotEmpty) {
      peakThreshold = double.parse(SingletonFunctionController
          .building
          .patchData[buildingAllApi.selectedBuildingID]!
          .patchData!
          .pdrThreshold!);
      valleyThreshold = peakThreshold * -1;
      return;
    }
    DeviceMeta deviceMeta = await DeviceMeta.init(storageKey: "exampleapp");

    try {
      manufacturer = deviceMeta.manufacturer!;
      String deviceModel = deviceMeta.model!;

      if (manufacturer.toLowerCase().contains("samsung")) {
        if (deviceModel.startsWith("A", 3)) {
          peakThreshold = 10.7;
          valleyThreshold = -10.7;
        } else if (deviceModel.startsWith("M", 3)) {
          peakThreshold = 11.0;
          valleyThreshold = -11.0;
        } else {
          peakThreshold = 11.111111;
          valleyThreshold = -11.111111;
        }
      } else if (manufacturer.toLowerCase().contains("oneplus")) {
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
        // step_threshold = 0.7;
      } else if (manufacturer.toLowerCase().contains("realme")) {
        peakThreshold = 11.0;
        valleyThreshold = -11.0;
      } else if (manufacturer.toLowerCase().contains("redmi")) {
        peakThreshold = 11.3;
        valleyThreshold = -11.3;
      } else if (manufacturer.toLowerCase().contains("google")) {
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
      } else if (manufacturer.toLowerCase().contains("apple")) {
        peakThreshold = 10.35;
        valleyThreshold = -10.35;
      } else {
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
      }

      if (UserCredentials().getUserPersonWithDisability() > 0) {
        peakThreshold = peakThreshold + 0.5;
        valleyThreshold = valleyThreshold - 0.5;
      }
    } catch (e) {
      throw (e);
    }
  }

  void handleCompassEvents() {
    magnetoData.magnetometerStream.listen((event) {
      wsocket.message["deviceInfo"]["sensors"]["compass"] = true;
      wsocket.message["deviceInfo"]["permissions"]["compass"] = true;
      // networkManager.ws.updateSensorStatus(compass: true);
      // networkManager.ws.updatePermissions(compass: true);
      double? compassHeading = event.heading;
      if (disposed) return;
      setState(() {
        user.theta = compassHeading!;
        if (mapState.interaction2) {
          mapState.bearing = compassHeading!;
          _googleMapController.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: mapState.target,
                zoom: mapState.zoom,
                bearing: mapState.bearing!,
              ),
            ),
          );
        } else {
          if (markers.isNotEmpty && markers[user.bid] != null) {
            markers[user.bid]![0] = customMarker.rotate(
                compassHeading! - mapbearing, markers[user.bid]![0]);
          }
        }
      });
    }, onError: (error) {
      wsocket.message["deviceInfo"]["sensors"]["compass"] = false;
      wsocket.message["deviceInfo"]["permissions"]["compass"] = false;
      // networkManager.ws.updateSensorStatus(compass: false);
      // networkManager.ws.updatePermissions(compass: false);
    });
  }

  void showToast(String mssg) {
    if(!kDebugMode) return;
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

  // bool disposed = false;
  // final List<_TtsItem> _ttsQueue = [];
  // bool _isSpeaking = false;

  Future<void> setFemaleIndianVoice() async {
    List<dynamic> voices = await flutterTts.getVoices;
    // print("voices $voices");

    // Filter Indian English voices
    var indianVoices = voices.where((voice) =>
        voice["locale"].toString().contains("hi-IN")
    ).toList();

    // Try to find female voice
    var femaleVoice = indianVoices.firstWhere(
            (voice) => voice["name"].toString().toLowerCase().contains("female"),
        orElse: () => indianVoices.isNotEmpty ? indianVoices[0] : null
    );

    if (femaleVoice != null) {
      await flutterTts.setVoice({
        "name": femaleVoice["name"],
        "locale": femaleVoice["locale"]
      });
    } else {
      await flutterTts.setLanguage("en-IN");
    }
  }

  Future<void> speak(String msg, String lngcode,
      {bool prevpause = false}) async {
    final stackTrace = StackTrace.current;
    print("speak Stack: \n$stackTrace");
    if (!UserState.ttsAllStop) {
      if (disposed) return;

      try {
        setFemaleIndianVoice();

        await flutterTts.stop();
        if (Platform.isAndroid) {
          await flutterTts.setSpeechRate(0.55);
        } else {
          await flutterTts.setSpeechRate(0.55);
        }

        await flutterTts.setPitch(1.0);

        // Check if Semantic Mode is enabled
        if (isSemanticEnabled) {
          //PushNotifications.showSimpleNotification(body: "", payload: "", title: msg);
        } else {
          await flutterTts.speak(msg);
        }
      } catch (e) {
        print("Error during TTS: $e");
      }
    }
  }

  void checkPermissions() async {
    await requestLocationPermission();
    await requestBluetoothConnectPermission();
    await enableBT();
    //  await requestActivityPermission();
  }

  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) {});
  }
  bool isPdr = false;
  // Function to start the timer
  void StartPDR() {
    setState(() {
      isPdr = true;
    });
    if (isAppinForeground) {
      pdrstepCount();
    }
  }

// Function to stop the timer
  bool isPdrStop = false;
  double stepmagnitude = 0.0;
  void StopPDR() async {
    if (isPdrStop) return;
    await pdr?.cancel();
    pdr = null;
    print("pdrstate:${pdr}");
    setState(() {
      isPdrStop = true;
      isPdr = false;
    });
  }

  int stepCount = 0;
  int lastPeakTime = 0;
  int lastValleyTime = 0;
  //will have to set according to the device
  double peakThreshold = 11.1111111;
  double valleyThreshold = -11.1111111;

  int peakInterval = 300;
  int valleyInterval = 300;
  //it is the smoothness factor of the low pass filter.
  double alpha = 0.4;
  double filteredX = 0;
  double filteredY = 0;
  double filteredZ = 0;
  bool restartScanning = false;

  List<double> orientationHistory = [];
  int orientationWindowSize = 10; // Number of readings for stability check
  double orientationThreshold = 0.1;
// late StreamSubscription<AccelerometerEvent>? pdr;
  //sideways movement 12.10
  void pdrstepCount() {
    pdr = accData.accelerometerStream.listen((event) {
      wsocket.message["deviceInfo"]["sensors"]["activity"] = true;
      wsocket.message["deviceInfo"]["permissions"]["activity"] = true;
      // networkManager.ws.updateSensorStatus(activity: true);
      // networkManager.ws.updatePermissions(activity: true);
      // Apply low-pass filter
      if (pdr == null) {
        return; // Exit the event listener if subscription is canceled
      }
      if (detectStep(event.x, event.y, event.z)) {
        setState(() {
          lastPeakTime = DateTime.now().millisecondsSinceEpoch;
          stepCount++;

          bool isvalid = MotionModel.isValidStep(
              user,
              SingletonFunctionController
                  .building.floorDimenssion[user.bid]![user.floor]![0],
              SingletonFunctionController
                  .building.floorDimenssion[user.bid]![user.floor]![1],
              SingletonFunctionController
                  .building.nonWalkable[user.bid]![user.floor]!,
              reroute,
              context);
          if (isvalid) {
            user.move(context).then((value) {
              renderHere();
            });
          } else {
            if (user.isnavigating) {
              // reroute();
              // showToast("You are out of path");
            }
          }
        });
      } else {
        filteredX = alpha * filteredX + (1 - alpha) * event.x;
        filteredY = alpha * filteredY + (1 - alpha) * event.y;
        filteredZ = alpha * filteredZ + (1 - alpha) * event.z;
        // Compute orientation angle from accelerometer data (e.g., pitch or roll)
        double orientation = atan2(
            filteredY, sqrt(filteredX * filteredX + filteredZ * filteredZ));
        // Add orientation to history and check variabilityf
        orientationHistory.add(orientation);
        if (orientationHistory.length > orientationWindowSize) {
          orientationHistory.removeAt(0); // Maintain a fixed window size

          // Calculate standard deviation of orientation
          double avgOrientation = orientationHistory.reduce((a, b) => a + b) /
              orientationWindowSize;
          double orientationVariance = orientationHistory.fold(
              0,
                  (sum, value) =>
              sum + pow(value - avgOrientation, 2).toInt()) /
              orientationWindowSize;
          double orientationStability = sqrt(orientationVariance);
          // Suppress step detection if orientation is too variable
          if (orientationStability > orientationThreshold) {
            // Too random, assume the user is stationary or talking, ignore steps
            return;
          }
        }
        // Compute magnitude of acceleration vector
        double magnitude = sqrt((filteredX * filteredX +
            filteredY * filteredY +
            filteredZ * filteredZ));
        // Detect peak and valley
        if (magnitude > peakThreshold &&
            DateTime.now().millisecondsSinceEpoch - lastPeakTime >
                peakInterval) {
          setState(() {
            lastPeakTime = DateTime.now().millisecondsSinceEpoch;
            stepCount++;

            stepmagnitude = magnitude;
            bool isvalid = MotionModel.isValidStep(
                user,
                SingletonFunctionController
                    .building.floorDimenssion[user.bid]![user.floor]![0],
                SingletonFunctionController
                    .building.floorDimenssion[user.bid]![user.floor]![1],
                SingletonFunctionController
                    .building.nonWalkable[user.bid]![user.floor]!,
                reroute,
                context);
            // Valid walking step
            if (isvalid) {
              user.move(context).then((value) {
                renderHere();
              });
            } else {
              if (user.isnavigating) {}
            }
          });
        } else if (magnitude < valleyThreshold &&
            DateTime.now().millisecondsSinceEpoch - lastValleyTime >
                valleyInterval) {
          setState(() {
            lastValleyTime = DateTime.now().millisecondsSinceEpoch;
          });
        }
      }
    }, onError: (error) {
      wsocket.message["deviceInfo"]["sensors"]["activity"] = false;
      wsocket.message["deviceInfo"]["permissions"]["activity"] = false;
      // networkManager.ws.updateSensorStatus(activity: false);
      // networkManager.ws.updatePermissions(activity: false);
    });
  }

  DateTime? lastStepTime; // To track the last step detection time
  final Duration stepCooldown = Duration(milliseconds: 800);
  bool isPdrActive = false;
  bool detectStep(double x, double y, double z) {
    if (!isPdrActive) return false;
    // Calculate pitch and roll
    double pitch = atan(x / sqrt(y * y + z * z)) * (180 / pi);
    double roll = atan(y / sqrt(x * x + z * z)) * (180 / pi);
    // Define problematic orientation thresholds
    bool isProblematicOrientation =
        (pitch > 80 && pitch < 100) || (roll > 80 && roll < 100);
    // Calculate movement magnitude
    double magnitude = sqrt(x * x + y * y + z * z);
    // Threshold to detect significant movement
    double movementThreshold = 9.85; // Adjust based on your testing
    // Check if a step is detected
    if (isProblematicOrientation && magnitude > movementThreshold) {
      DateTime now = DateTime.now();

      // Ensure cooldown between steps
      if (lastStepTime == null ||
          now.difference(lastStepTime!) > stepCooldown) {
        lastStepTime = now; // Update the last step detection time
        return true; // Step detected
      }
    }
    return false; // No step detected
  }

  Future<void> paintMarker(LatLng Location) async {
    markers.clear();
    if (markers.containsKey(user.bid)) {
      markers[user.bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      if (!kIsWeb && kDebugMode) {
        markers[user.bid]?.add(Marker(
          markerId: MarkerId("debug"),
          position: Location,
          icon: BitmapDescriptor.fromBytes(userlocdebug),
          anchor: Offset(0.5, 0.829),
        ));
      }
    } else {
      markers.putIfAbsent(user.bid, () => []);
      markers[user.bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      if (!kIsWeb && kDebugMode) {
        markers[user.bid]?.add(Marker(
          markerId: MarkerId("debug"),
          position: Location,
          icon: BitmapDescriptor.fromBytes(userlocdebug),
          anchor: Offset(0.5, 0.829),
        ));
      }
    }
  }

  void changeBuilding(String oldBid, String newBid) {
    print("oldBid $oldBid   newBid $newBid  ${markers[oldBid]!}");
    markers[newBid] = markers[oldBid]!;
    tools.setBuildingAngle(SingletonFunctionController
        .building.patchData[newBid]!.patchData!.buildingAngle!);
  }

  Animation<LatLng>? _markerAnimation;

  void renderHere() async {
    if (markers.isNotEmpty) {
      List<double> lvalue = [user.lat, user.lng];

      LatLng currentMarkerPosition = markers[user.bid]![0].position;
      LatLng newMarkerPosition = LatLng(lvalue[0], lvalue[1]);

      // Define a smooth transition animation
      _markerAnimation = LatLngTween(
        begin: currentMarkerPosition,
        end: newMarkerPosition,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ));
      // Start the animation
      _animationController!.forward(from: 0);
      _animationController!.addListener(() {
        setState(() {
          // Update marker position as animation progresses
          markers[user.bid]?[0] = customMarker.move(
            _markerAnimation!.value,
            markers[user.bid]![0],
          );
        });
      });

      mapState.target = newMarkerPosition;

      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: (UserState.isTurn || onStart == false)
                ? mapState.target
                : mapState.target,
            zoom: mapState.zoom,
            bearing: mapState.bearing ?? 0,
            tilt: mapState.tilt,
          ),
        ),
      );
      try {
        alignMapToPath(lvalue,
            [
              user.cellPath[user.pathobj.index + 1].lat,
              user.cellPath[user.pathobj.index + 1].lng
            ]
        );
        mapState.aligned = true;
      } catch (e) {}
      List<double> ldvalue = tools.localtoglobal(
          user.coordX.toInt(),
          user.coordY.toInt(),
          SingletonFunctionController.building.patchData[user.bid]);
      try {
        markers[user.bid]?[1] = customMarker.move(
            LatLng(ldvalue[0], ldvalue[1]), markers[user.bid]![1]);
      }catch(e){
        print("renderHere:${e}");
      }
      //modifyPathCovered(user.bid, user.floor, newMarkerPosition);
    }
  }

  void _recenterMap() {
    try {
      alignMapToPath([
        user.cellPath[user.pathobj.index].lat,
        user.cellPath[user.pathobj.index].lng
      ], [
        user.cellPath[user.pathobj.index + 1].lat,
        user.cellPath[user.pathobj.index + 1].lng
      ]);
      mapState.aligned = true;
    } catch (e) {}
  }

  void onStepCount() {
    setState(() {
      if (_userAccelerometerEvent?.y != null) {
        if (_userAccelerometerEvent!.y > step_threshold ||
            _userAccelerometerEvent!.y < -step_threshold) {
          bool isvalid = MotionModel.isValidStep(
              user,
              SingletonFunctionController
                  .building.floorDimenssion[user.bid]![user.floor]![0],
              SingletonFunctionController
                  .building.floorDimenssion[user.bid]![user.floor]![1],
              SingletonFunctionController
                  .building.nonWalkable[user.bid]![user.floor]!,
              reroute,
              context);
          if (isvalid) {
            user.move(context).then((value) {
              setState(() {
                if (markers.length > 0) {
                  markers[user.bid]![0] = customMarker.move(
                      LatLng(
                          tools.localtoglobal(
                              user.showcoordX.toInt(),
                              user.showcoordY.toInt(),
                              SingletonFunctionController
                                  .building.patchData[user.bid])[0],
                          tools.localtoglobal(
                              user.showcoordX.toInt(),
                              user.showcoordY.toInt(),
                              SingletonFunctionController
                                  .building.patchData[user.bid])[1]),
                      markers[user.bid]![0]);
                }
              });
            });
          } else {
            showToast("You are out of path");
          }
        }
      }
    });
  }

  List<String> finalDirections = [];

  List<String> calcDirectionsExploreMode(List<int> userCords,
      List<int> newUserCord, List<nearestLandInfo> nearbyLandmarkCoords) {
    List<String> finalDirections = [];
    for (int i = 0; i < nearbyLandmarkCoords.length; i++) {
      double value = tools.calculateAngle2(userCords, newUserCord, [
        nearbyLandmarkCoords[i].coordinateX!,
        nearbyLandmarkCoords[i].coordinateY!
      ]);

      //
      //
      String finalvalue =
      tools.angleToClocksForNearestLandmarkToBeacon(value, context);
      //
      finalDirections.add(finalvalue);
    }
    return finalDirections;
  }

  List<String> EM_finalDirections = [];
  List<String> EM_calcDirectionsExploreMode(List<int> userCords,
      List<int> newUserCord, List<Landmarks> nearbyLandmarkCoords) {
    List<String> finalDirections = [];
    for (int i = 0; i < nearbyLandmarkCoords.length; i++) {
      double value = tools.calculateAngle2(userCords, newUserCord, [
        nearbyLandmarkCoords[i].coordinateX!,
        nearbyLandmarkCoords[i].coordinateY!
      ]);

      //
      //
      String finalvalue =
      tools.angleToClocksForNearestLandmarkToBeacon(value, context);
      //
      finalDirections.add(finalvalue);
    }
    return finalDirections;
  }

  void repaintUser(String nearestBeacon) {
    reroute();
    paintUser(nearestBeacon, null, speakTTS: false);
  }

  String convertTolng(String msg, String lngcode, String finalvalue) {
    if (msg ==
        "You are on ${tools.numericalToAlphabetical(user.floor)} floor, near ${user.locationName}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(user.floor)} मंज़िल, ${user.locationName} आपके नज़दीक है";
      }
    } else if (msg ==
        "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(user.floor)} मंजिल पर हैं, ${user.locationName} आपके ${LocaleData.properties5[finalvalue]?.getString(context)} पर है";
      }
    } else if (msg == "Confirm Your Location Amongst Below Given List") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "नीचे दी गई सूची में से अपना स्थान पुष्टि करें";
      }
    } else if (msg == "Turn $finalvalue") {
      if (lngcode == 'en') {
        return msg;
      } else {
        print(
            "LocaleData.properties5[finalvalue]:${LocaleData.properties5[finalvalue]}");
        return "${LocaleData.properties5[finalvalue]?.getString(context)} मुड़ें";
      }
    } else if (msg == "Go Straight") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "सीधे जाएं";
      }
    }
    return "";
  }

  late AnimationController _controller;
  late Animation<double> _animation;
  // land userSetLandmarkMap = land().landmarksMap;
  Future<Landmarks?> getGlobalCoords(LatLng coordinates) async {
    debugMarker.clear();
    Landmarks? closestLandmark;
    double minDistance = 150;

    // Fetch landmark data
    final landmarkData =
    await SingletonFunctionController.building.landmarkdata;
    if (landmarkData?.landmarks == null) return null;

    for (var landmark in landmarkData!.landmarks!) {
      if (landmark.element?.type != "FloorConnection" &&
          landmark.element?.subType != "restRoom" &&
          landmark.element?.subType != "AR" &&
          landmark.element?.subType != "Alert" &&
          landmark.element?.subType != "BP" &&
          landmark.floor == 0 &&
          landmark.coordinateX != null &&
          landmark.coordinateY != null &&
          landmark.properties!.latitude != null &&
          landmark.properties!.longitude != null) {
        List<double> latLngValue = [double.parse(landmark.properties!.doorLat??landmark.properties!.latitude!), double.parse(landmark.properties!.doorLng??landmark.properties!.longitude!)];
        double dist = tools.calculateAerialDist(latLngValue[0], latLngValue[1],
            coordinates.latitude, coordinates.longitude);
        print("distance for ${landmark.name} is ${dist} m");
        if (landmark.properties?.polyId != null &&
            landmark.name?.isNotEmpty == true &&
            dist < minDistance) {
          minDistance = dist;
          closestLandmark = Landmarks.fromJson(landmark.toJson());
        }
      }
    }
    print(
        "closestLandmark $closestLandmark ${SingletonFunctionController.building.polylinedatamap[buildingAllApi.outdoorID]?.polyline?.floors}");

    if (closestLandmark == null || Building.waypoint[buildingAllApi.outdoorID] == null) return closestLandmark;

    // Find closest waypoint
    Map<double, Nodes> waypoints = {};
    final polylineData = SingletonFunctionController.building.polylinedatamap;
    PathModel model = Building.waypoint[buildingAllApi.outdoorID]!
        .firstWhere((e) => e.floor == 0);
    Map<String, List<dynamic>> adj = model.pathNetwork ?? {};
    Map<String, List<dynamic>> adjGlobal = model.pathNetworkGlobal ?? {};

    polylineData[buildingAllApi.outdoorID]?.polyline?.floors?.forEach((floor) {
      floor.polyArray?.forEach((polyline) {
        if (polyline.polygonType == "Waypoints" &&
            polyline.floor ==
                tools.numericalToAlphabetical(closestLandmark?.floor ?? 0)) {
          for (var node in polyline.nodes ?? []) {
            double dist = tools.calculateAerialDist(node.lat!, node.lon!,
                coordinates.latitude, coordinates.longitude);
            if (adj.containsKey("${node.coordx},${node.coordy}")) {
              waypoints[dist] = node;
            }
          }
        }
      });
    });

    List<Nodes> getTop3Nearest(Map<double, Nodes> waypoints) {
      var sortedEntries = waypoints.entries.toList();
      sortedEntries.sort((a, b) => a.key.compareTo(b.key)); // Sort in-place

      return sortedEntries
          .take(3) // Take the first 3 entries
          .map((e) => e.value) // Extract Cell objects
          .toList(); // Convert to List<Cell>
    }

    List<Nodes> nearestWaypoints = getTop3Nearest(waypoints);

    print("nearestWaypoints $nearestWaypoints");

    if (waypoints.isNotEmpty) {
      Map<Nodes, ClosestPointResult> result = {};
      for (var waypoint in nearestWaypoints) {
        addDebugMarkers(LatLng(waypoint.lat!, waypoint.lon!), hue: BitmapDescriptor.hueMagenta);
        List<dynamic>? adjList = adj["${waypoint?.coordx},${waypoint?.coordy}"];
        List<dynamic>? adjGlobalList =
        adjGlobal["${waypoint?.lat},${waypoint?.lon}"];
        print("adj $adj");
        print("adjGlobalList $adjGlobalList");

        ClosestPointResult closestPoint = ClosestPointResult(
            LatLng(waypoint!.lat!, waypoint!.lon!),
            IntPoint(waypoint!.coordx!, waypoint!.coordy!),
            tools.calculateAerialDist(coordinates.latitude,
                coordinates.longitude, waypoint!.lat!, waypoint!.lon!));

        if (adjList != null && adjGlobalList != null) {
          adjList.remove("${waypoint!.coordx},${waypoint!.coordy}");
          adjGlobalList.remove("${waypoint!.lat},${waypoint!.lon}");

          List<LatLng> latLngPoints = tools.convertToLatLngList(adjGlobalList);
          List<IntPoint> intPoints = tools.convertToIntPointList(adjList);
          closestPoint = shortestPoint(coordinates, closestPoint.latLngPoint, closestPoint.intPoint, latLngPoints, intPoints);
          result[waypoint] = closestPoint;
        }
      }

      MapEntry<Nodes, ClosestPointResult> shortestProjection = result.entries
          .reduce(
              (a, b) => a.value.projectLength < b.value.projectLength ? a : b);
      ClosestPointResult closestPoint = shortestProjection.value;
      if (tools.calculateDistance([shortestProjection.value.intPoint.x, shortestProjection.value.intPoint.y], [shortestProjection.key!.coordx!, shortestProjection.key!.coordy!]) <= 10) {
        closestPoint = ClosestPointResult(
            LatLng(shortestProjection.key!.lat!, shortestProjection.key!.lon!),
            IntPoint(shortestProjection.key!.coordx!,
                shortestProjection.key!.coordy!),
            0);
      }
      closestLandmark!
        ..coordinateX = closestPoint.intPoint.x
        ..coordinateY = closestPoint.intPoint.y
        ..doorX = closestPoint.intPoint.x
        ..doorY = closestPoint.intPoint.y
        ..buildingID = buildingAllApi.outdoorID
        ..properties!.latitude = closestPoint.latLngPoint.latitude.toString()
        ..properties!.longitude = closestPoint.latLngPoint.longitude.toString()
        ..properties!.doorLat = closestPoint.latLngPoint.latitude.toString()
        ..properties!.doorLng = closestPoint.latLngPoint.longitude.toString();
    }

    return closestLandmark;
  }

  void cleardebugMarkers(){
    setState(() {
      debugMarker.clear();
    });
  }

  Set<Marker> debugMarker = Set();
  void addDebugMarkers(LatLng point, {double? hue, int? id, bool clear = false}) {
    if(clear){
      debugMarker.clear();
    }
    if (!kIsWeb && kDebugMode) {
      print("adding marker at $point");
      setState(() {
        debugMarker.add(Marker(
          markerId: MarkerId("debug${DateTime.now().toString()}"),
          position: point,
          visible: true,
          onTap: () {},
          infoWindow: InfoWindow(
              title: id.toString(),
              // snippet: '${landmarks[i].properties!.polyId}',
              // Replace with additional information
              onTap: () {}),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              hue ?? BitmapDescriptor.hueAzure),
        ));
      });
    }
  }

  Set<Marker> GpsMarker = Set();
  void addGpsMarkers(Location point, {double? hue, int? id}) {
    if (true) {
      GpsMarker.clear();
      print("adding GPS marker at $point");
      setState(() {
        GpsMarker.add(Marker(
          markerId: MarkerId("debug${DateTime.now().toString()}"),
          position: LatLng(point.latitude, point.longitude),
          visible: true,
          onTap: () {},
          infoWindow: InfoWindow(
              title: id.toString(),
              // snippet: '${landmarks[i].properties!.polyId}',
              // Replace with additional information
              onTap: () {}),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              hue ?? BitmapDescriptor.hueAzure),
        ));
      });
    }
  }

  Map<MarkerId, Marker> nearbyLandmarks = {};
  Landmarks? PinedLandmark;

  Future<void> addNearbyLandmarkMarkers(LatLng point,String id, String name, bool visible, {String? road}) async {
    final Uint8List iconMarker = await getImagesFromMarker('assets/OptionLandmark.png', 30);
    BitmapDescriptor optionLandmark = BitmapDescriptor.fromBytes(iconMarker);
    final markerId = MarkerId(id);
    setState(() {
      if(nearbyLandmarks[markerId] != null){
        print("already exists a landmark ${markerId.value}");
      }
      nearbyLandmarks[markerId] = Marker(
        markerId: MarkerId("$name${road!=null?"#$road":"#"}#${visible?"true":"false"}#$id"),
        position: point,
        visible: visible,
        icon: optionLandmark,
        anchor: Offset(0.5, 0.5)
      );
    });
    PinLandmarkPannel.togglePanel();
    print("Added NearbyLandmark at $point with ID: $markerId");
  }

  void selectPinLandmark(CameraPosition cameraposition){
    double distance = 5;
    MarkerId? id;
    nearbyLandmarks.forEach((key,value){
      double d = tools.calculateAerialDist(cameraposition.target.latitude, cameraposition.target.longitude, value.position.latitude, value.position.longitude);
      if(d<distance){
        distance = d;
        id = key;
      }
    });
    if(id != null){
      updateNearbyLandmarkMarkers(id!);
    }else{
      PinedLandmark = null;
    }
  }

  Future<void> focusOnPinLandmark(LatLng position) async {
    LatLngBounds bounds = await _googleMapController.getVisibleRegion();
    LatLng center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );
    if (center.latitude.toStringAsFixed(5) !=
        position.latitude.toStringAsFixed(5) ||
        center.longitude.toStringAsFixed(5) !=
            position.longitude.toStringAsFixed(5)) {
      print("focusing map $position");
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position, // Use the last known target
            zoom: 22, // Use the last known zoom
            bearing: user.theta, // Update the bearing
          ),
        ),
      );
    }
  }

  Future<void> updateNearbyLandmarkMarkers(MarkerId id) async {
    if (PinedLandmark ==
        SingletonFunctionController.building.listOfNearbyLandmarksToLocalize!
            .where((landmark) => landmark.sId == id.value)
            .first) {
      focusOnPinLandmark(nearbyLandmarks[id]!.position);
    }
    if (!nearbyLandmarks.containsKey(id) ||
        PinedLandmark ==
            SingletonFunctionController
                .building.listOfNearbyLandmarksToLocalize!
                .where((landmark) => landmark.sId == id.value)
                .first) return;
    final Uint8List selectedMarker =
    await getImagesFromMarker('assets/LandmarkSelected.png', 30);
    BitmapDescriptor selectedLandmark =
    BitmapDescriptor.fromBytes(selectedMarker);

    final Uint8List iconMarker =
    await getImagesFromMarker('assets/OptionLandmark.png', 30);
    BitmapDescriptor optionLandmark = BitmapDescriptor.fromBytes(iconMarker);
    setState(() {
      // Update all markers to default
      nearbyLandmarks.updateAll((markerId, marker) {
        return marker.copyWith(iconParam: optionLandmark, anchorParam: Offset(0.5, 0.5));
      });
      // Update the selected marker to a different icon
      nearbyLandmarks[id] =
          nearbyLandmarks[id]!.copyWith(iconParam: selectedLandmark, anchorParam: Offset(0.5, 0.5));
    });
    focusOnPinLandmark(nearbyLandmarks[id]!.position);
    if (SingletonFunctionController.building.listOfNearbyLandmarksToLocalize !=
        null) {
      PinedLandmark = SingletonFunctionController
          .building.listOfNearbyLandmarksToLocalize!
          .where((landmark) => landmark.sId == id.value)
          .first;
    }
    print(
        "Updated NearbyLandmark with ID: ${nearbyLandmarks[id]!.markerId.value}  now the list is $nearbyLandmarks");
  }

  ClosestPointResult shortestPoint(LatLng userLatLng, LatLng targetLatLng, IntPoint targetintPoint, List<LatLng> latLngPoints, List<IntPoint> intPoints) {

    addDebugMarkers(targetLatLng,hue:BitmapDescriptor.hueMagenta);
    double distanceBetweenLatLng(LatLng a, LatLng b) {
      return sqrt(pow(a.latitude - b.latitude, 2) + pow(a.longitude - b.longitude, 2));
    }

    LatLng? projectLatLngIfWithinSegment(
        LatLng user, LatLng start, LatLng end) {
      double ax = user.latitude - start.latitude;
      double ay = user.longitude - start.longitude;
      double bx = end.latitude - start.latitude;
      double by = end.longitude - start.longitude;

      double t = (ax * bx + ay * by) / (bx * bx + by * by);

      // Check if the projection lies within the segment
      if (t < 0 || t > 1) {
        return null; // Outside the segment
      }

      print("latlng projected are ${start.latitude + t * bx},${start.longitude + t * by}");
      return LatLng(start.latitude + t * bx, start.longitude + t * by);
    }

    double minDistanceLatLng = double.infinity;
    LatLng? closestLatLngPoint;
    LatLng? xPoint;
    LatLng? yPoint;
    navPoints? closestIntPoint;
    IntPoint? xintegerpoint;
    IntPoint? yintegerpoint;

    for (int i = 0; i < latLngPoints.length; i++) {
      LatLng latLngPoint = latLngPoints[i];
      if(latLngPoint.latitude == targetLatLng.latitude && latLngPoint.longitude == targetLatLng.longitude) continue;

      LatLng? projectedLatLng = projectLatLngIfWithinSegment(userLatLng, targetLatLng, latLngPoint);

      if (projectedLatLng != null) {
        addDebugMarkers(latLngPoint,hue:BitmapDescriptor.hueOrange);
        double distance = distanceBetweenLatLng(userLatLng, projectedLatLng);
        if (distance < minDistanceLatLng) {
          xintegerpoint = tools.findCoordinatesOfWaypoint(targetLatLng);
          yintegerpoint = tools.findCoordinatesOfWaypoint(latLngPoint);
          if(xintegerpoint == null || yintegerpoint == null) continue;
          minDistanceLatLng = distance;
          closestLatLngPoint = projectedLatLng;
          xPoint = targetLatLng;
          yPoint = latLngPoint;
        }
      }
    }

    // Check if the direct distance to the target is shorter
    double distanceToTargetLatLng = distanceBetweenLatLng(userLatLng, targetLatLng);
    if (distanceToTargetLatLng < minDistanceLatLng) {
      return ClosestPointResult(targetLatLng, targetintPoint!, tools.calculateAerialDist(userLatLng.latitude, userLatLng.longitude, targetLatLng.latitude, targetLatLng.longitude)); // Return target for both formats
    }

    if(closestLatLngPoint != null && xPoint!= null && yPoint != null && xintegerpoint != null && yintegerpoint != null){


      navPoints X = navPoints(xPoint.latitude,xPoint.longitude,xintegerpoint.x,xintegerpoint.y);
      navPoints Y = navPoints(yPoint.latitude,yPoint.longitude,yintegerpoint.x,yintegerpoint.y);
      navPoints Z = navPoints(closestLatLngPoint.latitude,closestLatLngPoint.longitude,0,0);
      closestIntPoint = tools.findCartesianCoordinates(X, Y, Z);
      // print("closestIntPoint ${X.x} ${X.y} , ${Y.x} ${Y.y} , ${closestIntPoint.x} ${closestIntPoint.y} ${closestIntPoint.latitude} ${closestIntPoint.longitude}");

    }


    return ClosestPointResult(closestLatLngPoint ?? targetLatLng, closestIntPoint!=null?IntPoint(closestIntPoint.x, closestIntPoint.y):targetintPoint,
        tools.calculateAerialDist(userLatLng.latitude, userLatLng.longitude, (closestLatLngPoint ?? targetLatLng).latitude, (closestLatLngPoint ?? targetLatLng).longitude)
    );
  }

  double currentHeading = 10.0; // Example current heading
  double referenceHeading = 0.0; // Example reference heading (North)
  double threshold = 10.0;
// Function to check compass accuracy with field strength
  double expectedFieldStrength = 50.0; // µT, typical for Earth
  double acceptableDeviationPercentage = 0.2;
  List<double> magneticValues = []; // 20% deviation is acceptable

// Function to check if calibration is needed
  bool isCalibrationNeeded(List<double> magneticFieldStrengths) {
    double acceptableLowerBound =
        expectedFieldStrength * (1 - acceptableDeviationPercentage);
    double acceptableUpperBound =
        expectedFieldStrength * (1 + acceptableDeviationPercentage);
    double averageStrength = 0.0;
    if (magneticFieldStrengths.length > 0) {
      averageStrength = magneticFieldStrengths.reduce((a, b) => a + b) /
          magneticFieldStrengths.length;
    }

    print(magneticFieldStrengths);

    if (averageStrength < acceptableLowerBound ||
        averageStrength > acceptableUpperBound) {
      return true; // Calibration needed
    }
    return false; // No calibration needed
  }

  double calculateMagneticFieldStrength(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  void listenToMagnetometer() {
    magnetometerEvents.listen((MagnetometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      // Calculate magnetic field strength
      double magneticFieldStrength = calculateMagneticFieldStrength(x, y, z);
      if (magneticValues.length < 6) {
        magneticValues.add(sqrt(x * x + y * y + z * z));
      }
      // print('Magnetic Field Strength: $magneticFieldStrength µT');
    });
  }

  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;
  void listenToMagnetometeronCalibration() {
    double lowerThreshold = 40.0;
    double upperThreshold = 60.0;
    print("insideee");
    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
          double x = event.x;
          double y = event.y;
          double z = event.z;

          // Calculate magnetic field strength
          double magneticFieldStrength = calculateMagneticFieldStrength(x, y, z);

          if (magneticFieldStrength < lowerThreshold ||
              magneticFieldStrength > upperThreshold) {
            accuracyNotifier.value = true;
          } else {
            Future.delayed(Duration(seconds: 3)).then((onValue) {
              _magnetometerSubscription.cancel();
              accuracyNotifier.value = false;
            });
            //showLowAccuracyDialog();
            _timerCompass?.cancel();
          }

          // if(accuracy==false){
          //   print("entereddd");
          //   _magnetometerSubscription.cancel();
          //   _timerCompass?.cancel();
          //   showLowAccuracyDialog();
          // }

          // print('Magnetic Field Strength: $magneticFieldStrength µT');
        });
  }

  void paintUser(String? nearestBeacon, String? polyID,
      {bool speakTTS = true,
        bool render = true,
        bool providePinSelection = false}) async {
    print(widget.directsourceID);
    setState(() {
      showClassB = false;
    });
    print("paintuser $nearestBeacon $polyID $showClassB");
    // Handle direct source ID case
    if (widget.directsourceID.length > 2) {
      nearestBeacon = null;
      polyID = widget.directsourceID;
      widget.directsourceID = '';
    }
    // If nearestBeacon is provided, localize the user to it
    if (nearestBeacon != null && nearestBeacon.isNotEmpty) {
      await _handleBeaconLocalization(
          nearestBeacon!, speakTTS, render, providePinSelection);
    }
    // If polyID is provided, localize the user to the polygon
    else if (polyID != null && polyID.isNotEmpty) {
      await _handlePolygonLocalization(polyID, speakTTS, render);
    }
    // Fallback to global coordinates if neither nearestBeacon nor polyID is available
    else {
      await _handleGlobalCoordinatesLocalization(
          speakTTS, render);
    }

    //   if (!providePinSelection)
    // {
    //   continuousGPSLocalisation();
    // }
    // Reset direct source ID and Land ID
    widget.directLandID = '';
    widget.directsourceID = '';
    recenterMap();
    Homepage.homePageKey.currentState?.hideLoading();
    setState(() {
      isLocalized = false;
      showClassB=true;
    });
    print("paintuser:${showClassB}");
  }

  Timer? continuousGPSLocalisationTimer = null;
  Animation<LatLng>? _initialMarkerAnimation;
  AnimationController? _initialiMarkerAnimationController;

  void continuousGPSLocalisation(){
    print("continuousGPSLocalisation ${StackTrace.current}");
    if(gpsSubscription != null){
      return;
    }
    gpsSubscription = GPSService.locationStream.listen((Location location) {
      gpsBuffer.add(location.latitude, location.longitude);
    }, onError: (error) {
      print("Error receiving GPS data: $error");
    });
    //start beacon scanning
    _initialiMarkerAnimationController!.addListener(_onMarkerAnimationUpdate);
    bluetoothScanAndroidClass.listenToScanUpdates(Building.apibeaconmap);
    continuousGPSLocalisationTimer = Timer.periodic(Duration(seconds: 5), (timer){
      //get beacon here
      String? currentBeacon=bluetoothScanAndroidClass.closestBeaconName;
      bluetoothScanAndroidClass.closestBeaconName = "";
      print("currentBeacon:${currentBeacon}");
      print("SingletonFunctionController.current:${SingletonFunctionController.currentBeacon}");
      if(currentBeacon.isNotEmpty && Building.apibeaconmap[currentBeacon] != null && false)
      {
        //if(tools.calculateAerialDist(UserState.geoLat!, UserState.geoLng!,Building.apibeaconmap[SingletonFunctionController.currentBeacon]!.properties!.latitude!,Building.apibeaconmap[SingletonFunctionController.currentBeacon].properties.latitude) > 10)
        _handleBeaconLocalization(currentBeacon,false, true,false);
      }else{
        gpsBuffer.Print();
        var location = gpsBuffer.getRobustPosition();
        print("location $location");
        //  print("SingletonFunctionController.current location:${location![0]} ${location![1]}");
        if(location != null){
          if(UserState.geoLat == null || UserState.geoLng == null){
            UserState.geoLat = location[0];
            UserState.geoLng = location[1];
          }
          else{
            // if(UserState.geoLat!=location[0] && UserState.geoLng!=location[1] && markers[user.bid]!=null){
            //   _googleMapController.animateCamera(CameraUpdate.zoomTo(19));
            //   onGPSUpdate(location[0],location[1]);
            // }
            _handleGlobalCoordinatesLocalization(false, true, location: location);
            UserState.geoLat=location[0];
            UserState.geoLng=location[1];
          }
        }
      }

      // check if beacon is not null then localise on beacon otherwise gps

    });
  }
  //
  void stopContinuousGPSLocalisation(){
    // stop beacon scanning
    bluetoothScanAndroidClass.stopScan();
    continuousGPSLocalisationTimer?.cancel();
    continuousGPSLocalisationTimer = null;
    gpsSubscription?.cancel(); // <-- This triggers native onCancel()
    gpsSubscription = null;
    // GPSService.dispose();
    try{
      _initialiMarkerAnimationController?.dispose();
    }catch(e){
      print(e);
    }
  }

  void _onMarkerAnimationUpdate() {
    if (!mounted || _initialMarkerAnimation == null) return;
    setState(() {
      LatLng animatedPosition = _initialMarkerAnimation!.value;
      markers[user.bid]![0] = customMarker.move(animatedPosition, markers[user.bid]![0]);
      // print("animatedPosition${animatedPosition}");
      // if (kDebugMode) {
      //   markers[user.bid]?.add(Marker(
      //     markerId: MarkerId("debug"),
      //     position: animatedPosition,
      //     icon: BitmapDescriptor.fromBytes(userlocdebug),
      //     anchor: Offset(0.5, 0.829),
      //   ));
      // }

      circles.clear();
      circles.add(
        Circle(
            circleId: CircleId("circle"),
            center: animatedPosition,
            radius: _animation.value,
            strokeWidth: 1,
            strokeColor: Colors.blue,
            fillColor: Colors.lightBlue.withOpacity(0.2),
            zIndex: 2
        ),
      );
    });
  }
  //
  void onGPSUpdate(double newLat, double newLng) {
    print("onGPSUpdate $onGPSUpdate");
    _initialiMarkerAnimationController!.duration = const Duration(seconds: 7);
    // Step 1: Get the current marker position
    LatLng currentPosition = markers[user.bid]?.isNotEmpty == true
        ? markers[user.bid]![0].position
        : LatLng(user.lat, user.lng);
    LatLng newPosition = LatLng(newLat, newLng);
    print("currentPosition $currentPosition newPosition $newPosition");
    // Step 2: Reset the animation controller to start from 0
    _initialiMarkerAnimationController!.reset();
    // Step 3: Create a NEW animation with new begin/end positions
    _initialMarkerAnimation = LatLngTween(
      begin: currentPosition,   // Where marker currently is
      end: newPosition,          // Where it should move to
    ).animate(CurvedAnimation(
      parent: _initialiMarkerAnimationController!,
      curve: Curves.easeInOut,
    ));
    // Step 4: Start the animation - THIS TRIGGERS THE LISTENER
    _initialiMarkerAnimationController!.forward();
  }

  Future<void> _handleBeaconLocalization(String nearestBeacon, bool speakTTS,
      bool render, bool providePinSelection) async {
    List<Future<void>> apiCalls = [];
    // Wait for all API calls to complete
    SingletonFunctionController.localizedBeacon = nearestBeacon;
    await Future.wait(apiCalls);
    try {
      print("got into beacon localization");
      wsocket.message["AppInitialization"]["localizedOn"] = nearestBeacon;
      // networkManager.ws.updateInitialization(localizedOn: nearestBeacon);
      final beaconData =
      SingletonFunctionController.apibeaconmap[nearestBeacon];
      if (beaconData == null) {
        print("_handleBeaconLocalization: Beacon data not found");
        if (speakTTS) unableToFindLocation();
        return;
      }
      print("Beacon debug:$beaconData");
      print("pinselectionStatus:: ${providePinSelection}");
      final landmarkData =
      await SingletonFunctionController.building.landmarkdata;
      Map<String, Landmarks>? landmarksMapAll = {};
      buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
        print("getStoredAllBuildingID $key");
        await RepositoryManager().getLandmarkDataNew(key).then((value) {
          print("key $key $value");
          landmarksMapAll!.addAll(value.landmarksMap!);
        });
      });
      print("landmarkdata $landmarksMapAll");
      if (landmarkData?.landmarksMap == null) {
        print("_handleBeaconLocalization: Landmark data not available");
        if (speakTTS) unableToFindLocation();
        return;
      }
      if (providePinSelection) {
        print("in pinselectionStatus$providePinSelection");
        Pinselectionlocationmodel pinLocation = Pinselectionlocationmodel(floor: beaconData.floor!, bid: beaconData.buildingID!, lat: double.parse(beaconData.properties!.latitude!), lng: double.parse(beaconData.properties!.longitude!), coordX: beaconData.coordinateX, coordY: beaconData.coordinateY);
        SingletonFunctionController.building.listOfNearbyLandmarksToLocalize = tools.findListOfNearbyLandmarkBLE(pinLocation, landmarkData!.landmarksMap!, maxDistance: 5);
        print("list of nearby landmarks::${SingletonFunctionController.building.listOfNearbyLandmarksToLocalize} ${beaconData} ${landmarkData!.landmarksMap!}");
        if (SingletonFunctionController.building.listOfNearbyLandmarksToLocalize != null){
          detected = false;
          print("got inside this");
          print("${SingletonFunctionController.building.listOfNearbyLandmarksToLocalize!.where((test)=>test.properties!.isWaypoint == false).length}");
          if(SingletonFunctionController.building.listOfNearbyLandmarksToLocalize!.where((test)=>test.properties!.isWaypoint == false).length>1){
            showListOfNearbyLandmarks(SingletonFunctionController.building.listOfNearbyLandmarksToLocalize!);
          }else{
            final userSetLocation = tools.localizefindNearbyLandmark(beaconData, landmarkData!.landmarksMap!);
            print("usersetlocation::${userSetLocation}");
            if (userSetLocation != null){
              initializeUser(userSetLocation, speakTTS: speakTTS, render: render);
            }else{
              if (speakTTS) unableToFindLocation();
            }
          }
          return;
        }else{
          final userSetLocation = tools.localizefindNearbyLandmark(beaconData, landmarkData!.landmarksMap!);
          print("usersetlocation::${userSetLocation}");
          if (userSetLocation != null){
            initializeUser(userSetLocation, speakTTS: speakTTS, render: render);
          }else{
            showToast("not in the list $nearestBeacon");
            if (speakTTS) unableToFindLocation();
          }
          return;
        }
      }
      final userSetLocation = tools.localizefindNearbyLandmark(
          beaconData, landmarkData!.landmarksMap!);

      if (userSetLocation != null) {
        initializeUser(userSetLocation, speakTTS: speakTTS, render: render)
            .then((_) {});
      } else {
        if (speakTTS) unableToFindLocation();
      }
    } catch (e, stackTrace) {
      print("Error during beacon localization: $e\n$stackTrace");
      if (speakTTS) unableToFindLocation();
    }
  }

  Future<void> _handlePolygonLocalization(
      String polyID, bool speakTTS, bool render) async {
    try {
      land? snapshot = await SingletonFunctionController.building.landmarkdata;
      // Collect all API call futures
      final userSetLocation = snapshot?.landmarksMap?[polyID];
      print("polygonlocalization called");
      if (userSetLocation != null) {
        initializeUser(userSetLocation, speakTTS: speakTTS, render: render);
      } else {
        if (speakTTS) unableToFindLocation();
      }
    } catch(e){
      print("Error during polygon localization: $e");
      if (speakTTS) unableToFindLocation();
    }
  }
  StreamSubscription? gpsSubscription;
  final gpsBuffer = GPSBuffer();
  Future<void> _handleGlobalCoordinatesLocalization(
      bool speakTTS, bool render, {List<double>? location}) async {
    print("got into GPS localization $speakTTS $render");
    if (kIsWeb) {
      return;
    }
    if(location == null){
      location = gpsBuffer.getRobustPosition();
      gpsSubscription?.cancel();
      // } catch (e) {
      //   if (widget.directLandID.length <= 2) {
      //     if (speakTTS) unableToFindLocation();
      //   }
      //   return;
      // }
    }

    if (location != null && location.isNotEmpty) {
      UserState.geoLat = location[0];
      UserState.geoLng = location[1];
      print("globalcoord ${UserState.geoLat},${UserState.geoLng}");
      final userSetLocation =
      await getGlobalCoords(LatLng(UserState.geoLat!, UserState.geoLng!));

      if (userSetLocation != null) {
        String polyID = userSetLocation.properties!.polyId!;
        initializeUser(userSetLocation, speakTTS: speakTTS, render: render);
      } else {
        if (speakTTS) unableToFindLocation();
      }
    } else {
      kDebugMode ? showToast("gps stream is not started") : ();
      if (speakTTS) unableToFindLocation();
    }
  }
  void unableToFindLocation(){
    if(!Platform.isAndroid){
      // if(_currentState==AvailabilityState.poweredOn){
      final stackTrace = StackTrace.current;
      print("unableToFindLocation Stack: \n$stackTrace");
      speak("Unable to find your location. Search nearby landmark to find your location",
          _currentLocale);
      showClassB=true;
      showLocationDialog(context);
      SingletonFunctionController.building.qrOpened = true;
      // }else{
      //   _showBluetoothDialog();
      // }
    }else{
      final stackTrace = StackTrace.current;
      print("unableToFindLocation Stack: \n$stackTrace");
      speak("Unable to find your location. Search nearby landmark to find your location",
          _currentLocale);
      showClassB=true;
      showLocationDialog(context);
      SingletonFunctionController.building.qrOpened = true;
    }


    setState(() {});
  }

  void _showBluetoothDialog() {
    // _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: true, // user cannot dismiss by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text("Bluetooth is turned off"),
          content: const Text(
            "Please restart Bluetooth in your device settings to continue.",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                AppSettings.openAppSettings();
                //try{
                //BLEManager();
                //}catch(e){
                // OpenSettingsPlusIOS().settings();
                // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
              ),
              child:  Text("Open Settings",style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }


  Future<void> showListOfNearbyLandmarks(List<Landmarks> landmarks) async {
    SingletonFunctionController.building.floor[landmarks.first.buildingID!] = landmarks.first.floor??0;
    await createRooms(SingletonFunctionController.building.polylinedatamap[landmarks.first.buildingID]!, landmarks.first.floor??0);
    await Future.delayed(Duration(milliseconds: 1000));
    speak(convertTolng("Confirm Your Location Amongst Below Given List", _currentLocale, ''), _currentLocale);
    focusOnPinLandmark(LatLng(double.parse(landmarks.first.properties!.latitude!), double.parse(landmarks.first.properties!.longitude!)));
    for (var landmark in landmarks){
      addNearbyLandmarkMarkers(LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),landmark.sId??"", (landmark.renderDetail?.name ?? landmark.name ?? landmark.element!.subType!??""), !landmark.properties!.isWaypoint, road: landmark.roadName);
    }
  }

  void _announceDirection(String instruction) {
    print("_announceDirection:${instruction}");
    final announcement = "${instruction}";
    SemanticsService.announce(announcement, TextDirection.ltr);
  }

  void localizeOnPinedLandmark() {
    if (PinedLandmark != null) {
      print("PinedLandmark:${PinedLandmark!.name}");
      initializeUser(PinedLandmark!);
    } else {
      unableToFindLocation();
    }
    // continuousGPSLocalisation();
    PinLandmarkPannel.hidePanel();
    setState(() {
      nearbyLandmarks.clear();
      SingletonFunctionController.building.listOfNearbyLandmarksToLocalize =
      null;
    });
  }

  void closePinnedLandmarkPannel() {
    //unableToFindLocation();
    PinLandmarkPannel.hidePanel();
    setState(() {
      nearbyLandmarks.clear();
      SingletonFunctionController.building.listOfNearbyLandmarksToLocalize =
      null;
      PinedLandmark = null;
    });
  }
  bool showClassB = false;
  Future<void> initializeUser(Landmarks userSetLocation,
      {bool speakTTS = true, bool render = true}) async {
    print("from direction header:${isFromLocalize}");
    Homepage.homePageKey.currentState?.locationDetected(userSetLocation);
    tools.setBuildingAngle(SingletonFunctionController.building
        .patchData[userSetLocation.buildingID]!.patchData!.buildingAngle!);
    setState(() {
      buildingAllApi.selectedID = userSetLocation!.buildingID!;
      buildingAllApi.selectedBuildingID = userSetLocation!.buildingID!;
    });
    List<int> localBeconCord = [];
    localBeconCord.add(userSetLocation.coordinateX!);
    localBeconCord.add(userSetLocation.coordinateY!);
    pathState().beaconCords = localBeconCord;
    // beacon? nearestPoint;
    List<double> values = [];

    // if(SingletonFunctionController.apibeaconmap.containsKey(bleManager.finalName)){
    //  nearestPoint=null;
    // }
    //floor alignment
    await SingletonFunctionController.building.landmarkdata!.then((land) {
      if (userSetLocation.floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            SingletonFunctionController
                .building
                .polylinedatamap[userSetLocation.buildingID!]!
                .polyline!
                .floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(userSetLocation.floor!),
            SingletonFunctionController
                .building
                .polylinedatamap[userSetLocation.buildingID!]!
                .polyline!
                .floors!);
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
        values = tools.localtoglobal(
            userSetLocation.coordinateX!,
            userSetLocation.coordinateY!,
            SingletonFunctionController
                .building.patchData[userSetLocation.buildingID!]);
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
        values = tools.localtoglobal(
            userSetLocation.coordinateX!,
            userSetLocation.coordinateY!,
            SingletonFunctionController
                .building.patchData[userSetLocation.buildingID!]);
      }
    });
    mapState.target = LatLng(values[0], values[1]);
    user.bid = userSetLocation.buildingID!;
    print("setting userbid ${user.bid}");
    user.locationName = userSetLocation!.renderDetail?.name??userSetLocation!.name ?? userSetLocation!.element!.subType;
    // double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!);
    // double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!);
    // did this change over here UDIT...
    double dist = double.infinity;
    // try {
    //   final beacon = SingletonFunctionController.apibeaconmap[bleManager.finalName];
    //   dist = tools.calculateDistance([
    //     nearestPoint!.coordinateX!,
    //     nearestPoint!.coordinateY!
    //   ], [beacon!.coordinateX!, beacon!.coordinateY!]);
    //   print("distance between points :${dist}");
    // }catch(e){
    //   print("nearest beacon is not in the list");
    // }
    user.coordX = userSetLocation.coordinateX!;
    user.coordY = userSetLocation.coordinateY!;
    List<double> ls = tools.localtoglobal(
        user.coordX,
        user.coordY,
        SingletonFunctionController
            .building.patchData[userSetLocation.buildingID]);
    user.lat = userSetLocation.properties?.doorLat != null ? double.parse(userSetLocation.properties!.doorLat!):ls[0];
    user.lng = userSetLocation.properties?.doorLng != null ? double.parse(userSetLocation.properties!.doorLng!):ls[1];
    if (userSetLocation!.doorX != null) {
      print(
          "usercoord fetched ${user.coordX},${user.coordY}   ${userSetLocation!.doorX!} ${userSetLocation!.doorY!}");
      user.coordX = userSetLocation!.doorX!;
      user.coordY = userSetLocation!.doorY!;
      List<double> latlng = tools.localtoglobal(
          userSetLocation!.doorX!,
          userSetLocation!.doorY!,
          SingletonFunctionController
              .building.patchData[userSetLocation!.buildingID]);
      user.lat = userSetLocation.properties?.doorLat != null ? double.parse(userSetLocation.properties!.doorLat!):latlng[0];
      user.lng = userSetLocation.properties?.doorLng != null ? double.parse(userSetLocation.properties!.doorLng!):latlng[1];
      user.locationName =
          userSetLocation!.renderDetail?.name??userSetLocation!.name ?? userSetLocation!.element!.subType;
    } else if (userSetLocation!.doorX == null) {
      user.coordX = userSetLocation!.coordinateX!;
      user.coordY = userSetLocation!.coordinateY!;
      List<double> latlng = [
        double.parse(userSetLocation.properties!.latitude!),
        double.parse(userSetLocation.properties!.longitude!)
      ];
      user.lat = userSetLocation.properties?.doorLat != null ? double.parse(userSetLocation.properties!.doorLat!):latlng[0];
      user.lng = userSetLocation.properties?.doorLng != null ? double.parse(userSetLocation.properties!.doorLng!):latlng[1];
      user.locationName =
          userSetLocation!.renderDetail?.name??userSetLocation!.name ?? userSetLocation!.element!.subType;
    }
    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;
    // if(dist<8){
    //   if(nearestPoint!=null){
    //     user.showcoordX=nearestPoint.coordinateX!;
    //     user.showcoordY=nearestPoint.coordinateY!;
    //     List<double> latlng = tools.localtoglobal(
    //         nearestPoint.coordinateX!,
    //         nearestPoint.coordinateY!,
    //         SingletonFunctionController
    //             .building.patchData[userSetLocation!.buildingID]);
    //     user.coordX=nearestPoint.coordinateX!;
    //     user.coordY=nearestPoint.coordinateY!;
    //     user.lat=latlng[0];
    //     user.lng=latlng[1];
    //   }
    print("usercoords :${user.coordX} ${user.coordY}");
    // }
    UserState.cols = SingletonFunctionController.building.floorDimenssion[
    userSetLocation.buildingID]![userSetLocation.floor]![0];
    UserState.rows = SingletonFunctionController.building.floorDimenssion[
    userSetLocation.buildingID]![userSetLocation.floor]![1];
    UserState.lngCode = _currentLocale;
    UserState.reroute = reroute;
    UserState.closeNavigation = closeNavigation;
    UserState.alignMapToPath = alignMapToPath;
    UserState.startOnPath = startOnPath;
    UserState.speak = speak;
    UserState.paintMarker = paintMarker;
    UserState.createCircle = updateCircle;
    UserState.autoRecenter = recenterMap;
    UserState.addDebugMarkers = addDebugMarkers;
    UserState.clearDebugMarkers = cleardebugMarkers;
    UserState.renderHere = renderHere;
    UserState.recenterMap = recenterMap;
    List<int> userCords = [];
    userCords.add(user.coordX);
    userCords.add(user.coordY);
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    List<int> newUserCord = [
      user.coordX + transitionValue[0],
      user.coordY + transitionValue[1]
    ];
    user.floor = userSetLocation.floor!;
    user.key = userSetLocation.properties!.polyId!;
    user.initialallyLocalised = true;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    Future.delayed(Duration(seconds: 2)).then((_){
      _announceDirection(
          'You are near ${user.locationName}, ${LocaleData.floor.getString(
              context)} ${user.floor}');
    });
    // Create the animation
    await initializeMarkers();
    setState((){
      // markers.clear();
      // circles.clear();
      //List<double> ls=tools.localtoglobal(user.coordX, user.coordY,patchData: SingletonFunctionController.building.patchData[SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID]);
      if (render){
        print("entered here ${markers[user.bid]}");
        // if(markers[user.bid]!=null){
        //   onGPSUpdate(user.lat,user.lng);
        // }else{
        markers.clear();
        markers.putIfAbsent(user.bid, ()=>[]);
        markers[user.bid]?.add(Marker(
          markerId: MarkerId("UserLocation"),
          position: LatLng(user.lat, user.lng),
          icon: BitmapDescriptor.fromBytes(userloc),
          anchor: Offset(0.5, 0.829),
        ));
        if (!kIsWeb && kDebugMode) {
          markers[user.bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
        }
        // }
      }
      else {
        user.moveToFloor(userSetLocation.buildingID!, userSetLocation.floor!);
      }
      // if (render) {
      //   print("entered here");
      //   markers.putIfAbsent(user.bid, () => []);
      //   updateMarkerPosition(LatLng(user.lat, user.lng),user.bid,userloc);
      //   // markers[user.bid]?.add(Marker(
      //   //   markerId: MarkerId("UserLocation"),
      //   //   position: LatLng(user.lat, user.lng),
      //   //   icon: BitmapDescriptor.fromBytes(userloc),
      //   //   anchor: Offset(0.5, 0.829),
      //   //   ehfikr
      //   // ));
      //   // if (!kIsWeb && kDebugMode) {
      //   //   markers[user.bid]?.add(Marker(
      //   //     markerId: MarkerId("debug"),
      //   //     position: LatLng(user.lat, user.lng),
      //   //     icon: BitmapDescriptor.fromBytes(userlocdebug),
      //   //     anchor: Offset(0.5, 0.829),
      //   //   ));
      //   // }
      //   circles.add(
      //     Circle(
      //         circleId: CircleId("circle"),
      //         center: LatLng(user.lat, user.lng),
      //         radius: _animation.value,
      //         strokeWidth: 1,
      //         strokeColor: Colors.blue,
      //         fillColor: Colors.lightBlue.withOpacity(0.2),
      //         zIndex: 2
      //     ),
      //   );
      // }else{
      //   user.moveToFloor(userSetLocation.floor!);
      // }

      if (widget.directLandID.length < 2 && speakTTS && isFromLocalize) {
        SingletonFunctionController.building
            .floor[userSetLocation.buildingID!] = userSetLocation.floor!;
        createRooms(
            SingletonFunctionController
                .building.polylinedatamap[userSetLocation.buildingID]!,
            userSetLocation.floor!);
      }
      if (isFromLocalize) {
        SingletonFunctionController.building.landmarkdata!.then((value) {
          print("userSetLocation!.floor! ${userSetLocation.floor!}");
          createMarkers(value, userSetLocation!.floor!, user.bid);
        });
      }
    });
    // _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
    //   ..addListener(() {
    //     _updateCircle(user.lat, user.lng);
    //   });
    List<nearestLandInfo> getallnearbylandmark = [];
    // if(localizedBeacon!=null){
    //   await SingletonFunctionController.building.landmarkdata!.then((value) {
    //     getallnearbylandmark = tools.localizefindAllNearbyLandmark(
    //         localizedBeacon!, value.landmarksMap!);
    //   });
    // }
    double value = 0;
    double value2 = 0;
    print("value is 1 $value");

    if (user.coordX != userSetLocation!.coordinateX! &&
        user.coordY != userSetLocation!.coordinateY!) {
      value = tools.calculateAngle2([user.coordX, user.coordY], newUserCord,
          [userSetLocation!.coordinateX!, userSetLocation!.coordinateY!]);
    }

    print("value is 2 $value ${[user.coordX, user.coordY]} $newUserCord ${[
      userSetLocation!.coordinateX!,
      userSetLocation!.coordinateY!
    ]}");
    double distBetweenLandmarks = 0.0;
    if (getallnearbylandmark.length > 2) {
      distBetweenLandmarks = tools.calculateDistance([
        user.coordX,
        user.coordY
      ], [
        getallnearbylandmark[1].coordinateX!,
        getallnearbylandmark[1].coordinateY!
      ]);
      value2 = tools.calculateAngle2(
          [user.coordX, user.coordY],
          newUserCord,
          [
            getallnearbylandmark[1].coordinateX!,
            getallnearbylandmark[1].coordinateY!
          ]);
    }
    print("value is 3 $value");
    mapState.zoom = 22;
    if (value != 0 && value < 45) {
      value = value + 45;
    }

    if (value2 < 45) {
      value2 = value2 + 45;
    }

    print("value is 4 $value");

    String? finalvalue = value == 0
        ? null
        : tools.angleToClocksForNearestLandmarkToBeacon(value, context);

    String? finalvalue2 = value2 == 0
        ? null
        : tools.angleToClocksForNearestLandmarkToBeacon(value2, context);

    if (user.isnavigating == false && speakTTS) {
      detected = true;
      if (!_isExploreModePannelOpen && speakTTS) {
        _isBuildingPannelOpen = true;
      }
      nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
    }
    setState(() {
      showClassB=true;
    });
    if (speakTTS && isFromLocalize && render) {
      if (finalvalue == null) {
        speak(
            convertTolng(
                "You are on ${tools.numericalToAlphabetical(user.floor)} floor, near ${user.locationName}",
                _currentLocale,
                ''),
            _currentLocale);
      } else {
        if (getallnearbylandmark.length > 2 &&
            distBetweenLandmarks <= 20 &&
            finalvalue2 != null) {
          speak(
              "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)} and ${getallnearbylandmark[1].name} is on your ${LocaleData.properties5[finalvalue2]?.getString(context)}",
              _currentLocale);
        } else {
          speak(
              convertTolng(
                  "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)}",
                  _currentLocale,
                  finalvalue),
              _currentLocale);
        }
      }
    }

    if (speakTTS) {
      List<double> lvalue = tools.localtoglobal(
          (userSetLocation.doorX ?? userSetLocation.coordinateX!).toInt(),
          (userSetLocation.doorY ?? userSetLocation.coordinateY!).toInt(),
          SingletonFunctionController.building.patchData[user.bid]);

      if(userSetLocation.properties?.doorLng != null){
        lvalue = [double.parse(userSetLocation.properties!.doorLat!), double.parse(userSetLocation.properties!.doorLng!)];
      }

      if (SingletonFunctionController.apibeaconmap[lastBeaconValue] != null &&
          isFromLocalize) {
        List<double> uvalue = tools.localtoglobal(
            SingletonFunctionController
                .apibeaconmap[lastBeaconValue]!.coordinateX!
                .toInt(),
            SingletonFunctionController
                .apibeaconmap[lastBeaconValue]!.coordinateY!
                .toInt(),
            SingletonFunctionController.building.patchData[user.bid]);

        LatLng currentMarkerPosition = LatLng(lvalue[0], lvalue[1]);
        LatLng newMarkerPosition = LatLng(uvalue[0], uvalue[1]);

        _markerAnimation = LatLngTween(
          begin: currentMarkerPosition,
          end: newMarkerPosition,
        ).animate(CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeInOut,
        ));
        // Start the animation
        _animationController!.forward(from: 0);
        _animationController!.addListener(() {
          setState(() {
            // Update marker position as animation progresses
            markers[user.bid]?[0] = customMarker.move(
              _markerAnimation!.value,
              markers[user.bid]![0],
            );
          });
        });
      }

      mapState.zoom = 22.0;
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lvalue[0], lvalue[1]), // Use the last known target
            zoom: 22, // Use the last known zoom
            bearing: user.theta, // Update the bearing
          ),
        ),
      );
    }

    // Future.delayed(Duration(milliseconds: 5000)).then((value){
    //   if(!kIsWeb && isCalibrationNeeded(magneticValues) && UserState.lowCompassAccuracy==false){
    //     UserState.lowCompassAccuracy=true;
    //     speak("low accuracy found.Please calibrate your device", _currentLocale);
    //     showLowAccuracyDialog();
    //   }
    // });
    //nearestPoint=null;
  }

  void updateMarkerPosition(LatLng newPosition, String bid, Uint8List userloc) {
    if (_oldPosition == null) {
      _oldPosition = newPosition;
      markers[bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: newPosition,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      setState(() {});
      return;
    }
    _newPosition = newPosition;
    final tween = LatLngTween(begin: _oldPosition!, end: _newPosition!);
    _moveAnimation = tween.animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {
          markers[bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: _moveAnimation.value,
            icon: BitmapDescriptor.fromBytes(userloc),
            anchor: Offset(0.5, 0.829),
          ));
        });
      });
    _moveController.forward(from: 0);
    _oldPosition = _newPosition;
  }

  bool _isExpanded = false;
  String? qrText;

  void showDestinationDialog(BuildContext context, String text) {
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${text}",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff000000),
                    height: 24 / 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text('Close', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLocationDialog(BuildContext context) {
    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      //speak("${LocaleData.scanQr.getString(context)}", _currentLocale);
      double screenWidth = MediaQuery.of(context).size.width;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 15, right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Choose Your Location",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff000000),
                      height: 24 / 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "We couldn't detect your location",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffa1a1aa),
                      height: 20 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Semantics(
                    label: "Search your current location",
                    child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewSearchPage(
                                hintText: 'Source location',
                                voiceInputEnabled: false,
                                user: user,
                              ),
                            ),
                          ).then((value) {
                            setState(() {
                              if (value != null) {
                                Navigator.of(context).pop();
                                paintUser(null, value);
                              } else {}
                            });
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              isSemanticEnabled
                                  ? ""
                                  : 'Search your current location',
                              style: TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffa1a1aa),
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 20),
                  // Text(
                  //   "Or",
                  //   style: const TextStyle(
                  //     fontFamily: "Roboto",
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w400,
                  //     color: Color(0xffa0a0a0),
                  //     height: 20 / 14,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // SizedBox(height: 16),
                  // Text(
                  //   "Scan the Nearby QR Code",
                  //   style: const TextStyle(
                  //     fontFamily: "Roboto",
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w400,
                  //     color: Color(0xff18181b),
                  //     height: 25 / 16,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // SizedBox(height: 10),
                  // Center(
                  //   child: Semantics(
                  //     label: "Open Qr Scanner to know your location",
                  //     child: GestureDetector(
                  //       onTap: () async {
                  //         setState(() {
                  //           _isExpanded = !_isExpanded;
                  //         });
                  //         Navigator.of(context).pop();
                  //         await Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => QRViewExample(
                  //                     frmMainPage: false,
                  //                   )),
                  //         ).then((value) {
                  //           setState(() {
                  //             isLoading = false;
                  //             isBlueToothLoading = false;
                  //           });
                  //           paintUser(null, value);
                  //         });
                  //         //Navigator.of(context).pop();
                  //         // if (result != null) {
                  //         //   setState(() {
                  //         //     qrText = result;
                  //         //   });
                  //         //
                  //         //   // Handle the scanned QR code text
                  //         // }else{
                  //         //
                  //         // }
                  //       },
                  //       child: AnimatedContainer(
                  //         duration: Duration(seconds: 3),
                  //         width: _isExpanded ? 120 : 80,
                  //         height: _isExpanded ? 120 : 80,
                  //         decoration: BoxDecoration(
                  //           border: Border.all(color: Colors.teal),
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //         child: Icon(Icons.qr_code_scanner,
                  //             size: 50, color: Colors.teal),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child:
                      Text('Skip', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  bool accuracy = false;
  ValueNotifier<bool> accuracyNotifier = ValueNotifier<bool>(true);

  void showLowAccuracyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return AlertDialog(
                title: Text("Low Compass Accuracy"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/calibrate.gif'),
                    // Use ValueListenableBuilder to listen to accuracyNotifier changes
                    ValueListenableBuilder<bool>(
                      valueListenable: accuracyNotifier,
                      builder: (context, accuracy, child) {
                        return RichText(
                          text: TextSpan(
                            text: "Compass accuracy:",
                            style: TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${accuracy == true ? "Low" : "High"}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                  accuracy == true ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      setState(() {
                        magneticValues.clear();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  // void showLowAccuracyDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //
  //       return StatefulBuilder(builder: (BuildContext context, StateSetter setStateDialog){
  //
  //         return AlertDialog(
  //           title: Text("Low Compass Accuracy"),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Image.asset('assets/calibrate.gif'),
  //               RichText(text: TextSpan(text: "Compass accuracy:",style: TextStyle(color: Colors.black), children: <TextSpan>[
  //                 TextSpan(
  //                     text: '${accuracy==true?"Low":"High"}', style: TextStyle(fontWeight: FontWeight.bold,color: accuracy==true?Colors.red:Colors.green)),
  //               ],),)
  //               // Text("Compass accuracy:${_accuracy==true?"Low":"High"}",style: TextStyle(color: _accuracy==true?Colors.red:Colors.green),),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               child: Text("OK"),
  //               onPressed: () {
  //                 setState(() {
  //                   magneticValues.clear();
  //                 });
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  //
  //
  //     },
  //   );
  // }

  void moveUser() async {
    List<double> lvalue = [user.lat, user.lng];
    LatLng userlocation = LatLng(lvalue[0], lvalue[1]);
    mapState.target = LatLng(userlocation.latitude, userlocation.longitude);
    mapState.zoom = 21.0;
    _googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        userlocation,
        20, // Specify your custom zoom level here
      ),
    );
    setState(() {
      markers.clear();
      markers.putIfAbsent(user.bid, () => []);
      markers[user.bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: userlocation,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      if (!kIsWeb && kDebugMode) {
        markers[user.bid]?.add(Marker(
          markerId: MarkerId("debug"),
          position: userlocation,
          icon: BitmapDescriptor.fromBytes(userlocdebug),
          anchor: Offset(0.5, 0.829),
        ));
      }
    });
    updateCircle(lvalue[0], lvalue[1]);
    Future.delayed(Duration(seconds: 1)).then((onValue) {
      recenterMap();
    });
  }

  void autoreroute({String? acc}) {
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      fitPolygonInScreen(patch.first);
    });
    Future.delayed(Duration(seconds: 3)).then((value) {
      if (!rerouting) {
        setState(() {
          rerouting = true;
        });
        //  if(user.isnavigating==false){
        clearPathVariables();
        // }
        PathState.clear();
        PathState.sourceX = user.coordX;
        PathState.sourceY = user.coordY;
        PathState.sourceLat = user.lat;
        PathState.sourceLng = user.lng;
        PathState.sourceBid = user.bid;
        user.showcoordX = user.coordX;
        user.showcoordY = user.coordY;
        PathState.sourceFloor = user.floor;

        PathState.sourceName = "Your current location";

        SingletonFunctionController.building.landmarkdata!.then((value) async {
          await calculateroute(value.landmarksMap!,
              accessibleby: acc ?? PathState.accessiblePath,
              autoStart: true)
              .then((value) {
            // print("autoreroute ${PathState.path}");
            // if (PathState.path.isNotEmpty) {
            //   user.pathobj = PathState;
            //   user.path = [
            //     ...PathState.path[PathState.sourceFloor]!,
            //     ...PathState.path[PathState.destinationFloor]!,
            //   ];
            //   user.cellPath = PathState.singleCellListPath;
            //   user.pathobj.index = 0;
            //   user.isnavigating = true;
            //   user.temporaryExit = false;
            //   user.moveToStartofPath(context).then((value) {
            //     setState(() {
            //       if (markers.length > 0) {
            //         markers[user.bid]?[0] = customMarker.move(
            //             LatLng(
            //                 tools.localtoglobal(
            //                     user.showcoordX.toInt(),
            //                     user.showcoordY.toInt(),
            //                     SingletonFunctionController
            //                         .building.patchData[user.bid])[0],
            //                 tools.localtoglobal(
            //                     user.showcoordX.toInt(),
            //                     user.showcoordY.toInt(),
            //                     SingletonFunctionController
            //                         .building.patchData[user.bid])[1]),
            //             markers[user.bid]![0]);
            //       }
            //     });
            //   });
            //   _isRoutePanelOpen = false;
            //   SingletonFunctionController.building.selectedLandmarkID = null;
            //   _isnavigationPannelOpen = true;
            setState(() {
              _isreroutePannelOpen = false;
            });
            startNavigation();
            //   int numCols = SingletonFunctionController
            //       .building.floorDimenssion[PathState.sourceBid]![
            //   PathState.sourceFloor]![0]; //floor length
            //   double angle = tools.calculateAngleBWUserandPath(
            //       user, PathState.path[PathState.sourceFloor]![1], numCols);
            //   if (angle != 0) {
            //     speak(
            //         "${LocaleData.turn.getString(context)} " +
            //             LocaleData.getProperty5(
            //                 tools.angleToClocks(angle, context), context),
            //         _currentLocale);
            //   } else {}
            //
            //   mapState.tilt = 50;
            //
            //   mapState.bearing = tools.calculateBearing([
            //     user.lat,
            //     user.lng
            //   ], [
            //     PathState.singleCellListPath[user.pathobj.index + 1].lat,
            //     PathState.singleCellListPath[user.pathobj.index + 1].lng
            //   ]);
            //   _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            //     CameraPosition(
            //         target: mapState.target,
            //         zoom: mapState.zoom,
            //         bearing: mapState.bearing!,
            //         tilt: mapState.tilt),
            //   ));
            // } else {
            //   print("autostarting");
            //   setState(() {
            //     //_isreroutePannelOpen = false;
            //     _isLandmarkPanelOpen = false;
            //     _isBuildingPannelOpen = false;
            //     // _isRoutePanelOpen = true;
            //   });
            // }
          });
        });
        rerouting = false;
      }
    });
  }

  void reroute({String? acc}) {
    final stackTrace = StackTrace.current;
    print("reroute Stack: \n$stackTrace");
    _isnavigationPannelOpen = false;
    _isRoutePanelOpen = false;
    _isLandmarkPanelOpen = false;
    _isreroutePannelOpen = true;
    user.isnavigating = false;
    user.temporaryExit = true;

    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;
    incrementRerouteCount();
    setState(() {
      onStart = false;
      startingNavigation = false;
      if (markers.length > 0) {
        List<double> dvalue = tools.localtoglobal(
            user.coordX.toInt(),
            user.coordY.toInt(),
            SingletonFunctionController.building.patchData[user.bid]);
        markers[user.bid]?[0] = customMarker.move(
            LatLng(dvalue[0], dvalue[1]), markers[user.bid]![0]);
      }
    });
    if (acc != null) {
      speak("${LocaleData.changingaccessiblepath.getString(context)}",
          _currentLocale);
    } else {
      speak("${LocaleData.reroute.getString(context)}", _currentLocale);
    }
    if (acc != null) {
      PathState.accessiblePath = acc;
      PathState.clearforaccessiblepath();
    }
    autoreroute(acc: acc);
  }

  Future<void> requestBluetoothConnectPermission() async {
    final PermissionStatus permissionStatus =
    await Permission.bluetoothScan.request();
    if (permissionStatus.isGranted) {
      wsocket.message["deviceInfo"]["sensors"]["BLE"] = true;
      wsocket.message["deviceInfo"]["permissions"]["BLE"] = true;
      // networkManager.ws.updateSensorStatus(ble: true);
      // networkManager.ws.updatePermissions(ble: true);
      //widget.bluetoothGranted = true;
      // Permission granted, you can now perform Bluetooth operations
    } else {
      wsocket.message["deviceInfo"]["sensors"]["BLE"] = false;
      wsocket.message["deviceInfo"]["permissions"]["BLE"] = false;
      // networkManager.ws.updateSensorStatus(ble: false);
      // networkManager.ws.updatePermissions(ble: false);
      // Permission denied, handle accordingly
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      wsocket.message["deviceInfo"]["sensors"]["location"] = true;
      wsocket.message["deviceInfo"]["permissions"]["location"] = true;
      // networkManager.ws.updateSensorStatus(location: true);
      // networkManager.ws.updatePermissions(location: true);
    } else {
      wsocket.message["deviceInfo"]["sensors"]["location"] = false;
      wsocket.message["deviceInfo"]["permissions"]["location"] = false;
      // networkManager.ws.updateSensorStatus(location: false);
      // networkManager.ws.updatePermissions(location: false);
    }
  }

  List<FilterInfoModel> landmarkListForFilter = [];
  bool isLoading = false;
  HashMap<String, beacon> resBeacons = HashMap();
  bool isBlueToothLoading = false;
  // Initially set to true to show loader
  LatLng? _userLocation;
  double? _accuracy;
  Future<void> _cation() async {
    Position position =

    //Position(longitude: 77.10259, latitude:  28.947595, timestamp: DateTime.now(), accuracy: 10, altitude: 1, altitudeAccuracy: 100, heading: 10, headingAccuracy: 100, speed: 100, speedAccuracy: 100);

    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _accuracy = position.accuracy;
      UserState.geoLat = position.latitude;
      UserState.geoLng = position.longitude;
      print("positionnn");
      print(_accuracy);
      print(position);
      print(UserState.geoLat);
      print(UserState.geoLng); // Get accuracy in meters
    });

    // Move the map camera to the user's location
    _googleMapController.animateCamera(CameraUpdate.newLatLng(_userLocation!));
  }

  void _updateProgress() {
    const onsec = const Duration(seconds: 1);
    Timer.periodic(onsec, (Timer t) {
      setState(() {
        _progressValue += 0.08;
        if (_progressValue.toStringAsFixed(1) == '1.0') {
          t.cancel();
          return;
        }
      });
    });
  }

  bool isBinEmpty() {
    for (int i = 0; i < SingletonFunctionController.btadapter.BIN.length; i++) {
      if (SingletonFunctionController.btadapter.BIN[i] != null &&
          SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty) {
        // If any bin is not empty, return false
        return false;
      }
    }
    // If all bins are empty, return true
    return true;
  }

  SingletonFunctionController controller = SingletonFunctionController();
  void apiCalls(context) async {
    var exhibitors;
    var categories;
    var sessions;
    var subEvents;
    List<String> itterated = [];
    NavigationAPIController apiController = NavigationAPIController(
        createPatch: createPatch,
        findCentroid: findCentroid,
        createotherPatch: createotherPatch,
        createRooms: createRooms,
        createARPatch: createARPatch,
        createotherARPatch: createotherARPatch,
        createMarkers: createMarkers);

    // try{
    //   await DataVersionApi().fetchDataVersionApiData(buildingAllApi.selectedBuildingID);
    // }catch(e){
    //   Navigator.pushReplacement(context, MaterialPageRoute(
    //       builder: (context) => const SomethingWentWrongPage(
    //         errorMessage: 'We couldn\'t load the data. Please check your internet connection.',
    //       )));
    // }

    _updateProgress();
    setState(() {
      resBeacons = SingletonFunctionController.apibeaconmap;
    });

    buildingAllApi.globalBuildingIDS.forEach((id, location) async {
      itterated.add(id);
      // try {
      // var globalData = await GlobalAnnotation().fetchGlobalAnnotationData(id);
      var globalData = await RepositoryManager().getGlobalAnnotationDataNew(id);
      print("globalData ${globalData.runtimeType}");

      GlobalAnnotationController controller = GlobalAnnotationController(
          data: globalData,
          polygonTap: polygonTap,
          apiController: apiController);

      await apiController.patchAPIController(id, true);

      polylinedata? polyline = controller.wrapPolyline();
      if (polyline != null) {
        await apiController.polylineAPIController(id, false,
            polylineData: polyline);
      }

      List<Landmarks>? landmarks =
      await controller.wrapLandmarks(polyline: polyline);
      if (landmarks != null && landmarks.isNotEmpty) {
        var obj = {
          "landmarkExist": true,
          "landmarks": landmarks.map((e) => e.toJson()).toList()
        };
        await apiController.landmarkAPIController(id, false,
            landmarkData: land.fromJson(obj), exhibitors: exhibitors, categories: categories, sessions: sessions, subEvents: subEvents);
      }
      return;
      // }catch(e){
      //
      // }
    });

    if (!buildingAllApi.globalBuildingIDS.keys
        .contains(buildingAllApi.selectedBuildingID)) {
      print(
          "buildingAllApi.selectedBuildingID ${buildingAllApi.selectedBuildingID}");
      await apiController.patchAPIController(
          buildingAllApi.selectedBuildingID, true);
      await apiController.polylineAPIController(
          buildingAllApi.selectedBuildingID, true);
      await apiController.landmarkAPIController(
          buildingAllApi.selectedBuildingID, true,
          exhibitors: exhibitors, categories: categories, sessions: sessions, subEvents: subEvents);
      itterated.add(buildingAllApi.selectedBuildingID);
    }

    List<String> ids = buildingAllApi.getStoredAllBuildingID().keys.toList();
    print("ids $ids");
    try {
      var outBuildingData = await outBuilding().outbuilding(ids);
      // var outBuildingData = await RepositoryManager().getCampusData(ids);
      buildingAllApi.outBuildingData = outBuildingData;
      if (outBuildingData != null) {
        print(
            "outBuildingData:${outBuildingData.data!.campusId} ${buildingAllApi.outBuildingData!.data!.globalAnnotation!}");
        buildingAllApi.outdoorID = outBuildingData.data!.campusId!;
        buildingAllApi.allBuildingID[outBuildingData.data!.campusId!] =
            LatLng(0.0, 0.0);
      }
    } catch (e) {
      print("outdoor building catch ${e}");
    }

    print(
        "buildingAllApi.getStoredAllBuildingID() ${buildingAllApi.getStoredAllBuildingID().length} ${buildingAllApi.getStoredAllBuildingID().keys}");
    Future<void> allBuildingCalls = Future.wait(
        buildingAllApi.getStoredAllBuildingID().entries.map((entry) async {
          var key = entry.key;

          // try{
          if (key == buildingAllApi.outdoorID &&
              buildingAllApi.outBuildingData != null &&
              buildingAllApi.outBuildingData!.data!.globalAnnotation!) {
            print("Globalannotationcheck${key}");
            // try {
            //   var globalData = await GlobalAnnotation().fetchGlobalAnnotationData(key);
            var globalData = await RepositoryManager().getGlobalAnnotationDataNew(key);
            print("globalData ${globalData.runtimeType}");
            Building.GlobalAnnotation = globalData;
            GlobalAnnotationController controller = GlobalAnnotationController(
                data: globalData,
                polygonTap: polygonTap,
                apiController: apiController);
            controller.wrapPatch();

            polylinedata? polyline = controller.wrapPolyline();
            if (polyline != null) {
              await apiController.polylineAPIController(key, false,
                  polylineData: polyline);
            }

            //closing for a while
            List<Landmarks>? landmarks = await controller.wrapLandmarks(polyline: polyline);

            if (landmarks != null && landmarks.isNotEmpty) {
              var obj = {
                "landmarkExist": true,
                "landmarks": landmarks.map((e) => e.toJson()).toList()
              };
              await apiController.landmarkAPIController(key, false, landmarkData: land.fromJson(obj), exhibitors: exhibitors, categories: categories, sessions: sessions, subEvents: subEvents);
              createMarkers(land.fromJson(obj), 0, key);
            }

            List<PathModel>? waypoints = controller.wrapWayPoint();
            if (waypoints != null) {
              Building.waypoint[buildingAllApi.outdoorID] = waypoints;
            }

            Set<Polygon>? campusRender = await controller.renderCampus();
            if(campusRender != null){
              blockLayer(campusRender);
            }
            print("outDoorGlobalBlock ${outDoorGlobalBlock.length}");
            return;
            // } catch (e) {}
          }
          try {
            // var waypointData = await waypointapi().fetchwaypoint(key, outdoor: key == buildingAllApi.outdoorID);
            var waypointData = await RepositoryManager()
                .getWaypointNew(key, key == buildingAllApi.outdoorID);
            Building.waypoint[key] = waypointData.cast<PathModel>();
          } catch (_) {}
          // print("buildingAllApi.selectedBuildingID ${buildingAllApi.selectedBuildingID}");
          if (!itterated.contains(key)) {
            itterated.add(key);
            print("forKeys $key");
            // try {
            //   await DataVersionApi().fetchDataVersionApiData(key);
            // } catch (e) {}
            await apiController.patchAPIController(key, false);
            await apiController.polylineAPIController(key, false);
            await apiController.landmarkAPIController(key, false,
                exhibitors: exhibitors, categories: categories, sessions: sessions, subEvents: subEvents);
            SingletonFunctionController.building.buildingsLoaded = true;
          }
        }));
    print(
        "widget.directLandID.length ${widget.directLandID.length} ${widget.directLandID}");
    print("Checking timer: ${SingletonFunctionController.timer}");
    var time = DateTime.now();

    var landmarkID = widget.directLandID;

    await Future.wait([
      Future.wait([allBuildingCalls]).then((_){
        if(landmarkID.length > 2){
          onLandmarkVenueClicked(landmarkID,
              DirectlyStartNavigation: false);
        }
      }),
      Future.wait([Future.delayed(Duration(seconds:5))]).then((_){
        if (landmarkID.length < 2) {
          print(
              "localize 3 delay ${SingletonFunctionController.SC_LOCALIZED_BEACON}");
          localizeUser(pinSelectionMarker: true);
        } else {
          //got here using a destination qr
          print("localize 4");
          localizeUser(speakTTS: false, pinSelectionMarker: false);
          SingletonFunctionController.building.destinationQr = true;
        }
      })
    ]);
    print("localize user got called..");

    buildingAllApi.setStoredString(buildingAllApi.getSelectedBuildingID());
    if (mounted) {
      setState(() {
        isLoading = false;
        isBlueToothLoading = false;
      });
    }
    // Future.delayed(Duration(seconds: 5));
    try {
      mapClustering.createBitmapMarker();
    } catch (e) {
      print("catch mapClustering $e");
    }
    await renderCampusPatchTransition(
      buildingAllApi.allBuildingID.keys.toList(),
      outdoorID: buildingAllApi.outdoorID,
    );
    // print("blurpath.length${blurPatch.length}");
    // print("blurPatchMarker.length${blurPatchMarker.length}");

    // _produceNameMarker();
  }

  Future<void> blockLayer(Set<Polygon> campusRender) async {
    // globalBlock
    for (var currentPolygon in campusRender) {
      final idValue = currentPolygon
          .polygonId.value; // this gives "Demo Layer - block layer"

      if (idValue.contains("block layer")) {
        print("campus render block layer ${idValue}");
        RegExp regex = RegExp(r"block layer \+(.*?)\s+imageFile \+(.*?)\s+sId \+(.*)");
        Match? match = regex.firstMatch(idValue);

        if (match != null) {
          String part1 = match.group(1)!.trim(); // "A - Block"
          String part2 = match.group(2)!.trim(); // whole filename with GMT+0000
          String part3 = match.group(3)!.trim(); // "12345"
          print("Part1: $part1");
          print("Part2: $part2");
          print("Part2: $part3");
          print("Part 4 ${"${AppConfig.baseUrl}/uploads/$part2"}");

          try {
            final marker = await creator.createUnifiedMarker(
              text: part1,
              imageSource: "${AppConfig.baseUrl}/uploads/$part2",
              layout: MarkerLayout.horizontal,
              textFormat: TextFormat.smartWrap,  // Uses your preferred logic!
              fontSize: 12.0,
            );

            globalBlock.add(currentPolygon);
            List<LatLng> latLngPoints = currentPolygon.points;
            polygonCalculation.landmarkWithPolygonPoints[part3] =
                latLngPoints;
            print("latLngPoints ${polygonCalculation
                .landmarkWithPolygonPoints[part3]}");
            List<LatLng>? calculatedPoints =
            polygonCalculation.getPolygonMajorAxisLatLng(latLngPoints);
            int leftMost = LeftMost().leftMostPoint(
                PointForCenter(calculatedPoints[0].latitude,
                    calculatedPoints[0].longitude, "name"),
                PointForCenter(calculatedPoints[1].latitude,
                    calculatedPoints[1].longitude, "name"),
                mapState.bearing);
            double rotation;
            if (leftMost == -1) {
              rotation = polygonCalculation.calculateBearing(
                  calculatedPoints[0], calculatedPoints[1]);
            } else {
              rotation = polygonCalculation.calculateBearing(
                  calculatedPoints[1], calculatedPoints[0]);
            }
            LatLng positionPoint = polygonCalculation.midpoint(
                calculatedPoints[0], calculatedPoints[1]);

            // print("Centroid: lat=${center.lat}, lng=${center.lng}");
            blockMarker.add(
                Marker(
                    markerId: MarkerId("Indoor Block Layer ${currentPolygon.polygonId.toString()}"),
                    anchor: marker.anchor,
                    position: positionPoint,
                    icon: marker.icon,
                    onTap: (){
                      _googleMapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(positionPoint.latitude, positionPoint.longitude), // Use the last known target
                            zoom: 18, // Use the last known zoom
                            bearing: user.theta, // Update the bearing
                          ),
                        ),
                      );
                    }
                )
            );
          }catch(e){
            print("Unhandled ${e}");
          }

          setState(() {});
          print("blockMarker Check ${blockMarker.length}");
        } else {}

        // print("campus render block layer ${idValue.toString().split("+")[1]}");
      } else if (idValue.contains("Outdoor Block Layer")) {
        final idValue = currentPolygon
            .polygonId.value; // this gives "Demo Layer - block layer"

        print("campus render Outdoor Block Layer ${idValue}");

        RegExp regex = RegExp(r"Outdoor Block Layer \+(.*?)\s+imageFile \+(.*?)\s+sId \+(.*)");
        Match? match = regex.firstMatch(idValue);

        if (match != null) {
          String part1 = match.group(1)!.trim(); // Parking
          String part2 = match.group(2)!.trim(); // null
          String part3 =
          match.group(3)!.trim(); // 68cbf43dacf5cc87e680be0d

          print("Part1: $part1");
          print("Part2: $part2");
          print("Part3: $part3");

          final marker = await creator.createUnifiedMarker(
            text: part1,
            imageSource: "${AppConfig.baseUrl}/uploads/$part2",
            layout: MarkerLayout.horizontal,
            textFormat: TextFormat.smartWrap,  // Uses your preferred logic!
            fontSize: 12.0,
          );
          // MarkerIconWithAnchor markerName =
          //     await HelperClass().bitmapDescriptorFromCenteredText(part1);
          outDoorGlobalBlock.add(currentPolygon);
          List<LatLng> latLngPoints = currentPolygon.points;
          polygonCalculation.landmarkWithPolygonPoints[part3] =
              latLngPoints;
          List<LatLng>? calculatedPoints =
          polygonCalculation.getPolygonMajorAxisLatLng(latLngPoints);
          int leftMost = LeftMost().leftMostPoint(
              PointForCenter(calculatedPoints[0].latitude,
                  calculatedPoints[0].longitude, "name"),
              PointForCenter(calculatedPoints[1].latitude,
                  calculatedPoints[1].longitude, "name"),
              mapState.bearing);
          double rotation;
          if (leftMost == -1) {
            rotation = polygonCalculation.calculateBearing(
                calculatedPoints[0], calculatedPoints[1]);
          } else {
            rotation = polygonCalculation.calculateBearing(
                calculatedPoints[1], calculatedPoints[0]);
          }
          LatLng positionPoint = polygonCalculation.midpoint(
              calculatedPoints[0], calculatedPoints[1]);

          // Convert to Turf Points (GeoJSON format: [lng, lat])
          final features = latLngPoints.map((latLng) {
            return turf.Feature(
              geometry: turf.Point(
                coordinates:
                turf.Position(latLng.longitude, latLng.latitude),
              ),
            );
          }).toList();

          // Create a FeatureCollection
          final collection = turf.FeatureCollection(features: features);

          // Calculate centroid
          final centerFeature = turf.centroid(collection);

          final center = centerFeature.geometry!.coordinates;
          print("Centroid: lat=${center.lat}, lng=${center.lng}");
          outdoorBlockMarker.add(Marker(
              markerId: MarkerId("Outdoor Block Layer ${currentPolygon.polygonId.toString()}"),
              anchor: marker.anchor,
              position: positionPoint,
              icon: marker.icon,
              onTap: (){
                _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(positionPoint.latitude, positionPoint.longitude), // Use the last known target
                      zoom: 18, // Use the last known zoom
                      bearing: user.theta, // Update the bearing
                    ),
                  ),
                );
              }
          ),);
          setState(() {});
        }
      } else {
        // globalCampus.add(currentPolygon);
      }
    }

  }

  void findCentroid(List<Coordinates> vertices, String bid) {
    double xSum = 0;
    double ySum = 0;
    int n = vertices.length;

    for (Coordinates vertex in vertices) {
      xSum += double.parse(vertex.globalRef!.lat!);
      ySum += double.parse(vertex.globalRef!.lng!);
    }

    Building.allBuildingID[bid] = LatLng(xSum / n, ySum / n);
  }

  void _updateCircle(double lat, double lng) {
    // Create a new Tween with the provided begin and end values
    // Optionally update UI or logic with animation value
    if (!mounted || disposed) return;

    final Circle updatedCircle = Circle(
        circleId: CircleId("circle"),
        center: LatLng(lat, lng),
        radius: _animation.value,
        strokeWidth: 0,
        strokeColor: Colors.blue,
        fillColor: Colors.lightBlue.withOpacity(0.2),
        zIndex: 2);
    if (mounted) {
      setState(() {
        circles.removeWhere((circle) => circle.circleId == CircleId("circle"));
        circles.add(updatedCircle);
      });
    }
  }

  void updateCircle(double lat, double lng,
      {double begin = 7, double end = 0}) {
    final stackTrace = StackTrace.current;
    print("Call Stack: \n$stackTrace");
    // Create a new Tween with the provided begin and end values
    _animation = Tween<double>(begin: begin, end: end).animate(_controller)
      ..addListener(() {
        // Optionally update UI or logic with animation value
        final Circle updatedCircle = Circle(
            circleId: CircleId("circle"),
            center: LatLng(lat, lng),
            radius: _animation.value,
            strokeWidth: 1,
            strokeColor: Colors.blue,
            fillColor: Colors.lightBlue.withOpacity(0.2),
            zIndex: 2);
        if (mounted || !disposed) {
          setState(() {
            circles
                .removeWhere((circle) => circle.circleId == CircleId("circle"));
            circles.add(updatedCircle);
          });
        }
      });
    // Start the animation
    _controller.forward(from: 0.0);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the earth in kilometers

    double dLat = degreesToRadians(lat2 - lat1);
    double dLon = degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c; // Distance in kilometers
    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String getRandomString(List<String> stringList) {
    Random random = Random();
    int randomIndex = random.nextInt(stringList.length);
    return stringList[randomIndex];
  }

  String nearestLandmarkToBeacon = "";
  String nearestLandmarkToMacid = "";
  Future<void> localizeUserInCallback({bool speakTTS = true}) async {
    double highestweight = 0;
    String nearestBeacon = "";
    nearestBeacon = SingletonFunctionController.SC_LOCALIZED_BEACON;
    print("localizeUser 2");
    // print("binresult ${SingletonFunctionController.btadapter.BIN}");
    // for (int i = 0;
    // i < SingletonFunctionController.btadapter.BIN.length;
    // i++) {
    //   if (SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty) {
    //     SingletonFunctionController.btadapter.BIN[i]!.forEach((key, value) {
    //       if (value < 0) {
    //         value = value * -1;
    //       }
    //       if (value > highestweight) {
    //         highestweight = value;
    //         nearestBeacon = key;
    //       }
    //     });
    //     break;
    //   }
    // }
    // nearestLandmarkToBeacon = nearestBeacon;
    // nearestLandmarkToMacid = highestweight.toString();
    // sumMap = SingletonFunctionController.btadapter.calculateAverage();
    if (nearestBeacon != "" && Building.apibeaconmap[nearestBeacon] != null) {
      SingletonFunctionController.currentBeacon =
          SingletonFunctionController.SC_LOCALIZED_BEACON;
      print("nearesbeacon:${SingletonFunctionController.currentBeacon}");
    }
  }

  String? parseString(String input) {
    final regex = RegExp(r'Optional\("(.+?)"\)\s+(\d+\.\d+)');
    final match = regex.firstMatch(input);

    if (match != null) {
      final device = match.group(1); // Extracts "IW622"
      return device;
    } else {
      print("No match found!");
      return null;
    }
  }
  String? parseStringT(String input) {
    final regex = RegExp(r'Optional\("(.+?)"\)\s+(\d+\.\d+)');
    final match = regex.firstMatch(input);

    if (match != null) {
      final value = double.tryParse(match.group(2) ?? '0'); // Extracts 6.0 as a double
      return value.toString();
    } else {
      print("No match found!");
      return null;
    }
  }

  Future<void> localizeUser(
      {bool speakTTS = true, bool pinSelectionMarker = false}) async {
    speak("${LocaleData.searchingyourlocation.getString(context)}",
        _currentLocale);
    print("localizeuser StackTrace.current ${StackTrace.current}");
    if(Platform.isIOS){
      BluetoothScanIOSClass.stopScan();
    }
    double beaconWeight = double.infinity;
    String nearestBeacon = "";
    // nearestBeacon = findMaxWeightKey(SingletonFunctionController.btadapter.latesILMap);
    print("singleto nearestBeacon $nearestBeacon ${SingletonFunctionController.currentBeacon}");
    if(Platform.isIOS){
      String receivedStringFromIOS = await BluetoothScanIOSClass.getBestDevice();
      nearestBeacon = parseString(receivedStringFromIOS) ?? "";
      beaconWeight = double.parse(parseStringT(receivedStringFromIOS)??"100.0");
    }else{
      if (await FlutterBluePlus.isOn) {
        if (bleManager.finalName.isNotEmpty) {
          nearestBeacon = bleManager.finalName;
          beaconWeight = bleManager.finalweight;
        } else {
          nearestBeacon = SingletonFunctionController.currentBeacon??'';
          beaconWeight = SingletonFunctionController.currentRssi;
        }
      } else {
        SingletonFunctionController.currentBeacon = "";
      }
    }

    print("beACONWEIGHT:${beaconWeight}");

    // if(beaconWeight.abs() > 95){
    //   nearestBeacon = "";
    //   beaconWeight = double.infinity;
    // }

    setState(() {
      //lastBeaconValue = nearestBeacon;
    });
    // nearestLandmarkToBeacon = nearestBeacon;
    // nearestLandmarkToMacid = highestweight.toString();
    setState(() {
      testBIn = SingletonFunctionController.btadapter.BIN;
      testBIn.forEach((key, value) {
        currentBinSIze.add(value.length);
      });
    });
    print(
        "nearestBeacon:${nearestBeacon} ${SingletonFunctionController.apibeaconmap[nearestBeacon]}");
    wsocket.message["AppInitialization"]["BID"] =
        buildingAllApi.selectedBuildingID;
    wsocket.message["AppInitialization"]["buildingName"] =
    "Research and Innovation Park";
    if (nearestBeacon != "" && Building.apibeaconmap[nearestBeacon] != null) {
      print("indside localizeuser ${isLocalized}");
      SingletonFunctionController.currentBeacon = nearestBeacon;
      buildingAllApi
          .setStoredString(Building.apibeaconmap[nearestBeacon]!.buildingID!);
      buildingAllApi.selectedID =
      Building.apibeaconmap[nearestBeacon]!.buildingID!;
      buildingAllApi.selectedBuildingID =
      Building.apibeaconmap[nearestBeacon]!.buildingID!;
    }
    // await findNearestPoint();
    initialInAppLoading = false;

    paintUser(nearestBeacon, null,
        speakTTS: speakTTS, providePinSelection: pinSelectionMarker);
    Future.delayed(Duration(milliseconds: 1500)).then((value) => {
      _controller.stop(),
    });
    //emptying the bin manually
    for (int i = 0; i < SingletonFunctionController.btadapter.BIN.length; i++) {
      if (SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty) {
        SingletonFunctionController.btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }
    SingletonFunctionController.btadapter.BIN.clear();
    setState(() {});
  }

  String findMaxWeightKey(Map<String, List<int>> data) {
    print("findMaxWeightKey $data");
    Map<String, double> makingAVGofdata = {};
    String maxKey = '';
    double maxAvgWeight = double.negativeInfinity;
    for (var entry in data.entries) {
      String key = entry.key;
      List<int> values = entry.value;
      // Calculate the average weight for this key
      double totalWeight =
      values.map((v) => getWeight(v.abs())).reduce((a, b) => a + b);
      double avgWeight = totalWeight / values.length;
      makingAVGofdata[key] = avgWeight;
      // Update if this key has a greater average weight
      if (avgWeight > maxAvgWeight) {
        maxAvgWeight = avgWeight;
        maxKey = key;
      }
    }
    print("findMaxWeightKey $makingAVGofdata");

    return maxKey;
  }

  double getWeight(int num) {
    if (num <= 65) return 12.0;
    if (num <= 75) return 6.0;
    if (num <= 80) return 4.0;
    if (num <= 85) return 0.5;
    if (num <= 90) return 0.25;
    if (num <= 95) return 0.15;
    return 0.0;
  }

  void callbackFunc() {
    print("callback");
    SingletonFunctionController()
        .executeFunction(buildingAllApi.allBuildingID)
        .then((_) {
      SingletonFunctionController.timer?.whenComplete(() {
        localizeUserInCallback();
        SingletonFunctionController.timer = null;
      });
    });
  }

  String nearbeacon = 'null';
  String weight = "null";
  HashMap<int, HashMap<String, double>> testBIn = HashMap();
  List<nearestLandInfo> getallnearestInfo = [];
  //Map<String, double> sumMap  = HashMap();
  List<int> currentBinSIze = [];
  Map<String, double> sumMap = new Map();
  Map<String, double> sortedsumMapfordebug = new Map();
  String lastBeaconValue = "";
  String EM_lastBeaconValue = "";
  List<Landmarks> EM_NearLandmarks = [];

  // Future<void> exploreModePaintUser(HashMap<String, beacon> apibeaconmap, Map<String, Landmarks> EM_buildingLandmark) async{
  //   print("BluetoothScanAndroidClass.EM_RSSI_VALUES");
  //   print(BluetoothScanAndroidClass.EM_RSSI_VALUES);
  //   print(BluetoothScanAndroidClass.EM_DEVICE_NAME);
  //   print(BluetoothScanAndroidClass.EM_RSSI_WEIGHT);
  //   BluetoothScanAndroidClass.EM_RSSI_AVERAGE = bluetoothScanAndroidClass.calculateAverageFromRssi(BluetoothScanAndroidClass.EM_RSSI_VALUES, BluetoothScanAndroidClass.EM_DEVICE_NAME, BluetoothScanAndroidClass.EM_RSSI_WEIGHT);
  //   String closestDeviceDetails = bluetoothScanAndroidClass.EM_findLowestRssiDevice(BluetoothScanAndroidClass.EM_RSSI_AVERAGE);
  //   beacon EM_NEAREST_BEACON_VALUE = apibeaconmap[closestDeviceDetails]!;
  //
  //   print("exploreModePaintUser");
  //   final Uint8List iconMarker = await getImagesFromMarker('assets/DirectionInstruction_sourceIcon.png', 85);
  //
  //   if(EM_NEAREST_BEACON_VALUE.name != EM_lastBeaconValue){
  //     _exploreModeMarker.clear();
  //     EM_NearLandmarks = tools.EM_localizefindAllNearbyLandmark(EM_NEAREST_BEACON_VALUE, EM_buildingLandmark);
  //     EM_NearLandmarks.forEach((landmark){
  //       List<double> value =[];
  //       if(landmark.coordinateX != null) {
  //         value = tools.localtoglobal(landmark.coordinateX!, landmark.coordinateY!, SingletonFunctionController.building.patchData[landmark.sId ?? buildingAllApi.getStoredString()]);
  //       }
  //       _exploreModeMarker.add(Marker(
  //         markerId: MarkerId("${value[0]}, ${value[1]}"),
  //         position: LatLng(value[0], value[1]),
  //         icon: BitmapDescriptor.fromBytes(iconMarker),
  //       ));
  //       setState(() {});
  //     });
  //
  //
  //     List<int> tv = tools.eightcelltransition(user.theta);
  //     EM_finalDirections = EM_calcDirectionsExploreMode(
  //         [EM_NEAREST_BEACON_VALUE.coordinateX!,EM_NEAREST_BEACON_VALUE.coordinateY!],
  //         [EM_NEAREST_BEACON_VALUE.coordinateX! + tv[0],EM_NEAREST_BEACON_VALUE.coordinateY! + tv[1]],
  //         EM_NearLandmarks
  //     );
  //     EM_lastBeaconValue = EM_NEAREST_BEACON_VALUE.name!;
  //     paintUser(EM_NEAREST_BEACON_VALUE.name!,null,null);
  //     setState(() {});
  //   }
  // }

  land EM_buildingLandmark = land();
  Future<void> initializeScanAndLandmarkData() async {
    print("initializeScanAndLandmarkData");
    EM_buildingLandmark =
    await SingletonFunctionController.building.landmarkdata!;
  }

  String firstValue = "";
  LatLng lastExplorePosition = LatLng(0.0, 0.0);



  void relocalizeUser() {
    print("relocalizeUser");
    SingletonFunctionController.btadapter.emptyBin();
    if (!user.isnavigating && !isLocalized) {
      SingletonFunctionController.btadapter.stopScanning();
      if (Platform.isAndroid) {
        bluetoothScanAndroidClass
            .listenToScanInitialLocalization(Building.apibeaconmap)
            .then((value) {
          setState(() {
            isLocalized = false;
          });
          localizeUser();
        });
      } else {
        //SingletonFunctionController.btadapter.startScanningIOS(SingletonFunctionController.apibeaconmap);
        BluetoothScanIOSClass.getInitialLocalizedDevice().then((value) {
          print("localized--");
          print(value);
          if (value != null) {
            localizeUser();
          }
        });
      }
      setState(() {
        isLocalized = true;
        resBeacons = SingletonFunctionController.apibeaconmap;
      });
      late Timer _timer;
      _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
        //localizeUser();
        _timer.cancel();
      });
    } else {
      recenterMap();
    }
  }

  void createPatch(patchDataModel value, {bool building = true}) async {
    print("patchformation $value");
    if (value.patchData!.coordinates!.isNotEmpty) {
      List<LatLng> polygonPoints = [];
      double latcenterofmap = 0.0;
      double lngcenterofmap = 0.0;

      for (int i = 0; i < 4; i++) {
        latcenterofmap = latcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!);
        lngcenterofmap = lngcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!);
      }
      latcenterofmap = latcenterofmap / 4;
      lngcenterofmap = lngcenterofmap / 4;

      _initialCameraPosition = CameraPosition(
        target: LatLng(latcenterofmap, lngcenterofmap),
        zoom: 20,
      );

      Map<int, LatLng> coordinates = {};

      for (int i = 0; i < 4; i++) {
        coordinates[i] = LatLng(
            latcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lat!) -
                        latcenterofmap),
            lngcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lng!) -
                        lngcenterofmap));
        polygonPoints.add(LatLng(
            latcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lat!) -
                        latcenterofmap),
            lngcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lng!) -
                        lngcenterofmap)));
      }

      if (!SingletonFunctionController.building.ARCoordinates
          .containsKey(buildingAllApi.selectedBuildingID)) {
        SingletonFunctionController.building
            .ARCoordinates[buildingAllApi.selectedBuildingID] = coordinates;
        print(
            "patchmade for${SingletonFunctionController.building.ARCoordinates.keys} ${StackTrace.current}");
      }

      setState(() {
        if(building){
          patch.add(
            Polygon(
                polygonId: PolygonId('patch'),
                points: polygonPoints,
                strokeWidth: 1,
                strokeColor: Colors.white70,
                fillColor: Colors.white,
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -1),
          );
        }else{
          patch.add(
            Polygon(
                polygonId: PolygonId('patch'),
                points: polygonPoints,
                strokeWidth: 1,
                strokeColor: Color(0xffC0C0C0),
                fillColor: Color(0xffffffff),
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -1),
          );
        }
        cachedPolygon.clear();
      });

      try {
        fitPolygonInScreen(patch.first);
      } catch (e) {}
    }
  }

  Map<int, List<Nodes>> extractWaypoint(polylinedata polyline) {
    Map<int, List<Nodes>> wayPoints = {};
    polyline.polyline!.floors!.forEach((floor) {
      floor.polyArray!.forEach((element) {
        if (element.polygonType!.toLowerCase() == "waypoints") {
          wayPoints.putIfAbsent(
              tools.alphabeticalToNumerical(element.floor!), () => []);
          wayPoints[tools.alphabeticalToNumerical(element.floor!)]!
              .addAll(element.nodes!);
        }
      });
    });

    return wayPoints;
  }

  void createotherPatch(String key, patchDataModel value, {bool building = true}) async {
    if (value.patchData!.coordinates!.isNotEmpty) {
      List<LatLng> polygonPoints = [];
      double latcenterofmap = 0.0;
      double lngcenterofmap = 0.0;

      for (int i = 0; i < 4; i++) {
        latcenterofmap = latcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!);
        lngcenterofmap = lngcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!);
      }
      latcenterofmap = latcenterofmap / 4;
      lngcenterofmap = lngcenterofmap / 4;

      Map<int, LatLng> coordinates = {};

      for (int i = 0; i < 4; i++) {
        coordinates[i] = LatLng(
            latcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lat!) -
                        latcenterofmap),
            lngcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lng!) -
                        lngcenterofmap));

        polygonPoints.add(LatLng(
            latcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lat!) -
                        latcenterofmap),
            lngcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lng!) -
                        lngcenterofmap)));
      }

      if (!SingletonFunctionController.building.ARCoordinates
          .containsKey(key)) {
        SingletonFunctionController.building.ARCoordinates[key] = coordinates;
        print("patchmade for${SingletonFunctionController.building.ARCoordinates.keys} ${StackTrace.current}");
      }
      setState(() {
        if(building){
          otherpatch.add(
            Polygon(
                polygonId: PolygonId('otherpatch ${value.patchData!.buildingID}'),
                points: polygonPoints,
                strokeWidth: 1,
                strokeColor: Colors.white70,
                fillColor: Colors.white,
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -1),
          );
        }else{
          otherpatch.add(
            Polygon(
                polygonId: PolygonId('otherpatch ${value.patchData!.buildingID}'),
                points: polygonPoints,
                strokeWidth: 1,
                strokeColor: Color(0xffC0C0C0),
                fillColor: Color(0xffffffff),
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -2),
          );
        }
        cachedPolygon.clear();
      });
    }
  }

  Future<BitmapDescriptor> bitmapDescriptorFromTextAndImageForPatchTransition(
      String text, String imagePath,
      {Size imageSize = const Size(50, 50)}) async {
    // Load the base marker image
    final ByteData baseImageBytes = await rootBundle.load(imagePath);
    final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
        baseImageBytes.buffer.asUint8List(),
        targetWidth: imageSize.width.toInt(),
        targetHeight: imageSize.height.toInt());
    final ui.FrameInfo markerImageFrame = await markerImageCodec.getNextFrame();
    final ui.Image markerImage = markerImageFrame.image;

    // Set the text style and layout
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 40.0, // Increased font size
        color: Colors.black,
        fontFamily: "Roboto",
        fontWeight: FontWeight.w500,
        height: 23 / 16,
      ),
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );

    // Calculate the overall canvas size
    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;
    final double canvasWidth =
    textWidth > imageSize.width ? textWidth : imageSize.width;
    final double canvasHeight =
        textHeight + imageSize.height + 20.0; // Increased padding

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Draw the text centered above the marker image
    final double textX = (canvasWidth - textWidth) / 2;
    final double textY = 0.0;
    textPainter.paint(canvas, Offset(textX, textY));

    // Draw the base marker image below the text
    final double imageX = (canvasWidth - imageSize.width) / 2;
    final double imageY = textHeight + 5.0; // Padding between text and image
    canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());

    // Generate the final image
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes!);
  }

  // Set<Marker> blurPatchMarker = Set();
  Set<Marker> blurPatchCampusMarker = Set();
  Set<Polygon> blurPatchCampus = Set();


  renderCampusPatchTransition(List<String> IDS, {String? outdoorID}) async {
    Map<int, LatLng> currentCoordinated = {};
    print("key${SingletonFunctionController.building.ARCoordinates.keys}");

    SingletonFunctionController.building.ARCoordinates.forEach((key, innerMap) {
      print("key $key");
      // if (key != outdoorID && IDS.contains(key)) {
      //   currentCoordinated = innerMap;
      //   print("innerMap ${key} ${currentCoordinated}");
      //   if (currentCoordinated.isNotEmpty) {
      //     List<LatLng> points = [];
      //     List<MapEntry<int, LatLng>> entryList =
      //         currentCoordinated.entries.toList();
      //     entryList.sort((a, b) => a.key.compareTo(b.key));
      //     LinkedHashMap<int, LatLng> sortedCoordinates =
      //         LinkedHashMap.fromEntries(entryList);
      //     sortedCoordinates.forEach((key, value) {
      //       points.add(value);
      //     });
      //
      //     setState(() {
      //       blurPatch.add(
      //         Polygon(
      //           polygonId: PolygonId('patch${points}'),
      //           points: points,
      //           strokeWidth: 1,
      //           strokeColor: Colors.black.withOpacity(0.5),
      //           fillColor: Color(0xfff0e6d1).withOpacity(1.0),
      //           geodesic: false,
      //           consumeTapEvents: false,
      //           zIndex: 5,
      //         ),
      //       );
      //       cachedPolygon.clear();
      //     });
      //   }
      //
      //   Building.allBuildingID.forEach((Key, Value) async {
      //     if (IDS.contains(Key) && Key != outdoorID) {
      //       String? showBuildingName = "";
      //
      //       Building.buildingData?.forEach((currKey, currValue) {
      //         if (currKey == Key) {
      //           showBuildingName = currValue;
      //         }
      //       });
      //       final result = await HelperClass()
      //           .bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
      //               showBuildingName?.trim() ?? "Zone",
      //               'assets/buildingIconESG.png',
      //               imageSize: const Size(100, 100));
      //       final iconMarker = result.icon;
      //       final anchor = result.anchor;
      //       blurPatchMarker.add(
      //         Marker(
      //           markerId: MarkerId(showBuildingName! + Key + Value.toString()),
      //           position: Value,
      //           icon: iconMarker,
      //           anchor: anchor,
      //         ),
      //       );
      //     }
      //   });
      // }
      // else
      if(key == outdoorID){
        print("key == outdoorID");
        currentCoordinated = innerMap;
        print("innerMap ${key} ${currentCoordinated}");
        if (currentCoordinated.isNotEmpty) {
          List<LatLng> points = [];
          List<MapEntry<int, LatLng>> entryList =
          currentCoordinated.entries.toList();
          entryList.sort((a, b) => a.key.compareTo(b.key));
          LinkedHashMap<int, LatLng> sortedCoordinates =
          LinkedHashMap.fromEntries(entryList);
          sortedCoordinates.forEach((key, value) {
            points.add(value);
          });

          setState(() {
            blurPatchCampus.add(
              Polygon(
                polygonId: PolygonId('patch${points}'),
                points: points,
                strokeWidth: 1,
                strokeColor: Colors.black,
                visible: false,
                fillColor: Color(0xfff9e9e6).withOpacity(1.0),
                geodesic: false,
                consumeTapEvents: false,
                zIndex: 5,
              ),
            );
            cachedPolygon.clear();
          });
        }

        Building.allBuildingID.forEach((Key, Value) async {
          if (IDS.contains(Key) && Key == outdoorID) {
            String? showBuildingName = "";

            Building.buildingData?.forEach((currKey, currValue) {
              if (currKey == Key) {
                showBuildingName = currValue;
              }
            });

            final marker = await creator.createUnifiedMarker(
              text: showBuildingName?.trim() ?? "Zone",
              imageSource: 'assets/campusPurpleFestMapIcon.png',
              layout: MarkerLayout.horizontal,
              textFormat: TextFormat.smartWrap,  // Uses your preferred logic!
              fontSize: 12.0,
            );
            blurPatchCampusMarker.add(
              Marker(
                  markerId: MarkerId(showBuildingName! + Key + Value.toString()),
                  position: Value,
                  icon: marker.icon,
                  anchor: marker.anchor,
                  visible: false,
                  onTap: (){
                    _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(Value.latitude, Value.longitude), // Use the last known target
                          zoom: 18.5, // Use the last known zoom
                          bearing: user.theta, // Update the bearing
                        ),
                      ),
                    );
                  }
              ),
            );
          }
        });
        // }
        // if(key == outdoorID){
        //   currentCoordinated = innerMap;
        //   print("innerMap ${key} ${currentCoordinated}");
        //   if (currentCoordinated.isNotEmpty) {
        //     List<LatLng> points = [];
        //     List<MapEntry<int, LatLng>> entryList =
        //     currentCoordinated.entries.toList();
        //     entryList.sort((a, b) => a.key.compareTo(b.key));
        //     LinkedHashMap<int, LatLng> sortedCoordinates =
        //     LinkedHashMap.fromEntries(entryList);
        //     sortedCoordinates.forEach((key, value) {
        //       points.add(value);
        //     });
        //
        //     setState(() {
        //       blurPatchCampus.add(
        //         Polygon(
        //           polygonId: PolygonId('patch${points}'),
        //           points: points,
        //           strokeWidth: 1,
        //           strokeColor: Colors.black.withOpacity(0.5),
        //           fillColor: Color(0xfff0e6d1).withOpacity(1.0),
        //           geodesic: false,
        //           consumeTapEvents: false,
        //           zIndex: 5,
        //         ),
        //       );
        //       cachedPolygon.clear();
        //     });
        //   }
        //
        //   Building.allBuildingID.forEach((Key, Value) async {
        //     if (IDS.contains(Key) && Key != outdoorID) {
        //       String? showBuildingName = "";
        //
        //       Building.buildingData?.forEach((currKey, currValue) {
        //         if (currKey == Key) {
        //           showBuildingName = currValue;
        //         }
        //       });
        //       final result = await HelperClass()
        //           .bitmapDescriptorFromTextAndImageUpdatedWithAnchor(
        //           showBuildingName?.trim() ?? "Zone",
        //           'assets/buildingMarker.png',
        //           imageSize: const Size(100, 100));
        //       final iconMarker = result.icon;
        //       final anchor = result.anchor;
        //       blurPatchCampusMarker.add(
        //         Marker(
        //           markerId: MarkerId(showBuildingName! + Key + Value.toString()),
        //           position: Value,
        //           icon: iconMarker,
        //           anchor: anchor,
        //         ),
        //       );
        //     }
        //   });
        //
        // }
      }
    });
  }

  void patchGeneration(Map<int, LatLng> currentCoordinated) {
    // print("patchGeneration");
    // if (currentCoordinated.isNotEmpty) {
    //   List<LatLng> points = [];
    //   List<MapEntry<int, LatLng>> entryList =
    //       currentCoordinated.entries.toList();
    //   entryList.sort((a, b) => a.key.compareTo(b.key));
    //   LinkedHashMap<int, LatLng> sortedCoordinates =
    //       LinkedHashMap.fromEntries(entryList);
    //   sortedCoordinates.forEach((key, value) {
    //     points.add(value);
    //   });
    //   setState(() {
    //     blurPatch.add(
    //       Polygon(
    //         polygonId: PolygonId('patch${points}'),
    //         points: points,
    //         strokeWidth: 1,
    //         strokeColor: Colors.black,
    //         fillColor: Color(0xffE5F9FF),
    //         geodesic: false,
    //         consumeTapEvents: true,
    //         zIndex: 5,
    //       ),
    //     );
    //     cachedPolygon.clear();
    //   });
    // }
  }

  void createARPatch(Map<int, LatLng> coordinates, {bool building = true}) async {
    print("createARPatch ${StackTrace.current}");
    if (coordinates.isNotEmpty) {
      List<LatLng> points = [];
      List<MapEntry<int, LatLng>> entryList = coordinates.entries.toList();

      // Sort the list by keys
      entryList.sort((a, b) => a.key.compareTo(b.key));

      // Create a new LinkedHashMap from the sorted list
      LinkedHashMap<int, LatLng> sortedCoordinates =
      LinkedHashMap.fromEntries(entryList);

      // Print the sorted map
      sortedCoordinates.forEach((key, value) {
        print("checkingpoint${key}");
        points.add(value);
      });
      SingletonFunctionController
          .building.ARCoordinates[buildingAllApi.selectedID] = coordinates;
      print("patchmade main for ${SingletonFunctionController.building.ARCoordinates.keys}");

      setState(() {
        patch.clear();
        if(building){
          patch.add(
            Polygon(
                polygonId: PolygonId('patch ${DateTime.now()}'),
                points: points,
                strokeWidth: 2,
                strokeColor: Colors.grey,
                fillColor: Colors.white,
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -1),
          );
        }else{
          patch.add(
            Polygon(
                polygonId: PolygonId('patch ${DateTime.now()}'),
                points: points,
                strokeWidth: 1,
                strokeColor: Color(0xffC0C0C0),
                fillColor: Color(0xffffffff),
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -2),
          );
        }
        cachedPolygon.clear();
      });
    } else {
      print("checkingpoint coordinate empty");
    }
  }

  void createotherARPatch(Map<int, LatLng> coordinates, String bid, {bool building = true}) async {
    print("createotherARPatch bid ${bid} ${StackTrace.current}");
    if (!mounted || disposed) return;
    if (coordinates.isNotEmpty) {
      List<LatLng> points = [];
      List<MapEntry<int, LatLng>> entryList = coordinates.entries.toList();

      // Sort the list by keys
      entryList.sort((a, b) => a.key.compareTo(b.key));

      // Create a new LinkedHashMap from the sorted list
      LinkedHashMap<int, LatLng> sortedCoordinates =
      LinkedHashMap.fromEntries(entryList);

      // Print the sorted map
      sortedCoordinates.forEach((key, value) {
        points.add(value);
      });
      SingletonFunctionController.building.ARCoordinates[bid] = coordinates;
      print(
          "patchmade other for $bid ${SingletonFunctionController.building.ARCoordinates.keys} ${StackTrace.current}");

      setState(() {
        otherpatch
            .removeWhere((element) => element.polygonId.value.contains(bid));
        if(building){
          otherpatch.add(
            Polygon(
                polygonId: PolygonId('otherpatch $bid'),
                points: points,
                strokeWidth: 2,
                strokeColor: Colors.grey,
                fillColor: Colors.white,
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -1),
          );
        }else{
          otherpatch.add(
            Polygon(
                polygonId: PolygonId('otherpatch $bid'),
                points: points,
                strokeWidth: 1,
                strokeColor: Color(0xfff6f6f6),
                fillColor: Color(0xfff6f6f6),
                geodesic: false,
                consumeTapEvents: true,
                zIndex: -2),
          );
        }
        cachedPolygon.clear();
      });
    }
  }

  Set<Polygon> _polygon = Set();
  PolygonId matchPolygonId = PolygonId("");
  List<LatLng> matchPolygonPoints = [];
  AnimationController? _controller12;
  Animation<double>? _sizeAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<LatLng> _latLngAnimation;

  Future<void> addselectedRoomMarker(
      List<LatLng> polygonPoints,
      String assetPath, {
        Color? color,
      }) async {
    // Cancel ongoing animation
    _controller12?.stop();
    _controller12?.dispose();
    _controller12 = null;

    selectedroomMarker.clear();
    _markers.clear();

    matchPolygonId = PolygonId("$polygonPoints");
    matchPolygonPoints = polygonPoints;

    _polygon.clear();
    _polygon.add(
      Polygon(
        polygonId: PolygonId("$polygonPoints"),
        points: polygonPoints,
        fillColor:
        color?.withOpacity(0.4) ?? Colors.lightBlueAccent.withOpacity(0.4),
        strokeColor: color ?? Colors.blue,
        strokeWidth: 2,
      ),
    );

    cachedPolygon.clear();

    // BASE SIZE IN LOGICAL PIXELS
    const int baseSize = 50;

    Uint8List baseIcon = await getImagesFromMarker(assetPath, baseSize);

    // Animation controller
    _controller12 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller12!, curve: Curves.easeInOut),
    );

    _controller12!.addListener(() async {
      double scale = _sizeAnimation!.value;

      // New logical size
      int newSize = (baseSize * scale).toInt();

      Uint8List resizedIcon = await getImagesFromMarker(assetPath, newSize);

      setState(() {
        final key = buildingAllApi.getStoredString();
        selectedroomMarker[key] = {
          Marker(
            markerId: const MarkerId('selectedRoomMarker'),
            position: calculateRoomCenter(polygonPoints),
            icon: BitmapDescriptor.fromBytes(resizedIcon),
            onTap: () {},
          )
        };
      });
    });

    _controller12!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller12?.dispose();
        _controller12 = null;

        setState(() {
          final key = buildingAllApi.getStoredString();
          selectedroomMarker[key] = {
            Marker(
              markerId: const MarkerId('selectedRoomMarker'),
              position: calculateRoomCenter(polygonPoints),
              icon: BitmapDescriptor.fromBytes(baseIcon),
              onTap: () {},
            )
          };
        });
      }
    });

    _controller12!.forward();
  }


  Future<void> addselectedMarker(LatLng point,{String? path}) async {
    selectedroomMarker.clear(); // Clear existing markers
    print("addSelectedMarker $point");
    Uint8List? resizedIcon;
    String buildingKey = buildingAllApi.getStoredString();
    if(path != null){
      resizedIcon = await getImagesFromMarker(path,75);
    }


    setState(() {
      selectedroomMarker[buildingKey] = {
        Marker(
          markerId: const MarkerId('selectedroomMarker'),
          position: point,
          icon: resizedIcon != null?BitmapDescriptor.fromBytes(resizedIcon) : BitmapDescriptor.defaultMarker,
        ),
      };
    });
  }

  double earthRadius = 6371000; // Earth radius in meters

  LatLng calculateRoomCenter(List<LatLng> polygonPoints) {
    if (polygonPoints.isEmpty) {
      throw ArgumentError('Polygon points cannot be empty');
    }

    // Choose the first point as reference
    double lat0 = polygonPoints[0].latitude * pi / 180;
    double lng0 = polygonPoints[0].longitude * pi / 180;

    // Convert LatLng to local Cartesian (x, y) in meters
    List<Point<double>> points = polygonPoints.map((point) {
      double latRad = point.latitude * pi / 180;
      double lngRad = point.longitude * pi / 180;

      double x = (lngRad - lng0) * cos(lat0) * earthRadius;
      double y = (latRad - lat0) * earthRadius;

      return Point<double>(x, y);
    }).toList();

    // Compute centroid in local coordinates
    double signedArea = 0.0;
    double centroidX = 0.0;
    double centroidY = 0.0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      Point<double> current = points[i];
      Point<double> next = points[(i + 1) % n];

      double cross = (current.x * next.y) - (next.x * current.y);
      signedArea += cross;
      centroidX += (current.x + next.x) * cross;
      centroidY += (current.y + next.y) * cross;
    }

    signedArea *= 0.5;

    if (signedArea == 0) {
      // Fallback: Average lat/lng if polygon is degenerate
      double avgLat = 0.0;
      double avgLng = 0.0;
      for (var pt in polygonPoints) {
        avgLat += pt.latitude;
        avgLng += pt.longitude;
      }
      return LatLng(avgLat / n, avgLng / n);
    }

    centroidX /= (6 * signedArea);
    centroidY /= (6 * signedArea);

    // Convert centroid back to LatLng
    double centroidLat = (centroidY / earthRadius + lat0) * 180 / pi;
    double centroidLng =
        (centroidX / (earthRadius * cos(lat0)) + lng0) * 180 / pi;

    return LatLng(centroidLat, centroidLng);
  }

  void fitPolygonInScreen(Polygon polygon) {
    List<LatLng> polygonPoints = getPolygonPoints(polygon);
    double minLat = polygonPoints[0].latitude;
    double maxLat = polygonPoints[0].latitude;
    double minLng = polygonPoints[0].longitude;
    double maxLng = polygonPoints[0].longitude;

    for (LatLng point in polygonPoints) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (point.longitude < minLng) {
        minLng = point.longitude;
      }
      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 0))
        .then((value) {
      return;
    });
  }

  LatLng calculateBoundsCenter(LatLngBounds bounds) {
    double centerLat =
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    double centerLng =
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2;

    return LatLng(centerLat, centerLng);
  }

  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
  }

  void animateToMarkers(Set<Marker> markers) {
    if (markers.isEmpty) return;

    double north = -90.0;
    double south = 90.0;
    double east = -180.0;
    double west = 180.0;

    // Find the bounds of all markers
    for (var marker in markers) {
      LatLng position = marker.position;
      north = max(north, position.latitude);
      south = min(south, position.latitude);
      east = max(east, position.longitude);
      west = min(west, position.longitude);
    }

    // Calculate the center of the map
    double centerLatitude = (north + south) / 2;
    double centerLongitude = (east + west) / 2;
    LatLng center = LatLng(centerLatitude, centerLongitude);

    // Optionally, adjust zoom level based on the spread of markers
    // This zoom level calculation is very basic and might need adjustment based on your specific needs
    double latDiff = north - south;
    double lngDiff = east - west;
    double zoom = max(
        0.0,
        15.0 -
            max(latDiff, lngDiff) *
                10); // Basic heuristic for zoom level: adjust as needed

    // Create a new camera position
    CameraPosition cameraPosition = CameraPosition(
      target: center,
      zoom: zoom,
    );

    // Animate camera to the new position
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void setCameraPosition(Set<Marker> selectedroomMarker1,
      {Set<Marker>? selectedroomMarker2 = null}) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;

    if (selectedroomMarker2 == null) {
      for (Marker marker in selectedroomMarker1) {
        double lat = marker.position.latitude;
        double lng = marker.position.longitude;

        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          200.0, // padding to adjust the bounding box on the screen
        ),
      );
    } else {
      for (Marker marker in selectedroomMarker1) {
        double lat = marker.position.latitude;
        double lng = marker.position.longitude;

        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }
      for (Marker marker in selectedroomMarker2) {
        double lat = marker.position.latitude;
        double lng = marker.position.longitude;

        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          200.0, // padding to adjust the bounding box on the screen
        ),
      );
    }
  }

  bool _isCameraAnimating = false;
  Future<void> setCameraPositionusingCoords(
      List<LatLng> selectedRoomMarker1, {
        List<LatLng>? selectedRoomMarker2,
      }) async {
    if (_isCameraAnimating || _googleMapController == null) {
      return; // If already animating or controller is null, exit
    }
    setState(() {
      _isCameraAnimating = true;
    });
    try {
      // Combine markers if the second list is provided
      List<LatLng> allMarkers = [...selectedRoomMarker1];
      if (selectedRoomMarker2 != null) {
        allMarkers.addAll(selectedRoomMarker2);
      }
      // Calculate bounds
      double minLat = double.infinity;
      double minLng = double.infinity;
      double maxLat = double.negativeInfinity;
      double maxLng = double.negativeInfinity;
      for (LatLng marker in allMarkers) {
        double lat = marker.latitude;
        double lng = marker.longitude;
        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      // Adjust bounds for top and bottom UI panels
      final double paddingFactor = 0.1; // Adjust as per your UI layout
      bounds = _adjustBoundsForPanels(bounds, paddingFactor);
      // Calculate zoom level dynamically
      final double distance =
      _calculateDistance(bounds.southwest, bounds.northeast);
      final double targetZoom = _calculateZoomLevel(bounds, distance);
      // Animate camera movement
      const int steps = 60;
      const Duration stepDuration = Duration(milliseconds: 20);
      final currentZoom = await _googleMapController.getZoomLevel();
      LatLng center = LatLng(
        (minLat + maxLat) / 2,
        (minLng + maxLng) / 2,
      );
      for (int i = 0; i <= steps; i++) {
        final t = i / steps; // Progress from 0 to 1
        final interpolatedLat =
        _lerp(center.latitude, bounds.northeast.latitude, t);
        final interpolatedLng =
        _lerp(center.longitude, bounds.northeast.longitude, t);
        final interpolatedZoom = _lerp(currentZoom, targetZoom, t);
        await _googleMapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(interpolatedLat, interpolatedLng),
              zoom: interpolatedZoom,
            ),
          ),
        );
        // Delay for smooth animation
        await Future.delayed(stepDuration);
      }
    } finally {
      setState(() {
        _isCameraAnimating = false;
      });
    }
  }

  LatLngBounds _adjustBoundsForPanels(
      LatLngBounds bounds, double paddingFactor) {
    final double latDiff =
        bounds.northeast.latitude - bounds.southwest.latitude;
    final double lngDiff =
        bounds.northeast.longitude - bounds.southwest.longitude;
    return LatLngBounds(
      southwest: LatLng(
        bounds.southwest.latitude + (latDiff * paddingFactor),
        bounds.southwest.longitude + (lngDiff * paddingFactor),
      ),
      northeast: LatLng(
        bounds.northeast.latitude - (latDiff * paddingFactor),
        bounds.northeast.longitude - (lngDiff * paddingFactor),
      ),
    );
  }

// Calculate zoom level dynamically
  double _calculateZoomLevel(LatLngBounds bounds, double distance) {
    if (distance < 0.05) {
      return 20.0; // High zoom for very close points
    } else if (distance < 0.5) {
      return 19.0; // Moderate zoom for nearby points
    } else {
      return 18.0; // Default zoom for larger distances
    }
  }

// Calculate distance between two LatLng points
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371.0; // Radius of Earth in kilometers
    final double dLat = _toRadians(point2.latitude - point1.latitude);
    final double dLng = _toRadians(point2.longitude - point1.longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(point1.latitude)) *
            math.cos(_toRadians(point2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

// Helper to convert degrees to radians
  double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }

// Linear interpolation helper
  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }
  // Future<void> setCameraPositionusingCoords(List<LatLng> selectedroomMarker1,
  //     {List<LatLng>? selectedroomMarker2 = null}) async {
  //   if(Platform.isAndroid){
  //     double minLat = double.infinity;
  //     double minLng = double.infinity;
  //     double maxLat = double.negativeInfinity;
  //     double maxLng = double.negativeInfinity;
  //
  //     if (selectedroomMarker2 == null) {
  //       for (LatLng marker in selectedroomMarker1) {
  //         double lat = marker.latitude;
  //         double lng = marker.longitude;
  //
  //         minLat = math.min(minLat, lat);
  //         minLng = math.min(minLng, lng);
  //         maxLat = math.max(maxLat, lat);
  //         maxLng = math.max(maxLng, lng);
  //       }
  //
  //       LatLngBounds bounds = LatLngBounds(
  //         southwest: LatLng(minLat, minLng),
  //         northeast: LatLng(maxLat, maxLng),
  //       );
  //
  //       _googleMapController.animateCamera(
  //         CameraUpdate.newLatLngBounds(
  //           bounds,
  //           200.0, // padding to adjust the bounding box on the screen
  //         ),
  //       );
  //     } else {
  //       for (LatLng marker in selectedroomMarker1) {
  //         double lat = marker.latitude;
  //         double lng = marker.longitude;
  //
  //         minLat = math.min(minLat, lat);
  //         minLng = math.min(minLng, lng);
  //         maxLat = math.max(maxLat, lat);
  //         maxLng = math.max(maxLng, lng);
  //       }
  //       for (LatLng marker in selectedroomMarker2) {
  //         double lat = marker.latitude;
  //         double lng = marker.longitude;
  //
  //         minLat = math.min(minLat, lat);
  //         minLng = math.min(minLng, lng);
  //         maxLat = math.max(maxLat, lat);
  //         maxLng = math.max(maxLng, lng);
  //       }
  //
  //       LatLngBounds bounds = LatLngBounds(
  //         southwest: LatLng(minLat, minLng),
  //         northeast: LatLng(maxLat, maxLng),
  //       );
  //
  //       _googleMapController.animateCamera(
  //         CameraUpdate.newLatLngBounds(
  //           bounds,
  //           200.0, // padding to adjust the bounding box on the screen
  //         ),
  //       );
  //     }
  //   }else{
  //     double minLat = double.infinity;
  //     double minLng = double.infinity;
  //     double maxLat = double.negativeInfinity;
  //     double maxLng = double.negativeInfinity;
  //
  //     if (selectedroomMarker2 == null) {
  //       for (LatLng marker in selectedroomMarker1) {
  //         double lat = marker.latitude;
  //         double lng = marker.longitude;
  //
  //         minLat = math.min(minLat, lat);
  //         minLng = math.min(minLng, lng);
  //         maxLat = math.max(maxLat, lat);
  //         maxLng = math.max(maxLng, lng);
  //       }
  //       double bearing = tools.calculateBearing_fromLatLng(selectedroomMarker1.first, selectedroomMarker1.last);
  //       LatLng center = LatLng(
  //         (minLat + maxLat) / 2,
  //         (minLng + maxLng) / 2,
  //       );
  //       LatLngBounds bounds = LatLngBounds(
  //         southwest: LatLng(minLat, minLng),
  //         northeast: LatLng(maxLat, maxLng),
  //       );
  //
  //       await _googleMapController.animateCamera(
  //         CameraUpdate.newLatLngBounds(
  //           bounds,
  //           60.0, // padding to adjust the bounding box on the screen
  //         ),
  //       );
  //       await Future.delayed(Duration(milliseconds: 100));
  //
  //       _googleMapController.animateCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(
  //             target: center,
  //             zoom: await _googleMapController.getZoomLevel(),
  //             bearing: bearing,
  //           ),
  //         ),
  //       );
  //
  //
  //     } else {
  //       for (LatLng marker in selectedroomMarker1) {
  //         double lat = marker.latitude;
  //         double lng = marker.longitude;
  //
  //         minLat = math.min(minLat, lat);
  //         minLng = math.min(minLng, lng);
  //         maxLat = math.max(maxLat, lat);
  //         maxLng = math.max(maxLng, lng);
  //       }
  //       for (LatLng marker in selectedroomMarker2) {
  //         double lat = marker.latitude;
  //         double lng = marker.longitude;
  //
  //         minLat = math.min(minLat, lat);
  //         minLng = math.min(minLng, lng);
  //         maxLat = math.max(maxLat, lat);
  //         maxLng = math.max(maxLng, lng);
  //       }
  //
  //       double bearing = tools.calculateBearing_fromLatLng(selectedroomMarker1.first, selectedroomMarker1.last);
  //       LatLng center = LatLng(
  //         (minLat + maxLat) / 2,
  //         (minLng + maxLng) / 2,
  //       );
  //
  //       LatLngBounds bounds = LatLngBounds(
  //         southwest: LatLng(minLat, minLng),
  //         northeast: LatLng(maxLat, maxLng),
  //       );
  //
  //       await _googleMapController.animateCamera(
  //         CameraUpdate.newLatLngBounds(
  //           bounds,
  //           60.0, // padding to adjust the bounding box on the screen
  //         ),
  //       );
  //       await Future.delayed(Duration(milliseconds: 100));
  //       _googleMapController.animateCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(
  //             target: center,
  //             zoom: await _googleMapController.getZoomLevel(),
  //             bearing: bearing,
  //           ),
  //         ),
  //       );
  //
  //     }
  //   }
  // }

  List<PolyArray> findLift(String floor, List<Floors> floorData) {
    List<PolyArray> lifts = [];
    floorData.forEach((Element) {
      if (Element.floor == floor) {
        Element.polyArray!.forEach((element) {
          if ((element.name ?? "").toLowerCase().contains("lift")) {
            lifts.add(element);
          }
        });
      }
    });
    return lifts;
  }

  List<int> findCommonLift(List<PolyArray> list1, List<PolyArray> list2) {
    List<int> diff = [0, 0];

    for (int i = 0; i < list1.length; i++) {
      for (int y = 0; y < list2.length; y++) {
        PolyArray l1 = list1[i];
        PolyArray l2 = list2[y];

        if (l1.name!.toLowerCase().contains("lift") &&
            l2.name!.toLowerCase().contains("lift") &&
            l1.name!.length > 4 &&
            l1.name == l2.name) {
          int x1 = 0;
          int y1 = 0;
          for (int a = 0; a < 4; a++) {
            x1 = (x1 + l1.nodes![a].coordx!).toInt();
            y1 = (y1 + l1.nodes![a].coordy!).toInt();
          }

          int x2 = 0;
          int y2 = 0;
          for (int a = 0; a < 4; a++) {
            x2 = (x2 + l2.nodes![a].coordx!).toInt();
            y2 = (y2 + l2.nodes![a].coordy!).toInt();
          }

          x1 = (x1 / 4).toInt();
          y1 = (y1 / 4).toInt();
          x2 = (x2 / 4).toInt();
          y2 = (y2 / 4).toInt();

          diff = [x2 - x1, y2 - y1];
        }
      }
    }
    return diff;
  }

  Future<bool> LandmarkPresent(String id) async {
    print("LandmarkPresent got id ${id}");
    var otherLandmarkdata =
    await SingletonFunctionController.building.landmarkdata;
    for (var element in otherLandmarkdata!.landmarks!) {
      if (element.properties!.polyId == id) {
        return true;
      }
    }
    return false;
  }

  int currentToggleFloor = 0;
  String selectedMarkerId = "";
  List<RoadInfo> roadPointMarkerList = [];
  Future<void> polygonTap(
      List<LatLng>? coordinates, String id, String path) async {
    print("polygonTap stacktarce:${StackTrace.current}\n");
    selectedMarkerId = id;
    landmarkMarkers.forEach((currMarker) {
      if (currMarker.markerId.toString().contains(id)) {
        print("foundone");
        currMarker.visible = false;
      } else {
        currMarker.visible = true;
      }
    });

    land? singletonData = await SingletonFunctionController.building.landmarkdata;
    print("called polygonTap $id ${path} ${singletonData!.landmarksMap![id]?.renderDetail?.boothType}");
    path = HelperClass().getCategoryAsset(singletonData!.landmarksMap![id]?.renderDetail?.boothType,path);
    Landmarks? landmark;
    if (singletonData!.landmarksMap![id] == null) {
      return;
    } else {
      landmark = singletonData!.landmarksMap![id];
    }
    if (coordinates != null) {
      _googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          calculateRoomCenter(coordinates),
          22,
        ),
      );
    } else {
      print("called polygonTap animating to landmark");
      _googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(double.parse(landmark!.properties!.latitude!),
              double.parse(landmark.properties!.longitude!)),
          22,
        ),
      );
    }
    setState(() {
      if (SingletonFunctionController.building.selectedLandmarkID != id &&
          !user.isnavigating &&
          !_isRoutePanelOpen) {
        user.reset();
        PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
        pathMarkers.clear();
        PathState.path.clear();
        PathState.sourcePolyID = "";
        PathState.destinationPolyID = "";
        singleroute.clear();
        pathCovered.clear();

        user.isnavigating = false;
        _isnavigationPannelOpen = false;
        SingletonFunctionController.building.selectedLandmarkID = id;
        SingletonFunctionController.building.ignoredMarker.clear();
        SingletonFunctionController.building.ignoredMarker.add(id);
        _isBuildingPannelOpen = false;
        _isRoutePanelOpen = false;
        singleroute.clear();
        pathCovered.clear();
        _isLandmarkPanelOpen = true;
        PathState.directions = [];
        interBuildingPath.clear();
        if (coordinates != null) {
          print("called polygonTap end first");
          addselectedRoomMarker(coordinates, path);
        } else {
          print("called polygonTap end second");
          addselectedMarker(LatLng(
              double.parse(landmark!.properties!.latitude!),
              double.parse(landmark.properties!.longitude!)),path: path);
        }
      }
    });
  }

  List<LatLng> tappedPolygonCoordinates = [];
  List<LatLng> landmarkFocus = [];
  PolygonCalculations polygonCalculation = PolygonCalculations();

  Future<void> createRooms(polylinedata value, int floor) async {
    final stackTrace = StackTrace.current;
    print(
        "createRooms Stack: ${value.polyline!.buildingID!} $floor \n$stackTrace");
    if (closedpolygons[buildingAllApi.getStoredString()] == null) {
      closedpolygons[buildingAllApi.getStoredString()] = Set();
    }

    closedpolygons[value.polyline!.buildingID!]?.clear();

    if (widget.directLandID.length < 2) {
      selectedroomMarker.clear();
      _isLandmarkPanelOpen = false;
      SingletonFunctionController.building.selectedLandmarkID = null;
    }
    polylines[value.polyline!.buildingID!]?.clear();
    dottedPath[value.polyline!.buildingID!]?.clear();

    if (floor != 0) {
      List<PolyArray> prevFloorLifts =
      findLift(tools.numericalToAlphabetical(0), value.polyline!.floors!);
      List<PolyArray> currFloorLifts = findLift(
          tools.numericalToAlphabetical(floor), value.polyline!.floors!);
      List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

      UserState.xdiff = dvalue[0];
      UserState.ydiff = dvalue[1];
    } else {
      UserState.xdiff = 0;
      UserState.ydiff = 0;
    }
    List<PolyArray>? FloorPolyArray = value.polyline!.floors![0].polyArray;
    for (int j = 0; j < value.polyline!.floors!.length; j++) {
      if (value.polyline!.floors![j].floor ==
          tools.numericalToAlphabetical(floor)) {
        FloorPolyArray = value.polyline!.floors![j].polyArray;
      }
    }
    setState(() {
      if (FloorPolyArray != null) {
        for (PolyArray polyArray in FloorPolyArray) {
          if (polyArray.visibilityType == "visible" &&
              polyArray.polygonType != "Waypoints") {
            List<LatLng> coordinates = [];
            for (Nodes node in polyArray.nodes!) {
              coordinates.add(LatLng(node.lat!, node.lon!));
              // coordinates.add(LatLng(
              //     tools.localtoglobal(
              //         node.coordx!,
              //         node.coordy!,
              //         SingletonFunctionController.building.patchData[value.polyline!.buildingID])[0],
              //     tools.localtoglobal(
              //         node.coordx!,
              //         node.coordy!, SingletonFunctionController.building.patchData[value.polyline!.buildingID])[1]));
            }
            if (!closedpolygons.containsKey(value.polyline!.buildingID!)) {
              closedpolygons.putIfAbsent(
                  value.polyline!.buildingID!, () => Set<Polygon>());
            }
            if (!polylines.containsKey(value.polyline!.buildingID!)) {
              polylines.putIfAbsent(
                  value.polyline!.buildingID!, () => Set<gmap.Polyline>());
            }
            if (polyArray.polygonType == 'Wall' ||
                polyArray.polygonType == 'undefined') {
              if (coordinates.length >= 2) {
                polylines[value.polyline!.buildingID!]!.add(gmap.Polyline(
                    polylineId: PolylineId(
                        "${value.polyline!.buildingID!} Line ${polyArray.id!}"),
                    points: coordinates,
                    color: polyArray.cubicleColor != null &&
                        polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                        '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Color(0xffC0C0C0),
                    width: 1,
                    onTap: () {}));
              }
            } else if (polyArray.polygonType?.toLowerCase() == 'room') {
              // print("coordinatespolyArray.name ${polyArray.name} ${polyArray.polygonType}");

              if (polyArray.name!.toLowerCase().contains('lr') ||
                  polyArray.name!.toLowerCase().contains('lab') ||
                  polyArray.name!.toLowerCase().contains('office') ||
                  polyArray.name!.toLowerCase().contains('pantry') ||
                  polyArray.name!.toLowerCase().contains('reception')) {
                // listOfCoordinates[polyArray.name!] = coordinates;

                // print("coordinatespolyArray.name 1 ${polyArray.name} ${polyArray.polygonType}");

                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);

                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] = coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                  print(
                      "checking polyid ${polyArray.id!} ${polygonCalculation.landmarkWithLatLng[polyArray.id!]}");
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  // Determine the asset based on the room type
                  String assetPath =
                  polyArray.name!.toLowerCase().contains('office')
                      ? 'assets/Office.png'
                      : 'assets/Generic Marker.png';
                  print("coordinates1 $coordinates");

                  closedpolygons[value.polyline!.buildingID!]!.add(
                    Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      strokeColor: Color(0xffA38F9F),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE8E3E7),
                      consumeTapEvents: true,
                      onTap: () {
                        polygonTap(coordinates, polyArray.id!, assetPath);
                      },
                    ),
                  );
                }
              } else if (polyArray.name!.toLowerCase().contains('board')) {
                // print("coordinatespolyArray.name 2 ${polyArray.name} ${polyArray.polygonType} ${coordinates.length}");
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  // Determine the asset based on the room type
                  String assetPath =
                  polyArray.name!.toLowerCase().contains('office')
                      ? 'assets/Office.png'
                      : 'assets/Generic Marker.png';
                  print("coordinates1 $coordinates");

                  closedpolygons[value.polyline!.buildingID!]!.add(
                    Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      strokeColor: Color(0xffA38F9F),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE8E3E7),
                      consumeTapEvents: true,
                      onTap: () {
                        polygonTap(coordinates, polyArray.id!, assetPath);
                      },
                    ),
                  );
                }
              } else if (polyArray.name!.toLowerCase().contains('atm') ||
                  polyArray.name!.toLowerCase().contains('health')) {
                // print("coordinatespolyArray.name 3 ${polyArray.name} ${polyArray.polygonType}");
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      strokeColor: Color(0xffE99696),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffFBEAEA),
                      consumeTapEvents: true,
                      onTap: () {
                        polygonTap(
                            coordinates, polyArray.id!, "assets/ATM.png");
                      }));
                }
              } else {
                // print("coordinatespolyArray.name 4 ${polyArray.name} ${polyArray.polygonType}");

                if (coordinates.length > 2) {
                  // print("polyArray.name${polyArray.name} ${polyArray.id}");
                  List<LatLng> breadthCenterPoints = polygonCalculation.calculateRectangleData(coordinates);
                  if (polyArray.id != null) {
                    polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] = coordinates;
                    polygonCalculation.landmarkWithLatLng[polyArray.id!] = breadthCenterPoints;
                    // print(
                    //     "coordinatespolyArray.name 4.1 ${polyArray.id}--$coordinates---${polygonCalculation.landmarkWithLatLng[polyArray.id!]}");
                  }
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId("${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      strokeColor: Color(0xffA38F9F),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE8E3E7),
                      consumeTapEvents: true,
                      onTap: () async {
                        String path = 'assets/Generic Marker.png';
                        Landmarks? matchedLandmark;
                        final landmarkData = await SingletonFunctionController
                            .building.landmarkdata;
                        try {
                          matchedLandmark = landmarkData?.landmarks!.firstWhere(
                                (landmark) =>
                            landmark.name != null &&
                                landmark.name!.toLowerCase().contains(
                                    polyArray.name.toString().toLowerCase()),
                          );
                        } catch (e) {
                          matchedLandmark = null; // Not found
                        }
                        if (matchedLandmark != null &&
                            matchedLandmark!.element!.subType == 'Cafeteria') {
                          path = 'assets/cutlery.png';
                        }
                        polygonTap(coordinates, polyArray.id!, path);
                      }));
                }
              }
            } else if (polyArray.polygonType == 'Cubicle') {
              if (polyArray.cubicleName == "Green Area" ||
                  polyArray.cubicleName == "Green Area | Pots" ||
                  (polyArray.name ?? "").toLowerCase().contains('auditorium') ||
                  (polyArray.name ?? "").toLowerCase().contains('basketball') ||
                  (polyArray.name ?? "").toLowerCase().contains('cricket') ||
                  (polyArray.name ?? "").toLowerCase().contains('football') ||
                  (polyArray.name ?? "").toLowerCase().contains('gym') ||
                  (polyArray.name ?? "").toLowerCase().contains('swimming') ||
                  (polyArray.name ?? "").toLowerCase().contains('tennis')) {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      strokeColor: Color(0xffADFA9E),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE7FEE9),
                      onTap: () {}));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("lift")) {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      strokeColor: Color(0xffB5CCE3),
                      consumeTapEvents: true,
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffDAE6F1),
                      onTap: () {
                        polygonTap(
                            coordinates, polyArray.id!, 'assets/MapLift.png');
                      }));
                }
              } else if (polyArray.cubicleName == "Male Washroom") {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xFFE7F4FE),
                      onTap: () {
                        polygonTap(coordinates, polyArray.id!,
                            "assets/MapMaleWashroom.png");
                      }));
                }
              } else if (polyArray.cubicleName == "Female Washroom") {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xFFE7F4FE),
                      onTap: () {
                        polygonTap(coordinates, polyArray.id!,
                            "assets/MapFemaleWashroom.png");
                      }));
                }
              } else if (polyArray.cubicleName?.toLowerCase() == "booth") {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  String assetPath =
                  polyArray.name!.toLowerCase().contains('office')
                      ? 'assets/Office.png'
                      : 'assets/Generic Marker.png';
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      consumeTapEvents: true,
                      strokeColor: Color(0xffA38F9F),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE8E3E7),
                      onTap: () {
                        polygonTap(coordinates, polyArray.id!, assetPath);
                      }));
                }
              } else if (polyArray.cubicleName?.toLowerCase() ==
                  "Registration Counter") {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  String assetPath =
                  polyArray.name!.toLowerCase().contains('office')
                      ? 'assets/Office.png'
                      : 'assets/Generic Marker.png';
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      consumeTapEvents: true,
                      strokeColor: Color(0xffA38F9F),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE8E3E7),
                      onTap: () {
                        polygonTap(coordinates, polyArray.id!, assetPath);
                      }));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("fire")) {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffF21D0D),
                      onTap: () {}));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("water")) {
                List<LatLng> breadthCenterPoints =
                polygonCalculation.calculateRectangleData(coordinates);
                if (polyArray.id != null) {
                  polygonCalculation.landmarkWithPolygonPoints[polyArray.id!] =
                      coordinates;
                  polygonCalculation.landmarkWithLatLng[polyArray.id!] =
                      breadthCenterPoints;
                }
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xff6EBCF7),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE7F4FE),
                      onTap: () {}));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("wall")) {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      strokeColor: Color(0xffC0C0C0),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffffffff),
                      onTap: () {}));
                }
              } else if (polyArray.cubicleName == "Restricted Area") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffCCCCCC),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE6E6E6),
                      onTap: () {}));
                }
              } else if (polyArray.cubicleName == "Non Walkable Area") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      strokeColor: Color(0xffcccccc),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE6E6E6),
                      onTap: () {}));
                }
              } else {
                if (coordinates.length > 2) {
                  String assetPath =
                  polyArray.name!.toLowerCase().contains('office')
                      ? 'assets/MapStage.png'
                      : 'assets/Generic Marker.png';
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                    points: coordinates,
                    strokeWidth: 1,
                    strokeColor: Color(0xffD3D3D3),
                    onTap: () {
                      polygonTap(coordinates, polyArray.id!, assetPath);
                    },
                    fillColor: polyArray.cubicleColor != null &&
                        polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                        '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Colors.white,
                  ));
                }
              }
            } else if (polyArray.polygonType == "Wall") {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                    points: coordinates,
                    strokeWidth: 1,
                    // Modify the color and opacity based on the selectedRoomId
                    strokeColor: Color(0xffD3D3D3),
                    fillColor: polyArray.cubicleColor != null &&
                        polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                        '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Colors.white,
                    consumeTapEvents: true,
                    onTap: () {}));
              }
            } else {
              polylines[value.polyline!.buildingID!]!.add(gmap.Polyline(
                  polylineId: PolylineId(polyArray.id!),
                  points: coordinates,
                  color: polyArray.cubicleColor != null &&
                      polyArray.cubicleColor != "undefined"
                      ? Color(int.parse(
                      '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                      : Color(0xffE6E6E6),
                  width: 1,
                  onTap: () {}));
            }
          } else if (polyArray.visibilityType == "visible" &&
              polyArray.polygonType == "Waypoints") {
            dottedPath.putIfAbsent(value.polyline!.buildingID!, () => Set());
            List<LatLng> coordinates = [];
            for (Nodes node in polyArray.nodes!) {
              coordinates.add(LatLng(node.lat!, node.lon!));
              // coordinates.add(LatLng(
              //     tools.localtoglobal(
              //         node.coordx!,
              //         node.coordy!,
              //         SingletonFunctionController
              //             .building.patchData[value.polyline!.buildingID])[0],
              //     tools.localtoglobal(
              //         node.coordx!,
              //         node.coordy!,
              //         SingletonFunctionController
              //             .building.patchData[value.polyline!.buildingID])[1]));
            }
            dottedPath[value.polyline!.buildingID!]!.add(gmap.Polyline(
                polylineId: PolylineId(
                    "${value.polyline!.buildingID!} Line ${polyArray.id!}"),
                points: coordinates,
                color: Color(0xfffa9b9c9),
                width: 1,
                patterns: [
                  gmap.PatternItem.dash(
                      Platform.isIOS ? 2 : 10), // length of each dash
                  gmap.PatternItem.gap(
                      Platform.isIOS ? 1 : 6), // gap between dashes
                ]));
            // double distanceInMeter = tools.calculateAerialDist(coordinates.first.latitude, coordinates.first.longitude, coordinates.last.latitude, coordinates.last.longitude);
            // if(distanceInMeter>5 && polyArray.name != null && polyArray.name != "undefined") {
            //   roadPointMarkerList.add(RoadInfo(positionFirst: coordinates.first,
            //       positionSecond: coordinates.last,
            //       roadName: polyArray.name!)
            //   );
            // }
          }
        }
        // addRoadMarker();
      }
    });

    cachedPolygon.clear();
    return;
  }

  void _createCurvedPolyline(String bid, int floor, LatLng pt1, LatLng pt2) {
    // Generate curved path points
    List<LatLng> curvedPoints = _generateCurvedPoints(pt1, pt2);
    singleroute.putIfAbsent(bid, ()=>Map());
    singleroute[bid]!.putIfAbsent(floor, ()=>Set());
    singleroute[bid]![floor]!.add(
      gmap.Polyline(
        polylineId: PolylineId('curved_line $pt1 & $pt2'),
        points: curvedPoints,
        color: Colors.blue,
        width: 5,
        // This creates the dotted pattern
        patterns: [
          PatternItem.dot,
          PatternItem.gap(10),
        ],
      ),
    );
  }

  // Generate curved points using quadratic Bezier curve
  List<LatLng> _generateCurvedPoints(LatLng start, LatLng end, {int segments = 50}) {
    List<LatLng> points = [];

    // Calculate the control point for the curve (midpoint with offset)
    double midLat = (start.latitude + end.latitude) / 2;
    double midLng = (start.longitude + end.longitude) / 2;

    // Calculate perpendicular offset for curve height
    double dx = end.longitude - start.longitude;
    double dy = end.latitude - start.latitude;
    double distance = math.sqrt(dx * dx + dy * dy);

    // Adjust curve height based on distance (20% of distance)
    double curveHeight = distance * 0.4;

    // Create control point perpendicular to the line
    LatLng controlPoint = LatLng(
      midLat - curveHeight * (dx / distance),
      midLng + curveHeight * (dy / distance),
    );

    // Generate points along the quadratic Bezier curve
    for (int i = 0; i <= segments; i++) {
      double t = i / segments;
      double lat = math.pow(1 - t, 2) * start.latitude +
          2 * (1 - t) * t * controlPoint.latitude +
          math.pow(t, 2) * end.latitude;
      double lng = math.pow(1 - t, 2) * start.longitude +
          2 * (1 - t) * t * controlPoint.longitude +
          math.pow(t, 2) * end.longitude;

      points.add(LatLng(lat, lng));
    }

    return points;
  }

  // void addRoadMarker(){
  //   print("roadPointMarkerList${roadPointMarkerList.length}");
  //   roadPointMarkerList.forEach((element) async {
  //     LatLng first = element.positionFirst;
  //     LatLng last = element.positionSecond;
  //
  //     double distanceInMeter = tools.calculateAerialDist(first.latitude, first.longitude, last.latitude, last.longitude);
  //     if(distanceInMeter>30) {
  //       LatLng midpoint = LatLng(
  //         (first.latitude + last.latitude) / 2,
  //         (first.longitude + last.longitude) / 2,
  //       );
  //
  //       var result = await HelperClass().bitmapDescriptorFromOutDoorRoads(element.roadName??"", null,fontSizee: 40);
  //       double rotation = getRotationFromLatLng(first, last);
  //
  //       MGMarkers.add(
  //           Marker(
  //               markerId: MarkerId("test${midpoint}"),
  //               position: midpoint,
  //               icon: result.icon,
  //               anchor: result.anchor,
  //               flat: true,
  //               rotation: rotation-270,
  //               infoWindow: InfoWindow(
  //                   title: midpoint.toString(),
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {}
  //               )
  //           )
  //       );
  //     }
  //   });
  // }
  Set<Marker> MGMarkers = Set();
  void addRoadMarker() {
    // print("roadPointMarkerList${roadPointMarkerList.length}");
    // roadPointMarkerList.forEach((element) async {
    //   LatLng first = element.positionFirst;
    //   LatLng last = element.positionSecond;
    //
    //   double distanceInMeter = tools.calculateAerialDist(first.latitude, first.longitude, last.latitude, last.longitude);
    //   if(distanceInMeter>30) {
    //     LatLng midpoint = LatLng(
    //       (first.latitude + last.latitude) / 2,
    //       (first.longitude + last.longitude) / 2,
    //     );
    //
    //     var result = await HelperClass().bitmapDescriptorFromOutDoorRoads(element.roadName??"", null,fontSizee: 40);
    //     double rotation = getRotationFromLatLng(first, last);
    //
    //     MGMarkers.add(
    //         Marker(
    //             markerId: MarkerId("test${midpoint}"),
    //             position: midpoint,
    //             icon: result.icon,
    //             anchor: result.anchor,
    //             flat: true,
    //             rotation: rotation-270,
    //             infoWindow: InfoWindow(
    //                 title: midpoint.toString(),
    //                 // snippet: '${landmarks[i].properties!.polyId}',
    //                 // Replace with additional information
    //                 onTap: () {}
    //             )
    //         )
    //     );
    //   }
    // });
  }
  double getRotationFromLatLng(LatLng start, LatLng end) {
    return Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  Future<Uint8List> getImagesFromMarker(String assetPath, int logicalSize) async {
    final double dpr = ui.window.devicePixelRatio;

    // Load original bytes
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Step 1: Decode once to read natural width/height
    final ui.Codec originalCodec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo originalFrame = await originalCodec.getNextFrame();
    final ui.Image original = originalFrame.image;

    final int originalW = original.width;
    final int originalH = original.height;

    // Step 2: Maintain aspect ratio using logicalSize as the SHORTER side
    double aspect = originalW / originalH;

    int targetW;
    int targetH;

    if (aspect >= 1) {
      // Landscape or square → width dominates
      targetW = (logicalSize * dpr).toInt();
      targetH = ((logicalSize / aspect) * dpr).toInt();
    } else {
      // Portrait → height dominates
      targetH = (logicalSize * dpr).toInt();
      targetW = ((logicalSize * aspect) * dpr).toInt();
    }

    // Step 3: Re-decode with correct proportional size
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetW,
      targetHeight: targetH,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? pngBytes =
    await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }



  Future<BitmapDescriptor> bitmapDescriptorFromTextAndImage(
      String text, String? imagePath,
      {Size imageSize = const Size(50, 50), Color? color}) async {
    if (kIsWeb) {
      imageSize = Size(45, 45);
    }
    // Set the text style and layout
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: kIsWeb ? 12.0 : 30.0, // Increased font size
        color: color ?? Color(0xff000000),
      ),
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );

    // Calculate the text size
    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;

    // Variables for canvas size, depending on whether the image is used
    double canvasWidth =
    textWidth > imageSize.width ? textWidth : imageSize.width;
    double canvasHeight = textHeight +
        (imagePath != null
            ? imageSize.height + 20.0
            : 0.0); // Increased padding if image is present

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Draw the text centered on the canvas
    final double textX = (canvasWidth - textWidth) / 2;
    final double textY = 0.0;
    textPainter.paint(canvas, Offset(textX, textY));

    // If an imagePath is provided, draw the image below the text
    if (imagePath != null) {
      // Load the base marker image
      final ByteData baseImageBytes = await rootBundle.load(imagePath);
      final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
          baseImageBytes.buffer.asUint8List(),
          targetWidth: imageSize.width.toInt(),
          targetHeight: imageSize.height.toInt());
      final ui.FrameInfo markerImageFrame =
      await markerImageCodec.getNextFrame();
      final ui.Image markerImage = markerImageFrame.image;

      // Draw the base marker image below the text
      final double imageX = (canvasWidth - imageSize.width) / 2;
      final double imageY = textHeight + 10.0; // Padding between text and image
      canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());
    }

    // Generate the final image
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes!);
  }

  Set<Marker> outDoorMarkers = {};
  List<Landmarks> _landmarks = [];
  double _lastZoom = 14;
  Set<Marker> doorMarkers = {};

  Set<Marker> roomNameMarkers = {};
  Map<String, List<LatLng>> listOfCoordinates = Map();

  void createMarkers(land _landData, int floor, String bid,{bool forced = false}) async {
    print("runcreateMarkers ${floor} ${_landData.landmarks?.length} ${bid} ${StackTrace.current}");
    // if (clustringOFF) {
    //   print("clustring is off");
    //   return;
    // }
    doorMarkers.clear();
    _markers.clear();

    print("first");
    print("_landmarks ${_landmarks.length}");
    print("landmarkMarkers ${landmarkMarkers.length}");

    List<Landmarks> landmarks = _landData.landmarks!;
    if(forced){
      landmarks.forEach((value){
        if (value.element?.type != "FloorConnection" &&
            value.element?.subType != "restRoom" &&
            value.element?.subType != "AR" &&
            value.element?.subType != "Alert" &&
            value.element?.subType != "BP" &&
            value.floor == 0 &&
            value.coordinateX != null &&
            value.coordinateY != null) {
          _landmarks.add(value);
        }
      });
      mapClustering.landmarks = _landmarks;
      print("create markers ended ${mapClustering.landmarks.length}");
      landmarkMarkers = mapClustering.recalculateClusters(_lastZoom, mapState.bearing);
      setState(() {});
      return;
    }

    if(forced == false) _landmarks.removeWhere((element) => element.buildingID == bid && element.floor != floor);
    // landmarkMarkers.removeWhere((marker) => marker.markerId.value.contains(bid));
    print("exhistinglandmarks${_landmarks.length}");

    // final result = await HelperClass().bitmapDescriptorFromTextAndImageUpdatedWithAnchor("", 'assets/MapDoorDot.png', imageSize: const Size(20, 20));
    // final iconMarker = result.icon;
    // final anchor = result.anchor;
    //
    // for (int i = 0; i < landmarks.length; i++) {
    //   print("landmarks[i].name");
    //   print("Landmarktype - ${landmarks[i].element!.type} ${landmarks[i].element!.subType}");
    //   print(landmarks[i].name);
    //   if(landmarks[i].floor == floor) {
    //     if (landmarks[i].element!.type == "Rooms" &&
    //         landmarks[i].element!.subType == "room door") {
    //       if (landmarks[i].doorX != null && landmarks[i].doorY != null) {
    //         print("insidecondition");
    //         List<double> value = tools.localtoglobal(
    //             landmarks[i].doorX!,
    //             landmarks[i].doorY!,
    //             SingletonFunctionController.building.patchData[bid ??
    //                 buildingAllApi.getStoredString()]);
    //         doorMarkers.add(
    //             Marker(
    //               markerId: MarkerId("${landmarks[i].sId}"),
    //               position: LatLng(value[0], value[1]),
    //               icon: iconMarker,
    //               anchor: anchor,
    //               flat: true,
    //               onTap: () {},
    //             )
    //         );
    //       }
    //     }
    //   }
    // }
    for (int i = 0; i < landmarks.length; i++) {
      if (landmarks[i].floor == floor && landmarks[i].buildingID ==
          (bid ?? buildingAllApi.selectedBuildingID)) {
        if (landmarks[i].element?.type == "Global") {
          // CHECK FRO MAKING NEW MARKER

          //FOR GLOBAL LANDMARKS (IIT DELHI - LHC,CAMPUS)
          if (landmarks[i].element?.subType == "Male Washroom") {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);
            _landmarks.add(landmarks[i]);
          } else if (landmarks[i].element?.subType == "Female Washroom") {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);
            _landmarks.add(landmarks[i]);
          } else if (landmarks[i].element?.subType == "room") {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);
            _landmarks.add(landmarks[i]);
          } else if (landmarks[i].element?.subType?.toLowerCase() == "booth") {
            _landmarks.add(landmarks[i]);
          } else if (landmarks[i].element?.subType == "Lift") {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);
            _landmarks.add(landmarks[i]);
          } else if (landmarks[i].element?.subType == "Stairs") {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);
            _landmarks.add(landmarks[i]);
          }else{
            _landmarks.add(landmarks[i]);
          }
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "Classroom" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);
          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "office") {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);
          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "Cafeteria" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].name != null &&
            landmarks[i].name!.toLowerCase().contains("pharmacy")) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);
          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "Point of Interest" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "Counter" &&
            landmarks[i].coordinateX != null) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "ATM" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "Consultation Room" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "Office" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);
          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType == "Entrance Only" &&
            landmarks[i].coordinateX != null) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);
          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType != "main entry" &&
            landmarks[i].element!.subType != "Entrance Only" &&
            landmarks[i].coordinateX != null) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          // print("MarkerLandmarkInformation in Room");
          try {
            _landmarks.add(landmarks[i]);
          } catch (e) {
            // print("MarkerLandmarkInformation error ${e}");
          }
        } else if (landmarks[i].element != null &&
            landmarks[i].element!.subType != null &&
            landmarks[i].element!.subType == "room door" &&
            landmarks[i].doorX != null) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);
          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].name != null &&
            landmarks[i].element!.type == ("FloorConnection") &&
            landmarks[i].element!.subType == "lift") {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].name != null &&
            landmarks[i].element!.type == ("FloorConnection") &&
            landmarks[i].element!.subType == "stairs") {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].properties!.washroomType != null &&
            landmarks[i].properties!.washroomType == "Male") {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].properties!.washroomType != null &&
            landmarks[i].properties!.washroomType == "Female") {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.subType != null &&
            landmarks[i].element!.subType == "main entry") {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else if (landmarks[i].element!.type == "Services" &&
            landmarks[i].element!.subType == "kiosk" &&
            landmarks[i].coordinateX != null) {
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!,
              landmarks[i].coordinateY!,
              SingletonFunctionController
                  .building.patchData[bid ?? buildingAllApi.getStoredString()]);

          _landmarks.add(landmarks[i]);
        } else {
          // print("landmarks entered in else ${landmarks[i].name}");
        }
        // print("_markerLocationsMapLanName ${_markerLocationsMapLanName}");
      }
    }
    print("After adding${_landmarks.length}");
    // List<Landmarks> nowLandmarks = mapClustering.landmarks;
    // nowLandmarks.addAll(_landmarks);
    mapClustering.landmarks = _landmarks;
    print("create markers ended ${mapClustering.landmarks.length}");
    landmarkMarkers = mapClustering.recalculateClusters(_lastZoom, mapState.bearing);
    setState(() {});
  }

  void toggleLandmarkPanel() {
    setState(() {
      _isLandmarkPanelOpen = !_isLandmarkPanelOpen;
      selectedroomMarker.clear();
      SingletonFunctionController.building.selectedLandmarkID = null;
      _googleMapController.animateCamera(CameraUpdate.zoomOut());
    });
  }

  PanelController _landmarkPannelController = new PanelController();
  bool calculatingPath = false;
  double aerialDist = 0.0;
  Timer? _timerCompass;
  bool hasPressedButton = false;
  bool clustringOFF = false;
  bool entryClustring = false;
  Widget landmarkdetailpannel(
      BuildContext context, AsyncSnapshot<land> snapshot) {

    // print("landmarkdetailpannel stacktrace ${StackTrace.current}");
    pathMarkers.clear();
    // if(user.isnavigating==false){
    //   clearPathVariables();
    // }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (!snapshot.hasData ||
        snapshot.data!.landmarksMap == null ||
        snapshot.data!.landmarksMap![
        SingletonFunctionController.building.selectedLandmarkID] ==
            null) {

      //
      // If the data is not available, return an empty container
      _isLandmarkPanelOpen = false;
      _isreroutePannelOpen = false;
      showMarkers();
      selectedroomMarker.clear();
      SingletonFunctionController.building.selectedLandmarkID = null;
      return Container();
    }

    // print(
    //     "landmark pannel got id ${SingletonFunctionController.building.selectedLandmarkID} ${snapshot
    //         .data!
    //         .landmarksMap![SingletonFunctionController
    //         .building.selectedLandmarkID]!
    //         .name}---${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.venueName}");

    if (user.initialallyLocalised) {
      double val1 = double.parse(snapshot
          .data!
          .landmarksMap![
      SingletonFunctionController.building.selectedLandmarkID]!
          .properties!
          .latitude!);
      double val2 = double.parse(snapshot
          .data!
          .landmarksMap![
      SingletonFunctionController.building.selectedLandmarkID]!
          .properties!
          .longitude!);
      aerialDist = tools.calculateAerialDist(user.lat, user.lng, val1, val2);
    }
    bool microService = false;
    bool startTime = snapshot
        .data!
        .landmarksMap![
    SingletonFunctionController.building.selectedLandmarkID]!
        .properties!
        .startTime !=
        null;

    bool contactDetail = ((snapshot
        .data!
        .landmarksMap![SingletonFunctionController
        .building.selectedLandmarkID]!
        .properties!
        .contactNo !=
        null &&
        snapshot
            .data!
            .landmarksMap![SingletonFunctionController
            .building.selectedLandmarkID]!
            .properties!
            .contactNo !=
            "") ||
        (snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.email != "" &&
            snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.email !=
                null) ||
        (snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.url !=
            "" &&
            snapshot
                .data!
                .landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!
                .properties!
                .url !=
                null));

    var landmark = snapshot.data!
        .landmarksMap![SingletonFunctionController.building.selectedLandmarkID];
    var inputFormat = intl.DateFormat("yyyy-MM-ddTHH:mm");
    List<Widget> events = [];
    // print("eventsState.groupedDataByVenue![SingletonFunctionController.building.selectedLandmarkID] ${SingletonFunctionController.building.selectedLandmarkID} ${landmark?.sId} ${eventsState.groupedDataByVenue![landmark?.sId]}");
    if (eventsState.groupedDataByVenue != null &&
        eventsState.groupedDataByVenue![landmark?.sId] != null) {
      var venueEvents =
      eventsState.groupedDataByVenue![landmark?.sId]!.where((cardData) {
        var status = getEventStatus(
            startDate: cardData.startDate!,
            endDate: cardData.endDate!,
            startTime: cardData.startTime!,
            endTime: cardData.endTime!,
            weekdays: cardData.weekDays);
        return (status != EventStatus.notToday);
      }).toList();

      // sort by startTime
      venueEvents.sort((a, b) {
        final aTime = inputFormat.parse(a.startTime!);
        final bTime = inputFormat.parse(b.startTime!);
        return aTime.compareTo(bTime);
      });
      events = venueEvents
          .map((cardData) => Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: card(cardData,
            openInDialoge: true, hideDirectionButton: true),
      ))
          .toList();
    }

    return Stack(
      children: [
        Positioned(
          left: 16,
          top: 16,
          right: 16,
          child: ExcludeSemantics(
            child: Container(
                width: screenWidth - 32,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white, // You can customize the border color
                    width: 1.0, // You can customize the border width
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey, // Shadow color
                      offset: Offset(0, 2), // Offset of the shadow
                      blurRadius: 4, // Spread of the shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 48,
                      margin: EdgeInsets.only(right: 4),
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            SingletonFunctionController.building.landmarkdata!.then((value) async {
                              print("SingletonFunctionController landmarks ${value.landmarks!.length}");
                              List<Landmarks> createLandmarks = [];
                              value.landmarks!.forEach((value){
                                if(value.floor == SingletonFunctionController.building.floor[value.buildingID]){
                                  createLandmarks.add(value);
                                }
                              });
                              land current = land();
                              landmarkMarkers.clear();
                              current.landmarks = createLandmarks;
                              createMarkers(current, 0, buildingAllApi.selectedBuildingID,forced: true);
                            });
                            landmarkMarkers.forEach((value) {
                              if (value.markerId
                                  .toString()
                                  .contains(selectedMarkerId)) {
                                value.visible = true;
                              }
                            });
                            selectedMarkerId = "";
                            _polygon.clear();
                            cachedPolygon.clear();
                            calculatingPath = false;
                            //  circles.clear();
                            showMarkers();
                            toggleLandmarkPanel();
                            _isBuildingPannelOpen = true;
                          },
                          icon: Semantics(
                            label: "Back",
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          child: Text(
                            snapshot
                                .data!
                                .landmarksMap![SingletonFunctionController
                                .building.selectedLandmarkID]!
                                .name ??
                                snapshot
                                    .data!
                                    .landmarksMap![SingletonFunctionController
                                    .building.selectedLandmarkID]!
                                    .element!
                                    .subType!,
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff8e8d8d),
                              height: 25 / 16,
                            ),
                          )),
                    ),
                    // Container(
                    //   height: 48,
                    //   width: 47,
                    //   child: Center(
                    //     child: IconButton(
                    //       onPressed: () {
                    //         _polygon.clear();
                    //         cachedPolygon.clear();
                    //         //  circles.clear();
                    //         showMarkers();
                    //         toggleLandmarkPanel();
                    //         _isBuildingPannelOpen = true;
                    //       },
                    //       icon: Semantics(
                    //         label: "Close",
                    //         child: Icon(
                    //           Icons.cancel_outlined,
                    //           color: Colors.black,
                    //           size: 24,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                )),
          ),
        ),
        SafeArea(
          child: SlidingUpPanel(
            controller: _landmarkPannelController,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ],
            minHeight: startTime ? 220 : 185,
            maxHeight: events.isNotEmpty
                ? screenHeight
                : (contactDetail && microService
                ? 0.73
                : (contactDetail
                ? (screenHeight * 0.45)
                : (microService
                ? (screenHeight * 0.28)
                : (startTime ? 220 : 185)))),
            snapPoint: 0.6,
            panel: () {
              _isRoutePanelOpen = false;
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press button to start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return landmarkPannelShimmer();
                case ConnectionState.done:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  return Semantics(
                    header: true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          contactDetail
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 38,
                                height: 6,
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xffd9d9d9),
                                  borderRadius:
                                  BorderRadius.circular(5.0),
                                ),
                              ),
                            ],
                          )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 17, top: 12, bottom: 4),
                                    child: Focus(
                                      autofocus: true,
                                      child: Semantics(
                                        child: Builder(
                                          builder: (context) {
                                            final landmark =
                                            snapshot.data!.landmarksMap![
                                            SingletonFunctionController
                                                .building
                                                .selectedLandmarkID]!;
                                            final text =
                                                landmark.renderDetail?.name ??
                                                    landmark.name ??
                                                    landmark.element!.subType!;
                                            final words = text.split(" ");
                                            final displayText = text.length > 25
                                                ? words.take(3).join(" ") +
                                                ((words.length > 3) ? "\n" : "") +
                                                words.skip(3).join(" ")
                                                : text;
                                            return Text(
                                              displayText,
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff000000),
                                                height: 28 / 22,
                                              ),
                                              textAlign: TextAlign.left,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                    EdgeInsets.only(left: 17, bottom: 4),
                                    child: Text(
                                      "${LocaleData.floor.getString(context)} ${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.floor}${(snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.buildingName == snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.venueName) ? ("") : (", ${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.buildingName}")}",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff777777),
                                        height: 24 / 16,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    padding:
                                    EdgeInsets.only(left: 17, bottom: 4),
                                    child: Text(
                                      "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.venueName}",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff777777),
                                        height: 20 / 14,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  snapshot
                                      .data!
                                      .landmarksMap![
                                  SingletonFunctionController
                                      .building
                                      .selectedLandmarkID]!
                                      .properties!
                                      .startTime !=
                                      null
                                      ? Container(
                                    padding: EdgeInsets.only(
                                        left: 17, bottom: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.startTime} AM- ${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.endTime} PM  ",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff777777),
                                            height: 20 / 14,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        tools.isNowBetween(
                                            snapshot
                                                .data!
                                                .landmarksMap![
                                            SingletonFunctionController
                                                .building
                                                .selectedLandmarkID]!
                                                .properties!
                                                .startTime!,
                                            snapshot
                                                .data!
                                                .landmarksMap![
                                            SingletonFunctionController
                                                .building
                                                .selectedLandmarkID]!
                                                .properties!
                                                .endTime!)
                                            ? Text(
                                          "Open Now",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w400,
                                            color:
                                            Color(0xff4CAF50),
                                            height: 20 / 14,
                                          ),
                                          textAlign: TextAlign.left,
                                        )
                                            : Text(
                                          "Closed",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w400,
                                            color: Colors.redAccent,
                                            height: 20 / 14,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  )
                                      : Container(),

                                  // (user.initialallyLocalised &&
                                  //         user.floor ==
                                  //             snapshot
                                  //                 .data!
                                  //                 .landmarksMap![
                                  //                     SingletonFunctionController
                                  //                         .building
                                  //                         .selectedLandmarkID]!
                                  //                 .floor!)
                                  //     ? Container(
                                  //         padding: EdgeInsets.only(
                                  //           left: 17,
                                  //         ),
                                  //         child: Text(
                                  //           "${aerialDist.toStringAsFixed(2)} m",
                                  //           style: const TextStyle(
                                  //             fontFamily: "Roboto",
                                  //             fontSize: 10,
                                  //             fontWeight: FontWeight.w400,
                                  //             color: Color(0xff8d8c8c),
                                  //             height: 25 / 16,
                                  //           ),
                                  //           textAlign: TextAlign.left,
                                  //         ),
                                  //       )
                                  //     : SizedBox(),
                                ],
                              ),
                              Semantics(
                                excludeSemantics: true,
                                child: Container(
                                    margin: EdgeInsets.only(top: 8, right: 16),
                                    child: IconButton(
                                        onPressed: () {
                                          HelperClass.shareContent(
                                              "${AppConfig.baseUrl}/#/landmarkId/${SingletonFunctionController.building.selectedLandmarkID!}",
                                              snapshot
                                                  .data!
                                                  .landmarksMap![
                                              SingletonFunctionController
                                                  .building
                                                  .selectedLandmarkID]!
                                                  .name ??
                                                  "landmark");
                                        },
                                        icon: Semantics(
                                            label: "Share route information",
                                            child: Icon(Icons.share)))),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          contactDetail
                              ? Semantics(
                            label: "Contact Details",
                            excludeSemantics: true,
                            child: Container(
                              margin: EdgeInsets.only(left: 17, top: 20),
                              child: Text(
                                "Contact Details",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff000000),
                                  height: 21 / 18,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          )
                              : Container(),
                          snapshot
                              .data!
                              .landmarksMap![SingletonFunctionController
                              .building.selectedLandmarkID]!
                              .properties!
                              .contactNo !=
                              null
                              ? InkWell(
                            onTap: () {
                              HelperClass.makePhoneCall(snapshot
                                  .data!
                                  .landmarksMap![
                              SingletonFunctionController
                                  .building.selectedLandmarkID]!
                                  .properties!
                                  .contactNo!);
                            },
                            child: Container(
                              margin:
                              EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: 12),
                                      width: 24,
                                      height: 24,
                                      child: Semantics(
                                        excludeSemantics: true,
                                        child: SvgPicture.asset(
                                            "assets/call.svg"),
                                      )),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Phone",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff777777),
                                          height: 16 / 12,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        width: screenWidth - 100,
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff055aa5),
                                              height: 24 / 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.contactNo!}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                              : Container(),
                          snapshot
                              .data!
                              .landmarksMap![
                          SingletonFunctionController
                              .building.selectedLandmarkID]!
                              .properties!
                              .email !=
                              "" &&
                              snapshot
                                  .data!
                                  .landmarksMap![
                              SingletonFunctionController
                                  .building.selectedLandmarkID]!
                                  .properties!
                                  .email !=
                                  null
                              ? InkWell(
                            onTap: () {
                              HelperClass.sendMailto(
                                  email: snapshot
                                      .data!
                                      .landmarksMap![
                                  SingletonFunctionController
                                      .building
                                      .selectedLandmarkID]!
                                      .properties!
                                      .email!);
                            },
                            child: Container(
                              margin:
                              EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: 12),
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          "assets/email.svg")),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff777777),
                                          height: 16 / 12,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        width: screenWidth - 100,
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff055aa5),
                                              height: 24 / 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.email!}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                              : Container(),
                          snapshot
                              .data!
                              .landmarksMap![
                          SingletonFunctionController
                              .building.selectedLandmarkID]!
                              .properties!
                              .url !=
                              "" &&
                              snapshot
                                  .data!
                                  .landmarksMap![
                              SingletonFunctionController
                                  .building.selectedLandmarkID]!
                                  .properties!
                                  .url !=
                                  null
                              ? InkWell(
                            onTap: () {
                              HelperClass.launchURL(snapshot
                                  .data!
                                  .landmarksMap![
                              SingletonFunctionController
                                  .building.selectedLandmarkID]!
                                  .properties!
                                  .url!);
                            },
                            child: Container(
                              margin:
                              EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: 12),
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          "assets/website.svg")),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Website",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff777777),
                                          height: 16 / 12,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        width: screenWidth - 100,
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff055aa5),
                                              height: 24 / 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.url!}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                              : Container(),
                          events.isNotEmpty
                              ? ExcludeSemantics(
                            child: Container(
                              margin: EdgeInsets.only(left: 17, top: 20),
                              child: Text(
                                "Event Happening Here",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff000000),
                                  height: 21 / 18,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          )
                              : Container(),
                          Semantics(
                              excludeSemantics: true,
                              child: Container(
                                  height: screenHeight - 280,
                                  child: SingleChildScrollView(
                                      child: Column(
                                        children: events,
                                      ))))
                        ],
                      ),
                    ),
                  );
              }
            }(),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Semantics(
            header: true,
            child: Container(
                height: 80,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color
                  boxShadow: (contactDetail || microService)
                      ? [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.1), // Shadow color
                      offset: Offset(0, -3), // Shadow offset (top shadow)
                      blurRadius: 6, // Blur radius
                      spreadRadius: 1, // Spread radius
                    )
                  ]
                      : null,
                ),
                child: Center(
                  // Center the button vertically
                  child: SizedBox(
                    height: 40, // Set the desired height for the TextButton
                    width: screenWidth - 32, // Set the width as needed
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xff6CC8BF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                      ),
                      onPressed: calculatingPath
                          ? null
                          : () async {
                        // stopContinuousGPSLocalisation();
                        hasPressedButton = true;
                        // landmarkMarkers.forEach((it) {
                        //   it.visible = false;
                        // });
                        // _landmarks.clear();
                        _directionFocus.requestFocus();
                        // landmarkMarkers.clear();
                        // clustringOFF = true;
                        setState(() {});
                        print("clustring turned ${clustringOFF}");

                        print("landmarkMarkers.clear() ${landmarkMarkers.length}");
                        Future<void> initFuture = Future.value();
                        if (SingletonFunctionController.apibeaconmap[
                        SingletonFunctionController
                            .currentBeacon] !=
                            null) {
                          _localizeTimer?.cancel();
                          final landmarkData =
                          await SingletonFunctionController
                              .building.landmarkdata;
                          final userSetLocation =
                          tools.localizefindNearbyLandmark(
                              SingletonFunctionController
                                  .apibeaconmap[
                              SingletonFunctionController
                                  .currentBeacon]!,
                              landmarkData!.landmarksMap!);
                          // print("usersetlocation::${userSetLocation!.name}");
                          if (userSetLocation != null) {
                            // Get pinned landmark
                            final pinnedX =
                                PinedLandmark?.coordinateX ?? 0;
                            final pinnedY =
                                PinedLandmark?.coordinateY ?? 0;
                            final userX = userSetLocation.coordinateX;
                            final userY = userSetLocation.coordinateY;
                            final distance = sqrt(
                                pow(userX! - pinnedX, 2) +
                                    pow(userY! - pinnedY, 2));
                            print(
                                "Skipping initializeUser due to short distance ${pinnedX} ${pinnedY} ${userX} ${userY} ($distance)");
                            if (distance < double.infinity) {
                              initFuture = Future.value(); // dummy future
                            } else {
                              initFuture = initializeUser(userSetLocation,
                                  speakTTS: false, render: false);
                            }
                          }
                        }
                        PinedLandmark = null;
                        // Always run this regardless of distance
                        initFuture.then((onValue) {
                          setState(() {
                            calculatingPath = true;
                            isFromLocalize = true;
                          });
                          SingletonFunctionController.currentBeacon = "";
                          SingletonFunctionController().dispose();
                          bleManager.stopScanning();
                          _polygon.clear();
                          cachedPolygon.clear();
                          Markers.clear();
                          setState(() {});
                          if (user.coordY != 0 && user.coordX != 0) {
                            PathState.sourceX = user.coordX;
                            PathState.sourceY = user.coordY;
                            PathState.sourceLat = user.lat;
                            PathState.sourceLng = user.lng;
                            PathState.sourceFloor = user.floor;
                            PathState.sourcePolyID = user.key;
                            PathState.sourceName =
                            "Your current location";
                            PathState.destinationPolyID =
                            SingletonFunctionController
                                .building.selectedLandmarkID!;
                            PathState.destinationName =
                                snapshot.data!.landmarksMap![PathState.destinationPolyID]!.renderDetail?.name ??
                                    snapshot.data!.landmarksMap![PathState.destinationPolyID]!.name ??
                                    snapshot.data!.landmarksMap![PathState.destinationPolyID]!.element!.subType!;
                            PathState.destinationFloor = snapshot
                                .data!
                                .landmarksMap![
                            PathState.destinationPolyID]!
                                .floor!;
                            PathState.sourceBid = user.bid;
                            PathState.destinationBid = snapshot
                                .data!
                                .landmarksMap![
                            PathState.destinationPolyID]!
                                .buildingID!;
                            Future.delayed(Duration(milliseconds: 400),
                                    () {
                                  calculateroute(snapshot.data!.landmarksMap!)
                                      .then((value) {
                                    calculatingPath = false;
                                    _isLandmarkPanelOpen = false;
                                    _isRoutePanelOpen = true;
                                  });
                                });
                          } else {
                            PathState.sourceName =
                            "Choose Starting Point";
                            PathState.destinationPolyID =
                            SingletonFunctionController
                                .building.selectedLandmarkID!;
                            PathState.destinationName = snapshot.data!.landmarksMap![PathState.destinationPolyID]!.renderDetail?.name ??
                                snapshot.data!.landmarksMap![PathState.destinationPolyID]!.name ??
                                snapshot.data!.landmarksMap![PathState.destinationPolyID]!.element!.subType!;
                            PathState.destinationFloor = snapshot
                                .data!
                                .landmarksMap![
                            PathState.destinationPolyID]!
                                .floor!;
                            SingletonFunctionController
                                .building.selectedLandmarkID = "";
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SourceAndDestinationPage(
                                      DestinationID:
                                      PathState.destinationPolyID,
                                      user: user,
                                    ),
                              ),
                            ).then((value) {
                              if (value != null) {
                                fromSourceAndDestinationPage(value);
                              }
                            });
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "${LocaleData.direction.getString(context)}",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        )
      ],
    );
  }

  int calculateindex(int x, int y, int fl) {
    return (y * fl) + x;
  }

  List<CommonConnection> findCommonLifts(
      Landmarks landmark1, Landmarks landmark2, String accessibleby) {
    List<CommonConnection> commonLifts = [];
    final stackTrace = StackTrace.current;
    print("findCommonLifts Stack: \n$stackTrace");
    print("landmark1.lifts! ${landmark1.lifts!}");
    print("landmark2.lifts! ${landmark2.lifts!}");
    if (accessibleby == "Lifts") {
      for (var lift1 in landmark1.lifts!) {
        for (var lift2 in landmark2.lifts!) {
          if (lift1.name == lift2.name) {
            // Create a new Lifts object with x and y values from both input lists
            print("lift ${lift1.name} <> ${lift1.distance}");
            commonLifts.add(CommonConnection(
                name: lift1.name,
                x1: lift1.x,
                y1: lift1.y,
                x2: lift2.x,
                y2: lift2.y,
                d1: lift1.distance,
                d2: lift2.distance));
            break;
          }
        }
      }
    } else if (accessibleby == "Stairs") {
      for (var stair1 in landmark1.stairs!) {
        for (var stair2 in landmark2.stairs!) {
          if (stair1.name == stair2.name) {
            // Create a new Lifts object with x and y values from both input lists

            commonLifts.add(CommonConnection(
                name: stair1.name,
                x1: stair1.x,
                y1: stair1.y,
                x2: stair2.x,
                y2: stair2.y,
                d1: stair1.distance,
                d2: stair2.distance));
            break;
          }
        }
      }
    } else if (accessibleby == "Ramps") {
      for (var ramp1 in landmark1.ramps!) {
        for (var ramp2 in landmark2.ramps!) {
          if (ramp1.name == ramp2.name) {
            // Create a new Lifts object with x and y values from both input lists

            commonLifts.add(CommonConnection(
                name: ramp1.name,
                x1: ramp1.x,
                y1: ramp1.y,
                x2: ramp2.x,
                y2: ramp2.y,
                d1: ramp1.distance,
                d2: ramp2.distance));
            break;
          }
        }
      }
    } else if (accessibleby == "Escalators") {
      for (var escalator1 in landmark1.escalators!) {
        for (var escalator2 in landmark2.escalators!) {
          if (escalator1.name == escalator2.name) {
            // Create a new Lifts object with x and y values from both input lists

            commonLifts.add(CommonConnection(
                name: escalator1.name,
                x1: escalator1.x,
                y1: escalator1.y,
                x2: escalator2.x,
                y2: escalator2.y,
                d1: escalator1.distance,
                d2: escalator2.distance));
            break;
          }
        }
      }
    }
    // Sort the commonLifts based on distance
    commonLifts.sort((a, b) {
      if (a.d1 == 0)
        return -1; // Ensure the single element with d1 == 0 is first
      if (b.d1 == 0) return 1; // Ensure others are placed after it

      final aSum = (a.d1 ?? 0) + (a.d2 ?? 0);
      final bSum = (b.d1 ?? 0) + (b.d2 ?? 0);

      return aSum.compareTo(bSum);
    });

    return commonLifts;
  }

  Map<List<String>, Set<gmap.Polyline>> interBuildingPath = new Map();

  Future<void> fetchRouteInIsolate(fetchrouteParams params) async {
    await fetchroute(
      params.sourceX,
      params.sourceY,
      params.destinationX,
      params.destinationY,
      params.floor,
      liftName: params.liftName,
      renderSource: params.renderSource,
      renderDestination: params.renderDestination,
    );
  }

  Future<void> runFuturesSequentially(
      List<Future<dynamic>> fetchrouteFutures) async {
    for (var future in fetchrouteFutures) {
      await future;
    }
  }

  void runInBackground(List<Future<dynamic>> fetchrouteFutures) {
    compute(runFuturesSequentially, fetchrouteFutures);
  }

  Future<Landmarks?> findCampusEntry(land land, Landmarks entry) async {
    try {
      return await land.landmarks!.firstWhere(
            (element) =>
        element.name == entry.name &&
            element.buildingID == buildingAllApi.outdoorID,
        orElse: () => throw Exception('No matching landmark found'),
      );
    } catch (e) {
      return null;
      print("CampusDestinationEntry error $e");
    }
    return null;
  }
  void setBuildingFloors(List<String> bids, {int? floor}) {
    for (var bid in bids) {
      if (bid != buildingAllApi.outdoorID) {
        SingletonFunctionController.building.floor[bid] = floor??PathState.sourceFloor;
        if (Building.numberOfFloorsDelhi[bid]!
            .contains(floor??PathState.sourceFloor)) {
          createRooms(
            SingletonFunctionController.building.polylinedatamap[bid]!,
            floor??PathState.sourceFloor,
          );
        }
      } else {
        SingletonFunctionController.building.floor[bid] = floor??PathState.sourceFloor;
      }
    }
  }

  void fitToPath(List<Cell> result) async {
    Cell? firstCell;
    Cell? lastCell;

    int? targetFloor = result.isNotEmpty ? result.first.floor : null;

    for (final cell in result) {
      if (cell.floor != targetFloor) break;

      firstCell ??= cell;   // assign when first time reached
      lastCell = cell;      // update continuously
    }
      List<LatLng> points = [
        LatLng(firstCell!.lat, firstCell!.lng),
        LatLng(lastCell!.lat, lastCell!.lng)
      ];
      print("source latlngs:${points.first}");
      print("destination latlngs:${points.last}");
      fitTwoPoints(points);

  }

  Future<void> fitTwoPoints(List<LatLng> points) async {
    LatLng point1 = points.first;
    LatLng point2 = points.last;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        point1.latitude < point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude < point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
      northeast: LatLng(
        point1.latitude > point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude > point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
    );
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(
        bounds, MediaQuery.of(context).size.height * 0.0872093023255814);
    // First move to an intermediate zoom level for a smooth effect
    await _googleMapController.animateCamera(CameraUpdate.zoomOut());
    await Future.delayed(Duration(milliseconds: 500));
    _googleMapController.animateCamera(cameraUpdate);
  }
  Future<void> runPaths(List<dynamic Function()> fetchrouteFutures,
      {bool autoStart = false}) async {
    //try {
    if (fetchrouteFutures.isNotEmpty) {
      //await createRooms(SingletonFunctionController.building.polylinedatamap[PathState.sourceBid]!, PathState.sourceFloor);
      print("starting calc");
      List<Future<List<Map<String, dynamic>>>> resolvedFutures =
      fetchrouteFutures.map((func) async {
        final list = await func(); // This is List<dynamic>
        return List<Map<String, dynamic>>.from(list); // Safely cast
      }).toList();
      List<List<Map<String, dynamic>>> resolved =
      await Future.wait(resolvedFutures);
      List<Map<String, dynamic>> result = resolved.expand((e) => e).toList();
      if (Building.GlobalAnnotation?.pathNetwork?.masterGraph != null) {
        result = result.reversed.toList();
      }

      List<direction?> lifts = [];
      for (var res in result) {
        Map<String, dynamic> data = await res;
        List<Cell> cellList = data["CellPath"];
        List<String> intermediatesBids = tools.findIntermediateBuildings(cellList);
        SingletonFunctionController.building.floorDimenssion
            .forEach((bid, map) {
          map.forEach((floor, dimmensions) {
            PathState.numCols ??= {};
            PathState.numCols!.putIfAbsent(bid, () => {});
            PathState.numCols![bid]!.putIfAbsent(floor, () => dimmensions[0]);
            PathState.numCols![bid]![floor] = dimmensions[0];
          });
        });

        setBuildingFloors(intermediatesBids);
        List<int> integerPath = cellList.map<int>((cell) => cell.node).toList();
        PathState.singleListPath.insertAll(0, integerPath);
        PathState.singleCellListPath.insertAll(0, data["CellPath"]);
        lifts.add(data["lift"]);
        print(
            "PathState.singleCellListPath ${PathState.singleCellListPath.length} ${PathState.singleCellListPath}");
      }

      PathState.directions =
      await createMarkersAndDirections(PathState.singleCellListPath, lifts);

      if (PathState.singleCellListPath.isNotEmpty) {
        fitToPath(PathState.singleCellListPath);
        setState(() {
          _focusNodeA.unfocus();
          _focusNodeA.requestFocus();
          semanticsLabel = "Start button double tap to navigate";
          startingNavigation = true;
        });

        int? distance = 0;
        PathState.directionInstructionViewModel = DirectionInstructionViewModel(
            PathState.directions,
            PathState.sourceBid,
            PathState.sourceName,
            PathState.sourceFloor,
            PathState.destinationBid,
            PathState.destinationName,
            PathState.destinationFloor,
            Building.buildingData,
            context);
        final distances = {
          PathState.directionInstructionViewModel?.totalSourceDistance,
          PathState.directionInstructionViewModel?.totalOutdoorDistance,
          PathState.directionInstructionViewModel?.totalDestinationDistance,
        };
        print("distances $distances");
        distance = distances.reduce((a, b) => a! + b!);

        if (autoStart) {
          startNavigation();
          setState(() {
            _isreroutePannelOpen = false;
          });
          return;
        }

        if (PathState.destinationName ==
            "${LocaleData.yourcurrentloc.getString(context)}") {
          if(canNavigate()){
            speak(
                "${LocaleData.yourcurrentloc.getString(context)} ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. ${LocaleData.clickstarttonavigate.getString(context)}",
                _currentLocale);
          }else{
            speak(
                "${LocaleData.yourcurrentloc.getString(context)} ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. Click Steps for route preview",
                _currentLocale);
          }
        } else {
          if(canNavigate()){
            speak(
                "${PathState.destinationName} ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. ${LocaleData.clickstarttonavigate.getString(context)}",
                _currentLocale);
          }else{
            speak(
                "${PathState.destinationName} ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. Click Steps for route preview",
                _currentLocale);
          }
        }
      }else{
        print("PathState.singleCellListPath is empty");
      }
    } else {
      print("starting calc not happening");
    }

    // } catch (e) {
    //   setState(() {
    //     PathState.noPathFound = true;
    //   });
    //   return;
    // }
  }

  String getBestConnection(List<String> available, String preferred) {
    const priority = ["Lifts", "Escalators", "Ramps", "Stairs"];
    if (available.contains(preferred)) return preferred;

    // Fallback to best available option based on priority
    for (final mode in priority) {
      if (available.contains(mode)) return mode;
    }
    // No valid connection (shouldn't happen if at least one connection exists)
    return "Unavailable";
  }

  List<String> getAvailableConnections(Landmarks landmark) {
    final List<String> available = [];

    if (landmark.lifts != null && landmark.lifts!.isNotEmpty) {
      available.add("Lifts");
    }
    if (landmark.stairs != null && landmark.stairs!.isNotEmpty) {
      available.add("Stairs");
    }
    if (landmark.escalators != null && landmark.escalators!.isNotEmpty) {
      available.add("Escalators");
    }
    if (landmark.ramps != null && landmark.ramps!.isNotEmpty) {
      available.add("Ramps");
    }

    print("getAvailableConnections $available");

    return available;
  }

  Future<void> calculateroute(Map<String, Landmarks> landmarksMap,
      {String? accessibleby, bool autoStart = false}) async {
    String? accessiblebySource = accessibleby;
    String? accessiblebyDestination = accessibleby;
    List<Function()> fetchrouteFutures = [];
    PathState.singleCellListPath.clear();
    setState(() {
      _focusNodeA.requestFocus();
      startingNavigation = false;
      semanticsLabel = "Please wait calculating the path";
    });

    if (PathState.sourcePolyID == "") {
      PathState.sourcePolyID = tools
          .localizefindNearbyLandmarkSecond(user, landmarksMap)!
          .properties!
          .polyId!;
    } else if (landmarksMap[PathState.sourcePolyID]!.lifts == null ||
        landmarksMap[PathState.sourcePolyID]!.lifts!.isEmpty) {
      Landmarks? land = tools.localizefindNearbyLandmarkSecond(
          user, landmarksMap,
          increaserange: true);
      if (land != null) {
        landmarksMap[PathState.sourcePolyID]!.lifts = land.lifts;
      }
    }
    try {
      if (PathState.sourcePolyID == "") {
        PathState.sourcePolyID = tools
            .localizefindNearbyLandmarkSecond(user, landmarksMap)!
            .properties!
            .polyId!;
      } else if (landmarksMap[PathState.sourcePolyID]!.lifts == null ||
          landmarksMap[PathState.sourcePolyID]!.lifts!.isEmpty) {
        landmarksMap[PathState.sourcePolyID]!.lifts = tools
            .localizefindNearbyLandmarkSecond(user, landmarksMap,
            increaserange: true)!
            .lifts;
      }
    } catch (e) {}

    List<String> availableConnections1 = []; // from building
    if (PathState.sourceFloor != 0) {
      availableConnections1 = getAvailableConnections(
          landmarksMap[PathState.sourcePolyID]!); // from building
    }
    List<String> availableConnections2 = []; // from building
    if (PathState.destinationFloor != 0) {
      availableConnections2 = getAvailableConnections(
          landmarksMap[PathState.destinationPolyID]!); // from building
    }

    if (PathState.sourceBid == buildingAllApi.outdoorID) {
      availableConnections1 = [];
    }
    if (PathState.destinationBid == buildingAllApi.outdoorID) {
      availableConnections2 = [];
    }

    var availableConnectionsUnion =
    {...availableConnections1, ...availableConnections2}.toList();

    if (availableConnections1.isNotEmpty && availableConnections2.isNotEmpty) {
      if (availableConnections1
          .toSet()
          .intersection(availableConnections2.toSet())
          .isEmpty) {
        availableConnectionsUnion = [];
      }
    }

    if (Building.GlobalAnnotation?.pathNetwork?.masterGraph != null) {
      availableConnectionsUnion =
          PathState.getAvailableConnectionsUnion(Building.GlobalAnnotation!);
    }

    PathState.filteredOptions = PathState.allOptions
        .where((option) =>
        availableConnectionsUnion.contains(option["accessibleBy"]))
        .toList();

    if (accessibleby == null &&
        PathState.sourceFloor != PathState.destinationFloor &&
        (PathState.filteredOptions ?? []).isNotEmpty) {
      print("filteredOptions ${PathState.filteredOptions}");
      PathState.accessiblePath =
      PathState.getHighestPriorityConnection(PathState.filteredOptions!)!;
      accessibleby = PathState.accessiblePath;
    }
    accessiblebySource =
        getBestConnection(availableConnections1, accessibleby ?? "");
    accessiblebyDestination =
        getBestConnection(availableConnections2, accessibleby ?? "");
    print("accessibleby $accessibleby");

    // circles.clear();

    //
    //
    //
    //
    playPreviewManager?.clearPreview();
    PathState.noPathFound = false;
    singleroute.clear();
    pathCovered.clear();
    pathMarkers.clear();
    // Markers.clear();
    print(
        "landmarksMap[PathState.destinationPolyID] ${landmarksMap[PathState.destinationPolyID]!.name}");
    if (PathState.destinationX != user.coordX ||
        PathState.destinationY != user.coordY) {
      PathState.destinationX =
      landmarksMap[PathState.destinationPolyID]!.coordinateX!;
      PathState.destinationY =
      landmarksMap[PathState.destinationPolyID]!.coordinateY!;
      if (landmarksMap[PathState.destinationPolyID]!.doorX != null) {
        PathState.destinationX =
        landmarksMap[PathState.destinationPolyID]!.doorX!;
        PathState.destinationY =
        landmarksMap[PathState.destinationPolyID]!.doorY!;
      }
    }
    print(
        "calculateroutesource ${PathState.sourceX},${PathState.sourceY} <> ${PathState.sourceBid},${PathState.sourceFloor}");
    print(
        "calculateroutedestination ${PathState.destinationX},${PathState.destinationY} <> ${PathState.destinationBid},${PathState.destinationFloor}, ${PathState.destinationPolyID}");
    if (Building.GlobalAnnotation?.pathNetwork?.masterGraph != null) {
      fetchrouteFutures.add(() => fetchroute(
          PathState.sourceX,
          PathState.sourceY,
          PathState.destinationX,
          PathState.destinationY,
          PathState.destinationFloor,
          Bid: PathState.destinationBid,
          renderDestination: true,
          renderSource: true));
      runPaths(fetchrouteFutures, autoStart: autoStart);
    } else if (PathState.sourceBid == PathState.destinationBid) {
      if (PathState.sourceFloor == PathState.destinationFloor) {
        List<double> svalue = [];
        List<double> dvalue = [];
        svalue = tools.localtoglobal(
            PathState.sourceX,
            PathState.sourceY,
            SingletonFunctionController
                .building.patchData[PathState.sourceBid]);
        dvalue = tools.localtoglobal(
            PathState.destinationX,
            PathState.destinationY,
            SingletonFunctionController
                .building.patchData[PathState.destinationBid]);
        // setCameraPositionusingCoords(
        //     [LatLng(svalue[0], svalue[1]), LatLng(dvalue[0], dvalue[1])]);
        fetchrouteFutures.add(() => fetchroute(
            PathState.sourceX,
            PathState.sourceY,
            PathState.destinationX,
            PathState.destinationY,
            PathState.destinationFloor,
            Bid: PathState.destinationBid));
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()] = user.floor;

        if (markers.length > 0)
          markers[user.bid]?[0] = customMarker.rotate(0, markers[user.bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        mapState.zoom = 21;
      } else if (PathState.sourceFloor != PathState.destinationFloor) {
        List<CommonConnection> commonlifts = findCommonLifts(
            landmarksMap[PathState.sourcePolyID]!,
            landmarksMap[PathState.destinationPolyID]!,
            accessibleby ?? "Lifts");
        if (commonlifts.isEmpty) {
          setState(() {
            PathState.noPathFound = true;
            _isLandmarkPanelOpen = false;
            _isRoutePanelOpen = true;
          });
          return;
        }
        fetchrouteFutures.add(() => fetchroute(
            commonlifts[0].x2!,
            commonlifts[0].y2!,
            PathState.destinationX,
            PathState.destinationY,
            PathState.destinationFloor,
            Bid: PathState.destinationBid,
            liftName: commonlifts[0].name,
            nextFloor: PathState.sourceFloor));

        fetchrouteFutures.add(() => fetchroute(
          PathState.sourceX,
          PathState.sourceY,
          commonlifts[0].x1!,
          commonlifts[0].y1!,
          PathState.sourceFloor,
          Bid: PathState.destinationBid,
          liftName: commonlifts[0].name,
          renderDestination: false,
          nextFloor: PathState.destinationFloor,
        ));

        PathState.connections[PathState.destinationBid] = {
          PathState.sourceFloor: calculateindex(
              commonlifts[0].x1!,
              commonlifts[0].y1!,
              SingletonFunctionController.building.floorDimenssion[
              PathState.destinationBid]![PathState.sourceFloor]![0]),
          PathState.destinationFloor: calculateindex(
              commonlifts[0].x2!,
              commonlifts[0].y2!,
              SingletonFunctionController.building.floorDimenssion[
              PathState.destinationBid]![PathState.destinationFloor]![0])
        };
      }
      runPaths(fetchrouteFutures, autoStart: autoStart);
    } else if (PathState.sourceBid == buildingAllApi.outdoorID ||
        PathState.destinationBid == buildingAllApi.outdoorID) {
      SingletonFunctionController.building.landmarkdata!.then((land) async {
        Landmarks? buildingEntry;

        if (PathState.destinationBid == buildingAllApi.outdoorID) {
          buildingEntry = await tools.findNearestPoint(PathState.sourcePolyID,
              PathState.destinationPolyID, land.landmarks!);
        } else {
          buildingEntry = await tools.findNearestPoint(
              PathState.destinationPolyID,
              PathState.sourcePolyID,
              land.landmarks!);
          print("pathcchec 1 ${buildingEntry.name}");
        }

        Landmarks? CampusEntry = await findCampusEntry(land, buildingEntry);
        print("pathcchec 2 ${CampusEntry!.name}");

        if (PathState.destinationBid == buildingAllApi.outdoorID) {
          fetchrouteFutures.add(() => fetchroute(
              CampusEntry!.coordinateX!,
              CampusEntry!.coordinateY!,
              PathState.destinationX,
              PathState.destinationY,
              CampusEntry.floor!,
              Bid: CampusEntry.buildingID));
          if (PathState.sourceFloor == buildingEntry!.floor) {
            fetchrouteFutures.add(() => fetchroute(
                PathState.sourceX,
                PathState.sourceY,
                buildingEntry!.coordinateX!,
                buildingEntry!.coordinateY!,
                buildingEntry!.floor!,
                Bid: PathState.sourceBid,
                renderDestination: false));
          } else if (PathState.sourceFloor != buildingEntry!.floor) {
            List<dynamic> commonlifts = findCommonLifts(
                landmarksMap[PathState.sourcePolyID]!,
                buildingEntry!,
                accessiblebySource ?? "Lifts");
            if (commonlifts.isEmpty) {
              setState(() {
                PathState.noPathFound = true;
                _isLandmarkPanelOpen = false;
                _isRoutePanelOpen = true;
              });
              return;
            }

            fetchrouteFutures.add(() => fetchroute(
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                buildingEntry!.coordinateX!,
                buildingEntry!.coordinateY!,
                buildingEntry!.floor!,
                Bid: PathState.sourceBid,
                renderDestination: false,
                nextFloor: PathState.sourceFloor));
            fetchrouteFutures.add(() => fetchroute(
                PathState.sourceX,
                PathState.sourceY,
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                PathState.sourceFloor,
                Bid: PathState.sourceBid,
                renderDestination: false,
                nextFloor: buildingEntry!.floor!));

            PathState.connections[PathState.sourceBid] = {
              PathState.sourceFloor: calculateindex(
                  commonlifts[0].x1!,
                  commonlifts[0].y1!,
                  SingletonFunctionController.building.floorDimenssion[
                  PathState.sourceBid]![PathState.sourceFloor]![0]),
              buildingEntry!.floor!: calculateindex(
                  commonlifts[0].x2!,
                  commonlifts[0].y2!,
                  SingletonFunctionController.building.floorDimenssion[
                  PathState.sourceBid]![buildingEntry!.floor!]![0])
            };
          }
        } else {
          if (PathState.destinationFloor == buildingEntry!.floor) {
            fetchrouteFutures.add(() => fetchroute(
              buildingEntry!.coordinateX!,
              buildingEntry!.coordinateY!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              Bid: buildingEntry.buildingID,
            ));
          } else if (PathState.destinationFloor != buildingEntry!.floor) {
            List<dynamic> commonlifts = findCommonLifts(
                landmarksMap[PathState.destinationPolyID]!,
                buildingEntry!,
                accessiblebyDestination ?? "Lifts");
            if (commonlifts.isEmpty) {
              setState(() {
                PathState.noPathFound = true;
                _isLandmarkPanelOpen = false;
                _isRoutePanelOpen = true;
              });
              return;
            }

            fetchrouteFutures.add(() => fetchroute(
              commonlifts[0].x1!,
              commonlifts[0].y1!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              Bid: PathState.destinationBid,
              nextFloor: buildingEntry!.floor!,
            ));

            fetchrouteFutures.add(() => fetchroute(
                buildingEntry!.coordinateX!,
                buildingEntry!.coordinateY!,
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                buildingEntry!.floor!,
                Bid: PathState.destinationBid,
                renderDestination: false,
                nextFloor: PathState.destinationFloor));

            PathState.connections[PathState.sourceBid] = {
              PathState.sourceFloor: calculateindex(
                  commonlifts[0].x1!,
                  commonlifts[0].y1!,
                  SingletonFunctionController.building.floorDimenssion[
                  PathState.sourceBid]![PathState.sourceFloor]![0]),
              buildingEntry!.floor!: calculateindex(
                  commonlifts[0].x2!,
                  commonlifts[0].y2!,
                  SingletonFunctionController.building.floorDimenssion[
                  PathState.sourceBid]![buildingEntry!.floor!]![0])
            };
          }
          fetchrouteFutures.add(() => fetchroute(
              PathState.sourceX,
              PathState.sourceY,
              CampusEntry!.coordinateX!,
              CampusEntry!.coordinateY!,
              PathState.sourceFloor,
              Bid: CampusEntry.buildingID,
              renderDestination: false));
        }
        runPaths(fetchrouteFutures, autoStart: autoStart);
      });
    } else {
      SingletonFunctionController.building.landmarkdata!.then((land) async {
        ///destination Entry finding
        Landmarks destinationEntry = await tools.findNearestPoint(
            PathState.destinationPolyID,
            PathState.sourcePolyID,
            land.landmarks!);

        /// source Entry finding
        Landmarks sourceEntry = await tools.findNearestPoint(
            PathState.sourcePolyID,
            PathState.destinationPolyID,
            land.landmarks!);

        /// destinationEntryINCAMPUS
        Landmarks? CampusDestinationEntry =
        await findCampusEntry(land, destinationEntry);

        /// sourceEntryINCAMPUS
        Landmarks? CampusSourceEntry = await findCampusEntry(land, sourceEntry);

        print(
            "CampusSourceEntry is ${CampusSourceEntry?.name} [${CampusSourceEntry?.coordinateX},${CampusSourceEntry?.coordinateY}]");
        print(
            "CampusDestinationEntry is ${CampusDestinationEntry?.name} [${CampusDestinationEntry?.coordinateX},${CampusDestinationEntry?.coordinateY}]");

        ///destination to destination Entry path algorithm
        if (destinationEntry.floor == PathState.destinationFloor) {
          print("dest 1");
          fetchrouteFutures.add(() => fetchroute(
              destinationEntry.coordinateX!,
              destinationEntry.coordinateY!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              Bid: PathState.destinationBid,
              renderSource: false));
        } else if (destinationEntry.floor != PathState.destinationFloor) {
          List<dynamic> commonlifts = findCommonLifts(
              destinationEntry,
              landmarksMap[PathState.destinationPolyID]!,
              accessiblebyDestination ?? "Lifts");
          if (commonlifts.isEmpty) {
            setState(() {
              PathState.noPathFound = true;
              _isLandmarkPanelOpen = false;
              _isRoutePanelOpen = true;
            });
            return;
          }
          print("dest 2");
          fetchrouteFutures.add(() => fetchroute(
              commonlifts[0].x2!,
              commonlifts[0].y2!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              Bid: PathState.destinationBid,
              nextFloor: destinationEntry.floor!));
          fetchrouteFutures.add(() => fetchroute(
            destinationEntry.coordinateX!,
            destinationEntry.coordinateY!,
            commonlifts[0].x1!,
            commonlifts[0].y1!,
            destinationEntry.floor!,
            Bid: PathState.destinationBid,
            liftName: commonlifts[0].name,
            renderSource: false,
            nextFloor: PathState.destinationFloor,
          ));

          PathState.connections[PathState.destinationBid] = {
            destinationEntry.floor!: calculateindex(
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                SingletonFunctionController.building.floorDimenssion[
                PathState.destinationBid]![destinationEntry.floor!]![0]),
            PathState.destinationFloor: calculateindex(
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                SingletonFunctionController.building.floorDimenssion[
                PathState.destinationBid]![PathState.destinationFloor]![0])
          };
        }
        Landmarks source = landmarksMap[PathState.sourcePolyID]!;
        double sourceLat = double.parse(source.properties!.latitude!);
        double sourceLng = double.parse(source.properties!.longitude!);

        Landmarks destination = landmarksMap[PathState.destinationPolyID]!;
        double destinationLat = double.parse(source.properties!.latitude!);
        double destinationLng = double.parse(source.properties!.longitude!);

        ///campusPath algorithm
        if (CampusSourceEntry != null &&
            CampusDestinationEntry != null &&
            CampusSourceEntry.coordinateX != null &&
            CampusSourceEntry.coordinateY != null &&
            CampusDestinationEntry.coordinateX != null &&
            CampusDestinationEntry.coordinateY != null &&
            CampusSourceEntry.floor != null &&
            CampusSourceEntry.buildingID != null) {
          try {
            print("campus 1");
            fetchrouteFutures.add(() => fetchroute(
                CampusSourceEntry!.coordinateX!,
                CampusSourceEntry.coordinateY!,
                CampusDestinationEntry!.coordinateX!,
                CampusDestinationEntry.coordinateY!,
                CampusSourceEntry.floor!,
                Bid: CampusSourceEntry.buildingID,
                renderDestination: false,
                renderSource: false));
          } catch (e) {
            print("calculateroute pathfinding error $e");
            CampusPathAPIAlgorithm(sourceEntry, destinationEntry);
          }
        } else {
          CampusPathAPIAlgorithm(sourceEntry, destinationEntry);
        }

        /// source to source Entry finding
        if (PathState.sourceFloor == sourceEntry.floor) {
          print("source 1");
          fetchrouteFutures.add(() => fetchroute(
              PathState.sourceX,
              PathState.sourceY,
              sourceEntry.coordinateX!,
              sourceEntry.coordinateY!,
              sourceEntry.floor!,
              Bid: PathState.sourceBid,
              renderDestination: false));
        } else if (PathState.sourceFloor != sourceEntry.floor) {
          List<dynamic> commonlifts = findCommonLifts(
              landmarksMap[PathState.sourcePolyID]!,
              sourceEntry,
              accessiblebySource ?? "Lifts");
          if (commonlifts.isEmpty) {
            setState(() {
              PathState.noPathFound = true;
              _isLandmarkPanelOpen = false;
              _isRoutePanelOpen = true;
            });
            return;
          }
          print("source 1");
          fetchrouteFutures.add(() => fetchroute(
              commonlifts[0].x2!,
              commonlifts[0].y2!,
              sourceEntry.coordinateX!,
              sourceEntry.coordinateY!,
              sourceEntry.floor!,
              Bid: PathState.sourceBid,
              renderDestination: false,
              nextFloor: PathState.sourceFloor));
          fetchrouteFutures.add(() => fetchroute(
            PathState.sourceX,
            PathState.sourceY,
            commonlifts[0].x1!,
            commonlifts[0].y1!,
            PathState.sourceFloor,
            Bid: PathState.sourceBid,
            liftName: commonlifts[0].name,
            renderDestination: false,
            nextFloor: sourceEntry.floor!,
          ));

          PathState.connections[PathState.sourceBid] = {
            PathState.sourceFloor: calculateindex(
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                SingletonFunctionController.building.floorDimenssion[
                PathState.sourceBid]![PathState.sourceFloor]![0]),
            sourceEntry.floor!: calculateindex(
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                SingletonFunctionController.building.floorDimenssion[
                PathState.sourceBid]![sourceEntry.floor!]![0])
          };
        }
        runPaths(fetchrouteFutures, autoStart: autoStart);
      });
    }
    _isLandmarkPanelOpen = false;

    setState(() {
      SingletonFunctionController.building
          .floor[buildingAllApi.selectedBuildingID] = PathState.sourceFloor;
    });

    // print("path:${pathState.}");
    return;
  }

  void CampusPathAPIAlgorithm(
      Landmarks sourceEntry, Landmarks destinationEntry) async {
    RealWorld rwModel = RealWorld();
    double sourceEntrylat = 0;
    double sourceEntrylng = 0;
    double destinationEntrylat = 0;
    double destinationEntrylng = 0;
    destinationEntrylat = double.parse(destinationEntry.properties!.latitude!);
    destinationEntrylng = double.parse(destinationEntry.properties!.longitude!);
    sourceEntrylat = double.parse(sourceEntry.properties!.latitude!);
    sourceEntrylng = double.parse(sourceEntry.properties!.longitude!);
    List<double> sourceEntryCoordinates = tools.localtoglobal(
        sourceEntry.coordinateX!,
        sourceEntry.coordinateY!,
        SingletonFunctionController.building.patchData[sourceEntry.buildingID]);
    List<double> destinationEntryCoordinates = tools.localtoglobal(
        destinationEntry.coordinateX!,
        destinationEntry.coordinateY!,
        SingletonFunctionController
            .building.patchData[destinationEntry.buildingID]);

    OutBuildingModel? buildData = await OutBuildingData.outBuildingData(
        sourceEntryCoordinates[0],
        sourceEntryCoordinates[1],
        destinationEntryCoordinates[0],
        destinationEntryCoordinates[1]);

    List<LatLng> coords = [
      LatLng(sourceEntryCoordinates[0], sourceEntryCoordinates[1])
    ];
    PathState.realWorldCoordinates.clear();
    PathState.realWorldCoordinates.add(sourceEntryCoordinates);

    if (buildData != null) {
      //uncomment here
      int len = buildData.path.length;
      for (int i = 0; i < len; i++) {
        // realWorldPath.add(Marker(
        //   markerId: MarkerId('rw [${buildData.path[i][1]},${buildData.path[i][0]}]'),
        //   position: LatLng(buildData.path[i][1],
        //       buildData.path[i][0]),
        //   icon: BitmapDescriptor.fromBytes(realWorldPathMarker),
        // ),);
        coords.add(LatLng(buildData.path[i][1], buildData.path[i][0]));
        PathState.realWorldCoordinates
            .add([buildData.path[i][1], buildData.path[i][0]]);
      }
      coords.add(LatLng(destinationEntrylat, destinationEntrylng));
      PathState.realWorldCoordinates
          .add([destinationEntrylat, destinationEntrylng]);

      List<String> key = [PathState.sourceBid, PathState.destinationBid];
      setState(() {
        singleroute.putIfAbsent(buildingAllApi.outdoorID, () => Map());
        singleroute[buildingAllApi.outdoorID]!.putIfAbsent(0, () => Set());
        singleroute[buildingAllApi.outdoorID]![0]?.add(gmap.Polyline(
            polylineId: PolylineId("buildData.pathId"),
            points: coords,
            color: Colors.lightBlueAccent,
            width: 8,
            zIndex: 0));
        singleroute[buildingAllApi.outdoorID]![0]?.add(gmap.Polyline(
            polylineId: PolylineId(buildData.pathId),
            points: coords,
            color: Colors.blueAccent,
            width: 5,
            zIndex: 2));
      });
      // List<Cell> interBuildingPath = [];
      // for(LatLng c in coords){
      //   Map<String,double> local = CoordinateConverter.globalToLocal(c.latitude, c.longitude, SingletonFunctionController.building.patchData[buildingAllApi.outdoorID]!.patchData!.toJson());
      //   int node = (local["lng"]!.round()*SingletonFunctionController.building.floorDimenssion[buildingAllApi.outdoorID]![1]![0])+local["lat"]!.round() ;
      //   interBuildingPath.add(Cell(node, local["lat"]!.round().toInt(), local["lng"]!.round().toInt(), tools.eightcelltransition, c.latitude, c.longitude, buildingAllApi.outdoorID));
      // }
      // PathState.listofPaths.insert(1, interBuildingPath);
    }
  }

  List<int> beaconCord = [];
  double cordL = 0;
  double cordLt = 0;
  List<List<int>> getPoints = [];
  List<int> getnodes = [];

  List<LatLng> _polylineCoordinates = [];
  Marker? _movingMarker;
  Timer? _polytimer;
  int _currentIndex = 0;
  AnimationController? _animationController;
  AnimationController? _animationController1;
  Animation<double>? _polyanimation;
  late LatLng sourcePosition;
  late LatLng destinationPosition;
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  List<int> pathList = [];
  int currentFloor = 0;
  String currentBid = "";
  int currentCols = 0;
  Future<List<dynamic>> fetchroute(
      int sourceX, int sourceY, int destinationX, int destinationY, int floor,
      {String? Bid,
        int? nextFloor,
        String? liftName,
        bool renderSource = false,
        bool renderDestination = false}) async {
    print(
        "checks for campus $Bid ${SingletonFunctionController.building.floorDimenssion[Bid]}");
    print(
        "pathcchec fetchingroute between $sourceX, $sourceY   $destinationX, $destinationY  $Bid ");

    List<MapEntry<String, Map<int, List<int>>>> path = [];
    List<MapEntry<String, Map<int, List<List<double>>>>> renderPath = [];
    bool mastergraph = false;

    // try {
    Map<String, List<dynamic>> adjList = {};
    print("Bid $Bid");

    if (Building.GlobalAnnotation?.pathNetwork?.masterGraph != null) {
      PathModel model = Building.waypoint[Bid]!
          .firstWhere((element) => element.floor == element.floor);
      print("model.pathNetwork $Bid $model ${model.pathNetwork}");
      mastergraph = true;
      print("adjList ${Building.GlobalAnnotation!.pathNetwork!.masterGraph!}");
      var paths = await masterFindShortestPath(
          Building.GlobalAnnotation!,
          sourceX,
          sourceY,
          PathState.sourceLat,
          PathState.sourceLng,
          PathState.sourceBid,
          PathState.sourceFloor,
          destinationX,
          destinationY,
          PathState.destinationBid,
          PathState.destinationFloor,
          SingletonFunctionController.building.nonWalkable[Bid]?[floor],
          SingletonFunctionController.building.floorDimenssion,
          PathState.floorConnector,
          isoutdoorPath: Bid == buildingAllApi.outdoorID);
      path = paths.localPath;
      renderPath = paths.globalPath;
      print("path from mastergraph $path");
      print("path from mastergraph $renderPath");
    } else {
      PathModel model = Building.waypoint[Bid]!
          .firstWhere((element) => element.floor == floor);
      print("model.pathNetwork $Bid $model ${model.pathNetwork}");
      adjList = model.pathNetwork ?? {};
      mastergraph = false;
      path = await findShortestPath(
          adjList,
          sourceX,
          sourceY,
          destinationX,
          destinationY,
          SingletonFunctionController.building.nonWalkable[Bid]?[floor],
          SingletonFunctionController.building.floorDimenssion[Bid]![floor]![0],
          SingletonFunctionController.building.floorDimenssion[Bid]![floor]![1],
          Bid!,
          floor,
          isoutdoorPath: Bid == buildingAllApi.outdoorID);
    }
    // } catch (e) {
    //   // print("error in path finding $e");
    //   // if (Bid != buildingAllApi.outdoorID) {
    //   //   path = await findPath(
    //   //     numRows,
    //   //     numCols,
    //   //     SingletonFunctionController.building.nonWalkable[Bid]![floor]!,
    //   //     sourceIndex,
    //   //     destinationIndex,
    //   //   );
    //   //   path = getFinalOptimizedPath(
    //   //       path,
    //   //       SingletonFunctionController.building.nonWalkable[Bid]![floor]!,
    //   //       numCols,
    //   //       sourceX,
    //   //       sourceY,
    //   //       destinationX,
    //   //       destinationY);
    //   // }
    // }

    List<Map<String, dynamic>> result = [];
    for (var step in path) {
      String buildingID = step.key;
      print("buildingfloors ${step.value.keys}");
      for (var fl in step.value.keys) {
        int floor = fl;
        List<int>? pathPoints = step.value[floor];
        if (pathPoints == null) continue;
        final targetEntry = renderPath.firstWhere(
              (e) => e.key == buildingID && e.value[fl]!.length == pathPoints.length);
        List<List<double>>? render = targetEntry.value[fl];
        renderPath.remove(targetEntry);
        targetEntry.value.remove(fl);
        renderPath.add(targetEntry);
        PathState.numCols ??= {};
        PathState.numCols![buildingID] = PathState.numCols![buildingID] ?? {};
        PathState.numCols![buildingID]![floor] = SingletonFunctionController
            .building.floorDimenssion[buildingID]![floor]![0];
        print("buildingID path $buildingID $render");
        // print("Building.GlobalAnnotation!.liftNodes ${Building.GlobalAnnotation!.liftNodes}");
        var lift;
        if (Building.GlobalAnnotation?.liftNodes != null && (PathState.sourceFloor != PathState.destinationFloor || PathState.sourceBid != PathState.destinationBid)) {
          lift = getFirstMatchedLiftName(
              liftNodes: Building.GlobalAnnotation!.getNodesForOption(PathState.floorConnector),
              path: pathPoints,
              numCol: PathState.numCols![buildingID]![floor]!,
              buildingId: buildingID,
              floor: floor);
          if (lift != null) {
            PathState.connections.putIfAbsent(buildingID, () => {});
            PathState.connections[buildingID]!.putIfAbsent(
                floor,
                    () =>
                (lift.y! * PathState.numCols![buildingID]![floor]!) +
                    lift.x!);
            liftName = lift.name;
          }
          int currentFloorIndex =
          step.value.keys.toList().indexWhere((floor) => floor == fl);
          if (currentFloorIndex != step.value.keys.length - 1) {
            nextFloor = step.value.keys.toList()[currentFloorIndex + 1];
          }
          print("liftName $liftName $lift");
        }
        Map<String, dynamic> value = await processPathRendering(
            pathPoints,
            render,
            buildingID,
            floor,
            sourceX,
            sourceY,
            destinationX,
            destinationY,
            lift,
            nextFloor,
            (buildingID == path.first.key &&
                floor == PathState.sourceFloor &&
                renderSource),
            (buildingID == path.last.key &&
                floor == PathState.destinationFloor &&
                renderDestination),
            mastergraph);

        result.add(value);
      }
    }

    return result;
  }

  landmark.Lifts? getFirstMatchedLiftName({
    required List<dynamic> liftNodes,
    required List<int> path,
    required int numCol,
    required String buildingId,
    required int floor,
  }) {
    // Convert path into coordinate pairs
    final pathCoords =
    path.map((val) => [val % numCol, val ~/ numCol]).toList();

    print("pathCoords $liftNodes ${pathCoords.first} ${pathCoords.last}");

    for (final node in liftNodes) {
      final parts = node.split(',');
      if (parts.length != 7) continue;

      final nodeBuildingId = parts[0];
      final x = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      final lat = double.tryParse(parts[5]);
      final lng = double.tryParse(parts[4]);
      final nodeFloor = int.tryParse(parts[3]);
      final name = parts[6];

      if (nodeBuildingId != buildingId ||
          nodeFloor != floor ||
          x == null ||
          y == null) {
        continue;
      }

      for (final coord in pathCoords) {
        if (coord[0] == x && coord[1] == y) {
          print("name found $name");
          return landmark.Lifts()
            ..x = x
            ..y = y
            ..lat = lat
            ..lng = lng
            ..name = name;
        }
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> processPathRendering(
      List<int> path,
      List<List<double>>? render,
      String Bid,
      int floor,
      int sourceX,
      int sourceY,
      int destinationX,
      int destinationY,
      landmark.Lifts? lift,
      int? nextFloor,
      bool renderSource,
      bool renderDestination,
      bool masterGraph) async {
    print("polyline for $Bid $floor");
    direction? liftDirection;
    List<List<int>> getPoints = [];

    if (Bid == buildingAllApi.outdoorID || masterGraph) {
      for (var turn in path) {
        getPoints.add([
          turn % PathState.numCols![Bid]![floor]!,
          turn ~/ PathState.numCols![Bid]![floor]!
        ]);
      }
    } else {
      List<int> turns =
      tools.getTurnpoints(path, PathState.numCols![Bid]![floor]!);
      getPoints.add([
        sourceX % PathState.numCols![Bid]![floor]!,
        sourceY ~/ PathState.numCols![Bid]![floor]!
      ]);
      for (var turn in turns) {
        getPoints.add([
          turn % PathState.numCols![Bid]![floor]!,
          turn ~/ PathState.numCols![Bid]![floor]!
        ]);
      }
      getPoints.add([destinationX, destinationY]);
    }
    Set<Marker> innerMarker = {};
    PathState.path[floor] = path;
    List<Cell> Cellpath = findCorridorSegments(
        path,
        render,
        SingletonFunctionController.building.nonWalkable[Bid]![floor] ?? [],
        PathState.numCols![Bid]![floor]!,
        Bid,
        floor,
        SingletonFunctionController.building.patchData,
        masterGraph);
    PathState.Cellpath[floor] = Cellpath;
    List<double> svalue = [];
    List<double> dvalue = [];

    if (path.isNotEmpty) {
      if (SingletonFunctionController.building.floor[Bid] != floor) {
        setState(() {
          SingletonFunctionController.building.floor[Bid] = floor;
        });
      }

      if (floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
          tools.numericalToAlphabetical(0),
          SingletonFunctionController
              .building.polylinedatamap[Bid]!.polyline!.floors!,
        );
        List<PolyArray> currFloorLifts = findLift(
          tools.numericalToAlphabetical(floor),
          SingletonFunctionController
              .building.polylinedatamap[Bid]!.polyline!.floors!,
        );
        List<int> diff = findCommonLift(prevFloorLifts, currFloorLifts);
        UserState.xdiff = diff[0];
        UserState.ydiff = diff[1];
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
      }

      svalue = tools.localtoglobal(sourceX, sourceY,
          SingletonFunctionController.building.patchData[Bid]);
      dvalue = tools.localtoglobal(destinationX, destinationY,
          SingletonFunctionController.building.patchData[Bid]);

      List<LatLng> coordinates = [];
      if (render != null) {
        for (var node in render) {
          print("lat ${node[0]} lng ${node[1]}");
          coordinates.add(LatLng(node[0], node[1]));
          await Future.delayed(Duration(microseconds: 0));
        }
      } else {
        for (var node in path) {
          int row = (node %
              PathState.numCols![Bid]![floor]!); //divide by floor length
          int col = (node ~/
              PathState.numCols![Bid]![floor]!); //divide by floor length
          print("row $row col $col");
          List<double> value = tools.localtoglobal(
              row, col, SingletonFunctionController.building.patchData[Bid]);
          coordinates.add(LatLng(value[0], value[1]));
          await Future.delayed(Duration(microseconds: 0));
        }
      }

      singleroute.putIfAbsent(Bid, () => Map());
      singleroute[Bid]!.putIfAbsent(floor, () => Set());
      gmap.Polyline updatedPolyline = gmap.Polyline(
        polylineId: PolylineId("$Bid $floor ${DateTime.now().toString()}"),
        points: coordinates,
        color: Colors.blueAccent,
        width: 8,
      );
      setState(() {
        singleroute[Bid]![floor]!.add(updatedPolyline);
      });

      print("singleroute ${singleroute}");

      // final highlighter = TurnHighlighter(
      //   path: coordinates,
      //   highlightRadiusMeters: Bid == buildingAllApi.outdoorID ? 5 : (5 * 0.342),
      // );
      // final whitePolylines = highlighter.getTurnPolylines();
      //
      // setState(() {
      //   singleroute[Bid]![floor]?.addAll(whitePolylines);
      // });

      final Uint8List tealtorch =
      await getImagesFromMarker('assets/tealtorch.png', 15);
      print("liftfound ${lift?.toJson()}");
      if (lift?.name != null) {
        liftDirection = direction(
          -1,
          "Take ${lift?.name} and Go to ${tools.numericalToAlphabetical(nextFloor??0)} Floor",
          null,
          null,
          Cellpath.first.floor.toDouble(),
          null,
          null,
          Cellpath.first.floor,
          Cellpath.first.bid ?? "",
          liftDestinationFloor: nextFloor,
        );
        if(lift?.lat != null && lift?.lng != null){
          final Uint8List greyDot = await getImagesFromMarker('assets/button.png', 12);
          innerMarker.add(
            Marker(
                markerId: MarkerId('lift${lift!.lat}'),
                position: LatLng(lift!.lat!, lift!.lng!),
                icon: BitmapDescriptor.fromBytes(greyDot),
                anchor: Offset(0.5, 0.5)
            ),
          );
        }
      }

      BitmapDescriptor textMarker = await bitmapDescriptorFromTextAndImage(
        PathState.destinationName,
        'assets/pyramids.png',
        imageSize: const Size(95, 95),
        color: Colors.black,
      );
      land? landmarks = await SingletonFunctionController.building.landmarkdata;
      setState(() {
        if (renderDestination) {
          if(landmarks != null && landmarks.landmarksMap != null && landmarks.landmarksMap![PathState.destinationPolyID] != null){
            LatLng landmarkCenter = LatLng(double.parse(landmarks.landmarksMap![PathState.destinationPolyID]!.properties!.latitude!), double.parse(landmarks.landmarksMap![PathState.destinationPolyID]!.properties!.longitude!));
            innerMarker.add(
              Marker(
                markerId: MarkerId('destination$Bid'),
                position: landmarkCenter,
                icon: textMarker,
              ),
            );
            print("PathState.destinationLat ${PathState.destinationLat}, ${PathState.destinationLng}");
            double offSet = tools.calculateAerialDist(landmarkCenter.latitude, landmarkCenter.longitude,render!.last[0], render.last[1]);
            print("offset $offSet");
            if(offSet >= 5 || true){
              _createCurvedPolyline(Bid, floor, landmarkCenter, LatLng(render.last[0], render.last[1]));
            }
          }else if(render != null){
            innerMarker.add(
              Marker(
                markerId: MarkerId('destination$Bid'),
                position: LatLng(render.last[0], render.last[1]),
                icon: textMarker,
              ),
            );

            if(PathState.destinationLat != 0.0 && PathState.destinationLng != 0.0){
              double offSet = tools.calculateAerialDist(render.last[0], render.last[1], PathState.destinationLat, PathState.destinationLng);
              if(offSet >= 9 || true){
                _createCurvedPolyline(Bid, floor, LatLng(render.last[0], render.last[1]), LatLng(PathState.destinationLat, PathState.destinationLng));
              }
            }
          }else{
            innerMarker.add(
              Marker(
                markerId: MarkerId('destination$Bid'),
                position: LatLng(dvalue[0], dvalue[1]),
                icon: textMarker,
              ),
            );

            if(PathState.destinationLat != 0.0 && PathState.destinationLng != 0.0){
              double offSet = tools.calculateAerialDist(dvalue[0], dvalue[1], PathState.destinationLat, PathState.destinationLng);
              if(offSet >= 9 || true){
                _createCurvedPolyline(Bid, floor, LatLng(dvalue[0], dvalue[1]), LatLng(PathState.destinationLat, PathState.destinationLng));
              }
            }
          }
        }

        if (!kIsWeb && renderSource) {
          if(render != null){
            innerMarker.add(
              Marker(
                markerId: MarkerId('source$Bid'),
                position: LatLng(render.first[0], render.first[1]),
                icon: BitmapDescriptor.fromBytes(tealtorch),
                anchor: Offset(0.5, 0.5),
              ),
            );
          }else{
            innerMarker.add(
              Marker(
                markerId: MarkerId('source$Bid'),
                position: LatLng(svalue[0], svalue[1]),
                icon: BitmapDescriptor.fromBytes(tealtorch),
                anchor: Offset(0.5, 0.5),
              ),
            );
          }
        }
        PathState.innerMarker[floor] = innerMarker;
        pathMarkers.putIfAbsent(Bid, () => {});
        pathMarkers[Bid]![floor] = innerMarker;
      });
    }

    print("returning dvalue for $Bid $svalue and $dvalue");
    return {
      "path": path,
      "CellPath": Cellpath,
      "liftName": lift?.name,
      "svalue": svalue,
      "dvalue": dvalue,
      "lift": liftDirection
    };
  }

  void showRouteSelector(BuildContext context, String acc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: RouteSelector(
            onRouteSelected: (String selectedRoute) {
              // Print the selected route ID
            },
            acc: acc,
          ),
        );
      },
    ).then((result) {
      if (result != null) {
        reroute(acc: result); // Handle the result after the dialog is closed
      }
    });
  }

  void modifyPathCovered(String bid, int floor, LatLng point) {
    pathCovered.putIfAbsent(bid, () => {floor: Set()});
    pathCovered[bid]!.putIfAbsent(floor, () => Set());
    List<LatLng> coordinates = [];
    if (pathCovered[bid]![floor] != null &&
        pathCovered[bid]![floor]!.isNotEmpty) {
      coordinates.addAll(pathCovered[bid]![floor]!.first.points);
    }
    coordinates.add(point);
    setState(() {
      if (pathCovered[bid]![floor] == null ||
          pathCovered[bid]![floor]!.isEmpty) {
        pathCovered[bid]![floor]!.add(gmap.Polyline(
          polylineId: const PolylineId("path covered"),
          points: coordinates,
          color: const Color(0xffb5b5c9),
          width: 10,
        ));
      } else {
        gmap.Polyline polyline = customMarker.extendPolyline(
            pathCovered[bid]![floor]!.first, coordinates);
        pathCovered[bid]![floor]!.clear();
        pathCovered[bid]![floor]!.add(polyline);
      }
    });
    print("pathCovered $pathCovered");
  }

  Future<List<direction>> createMarkersAndDirections(
      List<Cell> path,
      List<direction?> lifts, {
        String? liftName,
      }) async {
    final value = await SingletonFunctionController.building.landmarkdata!;
    List<Landmarks> nearbyLandmarks =
    tools.findNearbyLandmark(path, value.landmarksMap!, 16);
    pathState.nearbyLandmarks = nearbyLandmarks;
    print("pathState.nearbyLandmarks:${nearbyLandmarks}");
    final associatedTurns =
    await tools.associateTurnWithLandmark(path, nearbyLandmarks);
    associatedTurns.forEach((turn, landmark){
      print("associateTurnWithLandmark ${landmark.name}");
    });
    PathState.associateTurnWithLandmark = associatedTurns;
    PathState.associateTurnWithLandmark.removeWhere((key, value) =>
    value.properties!.polyId == PathState.destinationPolyID);
    try {
      for (var landmark in associatedTurns.values) {
        // Do something with each landmark
        print(landmark.name); // assuming Landmarks has a 'name' property
      }
    } catch (e) {}
    destiPoly = PathState.destinationPolyID;

    List<direction> directions = [];

    // if (liftName != null) {
    //   directions.add(
    //     direction(
    //       -1,
    //       "Take $liftName and Go to ${PathState.destinationFloor} Floor",
    //       null,
    //       null,
    //       path.first.floor.toDouble(),
    //       null,
    //       null,
    //       path.first.floor,
    //       path.first.bid ?? "",
    //       liftDestinationFloor: PathState.destinationFloor,
    //     ),
    //   );
    // }

    directions.addAll(
      tools.getDirections(path, associatedTurns, PathState, lifts, context),
    );

    print("directionsonpath:    ${PathState.directions}");

    directions.addAll(PathState.directions);
    directions.forEach((action) {
      print("directionsonpath:${action.turnDirection}");
    });

    return directions;
  }

  void _initializePolylineAndMarker() {
    setState(() {
      _movingMarker = Marker(
        markerId: MarkerId('moving_marker'),
        position: _polylineCoordinates[0],
      );
    });
  }

  List<LatLng> _visibleWhitePolyline = [];

  void _startAnimation() {
    int currentIndex = 0;
    _polytimer = Timer.periodic(Duration(milliseconds: 50), (Timer timer) {
      setState(() {
        currentIndex++;
        if (currentIndex >= _polylineCoordinates.length) {
          currentIndex = 0;
          _visibleWhitePolyline.clear();
        } else {
          _visibleWhitePolyline.add(_polylineCoordinates[currentIndex]);
        }
      });
    });
  }

  LatLng _getLatLngAlongPath(double fraction) {
    int startIndex = (_polylineCoordinates.length - 1) * fraction ~/ 1;
    int endIndex = startIndex + 1;

    if (endIndex >= _polylineCoordinates.length) {
      endIndex = _polylineCoordinates.length - 1;
    }

    final startPoint = _polylineCoordinates[startIndex];
    final endPoint = _polylineCoordinates[endIndex];

    final lat = _lerp(startPoint.latitude, endPoint.latitude, fraction);
    final lng = _lerp(startPoint.longitude, endPoint.longitude, fraction);

    return LatLng(lat, lng);
  }

  void closeRoutePannel() {
    _routeDetailPannelController.close();
  }

  void openRoutePannel() {
    _routeDetailPannelController.open();
  }

  void clearPathVariables() {
    getPoints.clear();
  }

  int floors = 0;
  Widget nofloorColumn() {
    return Container();
  }

  Widget floorColumn() {
    List<int> floorNumbers = List.generate(
        SingletonFunctionController
            .building.numberOfFloors[buildingAllApi.getStoredString()]!,
            (index) => index);

    return Semantics(
      excludeSemantics: excludeFloorSemanticWork,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 300, // Set the maximum height
        ),
        child: Container(
          width: 100, // Allow the container to take full width
          child: ListView.builder(
            shrinkWrap:
            true, // Ensures the ListView takes the height of its children
            itemCount: SingletonFunctionController
                .building.numberOfFloors[buildingAllApi.getStoredString()]!,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(top: 10),
                child: Material(
                  elevation: 4.0, // Add elevation for shadow effect
                  shape: CircleBorder(), // Circular shape
                  child: Semantics(
                    label: "Floor ${index}",
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(50), // Circular tap effect
                      onTap: () {
                        SingletonFunctionController.building
                            .floor[buildingAllApi.getStoredString()] = index;
                        createRooms(
                          SingletonFunctionController.building.polylinedatamap[
                          buildingAllApi.getStoredString()]!,
                          SingletonFunctionController.building
                              .floor[buildingAllApi.getStoredString()]!,
                        );
                        if (pathMarkers[index] != null) {
                          //setCameraPosition(pathMarkers[i]!);
                        }
                        SingletonFunctionController.building.landmarkdata!
                            .then((value) {
                          createMarkers(
                              value,
                              SingletonFunctionController.building
                                  .floor[buildingAllApi.getStoredString()]!,
                              buildingAllApi.getStoredString());
                        });
                      },
                      child: CircleAvatar(
                        // Circular Avatar for the button
                        backgroundColor: Colors.white, // Background color
                        radius: 30.0, // Adjust size as needed
                        child: Center(
                          child: Semantics(
                            excludeSemantics: true,
                            child: Text(
                              floorNumbers[index]
                                  .toString(), // Text to be displayed
                              style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void addDirectionsWidget() {}
  bool _isPlaying = false;
  Future<void> callPreviewAnimation() async {
    print("singleRoute ${singleroute}");
    List<LatLng> currentCoordinates = [];
    Set<Marker> innerMarker = Set();
    await SingletonFunctionController.building.landmarkdata!
        .then((value) async {
      List<Landmarks> nearbyLandmarks =
      tools.findNearbyLandmark(user.cellPath, value.landmarksMap!, 5);
      List<int> turnPoints = tools.getTurnpoints(pathList, currentCols);
      for (int i = 0; i < pathList.length - 2; i++) {
        int node = pathList[i];
        int node1 = pathList[i + 2];
        int row1 = (node1 % currentCols); //divide by floor length
        int col1 = (node1 ~/ currentCols);
        int row = (node % currentCols); //divide by floor length
        int col = (node ~/ currentCols); //divide by floor length
        List<double> value = tools.localtoglobal(row, col,
            SingletonFunctionController.building.patchData[currentBid]);
        List<double> value1 = tools.localtoglobal(row1, col1,
            SingletonFunctionController.building.patchData[currentBid]);
        currentCoordinates.add(LatLng(value[0], value[1]));
        if (singleroute[currentBid] == null) {
          singleroute.putIfAbsent(currentBid, () => Map());
        }
        if (singleroute[currentBid]![currentFloor] != null) {
          gmap.Polyline oldPolyline =
          singleroute[currentBid]![currentFloor]!.firstWhere(
                (polyline) => polyline.polylineId.value == currentBid,
          );
          gmap.Polyline updatedPolyline = gmap.Polyline(
            polylineId: oldPolyline.polylineId,
            points: currentCoordinates,
            color: oldPolyline.color,
            width: oldPolyline.width,
          );
          setState(() {
            if (i < nearbyLandmarks.length - 1) {
              try {
                List<double> value1 = tools.localtoglobal(
                    nearbyLandmarks[i].coordinateX!,
                    nearbyLandmarks[i].coordinateY!,
                    SingletonFunctionController.building.patchData[currentBid]);
                innerMarker.add(
                  Marker(
                    markerId:
                    MarkerId('previewMarker${nearbyLandmarks[i].sId}'),
                    position: LatLng(value1[0], value[1]),
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                );
              } catch (e) {
                print("error in preview markers ${e}");
              }
            }
            // Remove the old polyline and add the updated polyline
            singleroute[currentBid]![currentFloor]!.remove(oldPolyline);
            singleroute[currentBid]![currentFloor]!.add(updatedPolyline);
          });
        } else {
          setState(() {
            singleroute[currentBid]!.putIfAbsent(currentFloor, () => Set());
            singleroute[currentBid]![currentFloor]?.add(gmap.Polyline(
              polylineId: PolylineId("$currentBid"),
              points: currentCoordinates,
              color: Colors.blueAccent,
              width: 8,
            ));
          });
        }
        if (turnPoints.contains(node)) {
          print("rendering path");
          await alignMapToPath([value[0], value[1]], [value1[0], value1[1]],
              isTurn: true);
        } else {
          await alignMapToPath([value[0], value[1]], [value1[0], value1[1]]);
        }
        await Future.delayed(Duration(microseconds: 2500));
        currentCoordinates.add(LatLng(value[0], value[1]));
      }
    });
    PathState.innerMarker[currentFloor] = innerMarker;
    pathMarkers.putIfAbsent(currentBid, () => Map());
    pathMarkers[currentBid]![currentFloor] = innerMarker;
  }

  final FocusNode _directionFocus = FocusNode();
  final FocusNode _startbuttonFocus = FocusNode();

  PanelController _routeDetailPannelController = new PanelController();
  bool startingNavigation = false;
  List<Widget> directionWidgets = [];
  Widget routeDeatilPannel() {
    setState(() {
      semanticShouldBeExcluded = true;
    });
    double? angle;
    try {
      if (PathState.singleCellListPath.isNotEmpty) {
        int l = PathState.singleCellListPath.length;
        angle = tools.calculateAngle([
          PathState.singleCellListPath[l - 2].x,
          PathState.singleCellListPath[l - 2].y
        ], [
          PathState.singleCellListPath[l - 1].x,
          PathState.singleCellListPath[l - 1].y
        ], [
          PathState.destinationX,
          PathState.destinationY
        ]);
      }
    } catch (e) {}

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    directionWidgets.clear();

    // for (int i = 0; i < PathState.directions.length; i++) {
    //   if (PathState.directions[i].keys.first == "Straight") {
    //     directionWidgets.add(directionInstruction(
    //         direction: "Go " + PathState.directions[i].keys.first,
    //         distance: tools
    //             .roundToNextInt(PathState.directions[i].values.first * 0.3048)
    //             .toString()));
    //   } else if (PathState.directions[i].keys.first.substring(0, 4) == "Take") {
    //     directionWidgets.add(directionInstruction(
    //         direction: PathState.directions[i].keys.first,
    //         distance: "Floor $sourceVal -> Floor $destinationVal"));
    //   } else {
    //     directionWidgets.add(directionInstruction(
    //         direction: "Turn " +
    //             PathState.directions[i].keys.first +
    //             ", and Go Straight",
    //         distance: tools
    //             .roundToNextInt(PathState.directions[++i].values.first * 0.3048)
    //             .toString()));
    //   }
    // }
    double time = 0;
    int? distance = 0;
    DateTime currentTime = DateTime.now();
    if (PathState.singleCellListPath.isNotEmpty) {
      final distances = {
        PathState.directionInstructionViewModel?.totalSourceDistance,
        PathState.directionInstructionViewModel?.totalOutdoorDistance,
        PathState.directionInstructionViewModel?.totalDestinationDistance,
      };
      distance = distances.reduce((a, b) => a! + b!);
      time = (distance! * 3.28084) / 120;
      time = time.ceil().toDouble();
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));
    return Visibility(
      visible: _isRoutePanelOpen,
      child: Stack(
        children: [
          ExcludeSemantics(
            child: Container(
              height:
              PathState.sourceFloor != PathState.destinationFloor ? 170 : 130,
              width: screenWidth,
              margin: EdgeInsets.only(left: 8, right: 8),
              padding: EdgeInsets.only(top: 15, right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
                color: Colors.white,
              ),
              child: Semantics(
                child: Column(
                  children: [
                    SizedBox(
                      height: 7,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: IconButton(
                              onPressed: () {
                                SingletonFunctionController.building.landmarkdata!.then((value) async {
                                  print("SingletonFunctionController landmarks ${value.landmarks!.length}");
                                  List<Landmarks> createLandmarks = [];
                                  value.landmarks!.forEach((value){
                                    if(value.floor == SingletonFunctionController.building.floor[value.buildingID]){
                                      createLandmarks.add(value);
                                    }
                                  });
                                  land current = land();
                                  landmarkMarkers.clear();
                                  current.landmarks = createLandmarks;
                                  createMarkers(current, 0, buildingAllApi.selectedBuildingID,forced: true);
                                });
                                playPreviewManager?.clearPreview();
                                showMarkers();
                                List<double> mvalues = tools.localtoglobal(
                                    PathState.destinationX,
                                    PathState.destinationY,
                                    SingletonFunctionController.building
                                        .patchData[PathState.destinationBid]);
                                _googleMapController.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(mvalues[0], mvalues[1]),
                                    20, // Specify your custom zoom level here
                                  ),
                                );
                                _isRoutePanelOpen = false;
                                _isLandmarkPanelOpen = true;
                                PathState = pathState.withValues(
                                    -1, -1, -1, -1, -1, -1, null, 0);
                                PathState.path.clear();
                                PathState.sourcePolyID = "";
                                PathState.destinationPolyID = "";
                                singleroute.clear();
                                pathCovered.clear();
                                //realWorldPath.clear();
                                _isBuildingPannelOpen = true;
                                if (user.isnavigating == false) {
                                  clearPathVariables();
                                }
                                setState(() {
                                  Marker? temp = selectedroomMarker[
                                  buildingAllApi.getStoredString()]
                                      ?.first;
                                  selectedroomMarker.clear();
                                  selectedroomMarker[
                                  buildingAllApi.getStoredString()]
                                      ?.add(temp!);
                                  pathMarkers.clear();
                                });
                              },
                              icon: Semantics(
                                label: "Back",
                                onDidGainAccessibilityFocus: closeRoutePannel,
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 24,
                                ),
                              )),
                        ),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 12, right: 5),
                                  width: 15.0,
                                  height: 15.0,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 12, right: 5),
                                  width: 5.0,
                                  height: 5.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 28, right: 5),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.red,
                                  size: 22,
                                ))
                          ],
                        ),
                        Expanded(
                          child: Semantics(
                            excludeSemantics: true,
                            child: Column(
                              children: [
                                Semantics(
                                  label: 'Source Name',
                                  header: true,
                                  child: InkWell(
                                    child: Container(
                                      height: 40,
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        border:
                                        Border.all(color: Color(0xffE2E2E2)),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: 8, top: 7, bottom: 8),
                                      child: Text(
                                        PathState.sourceName,
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff24b9b0),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        startingNavigation = false;
                                      });
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GlobalSearchPage(
                                                    hintText: 'Source location',
                                                    voiceInputEnabled: false,
                                                    user: user,
                                                  ))).then((value) async {
                                        // onLandmarkVenueClicked(value,DirectlyStartNavigation: true);
                                        onSourceVenueClicked(value);
                                      });
                                    },
                                  ),
                                ),
                                Semantics(
                                  label: "destination name",
                                  header: true,
                                  child: InkWell(
                                    child: Container(
                                      height: 40,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        border:
                                        Border.all(color: Color(0xffE2E2E2)),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: 8, top: 7, bottom: 8),
                                      child: Semantics(
                                        onDidGainAccessibilityFocus:
                                        closeRoutePannel,
                                        child: Text(
                                          PathState.destinationName,
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff282828),
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        startingNavigation = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GlobalSearchPage(
                                                    hintText:
                                                    'Destination location',
                                                    voiceInputEnabled: false,
                                                    user: user,
                                                  ))).then((value) {
                                        _isBuildingPannelOpen = false;
                                        onDestinationVenueClicked(value);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  playPreviewManager?.clearPreview();
                                  PathState.swap();
                                  PathState.path.clear();
                                  pathMarkers.clear();
                                  PathState.directions.clear();
                                  if (user.isnavigating == false) {
                                    clearPathVariables();
                                  }
                                  SingletonFunctionController
                                      .building.landmarkdata!
                                      .then((value) {
                                    calculateroute(value.landmarksMap!);
                                  });
                                });
                              },
                              icon: Semantics(
                                label: "Swap location",
                                child: Icon(
                                  Icons.swap_vert_circle_outlined,
                                  size: 24,
                                ),
                              )),
                        ),
                      ],
                    ),
                    (PathState.sourceFloor != PathState.destinationFloor &&
                        PathState.filteredOptions != null)
                        ? Semantics(
                      excludeSemantics: true,
                      child: Container(
                        margin: EdgeInsets.only(top: 0, left: 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                            PathState.filteredOptions!.map((option) {
                              return AccessiblePathButton(
                                label: option["label"],
                                icon: option["icon"],
                                accessibleBy: option["accessibleBy"],
                                floorConnector: option["floorConnector"],
                                PathState: PathState,
                                calculateroute: calculateroute,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
          Focus(
            focusNode: _directionFocus,
            child: Semantics(
              child: Visibility(
                visible: PathState.sourceX != 0,
                child: SafeArea(
                  child: SlidingUpPanel(
                      controller: _routeDetailPannelController,
                      borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20.0,
                          color: Colors.grey,
                        ),
                      ],
                      minHeight: 140,
                      maxHeight: screenHeight,
                      panel: PathState.noPathFound
                          ? Container(
                        margin: EdgeInsets.only(top: 36),
                        child: Semantics(
                          label: "Can't find a way there",
                          excludeSemantics: true,
                          child: Column(
                            children: [
                              Image.asset("assets/error.png"),
                              Text(
                                "Can't find a way there",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff3f3f46),
                                  height: 40 / 14,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      )
                          : Semantics(
                        label: distance>=1000?"Walk For ${time.toInt()} min about (${(distance/1000).toStringAsFixed(1)} KM),":"Walk For ${time.toInt()} min about (${distance} m),",
                        header: true,
                        sortKey: const OrdinalSortKey(0),
                        child: Focus(
                          autofocus: true,
                          onFocusChange: (hasFocus) {
                            if (!hasFocus) {
                              print("printhasFocus");
                              _startbuttonFocus.requestFocus();
                            } else {
                              print("printhasFocus");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(16.0)),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 4,
                                  margin: EdgeInsets.only(top: 6, bottom: 6),
                                  decoration: BoxDecoration(
                                    color: Color(0xff79747e),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                Container(
                                  margin:
                                  EdgeInsets.only(left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ExcludeSemantics(
                                            child: Text(
                                              'Walk',
                                              style: TextStyle(
                                                color: const Color(0xFF171717),
                                                fontSize: 18,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: _routeDetailPannelController
                                                .isAttached
                                                ? _routeDetailPannelController
                                                .isPanelClosed
                                                ? closeRoutePreview()
                                                : closeRoutePreviewPannel()
                                                : closeRoutePreview(),
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        child: Semantics(
                                          excludeSemantics: true,
                                          child: Text(
                                            distance>=1000?"${time.toInt()} min (${(distance/1000).toStringAsFixed(1)} KM)":"${time.toInt()} min (${distance} m)",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff615e5e),
                                              height: 26 / 20,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PathState.sourceFloor !=
                                    PathState.destinationFloor
                                    ? ExcludeSemantics(
                                  child: Container(
                                    child: Row(children: [
                                      Container(
                                          margin:
                                          EdgeInsets.only(left: 20),
                                          child: SvgPicture.asset(
                                              'assets/routeDetailPannel_manIcon.svg')),
                                      Container(
                                          margin:
                                          EdgeInsets.only(left: 5),
                                          child: Text(
                                            "F${PathState.sourceFloor}",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w500,
                                              color: Color(0xff333333),
                                              height: 9 / 12,
                                            ),
                                          )),
                                      Container(
                                          margin:
                                          EdgeInsets.only(left: 3),
                                          child: Icon(Icons
                                              .keyboard_arrow_right_outlined)),
                                      Container(
                                          margin:
                                          EdgeInsets.only(left: 5),
                                          child: SvgPicture.asset(
                                            'assets/routeDetailPannel_LisftIcon.svg',
                                            color: Colors.black,
                                          )),
                                      Container(
                                          margin:
                                          EdgeInsets.only(left: 3),
                                          child: Icon(Icons
                                              .keyboard_arrow_right_outlined)),
                                      Container(
                                          margin:
                                          EdgeInsets.only(right: 3),
                                          child: SvgPicture.asset(
                                              'assets/routeDetailPannel_manIcon.svg')),
                                      Container(
                                          margin:
                                          EdgeInsets.only(right: 3),
                                          child: Text(
                                            "F${PathState.destinationFloor}",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w500,
                                              color: Color(0xff333333),
                                              height: 9 / 12,
                                            ),
                                          )),
                                    ]),
                                  ),
                                )
                                    : Container(),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 12, top: 8, right: 12),
                                  child: Row(
                                    children: [
                                      canNavigate()
                                          ? startNavigationButton()
                                          : playPreviewButton(),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      stepsPreviewButton(),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Divider(
                                  color: Color(0xffEBEBEB),
                                ),
                                PathState.directionInstructionViewModel !=
                                    null
                                    ? Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Semantics(
                                            header: true,
                                            label:
                                            'Direction Instructions',
                                            child: DirectionInstruction(
                                              viewModel: PathState
                                                  .directionInstructionViewModel!,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget openInAppButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.phone_android_sharp, color: Colors.white),
      label: Text('Open In App', style: TextStyle(color: Colors.white)),
      onPressed: () async {
        // HelperClass.openMobileApp();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget playPreviewButton() {

    return Semantics(
      label: "Play Preview",
      hint: "Button. Double tap to activate",
      sortKey: const OrdinalSortKey(1),
      child: Focus(
        focusNode: _startbuttonFocus,
        child: Semantics(
          excludeSemantics: true,
          child: ElevatedButton.icon(
            icon: Icon(Icons.double_arrow_rounded, color: Colors.blue),
            label: Text('Preview', style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              InteractionManager().logInteraction("Play Preview");
              if (playPreviewManager?.isPlaying == false) {

                List<String> intermediatesBids = tools.findIntermediateBuildings(PathState.singleCellListPath);
                setBuildingFloors(intermediatesBids, floor: PathState.sourceFloor);
                fitPathPoints(floor: PathState.sourceFloor, bid: PathState.sourceBid);

                playPreviewManager?.clearPreview();
                PlayPreviewManager.alignMapToPath = alignMapToPath;
                PlayPreviewManager.findLift = findLift;
                PlayPreviewManager.findCommonLift = findCommonLift;
                PlayPreviewManager.createRooms =
                    (int floor, String bid) {
                  print("got called");
                  List<String> intermediatesBids = tools.findIntermediateBuildings(PathState.singleCellListPath);
                  setBuildingFloors([...intermediatesBids, bid], floor: floor);
                  fitPathPoints(floor: floor, bid: bid);
                };
                playPreviewManager?.playPreviewAnimation(
                    pathList: PathState.singleCellListPath).then((value){
                  List<String> intermediatesBids = tools.findIntermediateBuildings(PathState.singleCellListPath);
                  setBuildingFloors(intermediatesBids, floor: PathState.sourceFloor);
                  fitPathPoints(floor: PathState.sourceFloor);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.blue),
              padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void fitPathPoints({int? floor, String? bid}) {
    floor ??= SingletonFunctionController
        .building.floor[bid??buildingAllApi.getStoredString()];
    List<Cell> renderedPath = [];
    if(bid != null){
      renderedPath = PathState.singleCellListPath.where((cell) => cell.floor == floor && cell.bid == bid).toList();
    }
    if(renderedPath.isEmpty){
      renderedPath = PathState.singleCellListPath.where((cell) => cell.floor == floor).toList();
    }
    if (renderedPath.length >=2) {
      List<LatLng> points = [LatLng(renderedPath.first.lat, renderedPath.first.lng), LatLng(renderedPath.last.lat, renderedPath.last.lng)];
      fitTwoPoints(points);
    }
  }

  Widget closeRoutePreviewPannel() {
    return IconButton(
      onPressed: () {
        _routeDetailPannelController.close();
      },
      padding: EdgeInsets.zero, // No padding
      icon: Icon(
        Icons.expand_circle_down,
        size: 22, // Smaller visual size
        color: Colors.black,
      ),
    );
  }

  Widget closeRoutePreview() {
    return GestureDetector(
      onTap: () {
        playPreviewManager?.clearPreview();

        SingletonFunctionController.building.landmarkdata!.then((value) async {
          print("SingletonFunctionController landmarks ${value.landmarks!.length}");
          List<Landmarks> createLandmarks = [];
          value.landmarks!.forEach((value){
            if(value.floor == SingletonFunctionController.building.floor[value.buildingID]){
              createLandmarks.add(value);
            }
          });
          land current = land();
          landmarkMarkers.clear();
          current.landmarks = createLandmarks;
          createMarkers(current, 0, buildingAllApi.selectedBuildingID,forced: true);
        });

        showMarkers();
        setState(() {
          _isBuildingPannelOpen = true;
          _isRoutePanelOpen = false;
        });
        widget.directLandID = "";
        selectedroomMarker.clear();
        pathMarkers.clear();
        SingletonFunctionController.building.selectedLandmarkID = null;
        PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
        PathState.path.clear();
        PathState.sourcePolyID = "";
        PathState.destinationPolyID = "";
        PathState.sourceBid = "";
        PathState.destinationBid = "";
        singleroute.clear();
        PathState.directions = [];
        interBuildingPath.clear();
        fitPolygonInScreen(patch.first);
        exitNavigation();
        setState(() {
          playPreviewManager?.clear();
          onStart = false;
          startingNavigation = false;
        });
        // continuousGPSLocalisation();
      },
      child: Semantics(
        label: "Close route preview",
        child: Icon(
          Icons.close,
          size: 22, // Smaller visual size
          color: Colors.black,
        ),
      ),
    );
  }

  Widget startNavigationButton() {

    return Semantics(
      label: "Start Navigation",
      hint: "Button. Double tap to activate",
      sortKey: const OrdinalSortKey(1),
      child: Focus(
        focusNode: _startbuttonFocus,
        child: Semantics(
          excludeSemantics: true,
          child: ElevatedButton.icon(
            icon: Icon(Icons.navigation, color: Colors.white),
            label: Text('Start', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              InteractionManager().logInteraction("Start Navigation");
              print("landmarkMarkers.clear() ${landmarkMarkers.length} ${_landmarks.length}");


              landmarkMarkers.forEach((value){
                print("value ${value.markerId.value}");
                if(!value.markerId.value.toLowerCase().contains("main entry")){
                  value.visible = false;
                }
              });

              // landmarkMarkers.clear();
              // _landmarks.clear();
              clustringOFF = true;
              startNavigation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget stepsPreviewButton() {
    return Semantics(
      label: _routeDetailPannelController.isAttached
          ? _routeDetailPannelController.isPanelClosed
          ? "Steps Preview"
          : "Close Steps preview"
          : "Steps Preview",
      hint: "Button. Double tap to activate",
      child: Focus(
        child: Semantics(
          excludeSemantics: true,
          child: ElevatedButton.icon(
            icon: Icon(
              _routeDetailPannelController.isAttached
                  ? _routeDetailPannelController.isPanelClosed
                  ? Icons.short_text_outlined
                  : Icons.map_sharp
                  : Icons.short_text_outlined,
              color: Colors.blue,
            ),
            label: Text(
              _routeDetailPannelController.isAttached
                  ? _routeDetailPannelController.isPanelClosed
                  ? "${LocaleData.steps.getString(context)}"
                  : "${LocaleData.maps.getString(context)}"
                  : "${LocaleData.steps.getString(context)}",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            onPressed: () {
              if (_routeDetailPannelController.isPanelOpen) {
                _routeDetailPannelController.close();
              } else {
                _routeDetailPannelController.open();
                // _directionFocus.requestFocus();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.blue),
              padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool canNavigate() {
    if (kIsWeb) {
      return false;
    }
    if (PathState.sourceX == user.coordX && PathState.sourceY == user.coordY) {
      return true;
    } else {
      return false;
    }
  }

  // void pathPreview(){
  //   if (currentNavigationLog != null) {
  //
  //   }
  // }

  Future<void> startNavigation() async {
    if (startingNavigation) {
      if (currentNavigationLog == null) {
        startNavigationLog(UserCredentials().getUserId(),
            PathState.sourcePolyID, PathState.destinationPolyID);
      }
      clearMarkers();
      tools.setBuildingAngle(SingletonFunctionController
          .building.patchData[PathState.sourceBid]!.patchData!.buildingAngle!);
      if (PathState.sourceBid == PathState.destinationBid && PathState.sourceFloor == PathState.destinationFloor && tools.calculateDistance([PathState.sourceX, PathState.sourceY], [PathState.destinationX, PathState.destinationY]) < 15) {
        //HelperClass.showToast("Source and Destination can not be same");
        setState(() {
          _isRoutePanelOpen = false;
        });
        closeNavigation(force: true);
        return;
      }
      setState(() {
        circles.clear();
        _markers.clear();
        markerSldShown = false;
      });
      user.onConnection = false;
      PathState.didPathStart = true;
      _currentPoint = null;
      UserState.cols = SingletonFunctionController.building
          .floorDimenssion[PathState.sourceBid]![PathState.sourceFloor]![0];
      UserState.rows = SingletonFunctionController.building.floorDimenssion[
      PathState.destinationBid]![PathState.destinationFloor]![1];
      UserState.lngCode = _currentLocale;
      UserState.reroute = reroute;
      UserState.closeNavigation = closeNavigation;
      UserState.alignMapToPath = alignMapToPath;
      UserState.startOnPath = startOnPath;
      UserState.speak = speak;
      UserState.paintMarker = paintMarker;
      UserState.createCircle = updateCircle;
      UserState.autoRecenter = recenterMap;
      //detected=false;
      //user.SingletonFunctionController.building = SingletonFunctionController.building;
      print("PathState.sourceName:${user.locationName}");
      wsocket.message["path"]["source"] = user.locationName;
      wsocket.message["path"]["destination"] = PathState.destinationName;
      // networkManager.ws.updatePath(source: user.locationName);
      // networkManager.ws.updatePath(destination: PathState.destinationName);
      // user.ListofPaths = PathState.listofPaths;
      // user.patchData = SingletonFunctionController.building.patchData;
      // user.buildingNumber = PathState.listofPaths.length-1;
      buildingAllApi.selectedID = PathState.sourceBid;
      buildingAllApi.selectedBuildingID = PathState.sourceBid;
      UserState.cols = SingletonFunctionController.building
          .floorDimenssion[PathState.sourceBid]![PathState.sourceFloor]![0];
      UserState.rows = SingletonFunctionController.building
          .floorDimenssion[PathState.sourceBid]![PathState.sourceFloor]![1];
      user.bid = PathState.sourceBid;
      user.coordX = PathState.sourceX;
      user.coordY = PathState.sourceY;
      user.temporaryExit = false;
      UserState.reroute = reroute;
      UserState.closeNavigation = closeNavigation;
      UserState.alignMapToPath = alignMapToPath;
      UserState.startOnPath = startOnPath;
      UserState.speak = speak;
      UserState.paintMarker = paintMarker;
      UserState.createCircle = updateCircle;
      UserState.changeBuilding = changeBuilding;
      UserState.autoRecenter = recenterMap;
      //user.realWorldCoordinates = PathState.realWorldCoordinates;
      print("startnavigation 1 ${PathState.sourceFloor}");
      user.floor = PathState.sourceFloor;
      user.path = PathState.singleListPath;
      user.isnavigating = true;
      user.cellPath = PathState.singleCellListPath;
      PathState.singleCellListPath.forEach((element) {});
      user.pathobj = PathState;
      user.moveToStartofPath(context).then((value) async {
        print("startnavigation 2 ${user.floor}");
        setState(() {
          markers.clear();
          List<double> val = [user.lat, user.lng];
          if (markers.isEmpty) {
            print("markers were empty");
            markers.putIfAbsent(user.bid, () => []);
            markers[user.bid]?.add(Marker(
              markerId: MarkerId("UserLocation"),
              position: LatLng(val[0], val[1]),
              icon: BitmapDescriptor.fromBytes(userloc),
              anchor: Offset(0.5, 0.829),
            ));
          } else {
            print("markers were not empty");
          }
          val = [user.lat, user.lng];

          List<double> destination = tools.localtoglobal(
              PathState.destinationX,
              PathState.destinationY,
              SingletonFunctionController
                  .building.patchData[PathState.destinationBid]);
          PathState.destinationLat = destination[0];
          PathState.destinationLng = destination[1];
          if (!kIsWeb && kDebugMode) {
            markers[user.bid]?.add(Marker(
              markerId: MarkerId("debug"),
              position: LatLng(val[0], val[1]),
              icon: BitmapDescriptor.fromBytes(userlocdebug),
              anchor: Offset(0.5, 0.829),
            ));
          }
          // circles.add(
          //   Circle(
          //     circleId: CircleId("circle"),
          //     center: LatLng(user.lat,user.lng),
          //     radius: _animation.value,
          //     strokeWidth: 1,
          //     strokeColor: Colors.blue,
          //     fillColor: Colors.lightBlue.withOpacity(0.2),
          //   ),
          // );
        });
      });
      _isRoutePanelOpen = false;
      SingletonFunctionController.currentBeacon ="";
      SingletonFunctionController.building.selectedLandmarkID = null;

      _isnavigationPannelOpen = true;

      semanticShouldBeExcluded = false;

      StartPDR();

      if (SingletonFunctionController.building.floor[PathState.sourceBid] !=
          PathState.sourceFloor) {
        SingletonFunctionController.building.floor[PathState.sourceBid] =
            PathState.sourceFloor;
        createRooms(
            SingletonFunctionController
                .building.polylinedatamap[PathState.sourceBid]!,
            PathState.sourceFloor);
        SingletonFunctionController.building.landmarkdata!.then((value) {
          createMarkers(value, PathState.sourceFloor, PathState.sourceBid);
        });
      }
      await Future.delayed(const Duration(milliseconds: 500));
      alignMapToPath([
        PathState.singleCellListPath[user.pathobj.index].lat,
        PathState.singleCellListPath[user.pathobj.index].lng
      ], [
        PathState.singleCellListPath[user.pathobj.index + 1].lat,
        PathState.singleCellListPath[user.pathobj.index + 1].lng
      ], isTurn: true,animate: true);
      print("startnavigation function called");
      Future.delayed(Duration(seconds: 2)).then((onValue) {
        setState(() {
          onStart = true;
        });
      });
      double angle = tools.calculateAngleBWUserandCellPath(
          user.cellPath[user.pathobj.index],
          user.cellPath[user.pathobj.index + 1],
          user.pathobj.numCols![user.bid]![user.floor]!,
          user.theta);
      String direction = tools.angleToClocks(angle, context) == "None"
          ? "Straight"
          : tools.angleToClocks(angle, context);

      print("direction and angle we got :${direction}--${angle}");
      if (user.floor != user.pathobj.destinationFloor &&
          user.pathobj.connections[user.bid]?[user.floor] ==
              (user.showcoordY * UserState.cols + user.showcoordX)) {
        speak(
            "Use this lift and go to ${tools.numericalToAlphabetical(user.pathobj.destinationFloor)} floor",
            _currentLocale,
            prevpause: false);

      } else if (direction == "Straight") {
        speak(convertTolng("Go Straight", _currentLocale, ''), _currentLocale);
      } else {
        print("speakdirection $direction");
        speak(convertTolng("Turn $direction", _currentLocale, direction),
            _currentLocale);
      }
      user.snapper?.setPath(user.cellPath);
      await user.snapper?.startGpsUpdates();
      user.handleGPS(context);
    }
  }

  final FocusNode _focusNodeA = FocusNode();
  final FocusNode _focusNodeC = FocusNode();
  String semanticsLabel = "";
  int _rating = 0;
  String _feedback = '';
  PanelController _feedbackController = PanelController();
  TextEditingController _feedbackTextController = TextEditingController();

  bool showFeedback = false;
  double minHight = 0.0;
  void __feedbackControllerUp(double d) {
    _feedbackController.animatePanelToPosition(d);
  }

  void __feedbackControllerDown() {
    _feedbackController.close();
  }

  String destiName = '';
  String destiPoly = '';
  String? BuildingName;
  Widget feedbackPanel(BuildContext context) {
    String destpoly = destiPoly.length > 1 ? destiPoly : destiPoly;
    String destiN = destiName.length > 1 ? destiName : destiName;
    if (SingletonFunctionController.building.landmarkdata != null) {
      SingletonFunctionController.building.landmarkdata!.then((value) {
        if (value.landmarksMap![destpoly] != null) {
          setState(() {
            BuildingName = value.landmarksMap![destpoly]!.venueName!;
          });
        }
      });
    }
    minHight = MediaQuery.of(context).size.height / 2.3;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Visibility(
      visible: showFeedback,
      child: Focus(
        autofocus: true,
        focusNode: _destination,
        child: Semantics(
          excludeSemantics: false,
          label:
          "You’ve Arrived ${destiN.isEmpty ? "Your Destination" : destiN}. It is ${finalDestinationDirection}",
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SlidingUpPanel(
                  controller: _feedbackController,
                  minHeight: minHight,
                  maxHeight: MediaQuery.of(context).size.height - 85,
                  snapPoint: 0.9,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        24.0), // Apply radius to top left corner
                    topRight: Radius.circular(
                        24.0), // Apply radius to top right corner
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20.0,
                      color: Colors.grey,
                    ),
                  ],
                  panel: SingleChildScrollView(
                      child: Column(
                        children: [
                          Semantics(
                            label:
                            "You’ve Arrived ${destiN.isEmpty ? "Your Destination" : destiN} ${BuildingName ?? ""}",
                            excludeSemantics: true,
                            header: true,
                            child: Container(
                              width: screenWidth,
                              padding: EdgeInsets.fromLTRB(17, 32, 17, 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(24.0),
                                    topLeft: Radius.circular(24.0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset('assets/success1.png'),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    "You’ve Arrived",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff000000),
                                      height: 25 / 16,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${destiN.isEmpty ? "Your Destination" : destiN}",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff000000),
                                      height: 30 / 32,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${BuildingName ?? ""}",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff000000),
                                      height: 20 / 14,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            indent: 24,
                            endIndent: 24,
                          ),
                          Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "How was your experience?",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff000000),
                                    height: 24 / 18,
                                  ),
                                  textAlign: TextAlign.left,
                                ),

                                SizedBox(height: 16),

                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          _rating = index + 1;
                                          if (_rating >= 4) {
                                            //__feedbackControllerUp(0.3);
                                            // _feedbackTextController.clear();
                                          } else if (_rating <= 3) {
                                            // __feedbackControllerUp(0.9);
                                          } else if (_rating == 3 || _rating == 4) {
                                            _feedbackTextController.clear();
                                          }

                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                          child: index < _rating
                                              ? Semantics(
                                              label: index == _rating - 1
                                                  ? "Rated ${index + 1} star"
                                                  : "Rate ${index + 1} star",
                                              child: SvgPicture.asset(
                                                'assets/ratingStarFilled.svg',
                                                width: 48.0,
                                                height: 48.0,
                                              ))
                                              : Semantics(
                                              label: "Rate ${index + 1} star",
                                              child: SvgPicture.asset(
                                                'assets/ratingStarBorder.svg',
                                                width: 48.0,
                                                height: 48.0,
                                              )),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                // SizedBox(height: 20),
                                // if (_rating > 0 && _rating < 4) ...[
                                //   SizedBox(height: 16),
                                //   Text(
                                //     "Select the Issues ",
                                //     style: const TextStyle(
                                //       fontFamily: "Roboto",
                                //       fontSize: 18,
                                //       fontWeight: FontWeight.w700,
                                //       color: Color(0xff000000),
                                //     ),
                                //     textAlign: TextAlign.left,
                                //   ),
                                //   SizedBox(height: 16),
                                //   ChipFilterWidget(
                                //
                                //     options: ['Bad map route', 'Wrong turns', 'UI Issue', 'App speed','Search Function','Map Accuracy'],
                                //     onSelected: (selectedOption) {
                                //
                                //       // Handle the selection here
                                //       _feedbackTextController.text = selectedOption;
                                //       _feedback = _feedbackTextController.text;
                                //
                                //       setState(() {
                                //
                                //       });
                                //     },
                                //
                                //   ),
                                //   SizedBox(height: 20),
                                //   Text(
                                //     "Add a Detailed Review",
                                //     style: const TextStyle(
                                //       fontFamily: "Roboto",
                                //       fontSize: 18,
                                //       fontWeight: FontWeight.w700,
                                //       color: Color(0xff000000),
                                //       height: 24/18,
                                //     ),
                                //     textAlign: TextAlign.left,
                                //   ),
                                //   SizedBox(height: 20),
                                //   TextFormField(
                                //       controller: _feedbackTextController,
                                //       maxLines: 4,
                                //       decoration: InputDecoration(
                                //         hintText: 'Please share your thoughts...',
                                //         border: OutlineInputBorder(
                                //           borderRadius: BorderRadius.circular(12),
                                //         ),
                                //         filled: false,
                                //         fillColor: Colors.white,
                                //       ),
                                //       onChanged: (value)  {
                                //         _feedback = value;
                                //
                                //         setState(() {
                                //
                                //         });
                                //       }
                                //   ),
                                // ],
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      RatingsaveAPI().saveRating(
                          _feedback,
                          _rating,
                          UserCredentials().getUserId(),
                          UserCredentials().getuserName(),
                          PathState.sourcePolyID,
                          PathState.destinationPolyID,
                          "com.iwayplus.accessibleashoka");
                      if (_feedback.isNotEmpty) {}
                      showFeedback = false;
                      _feedbackController.hide();

                      _feedbackTextController.clear();

                      BuildingName = null;
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Semantics(
                        label: "Submit feedback",
                        excludeSemantics: true,
                        header: true,
                        child: Text(
                          (_rating > 0) ? 'Done' : 'Exit',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff24B9B0),
                      //  disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  LatLng? lastTarget;
  double cameraBearing = 0;
  double smoothingFactor = 0.05; // keep camera fixed until a turn

  Future<void> alignMapToPath(List<double> A, List<double> B,{bool isTurn=false, bool animate = false}) async {
    mapState.tilt = 52.5;
    mapState.target = LatLng(A[0], A[1]);
    mapState.bearing = tools.calculateBearing(A, B);
    if(mapState.bearing == 0.0){
      _googleMapController.animateCamera(CameraUpdate.zoomTo(21));
      return;
    }
    print("mapState.bearing ${mapState.bearing} ${mapState.tilt} ${mapState.zoom} ${mapState.target} ");
// if(isTurn) {
    setState(() {
      if (animate) {
        mapState.zoom=21;
        _googleMapController.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: mapState.target,
              zoom: mapState.zoom,
              bearing: mapState.bearing!,
              tilt: mapState.tilt),
        ));
      } else {
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: mapState.target,
              zoom: 21.0,
              bearing: mapState.bearing!,
              tilt: mapState.tilt),
        ));
      }
    });
// }
  }
  static double normalizeBearing(double newBearing, double lastBearing) {
    double diff = newBearing - lastBearing;
    // wrap into [-180, 180] range
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    return lastBearing + diff;
  }

  static double smoothBearing(double current, double target, double factor) {
    return current + (target - current) * factor; // factor ~0.2
  }

  void shouldBeOpenedVarChangeFunc() {
    setState(() {
      semanticShouldBeExcluded = false;
    });
  }

  bool shouldStepOpen = false;
  void shouldStepOpenfunc() {
    setState(() {
      shouldStepOpen = true;
    });
  }

  void noshouldStepOpenfunc() {
    Future.delayed(Duration(seconds: 10)).then((_) {
      setState(() {
        shouldStepOpen = false;
      });
    });
  }

  bool isLift = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  Timer? _messageTimer;
  bool disposed = false;

  void _startScrolling() {
    _scrollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 3),
          curve: Curves.easeInOut,
        );
        _resetScrollPosition();
      }
    });
  }

  void _resetScrollPosition() {
    Timer(Duration(seconds: 3), () {
      _scrollController.animateTo(
        0.0,
        duration: Duration(seconds: 3),
        curve: Curves.easeInOut,
      );
    });
  }
  // void _addCircle(double l1,double l2){
  //   _updateCircle();
  // }

  void pauseCompassSubscription() {
    compassSubscription?.pause();
  }

// Function to resume the compass subscription
  void resumeCompassSubscription() {
    compassSubscription?.resume();
  }

  void cancelCompassSubscription() {
    compassSubscription.cancel();
  }

  void getPathDirections() {
    setState(() {
      user.theta = tools.calculateBearing_fromLatLng(
          LatLng(user.lat, user.lng),
          LatLng(user.cellPath[user.pathobj.index + 1].lat,
              user.cellPath[user.pathobj.index + 1].lng));
      if (mapState.interaction2) {
        mapState.bearing = tools.calculateBearing_fromLatLng(
            LatLng(user.lat, user.lng),
            LatLng(user.cellPath[user.pathobj.index + 1].lat,
                user.cellPath[user.pathobj.index + 1].lng));
        _googleMapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: mapState.target,
              zoom: mapState.zoom,
              bearing: mapState.bearing!,
            ),
          ),
          //duration: Duration(milliseconds: 500), // Adjust the duration here (e.g., 500 milliseconds for a faster animation)
        );
      } else {
        if (markers.length > 0 && markers[user.bid] != null)
          markers[user.bid]![0] = customMarker.rotate(
              tools.calculateBearing_fromLatLng(
                  LatLng(user.lat, user.lng),
                  LatLng(user.cellPath[user.pathobj.index + 1].lat,
                      user.cellPath[user.pathobj.index + 1].lng)) -
                  mapbearing,
              markers[user.bid]![0]);
      }
    });
  }

  void moveUserHard() {
    bool isvalid = MotionModel.isValidStep(
        user,
        SingletonFunctionController
            .building.floorDimenssion[user.bid]![user.floor]![0],
        SingletonFunctionController
            .building.floorDimenssion[user.bid]![user.floor]![1],
        SingletonFunctionController
            .building.nonWalkable[user.bid]![user.floor]!,
        reroute,
        context);
    if (isvalid) {
      user.move(context).then((value) {
        print("renderedddd here");
        ();
      });
    }
  }

  bool insideLift = false;
  bool onStart = false;
  Widget navigationPannel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double time = 0;
    double distance = 0;
    DateTime currentTime = DateTime.now();
    if (PathState.singleCellListPath.isNotEmpty) {
      distance = tools.PathDistance(PathState.singleCellListPath,
          index: user.pathobj.index);
      time = distance / 120;
      time = time.ceil().toDouble();

      distance = distance * 0.3048;
      distance = double.parse(distance.toStringAsFixed(1));
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));
    return Visibility(
        visible: _isnavigationPannelOpen,
        child: Stack(
          children: [
            SafeArea(
              child: SlidingUpPanel(
                controller: _panelController,
                isDraggable: false,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20.0,
                    color: Colors.grey,
                  ),
                ],
                minHeight: 92,
                maxHeight: screenHeight * 0.9,
                snapPoint: 0.9,
                panel: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 92,
                        padding: EdgeInsets.fromLTRB(11, 22, 14.08, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Semantics(
                                onDidGainAccessibilityFocus:
                                noshouldStepOpenfunc,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Semantics(
                                          excludeSemantics: false,
                                          child: Row(
                                            children: [
                                              Semantics(
                                                label: "Travel time",
                                                child: Text(
                                                  "${time.toInt()} min",
                                                  style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 20,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      height: 26 / 20,
                                                      color: Color(0xffDC6A01)),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              Text(
                                                " (${distance} m)",
                                                style: const TextStyle(
                                                  fontFamily: "Roboto",
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  height: 26 / 20,
                                                ),
                                                textAlign: TextAlign.left,
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Semantics(
                                          excludeSemantics: true,
                                          child: Text(
                                            "ETA- ${newTime.hour}:${newTime.minute}",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff8d8c8c),
                                              height: 20 / 14,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Semantics(
                              label: "Exit navigation",
                              excludeSemantics: true,
                              child: Container(
                                height: 40,
                                width: 65,
                                decoration: BoxDecoration(
                                  color: Color(0xffDF3535),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: TextButton(
                                    onPressed: () {
                                      clustringOFF = false;
                                      setState((){});
                                      setState(() {

                                        StopPDR();
                                        onStart = false;
                                        startingNavigation = true;
                                        PathState.sourceX = user.coordX;
                                        PathState.sourceY = user.coordY;
                                        PathState.sourceFloor = user.floor;
                                        PathState.sourceBid = user.bid;
                                        PathState.sourceLat = user.lat;
                                        PathState.sourceLng = user.lng;
                                        PathState.sourceName =
                                        "Your current location";

                                        user.temporaryExit = true;
                                        user.isnavigating = false;
                                        _isRoutePanelOpen = true;
                                        _isnavigationPannelOpen = false;

                                        if (pathMarkers[user.bid] != null) {
                                          // setCameraPosition(
                                          //     pathMarkers[user.bid]![
                                          //     SingletonFunctionController
                                          //         .building
                                          //         .floor[user.bid]]!);
                                          List<LatLng> ll = [
                                            pathMarkers[user.bid]![
                                            SingletonFunctionController
                                                .building
                                                .floor[user.bid]]!
                                                .first
                                                .position,
                                            pathMarkers[user.bid]![
                                            SingletonFunctionController
                                                .building
                                                .floor[user.bid]]!
                                                .last
                                                .position
                                          ];
                                          fitTwoPoints(ll);
                                        }
                                      });
                                    },
                                    child: Text(
                                      "Exit",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xffFFFFFF),
                                        height: 20 / 14,
                                      ),
                                      textAlign: TextAlign.left,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: 1,
                        color: Color(0xffEBEBEB),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            DirectionHeader(
              user: user,
              paint: paintUser,
              repaint: repaintUser,
              reroute: reroute,
              moveUser: moveUser,
              closeNavigation: closeNavigation,
              isRelocalize: false,
              focusOnTurn: focusOnTurn,
              clearFocusTurnArrow: clearFocusTurnArrow,
              context: context,
              //turnMarkersVisible:turnMarkersVisible,
            )
          ],
        ));
  }
  final FocusNode _focusNodeB = FocusNode();
  void exitNavigation() {
    setState(() {
      if (PathState.didPathStart) {
        showFeedback = true;
        Future.delayed(Duration(seconds: 5));
        _feedbackController.open();
        _feedbackTextController.clear();
      }
    });
    markNavigationUnsuccessful("User Exited Navigation");
    markerSldShown = true;
    focusturnArrow.clear();
    clearPathVariables();
    _isnavigationPannelOpen = false;
    user.reset();
    PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
    selectedroomMarker.clear();
    pathMarkers.clear();
    PathState.path.clear();
    PathState.sourcePolyID = "";
    PathState.destinationPolyID = "";
    singleroute.clear();
    pathCovered.clear();
    if (Platform.isIOS) {
      BluetoothScanIOSClass.stopScan();
    } else {
      bluetoothScanAndroidClass.stopScan();
    }
    fitPolygonInScreen(patch.first);
    setState(() {
      if (markers.length > 0) {
        List<double> lvalue = tools.localtoglobal(
            user.showcoordX.toInt(),
            user.showcoordY.toInt(),
            SingletonFunctionController.building.patchData[user.bid]);
        markers[user.bid]?[0] = customMarker.move(
            LatLng(lvalue[0], lvalue[1]), markers[user.bid]![0]);
      }
    });
  }

  bool rerouting = false;

  Widget reroutePannel(context) {
    return Visibility(
        visible: _isreroutePannelOpen,
        child: SlidingUpPanel(
          minHeight: 119,
          backdropEnabled: true,
          isDraggable: false,
          panel: Container(
            padding: EdgeInsets.only(left: 13, top: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/Reroutevector.svg"),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Off-Path Notification",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff000000),
                        height: 26 / 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      "Lost the path? New route?",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8d8c8c),
                        height: 20 / 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        FocusScope(
                          autofocus: true,
                          child: Semantics(
                            label: "Reroute",
                            child: Container(
                              width: 85,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(0xff24B9B0),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TextButton(
                                key: rerouteButton,
                                onPressed: () async {
                                  autoreroute();
                                },
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        // Container(
                        //   width: 92,
                        //   height: 36,
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(4.0),
                        //       border: Border.all(color: Colors.black)),
                        //   // child: TextButton(
                        //   //   onPressed: () {
                        //   //
                        //   //   },
                        //   //
                        //   //
                        //   //   child: Text(
                        //   //     "Continue",
                        //   //     style: const TextStyle(
                        //   //       fontFamily: "Roboto",
                        //   //       fontSize: 14,
                        //   //       fontWeight: FontWeight.w400,
                        //   //       color: Color(0xff000000),
                        //   //       height: 20 / 14,
                        //   //     ),
                        //   //     textAlign: TextAlign.left,
                        //   //   ),
                        //   // ),
                        // )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  List<String> optionsTags = [];
  List<String> floorOptionsTags = [];

  List<String> options = [
    'Washroom',
    'Food & Drinks',
    'Reception',
    'Break Room',
    'Education',
    'Fashion',
    'Travel',
    'Rooms',
    'Tech',
    'Science',
  ];
  List<String> floorOptions = [
    'All',
    'Floor 0',
    'Floor 1',
    'Floor 2',
    'Floor 3'
  ];

  List<ImageProvider<Object>> imageList = [];
  late land landmarkData = new land();
  List<Landmarks> LandmarkItems = [];
  List<Landmarks> filteredItems = [];

  void fetchlist() async {
    // await landmarkApi().fetchLandmarkData().then((value){
    //   landmarkData = value;
    //   LandmarkItems = value.landmarks!;
    // });
    //LandmarkItems = landmarkData.landmarks!;
  }

  void filterItems() {
    if (optionsTags == null && floorOptionsTags != null) {
      setState(() {
        filteredItems = LandmarkItems.where(
                (item) => floorOptionsTags.contains('Floor ${item.floor}'))
            .toList();
      });
    } else if (optionsTags != null && floorOptionsTags == null) {
      setState(() {
        filteredItems = LandmarkItems.where((item) =>
        optionsTags.contains(item.element?.type) &&
            floorOptionsTags.contains('Floor ${item.floor}')).toList();
      });
    } else {
      setState(() {
        filteredItems = LandmarkItems.where(
                (item) => optionsTags.contains(item.element?.type)).toList();
      });
    }
  }

// Call filterItems() whenever tags change
  void onTagsChanged() {
    setState(() {
      filterItems();
    });
  }

  final PanelController _panelController = PanelController();

  void _slidePanelUp() {
    _panelController.open();
  }

  void _slidePanelUpNavigation() {
    _panelController.animatePanelToSnapPoint();
  }

  void _slidePanelDown() {
    _panelController.close();
  }

  void _slidePanelDownNavigation() {
    _panelController.animatePanelToPosition(90.0);
  }

  bool _isFilterOpen = false;
  bool isLiveLocalizing = false;

  Future<int> getHiveBoxLength() async {
    final box = await Hive.openBox(
        'Filters'); // Replace 'yourBoxName' with the name of your box
    return box.length;
  }

  Widget buildingDetailPannel() {
    buildingAll element = new buildingAll.buildngAllAPIModel();
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();
    if (BuildingAllBox.length > 0) {
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAll> buildingList =
      responseBody.map((data) => buildingAll.fromJson(data)).toList();
      buildingList.forEach((Element) {
        if (Element.sId == buildingAllApi.getStoredString()) {
          setState(() {
            element = Element;
          });
        }
      });
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //fetchlist();
    //filterItems();
    return Visibility(
        visible: _isBuildingPannelOpen,
        child: SlidingUpPanel(
            controller: _panelController,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ],
            minHeight:
            element.workingDays != null && element.workingDays!.length > 0
                ? 155
                : 140,
            snapPoint:
            element.workingDays != null && element.workingDays!.length > 0
                ? 190 / screenHeight
                : 175 / screenHeight,
            maxHeight: screenHeight * 0.9,
            panel: Semantics(
              child: Container(
                  child: !_isFilterOpen
                      ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 6,
                              margin: EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Color(0xffd9d9d9),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, bottom: 4),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${element.buildingName}",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      height: 27 / 18,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  element.workingDays != null &&
                                      element.workingDays!.length > 0
                                      ? Row(
                                    children: [
                                      Text(
                                        "Open ",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.w400,
                                          color: Color(0xff4caf50),
                                          height: 25 / 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "  Closes ${element.workingDays![0].closingTime}",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.w400,
                                          color: Color(0xff8d8c8c),
                                          height: 25 / 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                      : Container()
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 8, bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 142,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Color(0xff24B9B0),
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                    ),
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              "assets/ExploreInside.svg"),
                                          SizedBox(width: 8),
                                          Text(
                                            "Explore Inside",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffffffff),
                                              height: 20 / 14,
                                            ),
                                            textAlign: TextAlign.left,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Container(
                                    width: 83,
                                    height: 42,
                                    decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        borderRadius:
                                        BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: Color(0xff000000))),
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: Color(0xff000000),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Call",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff000000),
                                              height: 20 / 14,
                                            ),
                                            textAlign: TextAlign.left,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Semantics(
                                    label: "Share",
                                    onDidGainAccessibilityFocus:
                                    _slidePanelUp,
                                    // onDidLoseAccessibilityFocus: _slidePanelDown,
                                    child: Container(
                                      width: 95,
                                      height: 42,
                                      decoration: BoxDecoration(
                                          color: Color(0xffffffff),
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: Color(0xff000000))),
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.share,
                                              color: Color(0xff000000),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Share",
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w500,
                                                color: Color(0xff000000),
                                                height: 20 / 14,
                                              ),
                                              textAlign: TextAlign.left,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Semantics(
                              label: "",
                              child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Semantics(
                                              header: true,
                                              child: GestureDetector(
                                                onTap: _slidePanelUp,
                                                child: Text(
                                                  "Services",
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    color: Color(0xff000000),
                                                    height: 23 / 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Semantics(
                                              label: 'Services',
                                              child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      //_isBuildingPannelOpen = !_isBuildingPannelOpen;
                                                      _isFilterOpen =
                                                      !_isFilterOpen;
                                                    });
                                                  },
                                                  child: Text(
                                                    "See All",
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      color:
                                                      Color(0xff4a4545),
                                                      height: 20 / 14,
                                                    ),
                                                    textAlign:
                                                    TextAlign.center,
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Row(
                                          children: [
                                            Semantics(
                                              label: "",
                                              child: Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 61,
                                                      height: 56,
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(Radius
                                                              .circular(
                                                              8)),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffB3B3B3))),
                                                      child: SvgPicture.asset(
                                                          "assets/washroomservice.svg"),
                                                    ),
                                                    Text(
                                                      "Washroom",
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color:
                                                        Color(0xff4a4545),
                                                        height: 20 / 14,
                                                      ),
                                                      textAlign:
                                                      TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Semantics(
                                              label: "",
                                              header: true,
                                              child: Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 61,
                                                      height: 56,
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(Radius
                                                              .circular(
                                                              8)),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffB3B3B3))),
                                                      child: SvgPicture.asset(
                                                          "assets/foodservice.svg"),
                                                    ),
                                                    Text(
                                                      "Food",
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color:
                                                        Color(0xff4a4545),
                                                        height: 20 / 14,
                                                      ),
                                                      textAlign:
                                                      TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Semantics(
                                              label: "",
                                              header: true,
                                              child: Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 61,
                                                      height: 56,
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(Radius
                                                              .circular(
                                                              8)),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffB3B3B3))),
                                                      child: SvgPicture.asset(
                                                          "assets/accservice.svg"),
                                                    ),
                                                    Text(
                                                      "Accessibility",
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color:
                                                        Color(0xff4a4545),
                                                        height: 20 / 14,
                                                      ),
                                                      textAlign:
                                                      TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Semantics(
                                              label: "",
                                              child: Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 61,
                                                      height: 56,
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(Radius
                                                              .circular(
                                                              8)),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffB3B3B3))),
                                                      child: SvgPicture.asset(
                                                          "assets/exitservice.svg"),
                                                    ),
                                                    Text(
                                                      "Exit",
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color:
                                                        Color(0xff4a4545),
                                                        height: 20 / 14,
                                                      ),
                                                      textAlign:
                                                      TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Semantics(
                                        onDidLoseAccessibilityFocus:
                                        _slidePanelDown,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: _slidePanelDown,
                                                child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 17),
                                                    child: Text(
                                                      "Information",
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color:
                                                        Color(0xff000000),
                                                        height: 23 / 16,
                                                      ),
                                                      textAlign:
                                                      TextAlign.left,
                                                    )),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 16, right: 16),
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 11, 0, 10),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 1.0,
                                                          color: Color(
                                                              0xffebebeb))),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        "assets/Depth 3, Frame 0.svg"),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Container(
                                                      width:
                                                      screenWidth - 100,
                                                      margin: EdgeInsets.only(
                                                          top: 8),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style:
                                                          const TextStyle(
                                                            fontFamily:
                                                            "Roboto",
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight
                                                                .w400,
                                                            color: Color(
                                                                0xff4a4545),
                                                            height: 25 / 16,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                              "${element.address}",
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Container(
                                              //   margin:
                                              //   EdgeInsets.only(left: 16, right: 16),
                                              //   padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                                              //   decoration: BoxDecoration(
                                              //     border: Border(
                                              //         bottom: BorderSide(
                                              //             width: 1.0,
                                              //             color: Color(0xffebebeb))),
                                              //   ),
                                              //   child: Row(
                                              //     crossAxisAlignment:
                                              //     CrossAxisAlignment.center,
                                              //     children: [
                                              //       SvgPicture.asset("assets/Depth 3, Frame 1.svg"),
                                              //       SizedBox(width: 16,),
                                              //       Container(
                                              //         margin: EdgeInsets.only(top: 8),
                                              //         child: RichText(
                                              //           text: TextSpan(
                                              //             style: const TextStyle(
                                              //               fontFamily: "Roboto",
                                              //               fontSize: 16,
                                              //               fontWeight: FontWeight.w400,
                                              //               color: Color(0xff4a4545),
                                              //               height: 25 / 16,
                                              //             ),
                                              //             children: [
                                              //               TextSpan(
                                              //                 text:
                                              //                 "6 Floors",
                                              //               ),
                                              //             ],
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
                                              element.phone != null
                                                  ? Container(
                                                margin: EdgeInsets.only(
                                                    left: 16,
                                                    right: 16),
                                                padding:
                                                EdgeInsets.fromLTRB(
                                                    0, 11, 0, 10),
                                                decoration:
                                                BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 1.0,
                                                          color: Color(
                                                              0xffebebeb))),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        "assets/Depth 3, Frame 1-1.svg"),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets
                                                          .only(top: 8),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style:
                                                          const TextStyle(
                                                            fontFamily:
                                                            "Roboto",
                                                            fontSize:
                                                            16,
                                                            fontWeight:
                                                            FontWeight
                                                                .w400,
                                                            color: Color(
                                                                0xff4a4545),
                                                            height:
                                                            25 / 16,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                              "${element.phone}",
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                                  : Container(),
                                              element.website != null
                                                  ? Container(
                                                margin: EdgeInsets.only(
                                                    left: 16,
                                                    right: 16),
                                                padding:
                                                EdgeInsets.fromLTRB(
                                                    0, 11, 0, 10),
                                                decoration:
                                                BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 1.0,
                                                          color: Color(
                                                              0xffebebeb))),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        "assets/Depth 3, Frame 1-2.svg"),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets
                                                          .only(top: 8),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style:
                                                          const TextStyle(
                                                            fontFamily:
                                                            "Roboto",
                                                            fontSize:
                                                            16,
                                                            fontWeight:
                                                            FontWeight
                                                                .w400,
                                                            color: Color(
                                                                0xff4a4545),
                                                            height:
                                                            25 / 16,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                              "${element.website}",
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                                  : Container(),
                                              element.workingDays != null &&
                                                  element.workingDays!
                                                      .length >
                                                      1
                                                  ? Container(
                                                margin: EdgeInsets.only(
                                                    left: 16,
                                                    right: 16),
                                                padding:
                                                EdgeInsets.fromLTRB(
                                                    0, 11, 0, 10),
                                                decoration:
                                                BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 1.0,
                                                          color: Color(
                                                              0xffebebeb))),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        "assets/Depth 3, Frame 1-3.svg"),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets
                                                              .only(
                                                              top:
                                                              8),
                                                          child:
                                                          RichText(
                                                            text:
                                                            TextSpan(
                                                              style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                "Roboto",
                                                                fontSize:
                                                                16,
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                color: Color(
                                                                    0xff4a4545),
                                                                height:
                                                                25 /
                                                                    16,
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                  "${element.workingDays![0].day} to ${element.workingDays![element.workingDays!.length - 1].day}",
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .only(
                                                              top:
                                                              8),
                                                          child:
                                                          RichText(
                                                            text:
                                                            TextSpan(
                                                              style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                "Roboto",
                                                                fontSize:
                                                                16,
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                color: Color(
                                                                    0xff4a4545),
                                                                height:
                                                                25 /
                                                                    16,
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                  "${element.workingDays![0].openingTime} - ${element.workingDays![element.workingDays!.length - 1].closingTime}",
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                      : Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 6,
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                color: Color(0xffd9d9d9),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 17, top: 8),
                              child: IconButton(
                                onPressed: () {
                                  _isFilterOpen = !_isFilterOpen;
                                },
                                icon: SvgPicture.asset(
                                  "assets/Navigation_closeIcon.svg",
                                  height: 24,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 17, top: 8),
                              child: Text(
                                "Filters",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff000000),
                                  height: 26 / 20,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Spacer(),
                            Container(
                              margin: EdgeInsets.only(right: 14, top: 10),
                              child: TextButton(
                                onPressed: () {
                                  optionsTags.clear();
                                  floorOptionsTags.clear();
                                },
                                child: Text(
                                  "Clear All",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff24b9b0),
                                    height: 20 / 14,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )
                          ],
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8, left: 16),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Services",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff000000),
                              height: 23 / 16,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        //-----------------------------CHECK FILTER SELECTED DATABASE---------------------------
                        // FutureBuilder<int>(
                        //   future: getHiveBoxLength(),
                        //   builder: (context, snapshot) {
                        //     if (snapshot.connectionState != ConnectionState.waiting) {
                        //       return Text('Error: ${snapshot.error}'); // or any loading indicator
                        //     } else if (snapshot.hasError) {
                        //       return Text('Error: ${snapshot.error}');
                        //     } else {
                        //       return Text('Length of Hive Box: ${snapshot.data}');
                        //     }
                        //   },
                        // ),
                        //---------------------------------------------------------------------------------------

                        Container(
                          child: ValueListenableBuilder(
                            valueListenable:
                            Hive.box('Filters').listenable(),
                            builder: (BuildContext context, value,
                                Widget? child) {
                              //List<dynamic> aa = []
                              if (value.length != 0) {
                                optionsTags = value.getAt(0);
                              }
                              return ChipsChoice<String>.multiple(
                                value: optionsTags,
                                onChanged: (val) {
                                  value.put(0, val);
                                  setState(() {
                                    optionsTags = val;
                                    onTagsChanged();
                                  });
                                },
                                choiceItems:
                                C2Choice.listFrom<String, String>(
                                  source: options,
                                  value: (i, v) => v,
                                  label: (i, v) => v,
                                  tooltip: (i, v) => v,
                                ),
                                choiceCheckmark: true,
                                choiceStyle: C2ChipStyle.filled(
                                    selectedStyle: const C2ChipStyle(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(7),
                                        ),
                                        backgroundColor:
                                        Color(0XFFABF9F4)),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(7),
                                    ),
                                    borderStyle: BorderStyle.solid),
                                wrapped: false,
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8, left: 16),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Choose Floor",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff000000),
                              height: 23 / 16,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          child: ValueListenableBuilder(
                            valueListenable:
                            Hive.box('Filters').listenable(),
                            builder: (BuildContext context, value,
                                Widget? child) {
                              //List<dynamic> aa = []
                              if (value.length == 2) {
                                floorOptionsTags = value.getAt(1);
                              }
                              return ChipsChoice<String>.multiple(
                                value: floorOptionsTags,
                                onChanged: (val) {
                                  value.put(1, val);
                                  setState(() {
                                    floorOptionsTags = val;
                                    onTagsChanged();
                                  });
                                },
                                choiceItems:
                                C2Choice.listFrom<String, String>(
                                  source: floorOptions,
                                  value: (i, v) => v,
                                  label: (i, v) => v,
                                  tooltip: (i, v) => v,
                                ),
                                choiceLeadingBuilder: (data, i) {
                                  if (data.meta == null) return null;
                                  return CircleAvatar(
                                    maxRadius: 12,
                                    backgroundImage: data.avatarImage,
                                  );
                                },
                                choiceCheckmark: true,
                                choiceStyle: C2ChipStyle.filled(
                                  selectedStyle: const C2ChipStyle(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7),
                                      ),
                                      backgroundColor: Color(0XFFABF9F4)),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(7),
                                  ),
                                ),
                                wrapped: false,
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8, left: 16),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Filter results ${filteredItems.length}",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                              height: 23 / 16,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          height: screenHeight - 410,
                          child: ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return NavigatonFilterCard(
                                LandmarkName: item.venueName!,
                                LandmarkDistance: "90 m",
                                LandmarkFloor: "Floor ${item.floor}",
                                LandmarksubName: item.buildingName!,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )),
            )));
  }

  String nearestLandmarkNameForPannel = "";
  String nearestAddressForPannel = "";
  bool _isExploreModePannelOpen = false;
  PanelController ExploreModePannelController = new PanelController();
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  bool isPressed = false;

  void EM_startAnimation() {
    if (!isPressed) {
      setState(() {
        isPressed = true;
      });
      EM_addRipple();
    }
  }

  void EM_stopAnimation() {
    setState(() {
      isPressed = false;
    });
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
  }

  void EM_addRipple() {
    if (!isPressed) return;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    final currentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );

    currentAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animations.remove(currentAnimation);
          _controllers.remove(controller);
        });
        controller.dispose();
      }
    });

    setState(() {
      _controllers.add(controller);
      _animations.add(currentAnimation);
    });

    controller.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (isPressed) {
        EM_addRipple();
      }
    });
  }

  late StreamSubscription<MagnetometerEvent> magnetometerSubscription;

  void identifyFrontLandmark() {
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    List<int> newUserCord = [
      user.coordX + transitionValue[0],
      user.coordY + transitionValue[1]
    ];
    for (var landmark in getallnearestInfo) {
      double value = tools.calculateAngle2([user.coordX, user.coordY],
          newUserCord, [landmark.coordinateX!, landmark.coordinateY!]);
      if (value < 45) {
        value = value + 45;
      }
      // if ((value >= 315 && value <= 360) || (value >= 0 && value <= 45)) {
      //   //Vibration.vibrate();
      //   speak("${landmark.name} is on your front", _currentLocale);
      // }
    }
  }

  Widget ExploreModePannel() {
    List<Widget> Exwidgets = [];
    for (int i = 0; i < getallnearestInfo.length; i++) {
      Exwidgets.add(
          ExploreModeWidget(getallnearestInfo[i], finalDirections[i]));
    }
    final size = MediaQuery.of(context).size;
    // Calculate the diagonal length of the screen
    final screenDiagonal =
    sqrt(size.width * size.width + size.height * size.height);

    return Visibility(
        visible: _isExploreModePannelOpen,
        child: SlidingUpPanel(
          maxHeight: 90 + (getallnearestInfo.length * 100),
          minHeight: 90 + 8,
          controller: ExploreModePannelController,
          panel: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(0xff79747E),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Explore Mode",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff000000),
                        height: 20 / 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    IconButton(
                        onPressed: () {
                          if (exploremodeLandmarkTimer != null &&
                              exploremodeLandmarkTimer!.isActive) {
                            exploremodeLandmarkTimer!.cancel();
                          }
                          isLiveLocalizing = false;
                          HelperClass.showToast("Explore mode is disabled");
                          _exploreModeMarker.clear();
                          _exploreModeTimer!.cancel();
                          _isExploreModePannelOpen = false;
                          _isBuildingPannelOpen = true;
                          lastBeaconValue = "";
                          magnetometerSubscription.cancel();
                        },
                        icon: Icon(Icons.close))
                  ],
                ),
                SizedBox(
                  height: 0,
                ),
                Column(
                  children: Exwidgets,
                ),
              ],
            ),
          ),
        ));
  }

  NavigationLog? currentNavigationLog;
  void startNavigationLog(String userId, String source, String destination) {
    currentNavigationLog = NavigationLog(
        userId: userId,
        source: source,
        destination: destination,
        startTime: DateTime.now(),
        // abruptEnd: false,
        directionButton: true
    );
    print("startNavigationLog:${currentNavigationLog}");
  }

  void markNavigationSuccessful() {
    if (currentNavigationLog != null) {
      currentNavigationLog!.markSuccessful();
      saveLog(currentNavigationLog!);
      NavigationLogManager().logNavigation(currentNavigationLog!);
    }
  }
  String exitReason='';
  void markNavigationUnsuccessful(String reason) {
    if (currentNavigationLog != null) {
      currentNavigationLog!.markUnsuccessful(reason);
      saveLog(currentNavigationLog!);
      NavigationLogManager().logNavigation(currentNavigationLog!);
      setState(() {
        exitReason=reason;
      });
    }
  }




  void incrementRerouteCount() {
    if (currentNavigationLog != null) {
      currentNavigationLog!.incrementReroute();
    }
  }

  void saveLog(NavigationLog log) {
    // Save log to database or local storage
    print("Navigation Log: ${log.toJson()}");
  }

  Widget nearestLandmarkpannel() {
    buildingAll element = new buildingAll.buildngAllAPIModel();
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();
    if (BuildingAllBox.length > 0) {
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAll> buildingList =
      responseBody.map((data) => buildingAll.fromJson(data)).toList();
      buildingList.forEach((Element) {
        if (Element.sId == buildingAllApi.getStoredString()) {
          setState(() {
            allBuildingList.add(Element.sId!);
            element = Element;
          });
        }
      });
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //fetchlist();
    //filterItems();

    return Visibility(
        visible: _isBuildingPannelOpen && !user.isnavigating,
        child: Semantics(
          label:
          "You are near ${user.locationName}, ${LocaleData.floor.getString(context)} ${user.floor}",
          excludeSemantics: true,
          child: SlidingUpPanel(
            controller: _panelController,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ],
            minHeight: 92,
            maxHeight: 92,
            panel: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Container(
                        width: screenWidth - 50,
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.only(left: 17, top: 12),
                        child: Semantics(
                          label: "",
                          excludeSemantics: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "You are near ${user.locationName}, ${LocaleData.floor.getString(context)} ${user.floor}",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff292929),
                                  height: 25 / 18,
                                ),
                                textAlign: TextAlign.left,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              )
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          _isBuildingPannelOpen = false;
                        },
                        child: Semantics(
                          label: "Close Info pannel",
                          child: Container(
                            margin: EdgeInsets.only(right: 20),
                            alignment: Alignment.topCenter,
                            child: SvgPicture.asset("assets/closeicon.svg"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Set<Marker> getCombinedMarkers() {
    Set<Marker> combinedMarkers = Set();
    combinedMarkers = combinedMarkers
        .union(MGMarkers)
        .union(_markers)
        .union(focusturnArrow)
        .union(Markers)
    // .union(debugMarker)
        .union(GpsMarker)
        .union(nearbyLandmarks.values.toSet())
        .union(_exploreModeMarker)
        .union(_exploreModeDebugBeaconMarker);
    if (user.floor ==
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()]) {
      if (_isLandmarkPanelOpen) {
        selectedroomMarker.forEach((key, value) {
          combinedMarkers = combinedMarkers.union(value);
        });
      }
    } else {
      if (_isLandmarkPanelOpen) {
        selectedroomMarker.forEach((key, value) {
          combinedMarkers = combinedMarkers.union(value);
        });
      }
    }

    buildingAllApi.allBuildingID.forEach((key, value) {
      if (pathMarkers[key] != null &&
          pathMarkers[key]![SingletonFunctionController.building.floor[key]] !=
              null) {
        combinedMarkers = combinedMarkers.union(pathMarkers[key]![
        SingletonFunctionController.building.floor[key]]!);
      }
      if ((!_isRoutePanelOpen || !_isnavigationPannelOpen) &&
          markers[key] != null &&
          user.floor == SingletonFunctionController.building.floor[key]) {
        combinedMarkers = combinedMarkers.union(Set<Marker>.of(markers[key]!));
      }
    });

    // // Always union the general Markers set at the end
    // if (SingletonFunctionController.building.floor[user.bid] == user.floor) {
    //   markers.forEach((key, value) {
    //     combinedMarkers = combinedMarkers.union(Set<Marker>.of(value));
    //   });
    // }

    if (playPreviewManager != null) {
      buildingAllApi.allBuildingID.forEach((key, value) {
        if (playPreviewManager?.previewMarker[key] != null &&
            playPreviewManager?.previewMarker[key]![
            SingletonFunctionController.building.floor[key]] !=
                null) {
          combinedMarkers = combinedMarkers.union(
              playPreviewManager!.previewMarker[key]![
              SingletonFunctionController.building.floor[key]]!);
          // print("combined markers:${key} ${value} ${combinedMarkers.length} ${SingletonFunctionController.building.floor[key]}");
        }
      });
    }

    return combinedMarkers;
  }

  Set<Polygon> cachedPolygon = {};
  Set<Polygon> getCombinedPolygons() {
    if (cachedPolygon.isEmpty) {
      Set<Polygon> polygons = Set();

      closedpolygons.forEach((key, value) {
        polygons = polygons.union(value);
      });

      polygons.union(otherpatch);
      polygons.union(_polygon);

      // polygons.union(blurPatch);

      polygons.union(patch);
      cachedPolygon = polygons;
      return polygons;
    }
    return cachedPolygon.union(patch).union(otherpatch);
    // .union(blurPatch);
  }

  Set<gmap.Polyline> getCombinedPolylines() {
    Set<gmap.Polyline> poly = Set();

    // Existing logic to union polylines
    polylines.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });

    if (mapState.zoom > 20) {
      dottedPath.forEach((key, value) {
        poly = poly.union(value);
      });
    }

    interBuildingPath.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });

    // Conditional logic to add additional polylines

    buildingAllApi.allBuildingID.forEach((key, value) {
      if (singleroute[key] != null &&
          singleroute[key]![SingletonFunctionController.building.floor[key]] !=
              null) {
        poly = poly.union(singleroute[key]![
        SingletonFunctionController.building.floor[key]]!);
      }
    });

    buildingAllApi.allBuildingID.forEach((key, value) {
      if (pathCovered[key] != null &&
          pathCovered[key]![SingletonFunctionController.building.floor[key]] !=
              null) {
        poly = poly.union(pathCovered[key]![
        SingletonFunctionController.building.floor[key]]!);
      }
    });

    if (playPreviewManager != null) {
      buildingAllApi.allBuildingID.forEach((key, value) {
        if (playPreviewManager?.pathCovered[key] != null &&
            playPreviewManager?.pathCovered[key]![
            SingletonFunctionController.building.floor[key]] !=
                null) {
          //combinedMarkers = combinedMarkers.union(playPreviewManager!.previewMarker[key]![SingletonFunctionController.building.floor[key]]!);
          poly = poly.union(playPreviewManager!.pathCovered[key]![
          SingletonFunctionController.building.floor[key]]!);
        }
      });
    }

    return poly;
  }

  void _updateMarkers(double zoom) {
    print("zoomLevel $zoom");
    if (SingletonFunctionController.building.updateMarkers) {
      Set<Marker> updatedMarkers = Set();
      if (user.isnavigating) {
        setState(() {
          Markers.forEach((marker) {
            List<String> words = marker.markerId.value.split(' ');

            if (marker.markerId.value.contains("Room")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Rest")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Entry")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Building")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Lift")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (SingletonFunctionController.building.ignoredMarker
                .contains(words[1])) {
              if (marker.markerId.value.contains("Door")) {
                Marker _marker = customMarker.visibility(false, marker);

                updatedMarkers.add(_marker);
              }
              if (marker.markerId.value.contains("Room")) {
                Marker _marker = customMarker.visibility(false, marker);
                updatedMarkers.add(_marker);
              }
            }
          });
          Markers = updatedMarkers;
        });
      } else {
        setState(() {
          Markers.forEach((marker) {
            List<String> words = marker.markerId.value.split(' ');
            if (SingletonFunctionController.building.ignoredMarker
                .contains(words[1])) {
              if (marker.markerId.value.contains("Door")) {
                Marker _marker = customMarker.visibility(true, marker);
                updatedMarkers.add(_marker);
              }
              if (marker.markerId.value.contains("Room")) {
                Marker _marker = customMarker.visibility(false, marker);
                updatedMarkers.add(_marker);
              }
            } else if (marker.markerId.value.contains("toppriority")) {
              Marker _marker = customMarker.visibility(zoom > 16, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Room")) {
              Marker _marker = customMarker.visibility(zoom > 20.5, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Rest")) {
              Marker _marker = customMarker.visibility(zoom > 19, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Entry")) {
              Marker _marker = customMarker.visibility(
                  (zoom > 12.5 && zoom < 13) || zoom > 20.3, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Building")) {
              Marker _marker = customMarker.visibility(zoom < 16.0, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Lift")) {
              Marker _marker = customMarker.visibility(zoom > 19, marker);
              updatedMarkers.add(_marker);
            }
          });
          Markers = updatedMarkers;
        });
      }
    }
  }

  void hideMarkers() {
    SingletonFunctionController.building.updateMarkers = false;
    Set<Marker> updatedMarkers = Set();
    Markers.forEach((marker) {
      Marker _marker = customMarker.visibility(false, marker);
      updatedMarkers.add(_marker);
    });
    Markers = updatedMarkers;
  }

  void showMarkers() {
    SingletonFunctionController.building.ignoredMarker.clear();
    SingletonFunctionController.building.updateMarkers = true;
  }

  void _updateBuilding(double zoom) {
    Set<Polygon> updatedclosedPolygon = Set();
    Set<Polygon> updatedpatchPolygon = Set();
    Set<gmap.Polyline> updatedpolyline = Set();
    setState(() {
      closedpolygons[buildingAllApi.getStoredString()]?.forEach((polygon) {
        Polygon _polygon = polygon.copyWith(visibleParam: zoom > 16.0);
        updatedclosedPolygon.add(_polygon);
      });
      patch.forEach((polygon) {
        Polygon _polygon = polygon.copyWith(visibleParam: zoom > 16.0);
        updatedpatchPolygon.add(_polygon);
      });
      polylines[buildingAllApi.getStoredString()]!.forEach((polyline) {
        gmap.Polyline _polyline = polyline.copyWith(visibleParam: zoom > 16.0);
        updatedpolyline.add(_polyline);
      });
      closedpolygons[buildingAllApi.getStoredString()] = updatedclosedPolygon;
      patch = updatedpatchPolygon;
      polylines[buildingAllApi.getStoredString()] = updatedpolyline;
    });
  }

  void clearFocusTurnArrow() {
    setState(() {
      focusturnArrow.clear();
    });
  }

  String finalDestinationDirection = "";
  FocusNode _destination=FocusNode();
  void closeNavigation({bool force = false}) {
    if ((_isreroutePannelOpen || !user.isnavigating) && !force) {
      return;
    }
    SingletonFunctionController.building.landmarkdata!.then((value) async {
      print("SingletonFunctionController landmarks ${value.landmarks!.length}");
      List<Landmarks> createLandmarks = [];
      value.landmarks!.forEach((value){
        if(value.floor == SingletonFunctionController.building.floor[value.buildingID]){
          createLandmarks.add(value);
        }
      });
      land current = land();
      landmarkMarkers.clear();
      current.landmarks = createLandmarks;
      createMarkers(current, 0, buildingAllApi.selectedBuildingID,forced: true);
    });
    String destname = PathState.destinationName;
    _destination.requestFocus();
    //String destPolyyy=PathState.destinationPolyID;
    destiName = destname;
    List<int> tv = tools.eightcelltransition(user.theta);
    List<Cell> turnPoints = tools.getTurnpoints_inCell(user.cellPath);
    double angle = tools.calculateAngle2(
        [user.showcoordX, user.showcoordY],
        [user.showcoordX + tv[0], user.showcoordY + tv[1]],
        [PathState.destinationX, PathState.destinationY]);
    String direction = tools.angleToClocks4(angle, context);
    markNavigationSuccessful();
    currentNavigationLog = null;
    finalDestinationDirection = direction;
    //isSemanticEnabled? showDestinationDialog(context,user.convertTolng("You have reached ${destname}. It is ${direction}","", 0.0, context, angle, "", "",destname: destname)): ();
    flutterTts.pause().then((value) {
      speak(
          user.convertTolng("You have reached ${destname}. It is ${direction}",
              "", 0.0, context, angle, "", "",
              destname: destname),
          _currentLocale);
    });
    // if(isSemanticEnabled) {
    //   showFeedback = true;
    //   Future.delayed(Duration(seconds: 5));
    //   _feedbackController.open();
    //   _feedbackTextController.clear();
    //   feedbackPanel(context);
    //   //showDestinationDialog(context,user.convertTolng("You have reached ${destname}. It is ${direction}","", 0.0, context, angle, "", "",destname: destname));
    // }

    clearPathVariables();
    StopPDR();
    PathState.didPathStart = true;
    _isnavigationPannelOpen = false;
    user.temporaryExit = true;
    user.reset();
    PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
    selectedroomMarker.clear();
    pathMarkers.clear();
    PathState.path.clear();
    PathState.sourcePolyID = "";
    PathState.destinationPolyID = "";
    SingletonFunctionController.currentBeacon = "";
    singleroute.clear();
    pathCovered.clear();
    fitPolygonInScreen(patch.first);
    if (Platform.isIOS) {
      BluetoothScanIOSClass.stopScan();
    } else {
      bluetoothScanAndroidClass.stopScan();
    }
    Future.delayed(Duration.zero, () async {
      setState(() {
        focusturnArrow.clear();
      });
    });
    // setState(() {
    if (markers.length > 0){
      List<double> lvalue = tools.localtoglobal(
          user.showcoordX.toInt(),
          user.showcoordY.toInt(),
          SingletonFunctionController.building.patchData[user.bid]);
      markers[user.bid]?[0] = customMarker.move(
          LatLng(lvalue[0], lvalue[1]), markers[user.bid]![0]);
    }
    showFeedback = true;
    Future.delayed(Duration(seconds: 5));
    _announceDirection('You have arrived ${destname}. It is ${direction}');
    _feedbackController.open();
  }

  void onLandmarkVenueClicked(String ID,
      {bool DirectlyStartNavigation = false}) async {
    print("onLandmarkVenueClicked $ID ${StackTrace.current}");
    _polygon.clear();
    land snapshot = land();
    // Collect all API call futures
    List<Future<void>> apiCalls = [];
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) {
      apiCalls.add(RepositoryManager().getLandmarkDataNew(key).then((value) {
        snapshot.mergeLandmarks(value.landmarks);
        print("merged $key");
      }));
    });
    // Wait for all API calls to complete
    await Future.wait(apiCalls);
    land? localData = await SingletonFunctionController.building.landmarkdata;
    snapshot.mergeLandmarks(localData?.landmarks);
    _isBuildingPannelOpen = false;
    try {
      if (snapshot.landmarksMap![ID]!.floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            SingletonFunctionController
                .building
                .polylinedatamap[snapshot.landmarksMap![ID]!.buildingID!]!
                .polyline!
                .floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(snapshot.landmarksMap![ID]!.floor!),
            SingletonFunctionController
                .building
                .polylinedatamap[snapshot.landmarksMap![ID]!.buildingID!]!
                .polyline!
                .floors!);

        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
      }
    } catch (e) {
      print("error in onLandmarkVenueClicked $e");
    }
    List<int> value = [
      snapshot.landmarksMap![ID]!.coordinateX!,
      snapshot.landmarksMap![ID]!.coordinateY!
    ];
    List<double> coords = tools.localtoglobal(
        value[0],
        value[1],
        SingletonFunctionController
            .building.patchData[snapshot.landmarksMap![ID]!.buildingID]);
    int floor = snapshot.landmarksMap![ID]!.floor!;
    try {
      List<Nodes>? nodes = SingletonFunctionController
          .building
          .polylinedatamap[snapshot.landmarksMap![ID]!.buildingID]!
          .polyline!
          .floors!
          .firstWhere((element) =>
      element.floor == tools.numericalToAlphabetical(floor))
          .polyArray!
          .firstWhere((element) =>
      element.id == snapshot.landmarksMap![ID]!.properties!.polyId)
          .nodes;
      List<LatLng> corners = [];
      for (var element in nodes!) {
        List<double> value = [element.lat!, element.lon!];
        corners.add(LatLng(value[0], value[1]));
      }
      _polygon.add(Polygon(
        polygonId: PolygonId("$ID"),
        points: corners,
        fillColor: Colors.lightBlueAccent.withOpacity(0.4),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));
      cachedPolygon.clear();
    } catch (e) {
      print("error in onLandmarkVenueClicked $e");
    }
    outdoorBlockMarker.forEach((value){
      value.visible = false;
    });
    outDoorGlobalBlock.forEach((value){
      value.visible = false;
    });
    setState(() {});
    _googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(coords[0], coords[1]),
        22,
      ),
    );
    if (snapshot.landmarksMap![ID]!.buildingID != buildingAllApi.outdoorID &&
        SingletonFunctionController
            .building.floor[snapshot.landmarksMap![ID]!.buildingID] !=
            floor) {
      SingletonFunctionController
          .building.floor[snapshot.landmarksMap![ID]!.buildingID!] = floor;
      createRooms(
          SingletonFunctionController.building
              .polylinedatamap[snapshot.landmarksMap![ID]!.buildingID]!,
          floor);

      createMarkers(snapshot, floor, snapshot.landmarksMap![ID]!.buildingID!);
    }
    if (widget.directLandID.length > 2) {
      await Future.delayed(const Duration(milliseconds: 2000));
    }
    polygonTap(null, ID, 'assets/Generic Marker.png');
  }

  void fromSourceAndDestinationPage(List<String> value) {
    _isBuildingPannelOpen = false;
    markers.clear();
    SingletonFunctionController.building.landmarkdata!.then((land) {
      SingletonFunctionController.building.selectedLandmarkID =
      land.landmarksMap![value[1]]!.properties!.polyId!;
      PathState.sourceX = land.landmarksMap![value[0]]!.coordinateX!;
      PathState.sourceY = land.landmarksMap![value[0]]!.coordinateY!;
      PathState.sourceLat = double.parse(land.landmarksMap![value[0]]!.properties!.latitude!);
      PathState.sourceLng = double.parse(land.landmarksMap![value[0]]!.properties!.longitude!);
      if (land.landmarksMap![value[0]]!.doorX != null) {
        PathState.sourceX = land.landmarksMap![value[0]]!.doorX!;
        PathState.sourceY = land.landmarksMap![value[0]]!.doorY!;
        PathState.sourceLat = double.parse(land.landmarksMap![value[0]]!.properties?.doorLat??land.landmarksMap![value[0]]!.properties!.latitude!);
        PathState.sourceLng = double.parse(land.landmarksMap![value[0]]!.properties?.doorLng??land.landmarksMap![value[0]]!.properties!.longitude!);
      }
      PathState.sourceBid = land.landmarksMap![value[0]]!.buildingID!;
      tools.setBuildingAngle(SingletonFunctionController
          .building.patchData[PathState.sourceBid]!.patchData!.buildingAngle!);
      PathState.sourceFloor = land.landmarksMap![value[0]]!.floor!;
      PathState.sourcePolyID = value[0];
      PathState.sourceName = land.landmarksMap![value[0]]!.name!;
      PathState.destinationName = land.landmarksMap![value[1]]!.name!;
      PathState.destinationX = land.landmarksMap![value[1]]!.coordinateX!;
      PathState.destinationY = land.landmarksMap![value[1]]!.coordinateY!;
      if (land.landmarksMap![value[1]]!.doorX != null) {
        PathState.destinationX = land.landmarksMap![value[1]]!.doorX!;
        PathState.destinationY = land.landmarksMap![value[1]]!.doorY!;
      }
      PathState.destinationBid = land.landmarksMap![value[1]]!.buildingID!;
      PathState.destinationFloor = land.landmarksMap![value[1]]!.floor!;
      PathState.destinationPolyID = value[1];
      setState(() {
        calculatingPath = true;
        _isLandmarkPanelOpen = true;
      });
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        calculatingPath = false;
        calculateroute(land.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
      });
    });
  }

  void onSourceVenueClicked(String ID) {
    setState(() {
      SingletonFunctionController.building.landmarkdata!.then((value) {
        _isLandmarkPanelOpen = false;
        PathState.sourceX = value.landmarksMap![ID]!.coordinateX!;
        PathState.sourceY = value.landmarksMap![ID]!.coordinateY!;
        PathState.sourceLat = double.parse(value.landmarksMap![ID]!.properties!.latitude!);
        PathState.sourceLng = double.parse(value.landmarksMap![ID]!.properties!.longitude!);
        if (value.landmarksMap![ID]!.doorX != null) {
          PathState.sourceX = value.landmarksMap![ID]!.doorX!;
          PathState.sourceY = value.landmarksMap![ID]!.doorY!;
          PathState.sourceLat = double.parse(value.landmarksMap![ID]!.properties?.doorLat??value.landmarksMap![ID]!.properties!.latitude!);
          PathState.sourceLng = double.parse(value.landmarksMap![ID]!.properties?.doorLng??value.landmarksMap![ID]!.properties!.longitude!);
        }
        PathState.sourceFloor = value.landmarksMap![ID]!.floor!;
        PathState.sourcePolyID = ID;
        PathState.sourceName = user.key == ID
            ? "Your current location"
            : (value.landmarksMap![ID]!.renderDetail?.name??value.landmarksMap![ID]!.name!);
        PathState.sourceBid = value.landmarksMap![ID]!.buildingID!;
        PathState.path.clear();
        PathState.directions.clear();
        // PathState.sourceBid = user.Bid;
        // PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
        calculateroute(value.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
      });
    });
  }

  void onDestinationVenueClicked(String ID) {
    setState(() {
      SingletonFunctionController.building.landmarkdata!.then((value) {
        _isLandmarkPanelOpen = false;
        PathState.destinationX = value.landmarksMap![ID]!.coordinateX!;
        PathState.destinationY = value.landmarksMap![ID]!.coordinateY!;
        if (value.landmarksMap![ID]!.doorX != null) {
          PathState.destinationX = value.landmarksMap![ID]!.doorX!;
          PathState.destinationY = value.landmarksMap![ID]!.doorY!;
        }
        PathState.destinationFloor = value.landmarksMap![ID]!.floor!;
        PathState.destinationPolyID = ID;
        PathState.destinationName = value.landmarksMap![ID]!.name!;
        PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
        PathState.path.clear();
        PathState.directions.clear();
        // PathState.sourceBid = user.Bid;
        // PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
        calculateroute(value.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
      });
    });
  }

  focusOnTurn(direction turn) async {
    focusturnArrow.clear();
    if (turn.x != null && turn.y != null && turn.numCols != null) {
      int i = user.path.indexWhere((element) => element == turn.node);
      if (SingletonFunctionController
          .building.floor[buildingAllApi.getStoredString()] !=
          turn.floor) {
        i++;
      } else {
        i--;
      }
      final Uint8List greytorch =
      await getImagesFromMarker('assets/previewarrow.png', 25);
      if (turn.floor != null &&
          SingletonFunctionController
              .building.floor[buildingAllApi.getStoredString()] !=
              turn.floor) {
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()] = turn.floor!;
        createRooms(
            SingletonFunctionController
                .building.polylinedatamap[buildingAllApi.getStoredString()]!,
            SingletonFunctionController
                .building.floor[buildingAllApi.getStoredString()]!);
      }
      List<int> nextPoint = [
        user.path[i] % turn.numCols!,
        user.path[i] ~/ turn.numCols!
      ];
      List<double> latlng = tools.localtoglobal(turn.x!, turn.y!,
          SingletonFunctionController.building.patchData[turn.Bid]);
      List<double> latlng2 = tools.localtoglobal(nextPoint[0], nextPoint[1],
          SingletonFunctionController.building.patchData[turn.Bid]);
      setState(() {
        // focusturn.add(gmap.Polyline(
        //   polylineId: PolylineId("focusturn"),
        //   points: coordinates,
        //   color: Colors.blue,
        //   width: 5,
        // ));
        focusturnArrow.add(Marker(
            markerId: MarkerId("focusturn"),
            position: LatLng(latlng[0], latlng[1]),
            icon: BitmapDescriptor.fromBytes(greytorch),
            anchor: Offset(0.5, 0.5)));
      });
      mapState.target = LatLng(latlng[0], latlng[1]);
      mapState.bearing = tools
          .calculateBearing([latlng2[0], latlng2[1]], [latlng[0], latlng[1]]);
      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: mapState.target,
            zoom: mapState.zoom,
            bearing: mapState.bearing!,
            tilt: mapState.tilt),
      ));
    }
  }

  Timer? exploremodeLandmarkTimer;
  String closestBuildingId = "";
  String newBuildingID = "";
  void focusBuildingChecker(CameraPosition position) {
    LatLng currentLatLng = position.target;
    // String closestBuildingId = "";
    double? minDistance;
    Building.allBuildingID.forEach((key, value) {
      if (key != buildingAllApi.outdoorID) {
        num distance = geo.Geodesy().distanceBetweenTwoGeoPoints(
          geo.LatLng(value.latitude, value.longitude),
          geo.LatLng(currentLatLng.latitude, currentLatLng.longitude),
        );
        // Update closestBuildingId if this SingletonFunctionController.building is closer
        if (minDistance == null || distance < minDistance!) {
          minDistance = distance.toDouble();
          closestBuildingId = key;
        }
      }
    });
    if (newBuildingID != closestBuildingId) {
      //patchTransition(closestBuildingId);
    }
    newBuildingID = closestBuildingId;

    // Store the nearest SingletonFunctionController.building ID
    if (closestBuildingId.isNotEmpty) {
      buildingAllApi.setStoredString(closestBuildingId);
    }
  }

  Set<Circle> circles = Set();

  @override
  void dispose() {
    // stopContinuousGPSLocalisation();
    _messageTimer?.cancel();
    _landmarks.clear();
    gpsSubscription?.cancel(); // <-- This triggers native onCancel()
    gpsSubscription = null;
    wsocket.disconnect();
    _localizeTimer?.cancel();
    SingletonFunctionController.SC_LOCALIZED_BEACON = "";
    SingletonFunctionController.currentBeacon = "";
    disposed = true;
    fingerprinting.disableFingerprinting();
    SingletonFunctionController().dispose();
    UserState.geoLat = 0.0;
    UserState.geoLng = 0.0;
    flutterTts.stop();
    _controller12?.dispose();
    SingletonFunctionController.building.qrOpened = false;
    SingletonFunctionController.building.destinationQr = false;
    if(currentNavigationLog!=null){
      NavigationLogManager().syncLogsToServer().then((_){
        currentNavigationLog=null;
      });
    }
    magneticValues.clear();
    _moveController.dispose();
    _googleMapController.dispose();
    _subscription.cancel();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    flutterTts.cancelHandler;
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    bluetoothScanAndroidClass.stopScan();
    PB_controller.dispose(); // Dispose of the controller to free up resources
    for (var controller in _controllers) {
      controller.dispose();
    }
    accData.stopMagnetometer();
    magnetoData.stopAccelerometer();
    super.dispose();
  }

  List<String> scannedDevices = [];

  Set<gmap.Polyline> finalSet = {};

  bool ispdrStart = false;
  bool semanticShouldBeExcluded = false;
  bool isSemanticEnabled = false;
  bool isLocalized = false;

  IconData _mainIcon = Icons.volume_up_outlined;
  Color _mainColor = Colors.green;

  void recenterMap() {
    try {
      alignMapToPath([
        user.cellPath[user.pathobj.index].lat,
        user.cellPath[user.pathobj.index].lng
      ], [
        user.cellPath[user.pathobj.index + 1].lat,
        user.cellPath[user.pathobj.index + 1].lng
      ]);
      mapState.aligned = true;
    } catch (e) {}
  }

  Future<BitmapDescriptor> createBitmapDescriptorFromWidget(
      BuildContext context, Widget widget) async {
    final GlobalKey key = GlobalKey();
    // Wrap the widget in an Offstage widget to prevent it from being displayed on the screen
    final offstageWidget = Offstage(
      child: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(
          key: key,
          child: widget,
        ),
      ),
    );
    // Add the widget to the overlay for rendering off-screen
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry =
    OverlayEntry(builder: (context) => offstageWidget);
    overlayState.insert(overlayEntry);
    // Allow some time for the widget to render
    await Future.delayed(Duration(milliseconds: 10000));
    // Capture the widget as an image
    final RenderRepaintBoundary boundary =
    key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    // Remove the widget from the overlay
    overlayEntry.remove();
    return BitmapDescriptor.fromBytes(pngBytes);
  }

  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort(
              (a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }

  late Timer EM_TIMER;
  String EM_LastBeacon = "";

  Future<bool> _handleBackPress() async {
    if (_isLandmarkPanelOpen) {
      setState(() {
        _polygon.clear();
        cachedPolygon.clear();
        //  circles.clear();
        showMarkers();
        toggleLandmarkPanel();
        _isBuildingPannelOpen = true;
        _isLandmarkPanelOpen = false;
      });
      return false;
    }
    if (_isRoutePanelOpen) {
      setState(() {
        SingletonFunctionController.building.landmarkdata!.then((value) {
          createMarkers(value, SingletonFunctionController.building.floor[buildingAllApi.getStoredString()]??0, user.bid);
        });
        PlayPreviewManager().clearPreview();
        _isRoutePanelOpen = false;
        _isLandmarkPanelOpen = true;
        showMarkers();
        List<double> mvalues = tools.localtoglobal(
            PathState.destinationX,
            PathState.destinationY,
            SingletonFunctionController
                .building.patchData[PathState.destinationBid]);
        _googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(mvalues[0], mvalues[1]),
            20, // Specify your custom zoom level here
          ),
        );
        PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
        PathState.path.clear();
        PathState.sourcePolyID = "";
        PathState.destinationPolyID = "";
        singleroute.clear();
        //realWorldPath.clear();
        _isBuildingPannelOpen = true;
        if (user.isnavigating == false) {
          clearPathVariables();
        }
        Marker? temp =
            selectedroomMarker[buildingAllApi.getStoredString()]?.first;
        selectedroomMarker.clear();
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(temp!);
        pathMarkers.clear();
      });
      return false;
    }
    if (_isnavigationPannelOpen) {
      setState(() {
        _isnavigationPannelOpen = false;
        _isRoutePanelOpen = true;
        initializeMarkers();
        StopPDR();
        onStart = false;
        startingNavigation = true;
        PathState.sourceX = user.coordX;
        PathState.sourceY = user.coordY;
        PathState.sourceFloor = user.floor;
        PathState.sourceBid = user.bid;
        PathState.sourceLat = user.lat;
        PathState.sourceLng = user.lng;
        PathState.sourceName = "Your current location";
        user.temporaryExit = true;
        user.isnavigating = false;
        markNavigationUnsuccessful("User Exited Navigation");
        if (pathMarkers[user.bid] != null) {
          setCameraPosition(pathMarkers[user.bid]![
          SingletonFunctionController.building.floor[user.bid]]!);
          List<LatLng> ll = [
            pathMarkers[user.bid]![
            SingletonFunctionController.building.floor[user.bid]]!
                .first
                .position,
            pathMarkers[user.bid]![
            SingletonFunctionController.building.floor[user.bid]]!
                .last
                .position
          ];
          fitTwoPoints(ll);
        }
      });
      return false;
    }
    Navigator.pop(context);
    print("got here");
    // All panels closed, allow screen pop
    return false;
  }

  Timer? _localizeTimer;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    isSemanticEnabled = MediaQuery.of(context).accessibleNavigation;
    HelperClass.SemanticEnabled = MediaQuery.of(context).accessibleNavigation;
    bool mapLoading = (SingletonFunctionController.building.buildingsLoaded || SingletonFunctionController.building.destinationQr || SingletonFunctionController.building.qrOpened || PinLandmarkPannel.isPanelOpened()) && initialInAppLoading;
    return Lowfedility.LFDesign?Homepage(key: Homepage.homePageKey):
    PopScope(
      canPop:(Platform.isIOS)?true:false,
      onPopInvoked:(didpop) async {
        print(StackTrace.current);
        if(Platform.isAndroid) {
          print("didpop:${didpop}");
          if(didpop==false){
            bool res=await _handleBackPress();
            if(res==true){
              Navigator.pop(context);
            }
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            detected
                ? Semantics(excludeSemantics: true, child: ExploreModePannel())
                : Semantics(excludeSemantics: true, child: Container()),
            Semantics(
              excludeSemantics: true,
              child: Container(
                child: GoogleMap(
                  padding: EdgeInsets.only(left: 20), // <--- padding added here
                  initialCameraPosition: _initialCameraPosition,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  mapToolbarEnabled: false,
                  polygons: getCombinedPolygons().union(_polygon).union(globalCampus).union(allGlobalBlocks).union(outDoorGlobalBlock).union(blurPatchCampus),
                  polylines: getCombinedPolylines(),
                  markers: getCombinedMarkers()
                      .union(_markers)
                  // .union(blurPatchMarker)
                      .union(outdoorBlockMarker)
                      .union(focusturnArrow).union(blockMarker)
                      .union(Markers).union(roomNameMarkers).union(blurPatchCampusMarker)
                      .union(debugMarker)
                      .union(GpsMarker).union(nearbyLandmarks.values.toSet()).union(_exploreModeMarker)
                      .union(_exploreModeDebugBeaconMarker).union(fingerprinting.getMarkers()).union(landmarkMarkers),
                  buildingsEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: true,
                  minMaxZoomPreference: MinMaxZoomPreference(2, 30),
                  onMapCreated: (controller){
                    controller.setMapStyle(maptheme);
                    _googleMapController = controller;
                    playPreviewManager = PlayPreviewManager();
                    //zoomWhileWait(buildingAllApi.allBuildingID, controller);
                    mapClustering.initMarkers().then((value){
                      landmarkMarkers = mapClustering.recalculateClusters(_lastZoom,mapState.bearing);
                    });
                    // _initMarkers();
                  },
                  onCameraMove: (CameraPosition cameraPosition) {
                    mapState.cameraposition = cameraPosition; // User has started panning
                    playPreviewManager?.cameraPosition = cameraPosition;
                    if (cameraPosition.zoom < 19) {
                      MGMarkers.forEach((_element) {
                        _element.visible = false;
                      });
                    } else {
                      MGMarkers.forEach((_element) {
                        _element.visible = true;
                      });
                    }

                    if (cameraPosition.zoom <= 16) {

                      // blurPatch.forEach((polygon) {
                      //   polygon.visible = false;
                      // });
                      // blurPatchMarker.forEach((marker) {
                      //   marker.visible = false;
                      // });

                      // outDoorGlobalBlock.forEach((polygon) {
                      //   polygon.visible = false;
                      // });
                      // outdoorBlockMarker.forEach((marker) {
                      //   marker.visible = false;
                      // });

                      blurPatchCampus.forEach((polygon) {
                        polygon.visible = true;
                      });
                      blurPatchCampusMarker.forEach((marker) {
                        marker.visible = true;
                      });
                      outDoorGlobalBlock.forEach((polygon) {
                        polygon.visible = false;
                      });
                      outdoorBlockMarker.forEach((marker) {
                        marker.visible = false;
                      });
                      setState(() {});
                    } else if (cameraPosition.zoom > 14.8 &&
                        cameraPosition.zoom < 18) {
                      blurPatchCampus.forEach((polygon) {
                        polygon.visible = false;
                      });
                      blurPatchCampusMarker.forEach((marker) {
                        marker.visible = false;
                      });

                      // blurPatch.forEach((polygon) {
                      //   polygon.visible = true;
                      // });
                      // blurPatchMarker.forEach((marker) {
                      //   marker.visible = true;
                      // });
                      outDoorGlobalBlock.forEach((polygon) {
                        polygon.visible = true;
                      });
                      outdoorBlockMarker.forEach((marker) {
                        marker.visible = true;
                      });
                      setState(() {});
                    } else if (cameraPosition.zoom >= 18) {
                      // print("cameraposition ${cameraPosition.zoom}");

                      // blurPatch.forEach((polygon) {
                      //   polygon.visible = false;
                      // });
                      // blurPatchMarker.forEach((marker) {
                      //   marker.visible = false;
                      // });

                      blurPatchCampus.forEach((polygon) {
                        polygon.visible = false;
                      });
                      blurPatchCampusMarker.forEach((marker) {
                        marker.visible = false;
                      });
                      outDoorGlobalBlock.forEach((polygon) {
                        polygon.visible = false;
                      });
                      outdoorBlockMarker.forEach((marker) {
                        marker.visible = false;
                      });

                      if (cameraPosition.zoom < 19) {
                        // print("cameraposition ${cameraPosition.zoom}");
                        // ✅ Show outdoor blocks when zoom < 19
                        outDoorGlobalBlock.forEach((polygon) {
                          polygon.visible = true;
                        });
                        outdoorBlockMarker.forEach((marker) {
                          marker.visible = true;
                        });
                        setState(() {});
                      } else {
                        // print("cameraposition ${cameraPosition.zoom}");
                        // Hide outdoor blocks when zoom >= 19
                        outDoorGlobalBlock.forEach((polygon) {
                          polygon.visible = false;
                        });
                        outdoorBlockMarker.forEach((marker) {
                          marker.visible = false;
                        });
                        setState(() {});
                        // blurPatch.forEach((polygon) {
                        //   polygon.visible = false;
                        // });
                        // blurPatchMarker.forEach((marker) {
                        //   marker.visible = false;
                        // });

                        blurPatchCampus.forEach((polygon) {
                          polygon.visible = false;
                        });
                        blurPatchCampusMarker.forEach((marker) {
                          marker.visible = false;
                        });
                        setState(() {});
                      }
                      setState(() {});
                    }
                    mapState.zoom = cameraPosition.zoom;
                    //Check zoom level and decide rendering strategy
                    if (cameraPosition.zoom > 16.8) {
                      focusBuildingChecker(cameraPosition);
                    } else if (cameraPosition.zoom > 15.5) {
                    } else {
                      //renderCampusPatchTransition([buildingAllApi.outdoorID]);
                    }
                    // print("cameraPosition.zoom ${cameraPosition.zoom}");
                    // if(cameraPosition.zoom <20.5){
                    //   // doorMarkers.forEach((_element){
                    //   //   _element.visible = false;
                    //   // });
                    //   roomNameMarkers.forEach((_element){
                    //     _element.visible = false;
                    //   });
                    // }else{
                    //   // doorMarkers.forEach((_element) {
                    //   //   _element.visible = true;
                    //   // });
                    //   roomNameMarkers.forEach((_element) {
                    //     _element.visible = true;
                    //   });
                    // }
                    // Update map alignment based on camera position
                    mapState.aligned = cameraPosition.target.latitude
                        .toStringAsFixed(5) ==
                        mapState.target.latitude.toStringAsFixed(5);

                    mapState.interaction =
                    true; // Interaction has occurred
                    mapState.bearing = cameraPosition.bearing;
                    mapbearing = cameraPosition.bearing;

                    // Sync zoom level only when there’s no active interaction
                    if (!mapState.interaction) {
                      mapState.zoom = cameraPosition.zoom;
                    }
                    // isLiveLocalizing? () : _updateMarkers(cameraPosition.zoom);
                    //_updateBuilding(cameraPosition.zoom);
                    // _updateMarkers(cameraPosition.zoom);
                    if (cameraPosition.zoom < 17) {
                      _markers.clear();
                      markerSldShown = false;
                    } else {
                      markerSldShown = true;
                    }

                    if (PathState.Cellpath.isEmpty && cameraPosition.zoom < 19 &&
                        cameraPosition.zoom > 17) {
                      // print("cameraPosition.zoom${cameraPosition.zoom}");
                      allGlobalBlocks.addAll(globalBlock);
                      blockMarker.forEach((val) {
                        val.visible = true;
                      });
                    } else {
                      blockMarker.forEach((val) {
                        val.visible = false;
                      });
                      allGlobalBlocks.clear();
                    }

                    // print("user.isnavigating ${user.isnavigating}");
                    if (cameraPosition.zoom > 19 && !user.isnavigating) {
                      clustringOFF = false;
                      // landmarkMarkers
                      //     .where((m) => !m.markerId.value.toLowerCase().contains("main entry"))
                      //     .forEach((m) => m.visible = false);

                    } else if( user.isnavigating){
                      // clustringOFF = true;
                      // print("cameraPosition.zoom < 19 ${cameraPosition.zoom}");
                      if(cameraPosition.zoom > 19){
                        landmarkMarkers.forEach((value){
                          if(!value.markerId.value.toLowerCase().contains("main entry")){
                            value.visible = false;
                          }else{
                            value.visible = true;
                          }
                        });
                      }else{
                        landmarkMarkers.forEach((value){
                          value.visible = false;
                        });
                      }

                    } else {
                      // print("Clustring will be off");
                      // clustringOFF = true;
                      // landmarkMarkers.forEach((value){
                      //   value.visible = false;
                      // });
                    }

                    if ((cameraPosition.zoom - _lastZoom).abs() > 0.2) {
                      _lastZoom = cameraPosition.zoom;
                      print("Clustring is ${clustringOFF}");
                      if (cameraPosition.zoom < 19 ) {
                        // landmarkMarkers.clear();
                        landmarkMarkers.forEach((value) {
                          value.visible = false;
                        });
                        setState(() {});

                      } else {
                        landmarkMarkers = mapClustering.recalculateClusters(_lastZoom, mapState.bearing);
                        setState(() {});
                        landmarkMarkers.forEach((value) {
                          if (selectedMarkerId.isNotEmpty) {
                            if (value.markerId
                                .toString()
                                .contains(selectedMarkerId)) {
                              value.visible = false;
                            } else {
                              value.visible = true;
                            }
                          }
                        });
                      }
                    }
                  },
                  onCameraIdle: () {
                    print("PinLandmarkPannel.isPanelOpened() ${PinLandmarkPannel.isPanelOpened()}");
                    if(PinLandmarkPannel.isPanelOpened()){
                      selectPinLandmark(mapState.cameraposition!);
                    }
                    // setState(() {
                    //   landmarkMarkers = outdoorBlockMarkersset;
                    // });

                    Set<Marker> updatedMarkers =
                    landmarkMarkers.where((marker) {
                      String markerId = marker.markerId.value;
                      String polyId =
                          markerId.split("polyId-").last.split(" ").first;

                      return polygonCalculation
                          .landmarkWithLatLng[polyId] !=
                          null && marker.flat;
                    }).map((marker) {
                      String markerId = marker.markerId.value;
                      String polyId =
                          markerId.split("polyId-").last.split(" ").first;
                      List<LatLng> points = polygonCalculation.landmarkWithLatLng[polyId]!;
                      List<LatLng> calculatedPoints = points;

                      int leftMost = LeftMost().leftMostPoint(
                        PointForCenter(calculatedPoints[0].latitude,
                            calculatedPoints[0].longitude, "name"),
                        PointForCenter(calculatedPoints[1].latitude,
                            calculatedPoints[1].longitude, "name1"),
                        mapState.bearing,
                      );

                      double rotation;
                      if (leftMost == -1) {
                        rotation = polygonCalculation.calculateBearing(
                            calculatedPoints[0], calculatedPoints[1]);
                      } else {
                        rotation = polygonCalculation.calculateBearing(
                            calculatedPoints[1], calculatedPoints[0]);
                      }

                      if(polygonCalculation.landmarkWithPolygonPoints[polyId] != null){
                        final result = findBestFitRectangleBearing(polygonCalculation.landmarkWithPolygonPoints[polyId]!);
                        rotation = result.bearing;
                        int leftMost = LeftMost().leftMostPoint(
                          PointForCenter(result.longestSide[0].latitude,
                              result.longestSide[0].longitude, "name"),
                          PointForCenter(result.longestSide[1].latitude,
                              result.longestSide[1].longitude, "name1"),
                          mapState.bearing,
                        );
                        if(leftMost == -1){
                          rotation -= 180;
                          if(rotation < 0){
                            rotation += 360;
                          }
                        }
                        // print('Longest axis bearing: ${rotation.toStringAsFixed(2)}°');
                      }

                      // print("marker.markerId.toString() ${marker.markerId.toString()} $leftMost $rotation");
                      return marker.copyWith(rotationParam: rotation);
                    }).toSet();
                    landmarkMarkers.removeWhere((marker)=>updatedMarkers.where((newMarker)=>newMarker.markerId == marker.markerId).isNotEmpty);
                    setState(() {
                      landmarkMarkers = landmarkMarkers.union(updatedMarkers);
                    });

                    if (!mapState.interaction) {
                      mapState.interaction2 = true;
                    }
                  },
                  onCameraMoveStarted: () {
                    user.building = SingletonFunctionController.building;
                    mapState.interaction2 = false;
                  },
                  circles: circles,
                ),
              ),
            ),
            //debug----

            DebugToggle.PDRIcon
                ? Positioned(
                top: 150,
                right: 50,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                    color: (isPdr) ? Colors.green : Colors.red,
                  ),
                  height: 20,
                  width: 20,
                ))
                : Container(),

            Positioned(
              bottom: isLiveLocalizing
                  ? screenHeight * 0.6
                  : 150.0, // Adjust the position as needed
              right: 16.0,
              child: Semantics(
                excludeSemantics: false,
                child: Column(
                  children: [
                    isSemanticEnabled || PinLandmarkPannel.isPanelOpened() || !_isnavigationPannelOpen
                        ? Container()
                        : SpeedDial(
                      icon: _mainIcon,
                      foregroundColor: _mainColor,
                      backgroundColor: Colors.white,
                      visible: true,
                      curve: Curves.bounceInOut,
                      children: [
                        SpeedDialChild(
                          child: Icon(Icons.volume_up_outlined,
                              color: Colors.white),
                          backgroundColor: Colors.green,
                          label: "All instructions", // full TTS
                          labelStyle: TextStyle(fontSize: 14.0),
                          onTap: () {
                            setState(() {
                              _mainIcon = Icons.volume_up_outlined;
                              _mainColor = Colors.green;
                            });
                            UserState.ttsAllStop = false;
                            UserState.ttsOnlyTurns = false;
                          },
                        ),
                        SpeedDialChild(
                          child: Icon(Icons.volume_down_outlined,
                              color: Colors.black),
                          backgroundColor: Colors.blueAccent,
                          label: "Only turns", // partial TTS
                          labelStyle: TextStyle(fontSize: 14.0),
                          onTap: () {
                            setState(() {
                              _mainIcon =
                                  Icons.volume_down_outlined;
                              _mainColor = Colors.blueAccent;
                            });
                            UserState.ttsOnlyTurns = true;
                            UserState.ttsAllStop = false;
                          },
                        ),
                        SpeedDialChild(
                          child: Icon(Icons.volume_off_outlined,
                              color: Colors.white),
                          backgroundColor: Colors.red,
                          label: "Mute all", // no TTS
                          labelStyle: TextStyle(fontSize: 14.0),
                          onTap: () {
                            setState(() {
                              _mainIcon = Icons.volume_off_outlined;
                              _mainColor = Colors.red;
                            });
                            UserState.ttsAllStop = true;
                            UserState.ttsOnlyTurns = false;
                          },
                        ),
                      ],
                    ),
                    Visibility(
                      visible: DebugToggle.StepButton,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.all(Radius.circular(24))),
                          child: IconButton(
                              onPressed: () {
                                //StartPDR();
                                bool isvalid = MotionModel.isValidStep(
                                    user,
                                    SingletonFunctionController
                                        .building.floorDimenssion[
                                    user.bid]![user.floor]![0],
                                    SingletonFunctionController
                                        .building.floorDimenssion[
                                    user.bid]![user.floor]![1],
                                    SingletonFunctionController
                                        .building.nonWalkable[
                                    user.bid]![user.floor]!,
                                    reroute,
                                    context);
                                if (isvalid) {
                                  user.move(context).then((value) {
                                    print("renderedddd here");
                                    renderHere();
                                  });
                                } else {
                                  if (user.isnavigating) {
                                    // reroute();
                                    // showToast("You are out of path");
                                  }
                                }
                              },
                              icon: Icon(Icons.directions_walk))),
                    ),
                    SizedBox(height: 28.0),
                    DebugToggle.Slider
                        ? Text("${user.theta}")
                        : Container(),
                    // if(_currentPoint!=null)Text("${_currentPoint!} ${_currentPoint!}"),
                    // Text("coord [${user.coordX},${user.coordY}] \n"
                    //     "showcoord [${user.showcoordX},${user.showcoordY}] \n"
                    //     "next coord [${user.pathobj.index+1<user.cellPath.length?user.cellPath[user.pathobj.index+1].x:0},${user.pathobj.index+1<user.cellPath.length?user.cellPath[user.pathobj.index+1].y:0}]\n"
                    // // "next bid ${user.pathobj.index+1<user.Cellpath.length?user.Cellpath[user.pathobj.index+1].bid:0} \n"
                    //     "floor ${user.floor}\n"
                    //     "userBid ${user.bid} \n"
                    //     "stepSize ${UserState.stepSize}\n"
                    //     "index ${user.pathobj.index} \n"
                    //     "theta ${user.theta} \n"
                    //     "theta ${tools.AngleBetweenBuildingandGlobalNorth} \n"
                    //     "node ${user.path.isNotEmpty ? user.path[user.pathobj.index] : ""}"),
                    DebugToggle.Slider
                        ? Slider(
                        value: user.theta,
                        min: -180,
                        max: 180,
                        onChanged: (newvalue) {
                          double? compassHeading = newvalue;
                          setState(() {
                            user.theta = compassHeading!;
                            if (mapState.interaction2) {
                              mapState.bearing = compassHeading!;
                              _googleMapController.moveCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: mapState.target,
                                    zoom: mapState.zoom,
                                    bearing: mapState.bearing!,
                                  ),
                                ),
                                //duration: Duration(milliseconds: 500), // Adjust the duration here (e.g., 500 milliseconds for a faster animation)
                              );
                            } else {
                              if (markers.length > 0)
                                markers[user.bid]?[0] =
                                    customMarker.rotate(
                                        compassHeading! - mapbearing,
                                        markers[user.bid]![0]);
                            }
                          });
                        })
                        : Container(),
                    !isLiveLocalizing? !isSemanticEnabled && !PinLandmarkPannel.isPanelOpened() && (playPreviewManager != null ? !playPreviewManager!.isPlaying : true)
                        ? Semantics(
                      label: "Change floor",
                      child: SpeedDial(
                        activeIcon: Icons.close,
                        backgroundColor: Colors.white,
                        children: List.generate(
                          (Building.numberOfFloorsDelhi[
                          buildingAllApi
                              .getStoredString()] ??
                              [0])
                              .length,
                              (int i) {
                            //
                            List<int> floorList = Building
                                .numberOfFloorsDelhi[
                            buildingAllApi
                                .getStoredString()] ??
                                [0];
                            List<int> revfloorList = floorList;
                            revfloorList.sort();
                            return SpeedDialChild(
                              // labelWidget: (i == 0 || i == 2)
                              //     ? Padding(
                              //         padding:
                              //             const EdgeInsets.only(
                              //                 right: 8.0),
                              //         child: Container(
                              //           height: 35,
                              //           decoration:
                              //               BoxDecoration(
                              //             color:
                              //                 Color(0xff011b33),
                              //             borderRadius:
                              //                 BorderRadius.circular(
                              //                     8), // Optional: rounded corners
                              //           ),
                              //           padding: const EdgeInsets
                              //               .all(
                              //               8.0), // Optional: padding inside the container
                              //           child: Image.asset(
                              //             'assets/logo.png',
                              //             width: 80,
                              //             height: 80,
                              //           ),
                              //         ),
                              //       )
                              //     : null,
                              // label: (i==0 || i==2)?'Empower':null ,
                              child: Semantics(
                                label: "${revfloorList[i]}",
                                child: Text(
                                  revfloorList[i] == 0
                                      ? 'G'
                                      : '${revfloorList[i]}',
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 19 / 16,
                                  ),
                                ),
                              ),
                              backgroundColor: (SingletonFunctionController
                                  .building
                                  .floor[
                              buildingAllApi
                                  .getStoredString()] ==
                                  revfloorList[i] ||
                                  PathState.destinationFloor !=
                                      null &&
                                      PathState
                                          .destinationFloor ==
                                          revfloorList[
                                          i])
                                  ? Colors.blue[400]
                                  : Colors.white,

                              onTap: () {
                                currentSelectedFloor = revfloorList[i];
                                print(
                                    "floor selected:${revfloorList[i]} , ${SingletonFunctionController.building.floor}");
                                _polygon.clear();
                                cachedPolygon.clear();
                                circles.clear();
                                _markers.clear();
                                if(PathState.singleCellListPath.isNotEmpty){
                                  List<String> intermediatesBids = tools.findIntermediateBuildings(PathState.singleCellListPath);
                                  setBuildingFloors([...intermediatesBids, buildingAllApi.getStoredString()], floor: revfloorList[i]);
                                }else{
                                  SingletonFunctionController
                                      .building.floor[
                                  buildingAllApi
                                      .getStoredString()] =
                                  revfloorList[i];
                                  print("SingletonFunctionController.building.floor${SingletonFunctionController
                                      .building.floor[
                                  buildingAllApi
                                      .getStoredString()]}");
                                  createRooms(
                                    SingletonFunctionController
                                        .building
                                        .polylinedatamap[
                                    buildingAllApi
                                        .getStoredString()]!,
                                    SingletonFunctionController
                                        .building.floor[
                                    buildingAllApi
                                        .getStoredString()]!,
                                  );
                                }
                                if (pathMarkers[i] !=
                                    null) {
                                  //setCameraPosition(pathMarkers[i]!);
                                }
                                // Markers.clear();
                                SingletonFunctionController
                                    .building
                                    .landmarkdata!
                                    .then((value) {
                                  createMarkers(
                                      value,
                                      SingletonFunctionController
                                          .building
                                          .floor[
                                      buildingAllApi
                                          .getStoredString()]!,
                                      buildingAllApi
                                          .getStoredString());
                                });
                                fitPathPoints(floor: revfloorList[i]);
                              },
                            );
                          },
                        ),
                        child: Text(
                          SingletonFunctionController
                              .building.floor[
                          buildingAllApi
                              .getStoredString()] ==
                              0
                              ? 'G'
                              : '${SingletonFunctionController.building.floor[buildingAllApi.getStoredString()]}',
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff24b9b0),
                            height: 19 / 16,
                          ),
                        ),
                      ),
                    )
                        : nofloorColumn()
                        : Container(),
                    SizedBox(height: 28.0), // Adjust the height as needed
                    // Container(
                    //   width: 300,
                    //   height: 100,
                    //   child: SingleChildScrollView(
                    //     scrollDirection: Axis.horizontal,
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(testBIn.keys.toString()),
                    //         Text(testBIn.values.toString()),
                    //         Text("summap"),
                    //         Text(sortedsumMapfordebug.toString()),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    !isLiveLocalizing? isSemanticEnabled || _isRoutePanelOpen || isSemanticEnabled && _isLandmarkPanelOpen || PinLandmarkPannel.isPanelOpened()
                        ? Container()
                        : Semantics(
                      child: FloatingActionButton(
                        onPressed: () async {
                          InteractionManager().logInteraction("Relocalization Button");
                          debugMarker.clear();
                          if (!user.isnavigating) {
                            // if (false) {
                            //   setState(() {
                            //     isFromLocalize = true;
                            //   });
                            //   // _localizeTimer=Timer.periodic(Duration(seconds: 5), (_){
                            //   print(
                            //       "SingletonFunctionController.currentBeacon:${SingletonFunctionController.currentBeacon}");
                            //   if (SingletonFunctionController
                            //       .currentBeacon!.isEmpty){
                            //     _localizeTimer!.cancel();
                            //   }
                            //   paintUser(
                            //       SingletonFunctionController
                            //           .currentBeacon,
                            //       null,
                            //       render: true,
                            //       speakTTS: true,
                            //       providePinSelection: false);
                            // } else {
                            if(isLocalized)return;
                            setState((){
                              isLocalized = true;
                            });
                            gpsSubscription = GPSService.locationStream.listen((Location location) {
                              gpsBuffer.add(location.latitude, location.longitude);
                            }, onError: (error){
                              print("Error receiving GPS data: $error");
                            });
                            if(Platform.isAndroid){
                              bleManager.startScanning(
                                  bufferSize: 5,
                                  streamFrequency: 5,
                                  duration: 5);
                            }else{
                              BluetoothScanIOSClass.startScan();
                            }
                            late Timer _timer;
                            _timer = Timer.periodic(
                                Duration(milliseconds: 5000),
                                    (timer) {
                                  localizeUser().then((value) => {
                                    setState(() {
                                      isLocalized = false;
                                    })
                                  });
                                  _timer.cancel();
                                });
                            // }
                          } else {
                            recenterMap();
                          }
                        },
                        child: Semantics(
                          label: !user.isnavigating
                              ? "Localize"
                              : "Recenter Map",
                          onDidGainAccessibilityFocus:
                          close_isnavigationPannelOpen,
                          child: (isLocalized)
                              ? lott.Lottie.asset(
                            'assets/localized.json', // Path to your Lottie animation
                            width: 70,
                            height: 70,
                          )
                              : Icon(
                              (!user.isnavigating)
                                  ? (user.coordX == 0.0 && user.coordY == 0.0)?Icons.my_location_sharp:Icons.my_location_sharp
                                  : (mapState.aligned
                                  ? CupertinoIcons
                                  .location_north_fill
                                  : CupertinoIcons
                                  .location_north),
                              color: (!user.isnavigating)
                                  ? (user.coordX == 0.0 && user.coordY == 0.0)?Colors.white:Colors.blue
                                  : Colors.blue),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              26.0), // Change radius here
                        ),
                        backgroundColor: (user.coordX == 0.0 && user.coordY == 0.0)?Colors.red:Colors.white, // Set the background color of the FAB
                      ),
                    ):Container(),
                    // SizedBox(
                    //   height: 30,
                    // ), // Adjust the height as needed// Adjust the height as needed
                    // FloatingActionButton(onPressed: (){
                    //   print("current landmark length ${_landmarks.length}");
                    //   print("current landmark length ${landmarkMarkers.length}");
                    //   _landmarks.forEach((val){
                    //     print("val print${val.name}");
                    //   });
                    //   landmarkMarkers.forEach((val){
                    //     print("val print${val.markerId}");
                    //   });
                    //
                    //   setState(() {
                    //
                    //   });
                    // },child: Icon(Icons.add_location_alt),),
                    // FloatingActionButton(onPressed: (){
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => LoggingScreen(
                    //         logging: bluetoothScanAndroidClass.logging,
                    //         loggingTaps: bluetoothScanAndroidClass.loggingTaps,
                    //       ),
                    //     ),
                    //   );
                    // },child: Icon(Icons.bluetooth_audio),)
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Stack(
                children:[
                  !isLiveLocalizing? Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _isLandmarkPanelOpen ||
                          _isRoutePanelOpen ||
                          _isnavigationPannelOpen || PinLandmarkPannel.isPanelOpened() || mapLoading
                          ? Semantics(excludeSemantics: true, child: Container())
                          : FocusScope(
                        autofocus: true,
                        child: Focus(
                          child: Semantics(
                            sortKey: const OrdinalSortKey(0), // header: true,
                            child:HomepageSearch(
                              onVenueClicked: onLandmarkVenueClicked,
                              fromSourceAndDestinationPage:
                              fromSourceAndDestinationPage,
                              user: user,
                            ),
                          ),
                        ),
                      )) : Container()] ,
              ),
            ),
            FutureBuilder(
              future: SingletonFunctionController.building.landmarkdata,
              builder: (context, snapshot) {
                if (_isLandmarkPanelOpen) {
                  return SafeArea(
                      child: landmarkdetailpannel(context, snapshot));
                } else {
                  return Semantics(
                      excludeSemantics: true, child: Container());
                }
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: routeDeatilPannel(),
            ),
            SafeArea(child: feedbackPanel(context)),
            navigationPannel(),
            SafeArea(child: reroutePannel(context)),
            SafeArea(child: ExploreModePannel()),
            SafeArea(child: PinLandmarkPannel.getPanelWidget(context,updateNearbyLandmarkMarkers, localizeOnPinedLandmark, closePinnedLandmarkPannel, nearbyLandmarks,PinedLandmark)),
            detected
                ? Semantics(
                child: SafeArea(child: nearestLandmarkpannel()))
                : Container(),
            SizedBox(height: 28.0), // Adjust the height as needed

            mapLoading? Container(
              height: screenHeight,
              width: screenWidth,
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: LoadingAnimationWidget.progressiveDots(
                    color: Colors.teal,
                    size: 50
                ),
              ),
            ) : Container(
              height: 0, width: 0,),

            // Container(
            //   height: screenHeight,
            //   width: screenWidth,
            //   color: Colors.white.withOpacity(0.8),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       lott.Lottie.asset(
            //         'assets/loding_animation.json', // Path to your Lottie animation
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 56, right: 56),
            //         child: LinearProgressIndicator(
            //           value: _progressValue,
            //           backgroundColor: Colors.grey,
            //           valueColor:
            //           AlwaysStoppedAnimation<Color>(Colors.red),
            //           borderRadius: BorderRadius.all(Radius.circular(10)),
            //         ),
            //       )
            //     ],
            //   ),
            // ),

            ExcludeSemantics(
                child: Visibility(
                    visible: nearbyLandmarks.isNotEmpty,
                    child: Center(child: PickupLocationPin())))
          ],
        ),
      ),
    );
  }




//
// int d=0;
// bool listenToBin(){
//   double highestweight = 0;
//   String nearestBeacon = "";
//   Map<String, double> sumMap = SingletonFunctionController.btadapter.calculateAverage();
//
//
//
//  // widget.direction = "";
//
//
//   for (int i = 0; i < SingletonFunctionController.btadapter.BIN.length; i++) {
//     if(SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty){
//       SingletonFunctionController.btadapter.BIN[i]!.forEach((key, value) {
//         key = "";
//         value = 0.0;
//       });
//     }
//   }
//   SingletonFunctionController.btadapter.numberOfSample.clear();
//   SingletonFunctionController.btadapter.rs.clear();
//   Building.thresh = "";
//
//   d++;
//   sumMap.forEach((key, value) {
//
//     setState(() {
//      // direction = "${widget.direction}$key   $value\n";
//     });
//
//
//
//     if(value>highestweight){
//       highestweight =  value;
//       nearestBeacon = key;
//     }
//   });
//
//   //
//
//
//   if(nearestBeacon !=""){
//
//     if(user.pathobj.path[Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor] != null){
//       if(user.key != Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId){
//
//         if(user.floor == Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor  && highestweight >9){
//           List<int> beaconcoord = [Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.coordinateX!,Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.coordinateY!];
//           List<int> usercoord = [user.showcoordX, user.showcoordY];
//           double d = tools.calculateDistance(beaconcoord, usercoord);
//           if(d < 5){
//             //near to user so nothing to do
//             return true;
//           }else{
//             int distanceFromPath = 100000000;
//             int? indexOnPath = null;
//             int numCols = user.pathobj.numCols![user.Bid]![user.floor]!;
//             user.path.forEach((node) {
//               List<int> pathcoord = [node % numCols, node ~/ numCols];
//               double d1 = tools.calculateDistance(beaconcoord, pathcoord);
//               if(d1<distanceFromPath){
//                 distanceFromPath = d1.toInt();
//
//
//                 indexOnPath = user.path.indexOf(node);
//
//               }
//             });
//
//             if(distanceFromPath>5){
//               _timer.cancel();
//               repaintUser(nearestBeacon);
//               return false;//away from path
//             }else{
//               user.key = Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId!;
//
//               speak("You are near ${Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.name}");
//               user.moveToPointOnPath(indexOnPath!);
//               moveUser();
//               return true; //moved on path
//             }
//           }
//
//
//           //
//           //
//           //
//           //
//           //
//         }else{
//
//           speak("You have reached ${tools.numericalToAlphabetical(Building.SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!)} floor");
//           paintUser(nearestBeacon); //different floor
//           return true;
//         }
//
//       }
//     }else{
//
//
//
//       _timer.cancel();
//       repaintUser(nearestBeacon);
//       return false;
//     }
//   }
//   return false;
// }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth_disabled, size: 100, color: Colors.blueGrey),
              const SizedBox(height: 20),
              const Text(
                "Bluetooth is turned off",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Please restart your Bluetooth in your device settings to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}

class CircleAnimation {
  final AnimationController controller;
  final Animation<double> animation;

  CircleAnimation(this.controller, this.animation);
}

class CustomMarker extends StatelessWidget {
  final IconData dirIcon;
  CustomMarker({required this.dirIcon});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(dirIcon, color: Colors.black, size: 42),
        ],
      ),
    );
  }
}

class TurnCustomMarker extends StatelessWidget {
  final String text;
  final IconData dirIcon;

  TurnCustomMarker({required this.text, required this.dirIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(
        dirIcon,
        color: Colors.black,
        size: 40,
        shadows: [
          BoxShadow(
            color: Colors.white, // Color of the shadow
            blurRadius: 6, // Spread of the shadow
            offset: Offset(-2, -2),
            // Position of the shadow
          ),
        ],
      ),
    );
  }
}

class ChatMessageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Starting from top left
    path.moveTo(0, 20);

    // Top left corner
    path.quadraticBezierTo(0, 0, 20, 0);

    // Top right corner
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);

    // Bottom right corner
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 20, size.height);

    // Bottom left corner with squeezed effect
    path.lineTo(20, size.height);
    path.quadraticBezierTo(0, size.height - 10, 0, size.height - 30);

    // Complete the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}

class ClosestPointResult {
  final LatLng latLngPoint;
  final IntPoint intPoint;
  final double projectLength;

  ClosestPointResult(this.latLngPoint, this.intPoint, this.projectLength);
}

class IntPoint {
  int x;
  int y;

  IntPoint(this.x, this.y);
}

class _TtsItem {
  final String msg;
  final String lngcode;
  final bool prevpause;
  _TtsItem(this.msg, this.lngcode, this.prevpause);
}