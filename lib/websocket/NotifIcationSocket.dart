
import 'dart:convert';

import 'package:iwaymaps/websocket/PushNotifications.dart';
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

  static void receiveMessage(){
    channel.on("com.iwayplus.aiimsjammu", (value){
      NotificationData notification = NotificationData.fromJson(value);
      PushNotifications.showSimpleNotificationwithImage(body: notification.body,imageUrl: notification.filepath,payload: notification.body,title: notification.title);
      print("socketMessage${value}");
    });
    List<dynamic> receivedMessage = channel.receiveBuffer;
    print(receivedMessage);
  }

}

