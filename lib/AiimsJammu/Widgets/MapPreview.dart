
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:navigation_sdk/navigation_sdk.dart';
import 'package:unified_map_view/unified_map_view.dart';
import 'package:unified_map_view/maplibre.dart';
import '../../API/PolyLineApi.dart';
import '../../APIMODELS/GlobalAnnotationModel.dart';
import '../../APIMODELS/landmark.dart';
import '../../APIMODELS/patchDataModel.dart';
import '../../APIMODELS/polylinedata.dart';
import '../../GlobalAnnotation/global_rendering.dart';
import '../../Navigation.dart';
import '../../config.dart';
import '../../navigationTools.dart';
import '../../singletonClass.dart';

class MapPreview extends StatefulWidget {

  MapPreview(this.polylineData, this.landmarkData, this.patchdata, this.globalData);

  List<dynamic> polylineData = [];
  List<dynamic> landmarkData = [];
  List<dynamic> patchdata = [];
  GlobalModel? globalData;

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  LatLng _center =
  const LatLng(32.5637551,
      75.0341691);

  var _initialCameraPosition = CameraPosition(
    target: LatLng(28.5450,
        77.1926),
    zoom: 0,
  );

  late GoogleMapController _googleMapController;

  Map<String, Set<Polygon>> closedpolygons = Map();

  Map<String, Set<gmap.Polyline>> polylines = Map();

  Set<Polygon> patch = Set();

  String maptheme = "";


  Future<void> createRooms(polylinedata value, int floor) async {
    List<PolyArray>? FloorPolyArray = value.polyline!.floors![0].polyArray;
    for (int j = 0; j < value.polyline!.floors!.length; j++) {
      if (value.polyline!.floors![j].floor ==
          tools.numericalToAlphabetical(floor)) {
        FloorPolyArray = value.polyline!.floors![j].polyArray;
      }
    }

    if (FloorPolyArray != null) {
      for (PolyArray polyArray in FloorPolyArray) {
        if (polyArray.visibilityType == "visible" &&
            polyArray.polygonType != "Waypoints") {
          List<LatLng> coordinates = [];

          for (Nodes node in polyArray.nodes!) {
            coordinates.add(LatLng(node.lat!, node.lon!));
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
          } else if (polyArray.polygonType == 'Room' ) {
            print("polyArray.name");
            print(polyArray.name);

            if(polyArray.name!.toLowerCase().contains('lr') || polyArray.name!.toLowerCase().contains('lab') || polyArray.name!.toLowerCase().contains('office') || polyArray.name!.toLowerCase().contains('pantry') || polyArray.name!.toLowerCase().contains('reception')) {
              print("COntaining LA");
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Room ${polyArray
                            .id!}"),
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
                    }));
              }
            }else if(polyArray.name!.toLowerCase().contains('atm') || polyArray.name!.toLowerCase().contains('health')) {
              print("COntaining LA");
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Room ${polyArray
                            .id!}"),
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
                    }));
              }
            } else{
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Room ${polyArray
                            .id!}"),
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
                    }));
              }
            }
          } else if (polyArray.polygonType == 'Cubicle') {
            if (polyArray.cubicleName == "Green Area" ||
                polyArray.cubicleName == "Green Area | Pots" || polyArray.name!.toLowerCase().contains('auditorium') || polyArray.name!.toLowerCase().contains('basketball') || polyArray.name!.toLowerCase().contains('cricket') || polyArray.name!.toLowerCase().contains('football') || polyArray.name!.toLowerCase().contains('gym') || polyArray.name!.toLowerCase().contains('swimming') || polyArray.name!.toLowerCase().contains('tennis')) {
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
                    onTap: () {

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
                      _googleMapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          tools.calculateRoomCenterinLatLng(coordinates),
                          22,
                        ),
                      );
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
                      _googleMapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          tools.calculateRoomCenterinLatLng(coordinates),
                          22,
                        ),
                      );
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
    setState(() {});
    return;
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
              zIndex:-1),
        );
      });

      try {
        fitPolygonInScreen(patch.first);
      } catch (e) {}
    }
  }

  void createARPatch(land landmarkData) async {
    var coordinates = <int, LatLng>{};
    for(var landmark in landmarkData.landmarks!){
      if (landmark.element!.subType == "AR") {
        coordinates[int.parse(landmark.properties!.arValue!)] = LatLng(
            double.parse(landmark.properties!.latitude!),
            double.parse(landmark.properties!.longitude!));
      }
    }
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
        //patch.clear();
        patch.add(
          Polygon(
              polygonId: PolygonId('patch${landmarkData.landmarks}'),
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

  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              mapToolbarEnabled: false,
              buildingsEnabled: false,
              onMapCreated: (controller) async {
                DefaultAssetBundle.of(context)
                    .loadString("assets/mapstyle.json")
                    .then((value) {
                  controller.setMapStyle(value);
                });
                _googleMapController = controller;
                for (var polylineData in widget.polylineData) {
                  createRooms(polylineData, 0);
                }
                for (var patchData in widget.patchdata) {
                  //createPatch(patchData);
                }
                for (var landmarkData in widget.landmarkData) {
                  createARPatch(landmarkData);
                }
                if(widget.globalData != null){
                  // closedpolygons[widget.globalData!.mappingElements!.first.buildingID!] = await globalRendering(widget.globalData!)??Set();
                }
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 16.0,
              ),
              polygons: getpolygons(),
              polylines: getpolylines(),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                mini: true,
                // onPressed: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => Navigation(),
                //     ),
                //   );
                // },
                onPressed: () {
                  NavigationSDK.startNavigation(
                    context,
                    data: {"venueName": "AIIMSJAMMU"},
                    appColor: const Color(0xFFEC5B13),
                    closeApp: false,
                    locale: AppConfig.languageCode,
                    skipSplash: true,
                    mapType: MapProvider.mapLibre,
                    providers: {MapProvider.mapLibre: MaplibreMapProvider()},
                  );
                },
                child: Icon(
                  Icons.fullscreen,
                  color: Colors.black,
                ),
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Padding(
            //     padding: EdgeInsets.only(bottom: 0.0),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: Colors.black.withOpacity(0.3),
            //         borderRadius: BorderRadius.circular(8.0),
            //       ),
            //       padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            //       child: Text(
            //         'Long press to zoom in',
            //         style: TextStyle(color: Colors.white, fontSize: 14.0),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Set<Polygon> getpolygons() {
    Set<Polygon> polygons = Set();
    for(var polygon in closedpolygons.values){
      polygons = polygons.union(polygon);
    }
    return polygons.union(patch);
  }

  Set<gmap.Polyline> getpolylines() {
    Set<gmap.Polyline> funcpolylines = Set();
    for(var polyline in polylines.values){
      funcpolylines = funcpolylines.union(polyline);
    }
    return funcpolylines;
  }
}
