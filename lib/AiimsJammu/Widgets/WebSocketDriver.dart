
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwaymaps/singletonClass.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/config.dart';

import '../../API/RefreshTokenAPI.dart';

class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  late io.Socket _socket;
  Timer? _locationTimer;
  Position? _currentPosition;
  bool _isTracking = false;
  bool _isConnected = false;

  String? _userId;
  String? _name;
  String? _accessToken;
  String? _refreshToken;
  String _profile = "user"; // Default
  String get _appId => "com.iwayplus.aiimsjammu-${_profile == "driver" ? "vehicle" : "user"}";

  bool get isTracking => _isTracking;
  bool get isConnected => _isConnected;
  Position? get currentPosition => _currentPosition;

  Future<void> initialize() async {
    _initializeSocket();
    await _loadUserData();
    await _checkLocationPermission();
  }

  Future<void> _loadUserData() async {
    final signInBox = await Hive.openBox('SignInDatabase');
    final userBox = await Hive.openBox('user');
    _userId = signInBox.get("userId");
    _accessToken = signInBox.get("accessToken");
    _refreshToken = signInBox.get("refreshToken");
    _name = userBox.get("name");
    _profile = signInBox.get("profile")??"user";

    if (_userId == null || _profile == "user" || _name == null ) {
      await _fetchUserDetailsFromAPI(signInBox,userBox);
    }
  }

  Future<void> _fetchUserDetailsFromAPI(Box signInBox,Box userBox) async {
    final String baseUrl = "${AppConfig.baseUrl}/secured/user/get";

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': _accessToken ?? '',
        },
      );
      print("web socket user data");
      print(response.statusCode);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody['userTypeForTracking']);
        _userId = responseBody['_id'];
        _profile = responseBody['userTypeForTracking'];
        _name = responseBody["name"];
        await signInBox.put("userId", _userId);
        await signInBox.put("profile", _profile);
        await userBox.put("name",_name);
      } else if (response.statusCode == 403) {
        String newToken = await RefreshTokenAPI.refresh();
        _accessToken = newToken;
        // await signInBox.put("accessToken", _accessToken);
        await _fetchUserDetailsFromAPI(signInBox,userBox);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user details: $e');
      }
    }
  }

  void _initializeSocket() {
    _socket = io.io(AppConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    _socket.onConnect((_) {
      _isConnected = true;
      print('✅ LocationTrackingService: Connected to WebSocket Server');
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) {
        print('⚠️ LocationTrackingService: Disconnected from WebSocket Server');
      }
    });

    _socket.onError((data) {
      if (kDebugMode) {
        print('❌ LocationTrackingService: WebSocket Error: $data');
      }
    });
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return false;
    }

    await _getCurrentPosition();
    return true;
  }

  void startTracking() {
    if (_locationTimer != null) {
      _locationTimer!.cancel();
    }

    _isTracking = true;
    _getCurrentPosition().then((_) => _sendLocationToServer());

    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _getCurrentPosition();
      _sendLocationToServer();
    });

    print('📍 LocationTrackingService: Location tracking started');
  }

  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;
    print('🛑 LocationTrackingService: Location tracking stopped');
  }

  Future<void> _getCurrentPosition() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print('❌ Error getting location: $e');
      }
    }
  }

  void _sendLocationToServer() {
    if (_currentPosition != null && _isConnected) {
      final locationData = {
        "appId": _appId,
        "name":_name,
        "userId": _userId ?? "unknown",
        "profile": _profile ,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude,
        "timestamp": DateTime.now().toIso8601String(),
        "beaconLat":SingletonFunctionController().getlocalizedBeacon()?.properties?.latitude??"",
        "beaconLng":SingletonFunctionController().getlocalizedBeacon()?.properties?.longitude??"",
      };

      _socket.emit('user-log-socket', locationData);
      print(" LocationTrackingService Sent message: $locationData");
      // if(kDebugMode)
      if(kDebugMode) {
        Fluttertoast.showToast(msg: "$locationData ");
      }
      print('LocationTrackingService: Location sent - Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}');

    }
  }

  void dispose() {
    stopTracking();
    _socket.disconnect();
    print('🗑️ LocationTrackingService: Disposed');
  }
}
