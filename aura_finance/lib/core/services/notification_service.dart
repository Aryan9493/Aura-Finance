import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Skip native timezone initialization on web
    if (kIsWeb) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));
    } else {
      try {
        tz.initializeTimeZones();
        final String locationName = (await FlutterTimezone.getLocalTimezone()).toString();
        tz.setLocalLocation(tz.getLocation(locationName));
      } catch (e) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // FIX: Using named parameter 'settings' for v21.x compatibility
    if (!kIsWeb) {
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {},
      );
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aura_finance_channel',
      'Aura Finance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
