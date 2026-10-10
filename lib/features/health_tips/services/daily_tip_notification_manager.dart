import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';
import '../models/health_tip_model.dart';
import '../repository/health_tips_repository.dart';

class DailyTipNotificationManager {
  static const String _prefKeyEnabled = 'rxdigi_daily_tip_notification_enabled';
  static const String _prefKeyHour = 'rxdigi_daily_tip_notification_hour';
  static const String _prefKeyMinute = 'rxdigi_daily_tip_notification_minute';

  static final DailyTipNotificationManager _instance =
      DailyTipNotificationManager._internal();
  factory DailyTipNotificationManager() => _instance;
  DailyTipNotificationManager._internal();

  final HealthTipsRepository _repository = HealthTipsRepository();
  final NotificationService _notificationService = NotificationService();

  /// Check if daily morning notification is enabled (default: true)
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyEnabled) ?? true;
  }

  /// Get scheduled morning time (default: 8:00 AM)
  Future<TimeOfDay> getScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefKeyHour) ?? 8;
    final minute = prefs.getInt(_prefKeyMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Set preferred morning time
  Future<void> setScheduledTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyHour, time.hour);
    await prefs.setInt(_prefKeyMinute, time.minute);
    await scheduleNextDailyTip();
  }

  /// Toggle daily tip notification on/off
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enabled);
    if (enabled) {
      await scheduleNextDailyTip();
    } else {
      await _notificationService.cancelDailyMorningHealthTip();
    }
  }

  /// Selects the tip of the day from 1050+ tips using a day-of-year rotation
  Future<HealthTipModel?> getTipOfDay([DateTime? targetDate]) async {
    final tips = await _repository.getAllTips();
    if (tips.isEmpty) return null;
    final date = targetDate ?? DateTime.now();
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final index = dayOfYear % tips.length;
    return tips[index];
  }

  /// Schedules daily 8:00 AM morning notification for the tip of the day
  Future<void> scheduleNextDailyTip() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    final time = await getScheduledTime();
    final tip = await getTipOfDay();
    if (tip == null) return;

    final title = '🌿 আজকের স্বাস্থ্য টিপস (${tip.categoryBn})';
    final body = '${tip.titleBn} — বিস্তারিত জানতে ট্যাপ করুন।';

    await _notificationService.scheduleDailyMorningHealthTip(
      tipId: tip.id,
      title: title,
      body: body,
      hour: time.hour,
      minute: time.minute,
    );
  }

  /// Instantly shows the tip notification to verify banner and tap navigation
  Future<void> sendInstantTestNotification({HealthTipModel? customTip}) async {
    final tip = customTip ?? await getTipOfDay();
    if (tip == null) return;

    final title = '🌿 আজকের স্বাস্থ্য টিপস (${tip.categoryBn})';
    final body = '${tip.titleBn} — বিস্তারিত জানতে ট্যাপ করুন।';

    await _notificationService.showDailyHealthTipInstantNotification(
      tipId: tip.id,
      title: title,
      body: body,
    );
  }
}

