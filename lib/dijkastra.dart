// Function to calculate Euclidean distance between two points
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:iwaymaps/singletonClass.dart';
import '/path.dart';
import 'API/buildingAllApi.dart';
import 'APIMODELS/GlobalAnnotationModel.dart';
import 'navigationTools.dart';

class paths{
  List<MapEntry<String, Map<int, List<int>>>> localPath;
  List<MapEntry<String, Map<int, List<List<double>>>>> globalPath;

  paths(this.localPath, this.globalPath);
}

enum PathOption {
  lift,
  stairs,
  escalator,
  ramp
}

// Function to calculate Euclidean distance between two points
double euclideanDistance(String point1, String point2, {String? prevPoint}) {
  var p1 = point1.split(',').map((e) => double.parse(e)).toList();
  var p2 = point2.split(',').map((e) => double.parse(e)).toList();

  double distance = sqrt(pow((p2[0] - p1[0]), 2) + pow((p2[1] - p1[1]), 2));

  // Check for a turn if a previous point exists
  if (prevPoint != null) {
    var p0 = prevPoint.split(',').map((e) => double.parse(e)).toList();

    var v1 = [p1[0] - p0[0], p1[1] - p0[1]];
    var v2 = [p2[0] - p1[0], p2[1] - p1[1]];

    double dotProduct = (v1[0] * v2[0]) + (v1[1] * v2[1]);
    double mag1 = sqrt(v1[0] * v1[0] + v1[1] * v1[1]);
    double mag2 = sqrt(v2[0] * v2[0] + v2[1] * v2[1]);

    if (mag1 > 0 && mag2 > 0) {
      double cosTheta = dotProduct / (mag1 * mag2);
      double angle = acos(cosTheta) * (180 / pi); // Convert to degrees

      if (angle > 30) { // Consider a turn if the angle is greater than 30 degrees
        distance += 5; // Add turn penalty
      }
    }
  }

  return distance;
}


double masterEuclideanDistance(String node1, String node2, {String? prevPoint}) {
  List<String> parts1 = node1.split(',');
  List<String> parts2 = node2.split(',');

  if(parts2.length != 6){
    print("part2 $parts2");
  }
  print("parts1 $parts1");
  int floor1 = int.parse(parts1[3]);
  List<double> l1 = [double.parse(parts1[5]), double.parse(parts1[4])];

  List<double> l2 = [double.parse(parts2[5]), double.parse(parts2[4])];
  int floor2 = int.parse(parts2[3]);

  double distance = tools.calculateAerialDist(l1[0], l1[1], l2[0], l2[1]);

  if (floor1 != floor2) {
    distance += 15; // Add floor change penalty
  }

  // if (prevPoint != null) {
  //   List<String> partsPrev = prevPoint.split(',');
  //   List<double> l0 = [double.parse(partsPrev[5]), double.parse(partsPrev[4])];
  //
  //   double turnAngle = angle(l0, l1, l2);
  //   if (turnAngle > 30) { // Only penalize sharp turns
  //     distance += turnAngle * 0.1; // Adjust multiplier as needed
  //   }
  // }

  return distance;
}

double angle(List<double> a, List<double> b, List<double> c) {
  const double R = 6371.0; // Earth's radius in km
  const double pi = 3.14159265358979323846;

  // Convert degrees to radians
  double toRad(double deg) => deg * pi / 180.0;

  double lat1 = toRad(a[1]), lon1 = toRad(a[0]);
  double lat2 = toRad(b[1]), lon2 = toRad(b[0]);
  double lat3 = toRad(c[1]), lon3 = toRad(c[0]);

  // Convert to Cartesian coordinates (3D)
  List<double> toCartesian(double lat, double lon) {
    return [
      R * cos(lat) * cos(lon),
      R * cos(lat) * sin(lon),
      R * sin(lat)
    ];
  }

  var p1 = toCartesian(lat1, lon1);
  var p2 = toCartesian(lat2, lon2);
  var p3 = toCartesian(lat3, lon3);

  // Vectors BA and BC
  double bax = p1[0] - p2[0], bay = p1[1] - p2[1], baz = p1[2] - p2[2];
  double bcx = p3[0] - p2[0], bcy = p3[1] - p2[1], bcz = p3[2] - p2[2];

  // Dot product and magnitudes
  double dot = bax * bcx + bay * bcy + baz * bcz;
  double magBA = sqrt(bax * bax + bay * bay + baz * baz);
  double magBC = sqrt(bcx * bcx + bcy * bcy + bcz * bcz);

  // Angle in degrees
  double cosTheta = dot / (magBA * magBC);
  cosTheta = cosTheta.clamp(-1.0, 1.0); // Clamp for numerical stability

  return acos(cosTheta) * (180.0 / pi);
}


