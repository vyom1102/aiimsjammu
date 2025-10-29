import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;

import 'MapRotationController.dart';

class OrientationButton extends StatelessWidget {
  MapRotationController? mapRotationController;
  OrientationButton({super.key, required this.mapRotationController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        return Semantics(
          label: mapRotationController!.isRotating
              ? 'Stop map rotation'
              : 'Enable map rotation',
          button: true,
          child: ElevatedButton(
            onPressed: () {
              mapRotationController!.toggleCompassRotation();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              elevation: 8,
              backgroundColor: Colors.white,
            ),
            child: Transform.rotate(
              angle: (mapRotationController!.mapBearing * (math.pi / 180)) * -1,
              child: mapRotationController!.isRotating
                  ? Image.asset(
                'assets/mapRotation.png',
                width: 24,
                height: 24,
              )
                  : SvgPicture.asset(
                'assets/compass.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        );
      },
    );
  }

}
