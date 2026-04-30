// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:iwaymaps/singletonClass.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
// import 'package:iwaymaps/config.dart';

// import '../../API/RefreshTokenAPI.dart';

// class LocationTrackingService {
//   static final LocationTrackingService _instance = LocationTrackingService._internal();
//   factory LocationTrackingService() => _instance;
//   LocationTrackingService._internal();

//   late io.Socket _socket;
//   Timer? _locationTimer;
//   Position? _currentPosition;
//   bool _isTracking = false;
//   bool _isConnected = false;

//   String? _userId;
//   String? _name;
//   String? _accessToken;
//   String? _refreshToken;
//   String _profile = "user";
//   String get _appId =>
//       "com.iwayplus.aiimsjammu-${_profile == "driver" ? "vehicle" : "user"}";

//   bool get isTracking => _isTracking;
//   bool get isConnected => _isConnected;
//   Position? get currentPosition => _currentPosition;

//   Future<void> initialize() async {
//     _initializeSocket();
//     await _loadUserData();
//     await _checkLocationPermission();
//   }

//   Future<void> _loadUserData() async {
//     final signInBox = await Hive.openBox('SignInDatabase');
//     final userBox = await Hive.openBox('user');
//     _userId = signInBox.get("userId");
//     _accessToken = signInBox.get("accessToken");
//     _refreshToken = signInBox.get("refreshToken");
//     _name = userBox.get("name");
//     _profile = signInBox.get("profile") ?? "user";

//     if (_userId == null || _profile == "user" || _name == null) {
//       await _fetchUserDetailsFromAPI(signInBox, userBox);
//     }
//   }

//   Future<void> _fetchUserDetailsFromAPI(Box signInBox, Box userBox) async {
//     final String baseUrl = "${AppConfig.baseUrl}/secured/user/get";
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'x-access-token': _accessToken ?? '',
//         },
//       );
//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseBody = json.decode(response.body);
//         _userId = responseBody['_id'];
//         _profile = responseBody['userTypeForTracking'];
//         _name = responseBody["name"];
//         await signInBox.put("userId", _userId);
//         await signInBox.put("profile", _profile);
//         await userBox.put("name", _name);
//       } else if (response.statusCode == 403) {
//         String newToken = await RefreshTokenAPI.refresh();
//         _accessToken = newToken;
//         await _fetchUserDetailsFromAPI(signInBox, userBox);
//       }

//     } catch (e) {
//       if (kDebugMode) print('Error fetching user details: $e');
//     }
//   }
//   void _initializeSocket() {
//     _socket = io.io(AppConfig.baseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//       'reconnection': true,
//       'reconnectionAttempts': 5,
//       'reconnectionDelay': 2000,
//     });

//     _socket.onConnect((_) {
//       _isConnected = true;
//       print('✅ Connected | id: ${_socket.id}');
//     });

//     _socket.onDisconnect((reason) {
//       _isConnected = false;
//       print('⚠️ Disconnected | reason: $reason');   // <-- tells you WHY
//     });

//     _socket.onConnectError((data) {
//       print('❌ Connect Error: $data');               // <-- most useful line
//     });

//     _socket.onError((data) {
//       print('❌ Socket Error: $data');
//     });

//     // Prints every packet — remove after debugging
//     _socket.onAny((event, data) {
//       print('📦 Event received: $event | data: $data');
//     });
//   }

//   Future<bool> _checkLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return false;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return false;
//     }
//     if (permission == LocationPermission.deniedForever) return false;

//     await _getCurrentPosition();
//     return true;
//   }

//   void startTracking() {
//     _locationTimer?.cancel();
//     _isTracking = true;
//     _getCurrentPosition().then((_) => _sendLocationToServer());

//     _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       await _getCurrentPosition();
//       _sendLocationToServer();
//     });
//     print('📍 LocationTrackingService: Location tracking started');
//   }

//   void stopTracking() {
//     _locationTimer?.cancel();
//     _locationTimer = null;
//     _isTracking = false;
//     print('🛑 LocationTrackingService: Location tracking stopped');
//   }

//   Future<void> _getCurrentPosition() async {
//     if (await Geolocator.isLocationServiceEnabled()) {
//       try {
//         _currentPosition = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//       } catch (e) {
//         print('❌ Error getting location: $e');
//       }
//     }
//   }

