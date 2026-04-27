import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/prescription_model.dart';
import 'base_repository.dart';

class PrescriptionRepository extends BaseRepository<PrescriptionModel> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<List<PrescriptionModel>> getAll() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('prescriptions', orderBy: 'createdAt DESC');
      return result.map((map) => PrescriptionModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching prescriptions: $e');
      return [];
    }
  }

  @override
  Future<PrescriptionModel?> getById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'prescriptions',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return PrescriptionModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error fetching prescription: $e');
      return null;
    }
  }

  @override
  Future<int> insert(PrescriptionModel model) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert('prescriptions', model.toMap());
    } catch (e) {
      print('Error inserting prescription: $e');
      return -1;
    }
  }

  @override
  Future<void> update(PrescriptionModel model) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'prescriptions',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('Error updating prescription: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'prescriptions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting prescription: $e');
    }
  }

  Future<List<PrescriptionModel>> getPrescriptionsByPatient(int patientId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'prescriptions',
        where: 'patientId = ?',
        whereArgs: [patientId],
        orderBy: 'createdAt DESC',
      );
      return result.map((map) => PrescriptionModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching patient prescriptions: $e');
      return [];
    }
  }

  Future<List<PrescriptionModel>> getPrescriptionsByDoctor(int doctorId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'prescriptions',
        where: 'doctorId = ?',
        whereArgs: [doctorId],
        orderBy: 'createdAt DESC',
      );
      return result.map((map) => PrescriptionModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching doctor prescriptions: $e');
      return [];
    }
  }
}
