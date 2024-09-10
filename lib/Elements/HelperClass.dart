import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;

import '../API/buildingAllApi.dart';
import '../APIMODELS/buildingAll.dart';
import '../MODELS/VenueModel.dart';

class HelperClass{
  static bool SemanticEnabled = false;


  static String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + '..';
    }
  }
  static void showToast(String mssg) {
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
  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }




  static Future<void> shareContent(String text) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: text,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw Exception('QR code generation failed');
      }
      final qrCode = qrValidationResult.qrCode;

      final ByteData imageData = await rootBundle.load('assets/qrlogo.png');
      final ui.Codec codec = await ui.instantiateImageCodec(imageData.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image image = fi.image;

      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF0B6B94),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
        embeddedImage: image,
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(300, 300),
        ),
      );

      final int qrSize = 2048;
      final int padding = 100;
      final int totalSize = qrSize + (2 * padding);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawColor(Colors.white, BlendMode.src);

      canvas.translate(padding.toDouble(), padding.toDouble());
      painter.paint(canvas, Size(qrSize.toDouble(), qrSize.toDouble()));

      final picture = recorder.endRecording();
      final img = await picture.toImage(totalSize, totalSize);
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      final buffer = pngBytes!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/doctor_share.png';
      final file = await File(tempPath).writeAsBytes(buffer);

      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (e) {
      print('Error sharing content: $e');
    }
  }

  static Future<HashMap<String,List<buildingAll>>> groupBuildings(List<buildingAll> data)async{
    HashMap<String,List<buildingAll>> venueMap = HashMap();
    for(buildingAll building in data){
      venueMap.putIfAbsent(building.venueName!, ()=>[]);
      venueMap[building.venueName]!.add(building);
    }
    return venueMap;
  }

  static Future<Map<String,g.LatLng>> createAllbuildingMap (HashMap<String,List<buildingAll>> venueMap, String venue)async{
    Map<String,g.LatLng> AllBuildingMap = Map();
    for (var building in venueMap[venue]!) {
      AllBuildingMap[building.sId!] = g.LatLng(building.coordinates![0], building.coordinates![1]);
    }
    return AllBuildingMap;
  }

  static String extractLandmark(String url) {
    final RegExp regex = RegExp(r'source=([^&]*)&appStore');
    final Match? match = regex.firstMatch(url);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    } else {
      return '';
    }
  }

  static Map<String, List<buildingAll>> createVenueHashMap(List<buildingAll> buildingList) {
    Map<String, List<buildingAll>> dummyVenueHashMap = HashMap<String, List<buildingAll>>();

    for (buildingAll building in buildingList) {
      // Check if the venueName is already a key in the HashMap
      if (dummyVenueHashMap.containsKey(building.venueName)) {
        // If yes, add the building to the existing list
        dummyVenueHashMap[building.venueName]!.add(building);
      } else {
        // If no, create a new list with the building and add it to the HashMap
        dummyVenueHashMap[building.venueName??""] = [building];
      }
    }
    return dummyVenueHashMap;
  }
  static List<VenueModel> createVenueList(Map<String, List<buildingAll>> venueHashMap){
    List<VenueModel> newList = [];
    for (var entry in venueHashMap.entries) {
      String key = entry.key;
      List<buildingAll> value = entry.value;
      newList.add(VenueModel(venueName: key, distance: 190, buildingNumber: value.length, imageURL: value[0].venuePhoto??"", Tag: value[0].venueCategory??"", address: value[0].address,description: value[0].description,phoneNo: value[0].phone,website: value[0].website,coordinates: value[0].coordinates!, dist: 0));
      // print('Key: $key');
      // print('Value: $value');
    }
    return newList;
  }
  static Map<String, List<buildingAll>> venueHashMap=new HashMap();
  static List<VenueModel> venueList=[];
  static List<VenueModel> buildingsPos=[];
  static buildingApicall()async{
    await buildingAllApi().fetchBuildingAllData().then((value) {
      // print(value);
      venueHashMap=createVenueHashMap(value);
      venueList = createVenueList(venueHashMap);
      for(int i=0;i<venueList.length;i++)
      {
        buildingsPos.add(venueList[i]);
      }
    });

  }

  static Future<int> getGeoFenced(String venueName,Position userPos)async{
    await buildingApicall();
    List<buildingAll>? buildingList=venueHashMap[venueName];
    for(int i=0;i<buildingList!.length;i++){
      var currentData=buildingList[i];
      if(currentData.geofencing!=null && currentData.geofencing!){
        for(int j=0;j<venueList.length;j++){
          if(userPos.latitude.toStringAsFixed(2)==venueList[j].coordinates[0].toStringAsFixed(2) && userPos.longitude.toStringAsFixed(2)==venueList[j].coordinates[1].toStringAsFixed(2)){
            return 0;
          }
        }
      }else{
        return 1;
      }
    }
    return 2;

  }


}