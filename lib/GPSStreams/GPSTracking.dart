import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../../GPS.dart';
import '../websocket/UserLog.dart';

class GpsService {
  final GPS gps = GPS();
  StreamSubscription<Position>? _subscription;
  double uniqueLat = 0.0;
  double uniqueLng = 0.0;
  final ws = WebSocketService();


  Future<void> startTracking() async {
    await gps.startGpsUpdates();
    _subscription = gps.positionStream.listen((position) {
      print("New Lat ${position.latitude} ${position.longitude}");
      if(position.latitude != uniqueLat && position.longitude != uniqueLng){
        ws.updateMessage({
          "userPosition.latitude": position.latitude,
          "userPosition.longitude": position.longitude,
        });

        uniqueLat = position.latitude;
        uniqueLng = position.longitude;
      }

    });
  }

  void stopTracking() {
    _subscription?.cancel();
  }
}
