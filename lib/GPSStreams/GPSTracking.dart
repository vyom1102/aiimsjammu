import 'dart:async';
import '../GPSService.dart';
import '../websocket/UserLog.dart';

class GpsTracking {
  StreamSubscription<Location>? _gpsSubscription;
  double uniqueLat = 0.0;
  double uniqueLng = 0.0;
  final ws = WebSocketService();


  Future<void> startTracking() async {
    _gpsSubscription = GPSService.locationStream.listen((Location location) {
      print("New Lat ${location.latitude} ${location.longitude}");
      if(location.latitude != uniqueLat && location.longitude != uniqueLng){
        ws.updateMessage({
          "userPosition.latitude": location.latitude,
          "userPosition.longitude": location.longitude,
        });
        print("WebSocketService().message");
        print(WebSocketService().message);

        uniqueLat = location.latitude;
        uniqueLng = location.longitude;
        print("uniqueLat $uniqueLat $uniqueLng ${WebSocketService().message["userPosition.latitude"]}");

      }

    }, onError: (error) {
      print("Error receiving GPS data: $error");
    });

  }

  void stopTracking() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }
}