// Dijkstra's algorithm to find the shortest path
Future<List<List<int>>> dijkstra(Map<String, dynamic> graph, String start, String goal, int col, {bool isoutdoorPath = false})async{

  var distances = <String, double>{};
  var previous = <String, String>{};
  var unvisited = PriorityQueue<MapEntry<String, double>>((a, b) => a.value.compareTo(b.value));

  for (var node in graph.keys) {
    distances[node] = double.infinity;
  }
  distances[start] = 0;

  unvisited.add(MapEntry(start, 0));

  while (unvisited.isNotEmpty) {
    var currentNode = unvisited.removeFirst().key;

    if (currentNode == goal) {
      var path = <List<int>>[];
      while (previous.containsKey(currentNode)) {
        path.add(currentNode.split(',').map(int.parse).toList());
        currentNode = previous[currentNode]!;
      }
      path.add(currentNode.split(',').map(int.parse).toList()); // Add the start node
      if(isoutdoorPath){
        return path.reversed.toList();
      }
      return addCoordinatesBetweenVertices(path.reversed.toList(), col);
    }

    if (graph.containsKey(currentNode)) {
      for (var neighbor in graph[currentNode]!) {
        String? prevNode = previous[currentNode]; // Get previous node (if available)
        var newDist = distances[currentNode]! + euclideanDistance(currentNode, neighbor, prevPoint: prevNode);

        if (newDist < distances[neighbor]!) {
          distances[neighbor] = newDist;
          previous[neighbor] = currentNode;
          unvisited.add(MapEntry(neighbor, newDist));
        }
      }
    }
  }

  return []; // Return an empty list if there's no path
}



Future<List<String>> masterDijkstra(
    GlobalModel masterGraph, String start, String goal, PathOption floorConnector,
    {bool isoutdoorPath = false}) async {

  var distances = <String, double>{};
  var previous = <String, String>{};
  var visited = <String>{};
  var unvisited = PriorityQueue<MapEntry<String, double>>((a, b) => a.value.compareTo(b.value));

  var graph = masterGraph.pathNetwork!.masterGraph!;

  var nonPreferableConnectors = masterGraph.getNodesForNonPreferableOption(floorConnector);

  for (var node in graph.keys) {
    distances[node] = double.infinity;
  }
  distances[start] = 0;

  print("start $start goal $goal");
  unvisited.add(MapEntry(start, 0));
  List<String> startExpanded = start.split(',');
  List<String> goalExpanded = goal.split(',');
  bool sameFloorDifferentBuilding = (startExpanded[0] != goalExpanded[0] && startExpanded[3] == goalExpanded[3]);

  print("sameFloorDifferentBuilding $sameFloorDifferentBuilding");
  while (unvisited.isNotEmpty) {
    var currentNode = unvisited.removeFirst().key;

    // Skip if already visited
    if (visited.contains(currentNode)) continue;
    visited.add(currentNode);

    if (currentNode == goal) {
      var path = <String>[];
      while (previous.containsKey(currentNode)) {
        path.add(currentNode);
        currentNode = previous[currentNode]!;
      }
      path.add(currentNode);

      return path.reversed.toList();
    }

    if (graph.containsKey(currentNode)) {
      for (var neighbor in graph[currentNode]!) {
        if(int.parse(startExpanded[3]) == 0 && sameFloorDifferentBuilding && neighbor != null && neighbor.isNotEmpty){
          List<String> neighborExpanded = neighbor.split(',');
          if(int.parse(neighborExpanded[3]) != 0){
            continue;
          }
        }
        if(neighbor != null && !nonPreferableConnectors.contains(neighbor) && !visited.contains(neighbor)){
          String? prevNode = previous[currentNode];
          // Simple edge distance without angle dependency
          var edgeDistance = masterEuclideanDistance(currentNode, neighbor, prevPoint: prevNode);
          var newDist = distances[currentNode]! + edgeDistance;

          if (newDist < distances[neighbor]!) {
            distances[neighbor] = newDist;
            previous[neighbor] = currentNode;
            unvisited.add(MapEntry(neighbor, newDist));
          }
        }
      }
    }
  }

  print("masterpath not found []");
  return [];
}

