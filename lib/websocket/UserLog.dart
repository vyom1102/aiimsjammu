import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  late io.Socket _socket;
  late io.Socket _receiveSocket;
  var userInfoBox = Hive.box('UserInformation');





  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  static double driverLat = 0.0;
  static double driverLng = 0.0;

  Map<dynamic, dynamic> message = {};


  Map<dynamic, dynamic> _initializeMessage(String appId) {
    message = {
      "appId": appId, // Now appId is dynamically assigned
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
        "bleScanResults": {},
        "localizedOn": ""
      },
      "userPosition": {
        "X": 0,
        "Y": 0,
        "floor": 0,
        "latitude": 0.0,
        "longitude": 0.0
      },
      "path": {
        "source": "",
        "destination": "",
        "didPathForm": false
      }
    };
    return message;
  }


  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal() {
    _initializeSocket();
  }

  void _initializeSocket() {
    _socket = io.io(AppConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true, // Automatically connects on app start
      'reconnection': true, // Enables auto-reconnect
      'reconnectionAttempts': 5, // Tries reconnecting 5 times
      'reconnectionDelay': 2000, // 2s delay between retries
    });

    _socket.onConnect((_) {
      print('✅ Connected to WebSocket Server');
      //sendMessage(); // Send initial message upon connection
    });

    _socket.onDisconnect((_) => print('⚠️ Disconnected from WebSocket Server'));
    _socket.onError((data) => print('❌ WebSocket Error: $data'));
    _socket.onReconnect((_) => print('🔄 Reconnecting...'));
    _socket.on("server-event", (data) {
      print("📩 Received:-- $data");
      if (data is Map<String, dynamic>) {
        _messageController.add(data); // Send data to stream listeners
      }
    });
    _receiveSocket = io.io(AppConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true, // Automatically connects on app start
      'reconnection': true, // Enables auto-reconnect
      'reconnectionAttempts': 5, // Tries reconnecting 5 times
      'reconnectionDelay': 2000, // 2s delay between retries
    });

    _receiveSocket.onConnect((_) {
      print('✅ Connected to WebSocket Server');
      //sendMessage(); // Send initial message upon connection
    });

    _receiveSocket.onDisconnect((_) => print('⚠️ Disconnected from WebSocket Server'));
    _receiveSocket.onError((data) => print('❌ WebSocket Error: $data'));
    _receiveSocket.onReconnect((_) => print('🔄 Reconnecting...'));
  }

  bool send = false;
  void updateMessage(Map<String, dynamic> updates) {
    String appId = "";
    if (userInfoBox.containsKey("userTracking")) {
      if (userInfoBox.get("userTracking")) {
        appId = "com.iwayplus.aiimsjammu-driver";
      } else {
        appId = "com.iwayplus.aiimsjammu";
      }
    }

    // Ensure message is initialized only once, not reset on every update
    if (message.isEmpty) {
      message = _initializeMessage(appId);
    }

    updates.forEach((key,value){
      updateNestedMap(message,key,value);
    });

    // print("🔄 Updated message: ${message["userPosition"]}");

    // sendMessage(message);
  }

  void updateNestedMap(Map<dynamic, dynamic> map, String key, dynamic value) {
    List<String> keys = key.split('.');
    Map<dynamic, dynamic> temp = map;

    for (int i = 0; i < keys.length - 1; i++) {
      temp = temp.putIfAbsent(keys[i], () => {}) as Map<String, dynamic>;
    }

    temp[keys.last] = value;
  }

  void sendMessage(Map<dynamic, dynamic> message) {
    if (_socket.connected) {
      _socket.emit("user-log-socket", message);
      print("📤 Sent message: $message");
    } else {
      print("⚠️ WebSocket not connected. Cannot send message.");
    }
  }

  void receiveMessage() {
    print("receiveMessage");
    _socket.on("client-log-com.iwayplus.aiimsjammu-driver", (data) {
      // print("📩 Received in Timer: ${data}");
      // print(data["userPosition"]["latitude"]);
      // print(data["userPosition"]["longitude"]);
      if(data["userPosition"]["latitude"] != 0.0 || data["userPosition"]["latitude"] != 0){
        driverLat = data["userPosition"]["latitude"];
      }
      if(data["userPosition"]["longitude"] != 0.0 || data["userPosition"]["longitude"] != 0){
        driverLng = data["userPosition"]["longitude"];
      }
    });
  }

  void disconnect() {
    _socket.disconnect();
    print("🛑 WebSocket disconnected.");
  }
}
