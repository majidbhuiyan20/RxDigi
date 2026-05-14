import '../database/database_helper.dart';

class CommonLabTestRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<String>> getCommonLabTests() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'common_lab_tests',
      orderBy: 'usageCount DESC, lastUsed DESC',
      limit: 20,
    );
    return result.map((map) => map['name'] as String).toList();
  }

  Future<void> addOrUpdateLabTest(String name) async {
    if (name.trim().isEmpty) return;
    final db = await _databaseHelper.database;
    final trimmedName = name.trim();

    final exists = await db.query(
      'common_lab_tests',
      where: 'name = ?',
      whereArgs: [trimmedName],
    );

    if (exists.isNotEmpty) {
      final count = (exists.first['usageCount'] as int) + 1;
      await db.update(
        'common_lab_tests',
        {
          'usageCount': count,
          'lastUsed': DateTime.now().toIso8601String(),
        },
        where: 'name = ?',
        whereArgs: [trimmedName],
      );
    } else {
      await db.insert('common_lab_tests', {
        'name': trimmedName,
        'usageCount': 1,
        'lastUsed': DateTime.now().toIso8601String(),
      });
    }
  }
}
