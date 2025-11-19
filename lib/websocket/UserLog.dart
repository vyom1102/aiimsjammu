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
      },
      "nearByDevices" : {},
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

  static void disconnect() {
    if (channel.connected) {
      print("Disconnecting WebSocket...");
      String id=message["userId"];
      message = {
        "appId" : appID,
        "userId": id,
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
          },
          "nearByDevices" : {},
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
      channel.disconnect();
    } else {
      print("WebSocket already disconnected.");
    }
  }


  static void sendmessg() {
    if (!channel.connected) {
      print("WebSocket not connected, trying to connect...");
      _initializeConnection();
      // Wait a bit before sending message
      channel.once('connect', (_) {
        print("Sending message after reconnect: $message");
        channel.emit("user-log-socket", message);
      });
    } else {
      // print("Sending message: $message");
      channel.emit("user-log-socket", message);
    }
  }

  static void _initializeConnection() {
    // Clean any old handlers
    channel.off('connect');
    channel.off('disconnect');
    channel.off('error');
    // Add listeners once
    channel.on('connect', (_) {
      print("WebSocket connected ✅");
    });
    channel.on('disconnect', (_) {
      print("WebSocket disconnected ❌");
    });

    channel.on('error', (data) {
      print("WebSocket error: $data");
    });
    channel.connect();
  }
}