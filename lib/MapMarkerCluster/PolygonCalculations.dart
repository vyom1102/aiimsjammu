import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class PolygonCalculations {
  PolygonCalculations._internal(); // private constructor
  static final PolygonCalculations _instance = PolygonCalculations._internal();
  factory PolygonCalculations() => _instance;


  Map<String, List<LatLng>> _landmarkWithLatLng = {};

  Map<String, List<LatLng>> get landmarkWithLatLng => _landmarkWithLatLng;

  set landmarkWithLatLng(Map<String, List<LatLng>> value) {
    _landmarkWithLatLng = value;
  }

  Map<String, List<LatLng>> _landmarkWithPolygonPoints = {};

  Map<String, List<LatLng>> get landmarkWithPolygonPoints => _landmarkWithPolygonPoints;

  set landmarkWithPolygonPoints(Map<String, List<LatLng>> value){
    _landmarkWithPolygonPoints = value;
  }

  LatLng midpoint(LatLng a, LatLng b) {
    return LatLng(
      (a.latitude + b.latitude) / 2,
      (a.longitude + b.longitude) / 2,
    );
  }

  double distance(LatLng a, LatLng b) {
    double dx = a.latitude - b.latitude;
    double dy = a.longitude - b.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  double getRotationFromLatLng(LatLng start, LatLng end) {
    return Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  double calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * pi / 180.0;
    final double lon1 = start.longitude * pi / 180.0;
    final double lat2 = end.latitude * pi / 180.0;
    final double lon2 = end.longitude * pi / 180.0;

    final double dLon = lon2 - lon1;

    final double y = sin(dLon) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) -
        sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x);
    bearing = bearing * 180.0 / pi;
    return (bearing + 360.0) % 360.0 + 90; // Normalize to 0° → 360°
  }
  List<LatLng> calculateRectangleData(List<LatLng> points) {
    // Assume points order: A(bottom-left), B(top-left), C(top-right), D(bottom-right)
    LatLng A = points[0];
    LatLng B = points[1];
    LatLng C = points[2];
    LatLng D = points[3];

    // Distances
    double AB = distance(A, B);
    double BC = distance(B, C);
    double CD = distance(C, D);
    double DA = distance(D, A);

    // Check which side is greater → length, smaller → breadth
    bool isABLength = AB > DA; // If AB > DA, AB is length else DA is length

    LatLng lengthMidTop, lengthMidBottom, breadthMidTop, breadthMidBottom;

    if (isABLength) {
      // AB and CD are length sides
      lengthMidTop = midpoint(B, C);
      lengthMidBottom = midpoint(A, D);

      // AD and BC are breadth sides
      breadthMidTop = midpoint(B, A);
      breadthMidBottom = midpoint(C, D);
    } else {
      // AD and BC are length sides
      lengthMidTop = midpoint(B, A);
      lengthMidBottom = midpoint(C, D);

      // AB and CD are breadth sides
      breadthMidTop = midpoint(B, C);
      breadthMidBottom = midpoint(A, D);
    }


    // Return breadth points (as you asked)
    return [lengthMidTop, lengthMidBottom];
  }

  List<LatLng> getPolygonMajorAxisLatLng(List<LatLng> polygonPoints) {
    // print("polygonPoints ${polygonPoints.first}\n${polygonPoints.last}");
    double earthRadius = 6371000;
    if (polygonPoints.isEmpty) throw ArgumentError('Polygon cannot be empty');
    if (polygonPoints.length < 3) throw ArgumentError('Polygon must have at least 3 points');

    // Reference point
    double lat0 = polygonPoints[0].latitude * pi / 180;
    double lng0 = polygonPoints[0].longitude * pi / 180;

    // Convert to local Cartesian
    List<Point<double>> points = polygonPoints.map((p) {
      double latRad = p.latitude * pi / 180;
      double lngRad = p.longitude * pi / 180;
      double x = (lngRad - lng0) * cos(lat0) * earthRadius;
      double y = (latRad - lat0) * earthRadius;
      return Point<double>(x, y);
    }).toList();

    // --- Step 1: Calculate centroid ---
    double signedArea = 0, cx = 0, cy = 0;
    for (int i = 0; i < points.length; i++) {
      Point<double> cur = points[i];
      Point<double> nxt = points[(i + 1) % points.length];
      double cross = cur.x * nxt.y - nxt.x * cur.y;
      signedArea += cross;
      cx += (cur.x + nxt.x) * cross;
      cy += (cur.y + nxt.y) * cross;
    }
    signedArea *= 0.5;
    if (signedArea.abs() < 1e-10) {
      throw ArgumentError('Degenerate polygon with zero area');
    }
    cx = cx / (6 * signedArea);
    cy = cy / (6 * signedArea);
    Point<double> centroid = Point(cx, cy);

    // --- Step 2: PCA for minor axis direction ---
    double meanX = centroid.x, meanY = centroid.y;
    double xx = 0, yy = 0, xy = 0;
    for (var p in points) {
      double dx = p.x - meanX;
      double dy = p.y - meanY;
      xx += dx * dx;
      yy += dy * dy;
      xy += dx * dy;
    }
    double trace = xx + yy;
    double det = xx * yy - xy * xy;
    double discriminant = (trace * trace) / 4 - det;
    if (discriminant < 0) discriminant = 0; // numerical safety

    double lambda2 = trace / 2 - sqrt(discriminant); // Minor eigenvalue (smaller)

    // Find eigenvector for smallest eigenvalue (minor axis)
    double vx, vy;
    if (xy.abs() > 1e-9) {
      vx = lambda2 - yy;
      vy = xy;
    } else if ((lambda2 - xx).abs() > 1e-9) {
      vx = lambda2 - xx;
      vy = 0;
    } else {
      // If covariance matrix is nearly diagonal/identity
      vx = 0;
      vy = 1;
    }
    double norm = sqrt(vx * vx + vy * vy);
    if (norm < 1e-10) {
      // Fallback direction if eigenvector calculation fails
      vx = 0;
      vy = 1;
    } else {
      vx /= norm;
      vy /= norm;
    }

    // --- Step 3: Find edge centers where minor axis intersects ---
    List<Point<double>> edgeCenters = [];
    for (int i = 0; i < points.length; i++) {
      Point<double> p1 = points[i];
      Point<double> p2 = points[(i + 1) % points.length];

      // Line through centroid: P = centroid + t * direction
      // Edge: Q = p1 + s * (p2 - p1)
      // Solve: centroid + t * (vx, vy) = p1 + s * (p2 - p1)
      double edgeDx = p2.x - p1.x;
      double edgeDy = p2.y - p1.y;

      // Determinant of the 2x2 system
      double det = vx * edgeDy - vy * edgeDx;
      if (det.abs() < 1e-10) continue; // Lines are parallel

      // Solve for s (parameter along edge)
      double dx = centroid.x - p1.x;
      double dy = centroid.y - p1.y;
      double s = (vx * dy - vy * dx) / det;

      // Check if intersection is within the edge segment
      if (s >= 0 && s <= 1) {
        // Instead of using intersection point, use the center of this edge
        double centerX = (p1.x + p2.x) / 2;
        double centerY = (p1.y + p2.y) / 2;
        edgeCenters.add(Point(centerX, centerY));
      }
    }

    if (edgeCenters.length < 2) {
      // Fallback: return centroid as both points
      LatLng centroidLatLng = toLatLng(centroid, lat0, lng0, earthRadius);
      return [centroidLatLng, centroidLatLng];
    }

    // --- Step 4: Find the two edge centers farthest apart ---
    Point<double> farthest1 = edgeCenters[0];
    Point<double> farthest2 = edgeCenters[1];
    num maxDistSq = pow(farthest2.x - farthest1.x, 2) + pow(farthest2.y - farthest1.y, 2);

    for (int i = 0; i < edgeCenters.length; i++) {
      for (int j = i + 1; j < edgeCenters.length; j++) {
        num distSq = pow(edgeCenters[j].x - edgeCenters[i].x, 2) +
            pow(edgeCenters[j].y - edgeCenters[i].y, 2);
        if (distSq > maxDistSq) {
          maxDistSq = distSq;
          farthest1 = edgeCenters[i];
          farthest2 = edgeCenters[j];
        }
      }
    }

    // Convert back to LatLng
    return [
      toLatLng(farthest1, lat0, lng0, earthRadius),
      toLatLng(farthest2, lat0, lng0, earthRadius)
    ];
  }

  LatLng toLatLng(Point<double> p, double lat0, double lng0, double earthRadius) {
    double lat = (p.y / earthRadius + lat0) * 180 / pi;
    double lng = (p.x / (earthRadius * cos(lat0)) + lng0) * 180 / pi;
    return LatLng(lat, lng);
  }

}

