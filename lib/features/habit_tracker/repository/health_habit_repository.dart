import 'package:sqflite/sqflite.dart';
import '../../../core/data/database/database_helper.dart';
import '../models/health_habit_model.dart';

class HealthHabitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<HealthHabitModel>> getActiveHabits() async {
    final db = await _dbHelper.database;
    var rows = await db.query('health_habits', where: 'isActive = 1', orderBy: 'createdAt ASC');
    if (rows.isEmpty) {
      final now = DateTime.now().toIso8601String();
      final defaults = [
        HealthHabitModel(title: 'Drink 8 glasses of water', category: 'Nutrition', icon: 'water_drop', color: '#1E88E5', createdAt: now),
        HealthHabitModel(title: 'Walk for 30 minutes', category: 'Exercise', icon: 'directions_walk', color: '#00897B', createdAt: now),
        HealthHabitModel(title: 'Sleep 7-8 hours', category: 'Sleep', icon: 'bedtime', color: '#5E35B1', createdAt: now),
        HealthHabitModel(title: 'Check BP or sugar', category: 'Vitals', icon: 'monitor_heart', color: '#E53935', createdAt: now),
        HealthHabitModel(title: 'Eat a healthy meal', category: 'Nutrition', icon: 'restaurant', color: '#FB8C00', createdAt: now),
        HealthHabitModel(title: 'Take medicines on time', category: 'Medicine', icon: 'medication', color: '#00897B', createdAt: now),
        HealthHabitModel(title: 'Avoid smoking today', category: 'Wellness', icon: 'health_and_safety', color: '#546E7A', createdAt: now),
      ];
      for (final habit in defaults) {
        await db.insert('health_habits', habit.toMap());
      }
      rows = await db.query('health_habits', where: 'isActive = 1', orderBy: 'createdAt ASC');
    }
    return rows.map(HealthHabitModel.fromMap).toList();
  }

  Future<int> insertHabit(HealthHabitModel habit) async {
    final db = await _dbHelper.database;
    return db.insert('health_habits', habit.toMap());
  }

  Future<void> deleteHabit(int id) async {
    final db = await _dbHelper.database;
    await db.delete('habit_logs', where: 'habitId = ?', whereArgs: [id]);
    await db.delete('health_habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<Set<int>> getCompletedHabitIds(String date) async {
    final db = await _dbHelper.database;
    final rows = await db.query('habit_logs', where: 'date = ? AND completed = 1', whereArgs: [date]);
    return rows.map((row) => row['habitId'] as int).toSet();
  }

  Future<void> setCompleted({required int habitId, required String date, required bool completed}) async {
    final db = await _dbHelper.database;
    if (completed) {
      await db.insert(
        'habit_logs',
        {
          'habitId': habitId,
          'date': date,
          'completed': 1,
          'completedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete('habit_logs', where: 'habitId = ? AND date = ?', whereArgs: [habitId, date]);
    }
  }

  Future<Map<String, int>> getDailyCompletedCounts(List<String> dates) async {
    if (dates.isEmpty) return {};
    final db = await _dbHelper.database;
    final rows = await db.query(
      'habit_logs',
      columns: ['date', 'COUNT(*) AS count'],
      where: 'date IN (${List.filled(dates.length, '?').join(',')}) AND completed = 1',
      whereArgs: dates,
      groupBy: 'date',
    );
    return {for (final row in rows) row['date'] as String: row['count'] as int};
  }
}
