import 'package:google_maps_flutter/google_maps_flutter.dart'; // for BitmapDescriptor

class Landmark {
  final String name;
  final LatLng position;
  final String landmarkType;
  final String buildingID;
  final String sID;

  Landmark({
    required this.name,
    required this.position,
    this.landmarkType="",
    required this.buildingID,
    this.sID =""
  });

  @override
  String toString() => 'Landmark(name: $name, position: $position)';
}
