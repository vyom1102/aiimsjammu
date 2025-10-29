import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/pathState.dart';
import 'APIMODELS/landmark.dart';
import 'UserState.dart';

class LandmarkHighlighter {
  final UserState user;
  final double highlightRadiusMeters;

  LandmarkHighlighter({
    required this.user,
    this.highlightRadiusMeters = 10.0,
  });

  Set<Marker> getHighlightedMarkers() {
    if(!user.isnavigating){
      return Set();
    }
    return pathState.nearbyLandmarks
        .where((landmark) => _isWithinRadius(LatLng(user.lat, user.lng), LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!))))
        .map((landmark) => Marker(
      markerId: MarkerId(landmark.sId!),
      position: LatLng(double.parse(landmark.properties!.latitude!), double.parse(landmark.properties!.longitude!)),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: landmark.name),
    ))
        .toSet();
  }

  bool _isWithinRadius(LatLng user, LatLng target) {
    const double earthRadius = 6371000; // in meters
    double dLat = _degToRad(target.latitude - user.latitude);
    double dLng = _degToRad(target.longitude - user.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(user.latitude)) *
            cos(_degToRad(target.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance <= highlightRadiusMeters;
  }

  double _degToRad(double deg) => deg * pi / 180.0;
}