List<List<int>> addCoordinatesBetweenVertices(List<List<int>> coordinates, int col) {
  var newCoordinates = <List<int>>[];

  for (var i = 0; i < coordinates.length - 1; i++) {
    var startX = coordinates[i][0];
    var startY = coordinates[i][1];
    var endX = coordinates[i + 1][0];
    var endY = coordinates[i + 1][1];

    // Determine the direction of increment for x and y
    var signX = startX < endX ? 1 : -1;
    var signY = startY < endY ? 1 : -1;

    // Add the starting point
    if(newCoordinates.isNotEmpty && newCoordinates.last[0] != startX && newCoordinates.last[1] != startY){
      newCoordinates.add([startX, startY]);
    }

    // Add intermediate points
    var x = startX;
    var y = startY;
    while (x != endX || y != endY) {
      if (x != endX) {
        x += signX;
      }
      if (y != endY) {
        y += signY;
      }
      newCoordinates.add([x, y]);
    }
  }

  // Add the last coordinate
  newCoordinates.add([coordinates.last[0], coordinates.last[1]]);

  return newCoordinates;
}

List<int> masterAddCoordinatesBetweenVertices(List<String> nodes, int col) {
  var newCoordinates = <int>[];

  for (var i = 0; i < nodes.length - 1; i++) {
    var value = tools.extractCoordinates(nodes[i]);
    var nextValue = tools.extractCoordinates(nodes[i+1]);
    List<int> coordinates = [value[0], value[1]];
    List<int> nextCoordinates = [nextValue[0], nextValue[1]];
    var startX = coordinates[0];
    var startY = coordinates[1];
    var endX = nextCoordinates[0];
    var endY = nextCoordinates[1];

    // Determine the direction of increment for x and y
    var signX = startX < endX ? 1 : -1;
    var signY = startY < endY ? 1 : -1;

    // Add the starting point
    if(newCoordinates.isEmpty || (newCoordinates.isNotEmpty && newCoordinates.last != startY*col+startX)){
      newCoordinates.add(startY*col+startX);
    }

    // Add intermediate points
    var x = startX;
    var y = startY;
    while (x != endX || y != endY) {
      if (x != endX) {
        x += signX;
      }
      if (y != endY) {
        y += signY;
      }
      newCoordinates.add(y*col+x);
    }
  }

  // Add the last coordinate
  var value = tools.extractCoordinates(nodes.last);
  newCoordinates.add(value[1]*col+value[0]);

  return newCoordinates;
}

List<String> findNearestAndSecondNearestVertices(
    Map<String, dynamic> pathNetwork,
    List<int> coord1,
    List<int> coord2) {
  final stackTrace = StackTrace.current;
  print("stateDebug Stack: \n$stackTrace");
  String nearestToCoord1 = '';
  String secondNearestToCoord1 = '';
  String nearestToCoord2 = '';
  String secondNearestToCoord2 = '';
  double minDistToCoord1 = double.infinity;
  double secondMinDistToCoord1 = double.infinity;
  double minDistToCoord2 = double.infinity;
  double secondMinDistToCoord2 = double.infinity;

  print("source and destination points are $coord1 and $coord2");

  // Iterate through each vertex in the pathNetwork
  pathNetwork.forEach((vertex, neighbors) {
    List<int> v = vertex.split(',').map((e) => int.parse(e)).toList();

    // Calculate distances from coord1 and coord2 to vertex v
    double distToCoord1 = sqrt(pow(v[0] - coord1[0], 2) + pow(v[1] - coord1[1], 2));
    double distToCoord2 = sqrt(pow(v[0] - coord2[0], 2) + pow(v[1] - coord2[1], 2));

    // Update nearest and second nearest vertices for coord1
    if (distToCoord1 < minDistToCoord1) {
      secondMinDistToCoord1 = minDistToCoord1;
      secondNearestToCoord1 = nearestToCoord1;
      minDistToCoord1 = distToCoord1;
      nearestToCoord1 = vertex;
    } else if (distToCoord1 < secondMinDistToCoord1) {
      secondMinDistToCoord1 = distToCoord1;
      secondNearestToCoord1 = vertex;
    }

    // Update nearest and second nearest vertices for coord2
    if (distToCoord2 < minDistToCoord2) {
      secondMinDistToCoord2 = minDistToCoord2;
      secondNearestToCoord2 = nearestToCoord2;
      minDistToCoord2 = distToCoord2;
      nearestToCoord2 = vertex;
    } else if (distToCoord2 < secondMinDistToCoord2) {
      secondMinDistToCoord2 = distToCoord2;
      secondNearestToCoord2 = vertex;
    }
  });

  if(nearestToCoord1 == "${coord1[0]},${coord1[1]}"){
    secondNearestToCoord1 = nearestToCoord1;
  }
  if(nearestToCoord2 == "${coord2[0]},${coord2[1]}"){
    secondNearestToCoord2 = nearestToCoord2;
  }
  return [
    nearestToCoord1,
    secondNearestToCoord1,
    nearestToCoord2,
    secondNearestToCoord2
  ];
}

