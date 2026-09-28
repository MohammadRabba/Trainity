import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

Future<void> createnewnote(String title, String body) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
    displayOnBackground: true,
    displayOnForeground: true,
    id: createUniqueId(),
    channelKey: 'Basic_channel',
    title: title,
    backgroundColor: Colors.blue,
    color: Colors.blueGrey,
    body: body,
    notificationLayout: NotificationLayout.BigPicture,
  ));
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}
