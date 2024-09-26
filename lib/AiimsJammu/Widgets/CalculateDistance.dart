import 'package:geolocator/geolocator.dart';

Future<double> calculateDistance(
    String destinationLatitudeStr,
    String destinationLongitudeStr
    ) async {
  try {
    print("latlong received:");
    print(destinationLatitudeStr);
    print(destinationLongitudeStr);

    double destinationLatitude = double.parse(destinationLatitudeStr);
    double destinationLongitude = double.parse(destinationLongitudeStr);

    print("Parsed latlong:");
    print("Latitude: $destinationLatitude, Longitude: $destinationLongitude");

    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return 0;
      }
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double currentLatitude = currentPosition.latitude;
    double currentLongitude = currentPosition.longitude;

    double distanceInMeters = Geolocator.distanceBetween(
        currentLatitude,
        currentLongitude,
        destinationLatitude,
        destinationLongitude
    );

    return distanceInMeters;
  } catch (e) {
    print('Error occurred while calculating distance: $e');
    return 0;
  }
}