List<String> masterFindNearestAndSecondNearestVertices(Map<String, dynamic> pathNetwork, String coord1, String coord2) {
  final stackTrace = StackTrace.current;
  print("stateDebug Stack: \n$stackTrace");
  String nearestToCoord1 = '';
  String nearestToCoord2 = '';
  double minDistToCoord1 = double.infinity;
  double minDistToCoord2 = double.infinity;

  print("Source and destination points are $coord1 and $coord2");

  List<int> coord1Parsed = tools.extractCoordinates(coord1);
  int coord1Floor = coord1Parsed[2];
  String coord1Bid = tools.extractBid(coord1);

  List<int> coord2Parsed = tools.extractCoordinates(coord2);
  int coord2Floor = coord2Parsed[2];
  String coord2Bid = tools.extractBid(coord2);

  print("Source and destination points extracted are $coord1Parsed and $coord2Parsed  $pathNetwork");
  // Iterate through each vertex in the pathNetwork
  pathNetwork.forEach((vertex, neighbors) {
    List<int> v = tools.extractCoordinates(vertex);
    String vBid = tools.extractBid(vertex);

    // Calculate distances from coord1 and coord2 to vertex v
    double distToCoord1 = sqrt(pow(v[0] - coord1Parsed[0], 2) + pow(v[1] - coord1Parsed[1], 2));
    if(v.length<3){
      print("v $v");
    }
    if(v[2] != coord1Floor || vBid != coord1Bid){
      distToCoord1 = double.infinity;
    }

    double distToCoord2 = sqrt(pow(v[0] - coord2Parsed[0], 2) + pow(v[1] - coord2Parsed[1], 2));
    if(v[2] != coord2Floor || vBid != coord2Bid){
      distToCoord2 = double.infinity;
    }

    // Update nearest and second nearest vertices for coord1
    if (distToCoord1 < minDistToCoord1) {
      minDistToCoord1 = distToCoord1;
      nearestToCoord1 = vertex;
    }

    // Update nearest and second nearest vertices for coord2
    if (distToCoord2 < minDistToCoord2) {
      minDistToCoord2 = distToCoord2;
      nearestToCoord2 = vertex;
    }
  });

  print("tools.extractCoordinates(nearestToCoord1) $nearestToCoord1 ");
  print("tools.extractCoordinates(nearestToCoord1)  ${tools.extractCoordinates(nearestToCoord1)}");
  print("tools.extractCoordinates(nearestToCoord2) $nearestToCoord2 ");
  print("tools.extractCoordinates(nearestToCoord2)  ${tools.extractCoordinates(nearestToCoord2)}");

  return [
    nearestToCoord1,
    nearestToCoord2,
  ];
}

