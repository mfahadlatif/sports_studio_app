import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();

  Future<NotificationService> init() async {
    await _setupLocalNotifications();
    await _requestPermissions();
    await _setupFCMHandlers();
    await registerToken();
    return this;
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification click when app is in foreground
        print('Notification clicked: ${details.payload}');
      },
    );
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else {
      print('User declined or has not accepted notification permissions');
    }
  }

  Future<void> _setupFCMHandlers() async {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle background/terminated message click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.data}');
      // Potential navigation logic here
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: details,
      payload: message.data.toString(),
    );
  }

  Future<void> registerToken() async {
    try {
      final authToken = await _storage.read(key: 'auth_token');
      if (authToken == null) return;

      String? token = await _fcm.getToken();
      if (token != null) {
        print('Registering FCM Token: $token');
        await ApiClient().dio.post('/update-fcm-token', data: {
          'token': token,
        });
        print('FCM Token registered successfully');
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      final authToken = await _storage.read(key: 'auth_token');
      if (authToken == null) return;

      print('Clearing FCM Token from backend...');
      await ApiClient().dio.post('/clear-fcm-token');
      print('FCM Token cleared successfully');
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }
}
