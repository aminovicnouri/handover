import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:handover/services/geofence_service_manager.dart';
import 'package:handover/view/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WillStartForegroundTask(
          onWillStart: () async {
            // You can add a foreground task start condition.
            return GeofenceServiceManager.instance().isRunningService();
          },
          androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'geofence_service_notification_channel',
            channelName: 'Geofence Service Notification',
            channelDescription:
                'This notification appears when the geofence service is running in the background.',
            channelImportance: NotificationChannelImportance.HIGH,
            priority: NotificationPriority.HIGH,
            isSticky: true,
          ),
          iosNotificationOptions: const IOSNotificationOptions(),
          notificationTitle: 'Geofence Service is running',
          notificationText: 'Tap to return to the app',
          foregroundTaskOptions: const ForegroundTaskOptions(),
          child: const HomePage()),
    ),
  );
}


