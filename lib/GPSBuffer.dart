class GPSBuffer {
  final List<double> _latitudes = [];
  final List<double> _longitudes = [];

  GPSBuffer();

  void add(double lat, double lon) {
    _latitudes.add(lat);
    _longitudes.add(lon);
  }

  void Print(){
    print("_latitudes $_latitudes, _longitudes $_longitudes");
  }

  List<double>? getRobustPosition() {
    List<double>? filterOutliers(List<double> values) {
      List<double> sorted = [...values]..sort();
      if(sorted.isEmpty) return null;
      double median = sorted[sorted.length ~/ 2];
      List<double> absDevs = values.map((v) => (v - median).abs()).toList();
      List<double> sortedDevs = [...absDevs]..sort();
      double mad = sortedDevs[sortedDevs.length ~/ 2];
      double threshold = 3 * mad;
      return values.where((v) => (v - median).abs() <= threshold).toList();
    }

    List<double>? filteredLat = filterOutliers(_latitudes);
    List<double>? filteredLon = filterOutliers(_longitudes);
    if(filteredLat == null || filteredLon == null){
      return null;
    }
    double avg(List<double> vals) => vals.reduce((a, b) => a + b) / vals.length;

    double initLat = filteredLat.isNotEmpty
        ? avg(filteredLat)
        : _latitudes[_latitudes.length ~/ 2];
    double initLon = filteredLon.isNotEmpty
        ? avg(filteredLon)
        : _longitudes[_longitudes.length ~/ 2];
    _latitudes.clear();
    _longitudes.clear();
    return [initLat, initLon];
  }
}