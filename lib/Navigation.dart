import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
<<<<<<< Updated upstream

=======
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:iwaymaps/singletonClass.dart';
import 'package:iwaymaps/websocket/NotifIcationSocket.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
>>>>>>> Stashed changes
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart';
import 'package:iwaymaps/DebugToggle.dart';
import 'package:iwaymaps/Elements/DirectionHeader.dart';
import 'package:iwaymaps/Elements/ExploreModeWidget.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'API/outBuilding.dart';
import 'APIMODELS/outdoormodel.dart';
import 'directionClass.dart';
import 'localizedData.dart';

import 'package:chips_choice/chips_choice.dart';
import 'package:device_information/device_information.dart';
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
import 'package:iwaymaps/API/PolyLineApi.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/APIMODELS/buildingAll.dart';
import 'package:iwaymaps/APIMODELS/landmark.dart';
import 'package:iwaymaps/Elements/HomepageLandmarkClickedSearchBar.dart';
import 'package:iwaymaps/Elements/buildingCard.dart';
import 'package:iwaymaps/Elements/directionInstruction.dart';
import 'package:iwaymaps/PolylineTestClass.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:iwaymaps/buildingState.dart';
import 'package:iwaymaps/navigationTools.dart';
import 'package:iwaymaps/path.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'API/PatchApi.dart';
import 'API/beaconapi.dart';
import 'API/ladmarkApi.dart';
import 'API/outbuildingapi.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/buildingAll.dart';
import 'APIMODELS/outbuildingmodel.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'Cell.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'DestinationSearchPage.dart';
import 'Elements/HomepageSearch.dart';
import 'Elements/NavigationFilterCard.dart';
import 'Elements/SearchNearby.dart';
import 'Elements/landmarkPannelShimmer.dart';
import 'MODELS/FilterInfoModel.dart';
import 'MapState.dart';
import 'MotionModel.dart';
import 'SourceAndDestinationPage.dart';
import 'bluetooth_scanning.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'cutommarker.dart';
import 'dart:math' as math;
import 'APIMODELS/landmark.dart' as la;
import 'dart:ui' as ui;
import 'package:geodesy/geodesy.dart' as geo;
import 'package:lottie/lottie.dart' as lott;
import '../Elements/DirectionHeader.dart';

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

  Navigation({this.directLandID = ''});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  MapState mapState = new MapState();
  Timer? PDRTimer;
  Timer? _exploreModeTimer;
  String maptheme = "";
  var _initialCameraPosition = CameraPosition(
    target: LatLng(60.543833319119475, 77.18729871127312),
    zoom: 0,
  );
  late GoogleMapController _googleMapController;
  Set<Polygon> patch = Set();
  Set<Polygon> otherpatch = Set();
  Map<String, Set<gmap.Polyline>> polylines = Map();
  Set<gmap.Polyline> otherpolylines = Set();
  Set<gmap.Polyline> focusturn = Set();
  Set<Marker> focusturnArrow = Set();
  Map<String, Set<Polygon>> closedpolygons = Map();
  Set<Polygon> otherclosedpolygons = Set();
  Set<Marker> Markers = Set();
  Map<String, Set<Marker>> selectedroomMarker = Map();
  Map<int, Set<Marker>> pathMarkers = {};
  Map<String, List<Marker>> markers = Map();
<<<<<<< Updated upstream
  Building building = Building(floor: Map(), numberOfFloors: Map());
  Map<int, Set<gmap.Polyline>> singleroute = {};
=======
  // Building SingletonFunctionController.building = Building(floor: Map(), numberOfFloors: Map());
  Map<String, Map<int, Set<gmap.Polyline>>> singleroute = {};
>>>>>>> Stashed changes
  Map<int, Set<Marker>> dottedSingleRoute = {};
  BLueToothClass btadapter = new BLueToothClass();
  bool _isLandmarkPanelOpen = false;
  bool _isRoutePanelOpen = false;
  bool _isnavigationPannelOpen = false;
  bool _isreroutePannelOpen = false;
  bool _isBuildingPannelOpen = true;
  bool _isFilterPanelOpen = false;
  bool checkedForPolyineUpdated = false;
  bool checkedForPatchDataUpdated = false;
  bool checkedForLandmarkDataUpdated = false;
<<<<<<< Updated upstream
  PriorityQueue<MapEntry<String, double>> debugPQ = new PriorityQueue();
=======
  pac.PriorityQueue<MapEntry<String, double>> debugPQ = new pac.PriorityQueue();
  late final Uint8List userloc;
  late final Uint8List userlocdebug;
>>>>>>> Stashed changes

  HashMap<String, beacon> apibeaconmap = HashMap();
  late FlutterTts flutterTts;
  double mapbearing = 0.0;
  //UserState user = UserState(floor: 0, coordX: 154, coordY: 94, lat: 28.543406741799892, lng: 77.18761156074972, key: "659001d7e6c204e1eec13e26");
  UserState user = UserState(
      floor: 0, coordX: 0, coordY: 0, lat: 0.0, lng: 0.0, key: "", theta: 0.0);
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
  final pdr = <StreamSubscription<dynamic>>[];
  Duration sensorInterval = Duration(milliseconds: 100);

  late StreamSubscription<CompassEvent> compassSubscription;
  bool detected = false;
  List<String> allBuildingList = [];
  List<double> accelerationMagnitudes = [];
  bool isCalibrating = false;
  bool excludeFloorSemanticWork = false;

<<<<<<< Updated upstream
  @override
  void initState() {
    super.initState();
    //PolylineTestClass.polylineSet.clear();
    // StartPDR();
=======
  //-----------------------------------------------------------------------------------------
  /// Set of displayed markers and cluster markers on the map

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker>? _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 15;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Url image used on normal markers
  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';

  /// Color of the cluster circle
  final Color _clusterColor = Color(0xfffddaa9);

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  /// Example marker coordinates
  final List<InitMarkerModel> mapMarkerLocationMapAndName = [];
  final Map<LatLng, String> _markerLocationsMap = {};
  final Map<LatLng, String> _markerLocationsMapLanName = {};
  final Map<LatLng, String> _markerLocationsMapLanNameBID = {};

  /// Inits [Fluster] and all the markers with network images and updates the loading state.

  void _initMarkers() async {
    final List<MapMarker> markers = [];

    // mapMarkerLocationMapAndName.forEach((element) async {
    //   final String values = element.tag;
    //   final String LandmarkValue = element.landMarkName;
    //   if(closestBuildingId!=""){
    //
    //     if (values == 'Lift' && element.specBuildingID == closestBuildingId) {
    //       Uint8List iconMarker = await getImagesFromMarker('assets/lift.png', 65);
    //       markers.add(
    //         MapMarker(
    //           id: element.latLng.toString(),
    //           position: element.latLng,
    //           icon: BitmapDescriptor.fromBytes(iconMarker),
    //           Landmarkname: LandmarkValue,
    //           mapController: _googleMapController,
    //         ),
    //       );
    //     } else if (values == 'Entry'&& element.specBuildingID == closestBuildingId) {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/log-in.png', 65);
    //       try {
    //         markers.add(
    //           MapMarker(
    //               id: element.latLng.toString(),
    //               position: element.latLng,
    //               icon: BitmapDescriptor.fromBytes(iconMarker),
    //               Landmarkname: LandmarkValue,
    //               mapController: _googleMapController,
    //               offset: [0.5,0.5]
    //           ),
    //         );
    //       } catch (e) {}
    //     } else if (values == 'Pharmacy'&& element.specBuildingID == closestBuildingId) {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/hospital.png', 70);
    //       markers.add(
    //         MapMarker(
    //             id: element.latLng.toString(),
    //             position: element.latLng,
    //             icon: BitmapDescriptor.fromBytes(iconMarker),
    //             Landmarkname: LandmarkValue,
    //             mapController: _googleMapController),
    //       );
    //     } else if (values == 'Kitchen'&& element.specBuildingID == closestBuildingId) {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/cutlery.png', 60);
    //       markers.add(
    //         MapMarker(
    //             id: element.latLng.toString(),
    //             position: element.latLng,
    //             icon: BitmapDescriptor.fromBytes(iconMarker),
    //             Landmarkname: LandmarkValue,
    //             mapController: _googleMapController),
    //       );
    //     } else if (values == 'Female'&& element.specBuildingID == closestBuildingId) {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/Femaletoilet.png', 65);
    //       markers.add(
    //         MapMarker(
    //           id: element.latLng.toString(),
    //           position: element.latLng,
    //           icon: BitmapDescriptor.fromBytes(iconMarker),
    //           Landmarkname: LandmarkValue,
    //           mapController: _googleMapController,
    //         ),
    //       );
    //     } else if (values == 'Male'&& element.specBuildingID == closestBuildingId) {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/Maletoilet.png', 65);
    //       markers.add(
    //         MapMarker(
    //           id: element.latLng.toString(),
    //           position: element.latLng,
    //           icon: BitmapDescriptor.fromBytes(iconMarker),
    //           Landmarkname: LandmarkValue,
    //           mapController: _googleMapController,
    //         ),
    //       );
    //     }
    //   }else{
    //     if (values == 'Lift') {
    //       Uint8List iconMarker = await getImagesFromMarker('assets/lift.png', 65);
    //       markers.add(
    //         MapMarker(
    //           id: element.latLng.toString(),
    //           position: element.latLng,
    //           icon: BitmapDescriptor.fromBytes(iconMarker),
    //           Landmarkname: LandmarkValue,
    //           mapController: _googleMapController,
    //         ),
    //       );
    //     } else if (values == 'Entry') {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/log-in.png', 65);
    //       try {
    //         markers.add(
    //           MapMarker(
    //               id: element.latLng.toString(),
    //               position: element.latLng,
    //               icon: BitmapDescriptor.fromBytes(iconMarker),
    //               Landmarkname: LandmarkValue,
    //               mapController: _googleMapController,
    //               offset: [0.5,0.5]
    //           ),
    //         );
    //       } catch (e) {}
    //     } else if (values == 'Pharmacy') {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/hospital.png', 70);
    //       markers.add(
    //         MapMarker(
    //             id: element.latLng.toString(),
    //             position: element.latLng,
    //             icon: BitmapDescriptor.fromBytes(iconMarker),
    //             Landmarkname: LandmarkValue,
    //             mapController: _googleMapController),
    //       );
    //     } else if (values == 'Kitchen') {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/cutlery.png', 60);
    //       markers.add(
    //         MapMarker(
    //             id: element.latLng.toString(),
    //             position: element.latLng,
    //             icon: BitmapDescriptor.fromBytes(iconMarker),
    //             Landmarkname: LandmarkValue,
    //             mapController: _googleMapController),
    //       );
    //     } else if (values == 'Female') {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/Femaletoilet.png', 65);
    //       markers.add(
    //         MapMarker(
    //           id: element.latLng.toString(),
    //           position: element.latLng,
    //           icon: BitmapDescriptor.fromBytes(iconMarker),
    //           Landmarkname: LandmarkValue,
    //           mapController: _googleMapController,
    //         ),
    //       );
    //     } else if (values == 'Male') {
    //       Uint8List iconMarker =
    //       await getImagesFromMarker('assets/Maletoilet.png', 65);
    //       markers.add(
    //         MapMarker(
    //           id: element.latLng.toString(),
    //           position: element.latLng,
    //           icon: BitmapDescriptor.fromBytes(iconMarker),
    //           Landmarkname: LandmarkValue,
    //           mapController: _googleMapController,
    //         ),
    //       );
    //     }
    //   }
    //
    //
    //
    //
    // });
    try {
      for (LatLng keys in _markerLocationsMap.keys) {
        final String values = _markerLocationsMap[keys]!;
        final String LandmarkValue = _markerLocationsMapLanName[keys]!;
        final String buildingValue = _markerLocationsMapLanNameBID[keys]!;

        // Uint8List iconMarker = await getImagesFromMarker('assets/user.png', 45);
        //
        final BitmapDescriptor markerImage =
            await MapHelper.getMarkerImageFromUrl(_markerImageUrl);
        //BitmapDescriptor bb = await getImageMarker(5,Colors.black,Colors.white,60,'Entry','assets/lift.png');

        if (values == 'Lift') {
          Uint8List iconMarker =
              await getImagesFromMarker('assets/MapLift.png', 85);
          markers.add(
            MapMarker(
              id: keys.toString() + buildingValue,
              position: keys,
              icon: BitmapDescriptor.fromBytes(iconMarker),
              Landmarkname: LandmarkValue,
              mapController: _googleMapController,
            ),
          );
        } else if (values == 'Entry') {
          Uint8List iconMarker =
              await getImagesFromMarker('assets/MapEntry.png', 85);
          try {
            markers.add(
              MapMarker(
                id: keys.toString() + buildingValue,
                position: keys,
                icon: BitmapDescriptor.fromBytes(iconMarker),
                Landmarkname: LandmarkValue,
                mapController: _googleMapController,
              ),
            );
          } catch (e) {}
        } else if (values == 'Pharmacy') {
          Uint8List iconMarker =
              await getImagesFromMarker('assets/hospital.png', 85);
          markers.add(
            MapMarker(
                id: keys.toString() + buildingValue,
                position: keys,
                icon: BitmapDescriptor.fromBytes(iconMarker),
                Landmarkname: LandmarkValue,
                mapController: _googleMapController),
          );
        } else if (values == 'Kitchen') {
          Uint8List iconMarker =
              await getImagesFromMarker('assets/cutlery.png', 85);
          markers.add(
            MapMarker(
                id: keys.toString() + buildingValue,
                position: keys,
                icon: BitmapDescriptor.fromBytes(iconMarker),
                Landmarkname: LandmarkValue,
                mapController: _googleMapController),
          );
        } else if (values == 'Female') {
          Uint8List iconMarker =
              await getImagesFromMarker('assets/MapFemaleWashroom.png', 95);
          markers.add(
            MapMarker(
              id: keys.toString() + buildingValue,
              position: keys,
              icon: BitmapDescriptor.fromBytes(iconMarker),
              Landmarkname: LandmarkValue,
              mapController: _googleMapController,
            ),
          );
        } else if (values == 'Male') {
          Uint8List iconMarker =
              await getImagesFromMarker('assets/MapMaleWashroom.png', 95);
          markers.add(
            MapMarker(
              id: keys.toString() + buildingValue,
              position: keys,
              icon: BitmapDescriptor.fromBytes(iconMarker),
              Landmarkname: LandmarkValue,
              mapController: _googleMapController,
            ),
          );
        }
        print("__markers");
        print(markers);

        // markers.add(
        //   MapMarker(
        //     id: keys.toString(),
        //     position: keys,
        //     icon: BitmapDescriptor.fromBytes(values=='Lift'? await getImagesFromMarker('assets/lift.png', 45) : await getImagesFromMarker('assets/user.png', 45)),
        //   ),
        // );
      }
    } catch (e) {}

    _clusterManager = await MapHelper.initClusterManager(
        markers, _minClusterZoom, _maxClusterZoom, _googleMapController);

    await _updateMarkers11();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers11([double? updatedZoom]) async {
    if (updatedZoom != null && updatedZoom! > 15.5) {
      if (_clusterManager == null || updatedZoom == _currentZoom) return;

      if (updatedZoom != null) {
        _currentZoom = updatedZoom;
      }

      setState(() {
        _areMarkersLoading = true;
      });

      final updatedMarkers = await MapHelper.getClusterMarkers(
          _clusterManager,
          _currentZoom,
          _clusterColor,
          _clusterTextColor,
          70,
          _googleMapController);

      updatedMarkers.forEach((currentMarker) {
        if (currentMarker.markerId.toString().contains(closestBuildingId)) {
          currentMarker.visible = true;
        } else {
          currentMarker.visible = false;
        }
      });
      _markers
        ..clear()
        ..addAll(updatedMarkers);
      print("_markers");
      print(_markers);

      setState(() {
        _areMarkersLoading = false;
      });
    }
  }

  Future<Uint8List> getIconBytes(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List bytes =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    return bytes;
  }

  //--------------------------------------------------------------------------------------
  double _progressValue = 0.0;
  @override
  void initState() {
    super.initState();

    initializeMarkers();
    wsocket.message["AppInitialization"]["BID"]=buildingAllApi.selectedBuildingID;
    wsocket.message["AppInitialization"]["buildingName"]="AIIMS JAMMU";
    //add a timer of duration 5sec
    //PolylineTestClass.polylineSet.clear();
    // StartPDR();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;

    if (UserCredentials().getUserOrentationSetting() == 'Focus Mode') {
      UserState.ttsOnlyTurns = true;
      UserState.ttsAllStop = false;
    } else {
      UserState.ttsOnlyTurns = false;
      UserState.ttsAllStop = false;
    }
    _messageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      wsocket.sendmessg();
    });
>>>>>>> Stashed changes
    setPdrThreshold();
    listenToMagnetometer();

    building.floor.putIfAbsent("", () => 0);
    flutterTts = FlutterTts();
    setState(() {
      isLoading = true;
      speak("Loading maps");
    });

    //  calibrate();

<<<<<<< Updated upstream
    //btadapter.strtScanningIos(apibeaconmap);
    apiCalls();
=======
    //SingletonFunctionController.btadapter.strtScanningIos(SingletonFunctionController.apibeaconmap);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speak("${LocaleData.loadingMaps.getString(context)}", _currentLocale);

      apiCalls(context);
    });

>>>>>>> Stashed changes
    !DebugToggle.Slider ? handleCompassEvents() : () {};

    DefaultAssetBundle.of(context)
        .loadString("assets/mapstyle.json")
        .then((value) {
      maptheme = value;
    });
    checkPermissions();

    getDeviceManufacturer();
    try {
      _streamSubscriptions.add(
        userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
            (UserAccelerometerEvent event) {
          final now = DateTime.now();
          // setState(() {
          //   _userAccelerometerEvent = event;
          //   if (_userAccelerometerUpdateTime != null) {
          //     final interval = now.difference(_userAccelerometerUpdateTime!);
          //     if (interval > _ignoreDuration) {
          //       _userAccelerometerLastInterval = interval.inMilliseconds;
          //     }
          //   }
          // });
          _userAccelerometerUpdateTime = now;
        }, onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support User Accelerometer Sensor"),
                );
              });
          cancelOnError:
          true;
        }),
      );
    } catch (E) {}
    // fetchlist();
    // filterItems();
<<<<<<< Updated upstream
=======
  }

  void initializeMarkers() async {
    userloc = await getImagesFromMarker('assets/userloc0.png', 130);
    if (kDebugMode) {
      userlocdebug = await getImagesFromMarker('assets/tealtorch.png', 35);
    }
  }

  Future<void> zoomWhileWait(
      Map<String, LatLng> allBuildingID, GoogleMapController controller) async {
    print("allbuilding id ${allBuildingID}");

    if (allBuildingID.length > 1) {
      while (!SingletonFunctionController.building.destinationQr &&
          !user.initialallyLocalised &&
          !SingletonFunctionController.building.qrOpened) {
        for (var entry in allBuildingID.entries) {
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: entry.value, zoom: 16),
          ));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await Future.delayed(Duration(milliseconds: 500));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: entry.value, zoom: 20),
          ));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await Future.delayed(Duration(seconds: 3));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: entry.value, zoom: 16),
          ));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
        }

        // Check the conditions before starting the next loop iteration
        if (user.initialallyLocalised ||
            SingletonFunctionController.building.qrOpened) {
          return; // Exit the function if conditions are met
        }
      }
    } else {
      if (patch.isNotEmpty) {
        fitPolygonInScreen(patch.first);
      }
    }
>>>>>>> Stashed changes
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
    try {
      manufacturer = await DeviceInformation.deviceManufacturer;
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
    try {
      manufacturer = await DeviceInformation.deviceManufacturer;
      String deviceModel = await DeviceInformation.deviceModel;

      if (manufacturer.toLowerCase().contains("samsung")) {
        if (deviceModel.startsWith("A", 3)) {
          //
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
<<<<<<< Updated upstream
=======
      } else if (manufacturer.toLowerCase().contains("apple")) {
        peakThreshold = 10.111111;
        valleyThreshold = -10.111111;
>>>>>>> Stashed changes
      } else {
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
      }
    } catch (e) {
      throw (e);
    }
  }

  void handleCompassEvents() {
    compassSubscription = FlutterCompass.events!.listen((event) {
      double? compassHeading = event.heading!;

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
            markers[user.Bid]![0] = customMarker.rotate(
                compassHeading! - mapbearing, markers[user.Bid]![0]);
        }
      });
    });
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

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  void checkPermissions() async {
<<<<<<< Updated upstream
    print("running");
    //  await requestLocationPermission();
=======
    await requestLocationPermission();
>>>>>>> Stashed changes
    await requestBluetoothConnectPermission();
    //  await requestActivityPermission();
  }

<<<<<<< Updated upstream
=======
  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) {});
  }

>>>>>>> Stashed changes
  bool isPdr = false;
  // Function to start the timer
  void StartPDR() {
    PDRTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      //
      setState(() {
        isPdr = true;
      });
      pdrstepCount();
      // onStepCount();
    });
  }

// Function to stop the timer
  bool isPdrStop = false;
  void StopPDR() async {
    if (PDRTimer != null && PDRTimer!.isActive) {
      setState(() {
        isPdrStop = true;
        isPdr = false;
      });

      PDRTimer!.cancel();
      for (final subscription in pdr) {
        subscription.cancel();
      }
    }
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

// late StreamSubscription<AccelerometerEvent>? pdr;
  void pdrstepCount() {
<<<<<<< Updated upstream
    pdr.add(accelerometerEventStream().listen((AccelerometerEvent event) {
      if (pdr == null) {
        return; // Exit the event listener if subscription is canceled
      }
      // Apply low-pass filter
      filteredX = alpha * filteredX + (1 - alpha) * event.x;
      filteredY = alpha * filteredY + (1 - alpha) * event.y;
      filteredZ = alpha * filteredZ + (1 - alpha) * event.z;
      // Compute magnitude of acceleration vector
      double magnitude = sqrt((filteredX * filteredX +
          filteredY * filteredY +
          filteredZ * filteredZ));
      // Detect peak and valley
      if (magnitude > peakThreshold &&
          DateTime.now().millisecondsSinceEpoch - lastPeakTime > peakInterval) {
        setState(() {
          lastPeakTime = DateTime.now().millisecondsSinceEpoch;
          stepCount++;

          print("prev [${user.coordX},${user.coordY}]");
          bool isvalid = MotionModel.isValidStep(
              user,
              building.floorDimenssion[user.Bid]![user.floor]![0],
              building.floorDimenssion[user.Bid]![user.floor]![1],
              building.nonWalkable[user.Bid]![user.floor]!,
              reroute);
          if (isvalid) {
            user.move().then((value) {
              renderHere();
            });
          } else {
            if (user.isnavigating) {
              // reroute();
              // showToast("You are out of path");
            }
          }

          print("peakThreshold: ${peakThreshold}");
        });
      } else if (magnitude < valleyThreshold &&
          DateTime.now().millisecondsSinceEpoch - lastValleyTime >
              valleyInterval) {
        setState(() {
          lastValleyTime = DateTime.now().millisecondsSinceEpoch;
        });
      }
    }));
  }

  Future<void> paintMarker(LatLng Location) async {
    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 80);
    final Uint8List userlocdebug =
        await getImagesFromMarker('assets/tealtorch.png', 35);

=======
    pdr.add(accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (pdr == null) {
          return; // Exit the event listener if subscription is canceled
        }
        wsocket.message["deviceInfo"]["permissions"]["activity"] = true;
        wsocket.message["deviceInfo"]["sensors"]["activity"] = true;
        // Apply low-pass filter
        filteredX = alpha * filteredX + (1 - alpha) * event.x;
        filteredY = alpha * filteredY + (1 - alpha) * event.y;
        filteredZ = alpha * filteredZ + (1 - alpha) * event.z;
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

            bool isvalid = MotionModel.isValidStep(
                user,
                SingletonFunctionController
                    .building.floorDimenssion[user.Bid]![user.floor]![0],
                SingletonFunctionController
                    .building.floorDimenssion[user.Bid]![user.floor]![1],
                SingletonFunctionController
                    .building.nonWalkable[user.Bid]![user.floor]!,
                reroute);
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
        } else if (magnitude < valleyThreshold &&
            DateTime.now().millisecondsSinceEpoch - lastValleyTime >
                valleyInterval) {
          setState(() {
            lastValleyTime = DateTime.now().millisecondsSinceEpoch;
          });
        }
      },
      onError: (error) {
        wsocket.message["deviceInfo"]["permissions"]["activity"] = false;
        wsocket.message["deviceInfo"]["sensors"]["activity"] = false;
      },
    ));
  }

  Future<void> paintMarker(LatLng Location) async {
>>>>>>> Stashed changes
    if (markers.containsKey(user.Bid)) {
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("debug"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userlocdebug),
        anchor: Offset(0.5, 0.829),
      ));
    } else {
      markers.putIfAbsent(user.Bid, () => []);
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("debug"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userlocdebug),
        anchor: Offset(0.5, 0.829),
      ));
    }
  }

<<<<<<< Updated upstream
  void renderHere() {
    setState(() {
      if (markers.length > 0) {
        List<double> lvalue = tools.localtoglobal(
            user.showcoordX.toInt(), user.showcoordY.toInt());
        markers[user.Bid]?[0] = customMarker.move(
            LatLng(lvalue[0], lvalue[1]), markers[user.Bid]![0]);
=======
  void changeBuilding(String oldBid, String newBid) {
    markers[newBid] = markers[oldBid]!;
    tools.setBuildingAngle(SingletonFunctionController
        .building.patchData[newBid]!.patchData!.buildingAngle!);
  }

  // void renderHere() {
  //   setState(() {
  //     if (markers.length > 0) {
  //       List<double> lvalue = tools.localtoglobal(user.showcoordX.toInt(),
  //           user.showcoordY.toInt(), SingletonFunctionController.building.patchData[user.Bid]);
  //       markers[user.Bid]?[0] = customMarker.move(
  //           LatLng(user.lat, user.lng), markers[user.Bid]![0]);
  //
  //       print("insideee thiss");
  //
  //       mapState.target = LatLng(lvalue[0], lvalue[1]);
  //       _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //             target: mapState.target,
  //             zoom: mapState.zoom,
  //             bearing: mapState.bearing!,
  //             tilt: mapState.tilt),
  //       ));
  //
  //       List<double> ldvalue = tools.localtoglobal(user.coordX.toInt(),
  //           user.coordY.toInt(), SingletonFunctionController.building.patchData[user.Bid]);
  //       markers[user.Bid]?[1] = customMarker.move(
  //           LatLng(ldvalue[0], ldvalue[1]), markers[user.Bid]![1]);
  //     }
  //   });
  // }
>>>>>>> Stashed changes

  void renderHere() async {
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    if (markers.length > 0) {
      List<double> lvalue = tools.localtoglobal(
          user.showcoordX.toInt(),
          user.showcoordY.toInt(),
          SingletonFunctionController.building.patchData[user.Bid]);
      markers[user.Bid]?[0] =
          customMarker.move(LatLng(user.lat, user.lng), markers[user.Bid]![0]);

      print("insideee this");
      print(onStart);

      mapState.target = LatLng(lvalue[0], lvalue[1]);

      // Calculate the pixel position of the current center of the map
      ScreenCoordinate screenCenter =
          await _googleMapController.getScreenCoordinate(mapState.target);

      // Adjust the y-coordinate to shift the camera upwards (moving the target down)
      int newY = 0;
      if (Platform.isAndroid) {
        newY = screenCenter.y - ((screenHeight * 0.58)).toInt();
      } else {
        newY = screenCenter.y - ((screenHeight * 0.08) * pixelRatio).toInt();
      }
      // Adjust 300 as needed for how far you want the user at the bottom

      // Convert the new screen coordinate back to LatLng
      LatLng newCameraTarget = await _googleMapController
          .getLatLng(ScreenCoordinate(x: screenCenter.x, y: newY));
      setState(() {
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: (UserState.isTurn || onStart == false)
                ? mapState.target
                : mapState.target,
            zoom: mapState.zoom,
            bearing: mapState.bearing! ?? 0,
            tilt: mapState.tilt,
          ),
        ));
      });

<<<<<<< Updated upstream
        List<double> ldvalue =
            tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt());
        markers[user.Bid]?[1] = customMarker.move(
            LatLng(ldvalue[0], ldvalue[1]), markers[user.Bid]![1]);
      }
    });
=======
      List<double> ldvalue = tools.localtoglobal(
          user.coordX.toInt(),
          user.coordY.toInt(),
          SingletonFunctionController.building.patchData[user.Bid]);
      markers[user.Bid]?[1] = customMarker.move(
          LatLng(ldvalue[0], ldvalue[1]), markers[user.Bid]![1]);
    }
