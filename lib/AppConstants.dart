class Appconstants{
  /// UserState.dart
  static const int secondsBeforeStartingKalman = 10;
  static const int minimumDistanceForKalmanReLocalization = 33; // in feet
  static const int distanceBWDestAndTurn = 10; // in feet <> Distance Between Destination And Last Turn To Terminate Navigation
  static const int isNearDestinationForOutdoor = 5; // in meters
  static const int isNearDestinationForIndoor = 2; // in meters
  static const int passingByLandmarkDistance = 5; // in feet
  static const int passingByDoorDistance = 10; // in feet
  static const int passingByAlertDistance = 6; // in feet
  static const int passingByElementDistance = 6; // in feet
  static const int mergingPositionsInOutdoor = 15; // in feet
  static const int mergingPositionsInIndoor = 6; // in feet
  static const double moveToNearestTurn = 10; // in feet
  static const double radiusForNearestTurnPoint = 11; // in feet
  static const int distanceForSwitchingToNextBuilding = 5; // in feet

  /// MotionModel.dart
  static const nonWalkableStuckCount = 5; // PDR Counts
  static const rerouteDistanceForOutdoor = 40; // in feet
  static const rerouteDistanceForIndoor = 20; // in feet
}