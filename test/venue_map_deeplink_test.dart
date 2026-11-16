import 'package:flutter_test/flutter_test.dart';
import 'package:iwaymaps/config.dart';
import 'package:iwaymaps/service/VenueMapScreen.dart';
import 'package:iwaymaps/service/map_calling_function.dart';

/// Parses [link] the way the app does and returns the hosted map URL's query.
Map<String, String> mapQueryFor(String link) {
  final parsed = NavigationService.parseVenueMapDeepLink(Uri.parse(link));
  expect(parsed, isNotNull, reason: link);
  final url = VenueMapScreen.mapUrl(
    venueName: parsed!.venueName,
    destinationLandmarkId: parsed.destinationLandmarkId,
    sourceLandmarkId: parsed.sourceLandmarkId,
  );
  expect(url, startsWith('https://maps.iwayplus.in/iwaymaps/?'));
  return Uri.parse(url).queryParameters;
}

void main() {
  const base = 'aiimsjammu://VenueMapScreen?venueName=AIIMSJAMMU';

  test('both landmarks', () {
    final q = mapQueryFor('$base&destinationLandmarkId=dest1&sourceLandmarkId=src1');
    expect(q, {
      'apiKey': AppConfig.Authorization,
      'venueName': 'AIIMSJAMMU',
      'destinationLandmarkId': 'dest1',
      'sourceLandmarkId': 'src1',
    });
  });

  test('destination only', () {
    final q = mapQueryFor('$base&destinationLandmarkId=dest1');
    expect(q['destinationLandmarkId'], 'dest1');
    expect(q.containsKey('sourceLandmarkId'), isFalse);
  });

  test('source only', () {
    final q = mapQueryFor('$base&sourceLandmarkId=src1');
    expect(q['sourceLandmarkId'], 'src1');
    expect(q.containsKey('destinationLandmarkId'), isFalse);
  });

  test('neither landmark, including empty and {} placeholders', () {
    for (final link in [
      base,
      '$base&destinationLandmarkId=&sourceLandmarkId=',
      '$base&destinationLandmarkId={}&sourceLandmarkId={}',
    ]) {
      final q = mapQueryFor(link);
      expect(q.keys.toSet(), {'apiKey', 'venueName'}, reason: link);
    }
  });

  test('venueName defaults to the app venue and host is case-insensitive', () {
    final q = mapQueryFor('aiimsjammu://venuemapscreen?sourceLandmarkId=src1');
    expect(q['venueName'], AppConfig.venueName);
  });

  test('other links are not treated as map links', () {
    for (final link in [
      'iwayplus://aiimsj.com/doctor?docId=1',
      'aiimsjammu://somethingElse?sourceLandmarkId=src1',
      'https://VenueMapScreen/?sourceLandmarkId=src1',
    ]) {
      expect(NavigationService.parseVenueMapDeepLink(Uri.parse(link)), isNull,
          reason: link);
    }
  });
}