>>>>>>> Stashed changes
  }

  void onStepCount() {
    setState(() {
      if (_userAccelerometerEvent?.y != null) {
        if (_userAccelerometerEvent!.y > step_threshold ||
            _userAccelerometerEvent!.y < -step_threshold) {
          bool isvalid = MotionModel.isValidStep(
              user,
<<<<<<< Updated upstream
              building.floorDimenssion[user.Bid]![user.floor]![0],
              building.floorDimenssion[user.Bid]![user.floor]![1],
              building.nonWalkable[user.Bid]![user.floor]!,
=======
              SingletonFunctionController
                  .building.floorDimenssion[user.Bid]![user.floor]![0],
              SingletonFunctionController
                  .building.floorDimenssion[user.Bid]![user.floor]![1],
              SingletonFunctionController
                  .building.nonWalkable[user.Bid]![user.floor]!,
>>>>>>> Stashed changes
              reroute);
          if (isvalid) {
            user.move().then((value) {
              setState(() {
                if (markers.length > 0) {
                  markers[user.Bid]![0] = customMarker.move(
                      LatLng(
<<<<<<< Updated upstream
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt())[0],
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt())[1]),
=======
                          tools.localtoglobal(
                              user.showcoordX.toInt(),
                              user.showcoordY.toInt(),
                              SingletonFunctionController
                                  .building.patchData[user.Bid])[0],
                          tools.localtoglobal(
                              user.showcoordX.toInt(),
                              user.showcoordY.toInt(),
                              SingletonFunctionController
                                  .building.patchData[user.Bid])[1]),
>>>>>>> Stashed changes
                      markers[user.Bid]![0]);
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

<<<<<<< Updated upstream
      // print("value----");
      // print(value);
      String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);
      // print(finalvalue);
=======
      //
      //
      String finalvalue =
          tools.angleToClocksForNearestLandmarkToBeacon(value, context);
      //
>>>>>>> Stashed changes
      finalDirections.add(finalvalue);
    }
    return finalDirections;
  }

  void repaintUser(String nearestBeacon) {
    reroute();
    paintUser(nearestBeacon, speakTTS: false);
  }

  void paintUser(String nearestBeacon,
      {bool speakTTS = true, bool render = true}) async {
    print("nearestBeacon : $nearestBeacon");

<<<<<<< Updated upstream
    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 80);
    final Uint8List userlocdebug =
        await getImagesFromMarker('assets/tealtorch.png', 35);

    if (apibeaconmap[nearestBeacon] != null) {
      //buildingAngle compute
      tools.angleBetweenBuildingAndNorth(
          apibeaconmap[nearestBeacon]!.buildingID!);
=======
  late AnimationController _controller;
  late Animation<double> _animation;
  // land userSetLandmarkMap = land().landmarksMap;
  Future<Landmarks?> getglobalcoords() async {
    Landmarks? temp;
    double? minDistance;
    await SingletonFunctionController.building.landmarkdata!.then((value) {
      value.landmarks?.forEach((value) {
        if (value.buildingID == buildingAllApi.outdoorID) {
          if (value.coordinateX != null && value.coordinateY != null) {
            List<double> latlngvalue = tools.localtoglobal(
                value.coordinateX!,
                value.coordinateY!,
                SingletonFunctionController
                    .building.patchData[value.buildingID]);
            double dist = tools.calculateAerialDist(latlngvalue[0],
                latlngvalue[1], UserState.geoLat, UserState.geoLng);
            if (dist <= 25) {
              if (value.properties!.polyId != null &&
                  (value.name != null && value.name != "")) {
                // If no closest landmark yet or if this one is closer, update
                if (minDistance == null || dist < minDistance!) {
                  minDistance = dist;
                  print("userslatlng");
                  print(minDistance);
                  temp = value;
                  if (temp != null) {
                    print(temp!.name);
                    print(latlngvalue);
                  }
                  return; // Update the closest landmark
                }
              }
            }
          }
        }
      });
    });
    return temp;
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

  void findNearbyLandmarkUsingGPS() async {
    Landmarks? latlngLandmark = await getglobalcoords();

    if (latlngLandmark == null) {
      // Handle null case, you can show a message or just stop the flow
      speak("No nearby Landmarks Found", _currentLocale);
      print("No nearby landmarks found.");
      return;
    }
    print("latlngmark");
    print(latlngLandmark.name);

    Landmarks userSetLocation = latlngLandmark!;
    String? polyID = latlngLandmark.properties!.polyId!;
    // await SingletonFunctionController.building.landmarkdata!.then((value) {
    //
    //   value.landmarksMap?.forEach((key, valuee) {
    //     if (key == polyID) {
    //       userSetLocation = valuee;
    //     }
    //   });
    //
    // });

    tools.setBuildingAngle(SingletonFunctionController.building
        .patchData[userSetLocation.buildingID]!.patchData!.buildingAngle!);

    //nearestLandmark compute
    nearestLandInfo currentnearest = nearestLandInfo(
        sId: userSetLocation.sId,
        buildingID: userSetLocation.buildingID,
        coordinateX: userSetLocation.coordinateX,
        coordinateY: userSetLocation.coordinateY,
        doorX: userSetLocation.doorX,
        doorY: userSetLocation.doorY,
        type: userSetLocation.type,
        floor: userSetLocation.floor,
        name: userSetLocation.name,
        updatedAt: userSetLocation.updatedAt,
        buildingName: userSetLocation.buildingName,
        venueName: userSetLocation.venueName);
    nearestLandInfomation = currentnearest;

    setState(() {
      buildingAllApi.selectedID = userSetLocation!.buildingID!;
      buildingAllApi.selectedBuildingID = userSetLocation!.buildingID!;
    });

    List<int> localBeconCord = [];
    localBeconCord.add(userSetLocation.coordinateX!);
    localBeconCord.add(userSetLocation.coordinateY!);

    pathState().beaconCords = localBeconCord;

    List<double> values = [];

    //floor alignment
    await SingletonFunctionController.building.landmarkdata!.then((land) {
      if (land.landmarksMap![polyID]!.floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            SingletonFunctionController
                .building
                .polylinedatamap[land.landmarksMap![polyID]!.buildingID!]!
                .polyline!
                .floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(land.landmarksMap![polyID]!.floor!),
            SingletonFunctionController
                .building
                .polylinedatamap[land.landmarksMap![polyID]!.buildingID!]!
                .polyline!
                .floors!);

        for (int i = 0; i < prevFloorLifts.length; i++) {}

        for (int i = 0; i < currFloorLifts.length; i++) {}
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
        values = tools.localtoglobal(
            land.landmarksMap![polyID]!.coordinateX!,
            land.landmarksMap![polyID]!.coordinateY!,
            SingletonFunctionController
                .building.patchData[land.landmarksMap![polyID]!.buildingID!]);
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
        values = tools.localtoglobal(
            land.landmarksMap![polyID]!.coordinateX!,
            land.landmarksMap![polyID]!.coordinateY!,
            SingletonFunctionController
                .building.patchData[land.landmarksMap![polyID]!.buildingID!]);
      }
    });

    mapState.target = LatLng(values[0], values[1]);

    user.Bid = userSetLocation.buildingID!;
    user.locationName = userSetLocation.name;

    //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!);

    //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!);

    //did this change over here UDIT...
    user.coordX = userSetLocation.coordinateX!;
    user.coordY = userSetLocation.coordinateY!;
    List<double> ls = tools.localtoglobal(
        user.coordX,
        user.coordY,
        SingletonFunctionController
            .building.patchData[userSetLocation.buildingID]);
    user.lat = ls[0];
    user.lng = ls[1];

    if (nearestLandInfomation != null && nearestLandInfomation!.doorX != null) {
      user.coordX = nearestLandInfomation!.doorX!;
      user.coordY = nearestLandInfomation!.doorY!;

      List<double> latlng = tools.localtoglobal(
          nearestLandInfomation!.coordinateX!,
          nearestLandInfomation!.coordinateY!,
          SingletonFunctionController
              .building.patchData[nearestLandInfomation!.buildingID]);
      print("latlngjfhdbj");
      print(latlng);

      user.lat = latlng[0];
      user.lng = latlng[1];
      user.locationName = nearestLandInfomation!.name ??
          nearestLandInfomation!.element!.subType;
    } else if (nearestLandInfomation != null &&
        nearestLandInfomation!.doorX == null) {
      user.coordX = nearestLandInfomation!.coordinateX!;
      user.coordY = nearestLandInfomation!.coordinateY!;
      List<double> latlng = tools.localtoglobal(
          nearestLandInfomation!.coordinateX!,
          nearestLandInfomation!.coordinateY!,
          SingletonFunctionController
              .building.patchData[nearestLandInfomation!.buildingID]);

      user.lat = latlng[0];
      user.lng = latlng[1];

      user.locationName = nearestLandInfomation!.name ??
          nearestLandInfomation!.element!.subType;
    }
    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;
    UserState.cols = SingletonFunctionController.building.floorDimenssion[
        userSetLocation.buildingID]![userSetLocation.floor]![0];
    UserState.rows = SingletonFunctionController.building.floorDimenssion[
        userSetLocation.buildingID]![userSetLocation.floor]![1];
    UserState.lngCode = _currentLocale;
    UserState.reroute = reroute;
    UserState.closeNavigation = closeNavigation;
    UserState.AlignMapToPath = alignMapToPath;
    UserState.startOnPath = startOnPath;
    UserState.speak = speak;
    UserState.paintMarker = paintMarker;
    UserState.createCircle = updateCircle;
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

    // Create the animation
    _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
      ..addListener(() {
        _updateCircle(user.lat, user.lng);
      });
    setState(() {
      markers.clear();
      //List<double> ls=tools.localtoglobal(user.coordX, user.coordY,patchData: SingletonFunctionController.building.patchData[SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID]);
      // if (render) {
      //    markers.putIfAbsent(user.Bid, () => []);
      //    markers[user.Bid]?.add(Marker(
      //      markerId: MarkerId("UserLocation"),
      //      position: LatLng(user.lat, user.lng),
      //      icon: BitmapDescriptor.fromBytes(userloc),
      //      anchor: Offset(0.5, 0.829),
      //    ));
      //    markers[user.Bid]?.add(Marker(
      //      markerId: MarkerId("debug"),
      //      position: LatLng(user.lat, user.lng),
      //      icon: BitmapDescriptor.fromBytes(userlocdebug),
      //      anchor: Offset(0.5, 0.829),
      //    ));
      //    circles.add(
      //      Circle(
      //        circleId: CircleId("circle"),
      //        center: LatLng(user.lat, user.lng),
      //        radius: _animation.value,
      //        strokeWidth: 1,
      //        strokeColor: Colors.blue,
      //        fillColor: Colors.lightBlue.withOpacity(0.2),
      //      ),
      //    );
      //  }

      // else {
      user.moveToFloor(userSetLocation.floor!);
      markers.putIfAbsent(user.Bid, () => []);
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: LatLng(user.lat, user.lng),
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("debug"),
        position: LatLng(user.lat, user.lng),
        icon: BitmapDescriptor.fromBytes(userlocdebug),
        anchor: Offset(0.5, 0.829),
      ));
      // }

      SingletonFunctionController.building.floor[userSetLocation.buildingID!] =
          userSetLocation.floor!;
      if (widget.directLandID.length < 2) {
        createRooms(SingletonFunctionController.building.polyLineData!,
            userSetLocation.floor!);
      }

      SingletonFunctionController.building.landmarkdata!.then((value) {
        createMarkers(value, userSetLocation!.floor!, bid: user.Bid);
      });
    });

    double value = 0;
    if (nearestLandInfomation != null) {
      value = tools.calculateAngle2(
          [
            userSetLocation.doorX ?? userSetLocation.coordinateX!,
            userSetLocation.doorY ?? userSetLocation.coordinateY!
          ],
          newUserCord,
          [
            nearestLandInfomation!.coordinateX!,
            nearestLandInfomation!.coordinateY!
          ]);
    }

    mapState.zoom = 22;

    String? finalvalue = value == 0
        ? null
        : tools.angleToClocksForNearestLandmarkToBeacon(value, context);

    // double value =
    //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
    //
    // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

    //
    //
    if (user.isnavigating == false) {
      detected = true;
      if (!_isExploreModePannelOpen) {
        _isBuildingPannelOpen = true;
      }
      nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
    }
    String name = nearestLandInfomation == null
        ? userSetLocation.name!
        : nearestLandInfomation!.name!;
    if (nearestLandInfomation == null) {
      //updating user pointer
      SingletonFunctionController
          .building.floor[buildingAllApi.getStoredString()] = user.floor;
      createRooms(
          SingletonFunctionController.building.polyLineData!,
          SingletonFunctionController
              .building.floor[buildingAllApi.getStoredString()]!);
      if (pathMarkers[user.Bid] != null &&
          pathMarkers[user.Bid]![user.floor] != null) {
        setCameraPosition(pathMarkers[user.Bid]![user.floor]!);
      }
      if (markers.length > 0)
        markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
      if (user.initialallyLocalised) {
        mapState.interaction = !mapState.interaction;
      }
      fitPolygonInScreen(patch.first);

      if (true) {
        if (finalvalue == null) {
          speak(
              convertTolng(
                  "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",
                  _currentLocale,
                  ''),
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
    } else {
      if (true) {
        if (finalvalue == null) {
          speak(
              convertTolng(
                  "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",
                  _currentLocale,
                  ''),
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

    if (true) {
      mapState.zoom = 22.0;
      _googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(user.lat, user.lng),
          22, // Specify your custom zoom level here
        ),
      );
    }
  }

  void paintUser(String? nearestBeacon,
      {bool speakTTS = true, bool render = true, String? polyID}) async {
    print("nearestbeacon");
    print(nearestBeacon);
    if (widget.directsourceID.length > 2) {
      nearestBeacon = null;
      polyID = widget.directsourceID;
      widget.directsourceID = '';
    }
    Landmarks? latlngLandmark = await getglobalcoords();
    // print("latlnglandmarks ${latlngLandmark!.name}");
    // print(latlngLandmark);

    if (nearestBeacon == null && polyID != null) {
      Landmarks userSetLocation = Landmarks();
      await SingletonFunctionController.building.landmarkdata!.then((value) {
        value.landmarksMap?.forEach((key, valuee) {
          if (key == polyID) {
            userSetLocation = valuee;
          }
        });
      });

      tools.setBuildingAngle(SingletonFunctionController.building
          .patchData[userSetLocation.buildingID]!.patchData!.buildingAngle!);
>>>>>>> Stashed changes

      //nearestLandmark compute
      await building.landmarkdata!.then((value) {
        nearestLandInfomation = tools.localizefindNearbyLandmark(
            apibeaconmap[nearestBeacon]!, value.landmarksMap!);
      });

      List<int> localBeconCord = [];
<<<<<<< Updated upstream
      localBeconCord.add(apibeaconmap[nearestBeacon]!.coordinateX!);
      localBeconCord.add(apibeaconmap[nearestBeacon]!.coordinateY!);
      print(
          "check beacon ${apibeaconmap[nearestBeacon]!.coordinateX} ${apibeaconmap[nearestBeacon]!.coordinateY}");
=======
      localBeconCord.add(userSetLocation.coordinateX!);
      localBeconCord.add(userSetLocation.coordinateY!);
>>>>>>> Stashed changes

      pathState().beaconCords = localBeconCord;

      List<double> values = [];

      //floor alignment
<<<<<<< Updated upstream
      if (apibeaconmap[nearestBeacon]!.floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            building.polyLineData!.polyline!.floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!),
            building.polyLineData!.polyline!.floors!);
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
        values = tools.localtoglobal(apibeaconmap[nearestBeacon]!.coordinateX!,
            apibeaconmap[nearestBeacon]!.coordinateY!);
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
        values = tools.localtoglobal(apibeaconmap[nearestBeacon]!.coordinateX!,
            apibeaconmap[nearestBeacon]!.coordinateY!);
      }

      LatLng beaconLocation = LatLng(values[0], values[1]);
=======
      await SingletonFunctionController.building.landmarkdata!.then((land) {
        if (land.landmarksMap![polyID]!.floor != 0) {
          List<PolyArray> prevFloorLifts = findLift(
              tools.numericalToAlphabetical(0),
              SingletonFunctionController
                  .building
                  .polylinedatamap[land.landmarksMap![polyID]!.buildingID!]!
                  .polyline!
                  .floors!);
          List<PolyArray> currFloorLifts = findLift(
              tools.numericalToAlphabetical(land.landmarksMap![polyID]!.floor!),
              SingletonFunctionController
                  .building
                  .polylinedatamap[land.landmarksMap![polyID]!.buildingID!]!
                  .polyline!
                  .floors!);

          for (int i = 0; i < prevFloorLifts.length; i++) {}

          for (int i = 0; i < currFloorLifts.length; i++) {}
          List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

          UserState.xdiff = dvalue[0];
          UserState.ydiff = dvalue[1];
          values = tools.localtoglobal(
              land.landmarksMap![polyID]!.coordinateX!,
              land.landmarksMap![polyID]!.coordinateY!,
              SingletonFunctionController
                  .building.patchData[land.landmarksMap![polyID]!.buildingID!]);
        } else {
          UserState.xdiff = 0;
          UserState.ydiff = 0;
          values = tools.localtoglobal(
              land.landmarksMap![polyID]!.coordinateX!,
              land.landmarksMap![polyID]!.coordinateY!,
              SingletonFunctionController
                  .building.patchData[land.landmarksMap![polyID]!.buildingID!]);
        }
      });

>>>>>>> Stashed changes
      mapState.target = LatLng(values[0], values[1]);

      user.Bid = apibeaconmap[nearestBeacon]!.buildingID!;

<<<<<<< Updated upstream
      user.coordX = apibeaconmap[nearestBeacon]!.coordinateX!;
      user.coordY = apibeaconmap[nearestBeacon]!.coordinateY!;
      user.showcoordX = user.coordX;
      user.showcoordY = user.coordY;
      UserState.cols = building.floorDimenssion[apibeaconmap[nearestBeacon]!
          .buildingID]![apibeaconmap[nearestBeacon]!.floor]![0];
      UserState.rows = building.floorDimenssion[apibeaconmap[nearestBeacon]!
          .buildingID]![apibeaconmap[nearestBeacon]!.floor]![1];
=======
      //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!);

      //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!);

      //did this change over here UDIT...
      user.coordX = userSetLocation.coordinateX!;
      user.coordY = userSetLocation.coordinateY!;
      List<double> ls = tools.localtoglobal(
          user.coordX,
          user.coordY,
          SingletonFunctionController
              .building.patchData[userSetLocation.buildingID]);
      user.lat = ls[0];
      user.lng = ls[1];

      if (nearestLandInfomation != null &&
          nearestLandInfomation!.doorX != null) {
        user.coordX = nearestLandInfomation!.doorX!;
        user.coordY = nearestLandInfomation!.doorY!;
        List<double> latlng = tools.localtoglobal(
            nearestLandInfomation!.doorX!,
            nearestLandInfomation!.doorY!,
            SingletonFunctionController
                .building.patchData[nearestLandInfomation!.buildingID]);

        user.lat = latlng[0];
        user.lng = latlng[1];
        user.locationName = nearestLandInfomation!.name ??
            nearestLandInfomation!.element!.subType;
      } else if (nearestLandInfomation != null &&
          nearestLandInfomation!.doorX == null) {
        user.coordX = nearestLandInfomation!.coordinateX!;
        user.coordY = nearestLandInfomation!.coordinateY!;
        List<double> latlng = tools.localtoglobal(
            nearestLandInfomation!.coordinateX!,
            nearestLandInfomation!.coordinateY!,
            SingletonFunctionController
                .building.patchData[nearestLandInfomation!.buildingID]);

        user.lat = latlng[0];
        user.lng = latlng[1];
        user.locationName = nearestLandInfomation!.name ??
            nearestLandInfomation!.element!.subType;
      }
      user.showcoordX = user.coordX;
      user.showcoordY = user.coordY;
      UserState.cols = SingletonFunctionController.building.floorDimenssion[
          userSetLocation.buildingID]![userSetLocation.floor]![0];
      UserState.rows = SingletonFunctionController.building.floorDimenssion[
          userSetLocation.buildingID]![userSetLocation.floor]![1];
      UserState.lngCode = _currentLocale;
>>>>>>> Stashed changes
      UserState.reroute = reroute;
      UserState.closeNavigation = closeNavigation;
      UserState.AlignMapToPath = alignMapToPath;
      UserState.startOnPath = startOnPath;
      UserState.speak = speak;
      UserState.paintMarker = paintMarker;
      List<int> userCords = [];
      userCords.add(user.coordX);
      userCords.add(user.coordY);
      List<int> transitionValue = tools.eightcelltransition(user.theta);
      List<int> newUserCord = [
        user.coordX + transitionValue[0],
        user.coordY + transitionValue[1]
      ];

      user.lat =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.latitude!);
      user.lng =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.longitude!);
      user.floor = apibeaconmap[nearestBeacon]!.floor!;
      user.key = apibeaconmap[nearestBeacon]!.sId!;
      user.initialallyLocalised = true;
      setState(() {
        markers.clear();
        if (render) {
          markers.putIfAbsent(user.Bid, () => []);
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: beaconLocation,
            icon: BitmapDescriptor.fromBytes(userloc),
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: beaconLocation,
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
        } else {
          user.moveToFloor(apibeaconmap[nearestBeacon]!.floor!);
          markers.putIfAbsent(user.Bid, () => []);
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userloc),
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
        }

<<<<<<< Updated upstream
        building.floor[apibeaconmap[nearestBeacon]!.buildingID!] =
            apibeaconmap[nearestBeacon]!.floor!;
        createRooms(
            building.polyLineData!, apibeaconmap[nearestBeacon]!.floor!);
        building.landmarkdata!.then((value) {
          createMarkers(value, apibeaconmap[nearestBeacon]!.floor!);
=======
        SingletonFunctionController.building
            .floor[userSetLocation.buildingID!] = userSetLocation.floor!;
        if (widget.directLandID.length < 2) {
          createRooms(SingletonFunctionController.building.polyLineData!,
              userSetLocation.floor!);
        }

        SingletonFunctionController.building.landmarkdata!.then((value) {
          createMarkers(value, userSetLocation!.floor!, bid: user.Bid);
>>>>>>> Stashed changes
        });
      });

      double value = tools.calculateAngle2(userCords, newUserCord, [
        nearestLandInfomation.coordinateX!,
        nearestLandInfomation.coordinateY!
      ]);

<<<<<<< Updated upstream
      print("value----");
      print(value);
      String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);
=======
      mapState.zoom = 22;

      String? finalvalue = value == 0
          ? null
          : tools.angleToClocksForNearestLandmarkToBeacon(value, context);
>>>>>>> Stashed changes

      // double value =
      //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
      //
      // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

<<<<<<< Updated upstream
      // print("final value");
      // print(finalvalue);
      if (user.isnavigating == false) {
=======
      //
      //
      if (user.isnavigating == false && speakTTS) {
>>>>>>> Stashed changes
        detected = true;
        if (!_isExploreModePannelOpen) {
          _isBuildingPannelOpen = true;
        }
        nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
      }

      if (nearestLandInfomation.name!.isEmpty) {
        nearestLandInfomation.name = apibeaconmap[nearestBeacon]!.name!;

        nearestLandInfomation.floor = apibeaconmap[nearestBeacon]!.floor!;

        //updating user pointer
<<<<<<< Updated upstream

        building.floor[buildingAllApi.getStoredString()] = user.floor;
        createRooms(building.polyLineData!,
            building.floor[buildingAllApi.getStoredString()]!);
        if (pathMarkers[user.floor] != null) {
          setCameraPosition(pathMarkers[user.floor]!);
=======
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()] = user.floor;
        createRooms(
            SingletonFunctionController.building.polyLineData!,
            SingletonFunctionController
                .building.floor[buildingAllApi.getStoredString()]!);
        if (pathMarkers[user.Bid] != null &&
            pathMarkers[user.Bid]![user.floor] != null) {
          setCameraPosition(pathMarkers[user.Bid]![user.floor]!);
        }
        if (markers.length > 0)
          markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        fitPolygonInScreen(patch.first);

        if (speakTTS) {
          if (finalvalue == null) {
            speak(
                convertTolng(
                    "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",
                    _currentLocale,
                    ''),
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
      } else {
        if (speakTTS) {
          if (finalvalue == null) {
            speak(
                convertTolng(
                    "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",
                    _currentLocale,
                    ''),
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
        mapState.zoom = 22.0;
        _googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(user.lat, user.lng),
            22, // Specify your custom zoom level here
          ),
        );
      }
    } else if ((nearestBeacon == null || nearestBeacon.isEmpty) &&
        latlngLandmark != null &&
        polyID == null) {
      Landmarks userSetLocation = latlngLandmark;
      polyID = latlngLandmark.properties!.polyId!;
      // await SingletonFunctionController.building.landmarkdata!.then((value) {
      //
      //   value.landmarksMap?.forEach((key, valuee) {
      //     if (key == polyID) {
      //       userSetLocation = valuee;
      //     }
      //   });
      //
      // });

      tools.setBuildingAngle(SingletonFunctionController.building
          .patchData[userSetLocation.buildingID]!.patchData!.buildingAngle!);

      //nearestLandmark compute
      nearestLandInfo currentnearest = nearestLandInfo(
          sId: userSetLocation.sId,
          buildingID: userSetLocation.buildingID,
          coordinateX: userSetLocation.coordinateX,
          coordinateY: userSetLocation.coordinateY,
          doorX: userSetLocation.doorX,
          doorY: userSetLocation.doorY,
          type: userSetLocation.type,
          floor: userSetLocation.floor,
          name: userSetLocation.name,
          updatedAt: userSetLocation.updatedAt,
          buildingName: userSetLocation.buildingName,
          venueName: userSetLocation.venueName);
      nearestLandInfomation = currentnearest;

      setState(() {
        buildingAllApi.selectedID = userSetLocation!.buildingID!;
        buildingAllApi.selectedBuildingID = userSetLocation!.buildingID!;
      });

      List<int> localBeconCord = [];
      localBeconCord.add(userSetLocation.coordinateX!);
      localBeconCord.add(userSetLocation.coordinateY!);

      pathState().beaconCords = localBeconCord;

      List<double> values = [];

      //floor alignment
      await SingletonFunctionController.building.landmarkdata!.then((land) {
        if (land.landmarksMap![polyID]!.floor != 0) {
          List<PolyArray> prevFloorLifts = findLift(
              tools.numericalToAlphabetical(0),
              SingletonFunctionController
                  .building
                  .polylinedatamap[land.landmarksMap![polyID]!.buildingID!]!
                  .polyline!
                  .floors!);
          List<PolyArray> currFloorLifts = findLift(
              tools.numericalToAlphabetical(land.landmarksMap![polyID]!.floor!),
              SingletonFunctionController
                  .building
                  .polylinedatamap[land.landmarksMap![polyID]!.buildingID!]!
                  .polyline!
                  .floors!);

          for (int i = 0; i < prevFloorLifts.length; i++) {}

          for (int i = 0; i < currFloorLifts.length; i++) {}
          List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

          UserState.xdiff = dvalue[0];
          UserState.ydiff = dvalue[1];
          values = tools.localtoglobal(
              land.landmarksMap![polyID]!.coordinateX!,
              land.landmarksMap![polyID]!.coordinateY!,
              SingletonFunctionController
                  .building.patchData[land.landmarksMap![polyID]!.buildingID!]);
        } else {
          UserState.xdiff = 0;
          UserState.ydiff = 0;
          values = tools.localtoglobal(
              land.landmarksMap![polyID]!.coordinateX!,
              land.landmarksMap![polyID]!.coordinateY!,
              SingletonFunctionController
                  .building.patchData[land.landmarksMap![polyID]!.buildingID!]);
        }
      });

      mapState.target = LatLng(values[0], values[1]);

      user.Bid = userSetLocation.buildingID!;
      user.locationName = userSetLocation.name;

      //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!);

      //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!);

      //did this change over here UDIT...
      user.coordX = userSetLocation.coordinateX!;
      user.coordY = userSetLocation.coordinateY!;
      List<double> ls = tools.localtoglobal(
          user.coordX,
          user.coordY,
          SingletonFunctionController
              .building.patchData[userSetLocation.buildingID]);
      user.lat = ls[0];
      user.lng = ls[1];

      if (nearestLandInfomation != null &&
          nearestLandInfomation!.doorX != null) {
        user.coordX = nearestLandInfomation!.doorX!;
        user.coordY = nearestLandInfomation!.doorY!;
        List<double> latlng = tools.localtoglobal(
            nearestLandInfomation!.doorX!,
            nearestLandInfomation!.doorY!,
            SingletonFunctionController
                .building.patchData[nearestLandInfomation!.buildingID]);

        user.lat = latlng[0];
        user.lng = latlng[1];
        user.locationName = nearestLandInfomation!.name ??
            nearestLandInfomation!.element!.subType;
      } else if (nearestLandInfomation != null &&
          nearestLandInfomation!.doorX == null) {
        user.coordX = nearestLandInfomation!.coordinateX!;
        user.coordY = nearestLandInfomation!.coordinateY!;
        List<double> latlng = tools.localtoglobal(
            nearestLandInfomation!.coordinateX!,
            nearestLandInfomation!.coordinateY!,
            SingletonFunctionController
                .building.patchData[nearestLandInfomation!.buildingID]);

        user.lat = latlng[0];
        user.lng = latlng[1];
        user.locationName = nearestLandInfomation!.name ??
            nearestLandInfomation!.element!.subType;
      }
      user.showcoordX = user.coordX;
      user.showcoordY = user.coordY;
      UserState.cols = SingletonFunctionController.building.floorDimenssion[
          userSetLocation.buildingID]![userSetLocation.floor]![0];
      UserState.rows = SingletonFunctionController.building.floorDimenssion[
          userSetLocation.buildingID]![userSetLocation.floor]![1];
      UserState.lngCode = _currentLocale;
      UserState.reroute = reroute;
      UserState.closeNavigation = closeNavigation;
      UserState.AlignMapToPath = alignMapToPath;
      UserState.startOnPath = startOnPath;
      UserState.speak = speak;
      UserState.paintMarker = paintMarker;
      UserState.createCircle = updateCircle;
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

      // Create the animation
      _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
        ..addListener(() {
          _updateCircle(user.lat, user.lng);
        });
      setState(() {
        markers.clear();
        //List<double> ls=tools.localtoglobal(user.coordX, user.coordY,patchData: SingletonFunctionController.building.patchData[SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID]);
        if (render) {
          markers.putIfAbsent(user.Bid, () => []);
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userloc),
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
          circles.add(
            Circle(
              circleId: CircleId("circle"),
              center: LatLng(user.lat, user.lng),
              radius: _animation.value,
              strokeWidth: 1,
              strokeColor: Colors.blue,
              fillColor: Colors.lightBlue.withOpacity(0.2),
            ),
          );
        } else {
          user.moveToFloor(userSetLocation.floor!);
          markers.putIfAbsent(user.Bid, () => []);
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userloc),
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
        }

        SingletonFunctionController.building
            .floor[userSetLocation.buildingID!] = userSetLocation.floor!;
        if (widget.directLandID.length < 2) {
          createRooms(SingletonFunctionController.building.polyLineData!,
              userSetLocation.floor!);
        }

        SingletonFunctionController.building.landmarkdata!.then((value) {
          createMarkers(value, userSetLocation!.floor!, bid: user.Bid);
        });
      });

      double value = 0;
      if (nearestLandInfomation != null) {
        value = tools.calculateAngle2(
            [
              userSetLocation.doorX ?? userSetLocation.coordinateX!,
              userSetLocation.doorY ?? userSetLocation.coordinateY!
            ],
            newUserCord,
            [
              nearestLandInfomation!.coordinateX!,
              nearestLandInfomation!.coordinateY!
            ]);
      }

      mapState.zoom = 22;

      String? finalvalue = value == 0
          ? null
          : tools.angleToClocksForNearestLandmarkToBeacon(value, context);

      // double value =
      //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
      //
      // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

      //
      //
      if (user.isnavigating == false && speakTTS) {
        detected = true;
        if (!_isExploreModePannelOpen && speakTTS) {
          _isBuildingPannelOpen = true;
        }
        nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
      }
      String name = nearestLandInfomation == null
          ? userSetLocation.name!
          : nearestLandInfomation!.name!;
      if (nearestLandInfomation == null) {
        //updating user pointer
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()] = user.floor;
        createRooms(
            SingletonFunctionController.building.polyLineData!,
            SingletonFunctionController
                .building.floor[buildingAllApi.getStoredString()]!);
        if (pathMarkers[user.Bid] != null &&
            pathMarkers[user.Bid]![user.floor] != null) {
          setCameraPosition(pathMarkers[user.Bid]![user.floor]!);
>>>>>>> Stashed changes
        }
        building.landmarkdata!.then((value) {
          createMarkers(
              value, building.floor[buildingAllApi.getStoredString()]!);
        });
        if (markers.length > 0)
          markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        mapState.zoom = 22;
        fitPolygonInScreen(patch.first);

        if (speakTTS) {
          if (finalvalue == "None") {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor, near ${apibeaconmap[nearestBeacon]!.name!}");
          } else {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${apibeaconmap[nearestBeacon]!.name!} is on your ${finalvalue}");
          }
        }
      } else {
        nearestLandInfomation.floor = apibeaconmap[nearestBeacon]!.floor!;

        if (speakTTS) {
          if (finalvalue == "None") {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor, near ${nearestLandInfomation.name}");
          } else {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${nearestLandInfomation.name} is on your ${finalvalue}");
          }
        }
      }

      if (speakTTS) {
        mapState.zoom = 22.0;
        _googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(user.lat, user.lng),
            22, // Specify your custom zoom level here
          ),
        );
      }
    } else {
<<<<<<< Updated upstream
      if (speakTTS) speak("Unable to find your location");
    }
    if (widget.directLandID.isNotEmpty) {
      print("checkdirectLandID");
      onLandmarkVenueClicked(widget.directLandID);
    }
  }

  void moveUser() async {
    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 80);
    final Uint8List userlocdebug =
        await getImagesFromMarker('assets/tealtorch.png', 35);
=======
      wsocket.message["AppInitialization"]["localizedOn"] = nearestBeacon;

      if (SingletonFunctionController.apibeaconmap[nearestBeacon] != null) {
        //buildingAngle compute

        tools.setBuildingAngle(SingletonFunctionController
            .building
            .patchData[SingletonFunctionController
                .apibeaconmap[nearestBeacon]!.buildingID]!
            .patchData!
            .buildingAngle!);

        //nearestLandmark compute

        try {
          await SingletonFunctionController.building.landmarkdata!
              .then((value) {
            nearestLandInfomation = tools.localizefindNearbyLandmark(
                SingletonFunctionController.apibeaconmap[nearestBeacon]!,
                value.landmarksMap!);
          });
        } catch (e) {}

        setState(() {
          buildingAllApi.selectedID = SingletonFunctionController
              .apibeaconmap[nearestBeacon]!.buildingID!;
          buildingAllApi.selectedBuildingID = SingletonFunctionController
              .apibeaconmap[nearestBeacon]!.buildingID!;
        });

        List<int> localBeconCord = [];
        localBeconCord.add(SingletonFunctionController
            .apibeaconmap[nearestBeacon]!.coordinateX!);
        localBeconCord.add(SingletonFunctionController
            .apibeaconmap[nearestBeacon]!.coordinateY!);

        pathState().beaconCords = localBeconCord;

        List<double> values = [];

        //floor alignment
        if (SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor !=
            0) {
          List<PolyArray> prevFloorLifts = findLift(
              tools.numericalToAlphabetical(0),
              SingletonFunctionController
                  .building
                  .polylinedatamap[SingletonFunctionController
                      .apibeaconmap[nearestBeacon]!.buildingID!]!
                  .polyline!
                  .floors!);
          List<PolyArray> currFloorLifts = findLift(
              tools.numericalToAlphabetical(SingletonFunctionController
                  .apibeaconmap[nearestBeacon]!.floor!),
              SingletonFunctionController
                  .building
                  .polylinedatamap[SingletonFunctionController
                      .apibeaconmap[nearestBeacon]!.buildingID!]!
                  .polyline!
                  .floors!);

          for (int i = 0; i < prevFloorLifts.length; i++) {}

          for (int i = 0; i < currFloorLifts.length; i++) {}
          List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

          UserState.xdiff = dvalue[0];
          UserState.ydiff = dvalue[1];
          values = tools.localtoglobal(
              SingletonFunctionController
                  .apibeaconmap[nearestBeacon]!.coordinateX!,
              SingletonFunctionController
                  .apibeaconmap[nearestBeacon]!.coordinateY!,
              SingletonFunctionController.building.patchData[
                  SingletonFunctionController
                      .apibeaconmap[nearestBeacon]!.buildingID!]);
        } else {
          UserState.xdiff = 0;
          UserState.ydiff = 0;
          values = tools.localtoglobal(
              SingletonFunctionController
                  .apibeaconmap[nearestBeacon]!.coordinateX!,
              SingletonFunctionController
                  .apibeaconmap[nearestBeacon]!.coordinateY!,
              SingletonFunctionController.building.patchData[
                  SingletonFunctionController
                      .apibeaconmap[nearestBeacon]!.buildingID!]);
        }

        mapState.target = LatLng(values[0], values[1]);

        user.Bid = SingletonFunctionController
            .apibeaconmap[nearestBeacon]!.buildingID!;
        user.locationName =
            SingletonFunctionController.apibeaconmap[nearestBeacon]!.name;

        //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!);

        //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!);

        //did this change over here UDIT...
        user.coordX = SingletonFunctionController
            .apibeaconmap[nearestBeacon]!.coordinateX!;
        user.coordY = SingletonFunctionController
            .apibeaconmap[nearestBeacon]!.coordinateY!;
        List<double> ls = tools.localtoglobal(
            user.coordX,
            user.coordY,
            SingletonFunctionController.building.patchData[
                SingletonFunctionController
                    .apibeaconmap[nearestBeacon]!.buildingID]);
        user.lat = ls[0];
        user.lng = ls[1];

        if (nearestLandInfomation != null &&
            nearestLandInfomation!.doorX != null) {
          user.coordX = nearestLandInfomation!.doorX!;
          user.coordY = nearestLandInfomation!.doorY!;
          List<double> latlng = tools.localtoglobal(
              nearestLandInfomation!.doorX!,
              nearestLandInfomation!.doorY!,
              SingletonFunctionController
                  .building.patchData[nearestLandInfomation!.buildingID]);

          user.lat = latlng[0];
          user.lng = latlng[1];
          user.locationName = nearestLandInfomation!.name ??
              nearestLandInfomation!.element!.subType;
        } else if (nearestLandInfomation != null &&
            nearestLandInfomation!.doorX == null) {
          user.coordX = nearestLandInfomation!.coordinateX!;
          user.coordY = nearestLandInfomation!.coordinateY!;
          List<double> latlng = tools.localtoglobal(
              nearestLandInfomation!.coordinateX!,
              nearestLandInfomation!.coordinateY!,
              SingletonFunctionController
                  .building.patchData[nearestLandInfomation!.buildingID]);

          user.lat = latlng[0];
          user.lng = latlng[1];
          user.locationName = nearestLandInfomation!.name ??
              nearestLandInfomation!.element!.subType;
        }
        user.showcoordX = user.coordX;
        user.showcoordY = user.coordY;
        UserState.cols = SingletonFunctionController.building.floorDimenssion[
                SingletonFunctionController
                    .apibeaconmap[nearestBeacon]!.buildingID]![
            SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor]![0];
        UserState.rows = SingletonFunctionController.building.floorDimenssion[
                SingletonFunctionController
                    .apibeaconmap[nearestBeacon]!.buildingID]![
            SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor]![1];
        UserState.lngCode = _currentLocale;
        UserState.reroute = reroute;
        UserState.closeNavigation = closeNavigation;
        UserState.AlignMapToPath = alignMapToPath;
        UserState.startOnPath = startOnPath;
        UserState.speak = speak;
        UserState.paintMarker = paintMarker;
        UserState.createCircle = updateCircle;
        List<int> userCords = [];
        userCords.add(user.coordX);
        userCords.add(user.coordY);
        List<int> transitionValue = tools.eightcelltransition(user.theta);
        List<int> newUserCord = [
          user.coordX + transitionValue[0],
          user.coordY + transitionValue[1]
        ];
        user.floor =
            SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!;
        user.key =
            SingletonFunctionController.apibeaconmap[nearestBeacon]!.sId!;
        user.initialallyLocalised = true;
        setState(() {
          markers.clear();
          //List<double> ls=tools.localtoglobal(user.coordX, user.coordY,patchData: SingletonFunctionController.building.patchData[SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID]);
          if (render) {
            markers.putIfAbsent(user.Bid, () => []);
            markers[user.Bid]?.add(Marker(
              markerId: MarkerId("UserLocation"),
              position: LatLng(user.lat, user.lng),
              icon: BitmapDescriptor.fromBytes(userloc),
              anchor: Offset(0.5, 0.829),
            ));
            markers[user.Bid]?.add(Marker(
              markerId: MarkerId("debug"),
              position: LatLng(user.lat, user.lng),
              icon: BitmapDescriptor.fromBytes(userlocdebug),
              anchor: Offset(0.5, 0.829),
            ));
            circles.add(
              Circle(
                circleId: CircleId("circle"),
                center: LatLng(user.lat, user.lng),
                radius: _animation.value,
                strokeWidth: 1,
                strokeColor: Colors.blue,
                fillColor: Colors.lightBlue.withOpacity(0.2),
              ),
            );
          } else {
            user.moveToFloor(SingletonFunctionController
                .apibeaconmap[nearestBeacon]!.floor!);
            markers.putIfAbsent(user.Bid, () => []);
            markers[user.Bid]?.add(Marker(
              markerId: MarkerId("UserLocation"),
              position: LatLng(user.lat, user.lng),
              icon: BitmapDescriptor.fromBytes(userloc),
              anchor: Offset(0.5, 0.829),
            ));
            markers[user.Bid]?.add(Marker(
              markerId: MarkerId("debug"),
              position: LatLng(user.lat, user.lng),
              icon: BitmapDescriptor.fromBytes(userlocdebug),
              anchor: Offset(0.5, 0.829),
            ));
          }

          if (widget.directLandID.length < 2) {
            circles.clear();
            SingletonFunctionController.building.floor[
                    SingletonFunctionController
                        .apibeaconmap[nearestBeacon]!.buildingID!] =
                SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!;
            createRooms(
                SingletonFunctionController.building.polylinedatamap[user.Bid]!,
                SingletonFunctionController
                    .apibeaconmap[nearestBeacon]!.floor!);
          }

          SingletonFunctionController.building.landmarkdata!.then((value) {
            createMarkers(value,
                SingletonFunctionController.apibeaconmap[nearestBeacon]!.floor!,
                bid: user.Bid);
          });
        });

        double value = 0;
        if (nearestLandInfomation != null) {
          value = tools.calculateAngle2(
              [user.coordX, user.coordY],
              newUserCord,
              [
                nearestLandInfomation!.coordinateX!,
                nearestLandInfomation!.coordinateY!
              ]);
        }

        mapState.zoom = 22;

        if (value < 45) {
          value = value + 45;
        }
        String? finalvalue = value == 0
            ? null
            : tools.angleToClocksForNearestLandmarkToBeacon(value, context);

        // double value =
        //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
        //
        // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

        //
        //
        if (user.isnavigating == false && speakTTS) {
          detected = true;
          if (!_isExploreModePannelOpen && speakTTS) {
            _isBuildingPannelOpen = true;
          }
          nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
        }
        String name = nearestLandInfomation == null
            ? SingletonFunctionController.apibeaconmap[nearestBeacon]!.name!
            : nearestLandInfomation!.name!;
        if (nearestLandInfomation == null) {
          //updating user pointer
          SingletonFunctionController
              .building.floor[buildingAllApi.getStoredString()] = user.floor;
          createRooms(
              SingletonFunctionController.building.polyLineData!,
              SingletonFunctionController
                  .building.floor[buildingAllApi.getStoredString()]!);
          if (pathMarkers[user.Bid] != null &&
              pathMarkers[user.Bid]![user.floor] != null) {
            setCameraPosition(pathMarkers[user.Bid]![user.floor]!);
          }
          if (markers.length > 0)
            markers[user.Bid]?[0] =
                customMarker.rotate(0, markers[user.Bid]![0]);
          if (user.initialallyLocalised) {
            mapState.interaction = !mapState.interaction;
          }
          fitPolygonInScreen(patch.first);

          if (speakTTS) {
            if (finalvalue == null) {
              speak(
                  convertTolng(
                      "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",
                      _currentLocale,
                      ''),
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
        } else {
          if (speakTTS) {
            if (finalvalue == null) {
              speak(
                  convertTolng(
                      "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",
                      _currentLocale,
                      ''),
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
          mapState.zoom = 22.0;
          _googleMapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(user.lat, user.lng),
              22, // Specify your custom zoom level here
            ),
          );
        }
      } else {
        if (speakTTS) {
          speak("${LocaleData.unabletofindyourlocation.getString(context)}",
              _currentLocale);
          showLocationDialog(context);
          SingletonFunctionController.building.qrOpened = true;
        }
      }
    }
  }

  bool _isExpanded = false;
  String? qrText;

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
                              builder: (context) => DestinationSearchPage(
                                hintText: 'Source location',
                                voiceInputEnabled: false,
                                userLocalized: user.key,
                              ),
                            ),
                          ).then((value) {
                            setState(() {
                              if (value != null) {
                                Navigator.of(context).pop();
                                paintUser(null, polyID: value);
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
                  SizedBox(height: 20),
                  Text(
                    "Or",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffa0a0a0),
                      height: 20 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Scan the Nearby QR Code",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff18181b),
                      height: 25 / 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Semantics(
                      label: "Open Qr Scanner to know your location",
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                          // Navigator.of(context).pop();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QRViewExample()),
                          ).then((value) {
                            setState(() {
                              isLoading = false;
                              isBlueToothLoading = false;
                            });
                            paintUser(null, polyID: value);
                          });
                          //Navigator.of(context).pop();
                          // if (result != null) {
                          //   setState(() {
                          //     qrText = result;
                          //   });
                          //
                          //   // Handle the scanned QR code text
                          // }else{
                          //
                          // }
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 3),
                          width: _isExpanded ? 120 : 80,
                          height: _isExpanded ? 120 : 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.qr_code_scanner,
                              size: 50, color: Colors.teal),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
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
>>>>>>> Stashed changes

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
    LatLng userlocation = LatLng(user.lat, user.lng);
    mapState.target = LatLng(user.lat, user.lng);
    mapState.zoom = 21.0;
    _googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(user.lat, user.lng),
        20, // Specify your custom zoom level here
      ),
    );

    setState(() {
      markers.clear();
      markers.putIfAbsent(user.Bid, () => []);
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: userlocation,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("debug"),
        position: userlocation,
        icon: BitmapDescriptor.fromBytes(userlocdebug),
        anchor: Offset(0.5, 0.829),
      ));
    });
  }

<<<<<<< Updated upstream
=======
  void autoreroute() {
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
        user.showcoordX = user.coordX;
        user.showcoordY = user.coordY;
        PathState.sourceFloor = user.floor;
        PathState.sourceName = "Your current location";
        // double d = double.infinity;
        // for (var value in user.Cellpath) {
        //   if(value.bid == user.Bid && value.floor == user.floor){
        //     double distance = tools.calculateDistance([value.x,value.y], [user.coordX,user.coordY]);
        //     if(distance<d){
        //       d = distance;
        //       PathState.sourceX = value.x;
        //       PathState.sourceY = value.y;
        //     }
        //   }
        // }

        SingletonFunctionController.building.landmarkdata!.then((value) async {
          await calculateroute(value.landmarksMap!).then((value) {
            if (PathState.path.isNotEmpty) {
              user.pathobj = PathState;
              user.path = [
                ...PathState.path[PathState.sourceFloor]!,
                ...PathState.path[PathState.destinationFloor]!,
              ];
              user.Cellpath = PathState.singleCellListPath;
              user.pathobj.index = 0;
              user.isnavigating = true;
              user.temporaryExit = false;
              user.moveToStartofPath().then((value) {
                setState(() {
                  if (markers.length > 0) {
                    markers[user.Bid]?[0] = customMarker.move(
                        LatLng(
                            tools.localtoglobal(
                                user.showcoordX.toInt(),
                                user.showcoordY.toInt(),
                                SingletonFunctionController
                                    .building.patchData[user.Bid])[0],
                            tools.localtoglobal(
                                user.showcoordX.toInt(),
                                user.showcoordY.toInt(),
                                SingletonFunctionController
                                    .building.patchData[user.Bid])[1]),
                        markers[user.Bid]![0]);
                  }
                });
              });
              _isRoutePanelOpen = false;
              SingletonFunctionController.building.selectedLandmarkID = null;
              _isnavigationPannelOpen = true;
              _isreroutePannelOpen = false;
              int numCols = SingletonFunctionController
                      .building.floorDimenssion[PathState.sourceBid]![
                  PathState.sourceFloor]![0]; //floor length
              double angle = tools.calculateAngleBWUserandPath(
                  user, PathState.path[PathState.sourceFloor]![1], numCols);
              if (angle != 0) {
                speak(
                    "${LocaleData.turn.getString(context)} " +
                        LocaleData.getProperty5(
                            tools.angleToClocks(angle, context), context),
                    _currentLocale);
              } else {}

              mapState.tilt = 50;

              mapState.bearing = tools.calculateBearing([
                user.lat,
                user.lng
              ], [
                PathState.singleCellListPath[user.pathobj.index + 1].lat,
                PathState.singleCellListPath[user.pathobj.index + 1].lng
              ]);
              _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: mapState.target,
                    zoom: mapState.zoom,
                    bearing: mapState.bearing!,
                    tilt: mapState.tilt),
              ));
            } else {
              setState(() {
                _isreroutePannelOpen = false;
                _isLandmarkPanelOpen = false;
                _isBuildingPannelOpen = false;
                _isRoutePanelOpen = true;
              });
            }
          });
        });
        rerouting = false;
      }
    });
  }

