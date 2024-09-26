import 'dart:ui';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config.dart';
class wsocket{
  static String appID = "";
  static final channel = io.io('${AppConfig.baseUrl}', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
//message ["userId"]=123456;
  static Map message = {
    "appId" : appID,
    "userId": "",
    "deviceInfo": {
      "sensors": {
        "BLE": false,
        "location": false,
        "activity": false,
        "compass": false
      },
      "permissions": {
        "BLE": false,
        "location": false,
        "activity": false,
        "compass": false
      },
      "deviceManufacturer": ""
    },
    "AppInitialization": {
      "BID": "",
      "buildingName": "",
      "bleScanResults": {
        "IW122": 0,
        "IW123": 0,
      },
      "localizedOn": ""
    },
    "userPosition": {
      "X": 0,
      "Y": 0,
      "floor": 0
    },
    "path": {
      "source": "",
      "destination": "",
      "didPathForm": false

    }
  };


  wsocket(String appid){
    appID = appid;
    channel.connect();

  }
  static void sendmessg() {
    channel.emit("user-log-socket", message);
  }
}