//   void _sendLocationToServer() {
//     if (_currentPosition != null && _isConnected) {
//       final locationData = {
//         "appId": _appId,
//         "name": _name,
//         "userId": _userId ?? "unknown",
//         "profile": _profile,
//         "latitude": _currentPosition!.latitude,
//         "longitude": _currentPosition!.longitude,
//         "timestamp": DateTime.now().toIso8601String(),
//         "beaconLat":SingletonFunctionController().getlocalizedBeacon()?.properties?.latitude??"",
//         "beaconLng":SingletonFunctionController().getlocalizedBeacon()?.properties?.longitude??"",
//       };
//       _socket.emit('user-log-socket', locationData);
//     }
//   }

//   // ─── SOS ────────────────────────────────────────────────────────────────────

//   Future<void> sendSOS() async {
//     print('🆘 SOS triggered');

//     await _getCurrentPosition();

//     final sosPayload = {
//       "appId": _appId,
//       "name": _name ?? "Unknown",
//       "userId": _userId ?? "unknown",
//       "profile": _profile,
//       "type": "SOS",
//       "latitude": _currentPosition?.latitude ?? 0.0,
//       "longitude": _currentPosition?.longitude ?? 0.0,
//       "timestamp": DateTime.now().toIso8601String(),
//       "beaconLat":
//       SingletonFunctionController().getlocalizedBeacon()?.properties?.latitude ?? "",
//       "beaconLng":
//       SingletonFunctionController().getlocalizedBeacon()?.properties?.longitude ?? "",
//       "message": "User triggered SOS alert",
//     };

//     // ✅ Only emit if already connected — never call _socket.connect() manually.
//     // The socket manages its own reconnection via reconnection: true.
//     // Calling connect() mid-session resets the socket and causes double-disconnect.
//     if (_isConnected) {
//       _socket.emit('send-notification', sosPayload);
//       print('🆘 SOS emitted via socket');
//       Fluttertoast.showToast(msg: "🆘 SOS alert sent!");
//     } else {
//       // Socket not ready — fall back to HTTP
//       print('⚠️ Socket not connected, falling back to HTTP for SOS');
//       final httpSuccess = await _sendSOSViaHttp(sosPayload);
//       if (httpSuccess) {
//         print('✅ SOS sent via HTTP');
//         Fluttertoast.showToast(msg: "🆘 SOS alert sent!");
//       } else {
//         print('❌ SOS failed on all channels');
//         Fluttertoast.showToast(
//           msg: "❌ SOS failed. Please call emergency services directly.",
//         );
//       }
//     }
//   }

//   /// HTTP fallback for when the socket is not yet connected.
//   /// The 500 you saw earlier means the endpoint path was wrong —
//   /// update the path below to match your actual backend route.
//   Future<bool> _sendSOSViaHttp(Map<String, dynamic> payload) async {
//     // 👇 Replace with your real SOS/notification endpoint
//     final uri = Uri.parse("${AppConfig.baseUrl}/secured/notification/send");
//     try {
//       final response = await http
//           .post(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'x-access-token': _accessToken ?? '',
//           'Authorization': AppConfig.Authorization,
//         },
//         body: json.encode(payload),
//       )
//           .timeout(const Duration(seconds: 8));

//       print('🌐 HTTP SOS status: ${response.statusCode} body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return true;
//       } else if (response.statusCode == 403) {
//         _accessToken = await RefreshTokenAPI.refresh();
//         return await _sendSOSViaHttp(payload); // retry once after refresh
//       } else {
//         return false;
//       }
//     } catch (e) {
//       print('❌ HTTP SOS error: $e');
//       return false;
//     }
//   }

//   // ────────────────────────────────────────────────────────────────────────────

