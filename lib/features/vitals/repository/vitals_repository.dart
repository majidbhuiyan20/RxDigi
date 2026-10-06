import 'package:sqflite/sqflite.dart';
import '../../../core/data/database/database_helper.dart';
import '../models/vital_log_model.dart';

class VitalsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertVital(VitalLogModel vital) async {
    final db = await _databaseHelper.database;
    return await db.insert('user_vitals', vital.toMap());
  }

  Future<List<VitalLogModel>> getAllVitals() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vitals',
      orderBy: 'recordedAt DESC',
    );
    return maps.map((map) => VitalLogModel.fromMap(map)).toList();
  }

  Future<List<VitalLogModel>> getVitalsByType(String type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vitals',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'recordedAt DESC',
    );
    return maps.map((map) => VitalLogModel.fromMap(map)).toList();
  }

  Future<VitalLogModel?> getLatestVital(String type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vitals',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'recordedAt DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return VitalLogModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteVital(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'user_vitals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
