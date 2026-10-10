import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/pregnancy_model.dart';

class PregnancyNotificationService {
  PregnancyNotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'pregnancy_care_channel';
  static const String channelName = 'Pregnancy & Maternal Care Alerts';
  static const int dailyNotificationId = 88888;
  static const int testNotificationId = 88889;

  /// Initialize Android channel for pregnancy
  static Future<void> initializeChannel() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: 'Daily maternal care advice and weekly fetal milestone updates',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
    }
  }

  /// Schedule daily maternal notification at the user's chosen time
  static Future<void> scheduleDailyNotification({
    required PregnancyModel model,
    required bool isBn,
  }) async {
    if (!model.isNotificationEnabled) {
      await cancelDailyNotification();
      return;
    }

    await initializeChannel();

    final weekInfo = PregnancyWeekCatalog.getWeekInfo(model.currentWeek);
    final title = isBn
        ? '🌸 ${model.babyNickname}র যত্ন • সপ্তাহ ${model.currentWeek}'
        : '🌸 Baby Care • Week ${model.currentWeek}';

    final body = isBn
        ? weekInfo.notificationTextBn
        : weekInfo.notificationTextEn;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      model.notificationHour,
      model.notificationMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Daily maternal care advice and weekly fetal milestone updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: dailyNotificationId,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Graceful fallback for devices without exact alarm permission
    }
  }

  /// Cancel existing daily pregnancy notification
  static Future<void> cancelDailyNotification() async {
    try {
      await _notificationsPlugin.cancel(id: dailyNotificationId);
    } catch (_) {}
  }

  /// Send instant test notification to show the user how it looks
  static Future<void> sendTestNotification({
    required PregnancyModel model,
    required bool isBn,
  }) async {
    await initializeChannel();

    final weekInfo = PregnancyWeekCatalog.getWeekInfo(model.currentWeek);
    final title = isBn
        ? '🌸 ${model.babyNickname}র যত্ন • সপ্তাহ ${model.currentWeek}'
        : '🌸 Baby Care • Week ${model.currentWeek}';

    final body = isBn
        ? weekInfo.notificationTextBn
        : weekInfo.notificationTextEn;

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Daily maternal care advice and weekly fetal milestone updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    await _notificationsPlugin.show(
      id: testNotificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
