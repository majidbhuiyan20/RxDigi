
import '../database/database_helper.dart';
import '../models/patient_model.dart';
import 'base_repository.dart';

class PatientRepository extends BaseRepository<PatientModel> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<List<PatientModel>> getAll() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('patients', orderBy: 'createdAt DESC');
      return result.map((map) => PatientModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching patients: $e');
      return [];
    }
  }

  @override
  Future<PatientModel?> getById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return PatientModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error fetching patient: $e');
      return null;
    }
  }

  @override
  Future<int> insert(PatientModel model) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert('patients', model.toMap());
    } catch (e) {
      print('Error inserting patient: $e');
      return -1;
    }
  }

  @override
  Future<void> update(PatientModel model) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'patients',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('Error updating patient: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting patient: $e');
    }
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'patients',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'createdAt DESC',
      );
      return result.map((map) => PatientModel.fromMap(map)).toList();
    } catch (e) {
      print('Error searching patients: $e');
      return [];
    }
  }
}