List<int> mergeLists(List<int> l1, List<int> l2, List<int> l3) {
  List<int> result = [];

  // Helper function to find the first intersection
  int findFirstIntersection(List<int> list1, List<int> list2) {
    for (int element in list1) {
      if (list2.contains(element)) {
        return element;
      }
    }
    return -1;
  }

  if (l1.isEmpty) {
    // If l1 is empty, merge l2 and l3
    int intersectionL2L3 = findFirstIntersection(l2, l3);

    if (intersectionL2L3 == -1) {
      // No intersection, just add all elements of l2 and l3
      result.addAll(l2);
      result.addAll(l3);
    } else {
      // Add elements of l2 till the intersection
      for (int i = 0; i < l2.length && l2[i] != intersectionL2L3; i++) {
        result.add(l2[i]);
      }
      result.add(intersectionL2L3);

      // Add elements of l3 after the intersection till the end
      int indexL2L3 = l3.indexOf(intersectionL2L3);
      for (int i = indexL2L3 + 1; i < l3.length; i++) {
        result.add(l3[i]);
      }
    }

  } else if (l3.isEmpty) {
    // If l3 is empty, merge l1 and l2
    int intersectionL1L2 = findFirstIntersection(l1, l2);

    if (intersectionL1L2 == -1) {
      // No intersection, just add all elements of l1 and l2
      result.addAll(l1);
      result.addAll(l2);
    } else {
      // Add elements of l1 till the intersection
      for (int i = 0; i < l1.length && l1[i] != intersectionL1L2; i++) {
        result.add(l1[i]);
      }
      result.add(intersectionL1L2);

      // Add elements of l2 after the intersection till the end
      int indexL1L2 = l2.indexOf(intersectionL1L2);
      for (int i = indexL1L2 + 1; i < l2.length; i++) {
        result.add(l2[i]);
      }
    }

  } else {
    // If neither l1 nor l3 is empty, perform the original merging logic
    int intersectionL1L2 = findFirstIntersection(l1, l2);

    if (intersectionL1L2 == -1) return result;

    // Add elements of l1 till the intersection
    for (int i = 0; i < l1.length && l1[i] != intersectionL1L2; i++) {
      result.add(l1[i]);
    }
    result.add(intersectionL1L2);

    // Find the first intersection of l2 and l3 after the intersection with l1
    int intersectionL2L3 = findFirstIntersection(l2.sublist(l2.indexOf(intersectionL1L2) + 1), l3);

    if (intersectionL2L3 == -1) return result;

    // Add elements of l2 after the first intersection till the next intersection
    int indexL1L2 = l2.indexOf(intersectionL1L2);
    for (int i = indexL1L2 + 1; i < l2.length && l2[i] != intersectionL2L3; i++) {
      result.add(l2[i]);
    }
    result.add(intersectionL2L3);

    // Add elements of l3 after the intersection till the end
    int indexL2L3 = l3.indexOf(intersectionL2L3);
    for (int i = indexL2L3 + 1; i < l3.length; i++) {
      result.add(l3[i]);
    }
  }

  return result;
}


