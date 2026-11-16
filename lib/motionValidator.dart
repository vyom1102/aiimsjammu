import 'dart:async';

import 'package:flutter/services.dart';

class NativeMotionValidator {
  static const EventChannel _movementChannel =
  EventChannel('com.yourapp/motion');

  StreamSubscription? _movementSub;
  bool isUserMoving = false;

  void startMovementListener() {
    _movementSub = _movementChannel.receiveBroadcastStream().listen((event) {
      isUserMoving = event == true;

      // You can tdisprigger a callback, or save this in state
      print("Movement detected: $isUserMoving");
    });
  }

  void stopMovementListener() {
    _movementSub?.cancel();
  }
}
