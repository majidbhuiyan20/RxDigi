import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/doctor_model.dart';
import 'base_repository.dart';

class DoctorRepository extends BaseRepository<DoctorModel> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<List<DoctorModel>> getAll() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('doctors');
      return result.map((map) => DoctorModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  @override
  Future<DoctorModel?> getById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'doctors',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return DoctorModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error fetching doctor: $e');
      return null;
    }
  }

  @override
  Future<int> insert(DoctorModel model) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert('doctors', model.toMap());
    } catch (e) {
      print('Error inserting doctor: $e');
      return -1;
    }
  }

  @override
  Future<void> update(DoctorModel model) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'doctors',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('Error updating doctor: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'doctors',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting doctor: $e');
    }
  }

  Future<DoctorModel?> getLatestDoctor() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'doctors',
        orderBy: 'createdAt DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        return DoctorModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error fetching latest doctor: $e');
      return null;
    }
  }
}
