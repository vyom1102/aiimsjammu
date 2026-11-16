import 'package:intl/intl.dart';

enum EventStatus {
  notToday,
  alreadyHappened,
  goingOn,
  goingToHappen,
}

EventStatus getEventStatus({
  required String startDate, // yyyy-MM-dd
  required String endDate,   // yyyy-MM-dd
  required String startTime, // yyyy-MM-ddTHH:mm
  required String endTime,   // yyyy-MM-ddTHH:mm
  required List<String>? weekdays, // e.g. ["Friday", "Monday"]
}) {
  final dateFormatter = DateFormat('yyyy-MM-dd');
  final timeFormatter = DateFormat('yyyy-MM-ddTHH:mm');

  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);

  final startDateObj = dateFormatter.parse(startDate);
  final endDateObj = dateFormatter.parse(endDate);

  // 1. Check if today is in the event's date range
  if (todayDate.isBefore(startDateObj) || todayDate.isAfter(endDateObj)) {
    return EventStatus.notToday;
  }

  // 2. Check if today is in the list of weekdays
  final todayWeekday = DateFormat('EEEE').format(now); // e.g. "Friday"
  if (weekdays != null && !weekdays.contains(todayWeekday)) {
    return EventStatus.notToday;
  }

  // 3. Get today's start & end time
  final startTimeObj = timeFormatter.parse(startTime);
  final endTimeObj = timeFormatter.parse(endTime);

  final todayStart = DateTime(
      now.year, now.month, now.day, startTimeObj.hour, startTimeObj.minute);
  final todayEnd = DateTime(
      now.year, now.month, now.day, endTimeObj.hour, endTimeObj.minute);

  if (now.isBefore(todayStart)) {
    return EventStatus.goingToHappen;
  } else if (now.isAfter(todayEnd)) {
    return EventStatus.alreadyHappened;
  } else {
    return EventStatus.goingOn;
  }
}

String? convertUtcToLocal(String? utcString) {
  if(utcString == null){
    return null;
  }
  // Parse the UTC string to DateTime
  DateTime utcTime = DateTime.parse(utcString);

  // Convert to local time
  DateTime localTime = utcTime.toLocal();

  // Format the output (example: yyyy-MM-dd HH:mm)
  return localTime.toIso8601String();
}