class Rectangle {
  final List<Point> corners;
  final double width;
  final double height;
  final double angle;

  Rectangle(this.corners, this.width, this.height, this.angle);
}

class RectangleResult {
  final double bearing;
  final List<LatLng> longestSide;

  RectangleResult(this.bearing, this.longestSide);
}

RectangleResult findBestFitRectangleBearing(List<LatLng> polygon) {
  if (polygon.length < 3) {
    throw ArgumentError('Polygon must have at least 3 points');
  }

  // Convert to local Cartesian coordinates (meters)
  final centroid = _getCentroid(polygon);
  final localPoints = polygon.map((p) => _latLngToLocal(p, centroid)).toList();

  // Find convex hull (for minimum bounding rectangle)
  final hull = _convexHull(localPoints);

  // Find minimum area bounding rectangle using rotating calipers
  final rectData = _minAreaRectangle(hull);

  // Determine longest axis
  final isWidthLonger = rectData.width >= rectData.height;
  final longestAxisAngle = isWidthLonger
      ? rectData.angle
      : (rectData.angle + 90) % 360;

  // Get the corners of the rectangle in local coordinates
  final rectCorners = rectData.corners;

  // Determine which side is the longest
  List<Point> longestSideLocal;
  if (isWidthLonger) {
    // Use the first edge (bottom side)
    longestSideLocal = [rectCorners[0], rectCorners[1]];
  } else {
    // Use the second edge (left side)
    longestSideLocal = [rectCorners[1], rectCorners[2]];
  }

  // Convert back to LatLng
  final longestSide = longestSideLocal
      .map((p) => _localToLatLng(p, centroid))
      .toList();

  // Convert to global bearing (0° = North, clockwise)
  var bearing = _normalizeBearing(longestAxisAngle + 90);

  // if(bearing > 180){
  //   bearing -= 180;
  // }

  return RectangleResult(bearing, longestSide);
}