Future<List<MapEntry<String, Map<int, List<int>>>>> findShortestPath (Map<String, dynamic> graph, int sourceX, int sourceY, int destinationX, int destinationY, List<int>? nonWalkableCells, int col, int row, String bid, int floor, {bool isoutdoorPath = false})async{
  nonWalkableCells ??= [];
  List<String> states = findNearestAndSecondNearestVertices(graph, [sourceX,sourceY], [destinationX,destinationY]);
  String start1 = states[0];
  String start2 = states[1];
  String goal1 = states[2];
  String goal2 = states[3];

  print("states debug $states");


  List<List<int>> temppath1 = await dijkstra(graph,start1,goal1,col,isoutdoorPath: isoutdoorPath);
  List<List<int>> temppath2 = await dijkstra(graph,start2,goal2,col, isoutdoorPath: isoutdoorPath);

  List<List<int>> temppath =[];

  if (temppath1.isEmpty || temppath2.isEmpty) {
    temppath = temppath1.isEmpty ? temppath2 : temppath1;
  } else {
    final start1Coords = start1.split(',').map(int.parse).toList();
    final start2Coords = start2.split(',').map(int.parse).toList();
    final distance = tools.calculateDistance(start1Coords, start2Coords);

    if (distance <= 10) {
      temppath = (temppath1.length > temppath2.length) ? temppath2 : temppath1;
      print("returning ${temppath == temppath2 ? '1 $temppath2' : '2'}");
    } else {
      print("returning 3");
      temppath = temppath1;
    }
  }





  if(tools.calculateDistance(temppath.first, [sourceX,sourceY])==1){
    print("inserting ${[sourceX,sourceY]} at 0 ${temppath.first}");
    temppath.insert(0, [sourceX,sourceY]);
  }

  int s = 0;
  int e = temppath.length -1;
  double d1 = double.infinity;
  double d2 = double.infinity;

  for(int i = 0 ; i< temppath.length ; i++){
    if(tools.calculateDistance(temppath[i], [sourceX,sourceY])<d1){
      d1 = tools.calculateDistance(temppath[i], [sourceX,sourceY]);
      s = i;
    }
    if(tools.calculateDistance(temppath[i], [destinationX,destinationY])<d2){
      d2 = tools.calculateDistance(temppath[i], [destinationX,destinationY]);
      e = i;
    }
  }
  List<int>l1 = [];
  List<int>l2 = [];
  List<int>l3 = [];
  if((sourceY*col)+sourceX != (temppath[s][1]*col)+temppath[s][0] && !isoutdoorPath){
    await findPath(row, col, nonWalkableCells, ((sourceY*col) + sourceX), ((temppath[s][1]*col)+temppath[s][0])).then((value){
      //value = getFinalOptimizedPath(value, nonWalkableCells, numCols, sourceX, sourceY, destinationX, destinationY);
      // print("path inside 1  between ${((sourceY*col) + sourceX)} and ${((temppath[s][1]*col)+temppath[s][0])} is $value");
      l1 = value;
      // print("l1 $l1");
    });
  }

  for(int i = s ; i<=e; i++){
    l2.add((temppath[i][1]*col) + temppath[i][0]);
  }
  if((sourceY*col)+sourceX != (temppath[0][1]*col)+temppath[0][0] && isoutdoorPath){
    var distance1 = tools.calculateDistance([sourceX,sourceY], [temppath[1][0],temppath[1][1]]);
    var distance2 = tools.calculateDistance([temppath[0][0],temppath[0][1]], [temppath[1][0],temppath[1][1]]);
    if(distance1<distance2){
      l2.removeAt(0);
    }
    l2.insert(0,(sourceY*col) + sourceX);
  }

  // print("l2 $l2");
  if((temppath[e][1]*col)+temppath[e][0] != (destinationY*col)+destinationX && !isoutdoorPath){

    await findPath(row, col, nonWalkableCells, ((temppath[e][1]*col)+temppath[e][0]), ((destinationY*col) + destinationX)).then((value){
      //value = getFinalOptimizedPath(value, nonWalkableCells, numCols, sourceX, sourceY, destinationX, destinationY);
      // print("path inside 2 $value");
      l3 = value;
      // print("l3 $l3");
    });


  }

  if(l1.isNotEmpty || l3.isNotEmpty){
    try {
      return [MapEntry(bid, { floor :  getFinalOptimizedPath(
          mergeLists(l1, l2, l3),
          nonWalkableCells,
          col,
          sourceX,
          sourceY,
          destinationX,
          destinationY)})];
    }catch(e){
      return [MapEntry(bid, { floor :  mergeLists(l1, l2, l3)})];
    }
  }else{
    return [MapEntry(bid, { floor :  mergeLists(l1, l2, l3)})];
  }

}



