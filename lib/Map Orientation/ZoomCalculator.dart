import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FitBoundsCalculator {
  static const int TILE_SIZE = 256;

  static double mercatorX(double lon) => (lon + 180) / 360;
  static double mercatorY(double lat) {
    final rad = lat * pi / 180;
    return 0.5 - log((1 + sin(rad)) / (1 - sin(rad))) / (4 * pi);
  }

  static double _calculateZoom(double delta, double screenSizePx, double paddingRatio) {
    final double worldSize = TILE_SIZE.toDouble();
    return log(worldSize / (delta * screenSizePx * paddingRatio)) / log(2);
  }

  static double calculateZoom({
    required LatLng center,
    required LatLng element,
    required Size screenSize,
    double paddingRatio = 0.5,
  }) {
    double centerX = mercatorX(center.longitude);
    double targetX = mercatorX(element.longitude);
    double dx = (targetX - centerX).abs();
    if (dx > 0.5) dx = 1.0 - dx;

    double centerY = mercatorY(center.latitude);
    double targetY = mercatorY(element.latitude);
    double dy = (targetY - centerY).abs();

    // Compute zoom for both directions
    double zoomX = _calculateZoom(dx, screenSize.width, paddingRatio);
    double zoomY = _calculateZoom(dy, screenSize.height, paddingRatio);

    double zoom = min(zoomX, zoomY);
    return zoom.clamp(0.0, 16.5);
  }
}
