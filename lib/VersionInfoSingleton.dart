class VersionInfoSingleton {
  // Private named constructor
  VersionInfoSingleton._internal();

  // Static private instance
  static final VersionInfoSingleton _instance = VersionInfoSingleton._internal();

  // Factory constructor that returns the same instance
  factory VersionInfoSingleton() {
    return _instance;
  }

  static int polylineDataVersion=0;
  static int buildingDataVersion=0;
  static int patchDataVersion=0;
  static int landmarksDataVersion=0;
  static int previousPolylineDataVersion =0;
  static int previousBuildingDataVersion=0;
  static int previousPatchDataVersion=0;
  static int previousLandmarksDataVersion=0;

  // Example method
   void doSomething() {
    print('Doing something...');
  }
}
