import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'baseSensorClass.dart';

class MagnetometerSensor implements BaseSensor {
  // static const _compassChannel = EventChannel('com.example.navigation/compass');
  // static Stream<double> get headingStream {
  //   return _compassChannel.receiveBroadcastStream().map((event) => event as double);
  // }
  StreamSubscription? _subscription;
  final StreamController<CompassEvent> _controller = StreamController.broadcast();

  @override
  void startListening() {
    _subscription = FlutterCompass.events!.listen((event) {
      _controller.add(event);
    });
  }
  @override
  Future<void> stopListening() async {
    await _controller.close();
    _subscription?.cancel();
    print("magentometer stream closed:${_controller}");
  }

  @override
  Stream<CompassEvent> get stream => _controller.stream;
}