>>>>>>> Stashed changes
  void reroute() {
    _isnavigationPannelOpen = false;
    _isRoutePanelOpen = false;
    _isLandmarkPanelOpen = false;
    _isreroutePannelOpen = true;
    user.isnavigating = false;
<<<<<<< Updated upstream
    print("reroute----- coord ${user.coordX},${user.coordY}");
    print("reroute----- show ${user.showcoordX},${user.showcoordY}");
=======
    user.temporaryExit = true;

>>>>>>> Stashed changes
    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;
    setState(() {
      onStart = false;
      startingNavigation = false;
      if (markers.length > 0) {
<<<<<<< Updated upstream
        List<double> dvalue =
            tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt());
=======
        List<double> dvalue = tools.localtoglobal(
            user.coordX.toInt(),
            user.coordY.toInt(),
            SingletonFunctionController.building.patchData[user.Bid]);
>>>>>>> Stashed changes
        markers[user.Bid]?[0] = customMarker.move(
            LatLng(dvalue[0], dvalue[1]), markers[user.Bid]![0]);
      }
    });
    speak(
        "You are going away from the path. Click Reroute to Navigate from here. ");
  }

  Future<void> requestBluetoothConnectPermission() async {
    final PermissionStatus permissionStatus =
        await Permission.bluetoothScan.request();
<<<<<<< Updated upstream
    print("permissionStatus    ----   ${permissionStatus}");
    if (permissionStatus.isGranted) {
      print("Bluetooth permission is granted");
      // Permission granted, you can now perform Bluetooth operations
    } else {
=======

    if (permissionStatus.isGranted) {
      wsocket.message["deviceInfo"]["permissions"]["BLE"] = true;
      wsocket.message["deviceInfo"]["sensors"]["BLE"] = true;

      //widget.bluetoothGranted = true;
      // Permission granted, you can now perform Bluetooth operations
    } else {
      wsocket.message["deviceInfo"]["permissions"]["BLE"] = false;
      wsocket.message["deviceInfo"]["sensors"]["BLE"] = false;

>>>>>>> Stashed changes
      // Permission denied, handle accordingly
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
<<<<<<< Updated upstream
      print('location permission granted');
    } else {}
=======
      wsocket.message["deviceInfo"]["permissions"]["location"] = true;
      wsocket.message["deviceInfo"]["sensors"]["location"] = true;
    } else {
      wsocket.message["deviceInfo"]["permissions"]["location"] = false;
      wsocket.message["deviceInfo"]["sensors"]["location"] = false;
    }
>>>>>>> Stashed changes
  }

  List<FilterInfoModel> landmarkListForFilter = [];
  bool isLoading = false;
  HashMap<String, beacon> resBeacons = HashMap();
  bool isBlueToothLoading = false;
  // Initially set to true to show loader
<<<<<<< Updated upstream

  void apiCalls() async {
    print("working 1");
    await patchAPI()
        .fetchPatchData(id: buildingAllApi.selectedBuildingID)
        .then((value) {
      print("${value.patchData.toString()}");
      building.patchData[value.patchData!.buildingID!] = value;
      createPatch(value);
      tools.globalData = value;
      for (int i = 0; i < 4; i++) {
        tools.corners.add(math.Point(
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!),
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!)));
      }
    });
    print("working 2");
    await PolyLineApi()
        .fetchPolyData(id: buildingAllApi.selectedBuildingID)
        .then((value) {
      print("object ${value.polyline!.floors!.length}");
      building.polyLineData = value;
      building.numberOfFloors[buildingAllApi.selectedBuildingID] =
          value.polyline!.floors!.length;
      building.polylinedatamap[buildingAllApi.selectedBuildingID] = value;
      createRooms(value, 0);
    });
    building.floor[buildingAllApi.selectedBuildingID] = 0;
    print("working 3");
    building.landmarkdata = landmarkApi()
        .fetchLandmarkData(id: buildingAllApi.selectedBuildingID)
        .then((value) {
      print("Himanshuchecker ids ${value.landmarks![0].name}");
      Map<int, LatLng> coordinates = {};
      for (int i = 0; i < value.landmarks!.length; i++) {
        if (value.landmarks![i].floor == 3 &&
            value.landmarks![i].properties!.name != null) {
          landmarkListForFilter.add(FilterInfoModel(
              LandmarkLat: value.landmarks![i].coordinateX!,
              LandmarkLong: value.landmarks![i].coordinateY!,
              LandmarkName: value.landmarks![i].properties!.name ?? ""));
=======
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
    findNearbyLandmarkUsingGPS();
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
>>>>>>> Stashed changes
        }
        if (value.landmarks![i].element!.subType == "AR") {
          coordinates[int.parse(value.landmarks![i].properties!.arValue!)] =
              LatLng(double.parse(value.landmarks![i].properties!.latitude!),
                  double.parse(value.landmarks![i].properties!.longitude!));
        }
        if (value.landmarks![i].element!.type == "Floor") {
          List<int> allIntegers = [];
          String jointnonwalkable =
              value.landmarks![i].properties!.nonWalkableGrids!.join(',');
          RegExp regExp = RegExp(r'\d+');
          Iterable<Match> matches = regExp.allMatches(jointnonwalkable);
          for (Match match in matches) {
            String matched = match.group(0)!;
            allIntegers.add(int.parse(matched));
          }
          Map<int, List<int>> currrentnonWalkable =
              building.nonWalkable[value.landmarks![i].buildingID!] ?? Map();
          currrentnonWalkable[value.landmarks![i].floor!] = allIntegers;

          building.nonWalkable[value.landmarks![i].buildingID!] =
              currrentnonWalkable;
          UserState.nonWalkable = currrentnonWalkable;
          localizedData.nonWalkable = currrentnonWalkable;

          Map<int, List<int>> currentfloorDimenssion =
              building.floorDimenssion[buildingAllApi.selectedBuildingID] ??
                  Map();
          currentfloorDimenssion[value.landmarks![i].floor!] = [
            value.landmarks![i].properties!.floorLength!,
            value.landmarks![i].properties!.floorBreadth!
          ];

          building.floorDimenssion[buildingAllApi.selectedBuildingID] =
              currentfloorDimenssion!;
          localizedData.currentfloorDimenssion = currentfloorDimenssion;

          print("fetch route--  ${building.floorDimenssion}");

          // building.floorDimenssion[value.landmarks![i].floor!] = [
          //   value.landmarks![i].properties!.floorLength!,
          //   value.landmarks![i].properties!.floorBreadth!
          // ];
        }
      }
      createARPatch(coordinates);
      createMarkers(value, 0);
      return value;
    });
<<<<<<< Updated upstream
    print("working 4");
=======
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
    try {
      await DataVersionApi()
          .fetchDataVersionApiData(buildingAllApi.selectedBuildingID);
    } catch (e) {
      print(" APICALLS DataVersionApi API TRY-CATCH");
    }
    _updateProgress();
    print("apicalls testing 1");
    // await Future.wait(buildingAllApi.allBuildingID.entries.map((entry) async {
    //   var key = entry.key;
    //
    //   var beaconData = await beaconapi().fetchBeaconData(key);
    //   if (SingletonFunctionController.building.beacondata == null) {
    //     SingletonFunctionController.building.beacondata = List.from(beaconData);
    //   } else {
    //     SingletonFunctionController.building.beacondata = List.from(SingletonFunctionController.building.beacondata!)..addAll(beaconData);
    //   }
    //
    //   for (var beacon in beaconData) {
    //     if (beacon.name != null) {
    //       SingletonFunctionController.apibeaconmap[beacon.name!] = beacon;
    //     }
    //   }
    //   Building.apibeaconmap = SingletonFunctionController.apibeaconmap;
    // }));
    //
    // if(Platform.isAndroid){
    //   SingletonFunctionController.btadapter.startScanning(SingletonFunctionController.apibeaconmap);
    // }else{
    //   SingletonFunctionController.btadapter.startScanningIOS(SingletonFunctionController.apibeaconmap);
    // }\

    // Future<void> timer = Future.delayed(Duration(seconds:(widget.directsourceID.length<2)?SingletonFunctionController.btadapter.isScanningOn()==false?9:0:0));
    (SingletonFunctionController.btadapter.isScanningOn() == false &&
            isBinEmpty() == true)
        ? controller.executeFunction(buildingAllApi.allBuildingID)
        : null;

    setState(() {
      resBeacons = SingletonFunctionController.apibeaconmap;
    });
    print("apicalls testing 2");

    var patchData =
        await patchAPI().fetchPatchData(id: buildingAllApi.selectedBuildingID);
    Building.buildingData ??= Map();
    Building.buildingData![patchData.patchData!.buildingID!] =
        patchData.patchData!.buildingName;
    SingletonFunctionController
        .building.patchData[patchData.patchData!.buildingID!] = patchData;
    createPatch(patchData);
    findCentroid(
        patchData.patchData!.coordinates!, buildingAllApi.selectedBuildingID);

    tools.globalData = patchData;
    tools.setBuildingAngle(patchData.patchData!.buildingAngle!);

    for (var i = 0; i < 4; i++) {
      tools.corners.add(math.Point(
          double.parse(patchData.patchData!.coordinates![i].globalRef!.lat!),
          double.parse(patchData.patchData!.coordinates![i].globalRef!.lng!)));
    }
    print("apicalls testing 3");
    var polylineData = await PolyLineApi()
        .fetchPolyData(id: buildingAllApi.selectedBuildingID);
    SingletonFunctionController.building.polyLineData = polylineData;
    SingletonFunctionController
            .building.numberOfFloors[buildingAllApi.selectedBuildingID] =
        polylineData.polyline!.floors!.length;
    SingletonFunctionController.building
        .polylinedatamap[buildingAllApi.selectedBuildingID] = polylineData;

    List<int> currentBuildingFloor =
        polylineData.polyline!.floors!.map((element) {
      return tools.alphabeticalToNumerical(element.floor!);
    }).toList();

    Building.numberOfFloorsDelhi[buildingAllApi.selectedBuildingID] =
        currentBuildingFloor;
    createRooms(polylineData, 0);

    SingletonFunctionController
            .building.floor[buildingAllApi.selectedBuildingID] =
        buildingAllApi.selectedBuildingID == "666848685496124d04fc6761" ? 5 : 0;
    print("apicalls testing 4");
    var landmarkData = await landmarkApi()
        .fetchLandmarkData(id: buildingAllApi.selectedBuildingID);
    SingletonFunctionController.building.landmarkdata =
        Future.value(landmarkData);
    var coordinates = <int, LatLng>{};

    for (var landmark in landmarkData.landmarks!) {
      if (landmark.floor == 3 && landmark.properties!.name != null) {
        landmarkListForFilter.add(FilterInfoModel(
            LandmarkLat: landmark.coordinateX!,
            LandmarkLong: landmark.coordinateY!,
            LandmarkName: landmark.properties!.name ?? ""));
      }

      if (landmark.element!.subType == "AR") {
        coordinates[int.parse(landmark.properties!.arValue!)] = LatLng(
            double.parse(landmark.properties!.latitude!),
            double.parse(landmark.properties!.longitude!));
      }

      if (landmark.element!.type == "Floor") {
        var nonWalkableGrids = landmark.properties!.nonWalkableGrids!.join(',');
        var regExp = RegExp(r'\d+');
        var matches = regExp.allMatches(nonWalkableGrids);
        print("nonWalkableGrids");
        print(nonWalkableGrids);
        print(matches);
        var allIntegers =
            matches.map((match) => int.parse(match.group(0)!)).toList();

        var currentNonWalkable = SingletonFunctionController
                .building.nonWalkable[landmark.buildingID!] ??
            {};
        currentNonWalkable[landmark.floor!] = allIntegers;

        SingletonFunctionController.building.nonWalkable[landmark.buildingID!] =
            currentNonWalkable;
        UserState.nonWalkable =
            SingletonFunctionController.building.nonWalkable;
        localizedData.nonWalkable = currentNonWalkable;

        var currentFloorDimensions = SingletonFunctionController
                .building.floorDimenssion[buildingAllApi.selectedBuildingID] ??
            {};
        currentFloorDimensions[landmark.floor!] = [
          landmark.properties!.floorLength!,
          landmark.properties!.floorBreadth!
        ];

        SingletonFunctionController
                .building.floorDimenssion[buildingAllApi.selectedBuildingID] =
            currentFloorDimensions;
        localizedData.currentfloorDimenssion = currentFloorDimensions;
      }
    }
    if (SingletonFunctionController
            .building.floorDimenssion[buildingAllApi.selectedBuildingID] ==
        null) {
      sendErrorToSlack(
          "Floor data is null for ${buildingAllApi.selectedBuildingID}", null);
    }

    if (SingletonFunctionController.building.ARCoordinates
            .containsKey(buildingAllApi.selectedBuildingID) &&
        coordinates.isNotEmpty) {
      SingletonFunctionController.building
          .ARCoordinates[buildingAllApi.selectedBuildingID] = coordinates;
    }

    createARPatch(coordinates);
    createMarkers(landmarkData, 0, bid: buildingAllApi.selectedBuildingID);
    print("apicalls testing 5");
>>>>>>> Stashed changes
    await Future.delayed(Duration(seconds: 2));
    print("5 seconds over");
    setState(() {
      isBlueToothLoading = true;
      print("isBlueToothLoading");
      print(isBlueToothLoading);
    });
try{
  await beaconapi().fetchBeaconData().then((value) {
    print("beacondatacheck");

    building.beacondata = value;
    for (int i = 0; i < value.length; i++) {
      print(value[i].name);
      beacon beacons = value[i];
      if (beacons.name != null) {
        apibeaconmap[beacons.name!] = beacons;
      }
    }
    Building.apibeaconmap = apibeaconmap;

    print("scanningggg starteddddd");

    if (Platform.isAndroid) {
      print("starting scanning for android");
      btadapter.startScanning(apibeaconmap);
    } else {
      print("starting scanning for IOS");
      btadapter.startScanningIOS(apibeaconmap);
      // btadapter.strtScanningIos(apibeaconmap);
      // btadapter.getDevicesList();
    }

    //btadapter.startScanning(apibeaconmap);
    setState(() {
      resBeacons = apibeaconmap;
    });
    // print("printing bin");
    // btadapter.printbin();
    late Timer _timer;
    //please wait
    //searching your location

    speak("Please wait");
    speak("Searching your location. .");

    _timer = Timer.periodic(Duration(milliseconds: 9000), (timer) {
      localizeUser();

      print("localize user is calling itself.....");
      _timer.cancel();
    });
  });
}catch(e){
  print("no beacons found");
}

    print("Himanshuchecker ids 1 ${buildingAllApi.getStoredAllBuildingID()}");
    print("Himanshuchecker ids 2 ${buildingAllApi.getStoredString()}");
    print("Himanshuchecker ids 3 ${buildingAllApi.getSelectedBuildingID()}");

    List<String> IDS = [];
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) {
      IDS.add(key);
    });
    await outBuilding().outbuilding(IDS).then((out) async {
      if (out != null) {
        buildingAllApi.outdoorID = out!.data!.campusId!;
        buildingAllApi.allBuildingID[out!.data!.campusId!] =
            geo.LatLng(0.0, 0.0);
      }
    });

    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      IDS.add(key);
      if (key != buildingAllApi.getSelectedBuildingID()) {
        await patchAPI().fetchPatchData(id: key).then((value) {
          building.patchData[value.patchData!.buildingID!] = value;
          if (key == buildingAllApi.outdoorID) {
            createotherPatch(value);
          } else {}
        });

<<<<<<< Updated upstream
        await PolyLineApi().fetchPolyData(id: key).then((value) {
          if (key == buildingAllApi.outdoorID) {
            createRooms(value, 1);
          } else {
            createRooms(value, 0);
          }
          building.polylinedatamap[key] = value;
          building.numberOfFloors[key] = value.polyline!.floors!.length;
          //building.polyLineData!.polyline!.mergePolyline(value.polyline!.floors);
        });

        await landmarkApi().fetchLandmarkData(id: key).then((value) async {
          await building.landmarkdata!.then((Value) {
            Value.mergeLandmarks(value.landmarks);
          });
          Map<int, LatLng> coordinates = {};
          for (int i = 0; i < value.landmarks!.length; i++) {
            if (value.landmarks![i].element!.subType == "AR" &&
                value.landmarks![i].properties!.arName ==
                    "P${int.parse(value.landmarks![i].properties!.arValue!)}") {
              coordinates[int.parse(value.landmarks![i].properties!.arValue!)] =
                  LatLng(
                      double.parse(value.landmarks![i].properties!.latitude!),
                      double.parse(value.landmarks![i].properties!.longitude!));
            }
            if (value.landmarks![i].element!.type == "Floor") {
              List<int> allIntegers = [];
              String jointnonwalkable =
                  value.landmarks![i].properties!.nonWalkableGrids!.join(',');
              RegExp regExp = RegExp(r'\d+');
              Iterable<Match> matches = regExp.allMatches(jointnonwalkable);
              for (Match match in matches) {
                String matched = match.group(0)!;
                allIntegers.add(int.parse(matched));
              }
              Map<int, List<int>> currrentnonWalkable =
                  building.nonWalkable[key] ?? Map();
              currrentnonWalkable[value.landmarks![i].floor!] = allIntegers;
              building.nonWalkable[key] = currrentnonWalkable;

              Map<int, List<int>> currentfloorDimenssion =
                  building.floorDimenssion[key] ?? Map();
              currentfloorDimenssion[value.landmarks![i].floor!] = [
                value.landmarks![i].properties!.floorLength!,
                value.landmarks![i].properties!.floorBreadth!
              ];
              building.floorDimenssion[key] = currentfloorDimenssion!;
              // print("fetch route--  ${building.floorDimenssion}");

              // building.floorDimenssion[value.landmarks![i].floor!] = [
              //   value.landmarks![i].properties!.floorLength!,
              //   value.landmarks![i].properties!.floorBreadth!
              // ];
            }
          }
          createotherARPatch(coordinates, value.landmarks![0].buildingID!);
        });
        await beaconapi().fetchBeaconData(id: key).then((value) {
          // print("beacondatacheck");
          //
          // building.beacondata = value;
          // for (int i = 0; i < value.length; i++) {
          //   print(value[i].name);
          //   beacon beacons = value[i];
          //   if (beacons.name != null) {
          //     apibeaconmap[beacons.name!] = beacons;
          //   }
          // }
          // Building.apibeaconmap = apibeaconmap;
          //
          // print("scanningggg starteddddd");
          //
          // if (Platform.isAndroid) {
          //   btadapter.startScanning(apibeaconmap);
          // } else {
          //   btadapter.strtScanningIos(apibeaconmap);
          // }
          //
          // // btadapter.startScanning(apibeaconmap);
          // setState(() {
          //   resBeacons = apibeaconmap;
          // });
          // // print("printing bin");
          // // btadapter.printbin();
          // late Timer _timer;
          // //please wait
          // //searching your location
          //
          // speak("Please wait");
          // speak("Searching your location. .");
          //
          // _timer = Timer.periodic(Duration(milliseconds: 9000), (timer) {
          //   localizeUser();
          //
          //   print("localize user is calling itself.....");
          //   _timer.cancel();
          // });
        });
      }
    });
=======
    try {
      var outBuildingData = await outBuilding().outbuilding(ids);
      if (outBuildingData != null) {
        buildingAllApi.outdoorID = outBuildingData.data!.campusId!;
        buildingAllApi.allBuildingID[outBuildingData.data!.campusId!] =
            LatLng(0.0, 0.0);
      }
      print("apicalls testing 6");
    } catch (_) {}
    print("apicalls testing 7");
    Future<void> allBuildingCalls = Future.wait(
        buildingAllApi.getStoredAllBuildingID().entries.map((entry) async {
      var key = entry.key;

      SingletonFunctionController.building.floor[key] = 0;
      print("apicalls testing 1 for $key");
      try {
        var waypointData = await waypointapi()
            .fetchwaypoint(key, outdoor: key == buildingAllApi.outdoorID);
        Building.waypoint[key] = waypointData;
      } catch (_) {}
      print("apicalls testing 2 for $key");
      if (key != buildingAllApi.getSelectedBuildingID()) {
        try {
          await DataVersionApi().fetchDataVersionApiData(key);
        } catch (e) {}
        print("apicalls testing 3 for $key");
        var patchData = await patchAPI().fetchPatchData(id: key);
        Building.buildingData ??= Map();

        Building.buildingData![patchData.patchData!.buildingID!] =
            patchData.patchData!.buildingName;
        SingletonFunctionController
            .building.patchData[patchData.patchData!.buildingID!] = patchData;
        createotherPatch(key, patchData);

        findCentroid(patchData.patchData!.coordinates!, key);
        print("apicalls testing 4 for $key");
        var polylineData = await PolyLineApi()
            .fetchPolyData(id: key, outdoor: key == buildingAllApi.outdoorID);
        SingletonFunctionController.building.polylinedatamap[key] =
            polylineData;
        SingletonFunctionController.building.numberOfFloors[key] =
            polylineData.polyline!.floors!.length;

        List<int> currentBuildingFloor =
            polylineData.polyline!.floors!.map((element) {
          return tools.alphabeticalToNumerical(element.floor!);
        }).toList();

        Building.numberOfFloorsDelhi[key] = currentBuildingFloor;

        createRooms(polylineData, 0);
        print("apicalls testing 5 for $key");
        var otherLandmarkData = await landmarkApi().fetchLandmarkData(
            id: key, outdoor: key == buildingAllApi.outdoorID);
        var otherLandmarkdata =
            await SingletonFunctionController.building.landmarkdata;
        otherLandmarkdata?.mergeLandmarks(otherLandmarkData.landmarks);

        var otherCoordinates = <int, LatLng>{};
        for (var landmark in otherLandmarkData.landmarks!) {
          if (landmark.element!.subType == "AR" &&
              landmark.properties!.arName ==
                  "P${int.parse(landmark.properties!.arValue!)}") {
            otherCoordinates[int.parse(landmark.properties!.arValue!)] = LatLng(
                double.parse(landmark.properties!.latitude!),
                double.parse(landmark.properties!.longitude!));
          }

          if (landmark.element!.type == "Floor") {
            var nonWalkableGrids =
                landmark.properties!.nonWalkableGrids!.join(',');
            var regExp = RegExp(r'\d+');
            var matches = regExp.allMatches(nonWalkableGrids);
            var allIntegers =
                matches.map((match) => int.parse(match.group(0)!)).toList();

            var currentNonWalkable =
                SingletonFunctionController.building.nonWalkable[key] ?? {};
            currentNonWalkable[landmark.floor!] = allIntegers;

            SingletonFunctionController.building.nonWalkable[key] =
                currentNonWalkable;

            var currentFloorDimensions =
                SingletonFunctionController.building.floorDimenssion[key] ?? {};
            currentFloorDimensions[landmark.floor!] = [
              landmark.properties!.floorLength!,
              landmark.properties!.floorBreadth!
            ];

            SingletonFunctionController.building.floorDimenssion[key] =
                currentFloorDimensions;
          }
        }
        if (SingletonFunctionController.building.floorDimenssion[key] == null) {
          sendErrorToSlack("Floor data is null for ${key}", null);
        }
        createMarkers(otherLandmarkData, 0, bid: key);
        createotherARPatch(
            otherCoordinates, otherLandmarkData.landmarks![0].buildingID!);
        print("apicalls testing 6 for $key");
      }
    }));

    if (SingletonFunctionController.timer != null) {
      await Future.wait([SingletonFunctionController.timer!, allBuildingCalls]);
    }
    print("apicalls testing 8");
    if (widget.directLandID.length < 2) {
      print("apicalls testing 9");
      localizeUser();
    } else {
      print("apicalls testing 10");
      SingletonFunctionController.btadapter.stopScanning();
      //got here using a destination qr
      localizeUser(speakTTS: false);
      onLandmarkVenueClicked(widget.directLandID,
          DirectlyStartNavigation: false);
      SingletonFunctionController.building.destinationQr = true;
      print("apicalls testing 11");
    }
>>>>>>> Stashed changes

    print("apicalls testing 12");
    buildingAllApi.setStoredString(buildingAllApi.getSelectedBuildingID());
<<<<<<< Updated upstream
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isLoading = false;
      isBlueToothLoading = false;
      print("isBlueToothLoading");
      print(isBlueToothLoading);
    });
    print("Circular progress stop");
=======
    print("apicalls testing 13");
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      print("apicalls testing 14");
      setState(() {
        isLoading = false;
        isBlueToothLoading = false;
      });
      print("apicalls testing 15");
    }
  }

  var versionBox = Hive.box('VersionData');
  final DataVersionLocalModelBox = DataVersionLocalModelBOX.getData();

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
    final Circle updatedCircle = Circle(
      circleId: CircleId("circle"),
      center: LatLng(lat, lng),
      radius: _animation.value,
      strokeWidth: 1,
      strokeColor: Colors.blue,
      fillColor: Colors.lightBlue.withOpacity(0.2),
    );
    if (mounted) {
      setState(() {
        circles.removeWhere((circle) => circle.circleId == CircleId("circle"));
        circles.add(updatedCircle);
      });
    }
  }

  void updateCircle(double lat, double lng,
      {double begin = 7, double end = 0}) {
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
        );

        setState(() {
          circles
              .removeWhere((circle) => circle.circleId == CircleId("circle"));
          circles.add(updatedCircle);
        });
      });
    // Start the animation
    _controller.forward(from: 0.0);
>>>>>>> Stashed changes
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

  late nearestLandInfo nearestLandInfomation;

<<<<<<< Updated upstream
  Future<void> localizeUser() async {
    print("Beacon searching started");
    double highestweight = 0;
    String nearestBeacon = "";
    print("btadapter.BIN");
    print(btadapter.BIN);

    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          if (value > highestweight) {
            highestweight = value;
            nearestBeacon = key;
          }
        });
        break;
=======
  Future<void> localizeUser({bool speakTTS = true}) async {
    double highestweight = 0;
    String nearestBeacon = "";

    if (await FlutterBluePlus.isOn) {
      for (int i = 0;
          i < SingletonFunctionController.btadapter.BIN.length;
          i++) {
        if (SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty) {
          SingletonFunctionController.btadapter.BIN[i]!.forEach((key, value) {
            if (value < 0) {
              value = value * -1;
            }
            if (value > highestweight) {
              highestweight = value;
              nearestBeacon = key;
            }
          });
          break;
        }
>>>>>>> Stashed changes
      }
    }
    setState(() {
      //lastBeaconValue = nearestBeacon;
    });

    nearestLandmarkToBeacon = nearestBeacon;
    nearestLandmarkToMacid = highestweight.toString();

    setState(() {
      testBIn = btadapter.BIN;
      testBIn.forEach((key, value) {
        currentBinSIze.add(value.length);
      });
    });
<<<<<<< Updated upstream
    btadapter.stopScanning();

    // sumMap = btadapter.calculateAverage();
    paintUser(nearestBeacon);
=======
    SingletonFunctionController.btadapter.stopScanning();

    // sumMap = SingletonFunctionController.btadapter.calculateAverage();
    if (nearestBeacon != "" && Building.apibeaconmap[nearestBeacon] != null) {
      buildingAllApi
          .setStoredString(Building.apibeaconmap[nearestBeacon]!.buildingID!);
      buildingAllApi.selectedID =
          Building.apibeaconmap[nearestBeacon]!.buildingID!;
      buildingAllApi.selectedBuildingID =
          Building.apibeaconmap[nearestBeacon]!.buildingID!;
    }
    paintUser(nearestBeacon, speakTTS: speakTTS);
    Future.delayed(Duration(milliseconds: 1500)).then((value) => {
          _controller.stop(),
        });
>>>>>>> Stashed changes

    //emptying the bin manually
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }
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

  Future<void> realTimeReLocalizeUser(
      HashMap<String, beacon> apibeaconmap) async {
    sumMap.clear();
    setState(() {
      sumMap = btadapter.calculateAverage();
    });

    String firstValue = "";

    if (sumMap.isNotEmpty) {
      Map<String, double> sortedsumMap = sortMapByValue(sumMap);
      firstValue = sortedsumMap.entries.first.key;

      if (lastBeaconValue != firstValue &&
          sortedsumMap.entries.first.value >= 0.5) {
        btadapter.stopScanning();

        await building.landmarkdata!.then((value) {
          getallnearestInfo = tools.localizefindAllNearbyLandmark(
              apibeaconmap[firstValue]!, value.landmarksMap!);
        });

        List<int> tv = tools.eightcelltransition(user.theta);
        finalDirections = calcDirectionsExploreMode([
          apibeaconmap[firstValue]!.coordinateX!,
          apibeaconmap[firstValue]!.coordinateY!
        ], [
          apibeaconmap[firstValue]!.coordinateX! + tv[0],
          apibeaconmap[firstValue]!.coordinateY! + tv[1]
        ], getallnearestInfo);
        paintUser(firstValue);
        ExploreModePannelController.open();
        setState(() {
          lastBeaconValue = firstValue;
        });
        btadapter.emptyBin();
      } else {
        //HelperClass.showToast("Beacon Already scanned");
      }
    }
  }

  void createPatch(patchDataModel value) async {
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

      for (int i = 0; i < 4; i++) {
<<<<<<< Updated upstream
=======
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======

      SingletonFunctionController.building
          .ARCoordinates[buildingAllApi.selectedBuildingID] = coordinates;

>>>>>>> Stashed changes
      setState(() {
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
      });

      try {
        fitPolygonInScreen(patch.first);
      } catch (e) {}
    }
  }

<<<<<<< Updated upstream
  void createotherPatch(patchDataModel value) async {
=======
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

  void createotherPatch(String key, patchDataModel value) async {
>>>>>>> Stashed changes
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

      for (int i = 0; i < 4; i++) {
<<<<<<< Updated upstream
=======
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

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
      SingletonFunctionController.building.ARCoordinates[key] = coordinates;

>>>>>>> Stashed changes
      setState(() {
        otherpatch.add(
          Polygon(
              polygonId: PolygonId('otherpatch ${value.patchData!.buildingID}'),
              points: polygonPoints,
              strokeWidth: 1,
              strokeColor: Color(0xffC0C0C0),
              fillColor: Color(0xffffffff),
              geodesic: false,
              consumeTapEvents: true,
              zIndex: -1),
        );
      });
    }
  }
<<<<<<< Updated upstream
=======

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

  renderCampusPatchTransition(String outDoorID) {
    blurPatch.clear();
    restBuildingMarker.clear();
    Map<int, LatLng> currentCoordinated = {};

    SingletonFunctionController.building.ARCoordinates.forEach((key, innerMap) {
      if (key == outDoorID) {
        currentCoordinated = innerMap;
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
            blurPatch.add(
              Polygon(
                polygonId: PolygonId('patch${points}'),
                points: points,
                strokeWidth: 1,
                strokeColor: Colors.black,
                fillColor: Color(0xffE5F9FF),
                geodesic: false,
                consumeTapEvents: true,
                zIndex: 5,
              ),
            );
          });
        }
        Building.allBuildingID.forEach((Key, Value) async {
          if (Key == outDoorID) {
            String? showBuildingName = "";
            Building.buildingData?.forEach((currKey, currValue) {
              if (currKey == Key) {
                showBuildingName = currValue;
              }
            });
            restBuildingMarker.add(
              Marker(
                markerId: MarkerId(Key + Value.toString()),
                position: Value,
                icon: await bitmapDescriptorFromTextAndImageForPatchTransition(
                    showBuildingName ?? "", 'assets/cleanenergy.png',
                    imageSize: const Size(100, 100)),
              ),
            );
          }
        });
      }
    });
  }

  Set<Marker> restBuildingMarker = Set();
  void patchTransition(String skipID) {
    Map<int, LatLng> currentCoordinated = {};
    blurPatch.clear();


    SingletonFunctionController.building.ARCoordinates.forEach((key, innerMap) {
      //print("ARCoordinateskeys ${key}");

      if (key != buildingAllApi.outdoorID) {
        if (PathState.sourceBid != "" && PathState.destinationBid == "") {
          if (key != skipID && key != PathState.sourceBid) {
            currentCoordinated = innerMap;
            patchGeneration(currentCoordinated);
            patchGenerationMarker(
                [skipID, PathState.sourceBid, buildingAllApi.outdoorID]);
          }
        } else if (PathState.destinationBid != "" &&
            PathState.sourceBid == "") {
          if (key != skipID && key != PathState.destinationBid) {
            currentCoordinated = innerMap;
            patchGeneration(currentCoordinated);
            patchGenerationMarker(
                [skipID, PathState.destinationBid, buildingAllApi.outdoorID]);
          }
        } else if (PathState.destinationBid != "" &&
            PathState.sourceBid != "") {
          if (key != skipID &&
              key != PathState.destinationBid &&
              key != PathState.sourceBid) {
            currentCoordinated = innerMap;
            patchGeneration(currentCoordinated);

            patchGenerationMarker([
              skipID,
              PathState.destinationBid,
              PathState.sourceBid,
              buildingAllApi.outdoorID
            ]);
          }
        } else {
          if (key != skipID) {
            currentCoordinated = innerMap;
            patchGeneration(currentCoordinated);
            patchGenerationMarker([skipID, buildingAllApi.outdoorID]);
          }
        }
      }
    });
  }

  void patchGeneration(Map<int, LatLng> currentCoordinated) {
    print("patchGeneration");
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
        blurPatch.add(
          Polygon(
            polygonId: PolygonId('patch${points}'),
            points: points,
            strokeWidth: 1,
            strokeColor: Colors.black,
            fillColor: Color(0xffE5F9FF),
            geodesic: false,
            consumeTapEvents: true,
            zIndex: 5,
          ),
        );
      });
    }
  }

  void patchGenerationMarker(List<String> skipIDs) {
    restBuildingMarker.clear();
    Building.allBuildingID.forEach((Key, Value) async {
      if (!skipIDs.contains(Key)) {
        String? showBuildingName = "";
        Building.buildingData?.forEach((currKey, currValue) {
          if (currKey == Key) {
            showBuildingName = currValue;
          }
        });
        restBuildingMarker.add(
          Marker(
            markerId: MarkerId(Key + Value.toString()),
            position: Value,
            icon: await bitmapDescriptorFromTextAndImageForPatchTransition(
                showBuildingName ?? "", 'assets/cleanenergy.png',
                imageSize: const Size(100, 100)),
          ),
        );
      }
    });
  }
>>>>>>> Stashed changes

  void createARPatch(Map<int, LatLng> coordinates) async {
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
      setState(() {
        patch.clear();
        patch.add(
          Polygon(
              polygonId: PolygonId('patch'),
              points: points,
              strokeWidth: 1,
              strokeColor: Color(0xffC0C0C0),
              fillColor: Color(0xffffffff),
              geodesic: false,
              consumeTapEvents: true,
              zIndex: -1),
        );
      });
    }
  }

  void createotherARPatch(Map<int, LatLng> coordinates, String bid) async {
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
<<<<<<< Updated upstream
=======
      if (SingletonFunctionController.building.ARCoordinates.containsKey(bid)) {
        SingletonFunctionController.building.ARCoordinates[bid] = coordinates;
      }

>>>>>>> Stashed changes
      setState(() {
        otherpatch
            .removeWhere((element) => element.polygonId.value.contains(bid));
        otherpatch.add(
          Polygon(
              polygonId: PolygonId('otherpatch $bid'),
              points: points,
              strokeWidth: 1,
              strokeColor: Color(0xffC0C0C0),
              fillColor: Color(0xffffffff),
              geodesic: false,
              consumeTapEvents: true,
              zIndex: -1),
        );
      });
    }
  }

  Future<void> addselectedRoomMarker(List<LatLng> polygonPoints) async {
    selectedroomMarker.clear(); // Clear existing markers
<<<<<<< Updated upstream
=======
    _polygon.clear(); // Clear existing markers
    _polygon.add(Polygon(
      polygonId: PolygonId("$polygonPoints"),
      points: polygonPoints,
      fillColor: color != null
          ? color.withOpacity(0.4)
          : Colors.lightBlueAccent.withOpacity(0.4),
      strokeColor: color ?? Colors.blue,
      strokeWidth: 2,
    )); // Clear existing markers

    List<geo.LatLng> points = [];
    for (var e in polygonPoints) {
      points.add(geo.LatLng(e.latitude, e.longitude));
    }
    Uint8List iconMarker =
        await getImagesFromMarker('assets/IwaymapsDefaultMarker.png', 140);
>>>>>>> Stashed changes
    setState(() {
      if (selectedroomMarker.containsKey(buildingAllApi.getStoredString())) {
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
              markerId: MarkerId('selectedroomMarker'),
              position: calculateRoomCenter(polygonPoints),
              icon: BitmapDescriptor.fromBytes(iconMarker),
              onTap: () {}),
        );
      } else {
        selectedroomMarker[buildingAllApi.getStoredString()] = Set<Marker>();
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
              markerId: MarkerId('selectedroomMarker'),
              position: calculateRoomCenter(polygonPoints),
              icon: BitmapDescriptor.fromBytes(iconMarker),
              onTap: () {}),
        );
      }
    });
  }

  Future<void> addselectedMarker(LatLng Point) async {
    selectedroomMarker.clear(); // Clear existing markers

    setState(() {
      if (selectedroomMarker.containsKey(buildingAllApi.getStoredString())) {
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
            markerId: MarkerId('selectedroomMarker'),
            position: Point,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      } else {
        selectedroomMarker[buildingAllApi.getStoredString()] = Set<Marker>();
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
            markerId: MarkerId('selectedroomMarker'),
            position: Point,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }
    });
  }

  LatLng calculateRoomCenter(List<LatLng> polygonPoints) {
    double lat = 0.0;
    double long = 0.0;
    if (polygonPoints.length <= 4) {
      for (int i = 0; i < polygonPoints.length; i++) {
        lat = lat + polygonPoints[i].latitude;
        long = long + polygonPoints[i].longitude;
      }
      return LatLng(lat / polygonPoints.length, long / polygonPoints.length);
    } else {
      for (int i = 0; i < 4; i++) {
        lat = lat + polygonPoints[i].latitude;
        long = long + polygonPoints[i].longitude;
      }
      return LatLng(lat / 4, long / 4);
    }
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
    _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 0));
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
          100.0, // padding to adjust the bounding box on the screen
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
<<<<<<< Updated upstream
          100.0, // padding to adjust the bounding box on the screen
        ),
      );
