import 'package:prescripto/core/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medicine_reminder_model.dart';
import '../models/medicine_adherence_model.dart';

class MedicineReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertReminder(MedicineReminderModel reminder) async {
    final db = await _dbHelper.database;
    return await db.insert('medicine_reminders', reminder.toMap());
  }

  Future<List<MedicineReminderModel>> getActiveReminders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicine_reminders',
      where: 'isActive = 1',
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => MedicineReminderModel.fromMap(m)).toList();
  }

  Future<List<MedicineReminderModel>> getAllReminders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicine_reminders',
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => MedicineReminderModel.fromMap(m)).toList();
  }

  Future<int> updateReminder(MedicineReminderModel reminder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'medicine_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> toggleReminderActive(int id, bool isActive) async {
    final db = await _dbHelper.database;
    return await db.update(
      'medicine_reminders',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await _dbHelper.database;
    await db.delete('medicine_adherence_logs', where: 'reminderId = ?', whereArgs: [id]);
    return await db.delete('medicine_reminders', where: 'id = ?', whereArgs: [id]);
  }

  /// Toggle adherence for a specific reminder and slot on a date
  Future<void> setAdherence({
    required int reminderId,
    required String date,
    required String slot,
    required bool isTaken,
  }) async {
    final db = await _dbHelper.database;
    if (isTaken) {
      await db.insert(
        'medicine_adherence_logs',
        {
          'reminderId': reminderId,
          'date': date,
          'slot': slot,
          'isTaken': 1,
          'takenAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        'medicine_adherence_logs',
        where: 'reminderId = ? AND date = ? AND slot = ?',
        whereArgs: [reminderId, date, slot],
      );
    }
  }

  /// Returns map of key: "${reminderId}_${slot}" -> bool isTaken
  Future<Map<String, bool>> getAdherenceMapForDate(String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> logs = await db.query(
      'medicine_adherence_logs',
      where: 'date = ? AND isTaken = 1',
      whereArgs: [date],
    );

    final map = <String, bool>{};
    for (final log in logs) {
      final rId = log['reminderId'];
      final slot = log['slot'] as String;
      map['${rId}_$slot'] = true;
    }
    return map;
  }

  Future<void> decrementStock(int reminderId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE medicine_reminders 
      SET currentStock = CASE WHEN currentStock > 0 THEN currentStock - 1 ELSE 0 END
      WHERE id = ? AND totalStock > 0
    ''', [reminderId]);
  }

  Future<void> incrementStock(int reminderId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE medicine_reminders 
      SET currentStock = currentStock + 1
      WHERE id = ? AND totalStock > 0
    ''', [reminderId]);
  }

  Future<void> refillStock(int reminderId, int addedStock) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE medicine_reminders 
      SET currentStock = currentStock + ?, totalStock = totalStock + ?
      WHERE id = ?
    ''', [addedStock, addedStock, reminderId]);
  }

  Future<WeeklyAdherenceReport> getWeeklyAdherenceReport() async {
    final db = await _dbHelper.database;
    final allMeds = await getAllReminders();

    final now = DateTime.now();
    final List<DailyAdherenceStat> dailyStats = [];
    int totalScheduledActiveDays = 0;
    int totalTakenActiveDays = 0;

    const bnDayNames = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
    const enDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // For this specific date, calculate how many doses were actually scheduled
      int scheduledForDay = 0;
      final isToday = (i == 0);
      final currentHour = now.hour;

      final adherenceLogs = await db.query(
        'medicine_adherence_logs',
        where: 'date = ? AND isTaken = 1',
        whereArgs: [dateStr],
      );
      final takenSlotsSet = <String>{};
      for (final row in adherenceLogs) {
        final rId = row['reminderId'];
        final slot = row['slot'];
        takenSlotsSet.add('${rId}_$slot');
      }
      final takenCount = adherenceLogs.length;

      for (final med in allMeds) {
        // If the date is BEFORE the medicine was started, do not schedule
        if (dateStr.compareTo(med.startDate) < 0) {
          continue;
        }
        // If durationDays > 0, check if past end date
        if (med.durationDays > 0) {
          final start = DateTime.tryParse(med.startDate);
          if (start != null) {
            final end = start.add(Duration(days: med.durationDays));
            if (date.isAfter(end)) continue;
          }
        }
        if (!isToday) {
          if (med.morning) scheduledForDay++;
          if (med.noon) scheduledForDay++;
          if (med.evening) scheduledForDay++;
          if (med.night) scheduledForDay++;
        } else {
          // For today, only count doses whose time window has passed or were taken
          if (med.morning) {
            if (currentHour >= 12 || takenSlotsSet.contains('${med.id}_morning')) scheduledForDay++;
          }
          if (med.noon) {
            if (currentHour >= 17 || takenSlotsSet.contains('${med.id}_noon')) scheduledForDay++;
          }
          if (med.evening) {
            if (currentHour >= 21 || takenSlotsSet.contains('${med.id}_evening')) scheduledForDay++;
          }
          if (med.night) {
            if (currentHour >= 21 || takenSlotsSet.contains('${med.id}_night')) scheduledForDay++;
          }
        }
      }

      final weekdayIndex = date.weekday - 1;
      final dayNameBn = bnDayNames[weekdayIndex];
      final dayNameEn = enDayNames[weekdayIndex];

      if (scheduledForDay > 0) {
        totalScheduledActiveDays += scheduledForDay;
        totalTakenActiveDays += takenCount;
      }

      dailyStats.add(DailyAdherenceStat(
        date: date,
        dateString: dateStr,
        dayNameBn: dayNameBn,
        dayNameEn: dayNameEn,
        totalScheduled: scheduledForDay,
        totalTaken: takenCount,
      ));
    }

    int streak = 0;
    for (int i = dailyStats.length - 1; i >= 0; i--) {
      final stat = dailyStats[i];
      if (stat.totalScheduled > 0 && stat.totalTaken >= stat.totalScheduled) {
        streak++;
      } else if (i == dailyStats.length - 1 && stat.totalScheduled > 0) {
        if (stat.totalTaken > 0) streak++;
        continue;
      } else if (stat.totalScheduled == 0) {
        // Days before user began tracking do not break the streak
        continue;
      } else {
        break;
      }
    }

    final rate = totalScheduledActiveDays > 0
        ? (totalTakenActiveDays / totalScheduledActiveDays).clamp(0.0, 1.0)
        : 1.0;
    final missed = totalScheduledActiveDays > totalTakenActiveDays
        ? (totalScheduledActiveDays - totalTakenActiveDays)
        : 0;

    return WeeklyAdherenceReport(
      adherenceRate: rate,
      totalTaken: totalTakenActiveDays,
      totalScheduled: totalScheduledActiveDays,
      currentStreak: streak,
      missedDoses: missed,
      dailyStats: dailyStats,
    );
  }
}

