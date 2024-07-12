import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/Elements/UserCredential.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:iwaymaps/pathState.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart' as PDM;
import 'API/PatchApi.dart';
import 'APIMODELS/patchDataModel.dart';
import 'Cell.dart';
import 'directionClass.dart';
import 'path.dart';

class tools {
  static List<PDM.Coordinates>? _cachedCordData;
  static List<Point<double>> corners = [];
  static double AngleBetweenBuildingandGlobalNorth = 0.0;

  static patchDataModel globalData = patchDataModel();

  static Future<void> fetchData() async {
    await patchAPI().fetchPatchData().then((value) {
      //print("object ${value.patchData!.coordinates.toString()}");
      _cachedCordData = value.patchData!.coordinates;
    });
  }

  static LatLng calculateRoomCenterinLatLng(List<LatLng> roomCoordinates) {
    double latSum = 0.0;
    double lngSum = 0.0;

    for (int i = 0; i < 4; i++) {
      latSum += roomCoordinates[i].latitude;
      lngSum += roomCoordinates[i].longitude;
    }

    double latCenter = latSum / 4;
    double lngCenter = lngSum / 4;
    return LatLng(latCenter, lngCenter);
  }

  static List<double> calculateRoomCenterinList(List<LatLng> roomCoordinates) {
    double latSum = 0.0;
    double lngSum = 0.0;

    for (int i = 0; i < 4; i++) {
      latSum += roomCoordinates[i].latitude;
      lngSum += roomCoordinates[i].longitude;
    }

    double latCenter = latSum / 4;
    double lngCenter = lngSum / 4;
    return [latCenter, lngCenter];
  }

  static String numericalToAlphabetical(int number) {
    switch (number) {
      case 0:
        return 'ground';
      case 1:
        return 'first';
      case 2:
        return 'second';
      case 3:
        return 'third';
      case 4:
        return 'fourth';
      case 5:
        return 'fifth';
      case 6:
        return 'sixth';
      case 7:
        return 'seventh';
      case 8:
        return 'eighth';
      case 9:
        return 'ninth';
      case 10:
        return 'tenth';
      default:
        return 'Invalid number';
    }
  }

  static int alphabeticalToNumerical(String word) {
    switch (word) {
      case 'ground':
        return 0;
      case 'first':
        return 1;
      case 'second':
        return 2;
      case 'third':
        return 3;
      case 'fourth':
        return 4;
      case 'fifth':
        return 5;
      case 'sixth':
        return 6;
      case 'seventh':
        return 7;
      case 'eighth':
        return 8;
      case 'ninth':
        return 9;
      case 'tenth':
        return 10;
      default:
        return -1; // Using -1 to indicate an invalid input
    }
  }


  static bool gotBhart = false;

  static List<double> localtoglobal(int x, int y,
      {PDM.patchDataModel? patchData = null}) {

    x = x - UserState.xdiff;
    y = y - UserState.ydiff;

    ////print("Wilsonlocaltoglobal started");
    PDM.patchDataModel Data = PDM.patchDataModel();
    if (patchData != null) {
      Data = patchData;
      if(patchData.patchData!.fileName == "004ef3cf-9294-4171-adc0-1554759d5400_IITCampus-BhartiSchool-ground_ground.png"){
        gotBhart = true;
      }

    } else {
      Data = globalData;
    }

    if(x>=100000000 || y>=100000000){
      var result = CoordinateConverter.localToGlobal(x.toDouble(), y.toDouble(), Data.patchData!.toJson());
      return[result["lat"]!,result["lng"]!];
    }

    int floor = 0;

    List<double> diff = [
      0,
      0,
      0,
    ];

    // {"coordinates" : patchDataApi().fetchedPatchData!.patchData!.coordinates! } ;

    List<Map<String, double>> ref = [
      {
        "lat": double.parse(Data.patchData!.coordinates![2].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![2].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![2].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![2].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![1].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![1].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![1].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![1].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![0].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![0].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![0].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![0].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![3].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![3].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![3].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![3].localRef!.lat!),
      },
    ];

    int leastLat = 0;
    for (int i = 0; i < ref.length; i++) {
      if (ref[i]["lat"] == ref[leastLat]["lat"]) {
        if (ref[i]["lon"]! > ref[leastLat]["lon"]!) {
          leastLat = i;
        }
      } else if (ref[i]["lat"]! < ref[leastLat]["lat"]!) {
        leastLat = i;
      }
    }

    int c1 = (leastLat == 3) ? 0 : (leastLat + 1);
    int c2 = (leastLat == 0) ? 3 : (leastLat - 1);
    int highLon = (ref[c1]["lon"]! > ref[c2]["lon"]!) ? c1 : c2;

    List<double> lengths = [];
    for (int i = 0; i < ref.length; i++) {
      double temp1;
      if (i == ref.length - 1) {
        temp1 = getHaversineDistance(ref[i], ref[0]);
      } else {
        temp1 = getHaversineDistance(ref[i], ref[i + 1]);
      }
      lengths.add(temp1);
    }

    double b = getHaversineDistance(ref[leastLat], ref[highLon]);
    Map<String, double> horizontal = obtainCoordinates(ref[leastLat], 0, b);

    double c = getHaversineDistance(ref[leastLat], horizontal);
    double a = getHaversineDistance(ref[highLon], horizontal);

    double out = acos((b * b + c * c - a * a) / (2 * b * c)) * 180 / pi;

    Map<String, double> localRef = {"localx": 0, "localy": 0};

    if (diff != null && diff.length > 1) {
      List<double> test = diff.where((d) => d == floor).toList();
      if (test.isNotEmpty) {
        localRef["localx"] = x - test[0];
        localRef["localy"] = y - test[1];
      } else {
        localRef["localx"] = x as double;
        localRef["localy"] = y as double;
      }
    } else {
      localRef["localx"] = x as double;
      localRef["localy"] = y as double;
    }

    double l = distance(ref[leastLat], ref[highLon]);
    double m = distance(localRef, ref[highLon]);
    double n = distance(ref[leastLat], localRef);

    double theta = acos((l * l + n * n - m * m) / (2 * l * n)) * 180 / pi;

    if (((l * l + n * n - m * m) / (2 * l * n) > 1) || m == 0 || n == 0) {
      theta = 0;
    }

    double ang = theta + out;
    double dist =
        distance(ref[leastLat], localRef) * 0.3048; // to convert to meter

    double ver = dist * sin(ang * pi / 180.0);
    double hor = dist * cos(ang * pi / 180.0);

    Map<String, double> finalCoords =
        obtainCoordinates(ref[leastLat], ver, hor);

    return [finalCoords["lat"]!, finalCoords["lon"]!];
  }

  static double getHaversineDistance(
      Map<String, double> firstLocation, Map<String, double> secondLocation) {
    const earthRadius = 6371; // km
    double diffLat =
        ((secondLocation["lat"]! - firstLocation["lat"]!) * pi) / 180;
    double difflon =
        ((secondLocation["lon"]! - firstLocation["lon"]!) * pi) / 180;
    double arc = cos((firstLocation["lat"]! * pi) / 180) *
            cos((secondLocation["lat"]! * pi) / 180) *
            sin(difflon / 2) *
            sin(difflon / 2) +
        sin(diffLat / 2) * sin(diffLat / 2);
    double line = 2 * atan2(sqrt(arc), sqrt(1 - arc));
    double distance = earthRadius * line * 1000;
    return distance;
  }

