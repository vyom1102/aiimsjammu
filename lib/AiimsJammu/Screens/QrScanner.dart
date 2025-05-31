
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/api/buildingAllApi.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../API/QRDataAPI.dart';
import '../../API/buildingByVenueAPI.dart';
import '../../APIMODELS/QRDataAPIModel.dart';
import '../../APIMODELS/buildingAll.dart';
import '../../Elements/HelperClass.dart';
import '../../MainScreen.dart';
import '../../Navigation.dart';
import '../Widgets/LocationIdFunction.dart';
import '../Widgets/Translator.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Map<String,g.LatLng>? buildingMap;
  static String? bid;
  static String? landmarkID;
  static String? source;
  bool _isDeepLinkHandled = false;
  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBuildings();
  }

  static Future<void> iwaymapsDeepLink(Uri? uri, BuildContext context, String appName) async {
    if (uri == null) {
      print("Error: URI is null.");
      return;
    }
    print("Deep link URI: ${uri.toString()}");
    String queryString = uri.fragment.contains('?') ? uri.fragment.split('?').last : '';
    Uri actualUri = Uri.parse('https://iwayplus.com/?$queryString');
    bid = actualUri.queryParameters['bid'];
    landmarkID = actualUri.queryParameters['landmark'];
    source = actualUri.queryParameters['source'];
    if (bid == null || landmarkID == null) {
      print("Error: Missing query parameters.");
      return;
    }
    try {
      final buildings = await buildingAllApi().fetchBuildingAllData();
      print("Fetched buildings: $buildings");
      final venue = buildings.firstWhere(
            (building) => building.sId == bid,
        orElse: () => throw Exception("Building not found."),
      ).venueName;
      final venueMap = await HelperClass.groupBuildings(buildings);
      final allBuildingMap = await HelperClass.createAllbuildingMap(venueMap, venue!);

      buildingAllApi.allBuildingID = allBuildingMap;
      buildingAllApi.selectedBuildingID = bid!;
      buildingAllApi.selectedID = bid!;
      buildingAllApi.selectedVenue = venue;
      if (source != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Navigation(directsourceID: source ?? ""),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Navigation(directLandID: landmarkID ?? ""),
          ),
        );
      }
    } catch (e) {
      print("Error handling deep link: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
            'QR Scanner',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          // text: 'QR Scanner',
          // fontSize: '18',
          // fontWeight: '500',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: TranslatorWidget(
                'Scan QR code',
                style: TextStyle(
                  fontSize: 12
                ),
                // text: 'Scan QR code',
                // fontSize: '12',
                // fontWeight: '400',
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isDeepLinkHandled) return;
      _isDeepLinkHandled = true;

      try {
        final scannedUrl = scanData.code ?? '';
        print("Scanned QR code: $scannedUrl");

        final landmarkId = extractLandmarkId(scannedUrl);
        if (landmarkId != null) {
          print("Navigating via landmarkId: $landmarkId");
          PassLocationId(context, landmarkId);
          return;
        }

        final qrCode = getQrCodeFromUrl(scannedUrl);
        print("CMS QR Code: $qrCode");

        final qrDataList = await QRDataAPI().fetchQRData(buildingMap != null?buildingMap!.keys.toList():buildingAllApi.allBuildingID.keys.toList());

        for(int i = 0; i<qrDataList!.length; i++){
          if(qrDataList[i].code == qrCode){
            print("Navigating via CMS: ${qrDataList[i].landmarkId!}");
            PassLocationId(context, qrDataList[i].landmarkId!);
            return;
          }
        }

        controller.stopCamera();
        HelperClass.showToast("Invalid/Unassigned QR");
        print("qr pop");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0,)));
        return;
      } catch (e) {
        print('Error while handling QR scan: $e');
      }
    });
  }

  String? extractLandmarkId(String url) {
    try {
      final uri = Uri.parse(url);
      final parts = uri.fragment.split('/');

      final index = parts.indexOf('landmarkId');
      if (index != -1 && index + 1 < parts.length) {
        return parts[index + 1];
      }
    } catch (_) {}
    return null;
  }

  String getQrCodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.fragment.split('/').last;
    } catch (_) {
      return '';
    }
  }

  Future<Map<String, LatLng>?> loadBuildings() async {
    var signInDatabaseBox = Hive.box('SignInDatabase');
    if (signInDatabaseBox.containsKey("accessToken")) {
      buildingMap = await Buildingbyvenueapi.findBuildings();
      return buildingMap;
    }else{
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