Point _latLngToLocal(LatLng point, LatLng origin) {
  final latRad = origin.latitude * pi / 180;
  final dLat = point.latitude - origin.latitude;
  final dLon = point.longitude - origin.longitude;

  final x = dLon * 111320.0 * cos(latRad);
  final y = dLat * 110540.0;

  return Point(x, y);
}

LatLng _localToLatLng(Point point, LatLng origin) {
  final latRad = origin.latitude * pi / 180;

  final dLon = point.x / (111320.0 * cos(latRad));
  final dLat = point.y / 110540.0;

  return LatLng(origin.latitude + dLat, origin.longitude + dLon);
}

LatLng _getCentroid(List<LatLng> polygon) {
  final lat = polygon.map((p) => p.latitude).reduce((a, b) => a + b) / polygon.length;
  final lon = polygon.map((p) => p.longitude).reduce((a, b) => a + b) / polygon.length;
  return LatLng(lat, lon);
}

List<Point> _convexHull(List<Point> points) {
  if (points.length < 3) return points;

  final sorted = List<Point>.from(points)
    ..sort((a, b) {
      final cmp = a.x.compareTo(b.x);
      return cmp != 0 ? cmp : a.y.compareTo(b.y);
    });

  double cross(Point o, Point a, Point b) {
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x).toDouble();
  }

  final lower = <Point>[];
  for (final p in sorted) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower[lower.length - 1], p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }

  final upper = <Point>[];
  for (final p in sorted.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper[upper.length - 1], p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }

  lower.removeLast();
  upper.removeLast();

  return [...lower, ...upper];
}

Rectangle _minAreaRectangle(List<Point> hull) {
  double minArea = double.infinity;
  Rectangle? bestRect;

  for (int i = 0; i < hull.length; i++) {
    final p1 = hull[i];
    final p2 = hull[(i + 1) % hull.length];

    // Edge vector
    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;
    final edgeAngle = atan2(dy, dx);

    // Rotate all points to align edge with x-axis
    final rotated = hull.map((p) {
      final rx = (p.x - p1.x) * cos(-edgeAngle) - (p.y - p1.y) * sin(-edgeAngle);
      final ry = (p.x - p1.x) * sin(-edgeAngle) + (p.y - p1.y) * cos(-edgeAngle);
      return Point(rx, ry);
    }).toList();

    // Find bounding box in rotated space
    final minX = rotated.map((p) => p.x).reduce(min);
    final maxX = rotated.map((p) => p.x).reduce(max);
    final minY = rotated.map((p) => p.y).reduce(min);
    final maxY = rotated.map((p) => p.y).reduce(max);

    final width = maxX - minX;
    final height = maxY - minY;
    final area = width * height;

    if (area < minArea) {
      minArea = area;
      // Angle in degrees from positive x-axis (East)
      final angleDeg = edgeAngle * 180 / pi;

      // Calculate the four corners in rotated space
      final corners = [
        Point(minX, minY),
        Point(maxX, minY),
        Point(maxX, maxY),
        Point(minX, maxY),
      ];

      // Rotate corners back to original orientation
      final originalCorners = corners.map((c) {
        final ox = c.x * cos(edgeAngle) - c.y * sin(edgeAngle) + p1.x;
        final oy = c.x * sin(edgeAngle) + c.y * cos(edgeAngle) + p1.y;
        return Point(ox, oy);
      }).toList();

      bestRect = Rectangle(originalCorners, width, height, angleDeg);
    }
  }

  return bestRect!;
}

double _normalizeBearing(double angle) {
  // Convert from mathematical angle (0° = East, counter-clockwise)
  // to bearing (0° = North, clockwise)
  double bearing = 90 - angle;

  // Normalize to [0, 360)
  bearing = bearing % 360;
  if (bearing < 0) bearing += 360;

  return bearing;
}

void main() {
  PolygonCalculations polygonCalculations = PolygonCalculations();
  List<LatLng> rectanglePoints = [
    LatLng(28.94782561921551, 77.10167252671204), // A: bottom-left
    LatLng(28.947779107904847, 77.10167461236837), // B: top-left
    LatLng(28.9477807182756, 77.10172151099529),   // C: top-right
    LatLng(28.947827229586263, 77.10171942533896), // D: bottom-right
  ];

  polygonCalculations.calculateRectangleData(rectanglePoints);
}
