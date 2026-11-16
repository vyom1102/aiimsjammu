class KeyCounter {
  String? _currentKey;
  int _counter = 0;

  MapEntry<String, int> update(String newKey) {
    if (_currentKey == newKey) {
      _counter++;
    } else {
      _currentKey = newKey;
      _counter = 1;
    }
    return MapEntry(_currentKey!, _counter);
  }

  MapEntry<String, int>? current() {
    if (_currentKey == null) return null; // No key set yet
    return MapEntry(_currentKey!, _counter);
  }

}