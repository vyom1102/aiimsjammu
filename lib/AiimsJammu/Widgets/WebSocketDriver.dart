import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:iwaymaps/config.dart';

class LocationTrackingService {
  // Singleton pattern
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  // Properties
  late io.Socket _socket;
  Timer? _locationTimer;
  Position? _currentPosition;
  bool _isTracking = false;
  bool _isConnected = false;

  // Getters
  bool get isTracking => _isTracking;
  bool get isConnected => _isConnected;
  Position? get currentPosition => _currentPosition;

  // Initialize the service
  Future<void> initialize() async {
    _initializeSocket();
    await _checkLocationPermission();
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
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print('Location services are disabled');
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permissions are denied');
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print('Location permissions are permanently denied');
      }
      return false;
    }

    // Get current position once
    await _getCurrentPosition();
    return true;
  }

  // Start tracking location
  void startTracking() {
    if (_locationTimer != null) {
      _locationTimer!.cancel();
    }

    _isTracking = true;

    // Send location immediately
    _getCurrentPosition().then((_) => _sendLocationToServer());

    // Set up timer to send location every 3 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _getCurrentPosition();
      _sendLocationToServer();
    });

    if (kDebugMode) {
      print('LocationTrackingService: Location tracking started');
    }
  }

  // Stop tracking location
  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;

    if (kDebugMode) {
      print('LocationTrackingService: Location tracking stopped');
    }
  }

  // Get current position
  Future<void> _getCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
    }
  }

  // Send location data to server
  void _sendLocationToServer() {
    print("LocationTrackingService in send location ");
    print(_currentPosition);
    print(_isConnected);
    if (_currentPosition != null && _isConnected) {
      final locationData = {
        "appId":"com.iwayplus.aiimsjammu-driver",
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _socket.emit('user-log-socket', locationData);
      print(" LocationTrackingService Sent message: $locationData");

        print('LocationTrackingService: Location sent - Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}');

    }
  }

  // Dispose the service
  void dispose() {
    stopTracking();
    _socket.disconnect();
    if (kDebugMode) {
      print('LocationTrackingService: Disposed');
    }
  }
}