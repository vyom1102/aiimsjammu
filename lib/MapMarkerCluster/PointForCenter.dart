import 'dart:math';


class PointForCenter {
  final double lat;
  final double lon;
  final String name;

  PointForCenter(this.lat, this.lon, this.name);

  @override
  String toString() => '$name($lat, $lon)';
}

class LeftMost {
  /// Returns which point is leftmost when looking in the direction of globalAngle
  /// Returns: -1 if p1 is leftmost, 1 if p2 is leftmost, 0 if equal
  int leftMostPoint(PointForCenter p1, PointForCenter p2, double globalAngle) {
    double angle = 0.0;
    if(globalAngle < 0){
      globalAngle += 360;
    }
    double diff = angle - globalAngle;
    if(diff < 0){
      diff += 360;
    }
    // print("angle $angle globalAngle $globalAngle diff $diff");
    if(diff < 180){
      return 1;
    }else{
      return -1;
    }
  }

  /// Alternative method using cross product (often more intuitive)
  int leftMostPointCrossProduct(PointForCenter p1, PointForCenter p2, double globalAngle) {
    // Convert to Cartesian coordinates
    double midLat = (p1.lat + p2.lat) / 2;
    double cosLat = cos(midLat * pi / 180.0);

    double x1 = (p1.lon - (p1.lon + p2.lon) / 2) * cosLat;
    double y1 = p1.lat - (p1.lat + p2.lat) / 2;
    double x2 = (p2.lon - (p1.lon + p2.lon) / 2) * cosLat;
    double y2 = p2.lat - (p1.lat + p2.lat) / 2;

    double theta = globalAngle * pi / 180.0;
    double dirX = cos(theta);
    double dirY = sin(theta);

    // Vector from p1 to p2
    double vecX = x2 - x1;
    double vecY = y2 - y1;

    // Cross product: positive means p2 is to the left of p1 when facing direction
    double crossProduct = dirX * vecY - dirY * vecX;

    if (crossProduct.abs() < 1e-9) return 0;
    return crossProduct > 0 ? 1 : -1;  // 1 means p2 is leftmost, -1 means p1 is leftmost
  }
}