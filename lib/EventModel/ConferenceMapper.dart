import 'dart:math';

import 'APIModel/CardData.dart';
import 'APIModel/SessionModel.dart' as session_model;
import 'APIModel/SubEventsModel.dart' as sub_event_model;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Conferencemapper{
  CardData mapSubEventToCard(sub_event_model.Data subEvent, session_model.Data session){
    return CardData(
        sId: subEvent.sId,
      eventName: subEvent.title,
      startDate: session.date,
      endDate: session.date,
      startTime: convertUtcToLocal(subEvent.startTime),
      endTime: convertUtcToLocal(subEvent.endTime),
      genre: subEvent.tags,
      Data: subEvent.toJson(),
      categories: subEvent.type,
      speakerName: (subEvent.speakers != null && subEvent.speakers!.isNotEmpty)
          ? subEvent.speakers!
          .map((s) => s.speakerName)
          .where((name) => name != null)
          .cast<String>()
          .toList()
          : []
    );
  }
  String? convertUtcToLocal(String? utcString) {
    if(utcString == null){
      return null;
    }
    // Parse the UTC string to DateTime
    DateTime utcTime = DateTime.parse(utcString);

    // Convert to local time
    DateTime localTime = utcTime.toLocal();

    // Format the output (example: yyyy-MM-dd HH:mm)
    return localTime.toIso8601String();
  }
}

class renderDetails{
  String name;
  String logo;
  String booth;
  String color;
  String? boothType;
  bool preSet;

  renderDetails(this.name, this.logo, this.booth, this.color, this.boothType, {this.preSet = true});

  LatLng calculateRoomCenter(List<LatLng> polygonPoints) {
    double earthRadius = 6371000; // Earth radius in meters
    if (polygonPoints.isEmpty) {
      throw ArgumentError('Polygon points cannot be empty');
    }

    // Choose the first point as reference
    double lat0 = polygonPoints[0].latitude * pi / 180;
    double lng0 = polygonPoints[0].longitude * pi / 180;

    // Convert LatLng to local Cartesian (x, y) in meters
    List<Point<double>> points = polygonPoints.map((point) {
      double latRad = point.latitude * pi / 180;
      double lngRad = point.longitude * pi / 180;

      double x = (lngRad - lng0) * cos(lat0) * earthRadius;
      double y = (latRad - lat0) * earthRadius;

      return Point<double>(x, y);
    }).toList();

    // Compute centroid in local coordinates
    double signedArea = 0.0;
    double centroidX = 0.0;
    double centroidY = 0.0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      Point<double> current = points[i];
      Point<double> next = points[(i + 1) % n];

      double cross = (current.x * next.y) - (next.x * current.y);
      signedArea += cross;
      centroidX += (current.x + next.x) * cross;
      centroidY += (current.y + next.y) * cross;
    }

    signedArea *= 0.5;

    if (signedArea == 0) {
      // Fallback: Average lat/lng if polygon is degenerate
      double avgLat = 0.0;
      double avgLng = 0.0;
      for (var pt in polygonPoints) {
        avgLat += pt.latitude;
        avgLng += pt.longitude;
      }
      return LatLng(avgLat / n, avgLng / n);
    }

    centroidX /= (6 * signedArea);
    centroidY /= (6 * signedArea);

    // Convert centroid back to LatLng
    double centroidLat = (centroidY / earthRadius + lat0) * 180 / pi;
    double centroidLng = (centroidX / (earthRadius * cos(lat0)) + lng0) * 180 / pi;

    return LatLng(centroidLat, centroidLng);
  }


  double calculatePolygonArea(List<LatLng> polygonPoints) {
    if (polygonPoints.length < 3) return 0.0; // not a polygon

    double area = 0.0;
    for (int i = 0; i < polygonPoints.length; i++) {
      LatLng p1 = polygonPoints[i];
      LatLng p2 = polygonPoints[(i + 1) % polygonPoints.length];

      // convert lat/lng to radians
      double x1 = p1.longitude * (3.141592653589793 / 180.0);
      double y1 = p1.latitude * (3.141592653589793 / 180.0);
      double x2 = p2.longitude * (3.141592653589793 / 180.0);
      double y2 = p2.latitude * (3.141592653589793 / 180.0);

      area += (x2 - x1) * (2 +
          sin(y1) + sin(y2));
    }

    // Earth radius in meters
    const double earthRadius = 6378137.0;
    area = area * earthRadius * earthRadius / 2.0;

    return area.abs(); // ensure positive
  }

}
