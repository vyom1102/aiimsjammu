import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ELEMENTS/HelperClass.dart';

class LoggingScreen extends StatelessWidget {
  final Map<DateTime, Map<String, List<String>>> logging;
  final List<DateTime> loggingTaps;
  final Map<String,String> ui = Map();

  LoggingScreen({
    required this.logging,
    required this.loggingTaps,
  });

  Future<void> requestStoragePermission() async {
    // Ask for regular storage permission (Android <11)
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print("✅ Storage permission granted");
    } else if (status.isDenied) {
      print("❌ Storage permission denied");
    } else if (status.isPermanentlyDenied) {
      print("❌ Permission permanently denied, please enable from settings");
      await openAppSettings();
    }
    return;
  }

  Future<void> saveBeaconDataToCsv(
      Map<String, List<MapEntry<DateTime, int>>> data,
      String fileName,
      ) async {
    await requestStoragePermission();
    // List of rows: first row is the header
    List<List<String>> rows = [
      ['timestamp', 'beacon name', 'rssi']
    ];

    // Flatten the data into rows
    data.forEach((beaconName, entries) {
      for (var entry in entries) {
        rows.add([
          entry.key.toIso8601String(),
          beaconName,
          entry.value.toString(),
        ]);
      }
    });

    // Convert to CSV format
    String csvData = const ListToCsvConverter().convert(rows);

    // Get file path (for mobile apps)
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final file = File('${downloadsDir!.path}/$fileName.csv');

    // Write CSV to file
    await file.writeAsString(csvData);
    Fluttertoast.showToast(
      msg: 'CSV saved at: ${file.path}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    print('CSV saved at: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    // Sort DateTime in descending order

    print("logging--- $logging");
    HelperClass().saveJsonToAndroidDownloads("BEACONLOGpath", logging.toString());
    Map<DateTime,Map<String, List<String>>> forUI = {};

    logging.forEach((key,value){
      if(forUI.containsKey(key)){
        forUI[key];
      }
      print(" $key $value");
    });

    final sortedTimes = logging.keys.toList()..sort();

    // Flatten all beacon RSSI values across timestamps
    Map<String, List<MapEntry<DateTime, int>>> beaconRSSILog = {};

    for (final time in sortedTimes) {
      final devices = logging[time];
      if (devices == null) continue;

      devices.forEach((beacon, rssiList) {
        for (var rssiStr in rssiList) {
          final rssi = int.tryParse(rssiStr);
          print("rssi $rssi");
          if (rssi != null) {
            beaconRSSILog.putIfAbsent(beacon, () => []);
            beaconRSSILog[beacon]!.add(MapEntry(time, rssi));
          }
        }
      });
    }
    print("beaconRSSILog $beaconRSSILog");
    saveBeaconDataToCsv(beaconRSSILog,"BluetoothLogPath");
    // HelperClass().saveJsonToAndroidDownloads("BluetoothLogPath", beaconRSSILog.toString());


    // Now compute average of last 5 RSSIs before each timestamp

    return Scaffold(
      body: Builder(
        builder: (context) {
          final List<MapEntry<String, String>> filteredEntries = [];
          final Set<String> seenEntries = {};
          DateTime? lastIncludedTime;


          final sortedUiEntries = ui.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)); // Sort by time (string)

          for (var entry in sortedUiEntries) {
            final time = entry.key;
            final beaconData = entry.value;
            final entryTime = DateTime.tryParse(time);

            if (entryTime == null) continue;

            // Only include entries at least 2 seconds apart
            if (lastIncludedTime != null &&
                entryTime.difference(lastIncludedTime).inSeconds < 2) {
              continue;
            }

            // Avoid duplicate beaconData
            if (seenEntries.contains(beaconData)) continue;

            filteredEntries.add(MapEntry(time, beaconData));
            seenEntries.add(beaconData);
            lastIncludedTime = entryTime;
          }

          return ListView.builder(
            itemCount: forUI.length,
            itemBuilder: (context, index) {
              final time = filteredEntries[index].key;
              final beaconData = filteredEntries[index].value;
              final entryTime = DateTime.tryParse(time);

              Color textColor = Colors.black;
              if (entryTime != null) {
                final isCloseToTap = loggingTaps.any((tapTime) =>
                (entryTime.difference(tapTime).inMilliseconds).abs() <= 200);
                if (isCloseToTap) textColor = Colors.red;
              }

              final dataList = beaconData
                  .split(',')
                  .map((e) => e.split(':'))
                  .where((parts) => parts.length >= 2)
                  .map((parts) {
                final key = parts[0];
                final value =
                    double.tryParse(parts[1])?.toStringAsFixed(2) ?? '0.00';
                return MapEntry(key, value);
              })
                  .toList()
                ..sort((a, b) => a.key.compareTo(b.key)); // Sort by key

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time: ${forUI[index]}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                    ...dataList.map((entry) => Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 2),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: textColor,
                        ),
                      ),
                    )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}