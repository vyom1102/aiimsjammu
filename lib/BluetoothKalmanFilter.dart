import 'dart:math';

class BluetoothKalmanFilter {
  double? estimate;
  double error = 1.0;
  final double processNoise;
  final double measurementNoise;

  BluetoothKalmanFilter({this.processNoise = 0.01, this.measurementNoise = 1.0});

  double update(double measurement) {
    estimate ??= measurement;
    error += processNoise;
    final gain = error / (error + measurementNoise);
    estimate = estimate! + gain * (measurement - estimate!);
    error *= (1 - gain);
    return estimate!;
  }


  List<double> removeOutliersIQR(List<double> data) {
    if (data.length < 4) return data;
    List<double> sorted = [...data]..sort();
    int q1Index = (sorted.length * 0.25).floor();
    int q3Index = (sorted.length * 0.75).floor();
    double q1 = sorted[q1Index];
    double q3 = sorted[q3Index];
    double iqr = q3 - q1;
    double lower = q1 - 1.5 * iqr;
    double upper = q3 + 1.5 * iqr;
    return data.where((x) => x >= lower && x <= upper).toList();
  }

  bool isStable(List<double> data, [double stdThreshold = 4.0]) {
    if (data.length < 2) return true;
    double mean = data.reduce((a, b) => a + b) / data.length;
    double variance = data.map((x) => pow(x - mean, 2)).reduce((a, b) =>
    a + b) / data.length;
    double stdDev = sqrt(variance);
    return stdDev <= stdThreshold;
  }

  double exponentialWeight(double rssi) {
    double value = pow(10, -0.1 * rssi.abs()).toDouble();
    double scaled = value * 1e9;
    double truncated = (scaled * 100).floor() / 100;
    return truncated;
  }

  MapEntry<String?, Map<String, Map<String, dynamic>>> getNearestBeacon(Map<String, List<double>> beacons, {double minStrength = 95.0, double minDelta = 1.5}) {
    final kalmanFilters = <String, BluetoothKalmanFilter>{};
    final smoothedBeacons = <String, Map<String, dynamic>>{};
    String? bestBeacon;
    double bestScore = double.negativeInfinity;
    double? secondBestScore;
    beacons.forEach((id, rssiList) {
      List<double> cleaned = removeOutliersIQR(rssiList);
      kalmanFilters.putIfAbsent(id, () => BluetoothKalmanFilter());
      BluetoothKalmanFilter kf = kalmanFilters[id]!;
      List<double> smoothed = cleaned.map((rssi) => kf.update(rssi)).toList();
      if (!isStable(smoothed)) return;
      List<double> weights = smoothed.map(exponentialWeight).toList();
      if(weights.isEmpty) return;
      double totalWeight = weights.reduce((a, b) => a + b);
      double weightedAvg = 0;
      for (int i = 0; i < smoothed.length; i++) {
        weightedAvg += smoothed[i] * weights[i];
      }
      weightedAvg /= totalWeight;
      smoothedBeacons[id] = {
        'smoothed': smoothed,
        'weightedAvg': weightedAvg,
      };
      if (weightedAvg > bestScore) {
        secondBestScore = bestScore;
        bestScore = weightedAvg;
        bestBeacon = id;
      } else if (secondBestScore == null || weightedAvg > secondBestScore!) {
        secondBestScore = weightedAvg;
      }
    });
    // Final decision check
    if (bestScore < minStrength || (secondBestScore != null &&
        (bestScore - secondBestScore!).abs() < minDelta)) {
      bestBeacon = null;
    }
    return MapEntry(bestBeacon, smoothedBeacons);
  }
}
void main() {
  Map<String, List<double>> beacons = {
    "IW25030974": [-73, -78, -72, -77, -72, -89, -79, -72],
    "IW25030973": [-92, -93, -94], // very weak
    "IW25030975": [-87, -83, -92, -89, -72, -94, -76],
    "IW25030976": [-84, -83, -80, -94, -82, -83, -89],
    "IW25030906": [-100, -100, -101] // filtered out
  };
  var result = BluetoothKalmanFilter().getNearestBeacon(beacons);
  String? nearest = result.key;
  var allBeacons = result.value;
  if (nearest == null) {
    print(":warning: No reliable beacon found — all too weak or unstable.");
  } else {
    print("\n:white_check_mark: Nearest Beacon: $nearest");
  }
  print("\n:signal_strength: Beacon Details:");
  allBeacons.forEach((id, data) {
    List<double> smoothed = data['smoothed'];
    double avg = data['weightedAvg'];
    print("$id:");
    print("  Smoothed RSSI: ${smoothed.map((x) => x.toStringAsFixed(1)).toList()}");
    print("  Weighted Avg : ${avg.toStringAsFixed(2)}\n");
  });
}