=======
          200.0, // padding to adjust the bounding box on the screen
        ),
      );
    }
  }

  Future<void> setCameraPositionusingCoords(List<LatLng> selectedroomMarker1, {List<LatLng>? selectedroomMarker2 = null}) async {
    if(Platform.isAndroid){
      double minLat = double.infinity;
      double minLng = double.infinity;
      double maxLat = double.negativeInfinity;
      double maxLng = double.negativeInfinity;

      if (selectedroomMarker2 == null) {
        for (LatLng marker in selectedroomMarker1) {
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

        _googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            200.0, // padding to adjust the bounding box on the screen
          ),
        );
      } else {
        for (LatLng marker in selectedroomMarker1) {
          double lat = marker.latitude;
          double lng = marker.longitude;

          minLat = math.min(minLat, lat);
          minLng = math.min(minLng, lng);
          maxLat = math.max(maxLat, lat);
          maxLng = math.max(maxLng, lng);
        }
        for (LatLng marker in selectedroomMarker2) {
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

        _googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            200.0, // padding to adjust the bounding box on the screen
          ),
        );
      }
    }else{
      double minLat = double.infinity;
      double minLng = double.infinity;
      double maxLat = double.negativeInfinity;
      double maxLng = double.negativeInfinity;

      if (selectedroomMarker2 == null) {
        for (LatLng marker in selectedroomMarker1) {
          double lat = marker.latitude;
          double lng = marker.longitude;

          minLat = math.min(minLat, lat);
          minLng = math.min(minLng, lng);
          maxLat = math.max(maxLat, lat);
          maxLng = math.max(maxLng, lng);
        }
        double bearing = tools.calculateBearing_fromLatLng(selectedroomMarker1.first, selectedroomMarker1.last);
        LatLng center = LatLng(
          (minLat + maxLat) / 2,
          (minLng + maxLng) / 2,
        );
        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );

        await _googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            60.0, // padding to adjust the bounding box on the screen
          ),
        );
        await Future.delayed(Duration(milliseconds: 100));

        _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: center,
              zoom: await _googleMapController.getZoomLevel(),
              bearing: bearing,
            ),
          ),
        );


      } else {
        for (LatLng marker in selectedroomMarker1) {
          double lat = marker.latitude;
          double lng = marker.longitude;

          minLat = math.min(minLat, lat);
          minLng = math.min(minLng, lng);
          maxLat = math.max(maxLat, lat);
          maxLng = math.max(maxLng, lng);
        }
        for (LatLng marker in selectedroomMarker2) {
          double lat = marker.latitude;
          double lng = marker.longitude;

          minLat = math.min(minLat, lat);
          minLng = math.min(minLng, lng);
          maxLat = math.max(maxLat, lat);
          maxLng = math.max(maxLng, lng);
        }

        double bearing = tools.calculateBearing_fromLatLng(selectedroomMarker1.first, selectedroomMarker1.last);
        LatLng center = LatLng(
          (minLat + maxLat) / 2,
          (minLng + maxLng) / 2,
        );

        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );

        await _googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            60.0, // padding to adjust the bounding box on the screen
          ),
        );
        await Future.delayed(Duration(milliseconds: 100));
        _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: center,
              zoom: await _googleMapController.getZoomLevel(),
              bearing: bearing,
            ),
          ),
        );

      }
>>>>>>> Stashed changes
    }
  }

  List<PolyArray> findLift(String floor, List<Floors> floorData) {
    List<PolyArray> lifts = [];
    floorData.forEach((Element) {
      if (Element.floor == floor) {
        Element.polyArray!.forEach((element) {
          if (element.cubicleName!.toLowerCase().contains("lift")) {
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
<<<<<<< Updated upstream
        if (l1.cubicleName!.toLowerCase() != "lift" &&
            l2.cubicleName!.toLowerCase() != "lift" &&
            l1.cubicleName == l2.cubicleName) {
          print("i ${l1.cubicleName}");
          print("y ${l2.cubicleName}");
=======

        if (l1.name!.toLowerCase().contains("lift") &&
            l2.name!.toLowerCase().contains("lift") &&
            l1.name!.length > 4 &&
            l1.name == l2.name) {
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
          print("11 ${[x1, y1]}");
          print("22 ${[x2, y2]}");
=======
>>>>>>> Stashed changes
        }
      }
    }
    return diff;
  }

  void createRooms(polylinedata value, int floor) {
    if (closedpolygons[buildingAllApi.getStoredString()] == null) {
      closedpolygons[buildingAllApi.getStoredString()] = Set();
    }

    closedpolygons[value.polyline!.buildingID!]?.clear();
<<<<<<< Updated upstream
    print(
        "createroomschecker ${closedpolygons[buildingAllApi.getStoredString()]}");
    selectedroomMarker.clear();
    _isLandmarkPanelOpen = false;
    building.selectedLandmarkID = null;
=======

    if (widget.directLandID.length < 2) {
      selectedroomMarker.clear();
      _isLandmarkPanelOpen = false;
      SingletonFunctionController.building.selectedLandmarkID = null;
    }
>>>>>>> Stashed changes
    polylines[value.polyline!.buildingID!]?.clear();

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
          if (polyArray.visibilityType == "visible") {
            List<LatLng> coordinates = [];

            for (Nodes node in polyArray.nodes!) {
              //coordinates.add(LatLng(node.lat!,node.lon!));
              coordinates.add(LatLng(
<<<<<<< Updated upstream
                  tools.localtoglobal(node.coordx!, node.coordy!,
                      patchData:
                          building.patchData[value.polyline!.buildingID])[0],
                  tools.localtoglobal(node.coordx!, node.coordy!,
                      patchData:
                          building.patchData[value.polyline!.buildingID])[1]));
=======
                  tools.localtoglobal(
                      node.coordx!,
                      node.coordy!,
                      SingletonFunctionController
                          .building.patchData[value.polyline!.buildingID])[0],
                  tools.localtoglobal(
                      node.coordx!,
                      node.coordy!,
                      SingletonFunctionController
                          .building.patchData[value.polyline!.buildingID])[1]));
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                        : Colors.black,
=======
                        : Color(0xffC0C0C0),
>>>>>>> Stashed changes
                    width: 1,
                    onTap: () {}));
              }
            } else if (polyArray.polygonType == 'Room') {
              print("polyArray.name");
              print(polyArray.name);

<<<<<<< Updated upstream
                    strokeColor: Colors.black,
                    fillColor: polyArray.cubicleColor != null &&
                            polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                            '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Color(0xffE5F9FF),
                    consumeTapEvents: true,
                    onTap: () {
                      _googleMapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          tools.calculateRoomCenterinLatLng(coordinates),
                          22,
                        ),
                      );
                      setState(() {
                        if (building.selectedLandmarkID != polyArray.id &&
                            !user.isnavigating &&
                            !_isRoutePanelOpen) {
                          user.reset();
                          PathState = pathState.withValues(
                              -1, -1, -1, -1, -1, -1, null, 0);
                          pathMarkers.clear();
                          PathState.path.clear();
                          PathState.sourcePolyID = "";
                          PathState.destinationPolyID = "";
                          singleroute.clear();

                          user.isnavigating = false;
                          _isnavigationPannelOpen = false;
                          building.selectedLandmarkID = polyArray.id;
                          building.ignoredMarker.clear();
                          building.ignoredMarker.add(polyArray.id!);
                          _isBuildingPannelOpen = false;
                          _isRoutePanelOpen = false;
                          singleroute.clear();
                          _isLandmarkPanelOpen = true;
                          PathState.directions = [];
                          interBuildingPath.clear();
                          addselectedRoomMarker(coordinates);
                        }
                      });
                    }));
              }
            } else if (polyArray.polygonType == 'Cubicle') {
              if (polyArray.cubicleName == "Green Area") {
=======
              if (polyArray.name!.toLowerCase().contains('lr') ||
                  polyArray.name!.toLowerCase().contains('lab') ||
                  polyArray.name!.toLowerCase().contains('office') ||
                  polyArray.name!.toLowerCase().contains('pantry') ||
                  polyArray.name!.toLowerCase().contains('reception')) {
                print("COntaining LA");
>>>>>>> Stashed changes
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

<<<<<<< Updated upstream
                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffC2F1D5),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("lift")) {
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
                          : Color(0xffFFFF00),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
=======
                      strokeColor: Color(0xffA38F9F),
                      fillColor: Color(0xffE8E3E7),
                      consumeTapEvents: true,
                      onTap: () {
                        _googleMapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            tools.calculateRoomCenterinLatLng(coordinates),
                            22,
                          ),
                        );
                        setState(() {
                          if (SingletonFunctionController
                                      .building.selectedLandmarkID !=
                                  polyArray.id &&
                              !user.isnavigating &&
                              !_isRoutePanelOpen) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1, -1, -1, -1, -1, -1, null, 0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            interBuildingPath.clear();
                            addselectedRoomMarker(coordinates);
                          }
                        });
                      }));
                }
              } else if (polyArray.name!.toLowerCase().contains('atm') ||
                  polyArray.name!.toLowerCase().contains('health')) {
                print("COntaining LA");
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffE99696),
                      fillColor: Color(0xffFBEAEA),
                      consumeTapEvents: true,
                      onTap: () {
                        _googleMapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            tools.calculateRoomCenterinLatLng(coordinates),
                            22,
                          ),
                        );
                        setState(() {
                          if (SingletonFunctionController
                                      .building.selectedLandmarkID !=
                                  polyArray.id &&
                              !user.isnavigating &&
                              !_isRoutePanelOpen) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1, -1, -1, -1, -1, -1, null, 0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            interBuildingPath.clear();
                            addselectedRoomMarker(coordinates);
                          }
                        });
                      }));
                }
              } else {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffA38F9F),
                      fillColor: Color(0xffE8E3E7),
                      consumeTapEvents: true,
                      onTap: () {
                        _googleMapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            tools.calculateRoomCenterinLatLng(coordinates),
                            22,
                          ),
                        );
                        setState(() {
                          if (SingletonFunctionController
                                      .building.selectedLandmarkID !=
                                  polyArray.id &&
                              !user.isnavigating &&
                              !_isRoutePanelOpen) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1, -1, -1, -1, -1, -1, null, 0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            interBuildingPath.clear();
                            addselectedRoomMarker(coordinates);
                          }
                        });
                      }));
                }
              }
            } else if (polyArray.polygonType == 'Cubicle') {
              if (polyArray.cubicleName == "Green Area" ||
                  polyArray.cubicleName == "Green Area | Pots" ||
                  polyArray.name!.toLowerCase().contains('auditorium') ||
                  polyArray.name!.toLowerCase().contains('basketball') ||
                  polyArray.name!.toLowerCase().contains('cricket') ||
                  polyArray.name!.toLowerCase().contains('football') ||
                  polyArray.name!.toLowerCase().contains('gym') ||
                  polyArray.name!.toLowerCase().contains('swimming') ||
                  polyArray.name!.toLowerCase().contains('tennis')) {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffADFA9E),
                      fillColor: Color(0xffE7FEE9),
                      onTap: () {}));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("lift")) {
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
                      fillColor: Color(0xffDAE6F1),
                      onTap: () {
                        _googleMapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            tools.calculateRoomCenterinLatLng(coordinates),
                            22,
                          ),
                        );
                        setState(() {
                          if (SingletonFunctionController
                                      .building.selectedLandmarkID !=
                                  polyArray.id &&
                              !user.isnavigating &&
                              !_isRoutePanelOpen) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1, -1, -1, -1, -1, -1, null, 0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            interBuildingPath.clear();
                            addselectedRoomMarker(coordinates,
                                color: Colors.greenAccent);
                          }
                        });
>>>>>>> Stashed changes
                      }));
                }
              } else if (polyArray.cubicleName == "Male Washroom") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
<<<<<<< Updated upstream

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xff0000FF),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
=======
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: Color(0xFFE7F4FE),
                      onTap: () {
                        _googleMapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            tools.calculateRoomCenterinLatLng(coordinates),
                            22,
                          ),
                        );
                        setState(() {
                          if (SingletonFunctionController
                                      .building.selectedLandmarkID !=
                                  polyArray.id &&
                              !user.isnavigating &&
                              !_isRoutePanelOpen) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1, -1, -1, -1, -1, -1, null, 0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            interBuildingPath.clear();
                            addselectedRoomMarker(coordinates,
                                color: Colors.white);
                          }
                        });
>>>>>>> Stashed changes
                      }));
                }
              } else if (polyArray.cubicleName == "Female Washroom") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
<<<<<<< Updated upstream

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffFF69B4),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
=======
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: Color(0xFFE7F4FE),
                      onTap: () {
                        _googleMapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            tools.calculateRoomCenterinLatLng(coordinates),
                            22,
                          ),
                        );
                        setState(() {
                          if (SingletonFunctionController
                                      .building.selectedLandmarkID !=
                                  polyArray.id &&
                              !user.isnavigating &&
                              !_isRoutePanelOpen) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1, -1, -1, -1, -1, -1, null, 0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            interBuildingPath.clear();
                            addselectedRoomMarker(coordinates,
                                color: Colors.white);
                          }
                        });
>>>>>>> Stashed changes
                      }));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("fire")) {
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
<<<<<<< Updated upstream
                          : Color(0xffFF4500),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
=======
                          : Color(0xffF21D0D),
                      onTap: () {}));
>>>>>>> Stashed changes
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("water")) {
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
<<<<<<< Updated upstream
                          : Color(0xff00FFFF),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
=======
                          : Color(0xffE7F4FE),
                      onTap: () {}));
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                          : Color(0xffCCCCCC),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
=======
                          : Color(0xffffffff),
                      onTap: () {}));
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                          : Color(0xff800000),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
=======
                          : Color(0xffE6E6E6),
                      onTap: () {}));
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                          : Color(0xff333333),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
=======
                          : Color(0xffE6E6E6),
                      onTap: () {}));
>>>>>>> Stashed changes
                }
              } else {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                    points: coordinates,
                    strokeWidth: 1,
                    strokeColor: Color(0xffD3D3D3),
                    onTap: () {},
                    fillColor: polyArray.cubicleColor != null &&
                            polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                            '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
<<<<<<< Updated upstream
                        : Colors.black.withOpacity(0.2),
=======
                        : Colors.white,
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                        : Color(0xffCCCCCC),
=======
                        : Colors.white,
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                      : Colors.black,
=======
                      : Color(0xffE6E6E6),
>>>>>>> Stashed changes
                  width: 1,
                  onTap: () {}));
            }
          }
        }
      }
    });
  }

  Future<Uint8List> getImagesFromMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

<<<<<<< Updated upstream
  void createMarkers(land _landData, int floor) async {
    Markers.clear();
    List<Landmarks> landmarks = _landData.landmarks!;

    for (int i = 0; i < landmarks.length; i++) {
      if (landmarks[i].floor == floor &&
          landmarks[i].buildingID == buildingAllApi.getStoredString()) {
        if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType != "main entry" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
          //   ImageConfiguration(size: Size(44, 44)),
          //   getImagesFromMarker('assets/location_on.png',50),
          // );
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/location_on.png', 55);
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!, landmarks[i].coordinateY!);

          Markers.add(Marker(
              markerId: MarkerId("Room ${landmarks[i].properties!.polyId}"),
              position: LatLng(value[0], value[1]),
              icon: BitmapDescriptor.fromBytes(iconMarker),
              anchor: Offset(0.5, 0.5),
              visible: false,
              onTap: () {
                print("Info Window");
              },
              infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: '${landmarks[i].properties!.polyId}',
                  // Replace with additional information
                  onTap: () {
                    print("Info Window ");
                  })));
=======
  Future<BitmapDescriptor> bitmapDescriptorFromTextAndImage(
      String text, String? imagePath,
      {Size imageSize = const Size(50, 50), Color? color}) async {
    // Set the text style and layout
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 30.0, // Increased font size
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

  void createMarkers(land _landData, int floor, {String? bid}) async {
    _markers.clear();
    _markerLocationsMap.clear();
    _markerLocationsMapLanName.clear();
    Markers.removeWhere((marker) => marker.markerId.value
        .contains(bid ?? buildingAllApi.selectedBuildingID));
    List<Landmarks> landmarks = _landData.landmarks!;
    try {
      for (int i = 0; i < landmarks.length; i++) {
        if (landmarks[i].floor == floor &&
            landmarks[i].buildingID ==
                (bid ?? buildingAllApi.selectedBuildingID)) {
          if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Classroom" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            BitmapDescriptor textMarker;
            if (landmarks[i].priority! > 1) {
              String markerText;
              List<String> parts = landmarks[i].name!.split('-');
              markerText = parts.isNotEmpty ? parts[0].trim() : '';
              textMarker = await bitmapDescriptorFromTextAndImage(
                  markerText, 'assets/Classroom.png',
                  imageSize: const Size(95, 95), color: Color(0xff544551));
            } else {
              final Uint8List iconMarker =
                  await getImagesFromMarker('assets/Classroom.png', 85);
              textMarker = BitmapDescriptor.fromBytes(iconMarker);
            }

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " +
                        (landmarks[i].priority! > 1 ? "toppriority" : "")),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Cafeteria" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            BitmapDescriptor textMarker;
            if (landmarks[i].priority! > 1) {
              String markerText;
              List<String> parts = landmarks[i].name!.split('-');
              markerText = parts.isNotEmpty ? parts[0].trim() : '';
              textMarker = await bitmapDescriptorFromTextAndImage(
                  markerText, 'assets/cutlery.png',
                  imageSize: const Size(95, 95), color: Color(0xfffb8c00));
            } else {
              final Uint8List iconMarker =
                  await getImagesFromMarker('assets/cutlery.png', 85);
              textMarker = BitmapDescriptor.fromBytes(iconMarker);
            }

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " +
                        (landmarks[i].priority! > 1 ? "toppriority" : "")),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Point of Interest" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );

            BitmapDescriptor textMarker;
            String markerText;
            markerText = landmarks[i].name ?? "";
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, null,
                imageSize: const Size(85, 85));

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Counter" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );

            BitmapDescriptor textMarker;
            String markerText;
            markerText = landmarks[i].name ?? "";
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, null,
                imageSize: const Size(85, 85));

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Point of Interest" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );

            BitmapDescriptor textMarker;
            String markerText;
            markerText = landmarks[i].name ?? "";
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, null,
                imageSize: const Size(85, 85));

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "ATM" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );

            BitmapDescriptor textMarker;
            if (landmarks[i].priority! > 1) {
              String markerText;
              List<String> parts = landmarks[i].name!.split('-');
              markerText = parts.isNotEmpty ? parts[0].trim() : '';
              textMarker = await bitmapDescriptorFromTextAndImage(
                  markerText, 'assets/ATM.png',
                  imageSize: const Size(100, 100), color: Color(0xffd32f2f));
            } else {
              final Uint8List iconMarker =
                  await getImagesFromMarker('assets/ATM.png', 100);
              textMarker = BitmapDescriptor.fromBytes(iconMarker);
            }

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " +
                        (landmarks[i].priority! > 1 ? "toppriority" : "")),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Consultation Room" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );

            BitmapDescriptor textMarker;
            if (landmarks[i].priority! > 1) {
              String markerText;
              List<String> parts = landmarks[i].name!.split('-');
              markerText = parts.isNotEmpty ? parts[0].trim() : '';
              textMarker = await bitmapDescriptorFromTextAndImage(
                  markerText, 'assets/Consultation Room.png',
                  imageSize: const Size(85, 85), color: Color(0xff544551));
            } else {
              final Uint8List iconMarker =
                  await getImagesFromMarker('assets/Consultation Room.png', 85);
              textMarker = BitmapDescriptor.fromBytes(iconMarker);
            }

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " +
                        (landmarks[i].priority! > 1 ? "toppriority" : "")),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType == "Office" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );

            BitmapDescriptor textMarker;
            if (landmarks[i].priority! > 1) {
              String markerText;
              List<String> parts = landmarks[i].name!.split('-');
              markerText = parts.isNotEmpty ? parts[0].trim() : '';
              textMarker = await bitmapDescriptorFromTextAndImage(
                  markerText, 'assets/Office.png',
                  imageSize: const Size(85, 85), color: Color(0xff544551));
            } else {
              final Uint8List iconMarker =
                  await getImagesFromMarker('assets/Office.png', 85);
              textMarker = BitmapDescriptor.fromBytes(iconMarker);
            }

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " +
                        (landmarks[i].priority! > 1 ? "toppriority" : "")),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType != "main entry" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );

            BitmapDescriptor textMarker;
            if (landmarks[i].priority! > 1) {
              String markerText;
              List<String> parts = landmarks[i].name!.split('-');
              markerText = parts.isNotEmpty ? parts[0].trim() : '';
              textMarker = await bitmapDescriptorFromTextAndImage(
                  markerText, 'assets/Generic Marker.png',
                  imageSize: const Size(85, 85));
            } else {
              final Uint8List iconMarker =
                  await getImagesFromMarker('assets/Generic Marker.png', 85);
              textMarker = BitmapDescriptor.fromBytes(iconMarker);
            }

            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " +
                        (landmarks[i].priority! > 1 ? "toppriority" : "")),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 1.0),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else if (landmarks[i].element!.subType != null &&
              landmarks[i].element!.subType == "room door" &&
              landmarks[i].doorX != null) {
            final Uint8List iconMarker =
                await getImagesFromMarker('assets/dooricon.png', 45);
            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!,
                  landmarks[i].coordinateY!,
                  SingletonFunctionController.building
                      .patchData[bid ?? buildingAllApi.getStoredString()]);
              Markers.add(Marker(
                  markerId: MarkerId(
                      "Door ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
                  position: LatLng(value[0], value[1]),
                  icon: BitmapDescriptor.fromBytes(iconMarker),
                  visible: false,
                  infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: 'Additional Information',
                    // Replace with additional information
                    onTap: () {
                      if (SingletonFunctionController
                              .building.selectedLandmarkID !=
                          landmarks[i].properties!.polyId) {
                        SingletonFunctionController
                                .building.selectedLandmarkID =
                            landmarks[i].properties!.polyId;
                        _isRoutePanelOpen = false;
                        singleroute.clear();
                        //realWorldPath.clear();
                        _isLandmarkPanelOpen = true;
                        addselectedMarker(LatLng(value[0], value[1]));
                      }
                    },
                  )));
            });
          } else if (landmarks[i].name != null &&
              landmarks[i].element!.type == ("FloorConnection") &&
              landmarks[i].element!.subType == "lift") {
            final Uint8List iconMarker =
                await getImagesFromMarker('assets/entry.png', 75);

            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!,
                  landmarks[i].coordinateY!,
                  SingletonFunctionController.building
                      .patchData[bid ?? buildingAllApi.getStoredString()]);

              // _markerLocations[LatLng(value[0], value[1])] = '1';
              mapMarkerLocationMapAndName.add(InitMarkerModel(
                  'Lift',
                  landmarks[i].name!,
                  LatLng(value[0], value[1]),
                  landmarks[i].buildingID!));
              _markerLocationsMap[LatLng(value[0], value[1])] = 'Lift';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
                  landmarks[i].name!;
              _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
                  landmarks[i].buildingID!;
            });
          } else if (landmarks[i].name != null &&
              landmarks[i].name!.toLowerCase().contains("pharmacy")) {
            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!,
                  landmarks[i].coordinateY!,
                  SingletonFunctionController.building
                      .patchData[bid ?? buildingAllApi.getStoredString()]);
              mapMarkerLocationMapAndName.add(InitMarkerModel(
                  'Pharmacy',
                  landmarks[i].name!,
                  LatLng(value[0], value[1]),
                  landmarks[i].buildingID!));

              _markerLocationsMap[LatLng(value[0], value[1])] = 'Pharmacy';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
                  landmarks[i].name!;
              _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
                  landmarks[i].buildingID!;
            });
          }
          // else if (landmarks[i].name != null &&
          //     landmarks[i].name!.toLowerCase().contains("kitchen")) {
          //
          //   setState(() {
          //     List<double> value = tools.localtoglobal(
          //         landmarks[i].coordinateX!, landmarks[i].coordinateY!,
          //         SingletonFunctionController.building.patchData[bid ?? buildingAllApi.getStoredString()]);
          //     _markerLocationsMap[LatLng(value[0], value[1])] = 'Kitchen';
          //     _markerLocationsMapLanName[LatLng(value[0], value[1])] =
          //     landmarks[i].name!;
          //   });
          // }
          else if (landmarks[i].properties!.washroomType != null &&
              landmarks[i].properties!.washroomType == "Male") {
            final Uint8List iconMarker =
                await getImagesFromMarker('assets/6.png', 65);
            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!,
                  landmarks[i].coordinateY!,
                  SingletonFunctionController.building
                      .patchData[bid ?? buildingAllApi.getStoredString()]);
              mapMarkerLocationMapAndName.add(InitMarkerModel(
                  'Male',
                  landmarks[i].name!,
                  LatLng(value[0], value[1]),
                  landmarks[i].buildingID!));

              _markerLocationsMap[LatLng(value[0], value[1])] = 'Male';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
                  landmarks[i].name!;
              _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
                  landmarks[i].buildingID!;

              // Markers.add(Marker(
              //     markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
              //     position: LatLng(value[0], value[1]),
              //     icon: BitmapDescriptor.fromBytes(iconMarker),
              //     visible: false,
              //     infoWindow: InfoWindow(
              //       title: landmarks[i].name,
              //       snippet: 'Additional Information',
              //       // Replace with additional information
              //       onTap: () {
              //         if (SingletonFunctionController.building.selectedLandmarkID !=
              //             landmarks[i].properties!.polyId) {
              //           SingletonFunctionController.building.selectedLandmarkID =
              //               landmarks[i].properties!.polyId;
              //           _isRoutePanelOpen = false;
              //           singleroute.clear();
              //           _isLandmarkPanelOpen = true;
              //           addselectedMarker(LatLng(value[0], value[1]));
              //         }
              //       },
              //     )));
            });
          } else if (landmarks[i].properties!.washroomType != null &&
              landmarks[i].properties!.washroomType == "Female") {
            final Uint8List iconMarker =
                await getImagesFromMarker('assets/4.png', 65);

            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!,
                  landmarks[i].coordinateY!,
                  SingletonFunctionController.building
                      .patchData[bid ?? buildingAllApi.getStoredString()]);
              mapMarkerLocationMapAndName.add(InitMarkerModel(
                  'Female',
                  landmarks[i].name!,
                  LatLng(value[0], value[1]),
                  landmarks[i].buildingID!));

              _markerLocationsMap[LatLng(value[0], value[1])] = 'Female';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
                  landmarks[i].name!;
              _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
                  landmarks[i].buildingID!;

              // Markers.add(Marker(
              //     markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
              //     position: LatLng(value[0], value[1]),
              //     icon: BitmapDescriptor.fromBytes(iconMarker),
              //     visible: false,
              //     infoWindow: InfoWindow(
              //       title: landmarks[i].name,
              //       snippet: 'Additional Information',
              //       // Replace with additional information
              //       onTap: () {
              //         if (SingletonFunctionController.building.selectedLandmarkID !=
              //             landmarks[i].properties!.polyId) {
              //           SingletonFunctionController.building.selectedLandmarkID =
              //               landmarks[i].properties!.polyId;
              //           _isRoutePanelOpen = false;
              //           singleroute.clear();
              //           _isLandmarkPanelOpen = true;
              //           addselectedMarker(LatLng(value[0], value[1]));
              //         }
              //       },
              //     )));
            });
          } else if (landmarks[i].element!.subType != null &&
              landmarks[i].element!.subType == "main entry") {
            final Uint8List iconMarker =
                await getImagesFromMarker('assets/1.png', 90);

            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!,
                  landmarks[i].coordinateY!,
                  SingletonFunctionController.building
                      .patchData[bid ?? buildingAllApi.getStoredString()]);
              // _markerLocations[LatLng(value[0], value[1])] = '1';
              mapMarkerLocationMapAndName.add(InitMarkerModel(
                  landmarks[i].buildingID == buildingAllApi.outdoorID
                      ? "Campus Entry"
                      : 'Entry',
                  landmarks[i].name!,
                  LatLng(value[0], value[1]),
                  landmarks[i].buildingID!));

              _markerLocationsMap[LatLng(value[0], value[1])] =
                  landmarks[i].buildingID == buildingAllApi.outdoorID
                      ? "Campus Entry"
                      : 'Entry';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
                  landmarks[i].name!;
              _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
                  landmarks[i].buildingID!;

              // _markers!.add(Marker(
              //   markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
              //   position: LatLng(value[0], value[1]),
              //   icon: BitmapDescriptor.fromBytes(iconMarker),
              // ));

              // Markers.add(Marker(
              //     markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
              //     position: LatLng(value[0], value[1]),
              //     icon: BitmapDescriptor.fromBytes(iconMarker),
              //     visible: true,
              //     infoWindow: InfoWindow(
              //       title: landmarks[i].name,
              //       snippet: 'Additional Information',
              //       // Replace with additional information
              //       onTap: () {
              //         if (SingletonFunctionController.building.selectedLandmarkID !=
              //             landmarks[i].properties!.polyId) {
              //           SingletonFunctionController.building.selectedLandmarkID =
              //               landmarks[i].properties!.polyId;
              //           _isRoutePanelOpen = false;
              //           singleroute.clear();
              //           _isLandmarkPanelOpen = true;
              //           addselectedMarker(LatLng(value[0], value[1]));
              //         }
              //       },
              //     ),
              //     onTap: () {
              //       if (SingletonFunctionController.building.selectedLandmarkID !=
              //           landmarks[i].properties!.polyId) {
              //         SingletonFunctionController.building.selectedLandmarkID =
              //             landmarks[i].properties!.polyId;
              //         _isRoutePanelOpen = false;
              //         singleroute.clear();
              //         _isLandmarkPanelOpen = true;
              //         addselectedMarker(LatLng(value[0], value[1]));
              //       }
              //     }));
            });
          } else if (landmarks[i].element!.type == "Services" &&
              landmarks[i].element!.subType == "kiosk" &&
              landmarks[i].coordinateX != null) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );
            final Uint8List iconMarker =
                await getImagesFromMarker('assets/pin.png', 50);
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!,
                landmarks[i].coordinateY!,
                SingletonFunctionController.building
                    .patchData[bid ?? buildingAllApi.getStoredString()]);
            //_markerLocations.add(LatLng(value[0],value[1]));
            BitmapDescriptor textMarker;
            String markerText;
            try {
              if (landmarks[i].name != "kiosk") {
                List<String> parts = landmarks[i].name!.split(' ');
                markerText = parts.isNotEmpty ? parts[1].trim() : '';
              } else {
                markerText = "Kiosk";
              }
            } catch (e) {
              markerText = "Kiosk";
            }

            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/check-in.png');

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 0.5),
                visible: false,
                onTap: () {},
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {})));
          } else {}
>>>>>>> Stashed changes
        }
        if (landmarks[i].element!.subType != null &&
            landmarks[i].element!.subType == "room door" &&
            landmarks[i].doorX != null) {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/dooricon.png', 45);
          setState(() {
            List<double> value =
                tools.localtoglobal(landmarks[i].doorX!, landmarks[i].doorY!);
            Markers.add(Marker(
                markerId: MarkerId("Door ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].name != null &&
            landmarks[i].name!.toLowerCase().contains("lift") &&
            landmarks[i].element!.subType != "room door") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/entry.png', 75);

          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Lift ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].properties!.washroomType != null &&
            landmarks[i].properties!.washroomType == "Male") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/6.png', 65);
          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].properties!.washroomType != null &&
            landmarks[i].properties!.washroomType == "Female") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/4.png', 65);

          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].element!.subType != null &&
            landmarks[i].element!.subType == "main entry") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/1.png', 90);

          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: true,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                ),
                onTap: () {
                  if (building.selectedLandmarkID !=
                      landmarks[i].properties!.polyId) {
                    building.selectedLandmarkID =
                        landmarks[i].properties!.polyId;
                    _isRoutePanelOpen = false;
                    singleroute.clear();
                    _isLandmarkPanelOpen = true;
                    addselectedMarker(LatLng(value[0], value[1]));
                  }
                }));
          });
        } else {}
      }
    }
    setState(() {
      // Markers.add(Marker(
      //   markerId: MarkerId("Building marker"),
      //   position: _initialCameraPosition.target,
      //   icon: BitmapDescriptor.defaultMarker,
      //   visible: false,
      // ));
    });
<<<<<<< Updated upstream
=======

    _initMarkers();
>>>>>>> Stashed changes
  }

  void toggleLandmarkPanel() {
    setState(() {
      _isLandmarkPanelOpen = !_isLandmarkPanelOpen;
      selectedroomMarker.clear();
      building.selectedLandmarkID = null;
      _googleMapController.animateCamera(CameraUpdate.zoomOut());
    });
  }

  PanelController _landmarkPannelController = new PanelController();
  bool calculatingPath = false;
<<<<<<< Updated upstream
=======
  double aerialDist = 0.0;
  Timer? _timerCompass;
>>>>>>> Stashed changes
  Widget landmarkdetailpannel(
      BuildContext context, AsyncSnapshot<land> snapshot) {
    pathMarkers.clear();
    clearPathVariables();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (!snapshot.hasData ||
        snapshot.data!.landmarksMap == null ||
<<<<<<< Updated upstream
        snapshot.data!.landmarksMap![building.selectedLandmarkID] == null) {
      print("object");
      //print(building.selectedLandmarkID);
=======
        snapshot.data!.landmarksMap![
                SingletonFunctionController.building.selectedLandmarkID] ==
            null) {
      //
>>>>>>> Stashed changes
      // If the data is not available, return an empty container
      _isLandmarkPanelOpen = false;
      _isreroutePannelOpen = false;
      showMarkers();
      selectedroomMarker.clear();
      building.selectedLandmarkID = null;
      return Container();
    }

<<<<<<< Updated upstream
=======
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

    bool microService = snapshot
                .data!
                .landmarksMap![
                    SingletonFunctionController.building.selectedLandmarkID]!
                .properties!
                .basinClock !=
            null &&
        snapshot
                .data!
                .landmarksMap![
                    SingletonFunctionController.building.selectedLandmarkID]!
                .properties!
                .cubicleClock !=
            null &&
        snapshot
                .data!
                .landmarksMap![
                    SingletonFunctionController.building.selectedLandmarkID]!
                .properties!
                .urinalClock !=
            null;

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

>>>>>>> Stashed changes
    return Stack(
      children: [
        Positioned(
          left: 16,
          top: 16,
          right: 16,
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
<<<<<<< Updated upstream
                      snapshot.data!.landmarksMap![building.selectedLandmarkID]!
                          .name!,
=======
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
>>>>>>> Stashed changes
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8e8d8d),
                        height: 25 / 16,
                      ),
                    )),
                  ),
                  Container(
                    height: 48,
                    width: 47,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          showMarkers();
                          toggleLandmarkPanel();
                          _isBuildingPannelOpen = true;
                        },
                        icon: Semantics(
                          label: "Close",
                          child: Icon(
                            Icons.cancel_outlined,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
        SlidingUpPanel(
          controller: _landmarkPannelController,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ],
<<<<<<< Updated upstream
          minHeight: 145,
          maxHeight: screenHeight,
=======
          minHeight: startTime ? 220 : 185,
          maxHeight: contactDetail && microService
              ? 0.73
              : (contactDetail
                  ? (screenHeight * 0.45)
                  : (microService
                      ? (screenHeight * 0.28)
                      : (startTime ? 220 : 185))),
>>>>>>> Stashed changes
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
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
<<<<<<< Updated upstream
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

                      Container(
                        padding: EdgeInsets.only(left: 17, top: 12),
                        child: Focus(
                          autofocus: true,
                          child: Semantics(
                            child: Text(
                              snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .name!,
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff292929),
                                height: 25 / 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 17,
                        ),
                        child: Text(
                          "Floor ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.buildingName!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.venueName!}",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff8d8c8c),
                            height: 25 / 16,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //       "1 min ",
                      //       style: const TextStyle(
                      //         color: Color(0xffDC6A01),
                      //         fontFamily: "Roboto",
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w400,
                      //         height: 25 / 16,
                      //       ),
                      //       textAlign: TextAlign.left,
                      //     ),
                      //     Text(
                      //       "(60 m)",
                      //       style: const TextStyle(
                      //         fontFamily: "Roboto",
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w400,
                      //         height: 25 / 16,
                      //       ),
                      //       textAlign: TextAlign.left,
                      //     )
                      //   ],
                      // ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 17,
                        ),
                        width: 114,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xff24B9B0),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            if (user.coordY != 0 && user.coordX != 0) {
                              PathState.sourceX = user.coordX;
                              PathState.sourceY = user.coordY;
                              PathState.sourceFloor = user.floor;
                              PathState.sourcePolyID = user.key;
                              print("object ${PathState.sourcePolyID}");
                              PathState.sourceName = "Your current location";
                              PathState.destinationPolyID =
                                  building.selectedLandmarkID!;
                              PathState.destinationName = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .name!;
                              PathState.destinationFloor = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .floor!;
                              PathState.sourceBid = user.Bid;

                              PathState.destinationBid = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .buildingID!;

                              setState(() {
                                print("valuechanged");
                                calculatingPath = true;
                              });
                              Future.delayed(Duration(seconds: 1), () {
                                calculateroute(snapshot.data!.landmarksMap!)
                                    .then((value) {
                                  calculatingPath = false;
                                  _isLandmarkPanelOpen = false;
                                  _isRoutePanelOpen = true;
                                });
                              });
                            } else {
                              PathState.sourceName = "Choose Starting Point";
                              PathState.destinationPolyID =
                                  building.selectedLandmarkID!;
                              PathState.destinationName = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .name!;
                              PathState.destinationFloor = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .floor!;
                              building.selectedLandmarkID = "";
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SourceAndDestinationPage(
                                            DestinationID:
                                                PathState.destinationPolyID,
                                          ))).then((value) {
                                if (value != null) {
                                  fromSourceAndDestinationPage(value);
                                }
                              });
                            }
                          },
                          child: (!calculatingPath)
                              ? const Row(
                                  //  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Direction",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                )
                              : Container(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
=======
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
                                    borderRadius: BorderRadius.circular(5.0),
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
                                padding: EdgeInsets.only(
                                    left: 17, top: 12, bottom: 4),
                                child: Focus(
                                  autofocus: true,
                                  child: Semantics(
                                    child: Text(
                                      snapshot
                                              .data!
                                              .landmarksMap![
                                                  SingletonFunctionController
                                                      .building
                                                      .selectedLandmarkID]!
                                              .name ??
                                          snapshot
                                              .data!
                                              .landmarksMap![
                                                  SingletonFunctionController
                                                      .building
                                                      .selectedLandmarkID]!
                                              .element!
                                              .subType!,
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff000000),
                                        height: 28 / 22,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 17, bottom: 4),
                                child: Text(
                                  "${LocaleData.floor.getString(context)} ${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.buildingName!},",
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
                                padding: EdgeInsets.only(left: 17, bottom: 4),
                                child: Text(
                                  "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.venueName!}",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff777777),
                                    height: 20 / 14,
>>>>>>> Stashed changes
                                  ),
                                  textAlign: TextAlign.left,
                                ),
<<<<<<< Updated upstream
                        ),
=======
                              ),
                              snapshot
                                          .data!
                                          .landmarksMap![
                                              SingletonFunctionController
                                                  .building.selectedLandmarkID]!
                                          .properties!
                                          .startTime !=
                                      null
                                  ? Container(
                                      padding:
                                          EdgeInsets.only(left: 17, bottom: 4),
                                      child: Row(
                                        children: [
                                          Text(
                                            "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.startTime!} AM- ${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.endTime!} PM  ",
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
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff4CAF50),
                                                    height: 20 / 14,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                )
                                              : Text(
                                                  "Closed",
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
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
                          Container(
                              margin: EdgeInsets.only(top: 8, right: 16),
                              child: IconButton(
                                  onPressed: () {
                                    HelperClass.shareContent(
                                        "https://dev.iwayplus.in/#/iway-apps/iwaymaps.com/landmark?bid=${buildingAllApi.getStoredString()}&landmark=${SingletonFunctionController.building.selectedLandmarkID!}&appStore=rgci-navigation/id6505062168&playStore=com.iwayplus.rgcinavigation");
                                  },
                                  icon: Semantics(
                                      label: "Share route information",
                                      child: Icon(Icons.share))))
                        ],
>>>>>>> Stashed changes
                      ),
                      SizedBox(
                        height: 16,
                      ),
<<<<<<< Updated upstream
                      Semantics(
                        label: "Information",
                        child: Container(
                          margin: EdgeInsets.only(left: 17, top: 20),
                          child: Text(
                            "Information",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff282828),
                              height: 24 / 18,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16, right: 16),
                        padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.0, color: Color(0xffebebeb))),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(right: 16),
                                width: 32,
                                height: 32,
                                child: Semantics(
                                  excludeSemantics: true,
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xff24B9B0),
                                    size: 24,
                                  ),
                                )),
                            Container(
                              width: screenWidth - 100,
                              margin: EdgeInsets.only(top: 8),
                              child: RichText(
                                text: TextSpan(
=======
                      contactDetail
                          ? Semantics(
                              label: "Contact Details",
                              excludeSemantics: true,
                              child: Container(
                                margin: EdgeInsets.only(left: 17, top: 20),
                                child: Text(
                                  "Contact Details",
>>>>>>> Stashed changes
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff000000),
                                    height: 21 / 18,
                                  ),
<<<<<<< Updated upstream
                                  children: [
                                    TextSpan(
                                      text:
                                          "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.name!}, Floor ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.buildingName!}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      snapshot.data!.landmarksMap![building.selectedLandmarkID]!
                                  .properties!.contactNo !=
                              null
                          ? Container(
                              margin: EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1.0,
                                    color: Color(0xffebebeb),
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 16),
                                    width: 32,
                                    height: 32,
                                    child: Icon(
                                      Icons.call,
                                      color: Color(0xff24B9B0),
                                      size: 24,
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth - 100,
                                    margin: EdgeInsets.only(top: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff4a4545),
                                          height: 25 / 16,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.properties!.contactNo!}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      snapshot.data!.landmarksMap![building.selectedLandmarkID]!
                                      .properties!.email !=
                                  "" &&
                              snapshot
                                      .data!
                                      .landmarksMap![
                                          building.selectedLandmarkID]!
                                      .properties!
                                      .email !=
                                  null
=======
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
                                    .landmarksMap![SingletonFunctionController
                                        .building.selectedLandmarkID]!
                                    .properties!
                                    .contactNo!);
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 16, right: 16),
                                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      .landmarksMap![SingletonFunctionController
                                          .building.selectedLandmarkID]!
                                      .properties!
                                      .email !=
                                  "" &&
                              snapshot
                                      .data!
                                      .landmarksMap![SingletonFunctionController
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
                                                .building.selectedLandmarkID]!
                                        .properties!
                                        .email!);
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 16, right: 16),
                                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      .landmarksMap![SingletonFunctionController
                                          .building.selectedLandmarkID]!
                                      .properties!
                                      .url !=
                                  "" &&
                              snapshot
                                      .data!
                                      .landmarksMap![SingletonFunctionController
                                          .building.selectedLandmarkID]!
                                      .properties!
                                      .url !=
                                  null
                          ? InkWell(
                              onTap: () {
                                HelperClass.launchURL(snapshot
                                    .data!
                                    .landmarksMap![SingletonFunctionController
                                        .building.selectedLandmarkID]!
                                    .properties!
                                    .url!);
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 16, right: 16),
                                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      microService
>>>>>>> Stashed changes
                          ? Container(
                              margin: EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1.0, color: Color(0xffebebeb))),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: 16),
                                      width: 32,
                                      height: 32,
                                      child: Icon(
<<<<<<< Updated upstream
                                        Icons.mail_outline,
                                        color: Color(0xff24B9B0),
                                        size: 24,
                                      )),
                                  Container(
                                    width: screenWidth - 100,
                                    margin: EdgeInsets.only(top: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff4a4545),
                                          height: 25 / 16,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.properties!.email!}",
                                          ),
                                        ],
                                      ),
                                    ),