  static Map<String, double> obtainCoordinates(
      Map<String, double> reference, double vertical, double horizontal) {
    const double R = 6378137; // Earth’s radius, sphere
    double dLat = vertical / R;
    double dLon = horizontal / (R * cos((pi * reference["lat"]!) / 180));
    double latA = reference["lat"]! + (dLat * 180) / pi;
    double lonA = reference["lon"]! + (dLon * 180) / pi;
    return {"lat": latA, "lon": lonA};
  }

  static double distance(
      Map<String, double> first, Map<String, double> second) {
    double dist1 = pow((second["localy"]! - first["localy"]!), 2) as double;
    double dist2 = pow((second["localx"]! - first["localx"]!), 2) as double;
    double dist = dist1 + dist2;
    //  pow((second["localy"] - first["localy"]), 2) as double + pow((second["localx"] - first["localx"]), 2) as double ;
    return sqrt(dist);
  }

 static String angleToClocks(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }
    String currentDir = UserCredentials().getuserNavigationModeSetting();
    if (angle >= 337.5 || angle <= 22.5) {
      return (currentDir == 'Natural Direction') ? "Straight" : "12 o'clock";
    } else if (angle > 22.5 && angle <= 67.5) {
      return (currentDir == 'Natural Direction')
          ? "Slight Right"
          : "1-2 o'clock";
    } else if (angle > 67.5 && angle <= 112.5) {
      return (currentDir == 'Natural Direction') ? "Right" : "3 o'clock";
    } else if (angle > 112.5 && angle <= 157.5) {
      return (currentDir == 'Natural Direction')
          ? "Sharp Right"
          : "4-5 o'clock";
    } else if (angle > 157.5 && angle <= 202.5) {
      return (currentDir == 'Natural Direction') ? "U Turn" : "6 o'clock";
    } else if (angle > 202.5 && angle <= 247.5) {
      return (currentDir == 'Natural Direction') ? "Sharp Left" : "7-8 o'clock";
    } else if (angle > 247.5 && angle <= 292.5) {
      return (currentDir == 'Natural Direction') ? "Left" : "9 o'clock";
    } else if (angle > 292.5 && angle <= 337.5) {
      return (currentDir == 'Natural Direction')
          ? "Slight Left"
          : "10-11 o'clock";
    } else {
      return "None";
    }
  }

  static String angleToClocks2(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }
    String currentDir = UserCredentials().getuserNavigationModeSetting();
    if (angle >= 337.5 || angle <= 22.5) {
      return (currentDir == 'Natural Direction')
          ? "on your front"
          : "on 12 o'clock";
    } else if (angle > 22.5 && angle <= 67.5) {
      return (currentDir == 'Natural Direction')
          ? "on your Slight Right"
          : "on 1-2 o'clock";
    } else if (angle > 67.5 && angle <= 112.5) {
      return (currentDir == 'Natural Direction')
          ? "on your Right"
          : "on 3 o'clock";
    } else if (angle > 112.5 && angle <= 157.5) {
      return (currentDir == 'Natural Direction')
          ? "on your Sharp Right"
          : "on 4-5 o'clock";
    } else if (angle > 157.5 && angle <= 202.5) {
      return (currentDir == 'Natural Direction')
          ? "on your back"
          : "on 6 o'clock";
    } else if (angle > 202.5 && angle <= 247.5) {
      return (currentDir == 'Natural Direction')
          ? "on your Sharp Left"
          : "on 7-8 o'clock";
    } else if (angle > 247.5 && angle <= 292.5) {
      return (currentDir == 'Natural Direction')
          ? "on your Left"
          : "on 9 o'clock";
    } else if (angle > 292.5 && angle <= 337.5) {
      return (currentDir == 'Natural Direction')
          ? "on your Slight Left"
          : "on 10-11 o'clock";
    } else {
      return "on your None";
    }
  }

  static String angleToClocks3(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }
    String currentDir = UserCredentials().getuserNavigationModeSetting();
    if (angle >= 315 || angle <= 45) {
      return (currentDir == 'Natural Direction')
          ? "on your Front"
          : "on 12 o'clock";
    } else if (angle > 45 && angle <= 180) {
      return (currentDir == 'Natural Direction')
          ? "on your Right"
          : "3 o'clock";
    } else if (angle > 180 && angle <= 315) {
      return (currentDir == 'Natural Direction') ? "on your Left" : "9 o'clock";
    } else {
      return (currentDir == 'Natural Direction') ? "on your Back" : "6 o'clock";
    }
  }

  static String angleToClocksForNearestLandmarkToBeacon(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }
    String currentDir = UserCredentials().getuserNavigationModeSetting();

    if ((angle >= 315 && angle <= 360) || (angle >= 0 && angle <= 45)) {
      return (currentDir == 'Natural Direction') ? "Front" : "12 o'clock";
    } else if (angle > 45 && angle <= 135) {
      return (currentDir == 'Natural Direction') ? "Right" : "3 o'clock";
    } else if (angle > 135 && angle <= 225) {
      return (currentDir == 'Natural Direction') ? "Back" : "6 o'clock";
    } else if (angle > 225 && angle < 315) {
      return (currentDir == 'Natural Direction') ? "Left" : "9 o'clock";
    } else {
      return "None";
    }
  }

  static double calculateAngle(List<int> a, List<int> b, List<int> c) {
    double angle1 = atan2(b[1] - a[1], b[0] - a[0]);
    double angle2 = atan2(c[1] - b[1], c[0] - b[0]);

    double angle = (angle2 - angle1) * 180 / pi;

    if (angle < 0) {
      angle += 360;
    }

    return angle;
  }

  static double calculateAnglefifth(int node1, int node2, int node3, int cols) {
    List<int> a = [node1 % cols , node1 ~/cols];
    List<int> b = [node2 % cols , node2 ~/cols];
    List<int> c = [node3 % cols , node3 ~/cols];

    double angle1 = atan2(b[1] - a[1], b[0] - a[0]);
    double angle2 = atan2(c[1] - b[1], c[0] - b[0]);

    double angle = (angle2 - angle1) * 180 / pi;

    if (angle < 0) {
      angle += 360;
    }

    return angle;
  }

  static double calculateAngleBetweenVectors(double latA, double lonA, double latB, double lonB, double angle) {
    Map<String, double> c = computeNewPosition(latA, lonA, angle, 3);
    // Convert all latitudes and longitudes from degrees to radians
    latA = degreesToRadians(latA);
    lonA = degreesToRadians(lonA);
    latB = degreesToRadians(latB);
    lonB = degreesToRadians(lonB);
    double latC = degreesToRadians(c['latitude']!);
    double lonC = degreesToRadians(c['longitude']!);

    // Convert lat/lon to Cartesian coordinates (X, Y, Z)
    var ax = cos(latA) * cos(lonA);
    var ay = cos(latA) * sin(lonA);
    var az = sin(latA);

    var bx = cos(latB) * cos(lonB);
    var by = cos(latB) * sin(lonB);
    var bz = sin(latB);

    var cx = cos(latC) * cos(lonC);
    var cy = cos(latC) * sin(lonC);
    var cz = sin(latC);

    // Compute vector AB and AC
    var abx = bx - ax;
    var aby = by - ay;
    var abz = bz - az;

    var acx = cx - ax;
    var acy = cy - ay;
    var acz = cz - az;

    // Compute the cross product of vectors AB and AC
    var crossProductX = aby * acz - abz * acy;
    var crossProductY = abz * acx - abx * acz;
    var crossProductZ = abx * acy - aby * acx;

    // Compute the dot product of vectors AB and AC
    var dotProduct = abx * acx + aby * acy + abz * acz;

    // Compute the magnitudes of vectors AB and AC
    var magnitudeAB = sqrt(abx * abx + aby * aby + abz * abz);
    var magnitudeAC = sqrt(acx * acx + acy * acy + acz * acz);

    // Compute the angle between vectors AB and AC
    var angleRadians = atan2(sqrt(crossProductX * crossProductX + crossProductY * crossProductY + crossProductZ * crossProductZ), dotProduct);

    // Convert the angle from radians to degrees
    var angleDegrees = radiansToDegrees(angleRadians);

    // Ensure the angle is between 0 and 360 degrees
    if (crossProductZ < 0) {
      angleDegrees = 360 - angleDegrees;
    }

    return angleDegrees;
  }


  static double calculateAnglefifthForMultiBuilding(Cell node1, List<int> node2, Cell node3) {
    List<int> a = [node1.x , node1.y];
    List<int> b = node2;
    List<int> c = [node3.x , node3.y];

    print("AA $a");
    print("B $b");
    print("C $c");

    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];


    // Calculate the angle between the two vectors in radians
    double angleInRadians = atan2(ac[1], ac[0]) - atan2(ab[1], ab[0]);

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;

    // Ensure the angle is within [0, 360] degrees
    if (angleInDegrees < 0) {
      angleInDegrees += 360;
    }

    return angleInDegrees;
  }

  static double toRadians(double degree) {
    return degree * pi / 180.0;
  }

  static double calculateBearing(List<double> pointA, List<double> pointB) {
    double lat1 = toRadians(pointA[0]);
    double lon1 = toRadians(pointA[1]);
    double lat2 = toRadians(pointB[0]);
    double lon2 = toRadians(pointB[1]);

    double dLon = lon2 - lon1;

    double x = sin(dLon) * cos(lat2);
    double y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearingRadians = atan2(x, y);
    double bearingDegrees = bearingRadians * 180.0 / pi;
    // Normalize the bearing to be within the range 0° to 360°
    bearingDegrees = (bearingDegrees + 360) % 360;

    return bearingDegrees;
  }


  static double calculateAngleSecond(List<int> a, List<int> b, List<int> c) {
    // print("AAAAAA $a");
    // print("B $b");
    // print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];


    // //print("ab----${ab}");
    // //print("ac-----${ac}");

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;

    // //print(angleInDegrees);

    return angleInDegrees;
  }


    static double calculateAngle2(List<int> a, List<int> b, List<int> c) {
    // //print("AAAAAA $a");
    // //print("B $b");
    // //print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];

    // Calculate the angle between the two vectors in radians
    double angleInRadians = atan2(ac[1], ac[0]) - atan2(ab[1], ab[0]);

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;

    // Ensure the angle is within [0, 360] degrees
    if (angleInDegrees < 0) {
      angleInDegrees += 360;
    }

    return angleInDegrees;
  }


  static double calculateAngleBWUserandPath(UserState user, int node , int cols) {
    List<int> a = [user.showcoordX, user.showcoordY];
    List<int> tval = tools.eightcelltransition(user.theta);
    List<int> b = [user.showcoordX+tval[0], user.showcoordY+tval[1]];
    List<int> c = [node % cols , node ~/cols];

    // //print("A $a");
    // //print("B $b");
    // //print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the cross product of the two vectors
    double crossProduct = ab[0] * ac[1].toDouble() - ab[1] * ac[0].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Check the sign of the cross product to determine the orientation
    if (crossProduct < 0) {
      angleInRadians = 2 * pi - angleInRadians;
    }

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;


    return angleInDegrees;
  }

  static bool isTurn(List<int> prev, List<int> currentCoordinate, List<int> next) {
    if (prev == null || next == null) {
      return false;  // Not enough data to determine if it's a turn.
    }

    // Extracting coordinates
    int prevX = prev[0];
    int prevY = prev[1];
    int currentX = currentCoordinate[0];
    int currentY = currentCoordinate[1];
    int nextX = next[0];
    int nextY = next[1];

    // Calculate the vectors from prev to current and from current to next
    int vector1X = currentX - prevX;
    int vector1Y = currentY - prevY;
    int vector2X = nextX - currentX;
    int vector2Y = nextY - currentY;

    // Calculate the cross product of vector1 and vector2
    int crossProduct = vector1X * vector2Y - vector1Y * vector2X;

    // A cross product of zero means the points are collinear (no turn).
    // Cross product != 0 means there is a turn.
    return crossProduct != 0;
  }


  static double calculateAngleBWUserandCellPath(Cell user, Cell node , int cols,double theta) {
    List<int> a = [user.x, user.y];
    List<int> tval = user.move(theta);

    if(user.move == tools.twocelltransitionhorizontal || user.move == tools.twocelltransitionvertical){
      tval = tools.fourcelltransition(theta);
    }
    List<int> b = [user.x+tval[0], user.y+tval[1]];
    List<int> c = [node.x , node.y];

    // //print("AA $a");
    // //print("BB $b");
    // //print("CC $c");
    // //print("DD ${node.move.toString()}");
    // //print("EE ${theta}");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the cross product of the two vectors
    double crossProduct = ab[0] * ac[1].toDouble() - ab[1] * ac[0].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Check the sign of the cross product to determine the orientation
    if (crossProduct < 0) {
      angleInRadians = 2 * pi - angleInRadians;
    }

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;


    return angleInDegrees;
  }

  //static setUpUserFromPath



  static double calculateAngleThird(List<int> a, Cell node2 , Cell node3) {

    List<int> b = [node2.x , node2.y];
    List<int> c = [node3.x , node3.y];

    // //print("A $a");
    // //print("B $b");
    // //print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the cross product of the two vectors
    double crossProduct = ab[0] * ac[1].toDouble() - ab[1] * ac[0].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Check the sign of the cross product to determine the orientation
    if (crossProduct < 0) {
      angleInRadians = 2 * pi - angleInRadians;
    }

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;


    return angleInDegrees;
  }

  static double calculateAnglefourth(int node1, int node2 , int node3 , int cols) {

    List<int> a = [node1 % cols , node1 ~/cols];
    List<int> b = [node2 % cols , node2 ~/cols];
    List<int> c = [node3 % cols , node3 ~/cols];

    // //print("A $a");
    // //print("B $b");
    // //print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the cross product of the two vectors
    double crossProduct = ab[0] * ac[1].toDouble() - ab[1] * ac[0].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Check the sign of the cross product to determine the orientation
    if (crossProduct < 0) {
      angleInRadians = 2 * pi - angleInRadians;
    }

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;


    return angleInDegrees;
  }

  static List<direction> getDirections(List<int> path, int columns,Map<int,Landmarks> associateTurnWithLandmark,int floor, String Bid, pathState PathState) {
    List<int> turns = tools.getTurnpoints(path, columns);
    turns.insert(0, path[0]);
    turns.add(path.last);
    double Nextdistance = tools.calculateDistance([turns[0]%columns,turns[0]~/columns], [turns[1]%columns,turns[1]~/columns]);
    List<direction> Directions = [direction(path[0], "Straight", null, Nextdistance, null,path[0]%columns,path[0]~/columns,floor,Bid,numCols:columns)];
    for(int i = 1 ; i<turns.length-1 ; i++){
      int index = path.indexOf(turns[i]);
      double Nextdistance = tools.calculateDistance([turns[i]%columns,turns[i]~/columns], [turns[i+1]%columns,turns[i+1]~/columns]);
      double Prevdistance = tools.calculateDistance([turns[i]%columns,turns[i]~/columns], [turns[i-1]%columns,turns[i-1]~/columns]);
      double angle = tools.calculateAnglefifth(path[index-1], path[index], path[index+1], columns);
      String direc = tools.angleToClocks(angle);
      Directions.add(direction(turns[i], direc, associateTurnWithLandmark[turns[i]], Nextdistance, Prevdistance,turns[i]%columns,turns[i]~/columns,floor,Bid,numCols:columns));
    }
    return Directions;
  }

  static int roundToNextInt(double number) {
    int rounded = number.round();
    return number >= 0 ? rounded : rounded - 1;
  }


  static List<Landmarks> findNearbyLandmark(
      List<int> path,
      Map<String, Landmarks> landmarksMap,
      int distance,
      int numCols,
      int floor,
      String bid) {
    List<Landmarks> nearbyLandmarks = [];
    for (int node in path) {
      landmarksMap.forEach((key, value) {
        if (floor == value.floor && value.name != null && value.buildingID == bid && value.element!.subType != "beacons" && value.element!.subType != "lift") {
          List<int> pCoord = computeCellCoordinates(node, numCols);
          double d = 0.0;
          if (value.doorX == null) {
            d = calculateDistance(
                pCoord, [value.coordinateX!, value.coordinateY!]);
          } else {

            d = calculateDistance(pCoord, [value.doorX!, value.doorY!]);
          }
          if (d < distance) {

            if (!nearbyLandmarks.contains(value)) {
              print("adding ${value.name} [${value.doorX??value.coordinateX},${value.doorY??value.coordinateY}]  for point $pCoord with distance $d");
              nearbyLandmarks.add(value);
            }
          }
        }
      });
    }
    return nearbyLandmarks;
  }


  static nearestLandInfo? localizefindNearbyLandmark(beacon Beacon, Map<String, Landmarks> landmarksMap) {

    PriorityQueue<MapEntry<nearestLandInfo, double>> priorityQueue = PriorityQueue<MapEntry<nearestLandInfo, double>>((a, b) => a.value.compareTo(b.value));
    int distance=10;
    List<int> pCoord = [];
    pCoord.add(Beacon.coordinateX!);
    pCoord.add(Beacon.coordinateY!);
    landmarksMap.forEach((key, value) {

      if(Beacon.buildingID == value.buildingID && value.element!.subType != "beacons" && value.coordinateX!=null){
        if (Beacon.floor! == value.floor) {

          double d = 0.0;

          if (value.doorX != null) {
            d = calculateDistance(
                pCoord, [value.doorX!, value.doorY!]);

          }else{


            d = calculateDistance(
                pCoord, [value.coordinateX!, value.coordinateY!]);
            // if (d<distance) {
            //   nearestLandInfo currentLandInfo = nearestLandInfo(buildingID: value.buildingID,buildingName: value.buildingName,coordinateX: value.coordinateX,coordinateY: value.coordinateY,
            //     doorX: value.doorX,doorY: value.doorY,floor: value.floor,sId: value.sId,name: value.name,venueName: value.venueName, type: '', updatedAt: '',);
            //   priorityQueue.add(MapEntry(currentLandInfo, d));
            // }


          }
          if (d<distance) {

            nearestLandInfo currentLandInfo = nearestLandInfo(buildingID: value.buildingID,buildingName: value.buildingName,coordinateX: value.coordinateX,coordinateY: value.coordinateY,
              doorX: value.doorX,doorY: value.doorY,floor: value.floor,sId: value.sId,name: value.name,venueName: value.venueName, type: '', updatedAt: '',);
            print(currentLandInfo.name);
            priorityQueue.add(MapEntry(currentLandInfo, d));

            //print(value.name);
          }

        }

      }
    });

    nearestLandInfo? nearestLandmark;
    if(priorityQueue.isNotEmpty){
      MapEntry<nearestLandInfo, double> entry = priorityQueue.removeFirst();
      nearestLandmark = entry.key;
    }else{
      //print("priorityQueue.isEmpty");
    }


    return nearestLandmark;
  }
  static List<nearestLandInfo> localizefindAllNearbyLandmark(beacon Beacon, Map<String, Landmarks> landmarksMap) {

    PriorityQueue<MapEntry<nearestLandInfo, double>> priorityQueue = PriorityQueue<MapEntry<nearestLandInfo, double>>((a, b) => a.value.compareTo(b.value));
    int distance=10;
    landmarksMap.forEach((key, value) {
      if(Beacon.buildingID == value.buildingID && value.element!.subType != "beacons" && value.name != null && Beacon.floor! == value.floor){
          List<int> pCoord = [];
          pCoord.add(Beacon.coordinateX!);
          pCoord.add(Beacon.coordinateY!);
          double d = 0.0;

          if (value.doorX != null) {
            d = calculateDistance(
                pCoord, [value.doorX!, value.doorY!]);
            //print("distance b/w beacon and location${d}");
            //print(value.name);
            if (d<distance) {
              nearestLandInfo currentLandInfo = nearestLandInfo(buildingID: value.buildingID,buildingName: value.buildingName,coordinateX: value.coordinateX,coordinateY: value.coordinateY,
                doorX: value.doorX,doorY: value.doorY,floor: value.floor,sId: value.sId,name: value.name,venueName: value.venueName, type: '', updatedAt: '',);
              priorityQueue.add(MapEntry(currentLandInfo, d));
            }
          }else{
            d = calculateDistance(
                pCoord, [value.coordinateX!, value.coordinateY!]);
            //print("distance b/w beacon and location${d}");
            //print(value.name);
            if (d<distance) {
              nearestLandInfo currentLandInfo = nearestLandInfo(buildingID: value.buildingID,buildingName: value.buildingName,coordinateX: value.coordinateX,coordinateY: value.coordinateY,
                doorX: value.doorX,doorY: value.doorY,floor: value.floor,sId: value.sId,name: value.name,venueName: value.venueName, type: '', updatedAt: '',);
              priorityQueue.add(MapEntry(currentLandInfo, d));
            }
          }

      }
    });
    List<nearestLandInfo> nearestLandmark=[];
    if(priorityQueue.isNotEmpty){
      // MapEntry<nearestLandInfo, double> entry = priorityQueue.removeFirst();
      //print("entry.key");
      while(priorityQueue.isNotEmpty)
        {
          MapEntry<nearestLandInfo, double> entry = priorityQueue.removeFirst();
          nearestLandmark.add(entry.key);
        }
    }else{
      //print("priorityQueue.isEmpty");
    }
    return nearestLandmark;
  }
  static List<int> localizefindNearbyLandmarkCoordinated(beacon Beacon, Map<String, Landmarks> landmarksMap) {

    //print("called");

    int distance=10;
    List<int> coordinates=[];
    int i=0;
    landmarksMap.forEach((key, value) {
      if (Beacon.buildingID == value.buildingID && value.element!.subType != "beacons" && Beacon.floor == value.floor) {
        List<int> pCoord = [];
        pCoord.add(Beacon.coordinateX!);
        pCoord.add(Beacon.coordinateY!);
        double d = 0.0;
        if (value.doorX != null) {
          d = calculateDistance(pCoord, [value.doorX!, value.doorY!]);
          if (d<distance) {
            coordinates.add(value.doorX!);
            coordinates.add(value.doorY!);
          }

          return;
        }else{
          d = calculateDistance(pCoord, [value.coordinateX!, value.coordinateY!]);
          if (d<distance) {
            coordinates.add(value.coordinateX!);
            coordinates.add(value.coordinateY!);
          }
        }
        return;
      }
    });

    return coordinates;
  }
  static List<List<int>> localizefindNearbyListLandmarkCoordinated(beacon Beacon, Map<String, Landmarks> landmarksMap) {

    //print("called");

    int distance=10;
    List<List<int>> finalCords=[];
    List<int> coordinates=[];
    landmarksMap.forEach((key, value) {
      if (Beacon.buildingID == value.buildingID && value.element!.subType != "beacons" && Beacon.floor == value.floor) {
        List<int> pCoord = [];
        pCoord.add(Beacon.coordinateX!);
        pCoord.add(Beacon.coordinateY!);
        double d = 0.0;
        if (value.doorX != null) {
          d = calculateDistance(pCoord, [value.doorX!, value.doorY!]);
          if (d<distance) {
            coordinates.add(value.coordinateX!);
            coordinates.add(value.coordinateY!);
            finalCords.add([value.coordinateX!,value.coordinateY!]);
          }
        }else{
          d = calculateDistance(pCoord, [value.coordinateX!, value.coordinateY!]);
          if (d<distance) {
            coordinates.add(value.coordinateX!);
            coordinates.add(value.coordinateY!);
           // finalCords.add(coordinates);
          }
        }
      }

    });

    return finalCords;
  }

  static List<int> computeCellCoordinates(int node, int numCols) {
    int row = (node % numCols);
    int col = (node ~/ numCols);
    return [row, col];
  }

  static double calculateDistance(List<int> p1, List<int> p2) {
    return sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2));
  }

  static void setBuildingAngle(String angle){
    AngleBetweenBuildingandGlobalNorth = double.parse(angle);
    AngleBetweenBuildingandGlobalNorth = AngleBetweenBuildingandGlobalNorth + 90;
    if(AngleBetweenBuildingandGlobalNorth>360){
      AngleBetweenBuildingandGlobalNorth=AngleBetweenBuildingandGlobalNorth-360;
    }
  }

  // static double
  // (String Bid) {
  //   // Assuming corners is a list of Point objects representing coordinates of the building corners
  //
  //   int i = 0;
  //   int j = 1;
  //   if(Bid  == "65d8825cdb333f89456d0562"){

  //     i = 2;
  //     j = 3;
  //   }else if(Bid == "65d8833adb333f89456e6519"){
  //     i=2;
  //     j=3;
  //   }else if(Bid == "65d8835adb333f89456e687f"){
  //     i = 2;
  //     j = 3;

  //   }else if(Bid == "66794105b80a6778c53c4856"){
  //     //0,1
  //     //1,2
  //     //2,3
  //     //1,3
  //     //2,1
  //     i=0;
  //     j=1;
  //   }else if(Bid == "6675792ca3119bff0e732f61"){
  //     i=2;
  //     j=3;
  //   }
  //
  //   // Choose two adjacent corners
  //   Point<double> corner1 = corners[i]; //0 for RNI   2 for Ashoka
  //   Point<double> corner2 = corners[j]; //1 for RNI   3 for Ashoka
  //
  //   // Calculate the slope
  //   double slope = (corner2.y - corner1.y) / (corner2.x - corner1.x);
  //
  //   // Calculate the angle in radians
  //   double angleRad = atan(slope);
  //
  //   // Convert angle to degrees
  //   double angleDeg = angleRad * (180 / pi);
  //
  //   // Adjust for the correct quadrant
  //   if (angleDeg < 0) {
  //     angleDeg += 360;
  //   }
  //

  //   AngleBetweenBuildingandGlobalNorth = angleDeg;
  //   print("buildingAngle set to $angleDeg");

  //   return angleDeg;
  // }

  static List<int> analyzeCell(List<Cell> path, Cell targetCell) {
    int targetIndex = path.indexOf(targetCell);

    if (targetIndex == -1) {
      throw ArgumentError('Cell not found in the path');
    }

    // Count cells to the left with the same move function
    int leftCount = 0;
    for (int i = targetIndex - 1; i >= 0; i--) {
      if (path[i].move == targetCell.move) {
        leftCount++;
      } else {
        break;
      }
    }

    // Count cells to the right with the same move function
    int rightCount = 0;
    for (int i = targetIndex + 1; i < path.length; i++) {
      if (path[i].move == targetCell.move) {
        rightCount++;
      } else {
        break;
      }
    }

    // Position within the segment
    int positionInSegment = leftCount + 1; // 1-based index

    return [leftCount+rightCount+1, positionInSegment];
  }

  static List<int> eightcelltransition(double angle, {int? currPointer,int? totalCells}) {
    if (angle < 0) {
      angle = angle + 360;
    }
    // //print("angleee-----${angle}");
    // //print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    print("angle is this $AngleBetweenBuildingandGlobalNorth");
    if (angle < 0) {
      angle = angle + 360;
    }
    if (angle >= 337.5 || angle <= 22.5) {
      return [0, -1];
    } else if (angle > 22.5 && angle <= 67.5) {
      return [1, -1];
    } else if (angle > 67.5 && angle <= 112.5) {
      return [1, 0];
    } else if (angle > 112.5 && angle <= 157.5) {
      return [1, 1];
    } else if (angle > 157.5 && angle <= 202.5) {
      return [0, 1];
    } else if (angle > 202.5 && angle <= 247.5) {
      return [-1, 1];
    } else if (angle > 247.5 && angle <= 292.5) {
      return [-1, 0];
    } else if (angle > 292.5 && angle <= 337.5) {
      return [-1, -1];
    } else {
      return [0, 0];
    }
  }

  static List<int> eightcelltransitionforTurns(double angle, {int? currPointer,int? totalCells}) {
    if (angle < 0) {
      angle = angle + 360;
    }
    // //print("angleee-----${angle}");
    // //print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }
    if (angle >= 345 || angle <= 15) {
      return [0, -1];
    } else if (angle > 30 && angle <= 60) {
      return [1, -1];
    } else if (angle > 75 && angle <= 105) {
      return [1, 0];
    } else if (angle > 120 && angle <= 150) {
      return [1, 1];
    } else if (angle > 165 && angle <= 195) {
      return [0, 1];
    } else if (angle > 210 && angle <= 240) {
      return [-1, 1];
    } else if (angle > 255 && angle <= 285) {
      return [-1, 0];
    } else if (angle > 300 && angle <= 330) {
      return [-1, -1];
    } else {
      return [0, 0];
    }
  }


  static List<int> fourcelltransition(double angle, {int? currPointer,int? totalCells}) {
    if (angle < 0) {
      angle = angle + 360;
    }
   // //print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }
    if (angle >= 315 || angle <= 45) {
      return [0, -1];
    } else if (angle > 45 && angle <= 135) {
      return [1, 0];
    } else if (angle > 135 && angle <= 225) {
      return [0,1];
    } else if (angle > 225 && angle <= 315) {
      return [-1 , 0];
    } else {
      return [0, 0];
    }
  }


  static List<int> twocelltransitionvertical1(double angle,{int? currPointer, int? totalCells}) {
    if (angle < 0) {
      angle = angle + 360;
    }
    ////print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }

    double adjustmentFactor = 0.0; // Default to no adjustment

    if (currPointer != null && totalCells != null) {
      double positionFactor = currPointer / totalCells;
      adjustmentFactor = 0.3*positionFactor;
    }

    double adjustmentAngle = 360*adjustmentFactor;

    if (angle >= 260 || angle <= 100) {
      return [0, -1];
    } else if (angle > 100 && angle <= 153) {
      return [1,0];
    } else if (angle > 153 && angle <= 207) {
      return [0,1];
    } else if (angle > 207 && angle <= 260) {
      return [-1,0];
    } else {
      return [0, 0];
    }
  }

  static List<int> twocelltransitionvertical2(double angle,{int? currPointer, int? totalCells}) {
    if (angle < 0) {
      angle = angle + 360;
    }
    ////print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }

    double adjustmentFactor = 0.0; // Default to no adjustment

    if (currPointer != null && totalCells != null) {
      double positionFactor = currPointer / totalCells;
      adjustmentFactor = 0.3*positionFactor;
    }

    double adjustmentAngle = 360*adjustmentFactor;

    if (angle >= 333 || angle <= 27) {
      return [0, -1];
    } else if (angle > 27 && angle <= 80) {
      return [1,0];
    } else if (angle > 80 && angle <= 280) {
      return [0,1];
    } else if (angle > 280 && angle <= 333) {
      return [-1,0];
    } else {
      return [0, 0];
    }
  }

  static List<int> twocelltransitionhorizontal1(double angle, {int? currPointer,int? totalCells}) {
    //print("first $angle");
    if (angle < 0) {
      angle = angle + 360;
    }
    ////print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }

    double adjustmentFactor = 0.0; // Default to no adjustment

    if (currPointer != null && totalCells != null) {
      double positionFactor = currPointer / totalCells;
      adjustmentFactor = 0.3*positionFactor;
    }

    double adjustmentAngle = 360*adjustmentFactor;

    if (angle > (170)  && angle <= 10) {
      return [-1,0];
    } else if (angle > 10 && angle <= 63) {
      return [0,-1];
    } else if (angle > 63 && angle <= 117) {
      return [1,0];
    } else if (angle > 117 && angle <= 170) {
      return [0,1];
    } else {
      return [0, 0];
    }
  }

  static List<int> twocelltransitionhorizontal2(double angle, {int? currPointer,int? totalCells}) {
    //print("first $angle");
    if (angle < 0) {
      angle = angle + 360;
    }
    ////print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }

    double adjustmentFactor = 0.0; // Default to no adjustment

    if (currPointer != null && totalCells != null) {
      double positionFactor = currPointer / totalCells;
      adjustmentFactor = 0.3*positionFactor;
    }

    double adjustmentAngle = 360*adjustmentFactor;

    if (angle > (243)  && angle <= 297) {
      return [-1,0];
    } else if (angle > 297 && angle <= 350) {
      return [0,-1];
    } else if (angle > 350 && angle <= 190) {
      return [1,0];
    } else if (angle > 190 && angle <= 243) {
      return [0,1];
    } else {
      return [0, 0];
    }
  }

  static List<int> twocelltransitionvertical(double angle,{int? currPointer,int? totalCells}) {
    if (angle < 0) {
      angle = angle + 360;
    }
    print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }
    if (angle >= 270 || angle <= 90) {
      return [0, -1];
    } else if (angle > 90 && angle <= 270) {
      return [0,1];
    } else {
      return [0, 0];
    }
  }

  static List<int> twocelltransitionhorizontal(double angle,{int? currPointer,int? totalCells}) {
    print("first $angle");
    if (angle < 0) {
      angle = angle + 360;
    }
    print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle < 0) {
      angle = angle + 360;
    }
    if (angle > 180 && angle <= 360) {
      return [-1,0];
    } else if (angle > 0 && angle <= 180) {
      return [1,0];
    } else {
      return [0, 0];
    }
  }

  static Future<Map<int,Landmarks>> associateTurnWithLandmark(List<int> path, List<Landmarks> landmarks, int numCols,)async{
    Map<int,Landmarks> ls = {};
    List<int> turns = [];
    for(int i = 1 ; i<path.length-1 ; i++){
      int prevPos = path[i-1];
      int currPos = path[i];
      int nextPos = path[i+1];

      int currentX = (currPos % numCols);
      int currentY = (currPos ~/ numCols);

      int nextX = (nextPos % numCols);
      int nextY = (nextPos ~/ numCols);

      int prevX = (prevPos % numCols);
      int prevY = (prevPos ~/ numCols);

      int vector1X = currentX - prevX;
      int vector1Y = currentY - prevY;
      int vector2X = nextX - currentX;
      int vector2Y = nextY - currentY;

      // Calculate the cross product of vector1 and vector2
      int dotProduct = vector1X * vector2X + vector1Y * vector2Y;
      if(dotProduct == 0){
        turns.add(currPos);
      }


    }

    turns.forEach((turn) {
      double d = 6.5;
      Landmarks? land;
      landmarks.forEach((element) {
        double distance = tools.calculateDistance([element.coordinateX!,element.coordinateY!], [turn%numCols,turn~/numCols]);
        if(distance<d){
          land = element;
          d = distance;
        }
      });
      if(land != null){
        ls[turn] = land!;
      }


    });

    // landmarks.forEach((element) {
    //   double d = 1000000;
    //   int? t;
    //   turns.forEach((turn) {
    //     if(tools.calculateDistance([element.coordinateX!,element.coordinateY!], [turn%numCols,turn~/numCols])<d){
    //       d = tools.calculateDistance([element.coordinateX!,element.coordinateY!], [turn%numCols,turn~/numCols]);
    //       t = turn;
    //     }
    //   });
    //   if(t != null){
    //     ls[t!] = element;
    //   }
    // });

    return ls;
  }

  static List<int> getTurnpoints(List<int> pathNodes,int numCols){
    List<int> res=[];



    for(int i=1;i<pathNodes.length-1;i++){



      int currPos = pathNodes[i];
      int nextPos=pathNodes[i+1];
      int prevPos=pathNodes[i-1];

      int x1 = (currPos % numCols);
      int y1 = (currPos ~/ numCols);

      int x2 = (nextPos % numCols);
      int y2 = (nextPos ~/ numCols);

      int x3 = (prevPos % numCols);
      int y3 = (prevPos ~/ numCols);

      int prevDeltaX=x1-x3;
      int prevDeltaY=y1-y3;
      int nextDeltaX=x2-x1;
      int nextDeltaY=y2-y1;

      if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){
        if(prevDeltaX==0 && nextDeltaX==0){

        }else if(prevDeltaY==0 && nextDeltaY==0){

        }else{
          res.add(currPos);
        }

      }



    }
    return res;
  }

  static List<int> getTurnpointsForMultiBuilding(List<List<Cell>> pathNodes){
    List<int> res=[];


    for(int j=0;j<pathNodes.length;j++){
      for(int i=1;i<pathNodes[j].length-2;i++){
        int currPos = pathNodes[j][i].node;

        int x1 = pathNodes[j][i].x;
        int y1 = pathNodes[j][i].y;

        int x2 = pathNodes[j][i+1].x;
        int y2 = pathNodes[j][i+1].y;

        int x3 = pathNodes[j][i-1].x;
        int y3 = pathNodes[j][i-1].y;

        int prevDeltaX=x1-x3;
        int prevDeltaY=y1-y3;
        int nextDeltaX=x2-x1;
        int nextDeltaY=y2-y1;

        if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){
          if(prevDeltaX==0 && nextDeltaX==0){

          }else if(prevDeltaY==0 && nextDeltaY==0){

          }else{
            res.add(currPos);
          }

        }


      }
    }
    return res;
  }


  static List<Cell> getCellTurnpoints(List<Cell> pathNodes,int numCols){
    List<Cell> res=[];



    for(int i=1;i<pathNodes.length-1;i++){



      Cell currPos = pathNodes[i];
      Cell nextPos=pathNodes[i+1];
      Cell prevPos=pathNodes[i-1];


      int prevDeltaX=currPos.x-prevPos.x;
      int prevDeltaY=currPos.y-prevPos.y;
      int nextDeltaX=nextPos.x-currPos.x;
      int nextDeltaY=nextPos.y-currPos.y;

      if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){
        if(prevDeltaX==0 && nextDeltaX==0){

        }else if(prevDeltaY==0 && nextDeltaY==0){

        }else{


          res.add(currPos);
        }

      }



    }
    return res;
  }

  static List<int> generateCompletePath(List<int> turns, int numCols, List<int> nonWalkableCells) {
    List<int> completePath = [];

    // Start with the first point in your path
    int currentPoint = turns[0];
    int x = currentPoint % numCols;
    int y = currentPoint ~/ numCols;
    completePath.add(x + y * numCols);

    // Connect each turn point with a straight line
    for (int i = 1; i < turns.length; i++) {
      int turnPoint = turns[i];
      int turnX = turnPoint % numCols;
      int turnY = turnPoint ~/ numCols;

      // Connect straight line from current point to turn point
      while (x != turnX || y != turnY) {
        if (x < turnX) {
          x++;
        } else if (x > turnX) {
          x--;
        }
        if (y < turnY) {
          y++;
        } else if (y > turnY) {
          y--;
        }

        // Convert current x, y coordinates back to index form
        int currentIndex = x + y * numCols;

        // Check if the current index is in the non-walkable cells list
        if (nonWalkableCells.contains(currentIndex)) {
          // Handle non-walkable cell, such as breaking out of the loop or finding an alternative path
          // Here, I'll just break out of the loop
          break;
        }

        // Add the current index to the complete path
        completePath.add(currentIndex);
      }
    }

    return completePath;
  }

  // static List<int> generateCompletePath(List<int> turns, int numCols,List<int> nonWalkableCells) {
  //   List<int> completePath = [];
  //
  //   // Start with the first point in your path
  //   int currentPoint = turns[0];
  //   int x = currentPoint % numCols;
  //   int y = currentPoint ~/ numCols;
  //   completePath.add(x+y*numCols);
  //
  //   // Connect each turn point with a straight line
  //   for (int i = 1; i < turns.length; i++) {
  //     int turnPoint = turns[i];
  //     int turnX = turnPoint % numCols;
  //     int turnY = turnPoint ~/ numCols;
  //
  //     // Connect straight line from current point to turn point
  //     while (x != turnX || y != turnY) {
  //       if (x < turnX) {
  //         x++;
  //       } else if (x > turnX) {
  //         x--;
  //       }
  //       if (y < turnY) {
  //         y++;
  //       } else if (y > turnY) {
  //         y--;
  //       }
  //       if(nonWalkableCells.contains(x+y*numCols)){
  //
  //       }
  //       completePath.add(x+y*numCols);
  //     }
  //   }
  //
  //   return completePath;
  // }
  static Map<int,int> getTurnMap(List<int> pathNodes,int numCols){
    Map<int,int> res=new Map();



    for(int i=1;i<pathNodes.length-1;i++){



      int currPos = pathNodes[i];
      int nextPos=pathNodes[i+1];
      int prevPos=pathNodes[i-1];

      int x1 = (currPos % numCols);
      int y1 = (currPos ~/ numCols);

      int x2 = (nextPos % numCols);
      int y2 = (nextPos ~/ numCols);

      int x3 = (prevPos % numCols);
      int y3 = (prevPos ~/ numCols);

      int prevDeltaX=x1-x3;
      int prevDeltaY=y1-y3;
      int nextDeltaX=x2-x1;
      int nextDeltaY=y2-y1;

      if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){

        if(prevDeltaX==0 && nextDeltaX==0){

        }else if(prevDeltaY==0 && nextDeltaY==0){

        }else{
          res[i]=currPos;
        }

      }



    }
    return res;
  }

  static int distancebetweennodes(Cell node1, Cell node2, List<Cell> path){

    int i1 = path.indexWhere((element) => element.node == node1.node);
    int i2 = path.indexWhere((element) => element.node == node2.node);

    return i1-i2;
  }

  static bool allElementsAreSame(List list) {
    if (list.isEmpty) return true;  // Consider an empty list as having all elements the same.
    var first = list.first;
    for (var element in list) {
      if (element > first) {
        return false;
      }
    }
    return true;
  }

  static Landmarks? findNearestEntry(List<Landmarks> listOfLandmarks, List<int> place, String placeBid ){
    double distance = 100000;
    Landmarks? nearestEntry;
    for (Landmarks element in listOfLandmarks) {
      if(element.element!.subType != null &&
          element.element!.subType == "main entry" &&
          element.name!.toLowerCase().contains("entry") &&
          element.buildingID == placeBid){
        double d = calculateDistance([element.coordinateX!,element.coordinateY!], place);
        if(d<distance){
          distance = d;
          nearestEntry = element;
        }
      }
    }
    return nearestEntry;
  }

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

