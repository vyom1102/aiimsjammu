import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIconWithAnchor {
  final BitmapDescriptor icon;
  final Offset anchor;
  MarkerIconWithAnchor(this.icon, this.anchor);
}