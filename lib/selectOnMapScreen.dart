import 'dart:async';
import 'dart:typed_data' as typed_data;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:collection/collection.dart' as pac;
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:iwaymaps/API/ladmarkApi.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:iwaymaps/singletonClass.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'API/buildingAllApi.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'CLUSTERING/InitMarkerModel.dart';
import 'CLUSTERING/MapHelper.dart';
import 'CLUSTERING/MapMarkers.dart';
import 'GlobalAnnotation/global_rendering.dart';
import 'MapState.dart';
import 'UserState.dart';
import 'buildingState.dart';
import 'cutommarker.dart';
import 'navigationTools.dart';
import 'package:geodesy/geodesy.dart' as geo;

class SelectOnMapScreen extends StatefulWidget {
  polylinedata poly;
  patchDataModel patchData;
  bool destiPoint;
  Building buildingData;
  SelectOnMapScreen(
      {super.key,
      required this.poly,
      required this.patchData,
      required this.destiPoint,
      required this.buildingData});
  @override
  State<SelectOnMapScreen> createState() => _SelectOnMapScreenState();
}

class _SelectOnMapScreenState extends State<SelectOnMapScreen>
    with TickerProviderStateMixin {
  MapState mapState = new MapState();
  Timer? PDRTimer;
  Timer? _exploreModeTimer;
  String maptheme = "";
  var _initialCameraPosition = CameraPosition(
    target: LatLng(60.543833319119475, 77.18729871127312),
    zoom: 20,
  );
  late GoogleMapController _googleMapController;
  Set<Polygon> patch = Set();
  Set<Polygon> otherpatch = Set();
  Set<Polygon> blurPatch = Set();
  Map<String, Set<gmap.Polyline>> polylines = Map();
  Set<gmap.Polyline> otherpolylines = Set();
  Set<gmap.Polyline> focusturn = Set();
  Set<Marker> focusturnArrow = Set();
  Map<String, Set<Polygon>> closedpolygons = Map();
  Set<Polygon> globalCampus = Set();
  Set<Polygon> otherclosedpolygons = Set();
  Set<Marker> Markers = Set();
  Set<Marker> builidngNameMarker = Set();
  Map<String, Set<Marker>> selectedroomMarker = Map();
  Map<String, Map<int, Set<Marker>>> pathMarkers = {};
  Map<String, List<Marker>> markers = Map();
  // Building SingletonFunctionController.building = Building(floor: Map(), numberOfFloors: Map());
  Map<String, Map<int, Set<gmap.Polyline>>> singleroute = {};
  Map<int, Set<Marker>> dottedSingleRoute = {};
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
  late final typed_data.Uint8List userloc;
  late final typed_data.Uint8List userlocdebug;

  // HashMap<String, beacon> SingletonFunctionController.apibeaconmap = HashMap();
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
  bool markerSldShown = true;
  Set<Marker> _markers = Set();
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale = '';
  final GlobalKey rerouteButton = GlobalKey();

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
  ///
  Set<Polygon> _polygon = Set();
  Set<Polygon> getCombinedPolygons() {
    if (cachedPolygon.isEmpty) {
      Set<Polygon> polygons = Set();

      closedpolygons.forEach((key, value) {
        polygons = polygons.union(value);
      });
      polygons.union(otherpatch);
      polygons.union(_polygon);
      polygons.union(blurPatch);
      polygons.union(patch);
      cachedPolygon = polygons;
      return polygons;
    }
    return cachedPolygon.union(patch).union(otherpatch).union(blurPatch);
  }

  land combinedMarker = land();

  @override
  void initState() {
    //createRooms(widget.poly, SingletonFunctionController.building.floor[buildingAllApi.getStoredString()]!.floor()??0);
    super.initState();
    renderData();
  }

  renderData() async {
    await renderpatchData();
    await renderpolylineData();
    await renderGlobalAnnotation();
    callMarkers();
  }

  renderpatchData() async {
    widget.buildingData.patchData.forEach((key, value) {
      createPatch(value);
    });
  }

  renderpolylineData() async {
    widget.buildingData.polylinedatamap.forEach((key, value) {
      createRooms(
          value,
          SingletonFunctionController
                  .building.floor[buildingAllApi.getStoredString()]!
                  .floor() ??
              0);
    });
  }

  renderGlobalAnnotation() async {
    closedpolygons[Building.GlobalAnnotation!.mappingElements!.first.buildingID!] = await globalRendering(Building.GlobalAnnotation!,null)??Set();
  }


  callMarkers() async {
    SingletonFunctionController.building.landmarkdata!.then((value) {
      createMarkers(value, 0);
    });
  }

  @override
  void dispose() {
    _controller12?.stop();
    _controller12?.dispose();
    _controller12 = null;
    _googleMapController.dispose();
    super.dispose();
  }

  String closestBuildingId = "";
  void createPatch(patchDataModel value) async {
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
        zoom: 21,
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
      SingletonFunctionController.building
          .ARCoordinates[buildingAllApi.selectedBuildingID] = coordinates;
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
        cachedPolygon.clear();
      });
      try {
        fitPolygonInScreen(patch.first);
      } catch (e) {}
    }
  }

  Set<Marker> getCombinedMarkers() {
    Set<Marker> combinedMarkers = Set();
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

    // Always union the general Markers set at the end
    if (SingletonFunctionController.building.floor[user.bid] == user.floor) {
      markers.forEach((key, value) {
        combinedMarkers = combinedMarkers.union(Set<Marker>.of(value));
      });
    }
    return combinedMarkers;
  }

  Set<Polygon> cachedPolygon = {};
  Set<Marker> restBuildingMarker = Set();
  Future<void> zoomWhileWait(
      Map<String, LatLng> allBuildingID, GoogleMapController controller) async {
    print("allbuilding id ${allBuildingID}");
    print("else");
    print(patch.length);
    print(widget.buildingData.polylinedatamap.keys);
    print(widget.buildingData.patchData.keys);
    if (patch.isNotEmpty) {
      fitPolygonInScreen(patch.first);
    }

    // if (allBuildingID.length > 1) {
    //   print("inif");
    //   while (!SingletonFunctionController.building.destinationQr && !user.initialallyLocalised && !SingletonFunctionController.building.qrOpened) {
    //     for (var entry in allBuildingID.entries) {
    //       if (SingletonFunctionController.building.destinationQr || user.initialallyLocalised || SingletonFunctionController.building.qrOpened) {
    //         return;
    //       }
    //       await controller.animateCamera(CameraUpdate.newCameraPosition(
    //         CameraPosition(target: entry.value, zoom: 16),
    //       ));
    //       if (SingletonFunctionController.building.destinationQr || user.initialallyLocalised || SingletonFunctionController.building.qrOpened) {
    //         return;
    //       }
    //       await Future.delayed(Duration(milliseconds: 500));
    //       if (SingletonFunctionController.building.destinationQr || user.initialallyLocalised || SingletonFunctionController.building.qrOpened) {
    //         return;
    //       }
    //       await controller.animateCamera(CameraUpdate.newCameraPosition(
    //         CameraPosition(target: entry.value, zoom: 20),
    //       ));
    //       if (SingletonFunctionController.building.destinationQr ||
    //           user.initialallyLocalised ||
    //           SingletonFunctionController.building.qrOpened) {
    //         return;
    //       }
    //       await Future.delayed(Duration(seconds: 3));
    //       if (SingletonFunctionController.building.destinationQr ||
    //           user.initialallyLocalised ||
    //           SingletonFunctionController.building.qrOpened) {
    //         return;
    //       }
    //       // await controller.animateCamera(CameraUpdate.newCameraPosition(
    //       //   CameraPosition(target: entry.value, zoom: 16),
    //       // ));
    //       if (SingletonFunctionController.building.destinationQr ||
    //           user.initialallyLocalised ||
    //           SingletonFunctionController.building.qrOpened) {
    //         return;
    //       }
    //     }
    //
    //     // Check the conditions before starting the next loop iteration
    //     if (user.initialallyLocalised ||
    //         SingletonFunctionController.building.qrOpened) {
    //       return; // Exit the function if conditions are met
    //     }
    //   }
    // } else {
    //   print("else");
    //   if (patch.isNotEmpty) {
    //     fitPolygonInScreen(patch.first);
    //   }
    // }
  }

  Future<typed_data.Uint8List> getImagesFromMarker(
      String path, int width) async {
    typed_data.ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> moveCameraSmoothly({
    required GoogleMapController controller,
    required CameraPosition targetPosition,
    required LatLng currTarget,
    Duration duration = const Duration(milliseconds: 100),
    int steps = 50,
  }) async {
    print("runnningggg");
    // Get the current camera position
    final LatLng currentTarget;
    if (tappedPolygonCoordinates.isNotEmpty) {
      currentTarget =
          tools.calculateRoomCenterinLatLng(tappedPolygonCoordinates);
    } else {
      currentTarget = currTarget;
    }
    // Assume the current zoom level
    double currentZoom = await controller.getZoomLevel();
    // Extract details for interpolation
    final double latIncrement =
        (targetPosition.target.latitude - currentTarget.latitude) / steps;
    final double lngIncrement =
        (targetPosition.target.longitude - currentTarget.longitude) / steps;
    final double zoomIncrement = (targetPosition.zoom - currentZoom) / steps;
    // Gradually update camera position
    for (int i = 1; i <= steps; i++) {
      final LatLng intermediateTarget = LatLng(
        currentTarget.latitude + (latIncrement * i),
        currentTarget.longitude + (lngIncrement * i),
      );
      final double intermediateZoom = currentZoom + (zoomIncrement * i);
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: intermediateTarget,
            zoom: intermediateZoom,
          ),
        ),
      );

      // Add a delay between each step
      await Future.delayed(duration ~/ steps);
    }
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

  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
  }

  PolygonId matchPolygonId = PolygonId("");
  List<LatLng> matchPolygonPoints = [];
  AnimationController? _controller12;
  Animation<double>? _sizeAnimation;
  List<LatLng> tappedPolygonCoordinates = [];
  Future<void> addselectedRoomMarker(List<LatLng> polygonPoints,
      {Color? color}) async {
    selectedroomMarker.clear(); // Clear existing markers
    matchPolygonId = PolygonId("$polygonPoints");
    matchPolygonPoints = polygonPoints;
    _polygon.clear(); // Clear existing markers
    _polygon.add(Polygon(
      polygonId: PolygonId("$polygonPoints"),
      points: polygonPoints,
      fillColor: color != null
          ? color.withOpacity(0.4)
          : Colors.lightBlueAccent.withOpacity(0.4),
      strokeColor: color ?? Colors.blue,
      strokeWidth: 2,
    ));
    cachedPolygon.clear(); // Clear existing markers

    List<geo.LatLng> points = [];
    for (var e in polygonPoints) {
      points.add(geo.LatLng(e.latitude, e.longitude));
    }
    Uint8List iconMarker =
        await getImagesFromMarker('assets/IwaymapsDefaultMarker.png', 140);
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

  void _updateMarkers(double zoom) {
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
    _googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 0))
        .then((value) {
      return;
    });
  }

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

      setState(() {
        _areMarkersLoading = false;
      });
    }
  }

  List<PolyArray> findLift(String floor, List<Floors> floorData) {
    List<PolyArray> lifts = [];
    floorData.forEach((Element) {
      if (Element.floor == floor) {
        Element.polyArray!.forEach((element) {
          if (element.name!.toLowerCase().contains("lift")) {
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

  Future<void> createRooms(polylinedata value, int floor) async {
    if (closedpolygons[buildingAllApi.getStoredString()] == null) {
      closedpolygons[buildingAllApi.getStoredString()] = Set();
    }

    closedpolygons[value.polyline!.buildingID!]?.clear();

    // if (widget.directLandID.length < 2) {
    //   selectedroomMarker.clear();
    //   _isLandmarkPanelOpen = false;
    //   SingletonFunctionController.building.selectedLandmarkID = null;
    // }
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
          if (polyArray.visibilityType == "visible" &&
              polyArray.polygonType != "Waypoints") {
            List<LatLng> coordinates = [];
            for (Nodes node in polyArray.nodes!) {
              //coordinates.add(LatLng(node.lat!,node.lon!));
              coordinates.add(LatLng(
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
            } else if (polyArray.polygonType == 'Room') {
              print("polyArray.name");
              print(polyArray.name);
              if (polyArray.name!.toLowerCase().contains('lr') ||
                  polyArray.name!.toLowerCase().contains('lab') ||
                  polyArray.name!.toLowerCase().contains('office') ||
                  polyArray.name!.toLowerCase().contains('pantry') ||
                  polyArray.name!.toLowerCase().contains('reception')) {
                print("COntaining LA");
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
                        print("polyid::${polyArray.id}");
                        setState(() {
                          tappedPolygonCoordinates = coordinates;
                        });
                        moveCameraSmoothly(
                            controller: _googleMapController,
                            targetPosition: CameraPosition(
                                target: tools
                                    .calculateRoomCenterinLatLng(coordinates),
                                zoom: 22),
                            currTarget: LatLng(user.lat, user.lng));
                        setState(() {
                          if (SingletonFunctionController
                                  .building.selectedLandmarkID !=
                              polyArray.id) {
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
                            addselectedRoomMarker(coordinates);
                            Future.delayed(Duration(milliseconds: 500))
                                .then((onValue) {
                              Navigator.pop(
                                  context,
                                  SingletonFunctionController
                                      .building.selectedLandmarkID);
                            });
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
                        print("polyid::${polyArray.id}");
                        setState(() {
                          tappedPolygonCoordinates = coordinates;
                        });

                        moveCameraSmoothly(
                            controller: _googleMapController,
                            targetPosition: CameraPosition(
                                target: tools
                                    .calculateRoomCenterinLatLng(coordinates),
                                zoom: 22),
                            currTarget: LatLng(user.lat, user.lng));
                        setState(() {
                          if (SingletonFunctionController
                                  .building.selectedLandmarkID !=
                              polyArray.id) {
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

                            addselectedRoomMarker(coordinates);
                            Future.delayed(Duration(milliseconds: 500))
                                .then((onValue) {
                              Navigator.pop(
                                  context,
                                  SingletonFunctionController
                                      .building.selectedLandmarkID);
                            });
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
                        print("polyid::${polyArray.id}");
                        setState(() {
                          tappedPolygonCoordinates = coordinates;
                        });

                        moveCameraSmoothly(
                            controller: _googleMapController,
                            targetPosition: CameraPosition(
                                target: tools
                                    .calculateRoomCenterinLatLng(coordinates),
                                zoom: 22),
                            currTarget: LatLng(user.lat, user.lng));

                        setState(() {
                          if (SingletonFunctionController
                                  .building.selectedLandmarkID !=
                              polyArray.id) {
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
                            addselectedRoomMarker(coordinates);
                            Future.delayed(Duration(milliseconds: 500))
                                .then((onValue) {
                              Navigator.pop(
                                  context,
                                  SingletonFunctionController
                                      .building.selectedLandmarkID);
                            });
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
                        print("polyid::${polyArray.id}");
                        setState(() {
                          tappedPolygonCoordinates = coordinates;
                        });
                        moveCameraSmoothly(
                            controller: _googleMapController,
                            targetPosition: CameraPosition(
                                target: tools
                                    .calculateRoomCenterinLatLng(coordinates),
                                zoom: 22),
                            currTarget: LatLng(user.lat, user.lng));
                        setState(() {
                          if (SingletonFunctionController
                                  .building.selectedLandmarkID !=
                              polyArray.id) {
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
                            addselectedRoomMarker(coordinates,
                                color: Colors.greenAccent);
                            Future.delayed(Duration(milliseconds: 500))
                                .then((onValue) {
                              Navigator.pop(
                                  context,
                                  SingletonFunctionController
                                      .building.selectedLandmarkID);
                            });
                          }
                        });
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
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: Color(0xFFE7F4FE),
                      onTap: () {
                        print("polyid::${polyArray.id}");
                        setState(() {
                          tappedPolygonCoordinates = coordinates;
                        });
                        moveCameraSmoothly(
                            controller: _googleMapController,
                            targetPosition: CameraPosition(
                                target: tools
                                    .calculateRoomCenterinLatLng(coordinates),
                                zoom: 22),
                            currTarget: LatLng(user.lat, user.lng));
                        setState(() {
                          if (SingletonFunctionController
                                  .building.selectedLandmarkID !=
                              polyArray.id) {
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

                            addselectedRoomMarker(coordinates,
                                color: Colors.white);
                            Future.delayed(Duration(milliseconds: 500))
                                .then((onValue) {
                              Navigator.pop(
                                  context,
                                  SingletonFunctionController
                                      .building.selectedLandmarkID);
                            });
                          }
                        });
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
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: Color(0xFFE7F4FE),
                      onTap: () {
                        print("polyid::${polyArray.id}");
                        setState(() {
                          tappedPolygonCoordinates = coordinates;
                        });
                        moveCameraSmoothly(
                            controller: _googleMapController,
                            targetPosition: CameraPosition(
                                target: tools
                                    .calculateRoomCenterinLatLng(coordinates),
                                zoom: 22),
                            currTarget: LatLng(user.lat, user.lng));
                        setState(() {
                          if (SingletonFunctionController
                                  .building.selectedLandmarkID !=
                              polyArray.id) {
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
                            addselectedRoomMarker(coordinates,
                                color: Colors.white);
                            Future.delayed(Duration(milliseconds: 500))
                                .then((onValue) {
                              Navigator.pop(
                                  context,
                                  SingletonFunctionController
                                      .building.selectedLandmarkID);
                            });
                          }
                        });
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
                          : Color(0xffF21D0D),
                      onTap: () {}));
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
          }
        }
      }
    });
    cachedPolygon.clear();
    return;
  }

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

  void createMarkers(land _landData, int floor, {String? bid}) async {
    // _markers.clear();
    // _markerLocationsMap.clear();
    // _markerLocationsMapLanName.clear();
    // Markers.removeWhere((marker) => marker.markerId.value
    //     .contains(bid ?? buildingAllApi.selectedBuildingID));
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

            String markerText;
            List<String> parts = landmarks[i].name!.split('-');
            markerText = parts.isNotEmpty ? parts[0].trim() : '';
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/Classroom.png',
                imageSize: const Size(95, 95), color: Color(0xff544551));

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
            String markerText;
            List<String> parts = landmarks[i].name!.split('-');
            markerText = parts.isNotEmpty ? parts[0].trim() : '';
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/cutlery.png',
                imageSize: const Size(95, 95), color: Color(0xfffb8c00));

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

            String markerText;
            List<String> parts = landmarks[i].name!.split('-');
            markerText = parts.isNotEmpty ? parts[0].trim() : '';
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/ATM.png',
                imageSize: const Size(100, 100), color: Color(0xffd32f2f));

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

            String markerText;
            List<String> parts = landmarks[i].name!.split('-');
            markerText = parts.isNotEmpty ? parts[0].trim() : '';
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/Consultation Room.png',
                imageSize: const Size(85, 85), color: Color(0xff544551));

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

            String markerText;
            List<String> parts = landmarks[i].name!.split('-');
            markerText = parts.isNotEmpty ? parts[0].trim() : '';
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/Office.png',
                imageSize: const Size(85, 85), color: Color(0xff544551));

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
            String markerText;
            List<String> parts = landmarks[i].name!.split('-');
            markerText = parts.isNotEmpty ? parts[0].trim() : '';
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/Generic Marker.png',
                imageSize: const Size(85, 85));
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
        }
      }
    } catch (e) {}
    setState(() {
      // Markers.add(Marker(
      //   markerId: MarkerId("Building marker"),
      //   position: _initialCameraPosition.target,
      //   icon: BitmapDescriptor.defaultMarker,
      //   visible: false,
      // ));
    });
  }

  void focusBuildingChecker(CameraPosition position) {
    blurPatch.clear();
    restBuildingMarker.clear();
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

    // Store the nearest SingletonFunctionController.building ID
    if (closestBuildingId.isNotEmpty) {
      buildingAllApi.setStoredString(closestBuildingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4, // Adds elevation for a shadow effect
        shadowColor: Colors.black.withOpacity(0.5), // Shadow color with opacity
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose ${(widget.destiPoint) ? "Destination" : "Starting"} Point",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4), // Spacing between texts
            Text(
              "Pan and zoom to select",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              padding: EdgeInsets.only(left: 20), // <--- padding added here
              initialCameraPosition: _initialCameraPosition,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
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
              polygons: getCombinedPolygons(),
              markers: getCombinedMarkers()
                  .union(_markers)
                  .union(focusturnArrow)
                  .union(Markers)
                  .union(restBuildingMarker),
              buildingsEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: true,
              minMaxZoomPreference: MinMaxZoomPreference(2, 30),
              onMapCreated: (controller) {
                controller.setMapStyle(maptheme);
                _googleMapController = controller;
                zoomWhileWait(buildingAllApi.allBuildingID, controller);
              },
              onCameraMove: (CameraPosition cameraPosition) {
                mapState.cameraposition = cameraPosition;
                if (cameraPosition.zoom > 16.8) {
                  focusBuildingChecker(cameraPosition);
                }

                if (cameraPosition.target.latitude.toStringAsFixed(5) != mapState.target.latitude.toStringAsFixed(5)) {
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
              onCameraIdle: () {},
              onCameraMoveStarted: () {
                user.building = SingletonFunctionController.building;
                mapState.interaction2 = false;
              },
            ),
          ),
          //debug----
          Positioned(
            bottom: 300.0, // Adjust the position as needed
            right: 16.0,
            child: Semantics(
              label: "Change floor",
              child: SpeedDial(
                child: Text(
                  SingletonFunctionController.building.floor == 0
                      ? 'G'
                      : '${SingletonFunctionController.building.floor[buildingAllApi.getStoredString()]}',
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 20,
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
                    List<int> floorList = Building.numberOfFloorsDelhi[
                            buildingAllApi.getStoredString()] ??
                        [0];
                    List<int> revfloorList = floorList;
                    revfloorList.sort();
                    return SpeedDialChild(
                      child: Semantics(
                        label: "${revfloorList[i]}",
                        child: Text(
                          revfloorList[i] == 0 ? 'G' : '${revfloorList[i]}',
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
                        cachedPolygon.clear();
                        _markers.clear();
                        _markerLocationsMap.clear();
                        _markerLocationsMapLanName.clear();
                        SingletonFunctionController.building.floor[buildingAllApi.getStoredString()] = revfloorList[i];
                        createRooms(
                          SingletonFunctionController.building.polylinedatamap[
                              buildingAllApi.getStoredString()]!,
                          SingletonFunctionController.building
                              .floor[buildingAllApi.getStoredString()]!,
                        );
                        if (pathMarkers[i] != null) {
                          //setCameraPosition(pathMarkers[i]!);
                        }
                        // Markers.clear();
                        SingletonFunctionController.building.landmarkdata!
                            .then((value) {
                          createMarkers(
                              value,
                              SingletonFunctionController.building
                                  .floor[buildingAllApi.getStoredString()]!,
                              bid: buildingAllApi.getStoredString());
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
