
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart';

import 'Model/NotificationData.dart';

class NotificationSocket{
  NotificationSocket(){
    channel.connect();
  }

  static final channel = io('https://dev.iwayplus.in', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });


}