// Function to convert lat/long to Cartesian coordinates
  static List<double> latLongToCartesian(double lat, double lon) {
    double latRad = degreesToRadians(lat);
    double lonRad = degreesToRadians(lon);
    return [
      cos(latRad) * cos(lonRad),
      cos(latRad) * sin(lonRad),
      sin(latRad)
    ];
  }

// Function to calculate the signed angle between two vectors in clockwise direction
  static double calculateSignedAngle(List<double> v1, List<double> v2) {
    double dotProduct = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
    double crossProductX = v1[1] * v2[2] - v1[2] * v2[1];
    double crossProductY = v1[2] * v2[0] - v1[0] * v2[2];
    double crossProductZ = v1[0] * v2[1] - v1[1] * v2[0];
    double crossProductMagnitude = sqrt(crossProductX * crossProductX + crossProductY * crossProductY + crossProductZ * crossProductZ);

    double angle = atan2(crossProductMagnitude, dotProduct);

    // Determine the sign of the angle
    if (crossProductZ < 0) {
      angle = 2 * pi - angle;
    }

    return angle;
  }

  static double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  static Map<String, double> computeNewPosition(double latitude, double longitude, double angle, double distance) {
    double earthRadius = 20925646.3 ;
    // Convert latitude and longitude from degrees to radians
    double latRad = degreesToRadians(latitude);
    double lonRad = degreesToRadians(longitude);
    double bearing = degreesToRadians(angle);

    // Calculate the new latitude
    double newLatRad = asin(sin(latRad) * cos(distance / earthRadius) +
        cos(latRad) * sin(distance / earthRadius) * cos(bearing));

    // Calculate the new longitude
    double newLonRad = lonRad + atan2(sin(bearing) * sin(distance / earthRadius) * cos(latRad),
        cos(distance / earthRadius) - sin(latRad) * sin(newLatRad));

    // Convert the new latitude and longitude from radians to degrees
    double newLat = radiansToDegrees(newLatRad);
    double newLon = radiansToDegrees(newLonRad);

    return {'latitude': newLat, 'longitude': newLon};
  }

  static double calculateDistanceBetweenLatLng(double lat1, double lon1, double lat2, double lon2, {bool inFeet = false}) {
    double earthRadiusMeters = 6378137.0;
    if(inFeet){
      earthRadiusMeters = 20925646.3;
    }
    // Convert latitude and longitude from degrees to radians
    double lat1Rad = degreesToRadians(lat1);
    double lon1Rad = degreesToRadians(lon1);
    double lat2Rad = degreesToRadians(lat2);
    double lon2Rad = degreesToRadians(lon2);

    // Haversine formula
    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Distance in meters
    double distance = earthRadiusMeters * c;

    return distance;
  }