=======
                                        Icons.accessible,
                                        color: Color(0xff24B9B0),
                                        size: 24,
                                      )),
                                  Column(
                                    children: [
                                      Container(
                                        width: screenWidth - 100,
                                        margin: EdgeInsets.only(top: 8),
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff4a4545),
                                              height: 25 / 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                  text: snapshot
                                                                  .data!
                                                                  .landmarksMap![
                                                                      SingletonFunctionController
                                                                          .building
                                                                          .selectedLandmarkID]!
                                                                  .properties!
                                                                  .numCubicles !=
                                                              "null" &&
                                                          snapshot
                                                                  .data!
                                                                  .landmarksMap![
                                                                      SingletonFunctionController
                                                                          .building
                                                                          .selectedLandmarkID]!
                                                                  .properties!
                                                                  .cubicleClock !=
                                                              "null"
                                                      ? "As your entry, washroom has ${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.numCubicles} toilet cubicles on ${UserCredentials().getuserNavigationModeSetting() != "Natural Direction" ? "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.cubicleClock.toString()}'o clock " : tools.convertClockDirectionToLRFB(snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.cubicleClock.toString())}. "
                                                      : ""
                                                          "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.numUrinals} urinals on ${UserCredentials().getuserNavigationModeSetting() != "Natural Direction" ? "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.urinalClock.toString()}'o clock " : tools.convertClockDirectionToLRFB(snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.urinalClock.toString())}, "
                                                          "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.numWashbasin} handwashing stations on ${UserCredentials().getuserNavigationModeSetting() != "Natural Direction" ? "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.basinClock.toString()}o'clock" : tools.convertClockDirectionToLRFB(snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.basinClock.toString())}."),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth - 100,
                                        margin: EdgeInsets.only(top: 8),
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff4a4545),
                                              height: 25 / 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                  text: snapshot
                                                                  .data!
                                                                  .landmarksMap![
                                                                      SingletonFunctionController
                                                                          .building
                                                                          .selectedLandmarkID]!
                                                                  .properties!
                                                                  .numUrinals !=
                                                              "null" &&
                                                          snapshot
                                                                  .data!
                                                                  .landmarksMap![
                                                                      SingletonFunctionController
                                                                          .building
                                                                          .selectedLandmarkID]!
                                                                  .properties!
                                                                  .urinalClock !=
                                                              "null"
                                                      ? "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.numUrinals} urinals on ${UserCredentials().getuserNavigationModeSetting() != "Natural Direction" ? "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.urinalClock.toString()}'o clock " : tools.convertClockDirectionToLRFB(snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.urinalClock.toString())}. "
                                                      : ""),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth - 100,
                                        margin: EdgeInsets.only(top: 8),
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff4a4545),
                                              height: 25 / 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                  text: snapshot
                                                                  .data!
                                                                  .landmarksMap![
                                                                      SingletonFunctionController
                                                                          .building
                                                                          .selectedLandmarkID]!
                                                                  .properties!
                                                                  .numWashbasin !=
                                                              "null" &&
                                                          snapshot
                                                                  .data!
                                                                  .landmarksMap![
                                                                      SingletonFunctionController
                                                                          .building
                                                                          .selectedLandmarkID]!
                                                                  .properties!
                                                                  .basinClock !=
                                                              "null"
                                                      ? "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.numWashbasin} handwashing stations on ${UserCredentials().getuserNavigationModeSetting() != "Natural Direction" ? "${snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.basinClock.toString()}o'clock" : tools.convertClockDirectionToLRFB(snapshot.data!.landmarksMap![SingletonFunctionController.building.selectedLandmarkID]!.properties!.basinClock.toString())}."
                                                      : ""),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
>>>>>>> Stashed changes
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                );
            }
          }(),
        ),
        Positioned(
          bottom: 0,
          child: Container(
              height: 80,
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white, // Set the background color
                boxShadow: (contactDetail || microService)
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Shadow color
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
                    onPressed: () async {
                      _polygon.clear();
                      // circles.clear();
                      Markers.clear();

                      if (user.coordY != 0 && user.coordX != 0) {
                        PathState.sourceX = user.coordX;
                        PathState.sourceY = user.coordY;
                        PathState.sourceFloor = user.floor;
                        PathState.sourcePolyID = user.key;

                        PathState.sourceName = "Your current location";
                        PathState.destinationPolyID =
                            SingletonFunctionController
                                .building.selectedLandmarkID!;
                        PathState.destinationName = snapshot
                                .data!
                                .landmarksMap![SingletonFunctionController
                                    .building.selectedLandmarkID]!
                                .name ??
                            snapshot
                                .data!
                                .landmarksMap![SingletonFunctionController
                                    .building.selectedLandmarkID]!
                                .element!
                                .subType!;
                        PathState.destinationFloor = snapshot
                            .data!
                            .landmarksMap![SingletonFunctionController
                                .building.selectedLandmarkID]!
                            .floor!;
                        PathState.sourceBid = user.Bid;

                        PathState.destinationBid = snapshot
                            .data!
                            .landmarksMap![SingletonFunctionController
                                .building.selectedLandmarkID]!
                            .buildingID!;

                        setState(() {
                          calculatingPath = true;
                        });
                        bool calibrate = isCalibrationNeeded(magneticValues);
                        print("calibrate1");
                        print(calibrate);
                        if (calibrate == true) {
                          setState(() {
                            accuracy = true;
                          });
                          speak(
                              "low accuracy found.Please calibrate your device",
                              _currentLocale);
                          showLowAccuracyDialog();
                          magneticValues.clear();
                          listenToMagnetometer();
                          _timerCompass =
                              Timer.periodic(Duration(seconds: 1), (timer) {
                            calibrate = isCalibrationNeeded(magneticValues);
                            print("calibrate2");
                            print(calibrate);
                            if (calibrate == false) {
                              setState(() {
                                accuracy = false;
                              });
                              magneticValues.clear();
                              _timerCompass?.cancel();
                            } else {
                              listenToMagnetometeronCalibration();
                              _timerCompass?.cancel();
                            }
                          });
                        }

                        Future.delayed(Duration(seconds: 1), () {
                          calculateroute(snapshot.data!.landmarksMap!)
                              .then((value) {
                            calculatingPath = false;

                            _isLandmarkPanelOpen = false;
                            _isRoutePanelOpen = true;
                          });
                        });
                      } else {
                        PathState.sourceName = "Choose Starting Point";
                        PathState.destinationPolyID =
                            SingletonFunctionController
                                .building.selectedLandmarkID!;
                        PathState.destinationName = snapshot
                                .data!
                                .landmarksMap![SingletonFunctionController
                                    .building.selectedLandmarkID]!
                                .name ??
                            snapshot
                                .data!
                                .landmarksMap![SingletonFunctionController
                                    .building.selectedLandmarkID]!
                                .element!
                                .subType!;
                        PathState.destinationFloor = snapshot
                            .data!
                            .landmarksMap![SingletonFunctionController
                                .building.selectedLandmarkID]!
                            .floor!;
                        SingletonFunctionController
                            .building.selectedLandmarkID = "";
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SourceAndDestinationPage(
                                      DestinationID:
                                          PathState.destinationPolyID,
                                      user: user,
                                    ))).then((value) {
                          if (value != null) {
                            fromSourceAndDestinationPage(value);
                          }
                        });
                      }
                    },
                    child: (!calculatingPath)
                        ? Row(
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
                          )
                        : Container(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              )),
        )
      ],
    );
  }

  int calculateindex(int x, int y, int fl) {
    return (y * fl) + x;
  }

<<<<<<< Updated upstream
  List<CommonLifts> findCommonLifts(
      List<la.Lifts> list1, List<la.Lifts> list2) {
    List<CommonLifts> commonLifts = [];

    for (var lift1 in list1) {
      for (var lift2 in list2) {
        if (lift1.name == lift2.name) {
          // Create a new Lifts object with x and y values from both input lists
          print(
              "name ${lift1.name} (${lift1.x},${lift1.y}) && (${lift2.x},${lift2.y})");
          commonLifts.add(CommonLifts(
              name: lift1.name,
              distance: lift1.distance,
              x1: lift1.x,
              y1: lift1.y,
              x2: lift2.x,
              y2: lift2.y));
          break;
=======
  List<CommonConnection> findCommonLifts(
      Landmarks landmark1, Landmarks landmark2, String accessibleby) {
    List<CommonConnection> commonLifts = [];

    if (accessibleby == "Lifts") {
      for (var lift1 in landmark1.lifts!) {
        for (var lift2 in landmark2.lifts!) {
          if (lift1.name == lift2.name) {
            // Create a new Lifts object with x and y values from both input lists

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
    } else if (accessibleby == "ramp") {
      for (var ramp1 in landmark1.others!) {
        for (var ramp2 in landmark2.others!) {
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
>>>>>>> Stashed changes
        }
      }
    }

    // Sort the commonLifts based on distance
    commonLifts.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    return commonLifts;
  }

  List<CommonStairs> findCommonStairs(
      List<la.Stairs> list1, List<la.Stairs> list2) {
    List<CommonStairs> commonStairs = [];

    for (var stair1 in list1) {
      for (var stair2 in list2) {
        if (stair1.name == stair2.name) {
          // Create a new Lifts object with x and y values from both input lists
          print(
              "name ${stair1.name} (${stair1.x},${stair2.y}) && (${stair1.x},${stair2.y})");
          commonStairs.add(CommonStairs(
              name: stair1.name,
              distance: stair1.distance,
              x1: stair1.x,
              y1: stair1.y,
              x2: stair2.x,
              y2: stair2.y));
          break;
        }
      }
    }

    // Sort the commonLifts based on distance
    commonStairs.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    return commonStairs;
  }

<<<<<<< Updated upstream
  Map<List<String>, Set<gmap.Polyline>> interBuildingPath = new Map();
  int pathTypeSelected = 0;
  bool multiFloorPath = false;

  Future<void> calculateroute(Map<String, Landmarks> landmarksMap) async {
    print("landmarksMap");
    print(landmarksMap.keys);
    print(landmarksMap.values);
    print(landmarksMap[PathState.destinationPolyID]!.buildingID);
    print(landmarksMap[PathState.sourcePolyID]!.buildingID);

=======
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

  Future<void> runPaths(List<dynamic Function()> fetchrouteFutures) async {
    if (PathState.sourceBid == PathState.destinationBid) {
      SingletonFunctionController.building.floor[PathState.sourceBid] =
          PathState.sourceFloor;
      createRooms(
          SingletonFunctionController
              .building.polylinedatamap[PathState.sourceBid]!,
          PathState.sourceFloor);
    } else {
      SingletonFunctionController.building.floor[PathState.sourceBid] =
          PathState.sourceFloor;
      SingletonFunctionController.building.floor[PathState.destinationBid] = 0;
      createRooms(
          SingletonFunctionController
              .building.polylinedatamap[PathState.sourceBid]!,
          PathState.sourceFloor);
      createRooms(
          SingletonFunctionController
              .building.polylinedatamap[PathState.destinationBid]!,
          0);
    }
    //try {
    if (fetchrouteFutures.isNotEmpty) {
      //await createRooms(SingletonFunctionController.building.polylinedatamap[PathState.sourceBid]!, PathState.sourceFloor);
      print("starting calc");
      List<dynamic> result = fetchrouteFutures.map((func) => func()).toList();
      for (int i = 0; i < result.length - 1; i++) {
        Map<String, dynamic> dataCurrent = await result[i];
        Map<String, dynamic> dataNext = await result[i + 1];

        singleroute.putIfAbsent("${buildingAllApi.outdoorID}", () => Map());
        singleroute["${buildingAllApi.outdoorID}"]!.putIfAbsent(0, () => Set());

        singleroute["${buildingAllApi.outdoorID}"]![0]?.add(gmap.Polyline(
          polylineId: PolylineId("${buildingAllApi.outdoorID} misc$i"),
          points: [
            LatLng(dataCurrent["svalue"][0], dataCurrent["svalue"][1]),
            LatLng(dataNext["dvalue"][0], dataNext["dvalue"][1])
          ],
          color: Colors.blueAccent,
          width: 8,
        ));
      }
      List<int> s = [PathState.sourceX, PathState.sourceY];
      String sBid = PathState.sourceBid;
      List<int> d = [];
      String dBid = PathState.sourceBid;
      List<double> svalue = [];
      List<double> dvalue = [];
      for (var res in result) {
        Map<String, dynamic> data = await res;
        List<int> path = await data["path"];
        PathState.singleListPath.insertAll(0, path);
        PathState.singleCellListPath.insertAll(0, data["CellPath"]);
        print(
            "PathState.singleCellListPath ${PathState.singleCellListPath.length}");
        if (data["CellPath"].last.floor == PathState.sourceFloor) {
          d = [data["CellPath"].last.x, data["CellPath"].last.y];
          dBid = data["CellPath"].last.bid;
        }
      }
      svalue = tools.localtoglobal(
          s[0], s[1], SingletonFunctionController.building.patchData[sBid]);
      dvalue = tools.localtoglobal(
          d[0], d[1], SingletonFunctionController.building.patchData[dBid]);
      setCameraPositionusingCoords(
          [LatLng(svalue[0], svalue[1]), LatLng(dvalue[0], dvalue[1])]);
      createMarkersAndDirections(PathState.singleCellListPath);

      double time = 0;
      double distance = 0;
      DateTime currentTime = DateTime.now();
      if (PathState.singleCellListPath.isNotEmpty) {
        distance = tools.PathDistance(PathState.singleCellListPath);
        time = distance / 120;
        time = time.ceil().toDouble();
        distance = distance * 0.3048;
        distance = double.parse(distance.toStringAsFixed(1));
        setState(() {
          startingNavigation = true;
        });

        if (PathState.destinationName ==
            "${LocaleData.yourcurrentloc.getString(context)}") {
          speak(
              " ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. ${LocaleData.clickstarttonavigate.getString(context)}",
              _currentLocale);
        } else {
          speak(
              "${PathState.destinationName} ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. ${LocaleData.clickstarttonavigate.getString(context)}",
              _currentLocale);
        }
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

  Future<void> calculateroute(Map<String, Landmarks> landmarksMap,
      {String accessibleby = "Lifts"}) async {
    List<Function()> fetchrouteFutures = [];

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
    // circles.clear();

    //
    //
    //
    //

    PathState.noPathFound = false;
>>>>>>> Stashed changes
    singleroute.clear();
    pathMarkers.clear();
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
    if (PathState.sourceBid == PathState.destinationBid) {
      if (PathState.sourceFloor == PathState.destinationFloor) {
<<<<<<< Updated upstream
        print("Calculateroute if statement");
        print(
            "${PathState.sourceX},${PathState.sourceY}    ${PathState.destinationX},${PathState.destinationY}");
        await fetchroute(
=======
        fetchrouteFutures.add(() => fetchroute(
>>>>>>> Stashed changes
            PathState.sourceX,
            PathState.sourceY,
            PathState.destinationX,
            PathState.destinationY,
            PathState.destinationFloor,
<<<<<<< Updated upstream
            bid: PathState.destinationBid);
        building.floor[buildingAllApi.getStoredString()] = user.floor;
        createRooms(building.polyLineData!,
            building.floor[buildingAllApi.getStoredString()]!);
=======
            bid: PathState.destinationBid));
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()] = user.floor;
>>>>>>> Stashed changes

        building.landmarkdata!.then((value) {
          createMarkers(
              value, building.floor[buildingAllApi.getStoredString()]!);
        });
        if (markers.length > 0)
          markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        mapState.zoom = 21;
      } else if (PathState.sourceFloor != PathState.destinationFloor) {
<<<<<<< Updated upstream
        setState(() {
          multiFloorPath = true;
        });
        if (pathTypeSelected == 0) {
          List<CommonLifts> commonlifts = findCommonLifts(
              landmarksMap[PathState.sourcePolyID]!.lifts!,
              landmarksMap[PathState.destinationPolyID]!.lifts!);

          await fetchroute(
              commonlifts[0].x2!,
              commonlifts[0].y2!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              bid: PathState.destinationBid,
              liftName: commonlifts[0].name);

          await fetchroute(PathState.sourceX, PathState.sourceY,
              commonlifts[0].x1!, commonlifts[0].y1!, PathState.sourceFloor,
              bid: PathState.destinationBid);

          PathState.connections[PathState.destinationBid] = {
            PathState.sourceFloor: calculateindex(
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.sourceFloor]![0]),
            PathState.destinationFloor: calculateindex(
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.destinationFloor]![0])
          };
        } else if (pathTypeSelected == 1) {
          List<CommonStairs> commonstairs = findCommonStairs(
              landmarksMap[PathState.sourcePolyID]!.stairs!,
              landmarksMap[PathState.destinationPolyID]!.stairs!);

          await fetchroute(
              commonstairs[0].x2!,
              commonstairs[0].y2!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              bid: PathState.destinationBid,
              liftName: commonstairs[0].name);

          await fetchroute(PathState.sourceX, PathState.sourceY,
              commonstairs[0].x1!, commonstairs[0].y1!, PathState.sourceFloor,
              bid: PathState.destinationBid);

          PathState.connections[PathState.destinationBid] = {
            PathState.sourceFloor: calculateindex(
                commonstairs[0].x1!,
                commonstairs[0].y1!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.sourceFloor]![0]),
            PathState.destinationFloor: calculateindex(
                commonstairs[0].x2!,
                commonstairs[0].y2!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.destinationFloor]![0])
          };
        }
      }
    } else {
      print("calculateroute else statement");
      double sourceEntrylat = 0;
      double sourceEntrylng = 0;
      double destinationEntrylat = 0;
      double destinationEntrylng = 0;

      building.landmarkdata!.then((land) async {
        for (int i = 0; i < land.landmarks!.length; i++) {
          Landmarks element = land.landmarks![i];
          print("running destination location");
          if (element.element!.subType != null &&
              element.element!.subType!.toLowerCase().contains("entry") &&
              element.buildingID == PathState.destinationBid) {
            destinationEntrylat = double.parse(element.properties!.latitude!);
            destinationEntrylng = double.parse(element.properties!.longitude!);
            if (element.floor == PathState.destinationFloor) {
              await fetchroute(
                  element.coordinateX!,
                  element.coordinateY!,
                  PathState.destinationX,
                  PathState.destinationY,
                  PathState.destinationFloor,
                  bid: PathState.destinationBid);
              print("running destination location no lift run");
            } else if (element.floor != PathState.destinationFloor) {
              setState(() {
                multiFloorPath = true;
              });
              if (pathTypeSelected == 0) {
                List<CommonLifts> commonlifts = findCommonLifts(element.lifts!,
                    landmarksMap[PathState.destinationPolyID]!.lifts!);
                await fetchroute(
                    commonlifts[0].x2!,
                    commonlifts[0].y2!,
                    PathState.destinationX,
                    PathState.destinationY,
                    PathState.destinationFloor,
                    bid: PathState.destinationBid);
                await fetchroute(element.coordinateX!, element.coordinateY!,
                    commonlifts[0].x1!, commonlifts[0].y1!, element.floor!,
                    bid: PathState.destinationBid);

                PathState.connections[PathState.destinationBid] = {
                  element.floor!: calculateindex(
                      commonlifts[0].x1!,
                      commonlifts[0].y1!,
                      building.floorDimenssion[PathState.destinationBid]![
                          element.floor!]![0]),
                  PathState.destinationFloor: calculateindex(
                      commonlifts[0].x2!,
                      commonlifts[0].y2!,
                      building.floorDimenssion[PathState.destinationBid]![
                          PathState.destinationFloor]![0])
                };
              } else if (pathTypeSelected == 1) {
                List<CommonStairs> commonstairs = findCommonStairs(
                    element.stairs!,
                    landmarksMap[PathState.destinationPolyID]!.stairs!);
                await fetchroute(
                    commonstairs[0].x2!,
                    commonstairs[0].y2!,
                    PathState.destinationX,
                    PathState.destinationY,
                    PathState.destinationFloor,
                    bid: PathState.destinationBid);
                await fetchroute(element.coordinateX!, element.coordinateY!,
                    commonstairs[0].x1!, commonstairs[0].y1!, element.floor!,
                    bid: PathState.destinationBid);

                PathState.connections[PathState.destinationBid] = {
                  element.floor!: calculateindex(
                      commonstairs[0].x1!,
                      commonstairs[0].y1!,
                      building.floorDimenssion[PathState.destinationBid]![
                          element.floor!]![0]),
                  PathState.destinationFloor: calculateindex(
                      commonstairs[0].x2!,
                      commonstairs[0].y2!,
                      building.floorDimenssion[PathState.destinationBid]![
                          PathState.destinationFloor]![0])
                };
              }
            }
            break;
          }
        }
        // Landmarks source= landmarksMap[PathState.sourcePolyID]!;
        // double sourceLat=double.parse(source.properties!.latitude!);
        // double sourceLng=double.parse(source.properties!.longitude!);
        //
        //
        // Landmarks destination= landmarksMap[PathState.destinationPolyID]!;
        // double destinationLat=double.parse(source.properties!.latitude!);
        // double destinationLng=double.parse(source.properties!.longitude!);

        for (int i = 0; i < land.landmarks!.length; i++) {
          Landmarks element = land.landmarks![i];
          print("running source location");
          if (element.element!.subType != null &&
              element.element!.subType!.toLowerCase().contains("entry") &&
              element.buildingID == PathState.sourceBid) {
            sourceEntrylat = double.parse(element.properties!.latitude!);
            sourceEntrylng = double.parse(element.properties!.longitude!);
            if (PathState.sourceFloor == element.floor) {
              await fetchroute(PathState.sourceX, PathState.sourceY,
                  element.coordinateX!, element.coordinateY!, element.floor!,
                  bid: PathState.sourceBid);
              print("running source location no lift run");
            } else if (PathState.sourceFloor != element.floor) {
              if (pathTypeSelected == 0) {
                List<CommonLifts> commonlifts = findCommonLifts(
                    landmarksMap[PathState.sourcePolyID]!.lifts!,
                    element.lifts!);

                await fetchroute(commonlifts[0].x2!, commonlifts[0].y2!,
                    element.coordinateX!, element.coordinateY!, element.floor!,
                    bid: PathState.sourceBid);
                await fetchroute(
                    PathState.sourceX,
                    PathState.sourceY,
                    commonlifts[0].x1!,
                    commonlifts[0].y1!,
                    PathState.sourceFloor,
                    bid: PathState.sourceBid);

                PathState.connections[PathState.sourceBid] = {
                  PathState.sourceFloor: calculateindex(
                      commonlifts[0].x1!,
                      commonlifts[0].y1!,
                      building.floorDimenssion[PathState.sourceBid]![
                          PathState.sourceFloor]![0]),
                  element.floor!: calculateindex(
                      commonlifts[0].x2!,
                      commonlifts[0].y2!,
                      building.floorDimenssion[PathState.sourceBid]![
                          element.floor!]![0])
                };
              } else if (pathTypeSelected == 1) {
                List<CommonStairs> commonstairs = findCommonStairs(
                    landmarksMap[PathState.sourcePolyID]!.stairs!,
                    element.stairs!);

                await fetchroute(commonstairs[0].x2!, commonstairs[0].y2!,
                    element.coordinateX!, element.coordinateY!, element.floor!,
                    bid: PathState.sourceBid);
                await fetchroute(
                    PathState.sourceX,
                    PathState.sourceY,
                    commonstairs[0].x1!,
                    commonstairs[0].y1!,
                    PathState.sourceFloor,
                    bid: PathState.sourceBid);

                PathState.connections[PathState.sourceBid] = {
                  PathState.sourceFloor: calculateindex(
                      commonstairs[0].x1!,
                      commonstairs[0].y1!,
                      building.floorDimenssion[PathState.sourceBid]![
                          PathState.sourceFloor]![0]),
                  element.floor!: calculateindex(
                      commonstairs[0].x2!,
                      commonstairs[0].y2!,
                      building.floorDimenssion[PathState.sourceBid]![
                          element.floor!]![0])
                };
              }
            }
            break;
          }
        }

        OutBuildingModel? buildData = await OutBuildingData.outBuildingData(
            sourceEntrylat,
            sourceEntrylng,
            destinationEntrylat,
            destinationEntrylng);
        print("build data: $buildData");

        List<LatLng> coords = [];
        if (buildData != null) {
          int len = buildData!.data!.path!.length;
          for (int i = 0; i < len; i++) {
            coords.add(LatLng(buildData!.data!.path![i].lat!,
                buildData!.data!.path![i].lng!));
          }

          List<String> key = [PathState.sourceBid, PathState.destinationBid];
          interBuildingPath[key] = Set();
          interBuildingPath[key]!.add(gmap.Polyline(
            polylineId: PolylineId("InterBuilding"),
            points: coords,
            color: Colors.red,
            width: 1,
          ));
=======
        List<CommonConnection> commonlifts = findCommonLifts(
            landmarksMap[PathState.sourcePolyID]!,
            landmarksMap[PathState.destinationPolyID]!,
            accessibleby);

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
            bid: PathState.destinationBid,
            liftName: commonlifts[0].name));

        fetchrouteFutures.add(() => fetchroute(
            PathState.sourceX,
            PathState.sourceY,
            commonlifts[0].x1!,
            commonlifts[0].y1!,
            PathState.sourceFloor,
            bid: PathState.destinationBid,
            liftName: commonlifts[0].name));

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
      runPaths(fetchrouteFutures);
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
        }

        Landmarks? CampusEntry = await findCampusEntry(land, buildingEntry);

        if (PathState.destinationBid == buildingAllApi.outdoorID) {
          fetchrouteFutures.add(() => fetchroute(
              CampusEntry!.coordinateX!,
              CampusEntry!.coordinateY!,
              PathState.destinationX,
              PathState.destinationY,
              CampusEntry.floor!,
              bid: CampusEntry.buildingID));
          if (PathState.sourceFloor == buildingEntry!.floor) {
            fetchrouteFutures.add(() => fetchroute(
                PathState.sourceX,
                PathState.sourceY,
                buildingEntry!.coordinateX!,
                buildingEntry!.coordinateY!,
                buildingEntry!.floor!,
                bid: PathState.sourceBid,
                renderDestination: false));
          } else if (PathState.sourceFloor != buildingEntry!.floor) {
            List<dynamic> commonlifts = findCommonLifts(
                landmarksMap[PathState.sourcePolyID]!,
                buildingEntry!,
                accessibleby);
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
                bid: PathState.sourceBid,
                renderDestination: false));
            fetchrouteFutures.add(() => fetchroute(
                  PathState.sourceX,
                  PathState.sourceY,
                  commonlifts[0].x1!,
                  commonlifts[0].y1!,
                  PathState.sourceFloor,
                  bid: PathState.sourceBid,
                ));

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
          if (PathState.sourceFloor == buildingEntry!.floor) {
            fetchrouteFutures.add(() => fetchroute(
                buildingEntry!.coordinateX!,
                buildingEntry!.coordinateY!,
                PathState.sourceX,
                PathState.sourceY,
                PathState.sourceFloor,
                bid: buildingEntry.buildingID,
                renderDestination: false));
          } else if (PathState.sourceFloor != buildingEntry!.floor) {
            List<dynamic> commonlifts = findCommonLifts(
                landmarksMap[PathState.sourcePolyID]!,
                buildingEntry!,
                accessibleby);
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
                  PathState.sourceX,
                  PathState.sourceY,
                  PathState.sourceFloor,
                  bid: PathState.sourceBid,
                ));

            fetchrouteFutures.add(() => fetchroute(
                buildingEntry!.coordinateX!,
                buildingEntry!.coordinateY!,
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                buildingEntry!.floor!,
                bid: PathState.sourceBid,
                renderDestination: false));

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
              PathState.destinationX,
              PathState.destinationY,
              CampusEntry!.coordinateX!,
              CampusEntry!.coordinateY!,
              PathState.destinationFloor,
              bid: CampusEntry.buildingID));
        }
        runPaths(fetchrouteFutures);
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
              bid: PathState.destinationBid,
              renderSource: false));
        } else if (destinationEntry.floor != PathState.destinationFloor) {
          List<dynamic> commonlifts = findCommonLifts(destinationEntry,
              landmarksMap[PathState.destinationPolyID]!, accessibleby);
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
              bid: PathState.destinationBid));
          fetchrouteFutures.add(() => fetchroute(
              destinationEntry.coordinateX!,
              destinationEntry.coordinateY!,
              commonlifts[0].x1!,
              commonlifts[0].y1!,
              destinationEntry.floor!,
              bid: PathState.destinationBid,
              renderSource: false));

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
                bid: CampusSourceEntry.buildingID,
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
              bid: PathState.sourceBid,
              renderDestination: false));
        } else if (PathState.sourceFloor != sourceEntry.floor) {
          List<dynamic> commonlifts = findCommonLifts(
              landmarksMap[PathState.sourcePolyID]!, sourceEntry, accessibleby);
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
              bid: PathState.sourceBid,
              renderDestination: false));
          fetchrouteFutures.add(() => fetchroute(
                PathState.sourceX,
                PathState.sourceY,
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                PathState.sourceFloor,
                bid: PathState.sourceBid,
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
>>>>>>> Stashed changes
        }
        runPaths(fetchrouteFutures);
      });
<<<<<<< Updated upstream
      print("different building detected");

      print(PathState.path.keys);
      print(pathMarkers.keys);
    }

    double time = 0;
    double distance = 0;
    DateTime currentTime = DateTime.now();
    if (PathState.path.isNotEmpty) {
      PathState.path.forEach((key, value) {
        time = time + value.length / 120;
        distance = distance + value.length;
=======
    }
    _isLandmarkPanelOpen = false;

    setState(() {
      SingletonFunctionController.building
          .floor[buildingAllApi.selectedBuildingID] = PathState.sourceFloor;
    });
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
    final Uint8List realWorldPathMarker =
        await getImagesFromMarker('assets/rw.png', 30);

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
>>>>>>> Stashed changes
      });
      time = time.ceil().toDouble();

      distance = distance * 0.3048;
      distance = double.parse(distance.toStringAsFixed(1));
      if (PathState.destinationName == "Your current location") {
        speak(
            "${nearestLandInfomation.name} is $distance meter away. Click Start to Navigate.");
      } else {
        speak(
            "${PathState.destinationName} is $distance meter away. Click Start to Navigate.");
      }
    }
  }

  List<int> beaconCord = [];
  double cordL = 0;
  double cordLt = 0;
  List<List<int>> getPoints = [];
  List<int> getnodes = [];

