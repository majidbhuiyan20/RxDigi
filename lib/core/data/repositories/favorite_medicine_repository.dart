import '../database/database_helper.dart';
import '../models/medicine_model.dart';

class FavoriteMedicineRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<MedicineModel>> getFavorites() async {
    final db = await _databaseHelper.database;
    final result = await db.query('favorite_medicines', orderBy: 'createdAt DESC');
    return result.map((map) => MedicineModel(
      id: map['medicineId'] as int?,
      name: map['name'] as String,
      genericName: map['genericName'] as String?,
      dosageForm: map['dosageForm'] as String?,
      strength: map['strength'] as String?,
    )).toList();
  }

  Future<int> addFavorite(MedicineModel medicine) async {
    final db = await _databaseHelper.database;
    // Check if already exists
    final exists = await db.query(
      'favorite_medicines',
      where: 'name = ? AND dosageForm = ?',
      whereArgs: [medicine.name, medicine.dosageForm],
    );
    if (exists.isNotEmpty) return -1;

    return await db.insert('favorite_medicines', {
      'medicineId': medicine.id,
      'name': medicine.name,
      'genericName': medicine.genericName,
      'dosageForm': medicine.dosageForm,
      'strength': medicine.strength,
    });
  }

  Future<void> removeFavorite(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('favorite_medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeFavoriteByMedicine(MedicineModel medicine) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'favorite_medicines',
      where: 'name = ? AND dosageForm = ?',
      whereArgs: [medicine.name, medicine.dosageForm],
    );
  }
}
