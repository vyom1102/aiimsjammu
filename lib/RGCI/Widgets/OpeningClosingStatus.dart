
import 'package:flutter/material.dart';

class OpeningClosingStatus extends StatelessWidget {
  final String startTime;
  final String endTime;

  OpeningClosingStatus({
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {

    DateTime currentDate = DateTime.now();

    DateTime parsedStartTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      int.parse(startTime.split(':')[0]),
      int.parse(startTime.split(':')[1]),
    );
    DateTime parsedEndTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      int.parse(endTime.split(':')[0]),
      int.parse(endTime.split(':')[1]),
    );

    DateTime oneHourFromNow = DateTime.now().add(Duration(hours: 1));
    bool isClosingSoon = parsedEndTime.isAfter(DateTime.now()) &&
        parsedEndTime.isBefore(oneHourFromNow);

    bool isOpen =
        currentDate.isAfter(parsedStartTime) && currentDate.isBefore(parsedEndTime);

    String statusText;
    Color textColor;
    if (isClosingSoon) {
      statusText = 'Closing soon';
      textColor = Colors.orange;
    }else if (isOpen) {
      statusText = 'Open Now';
      textColor = Colors.green;
    }
    else  {
      statusText = 'Closed';
      textColor = Colors.red;
    }

    return Text(
      statusText,
      style: TextStyle(
        color:textColor,
        fontSize: 14,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        height: 0.10,
      ),
    );

  }
}
