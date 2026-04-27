import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/medicine_model.dart';
import 'base_repository.dart';

class MedicineRepository extends BaseRepository<MedicineModel> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const String _csvPath = 'assets/file/medicine.csv';

  @override
  Future<List<MedicineModel>> getAll() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('medicines');
      return result.map((map) => MedicineModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }

  @override
  Future<MedicineModel?> getById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'medicines',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return MedicineModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error fetching medicine: $e');
      return null;
    }
  }

  @override
  Future<int> insert(MedicineModel model) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert('medicines', model.toMap());
    } catch (e) {
      print('Error inserting medicine: $e');
      return -1;
    }
  }

  @override
  Future<void> update(MedicineModel model) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'medicines',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('Error updating medicine: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'medicines',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting medicine: $e');
    }
  }

  Future<void> loadMedicinesFromCsv() async {
    try {
      final db = await _databaseHelper.database;
      
      // Check if medicines already loaded
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM medicines'),
      );
      
      if (count != null && count > 0) {
        print('Medicines already loaded');
        return;
      }

      // Load CSV file
      final csvString = await rootBundle.loadString(_csvPath);
      final List<List<dynamic>> rows = CsvToListConverter().convert(csvString);

      // Skip header row and insert medicines
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isNotEmpty) {
          final medicine = MedicineModel.fromCsv(
            row.map((e) => e.toString()).toList(),
          );
          await insert(medicine);
        }
      }
      print('Medicines loaded from CSV successfully');
    } catch (e) {
      print('Error loading medicines from CSV: $e');
    }
  }

  Future<List<MedicineModel>> searchMedicines(String query) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'medicines',
        where: 'name LIKE ? OR genericName LIKE ? OR manufacturer LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );
      return result.map((map) => MedicineModel.fromMap(map)).toList();
    } catch (e) {
      print('Error searching medicines: $e');
      return [];
    }
  }

  Future<List<MedicineModel>> getMedicinesByStrength(String strength) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'medicines',
        where: 'strength LIKE ?',
        whereArgs: ['%$strength%'],
      );
      return result.map((map) => MedicineModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching medicines by strength: $e');
      return [];
    }
  }
}