//   void dispose() {
//     stopTracking();
//     _socket.disconnect();
//     print('🗑️ LocationTrackingService: Disposed');
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
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
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  io.Socket? _socket;
  Timer? _locationTimer;
  Timer? _sosLiveLocationTimer; // ← separate timer for SOS live location
  Position? _currentPosition;
  bool _isTracking = false;
  bool _isConnected = false;
  bool _isSosActive = false; // ← tracks whether SOS live-share is running
  bool _isInitializingSocket = false;

  String? _userId;
  String? _name;
  String? _accessToken;
  String? _refreshToken;
  String _profile = "user";
  String get _appId =>
      "com.iwayplus.aiimsjammu-${_profile == "driver" ? "vehicle" : "user"}";

  bool get isTracking => _isTracking;
  bool get isConnected => _isConnected;
  bool get isSosActive => _isSosActive;
  Position? get currentPosition => _currentPosition;

  // ─── INIT ────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    print('🔧 [INIT] initialize() called');
    await _loadUserData();
    await _checkLocationPermission();
    print(
        '🔧 [INIT] initialize() complete — socket NOT yet created (lazy init)');
  }

  Future<void> _loadUserData() async {
    print('📦 [LOAD] Loading user data from Hive...');
    final signInBox = await Hive.openBox('SignInDatabase');
    final userBox = await Hive.openBox('user');
    _userId = signInBox.get("userId");
    _accessToken = signInBox.get("accessToken");
    print("access token : $_accessToken");
    _refreshToken = signInBox.get("refreshToken");
    _name = userBox.get("name");
    _profile = signInBox.get("profile") ?? "user";

    print('📦 [LOAD] userId=$_userId | profile=$_profile | name=$_name');

    if (_userId == null || _profile == "user" || _name == null) {
      print('📦 [LOAD] Missing fields — fetching from API...');
      await _fetchUserDetailsFromAPI(signInBox, userBox);
    } else {
      print('📦 [LOAD] All required fields present, skipping API fetch');
    }
  }

  Future<void> _fetchUserDetailsFromAPI(Box signInBox, Box userBox) async {
    final String baseUrl = "${AppConfig.baseUrl}/secured/user/get";
    print('🌐 [API] Fetching user details from $baseUrl');
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': _accessToken ?? '',
        },
      );
      print('🌐 [API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        _userId = responseBody['_id'];
        _profile = responseBody['userTypeForTracking'];
        _name = responseBody["name"];
        print(
            '🌐 [API] Got → userId=$_userId | profile=$_profile | name=$_name');
        await signInBox.put("userId", _userId);
        await signInBox.put("profile", _profile);
        await userBox.put("name", _name);
        print('📦 [HIVE] Saved userId, profile, name to Hive');
      } else if (response.statusCode == 403) {
        print('🔑 [API] 403 — refreshing token and retrying...');
        String newToken = await RefreshTokenAPI.refresh();
        _accessToken = newToken;
        await _fetchUserDetailsFromAPI(signInBox, userBox);
        print("access Token :$_accessToken");
      } else {
        print(
            '❌ [API] Unexpected status: ${response.statusCode} | body: ${response.body}');
      }
    } catch (e) {
      print('❌ [API] Exception in _fetchUserDetailsFromAPI: $e');
    }
  }

  // ─── SOCKET (Lazy — created only when SOS is triggered) ──────────────────────

  /// Called ONLY when the SOS button is pressed.
  /// Creates a fresh socket if one doesn't exist, then connects.

  Future<void> _initializeSocket() async {
    if (_isInitializingSocket) {
      print('⚠️ [SOCKET] Already initializing, skipping duplicate call');
      return;
    }
    if (_socket != null && _isConnected) {
      print('✅ Already connected, skipping');
      return;
    }

    _isInitializingSocket = true;

    try {
      if (_socket != null) {
        print('⚠️ Dead socket — destroying and recreating...');
        _socket!.dispose();
        _socket = null;
      }

      print('🔑 [SOCKET] Refreshing token before connect...');
      try {
        _accessToken = await RefreshTokenAPI.refresh();
        print('🔑 [SOCKET] Token refreshed: $_accessToken');
      } catch (e) {
        print('❌ [SOCKET] Token refresh failed: $e');
      }

      // ─── DIAGNOSTIC BLOCK ───────────────────────────────────────────────────
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 [DIAG] AppConfig.baseUrl = "${AppConfig.baseUrl}"');
      print('🔍 [DIAG] Token (first 30 chars) = "${_accessToken?.substring(0, 30)}..."');

      // Test 1: Basic server reachability
      print('🏓 [DIAG] Test 1 — Basic reachability...');
      try {
        final basicRes = await http.get(
          Uri.parse(AppConfig.baseUrl),
        ).timeout(const Duration(seconds: 5));
        print('🏓 [DIAG] Test 1 PASSED — status: ${basicRes.statusCode}');
      } catch (e) {
        print('❌ [DIAG] Test 1 FAILED — server unreachable: $e');
        print('❌ [DIAG] CHECK: Is the device on the correct WiFi/network?');
        print('❌ [DIAG] CHECK: Is AppConfig.baseUrl correct?');
      }

      // Test 2: Socket.IO polling handshake (no auth)
      print('🏓 [DIAG] Test 2 — Socket.IO polling endpoint (no auth)...');
      try {
        final pollRes = await http.get(
          Uri.parse('${AppConfig.baseUrl}/socket.io/?EIO=4&transport=polling'),
        ).timeout(const Duration(seconds: 5));
        print('🏓 [DIAG] Test 2 status: ${pollRes.statusCode}');
        print('🏓 [DIAG] Test 2 body: ${pollRes.body}');
        if (pollRes.statusCode == 200) {
          print('✅ [DIAG] Socket.IO endpoint reachable — server is UP');
        } else {
          print('⚠️ [DIAG] Unexpected status — server may use custom path or reject unauthenticated polling');
        }
      } catch (e) {
        print('❌ [DIAG] Test 2 FAILED: $e');
        print('❌ [DIAG] Socket.IO endpoint not reachable at all');
      }

      // Test 3: Socket.IO polling with token in query
      print('🏓 [DIAG] Test 3 — Socket.IO polling WITH token...');
      try {
        final authPollRes = await http.get(
          Uri.parse('${AppConfig.baseUrl}/socket.io/?EIO=4&transport=polling&token=${_accessToken}&accessToken=${_accessToken}'),
          headers: {
            'x-access-token': _accessToken ?? '',
          },
        ).timeout(const Duration(seconds: 5));
        print('🏓 [DIAG] Test 3 status: ${authPollRes.statusCode}');
        print('🏓 [DIAG] Test 3 body: ${authPollRes.body}');
        if (authPollRes.statusCode == 200) {
          print('✅ [DIAG] Auth polling works — token is accepted');
        } else if (authPollRes.statusCode == 401 || authPollRes.statusCode == 403) {
          print('❌ [DIAG] Token REJECTED by server — auth key name mismatch');
        }
      } catch (e) {
        print('❌ [DIAG] Test 3 FAILED: $e');
      }

      // Test 4: Check if a namespace is required (e.g. /tracking, /sos)
      print('🏓 [DIAG] Test 4 — Checking common namespaces...');
      for (final ns in ['/tracking', '/sos', '/live', '/socket']) {
        // try {
        //   final nsRes = await http.get(
        //     Uri.parse('${AppConfig.baseUrl}$ns/socket.io/?EIO=4&transport=polling'),
        //   ).timeout(const Duration(seconds: 3));
        //   print('🏓 [DIAG] Namespace "$ns" → status: ${nsRes.statusCode} | body: ${nsRes.body.substring(0, nsRes.body.length.clamp(0, 80))}');
        // } catch (e) {
        //   print('🏓 [DIAG] Namespace "$ns" → unreachable: $e');
        // }
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // ────────────────────────────────────────────────────────────────────────

      print('🔌 [SOCKET] Creating new socket → ${AppConfig.baseUrl}');

      // _socket = IO.io(
      //   AppConfig.baseUrl,
      //   IO.OptionBuilder()
      //       .setTransports(['polling', 'websocket'])
      //       .setAuth({
      //     'x-access-token': _accessToken,
      //     // 'accessToken': _accessToken,
      //   })
      //       .setExtraHeaders({
      //     'x-access-token': _accessToken ?? '',
      //   })
      //       .setQuery({
      //     // 'accessToken': _accessToken,
      //     'x-access-token': _accessToken,
      //   })
      //       .enableAutoConnect()
      //       .enableReconnection()
      //       .setReconnectionAttempts(3)
      //       .setReconnectionDelay(2000)
      //       .setTimeout(10000)
      //       .build(),
      // );

      _socket = IO.io(
        AppConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['polling','websocket'])
            .disableAutoConnect()
            .setExtraHeaders({
          'x-access-token': _accessToken ?? '',
        })
            .setAuth({
          'token': _accessToken ?? '',
        })
            .setQuery({
          'x-access-token': _accessToken ?? '',
          'token': _accessToken ?? '',
        })
            .enableForceNew()
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        _isConnected = true;
        print('✅ [SOCKET] Connected | id: ${_socket?.id}');
        _startSosLiveLocation();
      });

      _socket!.onDisconnect((reason) {
        _isConnected = false;
        print('⚠️ [SOCKET] Disconnected | reason: $reason');
      });

      _socket!.onConnectError((data) {
        _isConnected = false;
        print('❌ [SOCKET] onConnectError: $data');
        print('❌ [SOCKET] This means the socket reached the server but was rejected');
        print('❌ [SOCKET] Likely cause: wrong auth key, wrong namespace, or CORS');
      });

      _socket!.onError((data) {
        print('❌ [SOCKET] Socket Error: $data');
        print('❌ [SOCKET] This is a server-side error after connection');
      });

      _socket!.onAny((event, data) {
        print('📦 [SOCKET] Event: $event | data: $data');
      });

      print('🔌 [SOCKET] Socket initialized, waiting for connection...');
      print('🔌 [SOCKET] Socket connected property right now: ${_socket?.connected}');
    } finally {
      _isInitializingSocket = false;
    }
  }

  // ─── REGULAR LOCATION TRACKING (unchanged) ───────────────────────────────────

  Future<bool> _checkLocationPermission() async {
    print('📍 [PERM] Checking location permission...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ [PERM] Location services disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('📍 [PERM] Current permission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('📍 [PERM] After request: $permission');
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) {
      print('❌ [PERM] Permission permanently denied');
      return false;
    }

    print('✅ [PERM] Location permission granted');
    await _getCurrentPosition();
    return true;
  }

  void startTracking() {
    print('▶️ [TRACK] startTracking() called');
    _locationTimer?.cancel();
    _isTracking = true;
    _getCurrentPosition().then((_) => _sendLocationToServer());

    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      print('⏱️ [TRACK] Timer tick #${timer.tick} — fetching position...');
      await _getCurrentPosition();
      _sendLocationToServer();
    });
    print('📍 [TRACK] Location tracking started (interval: 3s)');
  }

  void stopTracking() {
    print('⏹️ [TRACK] stopTracking() called');
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;
    print('🛑 [TRACK] Location tracking stopped');
  }

  Future<void> _getCurrentPosition() async {
    print('📡 [GPS] Fetching current position...');
    if (await Geolocator.isLocationServiceEnabled()) {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print(
            '📡 [GPS] Got position → lat: ${_currentPosition!.latitude}, lng: ${_currentPosition!.longitude}');
      } catch (e) {
        print('❌ [GPS] Error getting location: $e');
      }
    } else {
      print('❌ [GPS] Location service not enabled');
    }
  }

  void _sendLocationToServer() {
    if (_currentPosition != null && _isConnected) {
      final locationData = {
        "appId": _appId,
        "name": _name,
        "userId": _userId ?? "unknown",
        "profile": _profile,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude,
        "timestamp": DateTime.now().toIso8601String(),
        "beaconLat": SingletonFunctionController()
                .getlocalizedBeacon()
                ?.properties
                ?.latitude ??
            "",
        "beaconLng": SingletonFunctionController()
                .getlocalizedBeacon()
                ?.properties
                ?.longitude ??
            "",
      };
      print('📤 [TRACK-EMIT] Emitting user-log-socket → $locationData');
      _socket!.emit('user-log-socket', locationData);
    } else {
      print(
          '⚠️ [TRACK-EMIT] Skipped — position: $_currentPosition | connected: $_isConnected');
    }
  }

  // ─── SOS ────────────────────────────────────────────────────────────────────

  /// Called by the SOS button on screen.
  /// Step 1: Loads user data (if not loaded)
  /// Step 2: Initializes socket (lazy)
  /// Step 3: On socket connect → _startSosLiveLocation() fires automatically
  Future<void> sendSOS() async {
    print('🆘 ─────────────────────────────────────────');
    print('🆘 [SOS] SOS button pressed!');
    print('🆘 ─────────────────────────────────────────');

    // Step 1 — make sure user data is loaded
    if (_userId == null || _name == null) {
      print('🆘 [SOS] User data missing — loading now...');
      await _loadUserData();
    } else {
      print('🆘 [SOS] User data ready → userId=$_userId | name=$_name');
    }

    // Step 2 — fetch current GPS position before anything else
    print('🆘 [SOS] Fetching current GPS position...');
    await _getCurrentPosition();
    print(
        '🆘 [SOS] Position → lat: ${_currentPosition?.latitude} | lng: ${_currentPosition?.longitude}');

    // Step 3 — initialize & connect socket (lazy, only on SOS)
    print('🆘 [SOS] Initializing socket...');
    _isSosActive = true;
    // _initializeSocket(); // onConnect callback triggers _startSosLiveLocation()
    await _initializeSocket();

    // Step 4 — if already connected (e.g. socket was alive from before),
    //           start live location immediately without waiting for onConnect
    if (_isConnected) {
      print('🆘 [SOS] Socket already connected — starting live location now');
      _startSosLiveLocation();
    } else {
      print(
          '🆘 [SOS] Waiting for socket to connect before starting live location...');
    }

    Fluttertoast.showToast(msg: "🆘 SOS activated — sharing live location...");
  }

  /// Starts a repeating timer that emits live location via `send-notification`.
  /// Called automatically once socket is connected.
  void _startSosLiveLocation() {
    if (!_isSosActive) {
      print(
          '⚠️ [SOS-LIVE] _startSosLiveLocation called but SOS is not active — aborting');
      return;
    }

    // Avoid double-starting
    if (_sosLiveLocationTimer != null && _sosLiveLocationTimer!.isActive) {
      print('⚠️ [SOS-LIVE] Timer already running, skipping re-start');
      return;
    }

    print(
        '🟢 [SOS-LIVE] Starting live location sharing via send-notification (interval: 3s)');

    // Send first payload immediately
    _emitSosLocation();

    _sosLiveLocationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      print('⏱️ [SOS-LIVE] Timer tick #${timer.tick}');
      await _getCurrentPosition();
      _emitSosLocation();
    });
  }

  /// Builds the SOS payload and emits it on `send-notification`.
  void _emitSosLocation() {
    if (!_isConnected || _socket == null) {
      print('⚠️ [SOS-EMIT] Socket not connected — skipping emit');
      return;
    }
    if (_currentPosition == null) {
      print('⚠️ [SOS-EMIT] No GPS position yet — skipping emit');
      return;
    }

    final sosPayload = {
      "appId": _appId,
      "name": _name ?? "Unknown",
      "userId": _userId ?? "unknown",
      "profile": _profile,
      "type": "SOS",
      "latitude": _currentPosition!.latitude,
      "longitude": _currentPosition!.longitude,
      "timestamp": DateTime.now().toIso8601String(),
      "beaconLat": SingletonFunctionController()
              .getlocalizedBeacon()
              ?.properties
              ?.latitude ??
          "",
      "beaconLng": SingletonFunctionController()
              .getlocalizedBeacon()
              ?.properties
              ?.longitude ??
          "",
      "message": "SOS — Live location update",
    };

    print('📤 [SOS-EMIT] Emitting on send-notification → $sosPayload');
    _socket!.emit('send-notification', sosPayload);
    print('✅ [SOS-EMIT] Emit done');
  }

  /// Call this when the user cancels / resolves the SOS.
  void stopSOS() {
    print('🛑 [SOS] stopSOS() called — stopping live location sharing');
    _isSosActive = false;
    _sosLiveLocationTimer?.cancel();
    _sosLiveLocationTimer = null;
    print('✅ [SOS] Live location sharing stopped');
    Fluttertoast.showToast(msg: "✅ SOS deactivated");
  }

  // ─── HTTP FALLBACK ───────────────────────────────────────────────────────────

  /// HTTP fallback for SOS when socket is unavailable.
  Future<bool> _sendSOSViaHttp(Map<String, dynamic> payload) async {
    final uri = Uri.parse("${AppConfig.baseUrl}/secured/notification/send");
    print('🌐 [HTTP-SOS] Sending SOS via HTTP → $uri');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-access-token': _accessToken ?? '',
              'Authorization': AppConfig.Authorization,
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 8));

      print(
          '🌐 [HTTP-SOS] Status: ${response.statusCode} | body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [HTTP-SOS] Success');
        return true;
      } else if (response.statusCode == 403) {
        print('🔑 [HTTP-SOS] 403 — refreshing token and retrying...');
        _accessToken = await RefreshTokenAPI.refresh();
        return await _sendSOSViaHttp(payload);
      } else {
        print('❌ [HTTP-SOS] Failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ [HTTP-SOS] Exception: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────

  void dispose() {
    print('🗑️ [DISPOSE] Disposing LocationTrackingService...');
    stopTracking();
    stopSOS();
    _socket?.disconnect();
    _socket = null;
    print('🗑️ [DISPOSE] Done');
  }
}
