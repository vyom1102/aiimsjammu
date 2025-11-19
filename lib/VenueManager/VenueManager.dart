import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/API/DataVersionApiNewForRepo.dart';
import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/DataVersion.dart';
import '../APIMODELS/landmark.dart';
import '../APIMODELS/patchDataModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/response.dart';
import '../Repository/RepositoryManager.dart';
import '../navigationTools.dart';
import 'BuildingStore.dart';

class VenueManager extends BuildingStore{

  VenueManager._internal();

  // Single instance - lazily initialized
  static final VenueManager _instance = VenueManager._internal();

  // Factory constructor returns the same instance
  factory VenueManager() {
    return _instance;
  }

  String _venueName = "KEM Hospital";
  BuildingData? _buildings;

  String get venueName => _venueName;

  set venueName(String value) {
    _venueName = value;
  }

  BuildingData? get buildings {
    return _buildings;
  }

  set buildings(BuildingData? value) {
    _buildings = value;
  }

  void changeFocusedBuilding(CameraPosition position){
    String? bid;
    double minimumDistance = double.infinity;
    if(_buildings?.buildings == null) return;
    for (var building in _buildings!.buildings!) {
      double distance = tools.calculateAerialDist(position.target.latitude, position.target.longitude, building.coordinates![0], building.coordinates![1]);
      if(distance < minimumDistance){
        minimumDistance = distance;
        bid = building.id;
      }
    }
    if(focusedBuilding != bid){
      focusedBuilding = bid;
      notifyListeners();
    }
  }

  Future<polylinedata?> getPolylinePolygonData(String buildingID) async {
      polylinedata? buildingData = await RepositoryManager().getPolylineDataNew(buildingID);
      return buildingData;
  }

  Future<List<dynamic>?> getBeaconDataAllBuildings() async {
    if(buildings?.buildings == null || buildings!.buildings!.isEmpty) return null;
    List<dynamic> beaconData = [];
    for(var building in buildings!.buildings!){
      List<dynamic> buildingData = await RepositoryManager().getBeaconDataNew(building.id);
      if(buildingData != null){
          beaconData.addAll(buildingData);
      }
    }
    print("beaconData $beaconData");
    return beaconData;
  }


  Future<List<polylinedata>?> getPolylinePolygonDataAllBuildings() async {
    print("polylinedata buildings $buildings");
    if(buildings?.buildings == null || buildings!.buildings!.isEmpty) return null;
    List<polylinedata> data = [];
    for (var building in buildings!.buildings!) {
      polylinedata? buildingData = await getPolylinePolygonData(building.id);
      if(buildingData != null) {
        data.add(buildingData);
      }
    }
    processAvailableFloors(data);
    return data;
  }

  Future<patchDataModel?> getPatchData(String buildingID) async {
      patchDataModel? buildingData = await RepositoryManager().getPatchDataNew(buildingID);
      return buildingData;
  }

  Future<List<patchDataModel>?> getPatchDataAllBuildings() async {
    print("patchDataModel buildings $buildings");
    if(buildings?.buildings == null || buildings!.buildings!.isEmpty) return null;
    List<patchDataModel> data = [];
    for (var building in buildings!.buildings!) {
      patchDataModel? buildingData = await getPatchData(building.id);
      if(buildingData != null){
        data.add(buildingData);
      }
    }
    return data;
  }

  Future<land?> getLandmarkData(String buildingID) async {
      land? buildingData = await RepositoryManager().getLandmarkDataNew(buildingID);
      return buildingData;
  }

  Future<List<land>?> getLandmarkDataAllBuildings() async {
    print("land buildings $buildings");
    if(buildings?.buildings == null || buildings!.buildings!.isEmpty) return null;
    List<land> data = [];
    for (var building in buildings!.buildings!) {
      land? buildingData = await getLandmarkData(building.id);
      if(buildingData != null){
        data.add(buildingData);
      }
    }
    return data;
  }

  Future<void> runDataVersionCycle() async {
    print("runDataVersionCycle $buildings");
    List<DataVersionModel>? dataVersion = await DataVersionapiNewForRepo().fetchDataVersion(_venueName);
    if(buildings?.buildings == null || buildings!.buildings!.isEmpty){
     await RepositoryManager().loadBuildings().then((_) async {
       print("Buildign was empty");
       for (var building in buildings!.buildings!) {
         var data = dataVersion?.where((dataV)=>dataV.buildingID == building.id);
         if(data != null && data.isNotEmpty){
           var obj = {
             "status": true,
             "versionData": data.first.toJson()
           };
           Response dataVersionData = Response(200, obj);
           await RepositoryManager().runAPICallDataVersion(building.id, dataVersionDataFromAPI: dataVersionData);
         }else{
           await RepositoryManager().runAPICallDataVersion(building.id);
         }
       }
       var data = dataVersion?.where((dataV)=>dataV.buildingID == buildings!.campus!.id);
       if(data != null && data.isNotEmpty){
         var obj = {
           "status": true,
           "versionData": data.first.toJson()
         };
         Response dataVersionData = Response(200, obj);
         await RepositoryManager().runAPICallDataVersion(buildings!.campus!.id, dataVersionDataFromAPI: dataVersionData);
       }else{
         await RepositoryManager().runAPICallDataVersion(buildings!.campus!.id);
       }
       RepositoryManager().startDataFechFromServerCycle();
     });
    }else {
      for (var building in buildings!.buildings!) {
        var data = dataVersion?.where((dataV)=>dataV.buildingID == building.id);
        if(data != null && data.isNotEmpty){
          var obj = {
            "status": true,
            "versionData": data.first.toJson()
          };
          Response dataVersionData = Response(200, obj);
          await RepositoryManager().runAPICallDataVersion(building.id, dataVersionDataFromAPI: dataVersionData);
        }else{
          await RepositoryManager().runAPICallDataVersion(building.id);
        }
      }
      var data = dataVersion?.where((dataV)=>dataV.buildingID == buildings!.campus!.id);
      if(data != null && data.isNotEmpty){
        var obj = {
          "status": true,
          "versionData": data.first.toJson()
        };
        Response dataVersionData = Response(200, obj);
        await RepositoryManager().runAPICallDataVersion(buildings!.campus!.id, dataVersionDataFromAPI: dataVersionData);
      }else{
        await RepositoryManager().runAPICallDataVersion(buildings!.campus!.id);
      }
      RepositoryManager().startDataFechFromServerCycle();
    }
  }

  // Future<void> runDataVersionCycle() async {
  //   print("runDataVersionCycle $buildings");
  //   if(buildings?.buildings == null || buildings!.buildings!.isEmpty){
  //     await RepositoryManager().loadBuildings().then((_) async {
  //       print("Buildign was empty");
  //       for (var building in buildings!.buildings!) {
  //         await RepositoryManager().runAPICallDataVersion(building.id);
  //       }
  //       RepositoryManager().startDataFechFromServerCycle();
  //     });
  //   }else {
  //     for (var building in buildings!.buildings!) {
  //       await RepositoryManager().runAPICallDataVersion(building.id);
  //     }
  //     RepositoryManager().startDataFechFromServerCycle();
  //   }
  // }

}