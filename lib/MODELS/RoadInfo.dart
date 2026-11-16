import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class RoadInfo{
  LatLng positionFirst;
  LatLng positionSecond;
  String roadName;
  RoadInfo({required this.positionFirst,required this.positionSecond, required this.roadName});
}