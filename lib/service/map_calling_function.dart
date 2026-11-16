import 'package:flutter/material.dart';

import '../config.dart';
import 'VenueMapScreen.dart';

/// Single entry point for opening the hosted venue map.
class NavigationService {
  static const String defaultVenue = AppConfig.venueName;

  /// Opens the venue map with no landmark selected.
  static Future<void> startVenueNavigation(
    BuildContext context, {
    String venueName = defaultVenue,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => VenueMapScreen(venueName: venueName)),
    );
  }

  /// Opens the map with [landmarkId] (its polyId) selected as the destination.
  static Future<void> startLandmarkNavigation(
    BuildContext context,
    String landmarkId, {
    String venueName = defaultVenue,
  }) {
    if (landmarkId.isEmpty) {
      return startVenueNavigation(context, venueName: venueName);
    }
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => VenueMapScreen(
          venueName: venueName,
          destinationLandmarkId: landmarkId,
        ),
      ),
    );
  }

  static Route<void>? _localizationRoute;

  /// Opens the map with the user localized AT [landmarkId] (e.g. the landmark
  /// whose QR they just scanned).
  static Future<void> startLandmarkLocalization(
    BuildContext context,
    String landmarkId, {
    String venueName = defaultVenue,
  }) {
    if (landmarkId.isEmpty) {
      return startVenueNavigation(context, venueName: venueName);
    }
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = MaterialPageRoute<void>(
      builder: (_) => VenueMapScreen(
        venueName: venueName,
        sourceLandmarkId: landmarkId,
      ),
    );
    // Scanning the next landmark's QR while this map is still open must move
    // the user, not stack a second map (and a second BLE/GPS scan) on top.
    final previous = _localizationRoute;
    _localizationRoute = route;
    if (previous != null && previous.isActive) navigator.removeRoute(previous);
    return navigator.push(route);
  }
}
