import 'dart:math' show Random;

Future<double> calculateDistance(String locationId) async {

  await Future.delayed(Duration(seconds: 2));

  return (10 + Random().nextInt(90)).toDouble();
}