// Function to insert intermediate points between given points
  static List<List<double>> insertIntermediatePoints(List<List<double>> points, double intervalFeet) {
    List<List<double>> result = [];

    for (int i = 0; i < points.length - 1; i++) {
      double lat1 = points[i][1];
      double lon1 = points[i][0];
      double lat2 = points[i + 1][1];
      double lon2 = points[i + 1][0];

      result.add([lat1, lon1]);

      double distance = calculateDistanceBetweenLatLng(lat1, lon1, lat2, lon2,inFeet: true);
      int numPointsToInsert = (distance / intervalFeet).floor();

      for (int j = 1; j <= numPointsToInsert; j++) {
        double fraction = j / (numPointsToInsert + 1);
        double angle = atan2(lon2 - lon1, lat2 - lat1) * 180.0 / pi;

        Map<String, double> newPosition = computeNewPosition(lat1, lon1, angle, fraction * distance);

        result.add([newPosition['latitude']!, newPosition['longitude']!]);
      }
    }

    // Add the last point
    result.add([points.last[1], points.last[0]]);

    return result;
  }

// Function to find the point with the minimum angle
  static Landmarks findMinAnglePoint(String sourceid, String destinationid, List<Landmarks> points, int n, {bool ramp = false}) {
    Landmarks s = points.where((element) => element.properties!.polyId == sourceid).first;
    Landmarks d = points.where((element) => element.properties!.polyId == destinationid).first;
    Poi source = Poi(double.parse(s.properties!.latitude!), double.parse(s.properties!.longitude!));
    Poi destination = Poi(double.parse(d.properties!.latitude!), double.parse(d.properties!.longitude!));
    List<double> sourceCartesian = latLongToCartesian(source.latitude, source.longitude);
    List<double> destinationCartesian = latLongToCartesian(destination.latitude, destination.longitude);
    List<double> sourceToDestination = [
      destinationCartesian[0] - sourceCartesian[0],
      destinationCartesian[1] - sourceCartesian[1],
      destinationCartesian[2] - sourceCartesian[2],
    ];

    double minAngle = n==1?10000:0;
    Landmarks? minAnglePoint;

    for (Landmarks point in points) {
      if(point.element!.subType != null &&
          point.element!.subType == "main entry" &&
          point.name!.toLowerCase().contains("entry") &&
          point.name!.toLowerCase().contains("ramp") == ramp &&
          point.buildingID == s.buildingID){
        List<double> pointCartesian = latLongToCartesian(double.parse(point.properties!.latitude!), double.parse(point.properties!.longitude!));
        List<double> sourceToPoint = [
          pointCartesian[0] - sourceCartesian[0],
          pointCartesian[1] - sourceCartesian[1],
          pointCartesian[2] - sourceCartesian[2],
        ];

        double angle = calculateSignedAngle(sourceToDestination, sourceToPoint);
        print("angle for ${point.name} ${point.sId} $angle");

        if(n == 1){
          if (angle < minAngle) {
            minAngle = angle;
            minAnglePoint = point;
          }
        }else{
          if (angle > minAngle) {
            minAngle = angle;
            minAnglePoint = point;
          }
        }


      }
    }

    return minAnglePoint!;
  }



}

