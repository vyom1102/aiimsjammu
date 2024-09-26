import 'dart:collection';

import 'APIMODELS/beaconData.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';

class Building{
  Map<String,int> floor;
  Map<String,int> numberOfFloors;
  Map<String,Map<int, List<int>>> nonWalkable = Map();

  Map<String,Map<int,List<int>>> floorDimenssion = Map();

  polylinedata? polyLineData = null;
  Map<String,polylinedata> polylinedatamap = Map();
    Future<land>? landmarkdata = null;
  List<beacon>? beacondata = null;
  String? selectedLandmarkID = null;
  Map<String,patchDataModel> patchData = Map();
  bool updateMarkers = true;
  List<String> ignoredMarker = [];
  static HashMap<String, beacon> apibeaconmap = HashMap();
  static String thresh = "";
  Building({required this.floor,required this.numberOfFloors});


  void dispose() {
    // Clear maps and lists to free memory
    nonWalkable.clear();
    floorDimenssion.clear();
    polylinedatamap.clear();
    patchData.clear();
    ignoredMarker.clear();
    ARCoordinates.clear();

    // Nullify future, lists, and other objects to remove references
    polyLineData = null;
    landmarkdata = null;
    beacondata = null;
    selectedLandmarkID = null;

    // Static fields should only be cleared if necessary; otherwise, leave them
    // buildingData = null;  // If you want to clear the static data

    // You don't need to explicitly free primitive types (like bool, int, etc.), as they will be automatically cleaned by Dart's garbage collector.

    print("Building object disposed.");
  }


}
