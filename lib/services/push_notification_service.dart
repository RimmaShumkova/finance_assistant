import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.ensureFirebaseInitialized();
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final ApiService _apiService = ApiService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _listensTokenRefresh = false;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'budget_alerts',
    'Budget alerts',
    description: 'Budget and goal notifications',
    importance: Importance.high,
  );

  static Future<void> ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> initialize() async {
    if (kIsWeb) return;

    await ensureFirebaseInitialized();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _messaging.setAutoInitEnabled(true);
    await _initializeLocalNotifications();

    FirebaseMessaging.onMessage.listen((message) {
      _showForegroundNotification(message);
    });
  }

  Future<void> registerCurrentDevice() async {
    if (kIsWeb) return;

    await _requestPermission();
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('FCM token is empty.');
      return;
    }

    await _apiService.registerDeviceToken(
      token: token,
      platform: _platformName,
    );
    debugPrint('FCM token registered on backend.');

    if (_listensTokenRefresh) return;
    _listensTokenRefresh = true;
    _messaging.onTokenRefresh.listen((newToken) async {
      await _apiService.registerDeviceToken(
        token: newToken,
        platform: _platformName,
      );
      debugPrint('FCM token refreshed on backend.');
    });
  }

  Future<void> registerCurrentDeviceIfSignedIn() async {
    if (!await _apiService.hasSession()) return;
    try {
      await registerCurrentDevice();
    } catch (error) {
      debugPrint('Failed to register FCM token: $error');
    }
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings: settings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      debugPrint('Push received without notification: ${message.messageId}');
      return;
    }

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
    debugPrint('Foreground push displayed: ${message.messageId}');
  }

  String get _platformName {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}
