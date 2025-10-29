import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Cell.dart';
import 'ZoomCalculator.dart';

class MapRotationController {
  final GoogleMapController _mapController;
  BuildContext context;
  CameraPosition _currentPosition;

  LatLng? _center;
  LatLng? _element;
  List<Cell>? _path;
  bool? _isNavigating;

  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _isRotating = false;

  MapRotationController(this._mapController, this._currentPosition, this.context);

  void updateCameraPosition(CameraPosition newPosition, {required LatLng? center, required LatLng? element, required List<Cell>? path, required bool? isNavigating}) {
    if (_isRotating && _compassSubscription != null) {
      if (_currentPosition.target.latitude != newPosition.target.latitude ||
          _currentPosition.target.longitude != newPosition.target.longitude) {
        stopCompassRotation();
      }
    }
    _center = center;
    _element = element;
    _path = path;
    _isNavigating = isNavigating;

    _currentPosition = newPosition;
  }

  double get mapBearing => _currentPosition.bearing;

  void startCompassRotation({double? zoom, LatLng? center}) {
    if (_compassSubscription != null) return;

    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      final double heading = event.heading ?? 0.0;

      _mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: center??_currentPosition.target,
            zoom: zoom??_currentPosition.zoom,
            tilt: _currentPosition.tilt,
            bearing: heading,
          ),
        ),
      );
      zoom = _currentPosition.zoom;
    });

    _isRotating = true;
  }

  Future<void> moveToTarget(LatLng? center, {double tilt = 48.0}) async {
    double heading = _currentPosition.bearing;
    CompassEvent? event = await FlutterCompass.events?.first;
    if (event != null && event.heading != null) {
      heading = event.heading!;
    }

    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: center??_currentPosition.target,
          zoom: 20,
          bearing: heading,
          tilt: center != null?tilt:0.0,
        ),
      ),
    );
  }

  Future<void> moveToElement(LatLng element) async {
    return await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:element,
          zoom: 22,
          bearing: _currentPosition.bearing,
          tilt: 0.0,
        ),
      ),
    );
  }

  Future<void> _boundLocationsInScreen(LatLng element, bool mapRotation) async {
    await stopCompassRotation();
    moveToElement(element);
    if(!mapRotation || _center == null) return;
    await Future.delayed(Duration(seconds: 1));
    double zoom = await boundLocations(element);
    await Future.delayed(Duration(seconds: 1));
    return startCompassRotation(zoom: zoom);
  }

  Future<double> boundLocations(LatLng element, {double tilt = 48.0}) async {
    Size screenSize = MediaQuery.of(context).size;
    double zoom = FitBoundsCalculator.calculateZoom(
      center: _center!, // example: Delhi
      element: element, // example: Gurgaon
      screenSize: screenSize,
    );
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _center!,
          zoom: zoom,
          bearing: _currentPosition.bearing,
          tilt: tilt,
        ),
      ),
    );
    return zoom;
  }

  Future<void> stopCompassRotation() async {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _isRotating = false;
    return await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition.target,
          zoom: _currentPosition.zoom,
          bearing: _currentPosition.bearing,
          tilt: 0.0,
        ),
      ),
    );
  }

  Future<void> activatePathRotation({bool mapRotation = true}) async {
    print("activatePathRotation $mapRotation");
    if(!mapRotation) return ;
    await moveToTarget(_center, tilt: 64);
    await Future.delayed(const Duration(milliseconds: 500));
    startCompassRotation();
  }

  Future<void> fitElementAndRotate({LatLng? element, bool mapRotation = true}) async {
    await _boundLocationsInScreen(element??_element!, mapRotation);
  }

  Future<void> _centerAndRotate() async {
    await moveToTarget(_center);
    await Future.delayed(const Duration(milliseconds: 500));
    startCompassRotation();
  }

  Future<void> _startBasicCompassRotation() async {
    startCompassRotation();
  }

  Future<void> _startCompassRotationWithFixedCenter() async {
    startCompassRotation(center: _center);
  }

  Future<void> pauseRotation() async {
    if(!_isRotating) return;
    _compassSubscription?.cancel();
    _compassSubscription = null;
    return await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition.target,
          zoom: _currentPosition.zoom,
          bearing: _currentPosition.bearing,
          tilt: 0.0,
        ),
      ),
    );
  }

  Future<void> toggleCompassRotation({bool turnOff = false}) async {
    if (turnOff || _isRotating) {
      await stopCompassRotation();

      if(_isNavigating??false){

      } else if(hasPath){
        await boundLocations(_element!);
      } else if (hasElement) {
        await moveToElement(_element!);
      }
      return;
    }

    if(_isNavigating??false){
      _centerAndRotate();
    } else if (hasPath) {
      await activatePathRotation();
    } else if (hasElement) {
      await fitElementAndRotate();
    } else if (hasCenter) {
      await _centerAndRotate();
    } else {
      await _startBasicCompassRotation();
    }
  }


  bool get isRotating => _isRotating;

  bool get hasPath => _path != null && _path!.isNotEmpty;
  bool get hasCenter => _center != null;
  bool get hasElement => _element != null;


  void dispose() {
    stopCompassRotation();
  }
}

