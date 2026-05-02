import 'dart:io';
import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';
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

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      print('Token refreshed: $newToken');
      registerToken();
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
      if (authToken == null) {
        print('🔔 [NotificationService] No auth token found, skipping token registration');
        return;
      }

      String? token;
      
      if (Platform.isIOS) {
        // On iOS, we often need to wait for the APNs token to be available
        // before Firebase can provide an FCM token.
        print('🔔 [NotificationService] Checking APNs token for iOS...');
        String? apnsToken = await _fcm.getAPNSToken();
        
        int retryCount = 0;
        while (apnsToken == null && retryCount < 3) {
          print('🔔 [NotificationService] APNs token not yet available, retrying in 2 seconds... (Attempt ${retryCount + 1})');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _fcm.getAPNSToken();
          retryCount++;
        }

        if (apnsToken != null) {
          print('✅ [NotificationService] APNs Token acquired: $apnsToken');
        } else {
          print('❌ [NotificationService] Failed to acquire APNs Token after retries');
        }
      }

      // For both Android and iOS, we use getToken() for Firebase Cloud Messaging.
      // On iOS, getToken() automatically maps the APNs token to an FCM token.
      token = await _fcm.getToken();

      if (token != null) {
        print('🚀 [NotificationService] Registering FCM Token: $token');
        final response = await ApiClient().dio.post('/update-fcm-token', data: {
          'token': token,
        });
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ [NotificationService] Token registered successfully on backend');
        } else {
          print('❌ [NotificationService] Backend failed to register token: ${response.statusCode}');
        }
      } else {
        print('❌ [NotificationService] FCM Token is null, cannot register');
      }
    } catch (e) {
      print('❌ [NotificationService] Error registering token: $e');
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
