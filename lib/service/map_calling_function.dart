import 'package:flutter/material.dart';

import '../config.dart';
import 'VenueMapScreen.dart';

/// Single entry point for opening the hosted venue map.
class NavigationService {
  static const String defaultVenue = AppConfig.venueName;

  /// URL scheme and host of the map deep link:
  /// `aiimsjammu://VenueMapScreen?venueName=..&destinationLandmarkId=..&sourceLandmarkId=..`
  static const String deepLinkScheme = 'aiimsjammu';
  static const String deepLinkHost = 'venuemapscreen';

  /// Opens the venue map with no landmark selected.
  static Future<void> startVenueNavigation(
    BuildContext context, {
    String venueName = defaultVenue,
  }) {
    return openMap(context, venueName: venueName);
  }

  /// Opens the map with [landmarkId] (its polyId) selected as the destination.
  static Future<void> startLandmarkNavigation(
    BuildContext context,
    String landmarkId, {
    String venueName = defaultVenue,
  }) {
    return openMap(context,
        venueName: venueName, destinationLandmarkId: landmarkId);
  }

  /// Opens the map with the user localized AT [landmarkId] (e.g. the landmark
  /// whose QR they just scanned).
  static Future<void> startLandmarkLocalization(
    BuildContext context,
    String landmarkId, {
    String venueName = defaultVenue,
  }) {
    return openMap(context, venueName: venueName, sourceLandmarkId: landmarkId);
  }

  static Route<void>? _mapRoute;

  /// Opens the map with any combination of landmarks: neither, a destination,
  /// a source (where the user is), or both. Blank IDs count as absent.
  static Future<void> openMap(
    BuildContext context, {
    String venueName = defaultVenue,
    String? destinationLandmarkId,
    String? sourceLandmarkId,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = MaterialPageRoute<void>(
      builder: (_) => VenueMapScreen(
        venueName: venueName.isEmpty ? defaultVenue : venueName,
        destinationLandmarkId: _blankToNull(destinationLandmarkId),
        sourceLandmarkId: _blankToNull(sourceLandmarkId),
      ),
    );
    // A new map request while one is open (another QR scan or deep link)
    // replaces it rather than stacking a second map and a second BLE/GPS scan.
    final previous = _mapRoute;
    _mapRoute = route;
    if (previous != null && previous.isActive) navigator.removeRoute(previous);
    return navigator.push(route);
  }

  /// Reads a `aiimsjammu://VenueMapScreen` deep link, or returns null for
  /// any other link. `venueName`, `destinationLandmarkId` and
  /// `sourceLandmarkId` are all optional; a missing venue falls back to
  /// [defaultVenue].
  static ({
    String venueName,
    String? destinationLandmarkId,
    String? sourceLandmarkId
  })? parseVenueMapDeepLink(Uri uri) {
    final isVenueMapLink = uri.scheme.toLowerCase() == deepLinkScheme &&
        (uri.host.toLowerCase() == deepLinkHost ||
            uri.pathSegments.any((s) => s.toLowerCase() == deepLinkHost));
    if (!isVenueMapLink) return null;
    final params = uri.queryParameters;
    return (
      venueName: _blankToNull(params['venueName']) ?? defaultVenue,
      destinationLandmarkId: _blankToNull(params['destinationLandmarkId']),
      sourceLandmarkId: _blankToNull(params['sourceLandmarkId']),
    );
  }

  /// Opens the map for a `aiimsjammu://VenueMapScreen` deep link. Returns
  /// false (and does nothing) for any other link.
  static bool openFromDeepLink(BuildContext context, Uri uri) {
    final link = parseVenueMapDeepLink(uri);
    if (link == null) return false;
    openMap(
      context,
      venueName: link.venueName,
      destinationLandmarkId: link.destinationLandmarkId,
      sourceLandmarkId: link.sourceLandmarkId,
    );
    return true;
  }

  // `{}` is the empty placeholder in the documented link template.
  static String? _blankToNull(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty || v == '{}' || v == 'null') ? null : v;
  }
}
