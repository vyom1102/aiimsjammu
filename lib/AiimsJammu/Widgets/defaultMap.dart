
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class defaultMap extends StatefulWidget {

  @override
  State<defaultMap> createState() => _defaultMapState();
}

class _defaultMapState extends State<defaultMap> {
  final LatLng _center =
  const LatLng(32.5637551,
      75.0341691);

  late GoogleMapController mapController;

  bool downloadingData = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
      GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('candor_techspace'),
            position: _center,
            infoWindow: InfoWindow(
              title: 'Candor TechSpace Sec 48',
              snippet: 'Gurugram, Haryana',
            ),
          ),
        },
      )
    );
  }
}