class BeaconInjector {
  final Map<String, int> _lastSeenSecond = {};
  final Map<String, MapEntry<int, int>> _lastValue = {};
  final Map<String, MapEntry<int, int>> _prevValue = {};
  final int expiry = 3;

  int _currentSecond = -1;

  Map<String, List<int>> process(Map<String, List<int>> current) {
    _currentSecond++;

    for (var entry in current.entries) {
      final beacon = entry.key;
      final newVal = entry.value.last;

      if (_lastValue.containsKey(beacon)) {
        _prevValue[beacon] = _lastValue[beacon]!;
      }

      _lastSeenSecond[beacon] = _currentSecond;
      _lastValue[beacon] = MapEntry(_currentSecond, newVal);
    }

    for (var beacon in _lastSeenSecond.keys.toList()) {
      final lastSecond = _lastSeenSecond[beacon]!;
      final gap = _currentSecond - lastSecond;

      if (gap <= expiry) {
        if (!current.containsKey(beacon) && _prevValue.containsKey(beacon)) {
          final last = _lastValue[beacon]!;
          final prev = _prevValue[beacon]!;

          int timeDiff = last.key - prev.key;
          int valDiff = last.value - prev.value;

          int slope = timeDiff == 0 ? 0 : (valDiff ~/ timeDiff);
          if(slope > 5){
            slope = 5;
          }

          int predicted = last.value + slope * gap;
          // print("predicted $predicted slope $slope gap $gap");
          if(last.value > -75){
            predicted = last.value - (slope * (gap));
          } else if(predicted > -75){
            predicted = predicted - (slope * (gap - 1) * 2);
          }

          current[beacon] = [predicted];
        }
      } else {
        _lastSeenSecond.remove(beacon);
        _lastValue.remove(beacon);
        _prevValue.remove(beacon);
      }
    }

    return current;
  }
}


final injector = BeaconInjector();

void main() {
  List<Map<String, List<int>>> data = [
    {
      "B1": [-82]
    },
    {"B1": [-77]},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
  ];
  for (var i = 0; i < data.length; i++) {
    print("Second $i → ${injector.process(data[i])}");
  }
}
