import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../APIMODELS/DataVersion.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/response.dart';
import '../DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '../DATABASE/DATABASEMODEL/BuildingByVenueMapAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DB2BeaconAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DB2BuildingByVenueMapAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DB2DataVersionLocalModel.dart';
import '../DATABASE/DATABASEMODEL/DB2GlobalAnnotationAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DB2LandMarkApiModel.dart';
import '../DATABASE/DATABASEMODEL/DB2PatchAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DB2PolyLineAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DB2WayPointModel.dart';
import '../DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '../DATABASE/DATABASEMODEL/GlobalAnnotationAPIModel.dart';
import '../DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import '../DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import '../DATABASE/DATABASEMODEL/VenueBeaconAPIModel.dart';
import '../DATABASE/DATABASEMODEL/WayPointModel.dart';
import '../DatabaseManager/DataBaseManager.dart';
import '../APIMODELS/Buildingbyvenue.dart';
import '../DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../DATABASE/DATABASEMODEL/OutDoorModel.dart';
import '../DatabaseManager/SwitchDataBase.dart';
import '../ELEMENTS/HelperClass.dart';
import '../Network/APIDetails.dart';
import '../Network/NetworkManager.dart';
import '../VenueManager/VenueManager.dart';
import '../VersioInfo.dart';

import '../VersionInfoSingleton.dart';
import '../waypoint.dart';

class RepositoryManager{

    static final RepositoryManager _instance = RepositoryManager._internal();

    factory RepositoryManager() {
        return _instance;
    }

    static bool _initialized = false;

    RepositoryManager._internal() {
        // ✅ This block runs only ONCE, when the singleton is first created
        loadBuildings();
    }

    NetworkManager networkManager = NetworkManager();
    DataBaseManager dataBaseManager = DataBaseManager();
    SwitchDataBase switchDataBase = SwitchDataBase();
    Apidetails apiDetails = Apidetails();
    bool shouldBeInjected = false;
    bool preLoadDataBaseCreated = false;

    Future<void> init() async {
        if (!_initialized) {
            await loadBuildings();
            _initialized = true;
        }
    }


    Future<void> loadBuildings() async {
        print("loadBuildings ${StackTrace.current}");
        BuildingData buildingData = await getBuildingByVenueNew(VenueManager().venueName);
        print("loadBuildings${buildingData.buildings}");
        VenueManager().buildings = buildingData;

    }

    Future<void> loadPreLoadedDataBase() async {
        print("runningloadPreLoadedDataBase");
        if(!preLoadDataBaseCreated) {
            print("runningloadPreLoadedDataBase1 ${VenueManager().buildings}");
            VenueManager().buildings!.buildings!.forEach((buildingByVenue) async {
                // print("CREATING DB1 FROM PRELOADED JSON");
                // Detail dataVersionDetail = apiDetails.dataVersion(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // print("JSON name ${dataVersionDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json");
                // String jsonStringDataVersion = await rootBundle.loadString('assets/PreLoads/${dataVersionDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                // final versionData = json.decode(jsonStringDataVersion);
                // final dataVersionData = DataVersionLocalModel(responseBody: versionData);
                // DataBaseManager().saveData(dataVersionData, dataVersionDetail, buildingByVenue.sId!);
                // print("CREATING DB1 DATA VERSION ${DataBaseManager().getDataBaseKeys(dataVersionDetail)}");


                // Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // // if (kDebugMode) print("${landmarkDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                // String jsonString = await rootBundle.loadString('assets/PreLoads/${landmarkDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                // final data = json.decode(jsonString);
                // final landmarkData = LandMarkApiModel(responseBody: data);
                // DataBaseManager().saveData(landmarkData, landmarkDetail, buildingByVenue.sId!);
                // print("CREATING DB1 LANDMARK ${DataBaseManager().getDataBaseKeys(landmarkDetail)}");

                // Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // // if (kDebugMode) print("${polylineDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                // String jsonStringPolyline = await rootBundle.loadString('assets/PreLoads/${polylineDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                // final dataPolyline = json.decode(jsonStringPolyline);
                // final polyLineData = PolyLineAPIModel(responseBody: dataPolyline);
                // DataBaseManager().saveData(polyLineData, polylineDetail, buildingByVenue.sId!);
                // print("CREATING DB1 POLYLINE ${DataBaseManager().getDataBaseKeys(polylineDetail)}");


                // Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // // if (kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                // String jsonStringPatch = await rootBundle.loadString('assets/PreLoads/${patchDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                // final dataPatch = json.decode(jsonStringPatch);
                // final patchData = PatchAPIModel(responseBody: dataPatch);
                // DataBaseManager().saveData(patchData, patchDetail, buildingByVenue.sId!);
                // print("CREATING DB1 PATCH ${DataBaseManager().getDataBaseKeys(patchDetail)}");


                // Detail beaconDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // // if (kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                // String jsonStringbeacon = await rootBundle.loadString('assets/PreLoads/${beaconDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                // final databeacon = json.decode(jsonStringbeacon);
                // final beaconData = PatchAPIModel(responseBody: databeacon);
                // DataBaseManager().saveData(beaconData, beaconDetail, buildingByVenue.sId!);
                // print("BEACON ${DataBaseManager().getDataBaseKeys(beaconDetail)}");


                // Detail waypointDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // // if (kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                // String jsonStringwaypoint = await rootBundle.loadString('assets/PreLoads/${waypointDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                // final dataWaypoint= json.decode(jsonStringwaypoint);
                // final waypointData = PatchAPIModel(responseBody: dataWaypoint);
                // DataBaseManager().saveData(waypointData, waypointDetail, buildingByVenue.sId!);
                // print("WAYPOINT ${DataBaseManager().getDataBaseKeys(waypointDetail)}");
                // preLoadDataBaseCreated = true;
            });
        }else{
            print("DB1 ALREADY CREATED FROM PRELOADED JSON");
        }
        VenueManager().runDataVersionCycle();
    }