Future<paths> masterFindShortestPath (GlobalModel masterGraph, int sourceX, int sourceY,double sourceLat, double sourceLng, String sourceBid, int sourceFloor, int destinationX, int destinationY, String destinationBid, int destinationFloor, List<int>? nonWalkableCells, Map<String, Map<int, List<int>>> col, PathOption floorConnector, {bool isoutdoorPath = false})async{
  nonWalkableCells ??= [];
  List<String> states = [];
  states = masterFindNearestAndSecondNearestVertices(masterGraph.pathNetwork!.masterGraph!, "$sourceBid,$sourceX,$sourceY,$sourceFloor", "$destinationBid,$destinationX,$destinationY,$destinationFloor");
  String start1 = states[0];
  String goal1 = states[1];

  print("states debug $states");

  List<String> temppath1 = await masterDijkstra(masterGraph,start1,goal1, floorConnector, isoutdoorPath: isoutdoorPath);

  print("temp1 $temppath1");

  List<String> temppath =temppath1;

  var zerothElement = tools.extractCoordinates(temppath[0]);
  var firstElement = tools.extractCoordinates(temppath[1]);

  if(sourceY != zerothElement[1] || sourceX != zerothElement[0]){
    var distance1 = tools.calculateDistance([sourceX,sourceY], [firstElement[0],firstElement[1]]);
    var distance2 = tools.calculateDistance([zerothElement[0],zerothElement[1]], [firstElement[0],firstElement[1]]);
    if(distance1<distance2){
      temppath.removeAt(0);
    }
    temppath.insert(0,"$sourceBid,$sourceX,$sourceY,$sourceFloor,$sourceLng,$sourceLat");
  }

  List<List<String>> paths = segmentPath(temppath);


  List<String> fullPath = [];
  paths.forEach((segment){
    String currentBid = tools.extractBid(segment[0]);
    int currentFloor = tools.extractCoordinates(segment[0]).last;
    if(currentBid != buildingAllApi.outdoorID){
      // int numCols = SingletonFunctionController.building.floorDimenssion[currentBid]![currentFloor]![0];
      // var tempFilled = masterAddCoordinatesBetweenVertices(segment, numCols);
      // var filled = tools.convertToFourPointerPath(tempFilled, currentBid, currentFloor);
      // fullPath.addAll(filled);
      fullPath.addAll(segment);
      print("path on $currentFloor is $segment");
    }else{
      fullPath.addAll(segment);
    }
  });

  print("fullPath $fullPath");

  return convertPath(fullPath, col);
}

paths convertPath(
    List<String> path,
    Map<String, Map<int, List<int>>> col,
    ) {
  final result = <MapEntry<String, Map<int, List<int>>>>[];
  final globalResult = <MapEntry<String, Map<int, List<List<double>>>>>[];

  for (final node in path) {
    final parts = node.split(',');
    if (parts.length != 6) continue;

    final buildingID = parts[0];
    final x = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    final floor = int.tryParse(parts[3]);
    final lat = double.tryParse(parts[5]);
    final lng = double.tryParse(parts[4]);
    var cols = col[buildingID]?[floor]?[0];
    if(buildingID == buildingAllApi.outdoorID && cols == null && col[buildingID]?[0] != null){
      SingletonFunctionController.building.floorDimenssion[buildingID]![floor!] = col[buildingID]![0]!;
      cols = col[buildingID]?[0]?[0];
    }
    print("floors $buildingID,$x,$y,$floor,$cols");


    if (x == null || y == null || floor == null || cols == null) continue;

    final index = (y * cols) + x;
    final globalCoordinate = [lat!, lng!];

    if(result.isNotEmpty && result.last.key == buildingID){
      result.last.value.putIfAbsent(floor, ()=>[]);
      result.last.value[floor]!.add(index);

      globalResult.last.value.putIfAbsent(floor, ()=>[]);
      globalResult.last.value[floor]!.add(globalCoordinate);
    }else{
      result.add(MapEntry(buildingID, {floor: [index]}));
      globalResult.add(MapEntry(buildingID, {floor: [globalCoordinate]}));
    }
  }

  print("result:::${result}");

  return paths(result, globalResult);
}



List<List<String>> segmentPath(List<String> path) {
  if (path.isEmpty) return [];

  List<List<String>> segments = [];
  List<String> currentSegment = [path[0]];

  String currentBid = tools.extractBid(path[0]);
  int currentFloor = tools.extractCoordinates(path[0]).last;

  for (int i = 1; i < path.length; i++) {
    String bid = tools.extractBid(path[i]);
    int floor = tools.extractCoordinates(path[i]).last;

    if (bid == currentBid && floor == currentFloor) {
      currentSegment.add(path[i]);
    } else {
      segments.add(currentSegment);
      currentSegment = [path[i]];
      currentBid = bid;
      currentFloor = floor;
    }
  }

  segments.add(currentSegment);
  print("segments $segments");
  return segments;
}


List<int>? globalPath(String sourceNodeId, String destinationNodeId, int col, EntriesNetwork entriesNetwork){
  List<int> path = [];
  List<Entry>? entries = entriesNetwork.entries[sourceNodeId];
  if(entries != null){
    print("found entries");
    Entry entry = entries.firstWhere((element)=> element.entryId == destinationNodeId);
    for (var point in entry.path) {
      print("point ${point.localCoords}");
      path.add((point.localCoords[1]*col)+point.localCoords[0]);
    }
    print("path $path");
    return path;
  }
  print("found nothing");
  return null;
}