<<<<<<< Updated upstream
  Future<List<int>> fetchroute(
      int sourceX, int sourceY, int destinationX, int destinationY, int floor,
      {String? bid = null, String? liftName}) async {
    int numRows = building.floorDimenssion[bid]![floor]![1]; //floor breadth
    int numCols = building.floorDimenssion[bid]![floor]![0]; //floor length
    int sourceIndex = calculateindex(sourceX, sourceY, numCols);
    int destinationIndex = calculateindex(destinationX, destinationY, numCols);

    print("numcol $numCols");

    List<int> path = await findBestPathAmongstBoth(
        numRows,
        numCols,
        building.nonWalkable[bid]![floor]!,
        sourceIndex,
        destinationIndex,
        building,
        floor,
        bid ?? "");

    List<int> turns = tools.getTurnpoints(path, numCols);
    for (int i = 0; i < turns.length; i++) {
      int x = turns[i] % numCols;
      int y = turns[i] ~/ numCols;
      getPoints.add([x, y]);
    }
    getPoints.add([destinationX, destinationY]);
    List<Landmarks> nearbyPathLandmarks = [];
    building.landmarkdata!.then((value) {
      List<Landmarks> nearbyLandmarks = tools.findNearbyLandmark(
          path, value.landmarksMap!, 5, numCols, floor, bid!);
      pathState.nearbyLandmarks = nearbyLandmarks;
      // PathState.nearbyLandmarks.forEach((element) {
      //   print(element.name);
      // });
      tools
          .associateTurnWithLandmark(path, nearbyLandmarks, numCols)
          .then((value) {
        PathState.associateTurnWithLandmark = value;
        // PathState.associateTurnWithLandmark.forEach((key, value) {
        //   print("${key} , ${value.name}");
        // });
        List<direction> directions = [];
        if (liftName != null) {
          directions.add(direction(-1, "Take ${liftName}", null, null,
              floor.toDouble(), null, null, floor, bid ?? ""));
        }
        directions.addAll(tools.getDirections(
            path, numCols, value, floor, bid ?? "", PathState));
        // directions.forEach((element) {
        //   print("directioons ${value[element.node]} +++  ${element.node}  +++++  ${element.turnDirection}  +++++++  ${element.nearbyLandmark}");
        // });

        directions.addAll(PathState.directions);
        PathState.directions = directions;
      });

      if (destinationX == PathState.destinationX &&
          destinationY == PathState.destinationY) {
        PathState.directions.add(direction(
            destinationIndex,
            value.landmarksMap![PathState.destinationPolyID]!.name!,
            value.landmarksMap![PathState.destinationPolyID],
            0,
            0,
            destinationX,
            destinationY,
            floor,
            bid,
            isDestination: true));
      }
    });

    List<Cell> Cellpath =
        findCorridorSegments(path, building.nonWalkable[bid]![floor]!, numCols);
    PathState.CellTurnPoints = tools.getCellTurnpoints(Cellpath, numCols);
    List<int> temp = [];
    List<Cell> Celltemp = [];

    temp.addAll(path);
    Celltemp.addAll(Cellpath);
    temp.addAll(PathState.singleListPath);
    Celltemp.addAll(PathState.singleCellListPath);
    PathState.singleListPath = temp;
    PathState.singleCellListPath = Celltemp;

    PathState.path[floor] = path;
=======
  List<LatLng> _polylineCoordinates = [];
  Marker? _movingMarker;
  Timer? _polytimer;
  int _currentIndex = 0;
  AnimationController? _animationController;
  Animation<double>? _polyanimation;
  late LatLng sourcePosition;
  late LatLng destinationPosition;
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;

  Future<Map<String, dynamic>> fetchroute(
      int sourceX, int sourceY, int destinationX, int destinationY, int floor,
      {String? bid = null,
      String? liftName,
      bool renderSource = true,
      bool renderDestination = true}) async {
    print(
        "checks for campus $bid ${SingletonFunctionController.building.floorDimenssion[bid]}");
    int numRows = SingletonFunctionController
        .building.floorDimenssion[bid]![floor]![1]; //floor breadth
    int numCols = SingletonFunctionController
        .building.floorDimenssion[bid]![floor]![0]; //floor length
    int sourceIndex = calculateindex(sourceX, sourceY, numCols);
    int destinationIndex = calculateindex(destinationX, destinationY, numCols);
    PathState.numCols ??= {};
    PathState.numCols![bid!] = PathState.numCols![bid] ?? {};
    PathState.numCols![bid]![floor] = numCols;

    List<int> path = [];

    try {
      PathModel model = Building.waypoint[bid]!
          .firstWhere((element) => element.floor == floor);
      Map<String, List<dynamic>> adjList = model.pathNetwork;
      path = await findShortestPath(
          adjList,
          sourceX,
          sourceY,
          destinationX,
          destinationY,
          SingletonFunctionController.building.nonWalkable[bid]![floor]!,
          numCols,
          numRows,
          isoutdoorPath: bid == buildingAllApi.outdoorID);
      print("path from waypoint for bid $bid $path");
    } catch (e) {
      print("error in path finding $e");
      if (bid != buildingAllApi.outdoorID) {
        path = await findPath(
          numRows,
          numCols,
          SingletonFunctionController.building.nonWalkable[bid]![floor]!,
          sourceIndex,
          destinationIndex,
        );
        path = getFinalOptimizedPath(
            path,
            SingletonFunctionController.building.nonWalkable[bid]![floor]!,
            numCols,
            sourceX,
            sourceY,
            destinationX,
            destinationY);
      }
    }
    if (path.isEmpty) {
      wsocket.message["path"]["didPathForm"] = false;
    } else {
      wsocket.message["path"]["didPathForm"] =
          path[0] == sourceIndex && path[path.length - 1] == destinationIndex;
    }

    if (bid == buildingAllApi.outdoorID) {
      path.forEach((turn) => getPoints.add([turn % numCols, turn ~/ numCols]));
    } else {
      List<int> turns = tools.getTurnpoints(path, numCols);
      getPoints.add([sourceX % numCols, sourceY ~/ numCols]);
      turns.forEach((turn) => getPoints.add([turn % numCols, turn ~/ numCols]));
      getPoints.add([destinationX, destinationY]);
    }

    Set<Marker> innerMarker = Set();

    PathState.path[floor] = path;
    List<Cell> Cellpath = findCorridorSegments(
        path,
        SingletonFunctionController.building.nonWalkable[bid]![floor]!,
        numCols,
        bid,
        floor,
        SingletonFunctionController.building.patchData);
>>>>>>> Stashed changes
    PathState.Cellpath[floor] = Cellpath;

    List<double> svalue = [];
    List<double> dvalue = [];

    if (path.isNotEmpty) {
<<<<<<< Updated upstream
      if (floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            building.polyLineData!.polyline!.floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(floor),
            building.polyLineData!.polyline!.floors!);
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
=======
      if (SingletonFunctionController.building.floor[bid] != floor) {
        setState(() {
          SingletonFunctionController.building.floor[bid] = floor;
        });
      }
      if (floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            SingletonFunctionController
                .building.polylinedatamap[bid]!.polyline!.floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(floor),
            SingletonFunctionController
                .building.polylinedatamap[bid]!.polyline!.floors!);
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

>>>>>>> Stashed changes
        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
      }
<<<<<<< Updated upstream
      List<double> svalue = [];
      List<double> dvalue = [];
      if (bid != null) {
        print("Himanshucheckerpath in if block ");
        print("building.patchData[bid]");
        print(building.patchData[bid]!.patchData!.fileName);
        svalue = tools.localtoglobal(sourceX, sourceY,
            patchData: building.patchData[bid]);
        dvalue = tools.localtoglobal(destinationX, destinationY,
            patchData: building.patchData[bid]);
      } else {
        print("Himanshucheckerpath in else block ");
        svalue = tools.localtoglobal(sourceX, sourceY);
        dvalue = tools.localtoglobal(destinationX, destinationY);
=======

      svalue = tools.localtoglobal(sourceX, sourceY,
          SingletonFunctionController.building.patchData[bid]);
      dvalue = tools.localtoglobal(destinationX, destinationY,
          SingletonFunctionController.building.patchData[bid]);

      // if(sourceX == PathState.sourceX || sourceY == PathState.sourceY){
      //   List<double> p1 = tools.localtoglobal(PathState.sourceX, PathState.sourceY,
      //       SingletonFunctionController.building.patchData[PathState.sourceBid]);
      //   List<double> p2 = tools.localtoglobal(PathState.destinationX, PathState.destinationY,
      //       SingletonFunctionController.building.patchData[PathState.destinationBid]);
      //   if(PathState.sourceFloor == PathState.destinationFloor){
      //
      //     setCameraPositionusingCoords(
      //         [LatLng(p1[0],p1[1]), LatLng(p2[0],p2[1])]);
      //   }else{
      //
      //     setCameraPositionusingCoords(
      //         [LatLng(svalue[0],svalue[1]), LatLng(dvalue[0],dvalue[1])]);
      //   }
      // }

      List<LatLng> coordinates = [];
      if (PathState.sourceBid == bid && floor == PathState.sourceFloor) {
        for (var node in path) {
          int row = (node % numCols); //divide by floor length
          int col = (node ~/ numCols); //divide by floor length
          List<double> value = tools.localtoglobal(
              row, col, SingletonFunctionController.building.patchData[bid]);
          coordinates.add(LatLng(value[0], value[1]));
          if (singleroute[bid] == null) {
            singleroute.putIfAbsent(bid, () => Map());
          }
          if (singleroute[bid]![floor] != null) {
            gmap.Polyline oldPolyline = singleroute[bid]![floor]!.firstWhere(
              (polyline) => polyline.polylineId.value == bid,
            );
            gmap.Polyline updatedPolyline = gmap.Polyline(
              polylineId: oldPolyline.polylineId,
              points: coordinates,
              color: oldPolyline.color,
              width: oldPolyline.width,
            );
            setState(() {
              // Remove the old polyline and add the updated polyline
              singleroute[bid]![floor]!.remove(oldPolyline);
              singleroute[bid]![floor]!.add(updatedPolyline);
            });
          } else {
            setState(() {
              singleroute[bid]!.putIfAbsent(floor, () => Set());
              singleroute[bid]![floor]?.add(gmap.Polyline(
                polylineId: PolylineId("$bid"),
                points: coordinates,
                color: Colors.blueAccent,
                width: 8,
              ));
            });
          }
          await Future.delayed(Duration(microseconds: 1500));
        }
      } else {
        if (singleroute[bid] == null) {
          singleroute.putIfAbsent(bid, () => Map());
        }
        for (var node in path) {
          int row = (node % numCols); //divide by floor length
          int col = (node ~/ numCols); //divide by floor length

          List<double> value = tools.localtoglobal(
              row, col, SingletonFunctionController.building.patchData[bid]);

          coordinates.add(LatLng(value[0], value[1]));
        }

        setState(() {
          singleroute[bid]!.putIfAbsent(floor, () => Set());
          singleroute[bid]![floor]?.add(gmap.Polyline(
            polylineId: PolylineId("$bid"),
            points: coordinates,
            color: Colors.blueAccent,
            width: 8,
          ));
        });
>>>>>>> Stashed changes
      }

      final Uint8List tealtorch =
          await getImagesFromMarker('assets/tealtorch.png', 35);

<<<<<<< Updated upstream
      Set<Marker> innerMarker = Set();

      innerMarker.add(Marker(
          markerId: MarkerId("destination${bid}"),
          position: LatLng(dvalue[0], dvalue[1]),
          icon: BitmapDescriptor.defaultMarker));
      innerMarker.add(
        Marker(
          markerId: MarkerId('source${bid}'),
          position: LatLng(svalue[0], svalue[1]),
          icon: BitmapDescriptor.fromBytes(tealtorch),
          anchor: Offset(0.5, 0.5),
        ),
      );
      setCameraPosition(innerMarker);
      pathMarkers[floor] = innerMarker;
    } else {
      print("No path found.");
=======
      if (liftName != null) {
        innerMarker.add(Marker(
          markerId: MarkerId("lift${bid}"),
          position: sourceX == PathState.sourceX
              ? LatLng(dvalue[0], dvalue[1])
              : LatLng(svalue[0], svalue[1]),
          icon: await CustomMarker(
                  text:
                      "To Floor ${sourceX == PathState.sourceX ? PathState.destinationFloor : PathState.sourceFloor}",
                  dirIcon: (sourceX == PathState.sourceX)
                      ? Icons.elevator_outlined
                      : Icons.elevator_outlined)
              .toBitmapDescriptor(
                  logicalSize: const Size(150, 150),
                  imageSize: const Size(300, 400)),
          anchor: Offset(0.0, 1.0),
          onTap: () {
            if (!user.isnavigating) {
              _polygon.clear();
              circles.clear();
              SingletonFunctionController
                      .building.floor[buildingAllApi.getStoredString()] =
                  PathState.sourceFloor == floor
                      ? PathState.destinationFloor
                      : PathState.sourceFloor;
              createRooms(
                SingletonFunctionController.building
                    .polylinedatamap[buildingAllApi.getStoredString()]!,
                SingletonFunctionController
                    .building.floor[buildingAllApi.getStoredString()]!,
              );
              SingletonFunctionController.building.landmarkdata!.then((value) {
                createMarkers(
                    value,
                    SingletonFunctionController
                        .building.floor[buildingAllApi.getStoredString()]!,
                    bid: buildingAllApi.getStoredString());
              });
            }
          },
        ));
      }

      setState(() {
        if (renderDestination && liftName == null) {
          innerMarker.add(
            Marker(
              markerId: MarkerId('destination${bid}'),
              position: LatLng(dvalue[0], dvalue[1]),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        }
        if (renderSource && liftName == null) {
          innerMarker.add(
            Marker(
              markerId: MarkerId('source${bid}'),
              position: LatLng(svalue[0], svalue[1]),
              icon: BitmapDescriptor.fromBytes(tealtorch),
              anchor: Offset(0.5, 0.5),
            ),
          );
        }
        PathState.innerMarker[floor] = innerMarker;
        pathMarkers.putIfAbsent(bid, () => Map());
        pathMarkers[bid]![floor] = innerMarker;
      });
>>>>>>> Stashed changes
    }
    print("returning dvalue for $bid $svalue and $dvalue");
    return {
      "path": path,
      "CellPath": Cellpath,
      "liftName": liftName,
      "svalue": svalue,
      "dvalue": dvalue
    };
  }

<<<<<<< Updated upstream
    List<LatLng> coordinates = [];

    for (int node in path) {
      if (!building.nonWalkable[bid]![floor]!.contains(node)) {
        int row = (node % numCols); //divide by floor length
        int col = (node ~/ numCols); //divide by floor length
        if (bid != null) {
          List<double> value =
              tools.localtoglobal(row, col, patchData: building.patchData[bid]);

          coordinates.add(LatLng(value[0], value[1]));
        } else {
          List<double> value = tools.localtoglobal(row, col);
          coordinates.add(LatLng(value[0], value[1]));
        }
      }
    }
    setState(() {
      singleroute.putIfAbsent(floor, () => Set());
      singleroute[floor]?.add(gmap.Polyline(
        polylineId: PolylineId("$bid"),
        points: coordinates,
        color: Colors.red,
        width: 5,
      ));
    });

    // setState(() {
    //   Set<gmap.Polyline> innerset = Set();
    //   innerset.add(gmap.Polyline(
    //     polylineId: PolylineId("route"),
    //     points: coordinates,
    //     color: Colors.red,
    //     width: 3,
    //   ));
    //   singleroute[floor] = innerset;
    // });

    building.floor[bid!] = floor;
    createRooms(building.polyLineData!, floor);
    return path;
=======
  Future<void> createMarkersAndDirections(List<Cell> path,
      {String? liftName}) async {
    await SingletonFunctionController.building.landmarkdata!.then((value) {
      List<Landmarks> nearbyLandmarks =
          tools.findNearbyLandmark(path, value.landmarksMap!, 5);
      pathState.nearbyLandmarks = nearbyLandmarks;
      tools
          .associateTurnWithLandmark(path, nearbyLandmarks)
          .then((value) async {
        PathState.associateTurnWithLandmark = value;
        PathState.associateTurnWithLandmark.removeWhere((key, value) =>
            value.properties!.polyId == PathState.destinationPolyID);
        // PathState.associateTurnWithLandmark.forEach((key, value) {
        //
        // });
        destiPoly = PathState.destinationPolyID;
        List<direction> directions = [];
        if (liftName != null) {
          directions.add(direction(
              -1,
              "Take ${liftName} and Go to ${PathState.destinationFloor} Floor",
              null,
              null,
              path.first.floor.toDouble(),
              null,
              null,
              path.first.floor,
              path.first.bid ?? ""));
        }
        directions.addAll(tools.getDirections(path, value, PathState, context));
        // directions.forEach((element) {
        //
        // });

        directions.addAll(PathState.directions);
        PathState.directions = directions;
      });
    });
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        building.numberOfFloors[buildingAllApi.getStoredString()]!,
=======
        SingletonFunctionController
            .building.numberOfFloors[buildingAllApi.getStoredString()]!,
>>>>>>> Stashed changes
        (index) => index);

    return Semantics(
      excludeSemantics: excludeFloorSemanticWork,
<<<<<<< Updated upstream
      child: Container(
        height: 300,
        width: 100,
        child: ListView.builder(
            itemCount:
                building.numberOfFloors[buildingAllApi.getStoredString()]!,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(top: 10),
                child: ClipRRect(
                  // Adjust the radius as needed
                  child: Material(
                    elevation: 4.0, // Add elevation for shadow effect
                    borderRadius: BorderRadius.circular(25.0),
                    child: Semantics(
                      label: "Floor ${index}",
                      child: Container(
                        width: 30,
                        height: 42,
                        child: ListTile(
                          onTap: () {
                            building.floor[buildingAllApi.getStoredString()] =
                                index;
                            createRooms(
                              building.polylinedatamap[
                                  buildingAllApi.getStoredString()]!,
                              building.floor[buildingAllApi.getStoredString()]!,
                            );
                            if (pathMarkers[index] != null) {
                              //setCameraPosition(pathMarkers[i]!);
                            }
                            building.landmarkdata!.then((value) {
                              createMarkers(
                                value,
                                building
                                    .floor[buildingAllApi.getStoredString()]!,
                              );
                            });
                          },
                          title: Center(
                            child: Semantics(
                              excludeSemantics: true,
                              child: Text(
                                floorNumbers[index]
                                    .toString(), // Text to be displayed
                                style: TextStyle(
                                  color: Colors.black, // Text color
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
=======
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
                              bid: buildingAllApi.getStoredString());
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
>>>>>>> Stashed changes
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

  PanelController _routeDetailPannelController = new PanelController();
  bool startingNavigation = false;
  Widget routeDeatilPannel() {
    setState(() {
      semanticShouldBeExcluded = true;
    });
    double? angle;
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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> directionWidgets = [];
    directionWidgets.clear();
    if (PathState.directions.isNotEmpty) {
      if (PathState.directions[0].distanceToNextTurn != null) {
        directionWidgets.add(directionInstruction(
            direction: "Go Straight",
            distance: (PathState.directions[0].distanceToNextTurn! * 0.3048)
                .ceil()
                .toString()));
      }

      for (int i = 1; i < PathState.directions.length; i++) {
        if (!PathState.directions[i].isDestination) {
          if (PathState.directions[i].nearbyLandmark != null) {
            directionWidgets.add(directionInstruction(
                direction: PathState.directions[i].turnDirection == "Straight"
                    ? "Go Straight"
                    : "Turn ${PathState.directions[i].turnDirection!} from ${PathState.directions[i].nearbyLandmark!.name!}, and Go Straight",
                distance: (PathState.directions[i].distanceToNextTurn! * 0.3048)
                    .ceil()
                    .toString()));
          } else {
            if (PathState.directions[i].node == -1) {
              directionWidgets.add(directionInstruction(
                  direction: "${PathState.directions[i].turnDirection!}",
                  distance:
<<<<<<< Updated upstream
                      "and go to ${PathState.directions[i].distanceToPrevTurn ?? 0.toInt()} floor"));
            } else {
              directionWidgets.add(directionInstruction(
                  direction: PathState.directions[i].turnDirection == "Straight"
                      ? "Go Straight"
                      : "Turn ${PathState.directions[i].turnDirection!}, and Go Straight",
                  distance:
                      (PathState.directions[i].distanceToNextTurn ?? 0 * 0.3048)
                          .ceil()
                          .toString()));
=======
                      "${LocaleData.and.getString(context)} ${LocaleData.goto.getString(context)} ${PathState.directions[i].distanceToPrevTurn?.toInt() ?? 0.toInt()} ${LocaleData.floor.getString(context)}",
                  context: context));
            } else {
              directionWidgets.add(directionInstruction(
                direction: PathState.directions[i].turnDirection == "Straight"
                    ? '${LocaleData.gostraight.getString(context)}'
                    : "${LocaleData.turn.getString(context)} ${LocaleData.getProperty4(PathState.directions[i].turnDirection!, context)}, ${LocaleData.and.getString(context)} ${LocaleData.gostraight.getString(context)}",
                distance:
                    (PathState.directions[i].distanceToNextTurn ?? 0 * 0.3048)
                        .ceil()
                        .toString(),
                context: context,
              ));
>>>>>>> Stashed changes
            }
          }
        }
      }
    }

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
    double distance = 0;
    DateTime currentTime = DateTime.now();
<<<<<<< Updated upstream
    if (PathState.path.isNotEmpty) {
      PathState.path.forEach((key, value) {
        time = time + value.length / 120;
        distance = distance + value.length;
      });
=======
    if (PathState.singleCellListPath.isNotEmpty) {
      distance = tools.PathDistance(PathState.singleCellListPath);
      time = distance / 120;
>>>>>>> Stashed changes
      time = time.ceil().toDouble();

      distance = distance * 0.3048;
      distance = double.parse(distance.toStringAsFixed(1));
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));

    return Visibility(
      visible: _isRoutePanelOpen,
      child: Stack(
        children: [
          Container(
<<<<<<< Updated upstream
            margin: EdgeInsets.only(left: 16, top: 16),
            height: (multiFloorPath) ? 160 : 119,
            width: screenWidth - 32,
=======
            height:
                PathState.sourceFloor != PathState.destinationFloor ? 170 : 130,
            width: screenWidth,
>>>>>>> Stashed changes
            padding: EdgeInsets.only(top: 15, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Semantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< Updated upstream
                  Container(
                    child: IconButton(
                        onPressed: () {
                          showMarkers();
                          List<double> mvalues = tools.localtoglobal(
                              PathState.destinationX, PathState.destinationY);
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
                          _isBuildingPannelOpen = true;
                          clearPathVariables();
                          setState(() {
                            Marker? temp = selectedroomMarker[
                                    buildingAllApi.getStoredString()]
                                ?.first;

                            selectedroomMarker.clear();
                            selectedroomMarker[buildingAllApi.getStoredString()]
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
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Color(0xffE2E2E2)),
                            ),
                            padding:
                                EdgeInsets.only(left: 8, top: 7, bottom: 8),
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
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DestinationSearchPage(
                                          hintText: 'Source location',
                                          voiceInputEnabled: false,
                                        ))).then((value) {
                              onSourceVenueClicked(value);
                            });
                          },
                        ),
                        InkWell(
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Color(0xffE2E2E2)),
                            ),
                            padding:
                                EdgeInsets.only(left: 8, top: 7, bottom: 8),
                            child: Semantics(
                              onDidGainAccessibilityFocus: closeRoutePannel,
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DestinationSearchPage(
                                          hintText: 'Destination location',
                                          voiceInputEnabled: false,
                                        ))).then((value) {
                              _isBuildingPannelOpen = false;
                              onDestinationVenueClicked(value);
                            });
                          },
                        ),

                        (multiFloorPath)
                            ? Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pathTypeSelected = 0;
                                        });
                                        building.landmarkdata!.then((value) {
                                          calculateroute(value.landmarksMap!);
                                        });
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: (pathTypeSelected == 0)
                                                ? Colors.cyan
                                                : Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(10),
                                        child: Text(
                                          'Lift',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pathTypeSelected = 1;
                                        });
                                        building.landmarkdata!.then((value) {
                                          calculateroute(value.landmarksMap!);
                                        });
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: (pathTypeSelected == 1)
                                                ? Colors.cyan
                                                : Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(10),
                                        child: Text(
                                          'Stair',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        // ChipsChoice<String>.multiple(
                        //   value: optionsTags,
                        //   onChanged: (val) {
                        //     print("calledddd");
                        //     // print(
                        //     //     "Filter change${val}${value.values}");
                        //     // value.put(0, val);
                        //     setState(() {
                        //       optionsTags = val;
                        //       onTagsChanged();
                        //     });
                        //   },
                        //   choiceItems: C2Choice.listFrom<String, String>(
                        //     source: options,
                        //     value: (i, v) => v,
                        //     label: (i, v) => v,
                        //     tooltip: (i, v) => v,
                        //   ),
                        //   choiceCheckmark: true,
                        //   choiceStyle: C2ChipStyle.filled(
                        //       selectedStyle: const C2ChipStyle(
                        //           borderRadius: BorderRadius.all(
                        //             Radius.circular(7),
                        //           ),
                        //           backgroundColor: Color(0XFFABF9F4)),
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(7),
                        //       ),
                        //       borderStyle: BorderStyle.solid),
                        //   wrapped: false,
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            PathState.swap();
                            PathState.path.clear();
                            pathMarkers.clear();
                            PathState.directions.clear();
                            clearPathVariables();
                            building.landmarkdata!.then((value) {
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
=======
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: IconButton(
                            onPressed: () {
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
                        child: Column(
                          children: [
                            InkWell(
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Color(0xffE2E2E2)),
                                ),
                                padding:
                                    EdgeInsets.only(left: 8, top: 7, bottom: 8),
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
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DestinationSearchPage(
                                              hintText: 'Source location',
                                              voiceInputEnabled: false,
                                              userLocalized: user.key,
                                            ))).then((value) async {
                                  // onLandmarkVenueClicked(value,DirectlyStartNavigation: true);
                                  onSourceVenueClicked(value);
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Color(0xffE2E2E2)),
                                ),
                                padding:
                                    EdgeInsets.only(left: 8, top: 7, bottom: 8),
                                child: Semantics(
                                  onDidGainAccessibilityFocus: closeRoutePannel,
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DestinationSearchPage(
                                              hintText: 'Destination location',
                                              voiceInputEnabled: false,
                                            ))).then((value) {
                                  _isBuildingPannelOpen = false;

                                  onDestinationVenueClicked(value);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: IconButton(
                            onPressed: () {
                              setState(() {
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
                  PathState.sourceFloor != PathState.destinationFloor
                      ? Container(
                          margin: EdgeInsets.only(top: 8, left: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 112,
                                margin: EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                    onPressed: () {
                                      PathState.accessiblePath = "Stairs";
                                      PathState.clearforaccessiblepath();
                                      SingletonFunctionController
                                          .building.landmarkdata!
                                          .then((value) {
                                        try {
                                          calculateroute(value.landmarksMap!,
                                              accessibleby: "Stairs");
                                        } catch (e) {}
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.greenAccent,
                                        backgroundColor:
                                            PathState.accessiblePath == "Stairs"
                                                ? Color(0xff24B9B0)
                                                : Colors.white,
                                        elevation:
                                            0 // Set the text color to black
                                        ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.stairs,
                                            color: PathState.accessiblePath ==
                                                    "Stairs"
                                                ? Colors.white
                                                : Color(0xff24B9B0),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 3),
                                            child: Text(
                                              "Stairs",
                                              style: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    PathState.accessiblePath ==
                                                            "Stairs"
                                                        ? Colors.white
                                                        : Colors.black,
                                                height: 20 / 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              Container(
                                width: 110,
                                margin: EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                    onPressed: () {
                                      PathState.accessiblePath = "Lifts";
                                      PathState.clearforaccessiblepath();
                                      SingletonFunctionController
                                          .building.landmarkdata!
                                          .then((value) {
                                        try {
                                          calculateroute(value.landmarksMap!,
                                              accessibleby: "Lifts");
                                        } catch (e) {}
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.greenAccent,
                                        backgroundColor:
                                            PathState.accessiblePath == "Lifts"
                                                ? Color(0xff24B9B0)
                                                : Colors.white,
                                        elevation:
                                            0 // Set the text color to black
                                        ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.elevator,
                                            color: PathState.accessiblePath ==
                                                    "Lifts"
                                                ? Colors.white
                                                : Color(0xff24B9B0),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 3),
                                            child: Text(
                                              "Lifts",
                                              style: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    PathState.accessiblePath ==
                                                            "Lifts"
                                                        ? Colors.white
                                                        : Colors.black,
                                                height: 20 / 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              Container(
                                width: 112,
                                margin: EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                    onPressed: () {
                                      PathState.accessiblePath = "ramp";
                                      PathState.clearforaccessiblepath();
                                      SingletonFunctionController
                                          .building.landmarkdata!
                                          .then((value) {
                                        try {
                                          calculateroute(value.landmarksMap!,
                                              accessibleby: "ramp");
                                        } catch (e) {}
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.greenAccent,
                                        backgroundColor:
                                            PathState.accessiblePath == "ramp"
                                                ? Color(0xff24B9B0)
                                                : Colors.white,
                                        elevation:
                                            0 // Set the text color to black
                                        ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.stairs_rounded,
                                            color: PathState.accessiblePath ==
                                                    "ramp"
                                                ? Colors.white
                                                : Color(0xff24B9B0),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 3),
                                            child: Text(
                                              "Ramp",
                                              style: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    PathState.accessiblePath ==
                                                            "ramp"
                                                        ? Colors.white
                                                        : Colors.black,
                                                height: 20 / 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        )
                      : Container(),
>>>>>>> Stashed changes
                ],
              ),
            ),
          ),
          Visibility(
            visible: PathState.sourceX != 0,
            child: SlidingUpPanel(
                controller: _routeDetailPannelController,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20.0,
                    color: Colors.grey,
                  ),
                ],
<<<<<<< Updated upstream
                minHeight: 163,
                maxHeight: screenHeight * 0.9,
                panel: Semantics(
                  sortKey: const OrdinalSortKey(0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          color: Colors.white,
                        ),
=======
                minHeight: 155,
                maxHeight: screenHeight * 0.8,
                panel: PathState.noPathFound
                    ? Container(
                        margin: EdgeInsets.only(top: 36),
>>>>>>> Stashed changes
                        child: Column(
                          children: [
<<<<<<< Updated upstream
                            Semantics(
                              excludeSemantics: true,
                              child: Row(
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
=======
                            Image.asset("assets/error.png"),
                            Text(
                              "Can't find a way there",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff3f3f46),
                                height: 40 / 14,
>>>>>>> Stashed changes
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    : Semantics(
                        sortKey: const OrdinalSortKey(0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
<<<<<<< Updated upstream
                                  Focus(
                                    autofocus: true,
                                    child: Semantics(
                                      label:
                                          "Your destination is ${distance}m away ",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Semantics(
                                            excludeSemantics: true,
                                            child: Text(
                                              "${time.toInt()} min ",
                                              style: const TextStyle(
                                                color: Color(0xffDC6A01),
                                                fontFamily: "Roboto",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                height: 24 / 18,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Semantics(
                                            excludeSemantics: true,
                                            child: Text(
                                              "(${distance} m)",
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                height: 24 / 18,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Spacer(),
                                          IconButton(
                                              onPressed: () {
                                                multiFloorPath = false;
                                                showMarkers();
                                                _isBuildingPannelOpen = true;
                                                _isRoutePanelOpen = false;
                                                selectedroomMarker.clear();
                                                pathMarkers.clear();

                                                building.selectedLandmarkID =
                                                    null;

                                                PathState =
                                                    pathState.withValues(
                                                        -1,
                                                        -1,
                                                        -1,
                                                        -1,
                                                        -1,
                                                        -1,
                                                        null,
                                                        0);
                                                PathState.path.clear();
                                                PathState.sourcePolyID = "";
                                                PathState.destinationPolyID =
                                                    "";
                                                PathState.sourceBid = "";
                                                PathState.destinationBid = "";
                                                singleroute.clear();
                                                PathState.directions = [];
                                                interBuildingPath.clear();
                                                clearPathVariables();
                                                fitPolygonInScreen(patch.first);
                                              },
                                              icon: Semantics(
                                                label: "Close",
                                                child: Icon(
                                                  Icons.cancel_outlined,
                                                  size: 25,
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Text(
                                  //   "via",
                                  //   style: const TextStyle(
                                  //     fontFamily: "Roboto",
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.w400,
                                  //     color: Color(0xff4a4545),
                                  //     height: 25 / 16,
                                  //   ),
                                  //   textAlign: TextAlign.left,
                                  // ),
                                  // Text(
                                  //   "ETA- ${newTime.hour}:${newTime.minute}",
                                  //   style: const TextStyle(
                                  //     fontFamily: "Roboto",
                                  //     fontSize: 14,
                                  //     fontWeight: FontWeight.w400,
                                  //     color: Color(0xff8d8c8c),
                                  //     height: 20 / 14,
                                  //   ),
                                  //   textAlign: TextAlign.left,
                                  // ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Semantics(
                                        sortKey: const OrdinalSortKey(1),
                                        child: Container(
                                          width: 108,
                                          height: 40,
=======
                                  Semantics(
                                    excludeSemantics: true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 6,
                                          margin: EdgeInsets.only(top: 8),
>>>>>>> Stashed changes
                                          decoration: BoxDecoration(
                                            color: Color(0xffd9d9d9),
                                            borderRadius:
<<<<<<< Updated upstream
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: TextButton(
                                            onPressed: () async {
                                              user.Bid = PathState.sourceBid;
                                              user.floor =
                                                  PathState.sourceFloor;
                                              user.pathobj = PathState;
                                              user.path =
                                                  PathState.singleListPath;
                                              user.isnavigating = true;
                                              user.Cellpath =
                                                  PathState.singleCellListPath;
                                              user
                                                  .moveToStartofPath()
                                                  .then((value) async {
                                                final Uint8List userloc =
                                                    await getImagesFromMarker(
                                                        'assets/userloc0.png',
                                                        80);
                                                final Uint8List userlocdebug =
                                                    await getImagesFromMarker(
                                                        'assets/tealtorch.png',
                                                        35);

                                                setState(() {
                                                  markers.clear();
                                                  List<double> val =
                                                      tools.localtoglobal(
                                                          user.showcoordX
                                                              .toInt(),
                                                          user.showcoordY
                                                              .toInt());

                                                  markers.putIfAbsent(
                                                      user.Bid, () => []);
                                                  markers[user.Bid]?.add(Marker(
                                                    markerId: MarkerId(
                                                        "UserLocation"),
                                                    position:
                                                        LatLng(val[0], val[1]),
                                                    icon: BitmapDescriptor
                                                        .fromBytes(userloc),
                                                    anchor: Offset(0.5, 0.829),
                                                  ));

                                                  val = tools.localtoglobal(
                                                      user.coordX.toInt(),
                                                      user.coordY.toInt());

                                                  markers[user.Bid]?.add(Marker(
                                                    markerId: MarkerId("debug"),
                                                    position:
                                                        LatLng(val[0], val[1]),
                                                    icon: BitmapDescriptor
                                                        .fromBytes(
                                                            userlocdebug),
                                                    anchor: Offset(0.5, 0.829),
                                                  ));
                                                });
                                              });
                                              _isRoutePanelOpen = false;

                                              building.selectedLandmarkID =
                                                  null;

                                              _isnavigationPannelOpen = true;

                                              semanticShouldBeExcluded = false;

                                              StartPDR();
                                              alignMapToPath([
                                                user.lat,
                                                user.lng
                                              ], [
                                                PathState
                                                    .singleCellListPath[
                                                        user.pathobj.index + 1]
                                                    .lat,
                                                PathState
                                                    .singleCellListPath[
                                                        user.pathobj.index + 1]
                                                    .lng
                                              ]);
                                            },
                                            child: !startingNavigation
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .assistant_navigation,
                                                        color: Colors.black,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Start",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    )),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 98,
                                        height: 40,
                                        margin: EdgeInsets.only(left: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            if (_routeDetailPannelController
                                                .isPanelOpen) {
                                              _routeDetailPannelController
                                                  .close();
                                            } else {
                                              _routeDetailPannelController
                                                  .open();
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _routeDetailPannelController
                                                        .isAttached
                                                    ? _routeDetailPannelController
                                                            .isPanelClosed
                                                        ? Icons
                                                            .short_text_outlined
                                                        : Icons.map_sharp
                                                    : Icons.short_text_outlined,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 8),
                                              Semantics(
                                                sortKey:
                                                    const OrdinalSortKey(2),
                                                onDidGainAccessibilityFocus:
                                                    openRoutePannel,
                                                child: Text(
                                                  _routeDetailPannelController
                                                          .isAttached
                                                      ? _routeDetailPannelController
                                                              .isPanelClosed
                                                          ? "Steps"
                                                          : "Map"
                                                      : "Steps",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
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
                            Container(
                              margin:
                                  EdgeInsets.only(left: 17, top: 12, right: 17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Semantics(
                                      excludeSemantics: true,
                                      child: Text(
                                        "Steps",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff000000),
                                          height: 24 / 18,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
=======
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                      ],
>>>>>>> Stashed changes
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    padding: EdgeInsets.only(left: 17, top: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Semantics(
                                              excludeSemantics: true,
                                              child: Text(
                                                "${time.toInt()} min Walk ",
                                                style: const TextStyle(
                                                  color: Color(0xffDC6A01),
                                                  fontFamily: "Roboto",
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  height: 24 / 18,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Semantics(
                                              excludeSemantics: true,
                                              child: Text(
                                                "(${distance} m)",
                                                style: const TextStyle(
                                                  fontFamily: "Roboto",
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  height: 24 / 18,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Spacer(),
                                            IconButton(
                                                onPressed: () {
                                                  showMarkers();
                                                  setState(() {
                                                    _isBuildingPannelOpen =
                                                        true;
                                                    _isRoutePanelOpen = false;
                                                  });
                                                  widget.directLandID = "";
                                                  selectedroomMarker.clear();
                                                  pathMarkers.clear();

                                                  SingletonFunctionController
                                                          .building
                                                          .selectedLandmarkID =
                                                      null;

                                                  PathState =
                                                      pathState.withValues(
                                                          -1,
                                                          -1,
                                                          -1,
                                                          -1,
                                                          -1,
                                                          -1,
                                                          null,
                                                          0);
                                                  PathState.path.clear();
                                                  PathState.sourcePolyID = "";
                                                  PathState.destinationPolyID =
                                                      "";
                                                  PathState.sourceBid = "";
                                                  PathState.destinationBid = "";
                                                  singleroute.clear();
                                                  //realWorldPath.clear();
                                                  PathState.directions = [];
                                                  interBuildingPath.clear();
                                                  //  if(user.isnavigating==false){
                                                  clearPathVariables();
                                                  //}
                                                  fitPolygonInScreen(
                                                      patch.first);
                                                  exitNavigation();
                                                  setState(() {
                                                    onStart = false;
                                                    startingNavigation = false;
                                                  });
                                                },
                                                icon: Semantics(
                                                  label: "Close Navigation",
                                                  child: Icon(
                                                    Icons.cancel_outlined,
                                                    size: 25,
                                                  ),
                                                ))
                                          ],
                                        ),
                                        // Text(
                                        //   "via",
                                        //   style: const TextStyle(
                                        //     fontFamily: "Roboto",
                                        //     fontSize: 16,
                                        //     fontWeight: FontWeight.w400,
                                        //     color: Color(0xff4a4545),
                                        //     height: 25 / 16,
                                        //   ),
                                        //   textAlign: TextAlign.left,
                                        // ),
                                        // Text(
                                        //   "ETA- ${newTime.hour}:${newTime.minute}",
                                        //   style: const TextStyle(
                                        //     fontFamily: "Roboto",
                                        //     fontSize: 14,
                                        //     fontWeight: FontWeight.w400,
                                        //     color: Color(0xff8d8c8c),
                                        //     height: 20 / 14,
                                        //   ),
                                        //   textAlign: TextAlign.left,
                                        // ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            Focus(
                                              autofocus: true,
                                              child: Semantics(
                                                sortKey:
                                                    const OrdinalSortKey(0),
                                                child: Container(
                                                  width: 108,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff24B9B0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      if (startingNavigation) {
                                                        tools.setBuildingAngle(
                                                            SingletonFunctionController
                                                                .building
                                                                .patchData[PathState
                                                                    .sourceBid]!
                                                                .patchData!
                                                                .buildingAngle!);
                                                        if (PathState.sourceX ==
                                                                PathState
                                                                    .destinationX &&
                                                            PathState.sourceY ==
                                                                PathState
                                                                    .destinationY) {
                                                          //HelperClass.showToast("Source and Destination can not be same");
                                                          setState(() {
                                                            _isRoutePanelOpen =
                                                                false;
                                                          });
                                                          closeNavigation();
                                                          return;
                                                        }
                                                        setState(() {
                                                          circles.clear();
                                                          _markers.clear();
                                                          markerSldShown =
                                                              false;
                                                        });
                                                        user.onConnection =
                                                            false;
                                                        PathState.didPathStart =
                                                            true;

                                                        UserState
                                                            .cols = SingletonFunctionController
                                                                .building
                                                                .floorDimenssion[
                                                            PathState
                                                                .sourceBid]![PathState
                                                            .sourceFloor]![0];
                                                        UserState
                                                            .rows = SingletonFunctionController
                                                                .building
                                                                .floorDimenssion[
                                                            PathState
                                                                .destinationBid]![PathState
                                                            .destinationFloor]![1];
                                                        UserState.lngCode =
                                                            _currentLocale;
                                                        UserState.reroute =
                                                            reroute;
                                                        UserState.closeNavigation = closeNavigation;
                                                        UserState
                                                                .AlignMapToPath =
                                                            alignMapToPath;
                                                        UserState.startOnPath =
                                                            startOnPath;
                                                        UserState.speak = speak;
                                                        UserState.paintMarker =
                                                            paintMarker;
                                                        UserState.createCircle =
                                                            updateCircle;

                                                        //detected=false;
                                                        //user.SingletonFunctionController.building = SingletonFunctionController.building;
                                                        wsocket.message["path"]
                                                                ["source"] =
                                                            PathState
                                                                .sourceName;
                                                        wsocket.message["path"][
                                                                "destination"] =
                                                            PathState
                                                                .destinationName;
                                                        // user.ListofPaths = PathState.listofPaths;
                                                        // user.patchData = SingletonFunctionController.building.patchData;
                                                        // user.buildingNumber = PathState.listofPaths.length-1;
                                                        buildingAllApi
                                                                .selectedID =
                                                            PathState.sourceBid;
                                                        buildingAllApi
                                                                .selectedBuildingID =
                                                            PathState.sourceBid;
                                                        UserState
                                                            .cols = SingletonFunctionController
                                                                .building
                                                                .floorDimenssion[
                                                            PathState
                                                                .sourceBid]![PathState
                                                            .sourceFloor]![0];
                                                        UserState
                                                            .rows = SingletonFunctionController
                                                                .building
                                                                .floorDimenssion[
                                                            PathState
                                                                .sourceBid]![PathState
                                                            .sourceFloor]![1];
                                                        user.Bid =
                                                            PathState.sourceBid;
                                                        user.coordX =
                                                            PathState.sourceX;
                                                        user.coordY =
                                                            PathState.sourceY;
                                                        user.temporaryExit =
                                                            false;
                                                        UserState.reroute =
                                                            reroute;
                                                        UserState
                                                                .closeNavigation =
                                                            closeNavigation;
                                                        UserState
                                                                .AlignMapToPath =
                                                            alignMapToPath;
                                                        UserState.startOnPath =
                                                            startOnPath;
                                                        UserState.speak = speak;
                                                        UserState.paintMarker =
                                                            paintMarker;
                                                        UserState.createCircle =
                                                            updateCircle;
                                                        UserState
                                                                .changeBuilding =
                                                            changeBuilding;
                                                        //user.realWorldCoordinates = PathState.realWorldCoordinates;
                                                        user.floor = PathState
                                                            .sourceFloor;
                                                        user.pathobj =
                                                            PathState;
                                                        user.path = PathState
                                                            .singleListPath;
                                                        user.isnavigating =
                                                            true;
                                                        user.Cellpath = PathState
                                                            .singleCellListPath;
                                                        PathState
                                                            .singleCellListPath
                                                            .forEach(
                                                                (element) {});
                                                        user
                                                            .moveToStartofPath()
                                                            .then(
                                                                (value) async {
                                                          setState(() {
                                                            markers.clear();
                                                            List<double> val = tools.localtoglobal(
                                                                user.showcoordX
                                                                    .toInt(),
                                                                user.showcoordY
                                                                    .toInt(),
                                                                SingletonFunctionController
                                                                        .building
                                                                        .patchData[
                                                                    PathState
                                                                        .sourceBid]);

                                                            markers.putIfAbsent(
                                                                user.Bid,
                                                                () => []);
                                                            markers[user.Bid]
                                                                ?.add(Marker(
                                                              markerId: MarkerId(
                                                                  "UserLocation"),
                                                              position: LatLng(
                                                                  val[0],
                                                                  val[1]),
                                                              icon: BitmapDescriptor
                                                                  .fromBytes(
                                                                      userloc),
                                                              anchor: Offset(
                                                                  0.5, 0.829),
                                                            ));

                                                            val = tools.localtoglobal(
                                                                user.coordX
                                                                    .toInt(),
                                                                user.coordY
                                                                    .toInt(),
                                                                SingletonFunctionController
                                                                        .building
                                                                        .patchData[
                                                                    PathState
                                                                        .sourceBid]);

                                                            markers[user.Bid]
                                                                ?.add(Marker(
                                                              markerId:
                                                                  MarkerId(
                                                                      "debug"),
                                                              position: LatLng(
                                                                  val[0],
                                                                  val[1]),
                                                              icon: BitmapDescriptor
                                                                  .fromBytes(
                                                                      userlocdebug),
                                                              anchor: Offset(
                                                                  0.5, 0.829),
                                                            ));
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
                                                          alignMapToPath([
                                                            user.lat,
                                                            user.lng
                                                          ], [
                                                            PathState
                                                                .singleCellListPath[user
                                                                        .pathobj
                                                                        .index +
                                                                    1]
                                                                .lat,
                                                            PathState
                                                                .singleCellListPath[user
                                                                        .pathobj
                                                                        .index +
                                                                    1]
                                                                .lng
                                                          ]);
                                                        });
                                                        _isRoutePanelOpen =
                                                            false;

                                                        SingletonFunctionController
                                                                .building
                                                                .selectedLandmarkID =
                                                            null;

                                                        _isnavigationPannelOpen =
                                                            true;

                                                        semanticShouldBeExcluded =
                                                            false;

                                                        StartPDR();

                                                        if (SingletonFunctionController
                                                                    .building
                                                                    .floor[
                                                                PathState
                                                                    .sourceBid] !=
                                                            PathState
                                                                .sourceFloor) {
                                                          SingletonFunctionController
                                                                      .building
                                                                      .floor[
                                                                  PathState
                                                                      .sourceBid] =
                                                              PathState
                                                                  .sourceFloor;
                                                          createRooms(
                                                              SingletonFunctionController
                                                                      .building
                                                                      .polylinedatamap[
                                                                  PathState
                                                                      .sourceBid]!,
                                                              PathState
                                                                  .sourceFloor);
                                                          SingletonFunctionController
                                                              .building
                                                              .landmarkdata!
                                                              .then((value) {
                                                            createMarkers(
                                                                value,
                                                                PathState
                                                                    .sourceFloor,
                                                                bid: PathState
                                                                    .sourceBid);
                                                          });
                                                        }

                                                        Future.delayed(Duration(
                                                                seconds: 2))
                                                            .then((onValue) {
                                                          setState(() {
                                                            onStart = true;
                                                          });
                                                        });
                                                      }
                                                    },
                                                    child: startingNavigation
                                                        ? Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .assistant_navigation,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                '${LocaleData.start.getString(context)}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(
                                                            width: 24,
                                                            height: 24,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 98,
                                              height: 40,
                                              margin: EdgeInsets.only(left: 12),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                              child: TextButton(
                                                onPressed: () {
                                                  if (_routeDetailPannelController
                                                      .isPanelOpen) {
                                                    _routeDetailPannelController
                                                        .close();
                                                  } else {
                                                    _routeDetailPannelController
                                                        .open();
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _routeDetailPannelController
                                                              .isAttached
                                                          ? _routeDetailPannelController
                                                                  .isPanelClosed
                                                              ? Icons
                                                                  .short_text_outlined
                                                              : Icons.map_sharp
                                                          : Icons
                                                              .short_text_outlined,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Semantics(
                                                      sortKey:
                                                          const OrdinalSortKey(
                                                              2),
                                                      onDidGainAccessibilityFocus:
                                                          openRoutePannel,
                                                      child: Text(
                                                        _routeDetailPannelController
                                                                .isAttached
                                                            ? _routeDetailPannelController
                                                                    .isPanelClosed
                                                                ? "${LocaleData.steps.getString(context)}"
                                                                : "${LocaleData.maps.getString(context)}"
                                                            : "${LocaleData.steps.getString(context)}",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
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
                                  Container(
<<<<<<< Updated upstream
                                    height: screenHeight - 300,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Semantics(
                                            excludeSemantics: false,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 25,
                                                  margin:
                                                      EdgeInsets.only(right: 8),
                                                  child: SvgPicture.asset(
                                                      "assets/StartpointVector.svg"),
                                                ),
                                                Semantics(
                                                  label:
                                                      "Steps preview,    You are heading from",
                                                  child: Text(
                                                    "${PathState.sourceName}",
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff0e0d0d),
                                                      height: 25 / 16,
                                                    ),
                                                    textAlign: TextAlign.left,
=======
                                    margin: EdgeInsets.only(
                                        left: 17, top: 12, right: 17),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Semantics(
                                            excludeSemantics: true,
                                            child: Text(
                                              "Steps",
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff000000),
                                                height: 24 / 18,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 22,
                                        ),
                                        Container(
                                          height: screenHeight - 300,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Semantics(
                                                  excludeSemantics: false,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 25,
                                                        margin: EdgeInsets.only(
                                                            right: 8),
                                                        child: SvgPicture.asset(
                                                            "assets/StartpointVector.svg"),
                                                      ),
                                                      Semantics(
                                                        label:
                                                            "Steps preview,    You are heading from",
                                                        child: Text(
                                                          "${PathState.sourceName}",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "Roboto",
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xff0e0d0d),
                                                            height: 25 / 16,
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                      )
                                                    ],
>>>>>>> Stashed changes
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                  width: screenHeight,
                                                  height: 1,
                                                  color: Color(0xffEBEBEB),
                                                ),
                                                Column(
                                                  children: directionWidgets,
                                                ),
                                                SizedBox(
                                                  height: 22,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 25,
                                                      margin: EdgeInsets.only(
                                                          right: 8),
                                                      child: Icon(
                                                        Icons.pin_drop_sharp,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    Semantics(
                                                      label:
                                                          "Your are heading towards ",
                                                      child: Text(
                                                        angle != null
                                                            ? "${PathState.destinationName} ${LocaleData.willbe.getString(context)}  ${LocaleData.getProperty(tools.angleToClocks3(angle, context), context)}"
                                                            : PathState
                                                                .destinationName,
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xff0e0d0d),
                                                          height: 25 / 16,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                  width: screenHeight,
                                                  height: 1,
                                                  color: Color(0xffEBEBEB),
                                                ),
                                              ],
                                            ),
                                          ),
<<<<<<< Updated upstream
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                            width: screenHeight,
                                            height: 1,
                                            color: Color(0xffEBEBEB),
                                          ),
                                          Column(
                                            children: directionWidgets,
                                          ),
                                          SizedBox(
                                            height: 22,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 25,
                                                margin:
                                                    EdgeInsets.only(right: 8),
                                                child: Icon(
                                                  Icons.pin_drop_sharp,
                                                  size: 24,
                                                ),
                                              ),
                                              Semantics(
                                                label:
                                                    "Your are heading towards ",
                                                child: Text(
                                                  angle != null
                                                      ? "${PathState.destinationName} will be ${tools.angleToClocks3(angle)}"
                                                      : PathState
                                                          .destinationName,
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff0e0d0d),
                                                    height: 25 / 16,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                            width: screenHeight,
                                            height: 1,
                                            color: Color(0xffEBEBEB),
                                          ),
                                        ],
                                      ),
=======
                                        )
                                      ],
>>>>>>> Stashed changes
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
          ),
        ],
      ),
    );
  }

  void alignMapToPath(List<double> A, List<double> B) {
    mapState.tilt = 50;

<<<<<<< Updated upstream
    mapState.bearing = tools.calculateBearing(A, B);
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: mapState.target,
          zoom: mapState.zoom,
          bearing: mapState.bearing!,
          tilt: mapState.tilt),
    ));
=======
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
        child: Semantics(
          excludeSemantics: false,
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
                          "com.iwayplus.navigation");

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

  void _submitFeedback() {
    String feedbackMessage = 'Rating: $_rating\n';
    if (_feedback.isNotEmpty) {
      feedbackMessage += 'Feedback: $_feedback';
    }

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(feedbackMessage),
    //     duration: Duration(seconds: 3),
    //   ),
    // );
    _feedbackController.close();
    _feedbackTextController.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => VenueSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void alignMapToPath(List<double> A, List<double> B) async {
    print("enteredddd");
    print(onStart);
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    mapState.tilt = 33.5;
    List<double> val = tools.localtoglobal(
        user.showcoordX.toInt(),
        user.showcoordY.toInt(),
        SingletonFunctionController.building.patchData[user.Bid]);
    mapState.target = LatLng(val[0], val[1]);
    mapState.bearing = tools.calculateBearing(A, B);
    ScreenCoordinate screenCenter =
        await _googleMapController.getScreenCoordinate(mapState.target);

    // Adjust the y-coordinate to shift the camera upwards (moving the target down)
    int newX = screenCenter.x - 10;
    int newY = 0;
    if (Platform.isAndroid) {
      newY = screenCenter.y - ((screenHeight * 0.58)).toInt();
    } else {
      newY = screenCenter.y - ((screenHeight * 0.08) * pixelRatio).toInt();
    } // Adjust 300 as needed for how far you want the user at the bottom

    // Convert the new screen coordinate back to LatLng
    LatLng newCameraTarget = await _googleMapController
        .getLatLng(ScreenCoordinate(x: newX, y: newY));
    setState(() {
      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: (onStart == false) ? mapState.target : mapState.target,
            zoom: mapState.zoom,
            bearing: mapState.bearing!,
            tilt: mapState.tilt),
      ));
    });
>>>>>>> Stashed changes
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
    setState(() {
      shouldStepOpen = false;
    });
  }

  bool isLift = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

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

<<<<<<< Updated upstream
=======
  // void _addCircle(double l1,double l2){
  //   _updateCircle();
  // }
  bool onStart = false;
>>>>>>> Stashed changes
  Widget navigationPannel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double time = 0;
    double distance = 0;
    DateTime currentTime = DateTime.now();
    if (PathState.singleCellListPath.isNotEmpty) {
      distance = tools.PathDistance(PathState.singleCellListPath);
      time = distance / 120;
      time = time.ceil().toDouble();

      distance = distance * 0.3048;
      distance = double.parse(distance.toStringAsFixed(1));
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));

    //implement the turn functionality.
    if (user.isnavigating && user.pathobj.numCols![user.Bid] != null) {
      int col = user.pathobj.numCols![user.Bid]![user.floor]!;

      if (MotionModel.reached(user, col) == false) {
        List<int> a = [user.showcoordX, user.showcoordY];
        List<int> tval = tools.eightcelltransition(user.theta);
        //print(tval);
        List<int> b = [user.showcoordX + tval[0], user.showcoordY + tval[1]];

<<<<<<< Updated upstream
        int index =
            user.path.indexOf((user.showcoordY * col) + user.showcoordX);

        int node = user.path[index + 1];
=======
        if (MotionModel.reached(user, col) == false &&
            user.Bid == user.Cellpath[user.pathobj.index + 1].bid) {
          List<int> a = [user.showcoordX, user.showcoordY];
          List<int> tval = tools.eightcelltransition(user.theta);
          //
          List<int> b = [user.showcoordX + tval[0], user.showcoordY + tval[1]];

          int index =
              user.path.indexOf((user.showcoordY * col) + user.showcoordX);
>>>>>>> Stashed changes

        List<int> c = [node % col, node ~/ col];
        int val = tools.calculateAngleSecond(a, b, c).toInt();
        //print("val $val");

<<<<<<< Updated upstream
        // print("user corrds");
        // print("${user.showcoordX}+" "+ ${user.showcoordY}");

        // print("pointss matchedddd ${getPoints.contains(
        //     [user.showcoordX, user.showcoordY])}");
        for (int i = 0; i < getPoints.length; i++) {
          // print("---length  = ${getPoints.length}");
          // print("--- point  = ${getPoints[i]}");
          // print("---- usercoord  = ${user.showcoordX} , ${user.showcoordY}");
          // print("--- val  = $val");
          // print("--- isPDRStop  = $isPdrStop");

          //print("turn corrds");

          //print("${getPoints[i][0]}, ${getPoints[i][1]}");
          if (isPdrStop && val == 0) {
            //print("points unmatchedddd");

            Future.delayed(Duration(milliseconds: 1800))
                .then((value) => {StartPDR()});

            setState(() {
              isPdrStop = false;
            });
=======
          List<int> c = [node % col, node ~/ col];
          int val = tools.calculateAngleSecond(a, b, c).toInt();
          //

          //
          //

          //
          for (int i = 0; i < getPoints.length; i++) {
            //
            //
            //
            //
            //

            //

            //
            if (isPdrStop && val == 0) {
              //

              Future.delayed(Duration(milliseconds: 1500)).then((value) => {
                    StartPDR(),
                  });
>>>>>>> Stashed changes

            break;
          }
          if (getPoints[i][0] == user.showcoordX &&
              getPoints[i][1] == user.showcoordY) {
            //print("points matchedddddddd");

<<<<<<< Updated upstream
            StopPDR();
            getPoints.removeAt(i);
            break;
=======
              break;
            }
            if (getPoints[i][0] == user.showcoordX &&
                getPoints[i][1] == user.showcoordY) {
              //

              StopPDR();
              getPoints.removeAt(i);
              break;
            }
>>>>>>> Stashed changes
          }
        }
      }
    }

    return Visibility(
        visible: _isnavigationPannelOpen,
        child: Stack(
          children: [
            SlidingUpPanel(
              controller: _panelController,
              isDraggable: false,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
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
                            child: Focus(
                              autofocus: true,
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
                          ),
<<<<<<< Updated upstream
                          Container(
                            height: 40,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Color(0xffDF3535),
                              borderRadius: BorderRadius.circular(20.0),
=======
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
                                    setState(() {
                                      StopPDR();
                                      onStart = false;
                                      startingNavigation = true;
                                      PathState.sourceX = user.coordX;
                                      PathState.sourceY = user.coordY;
                                      PathState.sourceFloor = user.floor;
                                      PathState.sourceBid = user.Bid;
                                      PathState.sourceLat = user.lat;
                                      PathState.sourceLng = user.lng;
                                      PathState.sourceName =
                                          "Your current location";

                                      user.temporaryExit = true;
                                      user.isnavigating = false;
                                      _isRoutePanelOpen = true;
                                      _isnavigationPannelOpen = false;

                                      if (pathMarkers[user.Bid] != null) {
                                        setCameraPosition(
                                            pathMarkers[user.Bid]![
                                                SingletonFunctionController
                                                    .building
                                                    .floor[user.Bid]]!);
                                      }
                                    });
                                  },
                                  child: Text(
                                    "${LocaleData.exit.getString(context)}",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffFFFFFF),
                                      height: 20 / 14,
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
>>>>>>> Stashed changes
                            ),
                            child: TextButton(
                                onPressed: () {
                                  _isnavigationPannelOpen = false;
                                  user.reset();
                                  PathState = pathState.withValues(
                                      -1, -1, -1, -1, -1, -1, null, 0);
                                  selectedroomMarker.clear();
                                  pathMarkers.clear();
                                  PathState.path.clear();
                                  PathState.sourcePolyID = "";
                                  PathState.destinationPolyID = "";
                                  singleroute.clear();
                                  fitPolygonInScreen(patch.first);
                                  setState(() {
                                    if (markers.length > 0) {
                                      List<double> lvalue = tools.localtoglobal(
                                          user.showcoordX.toInt(),
                                          user.showcoordY.toInt());
                                      markers[user.Bid]?[0] = customMarker.move(
                                          LatLng(lvalue[0], lvalue[1]),
                                          markers[user.Bid]![0]);
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
            )
          ],
        ));
  }

<<<<<<< Updated upstream
=======
  void exitNavigation() {
    setState(() {
      if (PathState.didPathStart) {
        showFeedback = true;
        Future.delayed(Duration(seconds: 5));
        _feedbackController.open();
        _feedbackTextController.clear();
      }
    });
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
    fitPolygonInScreen(patch.first);
    setState(() {
      if (markers.length > 0) {
        List<double> lvalue = tools.localtoglobal(
            user.showcoordX.toInt(),
            user.showcoordY.toInt(),
            SingletonFunctionController.building.patchData[user.Bid]);
        markers[user.Bid]?[0] = customMarker.move(
            LatLng(lvalue[0], lvalue[1]), markers[user.Bid]![0]);
      }
    });
  }

>>>>>>> Stashed changes
  bool rerouting = false;
  Widget reroutePannel() {
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
                                onPressed: () async {
                                  if (!rerouting) {
                                    setState(() {
                                      rerouting = true;
                                    });
                                    clearPathVariables();
                                    PathState.clear();
                                    PathState.sourceX = user.coordX;
                                    PathState.sourceY = user.coordY;
                                    user.showcoordX = user.coordX;
                                    user.showcoordY = user.coordY;
                                    PathState.sourceFloor = user.floor;
                                    PathState.sourcePolyID = user.key;
                                    PathState.sourceName =
                                        "Your current location";
                                    building.landmarkdata!.then((value) async {
                                      await calculateroute(value.landmarksMap!)
                                          .then((value) {
                                        user.pathobj = PathState;
                                        user.path = PathState.path.values
                                            .expand((list) => list)
                                            .toList();
                                        user.Cellpath =
                                            PathState.singleCellListPath;
                                        user.pathobj.index = 0;
                                        user.isnavigating = true;
                                        user.moveToStartofPath().then((value) {
                                          setState(() {
                                            if (markers.length > 0) {
                                              markers[user.Bid]?[
                                                      0] =
                                                  customMarker.move(
                                                      LatLng(
                                                          tools.localtoglobal(
                                                              user.showcoordX
                                                                  .toInt(),
                                                              user.showcoordY
                                                                  .toInt())[0],
                                                          tools.localtoglobal(
                                                              user.showcoordX
                                                                  .toInt(),
                                                              user.showcoordY
                                                                  .toInt())[1]),
                                                      markers[user.Bid]![0]);
                                            }
                                          });
                                        });
                                        _isRoutePanelOpen = false;
                                        building.selectedLandmarkID = null;
                                        _isnavigationPannelOpen = true;
                                        _isreroutePannelOpen = false;
                                        int numCols = building.floorDimenssion[
                                            PathState
                                                .sourceBid]![PathState
                                            .sourceFloor]![0]; //floor length
                                        double angle =
                                            tools.calculateAngleBWUserandPath(
                                                user,
                                                PathState.path[
                                                    PathState.sourceFloor]![1],
                                                numCols);
                                        if (angle != 0) {
                                          speak("Turn " +
                                              tools.angleToClocks(angle));
                                        } else {}

                                        mapState.tilt = 50;

                                        mapState.bearing =
                                            tools.calculateBearing([
                                          user.lat,
                                          user.lng
                                        ], [
                                          PathState
                                              .singleCellListPath[
                                                  user.pathobj.index + 1]
                                              .lat,
                                          PathState
                                              .singleCellListPath[
                                                  user.pathobj.index + 1]
                                              .lng
                                        ]);
                                        _googleMapController.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: mapState.target,
                                              zoom: mapState.zoom,
                                              bearing: mapState.bearing!,
                                              tilt: mapState.tilt),
                                        ));
                                      });
                                    });
                                    rerouting = false;
                                  }
                                },
<<<<<<< Updated upstream
                                child: !rerouting
                                    ? Text(
                                        "Reroute",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff000000),
                                          height: 20 / 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    : Container(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
=======
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                                                        print(
                                                            "Himanshuchecker");
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                                      print("tags");
                                      print(optionsTags);
=======
>>>>>>> Stashed changes
                                    }
                                    return ChipsChoice<String>.multiple(
                                      value: optionsTags,
                                      onChanged: (val) {
<<<<<<< Updated upstream
                                        print(
                                            "Filter change${val}${value.values}");
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                                        print(
                                            "Filter change${val}${value.values}");
=======
>>>>>>> Stashed changes
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

  Widget ExploreModePannel() {
    List<Widget> Exwidgets = [];
    for (int i = 0; i < getallnearestInfo.length; i++) {
      Exwidgets.add(
          ExploreModeWidget(getallnearestInfo[i], finalDirections[i]));
    }

    return Visibility(
        visible: _isExploreModePannelOpen,
        child: SlidingUpPanel(
          maxHeight: 90 + 8 + (getallnearestInfo.length * 100),
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
                          isLiveLocalizing = false;
                          HelperClass.showToast("Explore mode is disabled");
                          _exploreModeTimer!.cancel();
                          _isExploreModePannelOpen = false;
                          _isBuildingPannelOpen = true;
                          lastBeaconValue = "";
                        },
                        icon: Icon(Icons.close))
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  children: Exwidgets,
                )
              ],
            ),
          ),
        ));
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
        visible: _isBuildingPannelOpen,
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
            minHeight: 90,
            snapPoint:
                element.workingDays != null && element.workingDays!.length > 0
                    ? 220 / screenHeight
                    : 175 / screenHeight,
            panel: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.only(left: 17, top: 12),
<<<<<<< Updated upstream
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${nearestLandInfomation.name}, Floor ${nearestLandInfomation.floor}",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff292929),
                                height: 25 / 18,
                              ),
                              textAlign: TextAlign.left,
                            )
                          ],
=======
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    if (user.floor == building.floor[buildingAllApi.getStoredString()]) {
=======
    Set<Marker> combinedMarkers = Set();

    if (user.floor ==
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()]) {
>>>>>>> Stashed changes
      if (_isLandmarkPanelOpen) {
        Set<Marker> marker = Set();

        selectedroomMarker.forEach((key, value) {
          marker = marker.union(value);
        });

        // print(Set<Marker>.of(markers[user.Bid]!));
        return (marker.union(Set<Marker>.of(markers[user.Bid] ?? [])));
      } else {
        return pathMarkers[building.floor[buildingAllApi.getStoredString()]] !=
                null
            ? (pathMarkers[building.floor[buildingAllApi.getStoredString()]]!
                    .union(Set<Marker>.of(markers[user.Bid] ?? [])))
                .union(Markers)
            : (Set<Marker>.of(markers[user.Bid] ?? [])).union(Markers);
      }
    } else {
      if (_isLandmarkPanelOpen) {
        Set<Marker> marker = Set();
        selectedroomMarker.forEach((key, value) {
          marker = marker.union(value);
        });
        return marker.union(Markers);
      } else {
        return pathMarkers[building.floor[buildingAllApi.getStoredString()]] !=
                null
            ? (pathMarkers[building.floor[buildingAllApi.getStoredString()]]!)
                .union(Markers)
            : Markers;
      }
    }
<<<<<<< Updated upstream
=======

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

    // Always union the general Markers set at the end
    if (SingletonFunctionController.building.floor[user.Bid] == user.floor) {
      markers.forEach((key, value) {
        combinedMarkers = combinedMarkers.union(Set<Marker>.of(value));
      });
    }

    return combinedMarkers;
>>>>>>> Stashed changes
  }

  Set<Polygon> getCombinedPolygons() {
    Set<Polygon> polygons = Set();
    closedpolygons.forEach((key, value) {
      polygons = polygons.union(value);
    });
    return polygons;
  }

  Set<gmap.Polyline> getCombinedPolylines() {
    Set<gmap.Polyline> poly = Set();
    polylines.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });
    interBuildingPath.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });
<<<<<<< Updated upstream
=======

    // Conditional logic to add additional polylines

    buildingAllApi.allBuildingID.forEach((key, value) {
      if (singleroute[key] != null &&
          singleroute[key]![SingletonFunctionController.building.floor[key]] !=
              null) {
        poly = poly.union(singleroute[key]![
            SingletonFunctionController.building.floor[key]]!);
      }
    });

>>>>>>> Stashed changes
    return poly;
  }

  void _updateMarkers(double zoom) {
<<<<<<< Updated upstream
    print(zoom);
    if (building.updateMarkers) {
      Set<Marker> updatedMarkers = Set();
      setState(() {
        Markers.forEach((marker) {
          List<String> words = marker.markerId.value.split(' ');
          if (marker.markerId.value.contains("Room")) {
            Marker _marker = customMarker.visibility(zoom > 20.5, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Rest")) {
            Marker _marker = customMarker.visibility(zoom > 19, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Entry")) {
            Marker _marker = customMarker.visibility(
                (zoom > 18.5 && zoom < 19) || zoom > 20.3, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Building")) {
            Marker _marker = customMarker.visibility(zoom < 16.0, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Lift")) {
            Marker _marker = customMarker.visibility(zoom > 19, marker);
            updatedMarkers.add(_marker);
          }
          if (building.ignoredMarker.contains(words[1])) {
            if (marker.markerId.value.contains("Door")) {
              Marker _marker = customMarker.visibility(true, marker);
              print(_marker);
              updatedMarkers.add(_marker);
            }
=======
    if (SingletonFunctionController.building.updateMarkers) {
      Set<Marker> updatedMarkers = Set();
      if (user.isnavigating) {
        setState(() {
          Markers.forEach((marker) {
            List<String> words = marker.markerId.value.split(' ');

>>>>>>> Stashed changes
            if (marker.markerId.value.contains("Room")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
<<<<<<< Updated upstream
          }
        });
        Markers = updatedMarkers;
      });
=======
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
              Marker _marker = customMarker.visibility(zoom > 19, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Room")) {
              Marker _marker = customMarker.visibility(zoom > 20.5, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Rest")) {
              Marker _marker = customMarker.visibility(zoom > 19, marker);
              updatedMarkers.add(_marker);
            } else if (marker.markerId.value.contains("Entry")) {
              Marker _marker = customMarker.visibility(
                  (zoom > 18.5 && zoom < 19) || zoom > 20.3, marker);
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
>>>>>>> Stashed changes
    }
  }

  void hideMarkers() {
    building.updateMarkers = false;
    Set<Marker> updatedMarkers = Set();
    Markers.forEach((marker) {
      Marker _marker = customMarker.visibility(false, marker);
      updatedMarkers.add(_marker);
    });
    Markers = updatedMarkers;
  }

  void showMarkers() {
    building.ignoredMarker.clear();
    building.updateMarkers = true;
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

  void closeNavigation() {
<<<<<<< Updated upstream
=======
    String destname = PathState.destinationName;
    //String destPolyyy=PathState.destinationPolyID;
    destiName = destname;

    List<int> tv = tools.eightcelltransition(user.theta);
    double angle = tools.calculateAngle2(
        [user.showcoordX, user.showcoordY],
        [user.showcoordX + tv[0], user.showcoordY + tv[1]],
        [PathState.destinationX, PathState.destinationY]);
    String direction = tools.angleToClocks3(angle, context);

    flutterTts.pause().then((value) {
      speak(
          user.convertTolng("You have reached ${destname}. It is ${direction}",
              "", 0.0, context, angle, "", "",
              destname: destname),
          _currentLocale);
    });
    clearPathVariables();
>>>>>>> Stashed changes
    StopPDR();
    _isnavigationPannelOpen = false;
    user.reset();
    PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
    selectedroomMarker.clear();
    pathMarkers.clear();
    PathState.path.clear();
    PathState.sourcePolyID = "";
    PathState.destinationPolyID = "";
    singleroute.clear();
    fitPolygonInScreen(patch.first);
    setState(() {
      focusturnArrow.clear();
    });

    // setState(() {
    if (markers.length > 0) {
<<<<<<< Updated upstream
      List<double> lvalue =
          tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt());
=======
      List<double> lvalue = tools.localtoglobal(
          user.showcoordX.toInt(),
          user.showcoordY.toInt(),
          SingletonFunctionController.building.patchData[user.Bid]);
>>>>>>> Stashed changes
      markers[user.Bid]?[0] = customMarker.move(
          LatLng(lvalue[0], lvalue[1]), markers[user.Bid]![0]);
    }
    // });
<<<<<<< Updated upstream
  }

  void onLandmarkVenueClicked(String ID,
      {bool DirectlyStartNavigation = false}) {
    setState(() {
      if (building.selectedLandmarkID != ID) {
        building.landmarkdata!.then((value) {
          _isBuildingPannelOpen = false;
          building.floor[value.landmarksMap![ID]!.buildingID!] =
              value.landmarksMap![ID]!.floor!;
          createRooms(
              building.polylinedatamap[value.landmarksMap![ID]!.buildingID]!,
              building.floor[value.landmarksMap![ID]!.buildingID!]!);
          createMarkers(
              value, building.floor[value.landmarksMap![ID]!.buildingID!]!);
          building.selectedLandmarkID = ID;
          singleroute.clear();
          _isRoutePanelOpen = DirectlyStartNavigation;
          _isLandmarkPanelOpen = !DirectlyStartNavigation;
          List<double> pvalues = tools.localtoglobal(
              value.landmarksMap![ID]!.coordinateX!,
              value.landmarksMap![ID]!.coordinateY!,
              patchData:
                  building.patchData[value.landmarksMap![ID]!.buildingID]);
          LatLng point = LatLng(pvalues[0], pvalues[1]);
          _googleMapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              point,
              22,
            ),
          );
          addselectedMarker(point);
        });
=======
    showFeedback = true;
    Future.delayed(Duration(seconds: 5));
    _feedbackController.open();
  }

  void onLandmarkVenueClicked(String ID,
      {bool DirectlyStartNavigation = false}) async {
    final snapshot = await SingletonFunctionController.building.landmarkdata;
    SingletonFunctionController.building.selectedLandmarkID = ID;

    _isBuildingPannelOpen = false;

    if (!DirectlyStartNavigation) {
      if (snapshot!.landmarksMap![ID]!.floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            SingletonFunctionController
                .building
                .polylinedatamap[snapshot!.landmarksMap![ID]!.buildingID!]!
                .polyline!
                .floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(snapshot!.landmarksMap![ID]!.floor!),
            SingletonFunctionController
                .building
                .polylinedatamap[snapshot!.landmarksMap![ID]!.buildingID!]!
                .polyline!
                .floors!);

        for (int i = 0; i < prevFloorLifts.length; i++) {}

        for (int i = 0; i < currFloorLifts.length; i++) {}
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
>>>>>>> Stashed changes
      }
    });

<<<<<<< Updated upstream
    if (DirectlyStartNavigation) {}
=======
      List<int> value = [
        snapshot!.landmarksMap![ID]!.coordinateX!,
        snapshot!.landmarksMap![ID]!.coordinateY!
      ];
      List<double> coords = tools.localtoglobal(
          value[0],
          value[1],
          SingletonFunctionController
              .building.patchData[snapshot!.landmarksMap![ID]!.buildingID]);
      int floor = snapshot!.landmarksMap![ID]!.floor!;

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
                element.id == snapshot!.landmarksMap![ID]!.properties!.polyId)
            .nodes;
        List<LatLng> corners = [];
        for (var element in nodes!) {
          List<double> value = tools.localtoglobal(
              element.coordx!,
              element.coordy!,
              SingletonFunctionController
                  .building.patchData[snapshot.landmarksMap![ID]!.buildingID]);
          corners.add(LatLng(value[0], value[1]));
        }
        _polygon.add(Polygon(
          polygonId: PolygonId("$ID"),
          points: corners,
          fillColor: Colors.lightBlueAccent.withOpacity(0.4),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ));
      } catch (e) {}

      _googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(coords[0], coords[1]),
          22,
        ),
      );

      if (SingletonFunctionController
              .building.floor[snapshot!.landmarksMap![ID]!.buildingID] !=
          floor) {
        SingletonFunctionController
            .building.floor[snapshot!.landmarksMap![ID]!.buildingID!] = floor;
        createRooms(
            SingletonFunctionController.building
                .polylinedatamap[snapshot!.landmarksMap![ID]!.buildingID]!,
            floor);
        createMarkers(snapshot!, floor);
      }

      setState(() {
        user.reset();
        PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
        pathMarkers.clear();
        PathState.path.clear();
        PathState.sourcePolyID = "";
        PathState.destinationPolyID = "";
        singleroute.clear();

        user.isnavigating = false;
        _isnavigationPannelOpen = false;
        SingletonFunctionController.building.selectedLandmarkID = ID;
        SingletonFunctionController.building.ignoredMarker.clear();
        SingletonFunctionController.building.ignoredMarker.add(ID);
        _isBuildingPannelOpen = false;
        _isRoutePanelOpen = false;
        singleroute.clear();
        _isLandmarkPanelOpen = true;
        PathState.directions = [];
        interBuildingPath.clear();

        addselectedMarker(LatLng(coords[0], coords[1]));
      });
    } else {
      setState(() {
        if (user.coordY != 0 && user.coordX != 0) {
          PathState.sourceX = user.coordX;
          PathState.sourceY = user.coordY;
          PathState.sourceFloor = user.floor;
          PathState.sourcePolyID = user.key;

          PathState.sourceName = "Your current location";
          PathState.destinationPolyID =
              SingletonFunctionController.building.selectedLandmarkID!;
          PathState.destinationName = snapshot!
                  .landmarksMap![
                      SingletonFunctionController.building.selectedLandmarkID]!
                  .name ??
              snapshot!
                  .landmarksMap![
                      SingletonFunctionController.building.selectedLandmarkID]!
                  .element!
                  .subType!;
          PathState.destinationFloor = snapshot!
              .landmarksMap![
                  SingletonFunctionController.building.selectedLandmarkID]!
              .floor!;
          PathState.sourceBid = user.Bid;

          PathState.destinationBid = snapshot!
              .landmarksMap![
                  SingletonFunctionController.building.selectedLandmarkID]!
              .buildingID!;

          setState(() {
            calculatingPath = true;
          });
          Future.delayed(Duration(seconds: 1), () {
            calculateroute(snapshot!.landmarksMap!).then((value) {
              calculatingPath = false;
              _isLandmarkPanelOpen = false;
              _isRoutePanelOpen = true;
            });
          });
        } else {
          PathState.sourceName = "Choose Starting Point";
          PathState.destinationPolyID =
              SingletonFunctionController.building.selectedLandmarkID!;
          PathState.destinationName = snapshot!
                  .landmarksMap![
                      SingletonFunctionController.building.selectedLandmarkID]!
                  .name ??
              snapshot!
                  .landmarksMap![
                      SingletonFunctionController.building.selectedLandmarkID]!
                  .element!
                  .subType!;
          PathState.destinationFloor = snapshot!
              .landmarksMap![
                  SingletonFunctionController.building.selectedLandmarkID]!
              .floor!;
          SingletonFunctionController.building.selectedLandmarkID = "";
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SourceAndDestinationPage(
                        DestinationID: PathState.destinationPolyID,
                        user: user,
                      ))).then((value) {
            if (value != null) {
              fromSourceAndDestinationPage(value);
            }
          });
        }
      });
    }
>>>>>>> Stashed changes
  }

  void fromSourceAndDestinationPage(List<String> value) {
    _isBuildingPannelOpen = false;
    markers.clear();
<<<<<<< Updated upstream
    building.landmarkdata!.then((land) {
      print("Himanshuchecker ${land.landmarksMap}");
      print("Himanshuchecker ${value[0]}");
=======
    SingletonFunctionController.building.landmarkdata!.then((land) {
      SingletonFunctionController.building.selectedLandmarkID =
          land.landmarksMap![value[1]]!.properties!.polyId!;
>>>>>>> Stashed changes
      PathState.sourceX = land.landmarksMap![value[0]]!.coordinateX!;
      PathState.sourceY = land.landmarksMap![value[0]]!.coordinateY!;
      if (land.landmarksMap![value[0]]!.doorX != null) {
        PathState.sourceX = land.landmarksMap![value[0]]!.doorX!;
        PathState.sourceY = land.landmarksMap![value[0]]!.doorY!;
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

      calculateroute(land.landmarksMap!).then((value) {
        _isRoutePanelOpen = true;
      });
    });
  }

  void onSourceVenueClicked(String ID) {
    setState(() {
      building.landmarkdata!.then((value) {
        _isLandmarkPanelOpen = false;
        PathState.sourceX = value.landmarksMap![ID]!.coordinateX!;
        PathState.sourceY = value.landmarksMap![ID]!.coordinateY!;
        if (value.landmarksMap![ID]!.doorX != null) {
          PathState.sourceX = value.landmarksMap![ID]!.doorX!;
          PathState.sourceY = value.landmarksMap![ID]!.doorY!;
        }
        PathState.sourceFloor = value.landmarksMap![ID]!.floor!;
        PathState.sourcePolyID = ID;
        PathState.sourceName = value.landmarksMap![ID]!.name!;
        PathState.sourceBid = value.landmarksMap![ID]!.buildingID!;
        PathState.path.clear();
        PathState.directions.clear();
        PathState.sourceBid = user.Bid;
        PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
        calculateroute(value.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
      });
    });
  }

  void onDestinationVenueClicked(String ID) {
    setState(() {
      building.landmarkdata!.then((value) {
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
        PathState.sourceBid = user.Bid;
        PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
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
<<<<<<< Updated upstream
      if (building.floor[buildingAllApi.getStoredString()] != turn.floor) {
=======
      if (SingletonFunctionController
              .building.floor[buildingAllApi.getStoredString()] !=
          turn.floor) {
>>>>>>> Stashed changes
        i++;
      } else {
        i--;
      }

      //List<LatLng> coordinates = [];
<<<<<<< Updated upstream
      BitmapDescriptor greytorch = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(44, 44)),
        'assets/greytorch.png',
      );
=======
      final Uint8List greytorch =
          await getImagesFromMarker('assets/previewarrow.png', 75);
      // BitmapDescriptor greytorch = await BitmapDescriptor.fromAssetImage(
      //   ImageConfiguration(size: Size(15, 15)),
      //   'assets/previewarrow.png',
      // );
>>>>>>> Stashed changes
      // for(int a = i;a>i-5;a--){
      //   if(a!=i && tools.isTurn([user.path[a-1]%turn.numCols!,user.path[a-1]~/turn.numCols!], [user.path[a]%turn.numCols!,user.path[a]~/turn.numCols!], [user.path[a+1]%turn.numCols!,user.path[a+1]~/turn.numCols!])){
      //     break;
      //   }
      //   List<double> ltln = tools.localtoglobal(user.path[a]%turn.numCols!, user.path[a]~/turn.numCols!);
      //   coordinates.insert(0,LatLng(ltln[0], ltln[1]));
      // }
      //
      // for(int a = i+1;a<i+6;a++){
      //   // if(a!=i && tools.isTurn([user.path[a-1]%turn.numCols!,user.path[a-1]~/turn.numCols!], [user.path[a]%turn.numCols!,user.path[a]~/turn.numCols!], [user.path[a+1]%turn.numCols!,user.path[a+1]~/turn.numCols!])){
      //   //   break;
      //   // }
      //   List<double> ltln = tools.localtoglobal(user.path[a]%turn.numCols!, user.path[a]~/turn.numCols!);
      //   coordinates.add(LatLng(ltln[0], ltln[1]));
      // }

      if (turn.floor != null &&
<<<<<<< Updated upstream
          building.floor[buildingAllApi.getStoredString()] != turn.floor) {
        building.floor[buildingAllApi.getStoredString()] = turn.floor!;
        createRooms(building.polyLineData!,
            building.floor[buildingAllApi.getStoredString()]!);
=======
          SingletonFunctionController
                  .building.floor[buildingAllApi.getStoredString()] !=
              turn.floor) {
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()] = turn.floor!;
        createRooms(
            SingletonFunctionController.building.polyLineData!,
            SingletonFunctionController
                .building.floor[buildingAllApi.getStoredString()]!);
>>>>>>> Stashed changes
      }

      List<int> nextPoint = [
        user.path[i] % turn.numCols!,
        user.path[i] ~/ turn.numCols!
      ];
      List<double> latlng = tools.localtoglobal(turn.x!, turn.y!,
<<<<<<< Updated upstream
          patchData: building.patchData[turn.Bid]);
      List<double> latlng2 = tools.localtoglobal(nextPoint[0], nextPoint[1],
          patchData: building.patchData[turn.Bid]);
=======
          SingletonFunctionController.building.patchData[turn.Bid]);
      List<double> latlng2 = tools.localtoglobal(nextPoint[0], nextPoint[1],
          SingletonFunctionController.building.patchData[turn.Bid]);
>>>>>>> Stashed changes

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
            icon: greytorch,
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

<<<<<<< Updated upstream
  void focusBuildingChecker(CameraPosition position) {
    // LatLng currentLatLng = position.target;
    // double distanceThreshold = 100.0;
=======
  // void turnMarkersVisible(int node){
  //   Set<Marker> tempSet=Set();
  //
  //   if (pathMarkers[user.Bid] != null && pathMarkers[user.Bid]![user.floor]!= null) {
  //
  //     for(var marker in pathMarkers[user.Bid]![user.floor]!){
  //
  //       if(marker.markerId.value.contains(node.toString())){
  //         tempSet.add(customMarker.visibility(true, marker));
  //       }else{
  //         tempSet.add(marker);
  //       }
  //     }
  //     pathMarkers[user.Bid]![user.floor]!=tempSet;
  //   }
  //
  //   for (var marker in pathMarkers[user.Bid]![user.floor]!) {
  //     if(marker.visible == true){
  //
  //     }
  //   }
  //
  // }
  String closestBuildingId = "";
  String newBuildingID = "";
  void focusBuildingChecker(CameraPosition position) {

    LatLng currentLatLng = position.target;
>>>>>>> Stashed changes
    // String closestBuildingId = "";
    // buildingAllApi.getStoredAllBuildingID().forEach((key, value) {

    //   if(key != buildingAllApi.outdoorID){
    //
    //     // tempMarkers.add(Marker(
    //     //     markerId: MarkerId("$key"),
    //     //     position: LatLng(value.latitude, value.longitude),
    //     //     onTap: () {
    //     //       print("$key");
    //     //     },
    //     // ));
    //     num distance = geo.Geodesy().distanceBetweenTwoGeoPoints(
    //       geo.LatLng(value.latitude, value.longitude),
    //       geo.LatLng(currentLatLng.latitude, currentLatLng.longitude),
    //     );
    //
    //     print("distance for $key is $distance");
    //
    //     if (distance < distanceThreshold) {
    //       closestBuildingId = key;
    //       buildingAllApi.setStoredString(key);
    //     }

<<<<<<< Updated upstream
    //   }
    // });
=======
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

      patchTransition(closestBuildingId);
    }
    newBuildingID = closestBuildingId;

    // Store the nearest SingletonFunctionController.building ID
    if (closestBuildingId.isNotEmpty) {
      buildingAllApi.setStoredString(closestBuildingId);
    }
>>>>>>> Stashed changes
  }

  @override
  void dispose() {
<<<<<<< Updated upstream
=======
    disposed = true;
    flutterTts.stop();
    SingletonFunctionController.building.qrOpened = false;
    SingletonFunctionController.building.dispose();
    SingletonFunctionController.apibeaconmap.clear();
    magneticValues.clear();
>>>>>>> Stashed changes
    _googleMapController.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    compassSubscription.cancel();
    flutterTts.cancelHandler;
    _timer.cancel();
    btadapter.stopScanning();
    super.dispose();
  }

  List<String> scannedDevices = [];
  late Timer _timer;

  Set<gmap.Polyline> finalSet = {};

  bool ispdrStart = false;
  bool semanticShouldBeExcluded = false;
  bool isSemanticEnabled = false;
<<<<<<< Updated upstream
=======
  bool isLocalized = false;

  IconData _mainIcon = Icons.volume_up_outlined;
  Color _mainColor = Colors.green;
  void _recenterMap() {
    alignMapToPath([
      user.lat,
      user.lng
    ], [
      PathState.singleCellListPath[user.pathobj.index + 1].lat,
      PathState.singleCellListPath[user.pathobj.index + 1].lng
    ]);
    print("value at recenter");
    print([user.lat, user.lng]);
    print([
      PathState.singleCellListPath[user.pathobj.index + 1].lat,
      PathState.singleCellListPath[user.pathobj.index + 1].lng
    ]);
    mapState.aligned = true;
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

  // Future<void> addCustomMarker(LatLng position, String bid, int floor) async {
  //
  //   pathMarkers.putIfAbsent(bid, ()=>Map());
  //   pathMarkers[bid]!.putIfAbsent(floor, ()=>Set());
  //   pathMarkers[bid]![floor]!.add(Marker(
  //       markerId: MarkerId("destination${bid}"),
  //       position: position,
  //       icon: await  CustomMarker(text: "hello").toBitmapDescriptor(
  //           logicalSize: const Size(150, 150), imageSize: const Size(300, 400))
  //   ));
  //   setState(() {
  //
  //   });
  // }

  Future<RenderRepaintBoundary> _capturePngFromWidget(
      BuildContext context, Widget widget, GlobalKey key) async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    return await Future.delayed(Duration(milliseconds: 20), () {
      return boundary;
    });
  }

  // Future<RenderRepaintBoundary> _capturePngFromWidget(BuildContext context, Widget widget) async {
  //   final RenderRepaintBoundary boundary = RenderRepaintBoundary();
  //   final RenderView renderView = RenderView(
  //     child: RenderProxyBox(boundary),
  //     configuration: ViewConfiguration(devicePixelRatio: MediaQuery.of(context).devicePixelRatio),
  //     view: WidgetsBinding.instance.window,
  //   );
  //   final PipelineOwner pipelineOwner = PipelineOwner()..rootNode = renderView;
  //   renderView.prepareInitialFrame();
  //   final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
  //   final RenderObjectToWidgetElement<RenderBox> rootElement =
  //   RenderObjectToWidgetAdapter<RenderBox>(
  //     container: boundary,
  //     child: widget,
  //   ).attachToRenderTree(buildOwner);
  //   buildOwner.buildScope(rootElement);
  //   buildOwner.finalizeTree();
  //   await Future.delayed(Duration(milliseconds: 20)); // wait for widget to build
  //   pipelineOwner.flushLayout();
  //   pipelineOwner.flushCompositingBits();
  //   pipelineOwner.flushPaint();
  //   return boundary;
  // }

  // void _addCustomMarker(String bid, int floor, LatLng position) async {
  //
  //   final customMarker = await createCustomMarkerBitmap(context, 'Your Text', Icons.location_on);
  //   pathMarkers.putIfAbsent(bid, ()=>Map());
  //   pathMarkers[bid]!.putIfAbsent(floor, ()=>Set());
  //   pathMarkers[bid]![floor]!.add(Marker(
  //     markerId: MarkerId('custom_marker'),
  //     position: position, // Your desired position
  //     icon: BitmapDescriptor.defaultMarker,
  //     onTap: () {
  //
  //       // Handle tap functionality here
  //     },
  //   ));
  // }
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidthPixels = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
    double screenHeightPixel = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
    isSemanticEnabled = MediaQuery.of(context).accessibleNavigation;
    HelperClass.SemanticEnabled = MediaQuery.of(context).accessibleNavigation;
    return SafeArea(
<<<<<<< Updated upstream
      child: isLoading && isBlueToothLoading
          ? Scaffold(
              body: Center(
                child: lott.Lottie.asset(
                  'assets/loading_bluetooth.json', // Path to your Lottie animation
                  width: 500,
                  height: 500,
                ),
              ),
            )
          : isLoading
              ? Scaffold(
                  body: Center(
                      child: lott.Lottie.asset(
                    'assets/loding_animation.json', // Path to your Lottie animation
                    width: 500,
                    height: 500,
                  )),
                )
              : Scaffold(
                  body: Stack(
                    children: [
                      detected
                          ? Semantics(
                              excludeSemantics: true,
                              child: ExploreModePannel())
                          : Semantics(
                              excludeSemantics: true, child: Container()),
                      Semantics(
                        excludeSemantics: true,
                        child: Container(
                          child: GoogleMap(
                            padding: EdgeInsets.only(
                                left: 20), // <--- padding added here
                            initialCameraPosition: _initialCameraPosition,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            zoomGesturesEnabled: true,

                            polygons: patch
                                .union(getCombinedPolygons())
                                .union(otherpatch),
                            polylines: singleroute[building.floor[
                                        buildingAllApi.getStoredString()]] !=
                                    null
                                ? getCombinedPolylines().union(singleroute[
                                    building.floor[
                                        buildingAllApi.getStoredString()]]!)
                                : getCombinedPolylines(),
                            markers: getCombinedMarkers().union(focusturnArrow),
                            onTap: (x) {
                              mapState.interaction = true;
                            },
                            mapType: MapType.normal,
                            buildingsEnabled: false,
                            compassEnabled: true,
                            rotateGesturesEnabled: true,
                            minMaxZoomPreference: MinMaxZoomPreference(2, 30),
                            onMapCreated: (controller) {
                              controller.setMapStyle(maptheme);
                              _googleMapController = controller;
                              print("tumhari galti hai sb saalo");

                              if (patch.isNotEmpty) {
                                fitPolygonInScreen(patch.first);
                              }
                            },
                            onCameraMove: (CameraPosition cameraPosition) {
                              print("plpl ${cameraPosition.tilt}");
                              focusBuildingChecker(cameraPosition);
                              mapState.interaction = true;
                              mapbearing = cameraPosition.bearing;
                              if (!mapState.interaction) {
                                mapState.zoom = cameraPosition.zoom;
                              }
                              if (true) {
                                _updateMarkers(cameraPosition.zoom);
                                //_updateBuilding(cameraPosition.zoom);
                              }
                            },
                            onCameraIdle: () {
                              if (!mapState.interaction) {
                                mapState.interaction2 = true;
                              }
                            },
                            onCameraMoveStarted: () {
                              mapState.interaction2 = false;
                            },
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
                        bottom: 150.0, // Adjust the position as needed
                        right: 16.0,

                        child: Semantics(
                          excludeSemantics: false,
                          child: Column(
                            children: [
                              //
                              // // Text(Building.thresh),
                              Visibility(
                                visible: DebugToggle.StepButton,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(24))),
                                    child: IconButton(
                                        onPressed: () {
                                          //StartPDR();

                                          bool isvalid =
                                              MotionModel.isValidStep(
                                                  user,
                                                  building.floorDimenssion[user
                                                      .Bid]![user.floor]![0],
                                                  building.floorDimenssion[user
                                                      .Bid]![user.floor]![1],
                                                  building.nonWalkable[
                                                      user.Bid]![user.floor]!,
                                                  reroute);
                                          if (isvalid) {
                                            user.move().then((value) {
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
                                              markers[user.Bid]?[0] =
                                                  customMarker.rotate(
                                                      compassHeading! -
                                                          mapbearing,
                                                      markers[user.Bid]![0]);
                                          }
                                        });
                                      })
                                  : Container(),
                              SizedBox(height: 28.0),
                              !isSemanticEnabled
                                  ? Semantics(
                                      label: "Change floor",
                                      child: SpeedDial(
                                        child: Text(
                                          building.floor == 0
                                              ? 'G'
                                              : '${building.floor[buildingAllApi.getStoredString()]}',
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff24b9b0),
                                            height: 19 / 16,
                                          ),
                                        ),
                                        activeIcon: Icons.close,
                                        backgroundColor: Colors.white,
                                        children: List.generate(
                                          building.numberOfFloors[buildingAllApi
                                              .getStoredString()]!,
                                          (int i) {
                                            return SpeedDialChild(
                                              child: Semantics(
                                                label: "i",
                                                child: Text(
                                                  i == 0 ? 'G' : '$i',
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    height: 19 / 16,
                                                  ),
                                                ),
                                              ),
                                              backgroundColor:
                                                  pathMarkers[i] == null
                                                      ? Colors.white
                                                      : Color(0xff24b9b0),
                                              onTap: () {
                                                building.floor[buildingAllApi
                                                    .getStoredString()] = i;
                                                createRooms(
                                                  building.polylinedatamap[
                                                      buildingAllApi
                                                          .getStoredString()]!,
                                                  building.floor[buildingAllApi
                                                      .getStoredString()]!,
                                                );
                                                if (pathMarkers[i] != null) {
                                                  //setCameraPosition(pathMarkers[i]!);
                                                }
                                                building.landmarkdata!
                                                    .then((value) {
                                                  createMarkers(
                                                    value,
                                                    building.floor[buildingAllApi
                                                        .getStoredString()]!,
                                                  );
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : floorColumn(),
                              SizedBox(
                                  height: 28.0), // Adjust the height as needed

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

                              Semantics(
                                child: FloatingActionButton(
                                  onPressed: () async {
                                    print(FlutterBluePlus.adapterStateNow
                                        .toString());
                                    btadapter.startScanningIOS(apibeaconmap);
                                    // //print(PathState.connections);
                                    // building.floor[buildingAllApi
                                    //     .getStoredString()] = user.floor;
                                    // createRooms(
                                    //     building.polyLineData!,
                                    //     building.floor[
                                    //         buildingAllApi.getStoredString()]!);
                                    // if (pathMarkers[user.floor] != null) {
                                    //   setCameraPosition(
                                    //       pathMarkers[user.floor]!);
                                    // }
                                    // building.landmarkdata!.then((value) {
                                    //   createMarkers(
                                    //       value,
                                    //       building.floor[buildingAllApi
                                    //           .getStoredString()]!);
                                    // });
                                    // if (markers.length > 0)
                                    //   markers[user.Bid]?[0] = customMarker
                                    //       .rotate(0, markers[user.Bid]![0]);
                                    // if (user.initialallyLocalised) {
                                    //   mapState.interaction =
                                    //       !mapState.interaction;
                                    // }
                                    // mapState.zoom = 21;
                                    // fitPolygonInScreen(patch.first);
                                  },
                                  child: Semantics(
                                    label: "Localize",
                                    onDidGainAccessibilityFocus:
                                        close_isnavigationPannelOpen,
                                    child: Icon(
                                      Icons.my_location_sharp,
                                      color: Colors.black,
                                    ),
                                  ),

                                  backgroundColor: Colors
                                      .white, // Set the background color of the FAB
                                ),
                              ),
                              SizedBox(height: 28.0),
                              FloatingActionButton(
                                onPressed: () async {
                                  if (user.initialallyLocalised) {
                                    setState(() {
                                      if (isLiveLocalizing) {
                                        isLiveLocalizing = false;
                                        HelperClass.showToast(
                                            "Explore mode is disabled");
                                        _exploreModeTimer!.cancel();
                                        _isExploreModePannelOpen = false;
                                        _isBuildingPannelOpen = true;
                                        lastBeaconValue = "";
                                      } else {
                                        speak("Explore Mode Enabled");
                                        isLiveLocalizing = true;
                                        HelperClass.showToast(
                                            "Explore mode enabled");
                                        _exploreModeTimer = Timer.periodic(
                                            Duration(milliseconds: 5000),
                                            (timer) async {
                                          btadapter.startScanning(resBeacons);
                                          Future.delayed(
                                                  Duration(milliseconds: 2000))
                                              .then((value) => {
                                                    realTimeReLocalizeUser(
                                                        resBeacons)
                                                    // listenToBin()
                                                  });
                                        });
                                        _isBuildingPannelOpen = false;
                                        _isExploreModePannelOpen = true;
                                      }
                                    });
                                  }
                                },
                                child: SvgPicture.asset(
                                  "assets/Navigation_RTLIcon.svg",
                                  // color:
                                  // (isLiveLocalizing) ? Colors.white : Colors.cyan,
                                ),
                                backgroundColor: Color(
                                    0xff24B9B0), // Set the background color of the FAB
                              ), // Adjust the height as needed// Adjust the height as needed

                              // FloatingActionButton(
                              //   onPressed: (){
                              //     print("checkingBuildingfloor");
                              //     //building.floor == 0 ? 'G' : '${building.floor}',
                              //     print(building.floor);
                              //     int firstKey = building.floor.values.first;
                              //     print(firstKey);
                              //     print(singleroute[building.floor.values.first]);
                              //
                              //     print(singleroute.keys);
                              //     print(singleroute.values);
                              //     print(building.floor[buildingAllApi.getStoredString()]);
                              //     print(singleroute[building.floor[buildingAllApi.getStoredString()]]);
                              //   },
                              //   child: Icon(Icons.add)
                              // ),
                              // FloatingActionButton(
                              //   onPressed: () async {
                              //
                              // StopPDR();
                              //
                              //
                              //
                              //     // if (user.initialallyLocalised) {
                              //     //   setState(() {
                              //     //     isLiveLocalizing = !isLiveLocalizing;
                              //     //   });
                              //     //
                              //     //   Timer.periodic(
                              //     //       Duration(milliseconds: 6000),
                              //     //           (timer) async {
                              //     //         print(resBeacons);
                              //     //         btadapter.startScanning(resBeacons);
                              //     //         Future.delayed(Duration(milliseconds: 4000)).then((value) => {
                              //     //           //c(resBeacons)
                              //     //         });
                              //     //
                              //     //       });
                              //     //
                              //     // }
                              //
                              //   },
                              //   child: Icon(
                              //     Icons.location_history_sharp,
                              //     color: (isLiveLocalizing)
                              //         ? Colors.cyan
                              //         : Colors.black,
                              //   ),
                              //   backgroundColor: Colors
                              //       .white, // Set the background color of the FAB
                              // ),
                            ],
                          ),
                        ),
                      ),
                      //-------
                      Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: _isLandmarkPanelOpen ||
                                  _isRoutePanelOpen ||
                                  _isnavigationPannelOpen
                              ? Semantics(
                                  excludeSemantics: true, child: Container())
                              : FocusScope(
                                  autofocus: true,
                                  child: Focus(
                                    child: Semantics(
                                      sortKey: const OrdinalSortKey(
                                          0), // header: true,
                                      child: HomepageSearch(
                                        onVenueClicked: onLandmarkVenueClicked,
                                        fromSourceAndDestinationPage:
                                            fromSourceAndDestinationPage,
                                      ),
                                    ),
                                  ),
                                )),
                      FutureBuilder(
                        future: building.landmarkdata,
                        builder: (context, snapshot) {
                          if (_isLandmarkPanelOpen) {
                            return landmarkdetailpannel(context, snapshot);
                          } else {
                            return Semantics(
                                excludeSemantics: true, child: Container());
                          }
                        },
                      ),
                      routeDeatilPannel(),
                      navigationPannel(),
                      reroutePannel(),
                      ExploreModePannel(),
                      detected
                          ? Semantics(child: nearestLandmarkpannel())
                          : Container(),
                      SizedBox(height: 28.0), // Adjust the height as needed
                      // FloatingActionButton(
                      //     onPressed: (){
                      //       print("checkingBuildingfloor");
                      //       //building.floor == 0 ? 'G' : '${building.floor}',
                      //       print(building.floor);
                      //       int firstKey = building.floor.values.first;
                      //       print(firstKey);
                      //       print(singleroute[building.floor.values.first]);
                      //
                      //       print(singleroute.keys);
                      //       print(singleroute.values);
                      //       print(building.floor[buildingAllApi.getStoredString()]);
                      //       print(singleroute[building.floor[buildingAllApi.getStoredString()]]);
                      //     },
                      //     child: Icon(Icons.add)
                      // ),

                      // FloatingActionButton(
                      //   onPressed: () async {
                      //
                      //     //StopPDR();
                      //
                      //     if (user.initialallyLocalised) {
                      //       setState(() {
                      //         isLiveLocalizing = !isLiveLocalizing;
                      //       });
                      //       HelperClass.showToast("realTimeReLocalizeUser started");
                      //
                      //       Timer.periodic(
                      //           Duration(milliseconds: 5000),
                      //               (timer) async {
                      //             print(resBeacons);
                      //             btadapter.startScanning(resBeacons);
                      //
                      //
                      //             // setState(() {
                      //             //   sumMap=  btadapter.calculateAverage();
                      //             // });
                      //
                      //
                      //             Future.delayed(Duration(milliseconds: 2000)).then((value) => {
                      //               realTimeReLocalizeUser(resBeacons)
                      //               // listenToBin()
                      //
                      //
                      //             });
                      //
                      //             setState(() {
                      //               debugPQ = btadapter.returnPQ();
                      //
                      //             });
                      //
                      //           });
                      //
                      //     }
                      //
                      //   },
                      //   child: Icon(
                      //     Icons.location_history_sharp,
                      //     color: (isLiveLocalizing)
                      //         ? Colors.cyan
                      //         : Colors.black,
                      //   ),
                      //   backgroundColor: Colors
                      //       .white, // Set the background color of the FAB
                      // ),
                    ],
                  ),
                ),
=======
      child: Scaffold(
        body: Stack(
          children: [
            detected
                ? Semantics(excludeSemantics: true, child: ExploreModePannel())
                : Semantics(excludeSemantics: true, child: Container()),
            Stack(children: [
              Semantics(
                excludeSemantics: true,
                child: Container(
                  child: GoogleMap(
                    padding:
                        EdgeInsets.only(left: 20), // <--- padding added here
                    initialCameraPosition: _initialCameraPosition,
                    // myLocationButtonEnabled: true,
                    // myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    mapToolbarEnabled: false,
                    // circles: _userLocation != null && _accuracy != null
                    //     ? {
                    //   Circle(
                    //     circleId: CircleId('accuracyCircle'),
                    //     center: _userLocation!,
                    //     radius: _accuracy!,  // Draw accuracy circle
                    //     strokeColor: Colors.blueAccent,
                    //     fillColor: Colors.blueAccent.withOpacity(0.2),
                    //     strokeWidth: 1,
                    //   )
                    // }
                    //     : {},

                    polygons: patch
                        .union(getCombinedPolygons())
                        .union(otherpatch)
                        .union(_polygon)
                        .union(blurPatch),
                    polylines: getCombinedPolylines(),
                    markers: getCombinedMarkers()
                        .union(_markers)
                        .union(focusturnArrow)
                        .union(Markers)
                        .union(restBuildingMarker),
                    onTap: (x) {
                      mapState.interaction = true;
                    },
                    mapType: MapType.normal,
                    buildingsEnabled: false,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    minMaxZoomPreference: MinMaxZoomPreference(2, 30),
                    onMapCreated: (controller) {
                      controller.setMapStyle(maptheme);
                      _googleMapController = controller;
                      zoomWhileWait(buildingAllApi.allBuildingID, controller);

                      _initMarkers();
                    },
                    onCameraMove: (CameraPosition cameraPosition) {
                      if (cameraPosition.zoom > 15.5) {
                        print("elsefocusBuildingChecker");
                        blurPatch.clear();
                        restBuildingMarker.clear();
                        focusBuildingChecker(cameraPosition);
                      } else {
                        print("elserenderCampusPatchTransition");
                        renderCampusPatchTransition(buildingAllApi.outdoorID);
                      }

                      if (cameraPosition.target.latitude.toStringAsFixed(5) !=
                          mapState.target.latitude.toStringAsFixed(5)) {
                        mapState.aligned = false;
                      } else {
                        mapState.aligned = true;
                      }
                      mapState.interaction = true;
                      mapbearing = cameraPosition.bearing;
                      if (!mapState.interaction) {
                        mapState.zoom = cameraPosition.zoom;
                      }
                      if (true) {
                        _updateMarkers(cameraPosition.zoom);
                        //_updateBuilding(cameraPosition.zoom);
                      }
                      // _updateMarkers(cameraPosition.zoom);
                      if (cameraPosition.zoom < 17) {
                        _markers.clear();
                        markerSldShown = false;
                      } else {
                        if (user.isnavigating) {
                          _markers.clear();
                          markerSldShown = false;
                        } else {
                          markerSldShown = true;
                        }
                      }
                      if (markerSldShown) {
                        _updateMarkers11(cameraPosition.zoom);
                      } else {}

                      // _updateEntryMarkers11(cameraPosition.zoom);
                      //_markerLocations.clear();
                      //
                    },
                    onCameraIdle: () {
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
              Positioned(
                bottom: 0,
                child: Container(
                  width: screenWidth,
                  height: 30,
                  color: Colors.white,
                ),
              )
            ]),
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
              bottom: 150.0, // Adjust the position as needed
              right: 16.0,

              child: Semantics(
                excludeSemantics: false,
                child: Column(
                  children: [
                    //
                    // // Text(Building.thresh),

                    isSemanticEnabled
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
                                onTap: () => {
                                  setState(() {
                                    _mainIcon = Icons.volume_up_outlined;
                                    _mainColor = Colors.green;
                                  }),
                                  UserState.ttsAllStop = false,
                                  UserState.ttsOnlyTurns = false,
                                },
                              ),
                              SpeedDialChild(
                                child: Icon(Icons.volume_down_outlined,
                                    color: Colors.black),
                                backgroundColor: Colors.blueAccent,
                                onTap: () => {
                                  setState(() {
                                    _mainIcon = Icons.volume_down_outlined;
                                    _mainColor = Colors.blueAccent;
                                  }),
                                  UserState.ttsOnlyTurns = true,
                                  UserState.ttsAllStop = false,
                                },
                              ),
                              SpeedDialChild(
                                child: Icon(Icons.volume_off_outlined,
                                    color: Colors.white),
                                backgroundColor: Colors.red,
                                onTap: () => {
                                  setState(() {
                                    _mainIcon = Icons.volume_off_outlined;
                                    _mainColor = Colors.red;
                                  }),
                                  UserState.ttsAllStop = true,
                                  UserState.ttsOnlyTurns = false,
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
                                        user.Bid]![user.floor]![0],
                                    SingletonFunctionController
                                            .building.floorDimenssion[
                                        user.Bid]![user.floor]![1],
                                    SingletonFunctionController.building
                                        .nonWalkable[user.Bid]![user.floor]!,
                                    reroute);
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
                    DebugToggle.Slider ? Text("${user.theta}") : Container(),

                    // Text("coord [${user.coordX},${user.coordY}] \n"
                    //     "showcoord [${user.showcoordX},${user.showcoordY}] \n"
                    // "next coord [${user.pathobj.index+1<user.Cellpath.length?user.Cellpath[user.pathobj.index+1].x:0},${user.pathobj.index+1<user.Cellpath.length?user.Cellpath[user.pathobj.index+1].y:0}]\n"
                    // "next bid ${user.pathobj.index+1<user.Cellpath.length?user.Cellpath[user.pathobj.index+1].bid:0}"
                    //     "floor ${user.floor}\n"
                    //     "userBid ${user.Bid} \n"
                    //     "index ${user.pathobj.index} \n"
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
                                    markers[user.Bid]?[0] = customMarker.rotate(
                                        compassHeading! - mapbearing,
                                        markers[user.Bid]![0]);
                                }
                              });
                            })
                        : Container(),
                    !isSemanticEnabled
                        ? Semantics(
                            label: "Change floor",
                            child: SpeedDial(
                              child: Text(
                                SingletonFunctionController.building.floor == 0
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
                              activeIcon: Icons.close,
                              backgroundColor: Colors.white,
                              children: List.generate(
                                (Building.numberOfFloorsDelhi[
                                            buildingAllApi.getStoredString()] ??
                                        [0])
                                    .length,
                                (int i) {
                                  //
                                  List<int> floorList = Building
                                              .numberOfFloorsDelhi[
                                          buildingAllApi.getStoredString()] ??
                                      [0];
                                  List<int> revfloorList = floorList;
                                  revfloorList.sort();
                                  // SingletonFunctionController.building.numberOfFloors[buildingAllApi
                                  //     .getStoredString()];
                                  //
                                  //
                                  return SpeedDialChild(
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
                                    backgroundColor: pathMarkers[i] == null
                                        ? Colors.white
                                        : Color(0xff24b9b0),
                                    onTap: () {
                                      _polygon.clear();
                                      circles.clear();

                                      _markers.clear();
                                      _markerLocationsMap.clear();
                                      _markerLocationsMapLanName.clear();

                                      SingletonFunctionController
                                                  .building.floor[
                                              buildingAllApi
                                                  .getStoredString()] =
                                          revfloorList[i];
                                      createRooms(
                                        SingletonFunctionController
                                                .building.polylinedatamap[
                                            buildingAllApi.getStoredString()]!,
                                        SingletonFunctionController
                                                .building.floor[
                                            buildingAllApi.getStoredString()]!,
                                      );
                                      if (pathMarkers[i] != null) {
                                        //setCameraPosition(pathMarkers[i]!);
                                      }
                                      // Markers.clear();
                                      SingletonFunctionController
                                          .building.landmarkdata!
                                          .then((value) {
                                        createMarkers(
                                            value,
                                            SingletonFunctionController
                                                    .building.floor[
                                                buildingAllApi
                                                    .getStoredString()]!,
                                            bid: buildingAllApi
                                                .getStoredString());
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        : nofloorColumn(),
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

                    Semantics(
                      child: FloatingActionButton(
                        onPressed: () async {
                          //  _getUserLocation();

                          if (!user.isnavigating && !isLocalized) {
                            SingletonFunctionController.btadapter.emptyBin();
                            SingletonFunctionController.btadapter
                                .stopScanning();
                            if (Platform.isAndroid) {
                              SingletonFunctionController.btadapter
                                  .startScanning(
                                      SingletonFunctionController.apibeaconmap);
                            } else {
                              SingletonFunctionController.btadapter
                                  .startScanningIOS(
                                      SingletonFunctionController.apibeaconmap);
                            }
                            setState(() {
                              isLocalized = true;
                              resBeacons =
                                  SingletonFunctionController.apibeaconmap;
                            });
                            late Timer _timer;
                            _timer = Timer.periodic(
                                Duration(milliseconds: 5000), (timer) {
                              localizeUser().then((value) => {
                                    setState(() {
                                      isLocalized = false;
                                    })
                                  });

                              _timer.cancel();
                            });
                          } else {
                            _recenterMap();
                          }
                          ;
                        },
                        child: Semantics(
                          label:
                              !user.isnavigating ? "Localize" : "Recenter Map",
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
                                      ? Icons.my_location_sharp
                                      : (mapState.aligned
                                          ? CupertinoIcons.location_north_fill
                                          : CupertinoIcons.location_north),
                                  color: (!user.isnavigating)
                                      ? Colors.black
                                      : Colors.blue),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(26.0), // Change radius here
                        ),
                        backgroundColor:
                            Colors.white, // Set the background color of the FAB
                      ),
                    ),
                    SizedBox(height: 28.0),
                    !user.isnavigating &&
                            (!_isLandmarkPanelOpen &&
                                !_isRoutePanelOpen &&
                                _isBuildingPannelOpen &&
                                !_isnavigationPannelOpen &&
                                user.initialallyLocalised)
                        ? FloatingActionButton(
                            onPressed: () async {
                              if (user.initialallyLocalised) {
                                setState(() {
                                  if (isLiveLocalizing) {
                                    isLiveLocalizing = false;
                                    HelperClass.showToast(
                                        "Explore mode is disabled");
                                    _exploreModeTimer!.cancel();
                                    _isExploreModePannelOpen = false;
                                    _isBuildingPannelOpen = true;
                                    lastBeaconValue = "";
                                  } else {
                                    speak(
                                        "${LocaleData.exploremodenabled.getString(context)}",
                                        _currentLocale);
                                    isLiveLocalizing = true;
                                    HelperClass.showToast(
                                        "Explore mode enabled");
                                    _exploreModeTimer = Timer.periodic(
                                        Duration(milliseconds: 5000),
                                        (timer) async {
                                      if (Platform.isAndroid) {
                                        SingletonFunctionController.btadapter
                                            .startScanning(
                                                SingletonFunctionController
                                                    .apibeaconmap);
                                      } else {
                                        SingletonFunctionController.btadapter
                                            .startScanningIOS(
                                                SingletonFunctionController
                                                    .apibeaconmap);
                                      }
                                      Future.delayed(
                                              Duration(milliseconds: 2000))
                                          .then((value) => {
                                                realTimeReLocalizeUser(
                                                    resBeacons)
                                                // listenToBin()
                                              });
                                    });
                                    _isBuildingPannelOpen = false;
                                    _isExploreModePannelOpen = true;
                                  }
                                });
                              }
                            },
                            child: Semantics(
                              label: "Explore mode",
                              child: SvgPicture.asset(
                                "assets/Navigation_RTLIcon.svg",
                                // color:
                                // (isLiveLocalizing) ? Colors.white : Colors.cyan,
                              ),
                            ),
                            backgroundColor: Color(
                                0xff24B9B0), // Set the background color of the FAB
                          )
                        : Container(), // Adjust the height as needed// Adjust the height as needed
                    // FloatingActionButton(
                    //   onPressed: () async {
                    //     AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
                    //   },
                    //   child: Icon(Icons.settings),
                    //   backgroundColor: Color(
                    //       0xff24B9B0), // Set the background color of the FAB
                    // )
                  ],
                ),
              ),
            ),
            //-------
            // (user.isnavigating && recenter)? Positioned(
            //   bottom: 145,
            //   right: 220,
            //   child: Container(
            //     height: 50,
            //     width: 150, // Adjust width as needed
            //     child: ElevatedButton(
            //       onPressed: () {
            //         // Implement recenter logic here
            //         _recenterMap();
            //       },
            //       style: ElevatedButton.styleFrom(
            //         foregroundColor: Colors.white, // Background color
            //         backgroundColor: Colors.blueGrey.withOpacity(0.5), // Text color
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(30), // Rounded corners
            //         ),
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.my_location, size: 24),
            //           SizedBox(width: 8), // Space between icon and text
            //           Text('Recenter', style: TextStyle(fontSize: 16)),
            //         ],
            //       ),
            //     ),
            //   ),
            // ):Container(),
            Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _isLandmarkPanelOpen ||
                        _isRoutePanelOpen ||
                        _isnavigationPannelOpen
                    ? Semantics(excludeSemantics: true, child: Container())
                    : FocusScope(
                        autofocus: true,
                        child: Focus(
                          child: Semantics(
                            sortKey: const OrdinalSortKey(0), // header: true,
                            child: HomepageSearch(
                              onVenueClicked: onLandmarkVenueClicked,
                              fromSourceAndDestinationPage:
                                  fromSourceAndDestinationPage,
                              user: user,
                            ),
                          ),
                        ),
                      )),
            FutureBuilder(
              future: SingletonFunctionController.building.landmarkdata,
              builder: (context, snapshot) {
                if (_isLandmarkPanelOpen) {
                  return landmarkdetailpannel(context, snapshot);
                } else {
                  return Semantics(excludeSemantics: true, child: Container());
                }
              },
            ),
            routeDeatilPannel(),
            feedbackPanel(context),
            navigationPannel(),
            reroutePannel(context),
            ExploreModePannel(),
            detected ? Semantics(child: nearestLandmarkpannel()) : Container(),
            SizedBox(height: 28.0), // Adjust the height as needed
            // FloatingActionButton(
            //     onPressed: (){
            //
            //       //SingletonFunctionController.building.floor == 0 ? 'G' : '${SingletonFunctionController.building.floor}',
            //
            //       int firstKey = SingletonFunctionController.building.floor.values.first;
            //
            //
            //
            //
            //
            //
            //
            //     },
            //     child: Icon(Icons.add)
            // ),

            // FloatingActionButton(
            //   onPressed: () async {
            //
            //     //StopPDR();
            //
            //     if (user.initialallyLocalised) {
            //       setState(() {
            //         isLiveLocalizing = !isLiveLocalizing;
            //       });
            //       HelperClass.showToast("realTimeReLocalizeUser started");
            //
            //       Timer.periodic(
            //           Duration(milliseconds: 5000),
            //               (timer) async {
            //
            //             SingletonFunctionController.btadapter.startScanning(resBeacons);
            //
            //
            //             // setState(() {
            //             //   sumMap=  SingletonFunctionController.btadapter.calculateAverage();
            //             // });
            //
            //
            //             Future.delayed(Duration(milliseconds: 2000)).then((value) => {
            //               realTimeReLocalizeUser(resBeacons)
            //               // listenToBin()
            //
            //
            //             });
            //
            //             setState(() {
            //               debugPQ = SingletonFunctionController.btadapter.returnPQ();
            //
            //             });
            //
            //           });
            //
            //     }
            //
            //   },
            //   child: Icon(
            //     Icons.location_history_sharp,
            //     color: (isLiveLocalizing)
            //         ? Colors.cyan
            //         : Colors.black,
            //   ),
            //   backgroundColor: Colors
            //       .white, // Set the background color of the FAB
            // ),
            (!SingletonFunctionController.building.destinationQr &&
                    !user.initialallyLocalised &&
                    !SingletonFunctionController.building.qrOpened)
                ? Container(
                    height: screenHeight,
                    width: screenWidth,
                    color: Colors.white.withOpacity(0.8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        lott.Lottie.asset(
                          'assets/loding_animation.json', // Path to your Lottie animation
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 56, right: 56),
                          child: LinearProgressIndicator(
                            value: _progressValue,
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
>>>>>>> Stashed changes
    );
  }
  //
  // int d=0;
  // bool listenToBin(){
  //   double highestweight = 0;
  //   String nearestBeacon = "";
  //   Map<String, double> sumMap = btadapter.calculateAverage();
  //
  //
  //
  //  // widget.direction = "";
  //
  //
  //   for (int i = 0; i < btadapter.BIN.length; i++) {
  //     if(btadapter.BIN[i]!.isNotEmpty){
  //       btadapter.BIN[i]!.forEach((key, value) {
  //         key = "";
  //         value = 0.0;
  //       });
  //     }
  //   }
  //   btadapter.numberOfSample.clear();
  //   btadapter.rs.clear();
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
  //     if(user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null){
  //       if(user.key != Building.apibeaconmap[nearestBeacon]!.sId){
  //
  //         if(user.floor == Building.apibeaconmap[nearestBeacon]!.floor  && highestweight >9){
  //           List<int> beaconcoord = [Building.apibeaconmap[nearestBeacon]!.coordinateX!,Building.apibeaconmap[nearestBeacon]!.coordinateY!];
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
  //               user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
  //
  //               speak("You are near ${Building.apibeaconmap[nearestBeacon]!.name}");
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
  //           speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor");
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

  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort(
          (a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }
}
<<<<<<< Updated upstream
=======

class CircleAnimation {
  final AnimationController controller;
  final Animation<double> animation;

  CircleAnimation(this.controller, this.animation);
}

class CustomMarker extends StatelessWidget {
  final String text;
  final IconData dirIcon;
  CustomMarker({required this.text, required this.dirIcon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xffFFFF00), // Set the background color to yellow
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
            bottomRight: Radius.circular(35),
            bottomLeft: Radius.circular(1)),
        border: Border.all(
          color: Colors.black, // Set the border color to white
          width: 2, // Set the border width (adjust as needed)
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(dirIcon, color: Colors.black, size: 32),
          SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              text,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
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
>>>>>>> Stashed changes
