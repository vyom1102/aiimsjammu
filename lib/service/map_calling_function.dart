import 'package:flutter/material.dart';
import 'VenueMapScreen.dart';
import '../config.dart';

class NavigationService {
  static const String defaultVenue = AppConfig.venueName;
  static const List<String> defaultbuildingIds = AppConfig.buildingIds;

  static Future<void> startVenueNavigation(
      BuildContext context, {
        String venueName = defaultVenue,
        List<String> buildingIds = defaultbuildingIds,
      }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => VenueMapScreen(venueName: venueName, buildingIDs: buildingIds,)),
    );
  }

  static Future<void> startLandmarkNavigation(
      BuildContext context,
      String landmarkId, {
        String venueName = defaultVenue,
        List<String> buildingIds = defaultbuildingIds,
      }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => VenueMapScreen(
          venueName: venueName,
          destinationLandmarkId: landmarkId,
          buildingIDs: buildingIds,
        ),
      ),
    );
  }
}
