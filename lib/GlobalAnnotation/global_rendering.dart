import 'package:flutter/material.dart';
import 'package:iwaymaps/ELEMENTS/HelperClass.dart';

import '../APIMODELS/GlobalAnnotationModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;

Future<Set<geo.Polygon>?> globalRendering(GlobalModel data, Function polygonTap) async {

  Set<geo.Polygon> polygons = Set();

  var mappingElements = data.mappingElements;

  if(mappingElements == null || mappingElements.isEmpty){
    return null;
  }

  for (var element in mappingElements) {
    // Null check for geometry
    if(element.geometry == null || element.geometry!.type != "Polygon") {
      continue;
    }

    // Null check for coordinates
    if(element.geometry!.coordinates == null ||
        element.geometry!.coordinates!.isEmpty ||
        element.geometry!.coordinates!.first == null) {
      continue;
    }

    List<geo.LatLng> coordinates = [];

    for (var cords in element.geometry!.coordinates!.first) {
      if(cords != null && cords.length >= 2) {
        coordinates.add(geo.LatLng(cords[1], cords[0]));
      }
    }

    if(coordinates.isNotEmpty) {
      coordinates.removeLast();
    }

    if (coordinates.length > 2) {
      // Get property type safely
      final propertyType = element.properties?.type;
      final propertyName = element.properties?.name ?? '';
      final imageFile = element.properties?.imageFile ?? '';
      final elementId = element.id ?? element.sId ?? '';

      // Null check for elementId
      if(elementId.isEmpty) {
        continue;
      }

      if (propertyType == "Outdoor Block Layer") {
        polygons.add(
            geo.Polygon(
              //IF CHANGING POLY-ID SHOULD CHANGE REGEX ALSO IN NAVIGATION DART FILE renderCampus()
                polygonId: geo.PolygonId("Outdoor Block Layer +$propertyName imageFile +$imageFile sId +$elementId"),
                points: coordinates,
                strokeWidth: 1,
                strokeColor: _getStrokeColor(element),
                fillColor: _getFillColor(element),
                consumeTapEvents: true,
                onTap: () {
                  polygonTap(coordinates, element.id, 'assets/Generic Marker.png');
                }
            )
        );
      } else {

        //IF CHANGING POLY-ID SHOULD CHANGE REGEX ALSO IN NAVIGATION DART FILE renderCampus()
        final polygonId = propertyType?.toLowerCase() == "block layer"
            ? geo.PolygonId("block layer +$propertyName imageFile +$imageFile sId +$elementId")
            : geo.PolygonId(elementId);

        if(propertyType?.toLowerCase() == "block layer"){
          print("polygonId check${polygonId}");
        }


        polygons.add(
            geo.Polygon(
                polygonId: polygonId,
                points: coordinates,
                strokeWidth: 1,
                strokeColor: _getStrokeColor(element),
                fillColor: _getFillColor(element),
                consumeTapEvents: true,
                onTap: () {
                  polygonTap(coordinates, element.id, 'assets/Generic Marker.png');
                }
            )
        );
      }
    }
  }

  print("returning polygons ${polygons.length}");
  return polygons;
}

// Helper function to get stroke color safely
Color _getStrokeColor(dynamic element) {
  final strokeColor = element.properties?.strokeColor;
  final propertyType = element.properties?.type;

  if(strokeColor != null && strokeColor != "undefined" && strokeColor.isNotEmpty) {
    try {
      final cleanColor = strokeColor.replaceAll('#', '');
      return Color(int.parse('0xFF$cleanColor'));
    } catch (e) {
      print("Error parsing stroke color: $e");
    }
  }

  // Fallback to color map or default
  if(propertyType != null && polygonColorMap.containsKey(propertyType)) {
    return polygonColorMap[propertyType]!['strokeColor']!;
  }

  return polygonColorMap['default']!['strokeColor']!;
}

// Helper function to get fill color safely
Color _getFillColor(dynamic element) {
  final fillColor = element.properties?.fillColor;
  final propertyType = element.properties?.type;

  if(fillColor != null && fillColor != "undefined" && fillColor.isNotEmpty) {
    try {
      final cleanColor = fillColor.replaceAll('#', '');
      return Color(int.parse('0xFF$cleanColor'));
    } catch (e) {
      print("Error parsing fill color: $e");
    }
  }

  // Fallback to color map or default
  if(propertyType != null && polygonColorMap.containsKey(propertyType)) {
    return polygonColorMap[propertyType]!['fillColor']!;
  }

  return polygonColorMap['default']!['fillColor']!;
}

final Map<String, Map<String, Color>> polygonColorMap = {
  // Green areas & sports
  'green_area': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},
  'auditorium': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},
  'gym': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},
  'swimming': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},
  'basketball': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},
  'football': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},
  'tennis': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},
  'cricket': {'strokeColor': Color(0xffADFA9E), 'fillColor': Color(0xffE7FEE9)},

  // Facilities
  'lift': {'strokeColor': Color(0xffB5CCE3), 'fillColor': Color(0xffDAE6F1)},
  'washroom': {'strokeColor': Color(0xff6EBCF7), 'fillColor': Color(0xFFE7F4FE)},
  'fire': {'strokeColor': Colors.black, 'fillColor': Color(0xffF21D0D)},
  'water': {'strokeColor': Color(0xff6EBCF7), 'fillColor': Color(0xffE7F4FE)},

  // Restricted
  'restricted_area': {'strokeColor': Color(0xffCCCCCC), 'fillColor': Color(0xffE6E6E6)},
  'non_walkable_area': {'strokeColor': Color(0xffCCCCCC), 'fillColor': Color(0xffE6E6E6)},
  'wall': {'strokeColor': Color(0xffCCCCCC), 'fillColor': Color(0xffE6E6E6)},

  // Rooms
  'lr': {'strokeColor': Color(0xffA38F9F), 'fillColor': Color(0xffE8E3E7)},
  'lab': {'strokeColor': Color(0xffA38F9F), 'fillColor': Color(0xffE8E3E7)},
  'office': {'strokeColor': Color(0xffA38F9F), 'fillColor': Color(0xffE8E3E7)},
  'pantry': {'strokeColor': Color(0xffA38F9F), 'fillColor': Color(0xffE8E3E7)},
  'reception': {'strokeColor': Color(0xffA38F9F), 'fillColor': Color(0xffE8E3E7)},
  'atm': {'strokeColor': Color(0xffE99696), 'fillColor': Color(0xffFBEAEA)},
  'health': {'strokeColor': Color(0xffE99696), 'fillColor': Color(0xffFBEAEA)},

  'default': {'strokeColor': Color(0xffCCCCCC), 'fillColor': Color(0xffE6E6E6)},
};