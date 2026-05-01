// import 'package:flutter/material.dart';
// import 'package:iwaymaps/LOGIN%20SIGNUP/SignIn.dart';
// import 'dart:async';
//
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     );
//
//     _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
//     );
//
//     _animationController.forward();
//
//     // Navigate to main screen after animation completes
//     Timer(const Duration(seconds: 4), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) =>  SignIn()),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//
//                     AnimatedBuilder(
//                         animation: _animation,
//                         builder: (context, child) {
//                           return Container(
//                             width: 80,
//                             height: 80,
//                             child: CustomPaint(
//                               painter: CircleWaterFillPainter(
//                                 fillLevel: _animation.value,
//                                 circleColor: Colors.blue[800]!,
//                                 waterColor: Colors.blue[300]!,
//                               ),
//                             ),
//                           );
//                         }
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // Footer text
//             const Padding(
//               padding: EdgeInsets.only(bottom: 20),
//               child: Column(
//                 children: [
//                   Text(
//                     'Design & Developed by Iwayplus',
//                     style: TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                   Text(
//                     'All copyrights reserved.',
//                     style: TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Custom painter for water-filling circle animation
// class CircleWaterFillPainter extends CustomPainter {
//   final double fillLevel;
//   final Color circleColor;
//   final Color waterColor;
//
//   CircleWaterFillPainter({
//     required this.fillLevel,
//     required this.circleColor,
//     required this.waterColor,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw the circle outline
//     Paint circlePaint = Paint()
//       ..color = circleColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;
//
//     Offset center = Offset(size.width / 2, size.height / 2);
//     double radius = size.width / 2 - 2;
//
//     canvas.drawCircle(center, radius, circlePaint);
//
//     // Calculate water fill height based on animation value
//     double waterHeight = size.height * fillLevel;
//     double waterY = size.height - waterHeight;
//
//     // Create clip path for the circle
//     Path clipPath = Path()
//       ..addOval(Rect.fromCircle(center: center, radius: radius));
//
//     canvas.clipPath(clipPath);
//
//     // Draw water fill
//     Paint waterPaint = Paint()
//       ..color = waterColor
//       ..style = PaintingStyle.fill;
//
//     canvas.drawRect(
//       Rect.fromLTWH(0, waterY, size.width, waterHeight),
//       waterPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(CircleWaterFillPainter oldDelegate) {
//     return oldDelegate.fillLevel != fillLevel;
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/SignIn.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _changeBackground = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _animationController.forward();

    // Listen for animation completion to change background
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _changeBackground = true;
        });
      }
    });

    // Navigate to main screen after animation completes
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn(emailOrPhoneNumber: 'mailtohimanshu100@gmail.com',password: 'BlackWater4232',)),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Change background color based on animation completion
      backgroundColor: _changeBackground ? const Color(0xFF003366) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !_changeBackground?
                    AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            width: 80,
                            height: 80,
                            child: Lottie.asset('assets/images/waterfillanimation.json'),
                            // CustomPaint(
                            //   painter: CircleWaterFillPainter(
                            //     fillLevel: _animation.value,
                            //     circleColor: Colors.blue[800]!,
                            //     waterColor: Colors.blue[300]!,
                            //   ),
                            // ),
                          );
                        }
                    ):Container(
                      height: 200,
                      width: 200,
                      child: Image.asset('assets/images/SplashLogo.png'),
                    ),
                  ],
                ),
              ),
            ),
            // Footer text
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Text(
                    'Design & Developed by Iwayplus',
                    style: TextStyle(
                        color: _changeBackground ? Colors.white70 : Colors.grey[700]!,
                        fontSize: 12
                    ),
                  ),
                  Text(
                    'All copyrights reserved.',
                    style: TextStyle(
                        color: _changeBackground ? Colors.white70 : Colors.grey[700]!,
                        fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for water-filling circle animation
class CircleWaterFillPainter extends CustomPainter {
  final double fillLevel;
  final Color circleColor;
  final Color waterColor;

  CircleWaterFillPainter({
    required this.fillLevel,
    required this.circleColor,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the circle outline
    Paint circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2 - 2;

    canvas.drawCircle(center, radius, circlePaint);

    // Calculate water fill height based on animation value
    double waterHeight = size.height * fillLevel;
    double waterY = size.height - waterHeight;

    // Create clip path for the circle
    Path clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.clipPath(clipPath);

    // Draw water fill
    Paint waterPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, waterY, size.width, waterHeight),
      waterPaint,
    );
  }

  @override
  bool shouldRepaint(CircleWaterFillPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel;
  }
}