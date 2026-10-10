import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/medicine_reminder/models/medicine_reminder_model.dart';
import '../../app/app_routes.dart';
import '../../features/health_tips/repository/health_tips_repository.dart';
import '../../features/health_tips/view/health_tip_detail_screen.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String _medicineChannelId = 'medicine_reminder_channel';
  static const String _medicineChannelName = 'Medicine Reminders';
  static const String _refillChannelId = 'medicine_refill_channel';
  static const String _refillChannelName = 'Refill & Stock Alerts';
  static const String _dailyTipChannelId = 'daily_health_tips_channel';
  static const String _dailyTipChannelName = 'Daily Morning Health Tips';
  static const int dailyTipNotificationId = 77777;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('health_tip:')) {
          final tipId = payload.substring('health_tip:'.length).trim();
          _handleHealthTipTap(tipId);
        }
      },
    );

    // Check if app was launched by tapping a notification
    try {
      final launchDetails = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null && payload.startsWith('health_tip:')) {
          final tipId = payload.substring('health_tip:'.length).trim();
          _handleHealthTipTap(tipId);
        }
      }
    } catch (_) {}

    // Create Android Notification Channels
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _medicineChannelId,
            _medicineChannelName,
            description: 'Daily alerts to take your scheduled medications on time',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _refillChannelId,
            _refillChannelName,
            description: 'Alerts when your medicine strips are almost finished',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _dailyTipChannelId,
            _dailyTipChannelName,
            description: 'Daily morning inspirational health and wellness tips',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
    }

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true;
  }

  /// Schedule daily notifications for an active medicine reminder
  Future<void> scheduleMedicineReminder(MedicineReminderModel reminder) async {
    if (reminder.id == null || !reminder.isActive) return;

    // Slots mapping: id offset
    // morning = base + 1, noon = base + 2, evening = base + 3, night = base + 4
    final baseId = reminder.id! * 10;

    if (reminder.morning) {
      await _scheduleDailySlot(
        notificationId: baseId + 1,
        medicineName: reminder.medicineName,
        timeString: reminder.morningTime,
        slotNameBn: 'সকাল',
        slotNameEn: 'Morning',
        instructions: reminder.instructions,
      );
    } else {
      await cancelNotification(baseId + 1);
    }

    if (reminder.noon) {
      await _scheduleDailySlot(
        notificationId: baseId + 2,
        medicineName: reminder.medicineName,
        timeString: reminder.noonTime,
        slotNameBn: 'দুপুর',
        slotNameEn: 'Noon',
        instructions: reminder.instructions,
      );
    } else {
      await cancelNotification(baseId + 2);
    }

    if (reminder.evening) {
      await _scheduleDailySlot(
        notificationId: baseId + 3,
        medicineName: reminder.medicineName,
        timeString: reminder.eveningTime,
        slotNameBn: 'সন্ধ্যা',
        slotNameEn: 'Evening',
        instructions: reminder.instructions,
      );
    } else {
      await cancelNotification(baseId + 3);
    }

    if (reminder.night) {
      await _scheduleDailySlot(
        notificationId: baseId + 4,
        medicineName: reminder.medicineName,
        timeString: reminder.nightTime,
        slotNameBn: 'রাত',
        slotNameEn: 'Night',
        instructions: reminder.instructions,
      );
    } else {
      await cancelNotification(baseId + 4);
    }
  }

  Future<void> cancelMedicineReminders(int reminderId) async {
    final baseId = reminderId * 10;
    await cancelNotification(baseId + 1);
    await cancelNotification(baseId + 2);
    await cancelNotification(baseId + 3);
    await cancelNotification(baseId + 4);
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> _scheduleDailySlot({
    required int notificationId,
    required String medicineName,
    required String timeString,
    required String slotNameBn,
    required String slotNameEn,
    required String instructions,
  }) async {
    final timeParts = _parseTimeString(timeString);
    final now = DateTime.now();

    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      timeParts.hour,
      timeParts.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _medicineChannelId,
      _medicineChannelName,
      channelDescription: 'Daily alerts to take your scheduled medications on time',
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

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: '💊 ঔষধ খাওয়ার সময় হয়েছে ($slotNameBn)!',
        body: '$medicineName খাওয়ার সময় হয়েছে ($instructions)। অ্যাপে গ্রহণ চিহ্নিত করুন।',
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // In case exact alarm permission is restricted on specific Android vendors
      // fallback gracefully
      // ignore: avoid_print
      print('Notification schedule error: $e');
    }
  }

  /// Show stock refill alert when medicine is running out
  Future<void> showRefillAlert({
    required String medicineName,
    required int remainingStock,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _refillChannelId,
      _refillChannelName,
      channelDescription: 'Alerts when your medicine strips are almost finished',
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

    final notificationId = medicineName.hashCode.abs() % 100000;

    await _flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: '⚠️ ঔষধ শেষ হয়ে আসছে: $medicineName',
      body: 'আপনার কাছে আর মাত্র $remainingStock টি বাকি আছে। ফার্মেসি থেকে নতুন পাতা কিনে রাখুন!',
      notificationDetails: notificationDetails,
    );
  }

  /// Send instant test notification to verify system works
  Future<void> sendTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _medicineChannelId,
      _medicineChannelName,
      channelDescription: 'Daily alerts to take your scheduled medications on time',
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

    await _flutterLocalNotificationsPlugin.show(
      id: 99999,
      title: '🔔 RxDigi নোটিফিকেশন সিস্টেম সক্রিয়!',
      body: 'আপনার ঔষধের অ্যালার্ম ও রিফিল সতর্কবার্তা সফলভাবে চালু রয়েছে।',
      notificationDetails: notificationDetails,
    );
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final trimmed = timeStr.trim().toUpperCase();
      final isPm = trimmed.contains('PM');
      final isAm = trimmed.contains('AM');

      final clean = trimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = clean.split(':');
      var hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());

      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  /// Handle user tapping on a health tip notification
  Future<void> _handleHealthTipTap(String tipId) async {
    try {
      final repo = HealthTipsRepository();
      final tip = await repo.getTipById(tipId);
      if (tip != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRoutes.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => HealthTipDetailScreen(tip: tip),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error navigating to health tip details: $e');
    }
  }

  /// Schedule daily morning health tip notification (e.g., at 8:00 AM)
  Future<void> scheduleDailyMorningHealthTip({
    required String tipId,
    required String title,
    required String body,
    int hour = 8,
    int minute = 0,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _dailyTipChannelId,
      _dailyTipChannelName,
      channelDescription: 'Daily morning inspirational health and wellness tips',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: dailyTipNotificationId,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'health_tip:$tipId',
      );
      debugPrint('☀️ Daily Morning Health Tip scheduled for $hour:${minute.toString().padLeft(2, '0')} (Tip: $tipId)');
    } catch (e) {
      debugPrint('Daily health tip schedule error: $e');
    }
  }

  /// Show instant health tip notification (useful for testing and instant delivery)
  Future<void> showDailyHealthTipInstantNotification({
    required String tipId,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _dailyTipChannelId,
      _dailyTipChannelName,
      channelDescription: 'Daily morning inspirational health and wellness tips',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    await _flutterLocalNotificationsPlugin.show(
      id: dailyTipNotificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: 'health_tip:$tipId',
    );
  }

  /// Cancel scheduled daily morning health tip
  Future<void> cancelDailyMorningHealthTip() async {
    await _flutterLocalNotificationsPlugin.cancel(id: dailyTipNotificationId);
  }
}

