//
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'dart:convert';
//
// import '../Widgets/LocationIdFunction.dart';
// import '../Widgets/Translator.dart';
//
// class QRScannerScreen extends StatefulWidget {
//   @override
//   _QRScannerScreenState createState() => _QRScannerScreenState();
// }
//
// class _QRScannerScreenState extends State<QRScannerScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//
//   @override
//   void reassemble() {
//     super.reassemble();
//     if (controller != null) {
//       controller!.pauseCamera();
//     }
//     controller?.resumeCamera();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TranslatorWidget('QR Scanner'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 5,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: TranslatorWidget('Scan a QR code'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       try {
//         final data = jsonDecode(scanData.code ?? '');
//         final id = data['id'];
//         final isSource=data['source'];
//         print("-----qr-----");
//         print(isSource);
//         print(id);
//         PassLocationId(context, id);
//         controller?.stopCamera();
//       } catch (e) {
//         print('Error parsing JSON: $e');
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:iwaymaps/api/buildingAllApi.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../APIMODELS/buildingAll.dart';
import '../../Elements/HelperClass.dart';
import '../../Navigation.dart';
import '../Widgets/Translator.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

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
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isDeepLinkHandled) {
        _isDeepLinkHandled = true;
        try {
          final uri = Uri.parse(scanData.code ?? '');
          iwaymapsDeepLink(uri, context, "rgci.com");
          controller.stopCamera();
        } catch (e) {
          print('Error parsing URL: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