    Future<dynamic> getDataVersionDatanew(String bID) async {
        Detail dataVersionDetails = await apiDetails.dataVersion(await dataBaseManager.getAccessToken()!, bID);
        if(SwitchDataBase().isGreenDataBaseActive()){
            if(kDebugMode) print("${dataVersionDetails.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            DataVersionLocalModel responseFromDatabase = DataBaseManager().getData(dataVersionDetails, bID);
            return dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
        }else{
            if(kDebugMode) print("${dataVersionDetails.getPreLoadPrefix} DATA FROM BLUE DATABASE");
            DataVersionLocalModel responseFromDatabase = DataBaseManager().getDataDB2(dataVersionDetails, bID);
            return dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
        }
    }

    Future<void> startDataFechFromServerCycle() async {
        if(SwitchDataBase().newDataFromServerDBShouldBeCreated){
            await updateNewDB().then((_){
                print("updateNewDB after called");
                var switchBox = Hive.box('SwitchingDatabaseInfo');
                SwitchDataBase().switchGreenDataBase(!switchBox.get('greenDataBase'));
                SwitchDataBase().newDataFromServerDBShouldBeCreated = false;
                SwitchDataBase().newDataBuildings.clear();
                print("SwitchDataBase().switchDatabaseBox");
                print(SwitchDataBase().switchDatabaseBox);
                HelperClass.showToast("DataBase Updated");
            });
        }else{
            // HelperClass.showToast("No new Version Found");
            print("SwitchDataBase().newDataFromServerDBShouldBeCreated ${SwitchDataBase().newDataFromServerDBShouldBeCreated} NO CREATION OF DB2");
        }
    }

    Future<void> updateNewDB() async {
        print("updateNewDB ${StackTrace.current}");
        // if(SwitchDataBase().patchDataFromServerDBShouldBeCreated){
        //     print("UPDATING DATABASE FOR PATCH");
        //     for (var building in VenueManager().buildings) {
        //         await RepositoryManager().runAPICallPatchData(building.sId!);
        //     }
        // }
        //
        // if(SwitchDataBase().polylineDataFromServerDBShouldBeCreated){
        //     print("UPDATING DATABASE FOR POLYLINE");
        //     for (var building in VenueManager().buildings) {
        //         await RepositoryManager().runAPICallPolylineData(building.sId!);
        //         await RepositoryManager().runAPICallWaypointData(building.sId!);
        //     }
        // }
        //
        // if(SwitchDataBase().landmarkDataFromServerDBShouldBeCreated){
        //     print("UPDATING DATABASE FOR LANDMARK");
        //     for (var building in VenueManager().buildings) {
        //         await RepositoryManager().runAPICallLandmarkData(building.sId!);
        //         await RepositoryManager().runAPICallBeaconData(building.sId!);
        //     }
        // }

        for (var building in SwitchDataBase().newDataBuildings) {
            print("running for ${building}");
            print("running 1 ${DateTime.now()}");
            await RepositoryManager().runAPICallPatchData(building);
            print("running 2 ${DateTime.now()}");
            await RepositoryManager().runAPICallPolylineData(building);
            print("running 3 ${DateTime.now()}");
            await RepositoryManager().runAPICallLandmarkData(building);
            print("running 4 ${DateTime.now()}");
            await RepositoryManager().runAPICallBeaconData(building);
            print("running 5 ${DateTime.now()}");
            await RepositoryManager().runAPICallWaypointData(building);
            print("running 6 ${DateTime.now()}");
            await RepositoryManager().runAPICallGlobalAnnotationData(building);
            print("running 7 ${DateTime.now()}");

            // Space optimization CODE for FUTURE
            // if(VersionInfo.buildingPatchDataVersionUpdate.containsKey(building.sId) && VersionInfo.buildingPatchDataVersionUpdate[building.sId]==true){
            //   RepositoryManager().savePatchDataForDB2(building.sId!);
            // }
            // if(VersionInfo.buildingPolylineDataVersionUpdate.containsKey(building.sId) && VersionInfo.buildingPolylineDataVersionUpdate[building.sId]==true){
            //   RepositoryManager().savePolylineDataForDB2(building.sId!);
            // }
            // if(VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(building.sId) && VersionInfo.buildingLandmarkDataVersionUpdate[building.sId]==true){
            //   RepositoryManager().saveLandmarkDataForDB2(building.sId!);
            // }
        }
        // await RepositoryManager().runAPICallPatchData(VenueManager().buildings!.campus!.id);
        // await RepositoryManager().runAPICallGlobalAnnotationData(VenueManager().buildings!.campus!.id);
    }

    Future<dynamic> runAPICallDataVersion(String bID, {bool generateJSON = false, Response? dataVersionDataFromAPI})async{
        print("runAPICallDataVersion $bID $dataVersionDataFromAPI");
        Detail dataVersionDetails = await apiDetails.dataVersion(await dataBaseManager!.getAccessToken()!, bID);
        dataVersionDataFromAPI ??= await networkManager.api.request(dataVersionDetails);
        if(dataVersionDataFromAPI == null){
            return;
        }
        if(generateJSON){
            if(dataVersionDataFromAPI.statusCode == 200){
                final apiData = DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                DataBaseManager().saveData(apiData, dataVersionDetails, bID);
                if (generateJSON){
                    Map<String, dynamic> JSONresponseBody = dataVersionDataFromAPI.data;String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("DataVersion$bID", formattedJson);
                }
                if (kDebugMode) {
                    print("GENERATED JSON FOR DATA VERSION $bID");
                }
            }
        }else{
            if(dataVersionDataFromAPI.statusCode == 200){
                if(SwitchDataBase().isGreenDataBaseActive()) {
                    print("DB1 ACTIVE");
                    List<dynamic> dataBaseIDs = DataBaseManager().getDataBaseKeys(dataVersionDetails);

                    if(!dataBaseIDs.contains(bID)){
                        String jsonStringDataVersion = await rootBundle.loadString('assets/PreLoads/${dataVersionDetails.getPreLoadPrefix}${bID}.json');
                        final versionData = json.decode(jsonStringDataVersion);

                        final dataVersionData = DataVersionLocalModel(responseBody: versionData);
                        DataBaseManager().saveData(dataVersionData, dataVersionDetails, bID);
                        final dataVersionNewData = DB2DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                        DataBaseManager().saveDataDB2(dataVersionNewData, dataVersionDetails, bID);

                        DataVersion dataVersionJSONData = dataVersionDetails.conversionFunction(dataVersionData.responseBody);
                        DataVersion newDataFromAPI = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);

                        if(newDataFromAPI.versionData!.buildingDataVersion! > dataVersionJSONData.versionData!.buildingDataVersion!){
                            VersionInfoSingleton.previousBuildingDataVersion = VersionInfoSingleton.buildingDataVersion;
                            VersionInfoSingleton.buildingDataVersion = newDataFromAPI.versionData!.buildingDataVersion!;
                            SwitchDataBase().buildingByVenueDataDataFromServerDBShouldBeCreated = true;
                            print("BUILDING BY VENUE NEW DATA FOUND");
                            print("PATCH NEW");
                        }else{
                            VersionInfoSingleton.buildingDataVersion = dataVersionJSONData.versionData!.buildingDataVersion!;
                            SwitchDataBase().buildingByVenueDataDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.patchDataVersion! > dataVersionJSONData.versionData!.patchDataVersion!){
                            VersionInfoSingleton.previousPatchDataVersion = VersionInfoSingleton.patchDataVersion;
                            VersionInfoSingleton.patchDataVersion = newDataFromAPI.versionData!.patchDataVersion!;
                            SwitchDataBase().patchDataFromServerDBShouldBeCreated = true;
                            print("PATCH NEW DATA FOUND");
                        }else{
                            VersionInfoSingleton.patchDataVersion = dataVersionJSONData.versionData!.patchDataVersion!;
                            SwitchDataBase().patchDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.polylineDataVersion! > dataVersionJSONData.versionData!.polylineDataVersion!){
                            print("POLYLINE NEW DATA FOUND");
                            VersionInfoSingleton.previousPolylineDataVersion = VersionInfoSingleton.polylineDataVersion;
                            VersionInfoSingleton.polylineDataVersion = newDataFromAPI.versionData!.polylineDataVersion!;
                            SwitchDataBase().polylineDataFromServerDBShouldBeCreated = true;
                        }else{
                            VersionInfoSingleton.polylineDataVersion = dataVersionJSONData.versionData!.polylineDataVersion!;
                            SwitchDataBase().polylineDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.landmarksDataVersion! > dataVersionJSONData.versionData!.landmarksDataVersion!){
                            print("LANDMARK NEW DATA FOUND");
                            VersionInfoSingleton.previousLandmarksDataVersion = VersionInfoSingleton.landmarksDataVersion;
                            VersionInfoSingleton.landmarksDataVersion = newDataFromAPI.versionData!.landmarksDataVersion!;
                            SwitchDataBase().landmarkDataFromServerDBShouldBeCreated = true;
                        }else{
                            VersionInfoSingleton.landmarksDataVersion = dataVersionJSONData.versionData!.landmarksDataVersion!;
                            SwitchDataBase().landmarkDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.buildingDataVersion! > dataVersionJSONData.versionData!.buildingDataVersion! ||
                            newDataFromAPI.versionData!.patchDataVersion! > dataVersionJSONData.versionData!.patchDataVersion! ||
                            newDataFromAPI.versionData!.polylineDataVersion! > dataVersionJSONData.versionData!.polylineDataVersion! ||
                            newDataFromAPI.versionData!.landmarksDataVersion! > dataVersionJSONData.versionData!.landmarksDataVersion! ||
                            newDataFromAPI.versionData!.globalAnnotationVersion! > dataVersionJSONData.versionData!.globalAnnotationVersion!
                        ){
                            if (kDebugMode) {
                                print("Building ${dataVersionJSONData.versionData!.buildingDataVersion!} -> ${newDataFromAPI.versionData!.buildingDataVersion} ");
                                print("Patch ${dataVersionJSONData.versionData!.patchDataVersion!} ->  ${newDataFromAPI.versionData!.patchDataVersion}");
                                print("Polyline ${dataVersionJSONData.versionData!.polylineDataVersion!} -> ${newDataFromAPI.versionData!.polylineDataVersion} ");
                                print("Landmark ${dataVersionJSONData.versionData!.landmarksDataVersion!} -> ${newDataFromAPI.versionData!.landmarksDataVersion} ");
                                print("Global Annotation ${dataVersionJSONData.versionData!.globalAnnotationVersion!} -> ${newDataFromAPI.versionData!.globalAnnotationVersion} ");
                                print("DATA VERSION DATA FROM API STORING IN DB2");
                            }
                            SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                            SwitchDataBase().newDataBuildings.add(bID);
                            print("REQUESTING TO CREATE DB2");
                        }else{
                            print("Building ${dataVersionJSONData.versionData!.buildingDataVersion!} -> ${newDataFromAPI.versionData!.buildingDataVersion} ");
                            print("Patch ${dataVersionJSONData.versionData!.patchDataVersion!} ->  ${newDataFromAPI.versionData!.patchDataVersion}");
                            print("Polyline ${dataVersionJSONData.versionData!.polylineDataVersion!} -> ${newDataFromAPI.versionData!.polylineDataVersion} ");
                            print("Landmark ${dataVersionJSONData.versionData!.landmarksDataVersion!} -> ${newDataFromAPI.versionData!.landmarksDataVersion} ");
                            print("Global Annotation ${dataVersionJSONData.versionData!.globalAnnotationVersion!} -> ${newDataFromAPI.versionData!.globalAnnotationVersion} ");
                            print("DATA VERSION DATA FROM API NO NEW VERSION FOUND");
                        }
                        print("DATA VERSION DATA FROM JSON${DataBaseManager().getDataBaseKeys(dataVersionDetails)}");
                    }else{
                        DataVersionLocalModel responseFromDatabase = DataBaseManager().getData(dataVersionDetails, bID);
                        DataVersion DB1Data = dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
                        DataVersion newDataFromAPI = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);
                        final dataVersionNewData = DB2DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                        DataBaseManager().saveDataDB2(dataVersionNewData, dataVersionDetails, bID);

                        if(newDataFromAPI.versionData!.buildingDataVersion! > DB1Data.versionData!.buildingDataVersion!){
                            VersionInfoSingleton.previousBuildingDataVersion = VersionInfoSingleton.buildingDataVersion;
                            VersionInfoSingleton.buildingDataVersion = newDataFromAPI.versionData!.buildingDataVersion!;
                            SwitchDataBase().buildingByVenueDataDataFromServerDBShouldBeCreated = true;
                            print("BUILDING BY VENUE NEW DATA FOUND");
                        }else{
                            VersionInfoSingleton.buildingDataVersion = DB1Data.versionData!.buildingDataVersion!;
                            SwitchDataBase().buildingByVenueDataDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.patchDataVersion! > DB1Data.versionData!.patchDataVersion!){
                            VersionInfoSingleton.previousPatchDataVersion = VersionInfoSingleton.patchDataVersion;
                            VersionInfoSingleton.patchDataVersion = newDataFromAPI.versionData!.patchDataVersion!;
                            SwitchDataBase().patchDataFromServerDBShouldBeCreated = true;
                            print("PATCH NEW DATA FOUND");
                        }else{
                            VersionInfoSingleton.patchDataVersion = DB1Data.versionData!.patchDataVersion!;
                            SwitchDataBase().patchDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.polylineDataVersion! > DB1Data.versionData!.polylineDataVersion!){
                            print("POLYLINE NEW DATA FOUND");
                            VersionInfoSingleton.previousPolylineDataVersion = VersionInfoSingleton.polylineDataVersion;
                            VersionInfoSingleton.polylineDataVersion = newDataFromAPI.versionData!.polylineDataVersion!;
                            SwitchDataBase().polylineDataFromServerDBShouldBeCreated = true;
                        }else{
                            VersionInfoSingleton.polylineDataVersion = DB1Data.versionData!.polylineDataVersion!;
                            SwitchDataBase().polylineDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.landmarksDataVersion! > DB1Data.versionData!.landmarksDataVersion!){
                            print("LANDMARK NEW DATA FOUND");
                            VersionInfoSingleton.previousLandmarksDataVersion = VersionInfoSingleton.landmarksDataVersion;
                            VersionInfoSingleton.landmarksDataVersion = newDataFromAPI.versionData!.landmarksDataVersion!;
                            SwitchDataBase().landmarkDataFromServerDBShouldBeCreated = true;
                        }else{
                            VersionInfoSingleton.landmarksDataVersion = DB1Data.versionData!.landmarksDataVersion!;
                            SwitchDataBase().landmarkDataFromServerDBShouldBeCreated = false;
                        }

                        if(newDataFromAPI.versionData!.buildingDataVersion! > DB1Data.versionData!.buildingDataVersion! ||
                            newDataFromAPI.versionData!.patchDataVersion! > DB1Data.versionData!.patchDataVersion! ||
                            newDataFromAPI.versionData!.polylineDataVersion! > DB1Data.versionData!.polylineDataVersion! ||
                            newDataFromAPI.versionData!.landmarksDataVersion! > DB1Data.versionData!.landmarksDataVersion! ||
                            newDataFromAPI.versionData!.globalAnnotationVersion! > DB1Data.versionData!.globalAnnotationVersion!
                        ){
                            if (kDebugMode) {
                                print("Building ${DB1Data.versionData!.buildingDataVersion!} -> ${newDataFromAPI.versionData!.buildingDataVersion} ");
                                print("Patch ${DB1Data.versionData!.patchDataVersion!} -> ${newDataFromAPI.versionData!.patchDataVersion} ");
                                print("Polyline ${DB1Data.versionData!.polylineDataVersion!} -> ${newDataFromAPI.versionData!.polylineDataVersion} ");
                                print("Landmark ${DB1Data.versionData!.landmarksDataVersion!} -> ${newDataFromAPI.versionData!.landmarksDataVersion} ");
                                print("Global Annotation ${DB1Data.versionData!.globalAnnotationVersion!} -> ${newDataFromAPI.versionData!.globalAnnotationVersion} ");
                                print("DATA VERSION DATA FROM API STORING IN DB2");
                            }
                            SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                            SwitchDataBase().newDataBuildings.add(bID);
                            print("REQUESTING TO CREATE DB2");
                        }else{
                            print("Building ${DB1Data.versionData!.buildingDataVersion!} -> ${newDataFromAPI.versionData!.buildingDataVersion} ");
                            print("Patch ${DB1Data.versionData!.patchDataVersion!} -> ${newDataFromAPI.versionData!.patchDataVersion} ");
                            print("Polyline ${DB1Data.versionData!.polylineDataVersion!} -> ${newDataFromAPI.versionData!.polylineDataVersion} ");
                            print("Landmark ${DB1Data.versionData!.landmarksDataVersion!} -> ${newDataFromAPI.versionData!.landmarksDataVersion} ");
                            print("Global Annotation ${DB1Data.versionData!.globalAnnotationVersion!} -> ${newDataFromAPI.versionData!.globalAnnotationVersion} ");
                            print("DATA VERSION DATA FROM API NO NEW VERSION FOUND");
                        }
                    }
                }else{
                    print("DB2 ACTIVE");
                    var hardSwitch = false;
                    var responseFromDatabase = DataBaseManager().getDataDB2(dataVersionDetails, bID);
                    DataVersion? DB2Data;
                    if(responseFromDatabase == null){
                        hardSwitch = true;
                    }else{
                        DB2Data = dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
                    }
                    DataVersion newData = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);
                    final dataVersionNewData = DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                    DataBaseManager().saveData(dataVersionNewData, dataVersionDetails, bID);
                    if(hardSwitch || newData.versionData!.buildingDataVersion! > DB2Data!.versionData!.buildingDataVersion! ||
                        newData.versionData!.patchDataVersion! > DB2Data.versionData!.patchDataVersion! ||
                        newData.versionData!.polylineDataVersion! > DB2Data.versionData!.polylineDataVersion! ||
                        newData.versionData!.landmarksDataVersion! > DB2Data.versionData!.landmarksDataVersion! ||
                        newData.versionData!.globalAnnotationVersion! > DB2Data.versionData!.globalAnnotationVersion!
                    ){
                        if (kDebugMode) {
                            if(hardSwitch || DB2Data == null){
                                print("hardSwitch on data");
                                print("Building ${newData.versionData!.buildingDataVersion}");
                                print("Patch ${newData.versionData!.patchDataVersion}");
                                print("Polyline ${newData.versionData!.polylineDataVersion} ");
                                print("Landmark ${newData.versionData!.landmarksDataVersion} ");
                                print("Global Annotation ${newData.versionData!.globalAnnotationVersion} ");
                            }else{
                                print("Building ${DB2Data.versionData!.buildingDataVersion!} -> ${newData.versionData!.buildingDataVersion}");
                                print("Patch ${DB2Data.versionData!.patchDataVersion!} -> ${newData.versionData!.patchDataVersion}");
                                print("Polyline ${DB2Data.versionData!.polylineDataVersion!} -> ${newData.versionData!.polylineDataVersion} ");
                                print("Landmark ${DB2Data.versionData!.landmarksDataVersion!} -> ${newData.versionData!.landmarksDataVersion} ");
                                print("Global Annotation ${DB2Data.versionData!.globalAnnotationVersion!} -> ${newData.versionData!.globalAnnotationVersion} ");
                            }
                            print("DATA VERSION DATA FROM API STORING IN DB1");
                        }

                        SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                        SwitchDataBase().newDataBuildings.add(bID);
                        print("REQUESTING TO CREATE DB1");
                    }else{
                        print("Building ${DB2Data.versionData!.buildingDataVersion!} -> ${newData.versionData!.buildingDataVersion}");
                        print("Patch ${DB2Data.versionData!.patchDataVersion!} -> ${newData.versionData!.patchDataVersion}");
                        print("Polyline ${DB2Data.versionData!.polylineDataVersion!} -> ${newData.versionData!.polylineDataVersion} ");
                        print("Landmark ${DB2Data.versionData!.landmarksDataVersion!} -> ${newData.versionData!.landmarksDataVersion} ");
                        print("Global Annotation ${DB2Data.versionData!.globalAnnotationVersion!} -> ${newData.versionData!.globalAnnotationVersion} ");
                        print("DATA VERSION DATA FROM API NO NEW VERSION FOUND");
                    }
                }
            }
        }
    }

    Future<dynamic> getLandmarkDataNew(String bID) async {
        final detail = await apiDetails.landmark(await dataBaseManager.getAccessToken(), bID);
        final isGreen = SwitchDataBase().isGreenDataBaseActive();
        try {
            if (isGreen) {
                final keys = DataBaseManager().getDataBaseKeys(detail);
                if (!keys.contains(bID)) {
                    final jsonString = await rootBundle.loadString('assets/PreLoads/${detail.getPreLoadPrefix}$bID.json');
                    final data = json.decode(jsonString);
                    final model = LandMarkApiModel(responseBody: data);
                    DataBaseManager().saveData(model, detail, bID);
                    print("LANDMARK DATA FROM JSON");
                    return detail.conversionFunction(model.responseBody);
                } else {
                    final model = DataBaseManager().getData(detail, bID);
                    print("LANDMARK DATA FROM DB1");
                    return detail.conversionFunction(model.responseBody);
                }
            } else {
                final model = DataBaseManager().getDataDB2(detail, bID);
                print("LANDMARK DATA FROM DB2");
                return detail.conversionFunction(model.responseBody);
            }
        } catch (e) {
            print("LANDMARK DATA FALLBACK for $bID: $e");
            return await _fetchAndStoreFromAPI(detail, bID, isGreen);
        }
    }

    Future<dynamic> _fetchAndStoreFromAPI(Detail detail, String bID, bool isGreen) async {
        final response = await networkManager.api.request(detail);

        if (response.statusCode == 200) {
            final data = response.data;
            if (isGreen) {
                final model = LandMarkApiModel(responseBody: data);
                DataBaseManager().saveData(model, detail, bID);
                print("LANDMARK DATA STORED IN DB1 FROM API");
            } else {
                final model = DB2LandMarkApiModel(responseBody: data);
                DataBaseManager().saveDataDB2(model, detail, bID);
                print("LANDMARK DATA STORED IN DB2 FROM API");
            }

            return detail.conversionFunction(data);
        } else {
            print("API REQUEST FAILED: ${response.statusCode}");
            return null;
        }
    }

    //Purpose of either Generating JSON or API Call and Storing into Respected DB
    Future<dynamic> runAPICallLandmarkData(String bID,{bool generateJSON = false}) async {
        Detail landmarkDetail = apiDetails.landmark(await dataBaseManager.getAccessToken(), bID);
        print("dataFromAPI.data.runtimeType initial${bID}");

        Response dataFromAPI = await networkManager.api.request(landmarkDetail);

        print("dataFromAPI.data.runtimeType");
        print(dataFromAPI.data.runtimeType);
        if(generateJSON){
            final landmarkData = LandMarkApiModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(landmarkData, landmarkDetail, bID);
            if(generateJSON) {
                print("JSONresponseBody");
                Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                HelperClass().saveJsonToAndroidDownloads("Landmark$bID", formattedJson);
            }
            if (kDebugMode) {
                print("GENERATED JSON FOR LANDMARK $bID");
            }
        }else{
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final patchData = DB2LandMarkApiModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(patchData, landmarkDetail, bID);
                    print("LANDMARK DATA FROM API STORED IN DB2");
                }else{
                    final patchData = LandMarkApiModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(patchData, landmarkDetail, bID);
                    print("LANDMARK DATA FROM API STORED IN DB1");
                }
            }
        }
    }


    Future<dynamic> getPolylineDataNew(String bID) async {
        print("getPolylineDataNew $bID");

        final polylineDetail = apiDetails.polyline(await dataBaseManager.getAccessToken(), bID);
        final isGreenDB = SwitchDataBase().isGreenDataBaseActive();
        print("getPolylineDataNew ${SwitchDataBase().isGreenDataBaseActive()}");

        try {
            if (isGreenDB) {
                final dataBaseIDs = DataBaseManager().getDataBaseKeys(polylineDetail);

                if (!dataBaseIDs.contains(bID)) {
                    final jsonString = await rootBundle.loadString('assets/PreLoads/${polylineDetail.getPreLoadPrefix}$bID.json');
                    final dataPolyline = json.decode(jsonString);
                    final polyLineData = PolyLineAPIModel(responseBody: dataPolyline);

                    DataBaseManager().saveData(polyLineData, polylineDetail, bID);
                    print("POLYLINE DATA FROM JSON ${DataBaseManager().getDataBaseKeys(polylineDetail)}");
                    return polylineDetail.conversionFunction(polyLineData.responseBody);
                } else {
                    final responseFromDatabase = DataBaseManager().getData(polylineDetail, bID);
                    print('POLYLINE DATA FROM DB1');
                    return polylineDetail.conversionFunction(responseFromDatabase.responseBody);
                }
            } else {
                final responseFromDatabase = DataBaseManager().getDataDB2(polylineDetail, bID);
                print("POLYLINE DATA FROM DB2");
                return polylineDetail.conversionFunction(responseFromDatabase.responseBody);
            }
        } catch (e) {
            print("POLYLINE DATA FALLBACK for $bID: $e");
            return await _handleApiFetch(polylineDetail, bID, isGreenDB);
        }
    }

    Future<dynamic> _handleApiFetch(Detail polylineDetail, String bID, bool isGreenDB) async {
        final dataFromAPI = await networkManager.api.request(polylineDetail);

        if (dataFromAPI.statusCode == 200) {
            if (isGreenDB) {
                final polylineData = PolyLineAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(polylineData, polylineDetail, bID);
                print("POLYLINE DATA FROM API STORED IN DB1");
            } else {
                final polylineData = DB2PolyLineAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveDataDB2(polylineData, polylineDetail, bID);
                print("POLYLINE DATA FROM API STORED IN DB2");
            }

            return polylineDetail.conversionFunction(dataFromAPI.data);
        } else {
            print("API Error: ${dataFromAPI.statusCode}");
            return null;
        }
    }

    Future<dynamic> runAPICallPolylineData(String bID,{bool generateJSON = false}) async {
        Detail polylineDetail = apiDetails.polyline(await dataBaseManager.getAccessToken(), bID);
        Response dataFromAPI = await networkManager.api.request(polylineDetail);
        if(generateJSON){
            if(dataFromAPI.statusCode == 200) {
                final patchData = PolyLineAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(patchData, polylineDetail, bID);
                Map<String, dynamic> JSONresponseBody = dataFromAPI.data;
                String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                HelperClass().saveJsonToAndroidDownloads("Polyline$bID", formattedJson);
                if (kDebugMode) {
                    print("GENERATED JSON FOR POLYLINE $bID");
                }
            }
        }else {
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final polylineData = DB2PolyLineAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(polylineData, polylineDetail, bID);
                    print("POLYLINE DATA FROM API STORED IN DB2");
                }else{
                    final polylineData = PolyLineAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(polylineData, polylineDetail, bID);
                    print("POLYLINE DATA FROM API STORED IN DB1");
                }
            }
        }
    }




    Future<dynamic> getPatchDataNew(String bID) async {
        final patchDetail = await apiDetails.patch(await dataBaseManager.getAccessToken(), bID);
        final isGreen = SwitchDataBase().isGreenDataBaseActive();

        try {
            if (isGreen) {
                final keys = DataBaseManager().getDataBaseKeys(patchDetail);
                if (!keys.contains(bID)) {
                    final jsonString = await rootBundle.loadString('assets/PreLoads/${patchDetail.getPreLoadPrefix}$bID.json');
                    final data = json.decode(jsonString);
                    final model = PatchAPIModel(responseBody: data);
                    DataBaseManager().saveData(model, patchDetail, bID);
                    print("PATCH DATA FROM JSON ${DataBaseManager().getDataBaseKeys(patchDetail)}");
                    return patchDetail.conversionFunction(model.responseBody);
                } else {
                    final model = DataBaseManager().getData(patchDetail, bID);
                    print("PATCH DATA FROM DB1");
                    return patchDetail.conversionFunction(model.responseBody);
                }
            } else {
                final model = DataBaseManager().getDataDB2(patchDetail, bID);
                print("PATCH DATA FROM DB2");
                return patchDetail.conversionFunction(model.responseBody);
            }
        } catch (e) {
            print("PATCH FALLBACK for $bID: $e");
            return await _fetchAndStorePatchDataFromAPI(patchDetail, bID, isGreen);
        }
    }

    Future<dynamic> _fetchAndStorePatchDataFromAPI(Detail detail, String bID, bool isGreen) async {
        print("_fetchAndStorePatchDataFromAPI $bID ${detail.body} ${detail.headers} ${detail.url}");
        final response = await networkManager.api.request(detail);
        print("_fetchAndStorePatchDataFromAPI ${response.statusCode} ${response.data}");
        if (response.statusCode == 200) {
            final data = response.data;
            if (isGreen) {
                final model = PatchAPIModel(responseBody: data);
                DataBaseManager().saveData(model, detail, bID);
                print("PATCH DATA STORED IN DB1 FROM API");
            } else {
                final model = DB2PatchAPIModel(responseBody: data);
                DataBaseManager().saveDataDB2(model, detail, bID);
                print("PATCH DATA STORED IN DB2 FROM API");
            }

            return detail.conversionFunction(data);
        } else {
            print("API REQUEST FAILED for $bID: ${response.statusCode}");
            return null;
        }
    }

    Future<dynamic> runAPICallPatchData(String bID,{bool generateJSON = false}) async {
        Detail patchDetail = await apiDetails.patch(await dataBaseManager.getAccessToken(), bID);
        print("runAPICallPatchData ${bID}");
        Response dataFromAPI = await networkManager.api.request(patchDetail);
        if(generateJSON){
            final patchData = PatchAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(patchData, patchDetail, bID);
            Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
            String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
            HelperClass().saveJsonToAndroidDownloads("Patch$bID", formattedJson);
            if (kDebugMode) {
                print("GENERATED JSON FOR PATCH $bID");
            }
        }else {
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final patchData = DB2PatchAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(patchData, patchDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB2");
                }else{
                    final patchData = PatchAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(patchData, patchDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB1");
                }
            }
        }
    }

    Future<List<beacon>> getBeaconDataNew(String bID) async {
        final beaconDetail = apiDetails.buildingBeacons(await dataBaseManager.getAccessToken(), bID);
        final isGreen = SwitchDataBase().isGreenDataBaseActive();

        try {
            if (isGreen) {
                final keys = DataBaseManager().getDataBaseKeys(beaconDetail);

                if (!keys.contains(bID)) {
                    final jsonString = await rootBundle.loadString('assets/PreLoads/${beaconDetail.getPreLoadPrefix}$bID.json');
                    final data = json.decode(jsonString);
                    final model = BeaconAPIModel(responseBody: data);
                    DataBaseManager().saveData(model, beaconDetail, bID);
                    print("BEACON DATA FROM JSON ${DataBaseManager().getDataBaseKeys(beaconDetail)}");
                    return _parseBeaconList(model.responseBody);
                } else {
                    final model = DataBaseManager().getData(beaconDetail, bID);
                    print("BEACON DATA FROM DB1");
                    return _parseBeaconList(model.responseBody);
                }
            } else {
                final model = DataBaseManager().getDataDB2(beaconDetail, bID);
                print("BEACON DATA FROM DB2");
                return _parseBeaconList(model.responseBody);
            }
        } catch (e) {
            print("BEACON FALLBACK for $bID: ");
            return await _fetchAndStoreBeaconDataFromAPI(beaconDetail, bID, isGreen);
        }
    }

    Future<List<beacon>> _fetchAndStoreBeaconDataFromAPI(Detail detail, String bID, bool isGreen) async {
        final response = await networkManager.api.request(detail);

        if (response.statusCode == 200) {
            final raw = response.data;

            if (isGreen) {
                final model = BeaconAPIModel(responseBody: raw);
                DataBaseManager().saveData(model, detail, bID);
                print("BEACON DATA STORED IN DB1 FROM API");
                return _parseBeaconList(model.responseBody);
            } else {
                final model = DB2BeaconAPIModel(responseBody: raw);
                DataBaseManager().saveDataDB2(model, detail, bID);
                print("BEACON DATA STORED IN DB2 FROM API");
                return _parseBeaconList(model.responseBody);
            }
        } else {
            print("BEACON API REQUEST FAILED for $bID: ${response.statusCode}");
            return [];
        }
    }

    List<beacon> _parseBeaconList(dynamic responseBody) {
        try {
            return (responseBody as List).map((e) => beacon.fromJson(e)).toList();
        } catch (e) {
            print("ERROR PARSING BEACON LIST: $e");
            return [];
        }
    }

    Future<dynamic> runAPICallBeaconData(String bID,{bool generateJSON = false}) async {
        Detail beaconDetail = apiDetails.buildingBeacons(await dataBaseManager.getAccessToken(), bID);
        Response dataFromAPI = await networkManager.api.request(beaconDetail);

        if(generateJSON){
            if(dataFromAPI.statusCode == 200){
                final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(beaconData, beaconDetail, bID);
                if(generateJSON) {
                    List<dynamic> JSONresponseBody = dataFromAPI.data;
                    String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("Beacon$bID", formattedJson);
                }
                if(kDebugMode) {
                    print("GENERATED JSON FOR BEACON $bID") ;
                }
            }
        }else{
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final beaconData = DB2BeaconAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(beaconData, beaconDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB2");
                }else{
                    final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(beaconData, beaconDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB1");
                }
            }
        }


    }

    Future<dynamic> getSingleBuildingBeaconData(String bID,{bool generateJSON = false}) async {
        Detail beaconDetail = apiDetails.buildingBeacons(await dataBaseManager.getAccessToken(), bID);
        final beaconBox = beaconDetail.dataBaseGetData!();

        if(switchDataBase.isGreenDataBaseActive()){
            // if(kDebugMode) print("${beaconDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            BeaconAPIModel responseFromDatabase = DataBaseManager().getData(beaconDetail, bID);
            return beaconDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            if(generateJSON || !beaconBox.containsKey(bID)){
                Response dataFromAPI = await networkManager.api.request(beaconDetail);
                if (dataFromAPI.statusCode == 200) {
                    final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(beaconData, beaconDetail, bID);
                    if(generateJSON) {
                        List<dynamic> JSONresponseBody = dataFromAPI.data;
                        String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                        HelperClass().saveJsonToAndroidDownloads("Beacon$bID", formattedJson);
                    }
                    if (kDebugMode) {
                        generateJSON? print("GENERATED JSON FOR BEACON $bID") : print("BEACON DATA FROM API");
                    }
                    return dataFromAPI.data;
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            }else{
                if (kDebugMode) {
                    print("BEACON DATA FROM DATABASE");
                }
                BeaconAPIModel responseFromDatabase = DataBaseManager().getData(beaconDetail, bID);
                return beaconDetail.conversionFunction(responseFromDatabase.responseBody);
            }
        }
    }


    Future<dynamic> getVenueBeaconData() async {
        Detail venueBeaconDetail = apiDetails.venueBeacons(await dataBaseManager.getAccessToken()!, VenueManager().venueName);
        final venueBeaconBox = venueBeaconDetail.dataBaseGetData!();

        if(venueBeaconBox.containsKey(VenueManager().venueName)){
            if (kDebugMode) {
                print("VENUE BEACON DATA FROM DATABASE");
            }
            VenueBeaconAPIModel responseFromDatabase = DataBaseManager().getData(venueBeaconDetail, VenueManager().venueName);
            return venueBeaconDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(venueBeaconDetail);
            if (kDebugMode) {
                print("VENUE BEACON DATA FROM API");
            }
            if(dataFromAPI.statusCode == 200) {
                final venueBeaconData = VenueBeaconAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(venueBeaconData, venueBeaconDetail, VenueManager().venueName);
                return dataFromAPI.data;
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }

        }
    }

    Future<dynamic> runAPIcallBuildingByVenue(String venueName,{bool generateJSON = false}) async {
        Detail buildingByVenueDetail = apiDetails.buildingByVenueApi(await dataBaseManager.getAccessToken(), venueName);
        Response dataFromAPI = await networkManager.api.request(buildingByVenueDetail);
        if(dataFromAPI.statusCode == 200){
            if(generateJSON){
                final buildingByVenue = BuildingByVenueMapAPIModel(responseBody: dataFromAPI.data);
                List<dynamic> JSONresponseBody = dataFromAPI.data;
                String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                HelperClass().saveJsonToAndroidDownloads("BuildingByVenue$venueName", formattedJson);
                print("GENERATED JSON FOR BUILDINGBYVENUE $venueName") ;
            }
        }
    }

    Future<dynamic> getBuildingByVenueNew(String venueName) async {
        final detail = apiDetails.buildingByVenueApi(await dataBaseManager.getAccessToken()!, venueName);
        final isGreen = SwitchDataBase().isGreenDataBaseActive();

        try {
            if (isGreen) {
                final keys = DataBaseManager().getDataBaseKeys(detail);
                if (!keys.contains(venueName)) {
                    final jsonString = await rootBundle.loadString('assets/PreLoads/${detail.getPreLoadPrefix}$venueName.json');
                    final data = json.decode(jsonString);
                    final model = BuildingByVenueMapAPIModel(responseBody: data);
                    DataBaseManager().saveData(model, detail, venueName);
                    print("BUILDING BY VENUE DATA FROM JSON ${DataBaseManager().getDataBaseKeys(detail)}");
                    return detail.conversionFunction(model.responseBody);
                } else {
                    final model = DataBaseManager().getData(detail, venueName);
                    print("BUILDING BY VENUE DATA FROM DB1");
                    return detail.conversionFunction(model.responseBody);
                }
            } else {
                final model = DataBaseManager().getDataDB2(detail, venueName);
                print("BUILDING BY VENUE DATA FROM DB2");
                return detail.conversionFunction(model.responseBody);
            }
        } catch (e) {
            print("FALLBACK for $venueName: $e");
            DataBaseManager().delete(detail, venueName);
            return await _fetchAndStoreBuildingByVenueFromAPI(detail, venueName, isGreen);
        }
    }

    Future<dynamic> _fetchAndStoreBuildingByVenueFromAPI(Detail detail, String venueName, bool isGreen) async {
        final response = await networkManager.api.request(detail);
        print("_fetchAndStoreBuildingByVenueFromAPI ${response.data}");
        if (response.statusCode == 200) {
            final raw = response.data;

            if (isGreen) {
                final model = BuildingByVenueMapAPIModel(responseBody: raw);
                DataBaseManager().saveData(model, detail, venueName);
                print("BUILDING BY VENUE DATA STORED IN DB1 FROM API");
            } else {
                final model = DB2BuildingByVenueMapAPIModel(responseBody: raw);
                DataBaseManager().saveDataDB2(model, detail, venueName);
                print("BUILDING BY VENUE DATA STORED IN DB2 FROM API");
            }

            return detail.conversionFunction(raw);
        } else {
            print("BUILDING BY VENUE API FAILED for $venueName: ${response.statusCode}");
            return null;
        }
    }


    Future<dynamic> getBuildingByVenue(String venueName) async {
        Detail buildingByVenueDetail = apiDetails.buildingByVenueApi(await dataBaseManager.getAccessToken(), venueName);

        if(buildingByVenueDetail.dataBaseGetData != null) {
            final buildingByVenueBox = buildingByVenueDetail.dataBaseGetData!();
            if(buildingByVenueBox.containsKey(venueName)) {
                if (kDebugMode) {
                    print("Data from DB");
                }
                BuildingByVenueMapAPIModel responseFromDatabase = DataBaseManager().getData(buildingByVenueDetail, venueName);
                return buildingByVenueDetail.conversionFunction(responseFromDatabase.responseBody);
            }
        }else {
            Response dataFromAPI = await networkManager.api.request(buildingByVenueDetail);
            if (kDebugMode) {
                print("Data from API");
            }
            if(dataFromAPI.statusCode == 200) {
                // final buildingByVenueData = BuildingByVenueAPIModel(
                //     responseBody: dataFromAPI.data);
                // DataBaseManager().saveData(
                //     buildingByVenueData, buildingByVenueDetail, venueName);
                return buildingByVenueDetail.conversionFunction(dataFromAPI.data);
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }
        }
    }

    Future<dynamic> runAPICallGlobalAnnotationData(String bID,{bool generateJSON = false}) async {
        Detail globalAnnotationDetail = apiDetails.globalAnnotation(await dataBaseManager.getAccessToken(), bID);
        Response dataFromAPI = await networkManager.api.request(globalAnnotationDetail);

        if(generateJSON){
            final globalAnnotationData = GlobalAnnotationAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(globalAnnotationData, globalAnnotationDetail, bID);
            if(generateJSON) {
                print("JSONresponseBody");
                Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                HelperClass().saveJsonToAndroidDownloads("GlobalAnnotation$bID", formattedJson);
            }
            if (kDebugMode) {
                print("GENERATED JSON FOR GLOBAL ANNOTATION $bID");
            }
        }else{
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final globalData = DB2GlobalAnnotationAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(globalData, globalAnnotationDetail, bID);
                    print("GLOBAL ANNOTATION DATA FROM API STORED IN DB2");
                }else{
                    final globalData = GlobalAnnotationAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(globalData, globalAnnotationDetail, bID);
                    print("GLOBAL ANNOTATION DATA FROM API STORED IN DB1");
                }
            }
        }
    }



    Future<dynamic> getGlobalAnnotationDataNew(String bID) async {
        final detail = await apiDetails.globalAnnotation(await dataBaseManager.getAccessToken(), bID);
        print("getGlobalAnnotationDataNew details ${bID}");
        print(detail.conversionFunction);

        final isGreen = SwitchDataBase().isGreenDataBaseActive();
        try{
            if(isGreen){
                final keys = DataBaseManager().getDataBaseKeys(detail);
                if (!keys.contains(bID)) {
                    final jsonString = await rootBundle.loadString('assets/PreLoads/${detail.getPreLoadPrefix}$bID.json');
                    final data = json.decode(jsonString);
                    final model = GlobalAnnotationAPIModel(responseBody: data);
                    DataBaseManager().saveData(model, detail, bID);
                    print("GLOBAL ANNOTATION DATA FROM JSON");
                    return detail.conversionFunction(model.responseBody);
                } else {
                    GlobalAnnotationAPIModel model = DataBaseManager().getData(detail, bID);
                    print("GLOBAL ANNOTATION DATA FROM DB1${model} ${detail.conversionFunction} ${detail.conversionFunction(model.responseBody).runtimeType}");
                    return detail.conversionFunction(model.responseBody);
                }
            } else {
                DB2GlobalAnnotationAPIModel model = DataBaseManager().getDataDB2(detail, bID);
                print("GLOBAL ANNOTATION DATA FROM DB2 ${model} ${detail.conversionFunction} ${detail.conversionFunction(model.responseBody).runtimeType}");
                return detail.conversionFunction(model.responseBody);
            }
        }catch(e){
            print("GLOBAL ANNOTATION DATA FALLBACK for $bID: $e");
            return await _fetchAndStoreFromGlobalAnnotationAPI(detail,bID,isGreen);
        }
    }

    Future<dynamic> _fetchAndStoreFromGlobalAnnotationAPI(Detail detail, String bID, bool isGreen) async {
        final response = await networkManager.api.request(detail);

        if (response.statusCode == 200) {
            final data = response.data;
            if (isGreen) {
                final model = GlobalAnnotationAPIModel(responseBody: data);
                DataBaseManager().saveData(model, detail, bID);
                print("GLOBAL ANNOTATION DATA STORED IN DB1 FROM API");
            } else {
                final model = DB2GlobalAnnotationAPIModel(responseBody: data);
                DataBaseManager().saveDataDB2(model, detail, bID);
                print("GLOBAL ANNOTATION DATA STORED IN DB2 FROM API");
            }
            return detail.conversionFunction(data);
        } else {
            print("API REQUEST FAILED: ${response.statusCode}");
            return null;
        }
    }

    Future<dynamic> getWaypointNew(String bID, bool outdoor) async {
        print("getWaypointNew");

        final detail = apiDetails.waypoint(await dataBaseManager.getAccessToken()!, bID, outdoor: outdoor);
        final isGreen = SwitchDataBase().isGreenDataBaseActive();

        try {
            if (isGreen) {
                final keys = DataBaseManager().getDataBaseKeys(detail);

                if (!keys.contains(bID)) {
                    try {
                        final jsonString = await rootBundle.loadString('assets/PreLoads/${detail.getPreLoadPrefix}$bID.json');
                        final data = json.decode(jsonString);
                        final model = WayPointModel(responseBody: data);
                        DataBaseManager().saveData(model, detail, bID);
                        print("WAYPOINT DATA FROM JSON ${DataBaseManager().getDataBaseKeys(detail)}");
                        return detail.conversionFunction(model.responseBody);
                    } catch (e) {
                        print("WAYPOINT JSON LOAD FAILED for $bID: $e");
                        return await _fetchAndStoreWaypointFromAPI(detail, bID, isGreen);
                    }
                } else {
                    final model = DataBaseManager().getData(detail, bID);
                    print("WAYPOINT DATA FROM DB1");
                    return detail.conversionFunction(model.responseBody);
                }
            } else {
                final model = DataBaseManager().getDataDB2(detail, bID);
                print("WAYPOINT DATA FROM DB2");
                return detail.conversionFunction(model.responseBody);
            }
        } catch (e) {
            print("WAYPOINT FALLBACK for $bID: $e");
            return await _fetchAndStoreWaypointFromAPI(detail, bID, isGreen);
        }
    }

    Future<dynamic> _fetchAndStoreWaypointFromAPI(Detail detail, String bID, bool isGreen) async {
        final response = await networkManager.api.request(detail);

        if (response.statusCode == 200) {
            final data = response.data;

            if (isGreen) {
                final model = WayPointModel(responseBody: data);
                DataBaseManager().saveData(model, detail, bID);
                print("WAYPOINT DATA STORED IN DB1 FROM API");
            } else {
                final model = DB2WayPointModel(responseBody: data);
                DataBaseManager().saveDataDB2(model, detail, bID);
                print("WAYPOINT DATA STORED IN DB2 FROM API");
            }

            return detail.conversionFunction(data);
        } else {
            print("WAYPOINT API FAILED for $bID: ${response.statusCode}");
            return null;
        }
    }


    Future<void> runAPICallWaypointData(String bID,{bool generateJSON = false}) async {
        print("runAPICallWaypointData");
        Detail waypointDetails = apiDetails.waypoint(await dataBaseManager.getAccessToken()!, bID);
        Response dataFromAPI = await networkManager.api.request(waypointDetails);
        if (generateJSON) {
            final wayPointData = WayPointModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(wayPointData, waypointDetails, bID);
            List<dynamic> JSONresponseBody = dataFromAPI.data;
            String formattedJson = JsonEncoder.withIndent('  ').convert(
                JSONresponseBody);
            HelperClass().saveJsonToAndroidDownloads(
                "Waypoint$bID", formattedJson);
            print("GENERATED JSON FOR WAYPOINT $bID");
        } else {
            if (dataFromAPI.statusCode == 200) {
                if (SwitchDataBase().isGreenDataBaseActive()) {
                    final wayPointData = DB2WayPointModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(wayPointData, waypointDetails, bID);
                    print("WAYPOINT DATA FROM API STORED IN DB2");
                } else {
                    final wayPointData = WayPointModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(wayPointData, waypointDetails, bID);
                    print("WAYPOINT DATA FROM API STORED IN DB1");
                }
            }
            return;
        }
    }

    Future<dynamic> getWaypointData(String bID,{bool generateJSON = false}) async {
        Detail waypointDetails = apiDetails.waypoint(await dataBaseManager.getAccessToken(), bID);
        final waypointBox = waypointDetails.dataBaseGetData!();
        if(SwitchDataBase().isGreenDataBaseActive()){
            if(kDebugMode) print("${waypointDetails.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            WayPointModel responseFromDatabase = DataBaseManager().getData(waypointDetails, bID);
            return waypointDetails.conversionFunction(responseFromDatabase.responseBody);
        }else {
            if (generateJSON || !waypointBox.containsKey(bID)) {
                Response dataFromAPI = await networkManager.api.request(waypointDetails);
                if (dataFromAPI.statusCode == 200) {
                    final wayPointData = WayPointModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(wayPointData, waypointDetails, bID);
                    if (generateJSON) {
                        List<dynamic> JSONresponseBody = dataFromAPI.data;
                        String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                        HelperClass().saveJsonToAndroidDownloads("Waypoint$bID", formattedJson);
                    }
                    if (kDebugMode) {
                        generateJSON
                            ? print("GENERATED JSON FOR WAYPOINT $bID")
                            : print("WAYPOINT DATA FROM API");
                    }
                    return dataFromAPI.data;
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            } else {
                if (kDebugMode) {
                    print("WAYPOINT DATA FROM DATABASE");
                }
                WayPointModel responseFromDatabase = DataBaseManager().getData(
                    waypointDetails, bID);
                return waypointDetails.conversionFunction(
                    responseFromDatabase.responseBody);
            }
        }
    }


    Future<dynamic> getCampusData(List<String> bIDS) async {
        Detail campusDetails = apiDetails.outBuilding(await dataBaseManager.getAccessToken()!, bIDS);
        final campusBox = campusDetails.dataBaseGetData!();

        for (var bid in bIDS) {
            if(campusBox.containsKey(bid)){
                if (kDebugMode) {
                    print("Data from DB");
                }
                OutDoorModel responseFromDatabase = DataBaseManager().getData(campusDetails, bid);
                return campusDetails.conversionFunction(responseFromDatabase.responseBody);
            }
        }

        Response dataFromAPI = await networkManager.api.request(campusDetails);
        if (kDebugMode) {
            print("Data from API");
        }
        if(dataFromAPI.statusCode == 200) {
            final campusData = OutDoorModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(campusData, campusDetails, bIDS[0]);
            return dataFromAPI.data;
        }else if(dataFromAPI.statusCode == 201){
            return null;
        }else{
            return null;
        }

    }

    dynamic getPreLoadedData(Detail details,String bID) async {
        // if(kDebugMode) print("${details.getPreLoadPrefix} DATA FROM GREEN DATABASE");
        String jsonString = await rootBundle.loadString('assets/PreLoads/${details.getPreLoadPrefix}$bID.json');
        final data = json.decode(jsonString);
        details.method;
        return details.conversionFunction(data);
    }

}
