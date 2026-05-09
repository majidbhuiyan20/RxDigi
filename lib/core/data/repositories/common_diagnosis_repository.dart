import '../database/database_helper.dart';

class CommonDiagnosisRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<String>> getCommonDiagnosis() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'common_diagnosis',
      orderBy: 'usageCount DESC, lastUsed DESC',
      limit: 20,
    );
    return result.map((map) => map['name'] as String).toList();
  }

  Future<void> addOrUpdateDiagnosis(String name) async {
    if (name.trim().isEmpty) return;
    final db = await _databaseHelper.database;
    final trimmedName = name.trim();

    final exists = await db.query(
      'common_diagnosis',
      where: 'name = ?',
      whereArgs: [trimmedName],
    );

    if (exists.isNotEmpty) {
      final count = (exists.first['usageCount'] as int) + 1;
      await db.update(
        'common_diagnosis',
        {
          'usageCount': count,
          'lastUsed': DateTime.now().toIso8601String(),
        },
        where: 'name = ?',
        whereArgs: [trimmedName],
      );
    } else {
      await db.insert('common_diagnosis', {
        'name': trimmedName,
        'usageCount': 1,
        'lastUsed': DateTime.now().toIso8601String(),
      });
    }
  }
}
