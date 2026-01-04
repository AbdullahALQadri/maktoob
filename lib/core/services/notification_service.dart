// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// //
// // class NotificationService {
// //   static final _localNotifications = FlutterLocalNotificationsPlugin();
// //   static final _firebaseMessaging = FirebaseMessaging.instance;
// //
// //   Future<void> init() async {
// //     // Request permissions (iOS)
// //     await _firebaseMessaging.requestPermission();
// //
// //     // 🔑 Get and print FCM Token
// //     final token = await _firebaseMessaging.getToken();
// //     print('🔐 FCM Token: $token'); // <-- Copy this token for Firebase Console testing
// //
// //     // Init local notifications
// //     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
// //     const iOS = DarwinInitializationSettings();
// //     const initSettings = InitializationSettings(android: android, iOS: iOS);
// //     await _localNotifications.initialize(initSettings);
// //
// //     // Foreground
// //     FirebaseMessaging.onMessage.listen(_showNotification);
// //
// //     // Background or terminated
// //     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //       // You can navigate here if needed
// //     });
// //   }
// //
// //   static Future<void> _showNotification(RemoteMessage message) async {
// //     final notification = message.notification;
// //     if (notification == null) return;
// //
// //     const details = NotificationDetails(
// //       android: AndroidNotificationDetails(
// //         'channel_id',
// //         'channel_name',
// //         importance: Importance.max,
// //         priority: Priority.high,
// //       ),
// //       iOS: DarwinNotificationDetails(),
// //     );
// //
// //     await _localNotifications.show(
// //       notification.hashCode,
// //       notification.title,
// //       notification.body,
// //       details,
// //     );
// //   }
// // }
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//   FlutterLocalNotificationsPlugin();
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;
//
//   Future<void> init() async {
//     // Request permission on iOS
//     await _firebaseMessaging.requestPermission();
//
//     // Initialize local notifications
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings();
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//     await _localNotifications.initialize(initSettings);
//
//     // Show token in logs
//     String? token = await _firebaseMessaging.getToken();
//     print('📱 FCM Token: $token');
//
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen(_showNotification);
//
//     // Handle messages when app is opened from background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('📩 App opened from notification: ${message.notification?.title}');
//     });
//   }
//
//   static Future<void> _showNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     if (notification == null) return;
//
//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'high_importance_channel', // Same as AndroidManifest.xml
//         'High Importance Notifications',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//
//     await _localNotifications.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       details,
//     );
//   }
// }
//
