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
}