class Poi {
  final double latitude;
  final double longitude;

  Poi(this.latitude, this.longitude);
}

class nearestLandInfo{
  Element? element;
  // Properties? properties;
  String? sId;
  String? buildingID;
  int? coordinateX;
  int? coordinateY;
  int? doorX;
  int? doorY;
  String? featureType;
  String? type;
  int? floor;
  String? geometryType;
  String? name;
  // List<Lifts>? lifts;
  // List<Stairs>? stairs;
  // List<Others>? others;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? buildingName;
  String? venueName;

  nearestLandInfo({
    this.element,
    // this.properties,
    required this.sId,
    required this.buildingID,
    required this.coordinateX,
    required this.coordinateY,
    required this.doorX,
    required this.doorY,
    required this.type,
    required this.floor,
    required this.name,
    // this.lifts,
    // this.stairs,
    // this.others,
    required this.updatedAt,
    required this.buildingName,
    required this.venueName,
  });

  bool? wasPolyIdNull ;

}
class Element {
  String? type;
  String? subType;

  Element({this.type, this.subType});

  Element.fromJson(Map<dynamic, dynamic> json) {
    type = json['type'];
    subType = json['subType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['subType'] = this.subType;
    return data;
  }
}

class CoordinateConverter {

  static Map<List<int>,List<double>> mapping = {};

