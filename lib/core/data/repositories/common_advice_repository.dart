import '../database/database_helper.dart';

class CommonAdviceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<String>> getCommonAdvice() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'common_advice',
      orderBy: 'usageCount DESC, lastUsed DESC',
      limit: 20,
    );
    return result.map((map) => map['name'] as String).toList();
  }

  Future<void> addOrUpdateAdvice(String name) async {
    if (name.trim().isEmpty) return;
    final db = await _databaseHelper.database;
    final trimmedName = name.trim();

    final exists = await db.query(
      'common_advice',
      where: 'name = ?',
      whereArgs: [trimmedName],
    );

    if (exists.isNotEmpty) {
      final count = (exists.first['usageCount'] as int) + 1;
      await db.update(
        'common_advice',
        {
          'usageCount': count,
          'lastUsed': DateTime.now().toIso8601String(),
        },
        where: 'name = ?',
        whereArgs: [trimmedName],
      );
    } else {
      await db.insert('common_advice', {
        'name': trimmedName,
        'usageCount': 1,
        'lastUsed': DateTime.now().toIso8601String(),
      });
    }
  }
}
