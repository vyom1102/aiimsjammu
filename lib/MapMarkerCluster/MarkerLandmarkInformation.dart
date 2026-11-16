import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../EventModel/ConferenceMapper.dart';


class MarkerLandmarkInformation {
  final String name;
  final LatLng position;
  final String landmarkType;
  final String buildingID;
  final String sID;
  final String polyId;
  final int floor;
  final int? coordinateX;
  final int? coordinateY;
  renderDetails? renderDetail;

  MarkerLandmarkInformation({
    required this.name,
    required this.position,
    this.landmarkType="",
    required this.buildingID,
    required this.sID,
    required this.polyId,
    required this.floor,
    required this.coordinateX,
    required this.coordinateY,
    required this.renderDetail
  });

  @override
  String toString() => 'Landmark(name: $name, position: $position)';
}