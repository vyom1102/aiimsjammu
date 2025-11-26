import 'dart:math';

import 'Cell.dart';

class GPSTracker {
  // Store last GPS position
  double? _lastLatitude;
  double? _lastLongitude;

  /// Updates position and returns the bearing angle in degrees (0-360)
  /// Returns null if this is the first position or positions are identical
  ///
  /// Bearing: 0° = North, 90° = East, 180° = South, 270° = West
  double? updatePosition(double currentLat, double currentLon) {
    print("currentLat $currentLat currentLon $currentLon");
    // If no previous position, store current and return null
    if (_lastLatitude == null || _lastLongitude == null) {
      _lastLatitude = currentLat;
      _lastLongitude = currentLon;
      return null;
    }

    // Calculate bearing from last position to current position
    double angle = calculateBearing(
        _lastLatitude!,
        _lastLongitude!,
        currentLat,
        currentLon
    );

    // Update stored position
    _lastLatitude = currentLat;
    _lastLongitude = currentLon;

    return angle;
  }

  /// Calculates bearing between two GPS coordinates
  /// Returns angle in degrees (0-360) where 0° is North
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    // Convert to radians
    double lat1Rad = _degreesToRadians(lat1);
    double lat2Rad = _degreesToRadians(lat2);
    double lonDiff = _degreesToRadians(lon2 - lon1);

    // Calculate bearing using formula
    double y = sin(lonDiff) * cos(lat2Rad);
    double x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(lonDiff);

    double bearing = atan2(y, x);

    // Convert to degrees and normalize to 0-360
    double bearingDegrees = _radiansToDegrees(bearing);
    return (bearingDegrees + 360) % 360;
  }

  /// Resets the stored position
  void reset() {
    _lastLatitude = null;
    _lastLongitude = null;
  }

  /// Gets the last stored position
  Map<String, double?>? getLastPosition() {
    if (_lastLatitude == null || _lastLongitude == null) {
      return null;
    }
    return {
      'latitude': _lastLatitude,
      'longitude': _lastLongitude,
    };
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;
  double _radiansToDegrees(double radians) => radians * 180 / pi;
}

class AngleDeviationCalculator {

  /// Calculate the deviation between the segment's bearing and a target angle.
  ///
  /// [currentSegment] List containing start and end points
  /// [targetAngle] Target angle in degrees (0-360, where 0/360 is North)
  /// Returns deviation in degrees (-180 to 180)
  static double calculateDeviation(List<Cell> currentSegment, double targetAngle) {
    if (currentSegment.length < 2) {
      throw ArgumentError('Segment must have at least 2 points');
    }

    final start = currentSegment.first;
    final end = currentSegment.last;

    // Calculate bearing from start to end
    final bearing = calculateBearing(start, end);

    // Calculate deviation
    double deviation = bearing - targetAngle;

    // Normalize deviation to range [-180, 180]
    while (deviation > 180) {
      deviation -= 360;
    }
    while (deviation < -180) {
      deviation += 360;
    }

    return deviation;
  }

  /// Calculate the bearing (angle) from start point to end point.
  /// Uses the forward azimuth formula.
  ///
  /// [start] Starting cell
  /// [end] Ending cell
  /// Returns bearing in degrees (0-360, where 0/360 is North, 90 is East)
  static double calculateBearing(Cell start, Cell end) {
    final lat1 = _toRadians(start.lat);
    final lat2 = _toRadians(end.lat);
    final dLng = _toRadians(end.lng - start.lng);

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) -
        sin(lat1) * cos(lat2) * cos(dLng);

    final bearing = _toDegrees(atan2(y, x));

    // Normalize to 0-360
    return (bearing + 360) % 360;
  }

  /// Calculate absolute deviation (always positive).
  static double calculateAbsoluteDeviation(List<Cell> currentSegment, double targetAngle) {
    return calculateDeviation(currentSegment, targetAngle).abs();
  }

  // Helper methods
  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}