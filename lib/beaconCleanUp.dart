import 'dart:async';


class BeaconCleanUpManager {
  final Map<String, DateTime> _beaconTimestamps = {};
  final Duration _beaconTimeout = const Duration(seconds: 30);
  Timer? _cleanupTimer;
  int _reRouteCountForConfectionary = 0;

  int get reRouteCountForConfectionary => _reRouteCountForConfectionary;

  set reRouteCountForConfectionary(int value) {
    _reRouteCountForConfectionary = value;
  }

  BeaconCleanUpManager() {
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(Duration(seconds: 5), (_) => _removeExpiredBeacons());
  }
  void addBeacon(String beaconId) {
    final now = DateTime.now();
    // Check if beacon is not present or its old entry has expired
    if (!_beaconTimestamps.containsKey(beaconId) ||
        now.difference(_beaconTimestamps[beaconId]!) > _beaconTimeout) {
      _beaconTimestamps[beaconId] = now;
      print('Added $beaconId at $now');
    } else {
      print('Beacon $beaconId already present and not expired yet.');
    }
  }


  void _removeExpiredBeacons() {
    final now = DateTime.now();
    _beaconTimestamps.removeWhere((id, time) => now.difference(time) > _beaconTimeout);

    print("_beaconTimestamps:${_beaconTimestamps}");
  }

  List<String> get activeBeacons => _beaconTimestamps.keys.toList();

  bool containsBeacon(String beaconId) {
    return _beaconTimestamps.containsKey(beaconId);
  }
  void dispose() {
    _cleanupTimer?.cancel();
  }
}