  // Function to convert local coordinates to global coordinates
  static Map<String, double> localToGlobal(double localLat, double localLng, Map<dynamic, dynamic> patchData) {
    List<double> v = mapping[[localLat,localLng]]!;
    return {'lat': v[0], 'lng': v[1]};
  }

  // Function to convert global coordinates to local coordinates (reverse)
  static Map<String, double> globalToLocal(double globalLat, double globalLng,Map<dynamic, dynamic> patchData) {
    List<Map<dynamic, dynamic>> coordinates = patchData['coordinates'];
    String buildingAngle = patchData['buildingAngle'];

    double angleRad = _degreesToRadians(double.parse(buildingAngle));

    // Find the translation components
    var globalRef = coordinates[0]['globalRef'];
    var localRef = coordinates[0]['localRef'];
    double originX = double.parse(globalRef['lat']);
    double originY = double.parse(globalRef['lng']);
    double localOriginX = double.parse(localRef['lat']);
    double localOriginY = double.parse(localRef['lng']);

    // Translate global coordinates to the local reference frame
    double translatedX = globalLat - originX;
    double translatedY = globalLng - originY;

    // Apply inverse rotation
    double rotatedX = translatedX * cos(angleRad) + translatedY * sin(angleRad);
    double rotatedY = -translatedX * sin(angleRad) + translatedY * cos(angleRad);

    // Convert to local coordinates
    double localX = rotatedX + localOriginX;
    double localY = rotatedY + localOriginY;

    mapping[[(1000000000+(localX*-1)).round().toInt(),(1000000000+(localY*-1)).round().toInt()]] = [globalLat,globalLng];

    return {'lat': 1000000000+(localX*-1), 'lng': 1000000000+(localY*-1)};
  }

  // Helper function to convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}